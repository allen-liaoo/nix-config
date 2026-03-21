{ config, lib, aln, pkgs, ... }@args:

let
  name = "authelia";
  db_name = name + "_db";
  pod_name = name + "-pod";
  logs_volume_name = name + "_logs";
  users_database = import ./users_database.nix; 
  # sops of user hashed passwords
  password_sops_name_from_user = (name: "authelia_users_${name}_password_hashed");
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
        in [
          "${authelia_conf}:/config/configuration.yml:ro"
          "${config.sops.templates.users_database.path}:/config/users_database.yml:ro"
          "${volumes.${logs_volume_name}.ref}:/logs:rw"

          "${config.sops.secrets.authelia_session_secret.path}:/run/secrets/session_secret:ro"
          "${config.sops.secrets.authelia_storage_encryption_key.path}:/run/secrets/storage_encryption_key:ro"
          "${config.sops.secrets.authelia_postgres_password.path}:/run/secrets/postgres_password:ro"
          "${config.sops.secrets.authelia_oidc_jwk_key_priv.path}:/run/secrets/oidc_jwk_key_priv:ro"
        ];
        environments = {
          X_AUTHELIA_CONFIG = "/config/configuration.yml";
          X_AUTHELIA_CONFIG_FILTERS = "template";
        };
        healthCmd = "/app/healthcheck.sh";
        healthInterval = "5m";
        healthStartPeriod = "5s";
      };
      unitConfig = {
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

  sops.secrets =
    # secrets for authelia to function
    (lib.genAttrs
      [
        "authelia_session_secret"
        "authelia_storage_encryption_key"
        "authelia_postgres_password"
        "authelia_oidc_jwk_key_priv"
      ]
      (secret_key: {
        # key in sops is: authelia/secret_key_without_authelia_prefix
        key = "authelia/" + builtins.substring 9 (builtins.stringLength secret_key) secret_key;
      }))
    //
    # secrets for users of authelia
    # in secrets/authelia_users.yaml
    (lib.mapAttrs' (user_name: _user: lib.nameValuePair (password_sops_name_from_user user_name) {
        sopsFile = aln.lib.relToRoot "secrets/authelia_users.yaml";
        key = "${user_name}/password_hashed";
      }) users_database.users);

  # inject secret as env var to db
  sops.templates.authelia_db_env = {
    mode = "0400";
    content = ''
      POSTGRES_PASSWORD=${config.sops.placeholder.authelia_postgres_password}
    '';
  };

  # generate users_database.yml from users_database.nix and add password from sops secrets
  sops.templates.users_database = {
    mode = "0400";
    # json is subset of yaml
    content = builtins.toJSON {
      users = lib.mapAttrs (user_name: user:
        user // {
          password = config.sops.placeholder.${password_sops_name_from_user user_name};
        }
      ) users_database.users;
    };
  };
}
