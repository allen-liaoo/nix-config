{ config, lib, aln, pkgs, ... }:

let
  name = "authelia";
  db_name = name + "_db";
  pod_name = name + "-pod";
  logs_volume_name = name + "_logs";
  users_db = (aln.lib.withPkgs pkgs).fromYaml ./users_database.yml;
  # names of authelia users
  user_names = builtins.attrNames users_db.users;
  user_secrets = lib.genAttrs user_names (name: {
      name = "authelia_users_${name}_password_hashed";
      key = "${name}/password_hashed";
      mountPath = "/run/secrets/${name}/password_hashed";
  });
in
{
  virtualisation.quadlet = let
    inherit (config.virtualisation.quadlet) containers images pods volumes;
  in {
    # authelia container
    containers.${name} = aln.lib.mkContainer name {
      containerConfig = {
        image = images.${name}.ref;
        pod = pods.${pod_name}.ref;
        startWithPod = true;
        volumes = let
          authelia_conf = config.lib.file.mkOutOfStoreSymlink (aln.lib.outOfStoreRelToRoot config.home.homeDirectory ./configuration.yml);
          #users_db = config.lib.file.mkOutOfStoreSymlink (aln.lib.outOfStoreRelToRoot config.home.homeDirectory ./users_database.yml);
        in [
          "${authelia_conf}:/config/configuration.yml:ro"
          "${config.sops.templates.users_database.path}:/config/users_database.yml:ro"
          "${volumes.${logs_volume_name}.ref}:/logs:rw"

          "${config.sops.secrets.authelia_session_secret.path}:/run/secrets/session_secret:ro"
          "${config.sops.secrets.authelia_storage_encryption_key.path}:/run/secrets/storage_encryption_key:ro"
          "${config.sops.secrets.authelia_postgres_password.path}:/run/secrets/postgres_password:ro"
          "${config.sops.secrets.authelia_oidc_jwk_key_priv.path}:/run/secrets/oidc_jwk_key_priv:ro"
        ];
        # mount secrets per authelia user
        #(user_secrets
        #|> builtins.attrValues
        #|> map (secret: "${config.sops.secrets.${secret.name}.path}:${secret.mountPath}:ro") user_secret_attrs);
        environments = {
          X_AUTHELIA_CONFIG = "/config/configuration.yml";
          X_AUTHELIA_CONFIG_FILTERS = "template";
        };
        healthCmd = "/app/healthcheck.sh";
        healthInterval = "5m";
        healthStartPeriod = "5s";
      };
      unitConfig.StartLimitBurst = 1;
      serviceConfig = {
        Requires = containers.${db_name}.ref;
        After = containers.${db_name}.ref;
      };
    };

    # authelia database container
    containers.${db_name} = aln.lib.mkContainer db_name {
      containerConfig = {
        image = images.${db_name}.ref;
        pod = pods.${pod_name}.ref;
        startWithPod = true;
        volumes = [
          "${volumes.${db_name}.ref}:/var/lib/postgresql/18/data:rw"
        ];
        environments = {
          POSTGRES_DB = "authelia";
          POSTGRES_USER = "authelia";
        };
        environmentFiles = [ config.sops.templates.authelia_db_env.path ];
      };
    };

    pods.${pod_name} = aln.lib.mkPod pod_name {
      podConfig = {
        publishPorts = [ "9080:80" ];
      };
    };

    images.${name} = aln.lib.mkImage name {
      imageConfig.image = "docker.io/authelia/authelia:latest";
    };

    images.${db_name} = aln.lib.mkImage db_name {
      imageConfig.image = "docker.io/library/postgres:18.1";
    };

    volumes.${logs_volume_name} = aln.lib.mkVolume logs_volume_name {};
    volumes.${db_name} = aln.lib.mkVolume db_name {};
  };

  sops.secrets = (
  # secrets for authelia to function
  lib.genAttrs 
    [
      "authelia_session_secret"
      "authelia_storage_encryption_key"
      "authelia_postgres_password"
      "authelia_oidc_jwk_key_priv"
    ]
    (secret_key: {
      # key in sops is: authelia/secret_key_without_authelia_prefix
      key = "authelia/" + builtins.substring 9 (builtins.stringLength secret_key) secret_key;
    })
  ) //
  # secrets for users of authelia
  # in secrets/authelia_users.yml
  lib.mergeAttrsList (map (secret: {
    ${secret.name} = {
      sopsFile = aln.lib.relToRoot "secrets/authelia_users.yaml";
      key = secret.key;
    };
  }) (builtins.attrValues user_secrets);

  # inject secret as env var to db
  sops.templates.authelia_db_env = {
    mode = "0400";
    content = ''
      POSTGRES_PASSWORD=${config.sops.placeholder.authelia_postgres_password}
    '';
  };

  sops.templates.users_database = {
    mode = "0400";
    content = ''
      users:
      allenliao:
        disabled: false
        displayname: 'Allen Liao'
        email: 'wcliaw610@gmail.com'
        password: '${config.sops.placeholder.${user_secrets.allenliao.name}}'
        groups:
          - 'admin'
          - 'authelia_users'
          - 'traccar_users'
      allenliao_radicale:
        disabled: false
        displayname: 'Allen Liao Radicale'
        email: 'allenliao_radicale@dummy'
        password: '${config.sops.placeholder.${user_secrets.allenliao_radicale.name}}'
        groups:
          - 'radicale_users'
      authelia:
        disabled: false
        displayname: 'Authelia'
        email: 'authelia@dummy'
        password: '${config.sops.placeholder.${user_secrets.authelia.name}}'
        groups:
          - 'service'
      radicale:
        disabled: false
        displayname: 'Radicale'
        email: 'radicale@dummy'
        password: '${config.sops.placeholder.${user_secrets.radicale.name}}'
        groups:
          - 'service'
    '';
  };
}
