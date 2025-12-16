{ ... }:

{
  imports = [
    ./root
    ./user
  ];

  home-manager.sharedModules = [
    {
      imports = [
        ../modules/home-manager
      ];
    }
  ];

  users.mutableUsers = false; # DECLARATIVE USERS!! :3
}
