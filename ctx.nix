{
  lib,
  inventory,
  hostName ? "",
  userName ? ""
}:

{
  host = inventory.hosts.${hostName} or null;
  user = inventory.users.${userName} or null;
}
