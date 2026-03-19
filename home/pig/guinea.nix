{ aln, lib, ... }: 

lib.optionalAttrs (aln.ctx.hostName == "guinea") {
  sops.secrets = {
    "nginx_cert_cloudflare" = {
      sopsFile = aln.lib.relToRoot "secrets/user/pig.yaml";
      mode = "0400";
      key = "nginx/cert_cloudflare";
    };
  };
}
