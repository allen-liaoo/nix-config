# metadata of hosts and users
{...}:

let
  system = {
    x86_linux = "x86_64-linux";
  };
in rec
{
  meta = {
    hosts = {
      # vm
      guinea = {
        name = "guinea";
        system = system.x86_linux;
        users = with users [ pig.name ];
      };
    };
  
    users = {
      # vm user
      pig = {
        name = "pig";
        primary = true;
      };
    };
  };
}
