{ ... }:

{
  imports = [
    ./root
    ./user
  ];

  users.mutableUsers = false; # DECLARATIVE USERS!! :3
}
