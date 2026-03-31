 { pkgs, ... }:

 {
   programs.firefox.profiles.default.search = {
     default = "ddg";
     force = true;
     order = [ "ddg" "mynixos" ];
     engines = {
       mynixos = {
         name = "MyNixOS";
         urls = [{ template = "https://mynixos.com/search?q={searchTerms}"; }];
         icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
         definedAliases = [ "@n" ];
       };
       "google".metaData.hidden = true;
       "amazondotcom-us".metaData.hidden = true;
       "bing".metaData.hidden = true;
       "ebay".metaData.hidden = true;
       "perplexity".metaData.hidden = true;
       "wikipedia".metaData.hidden = true;
     };
   };
 }
