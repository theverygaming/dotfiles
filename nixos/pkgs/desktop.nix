{ config, pkgs, ... }:

{
  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome = {
    enable = true;
    extraGSettingsOverrides = ''
      # mouse and touchpad
      [org.gnome.desktop.peripherals.touchpad]
      tap-to-click=true
      natural-scroll=false

      # enable minimize, maximize buttons
      [org.gnome.desktop.wm.preferences]
      button-layout=':appmenu,minimize,maximize,close'

      # hell naw to automount and autorun
      # (like ???what this isnt windows)
      [org.gnome.desktop.media-handling]
      automount=false
      automount-open=false
      autorun-never=true

      # set dark theme by default and show seconds on clock
      [org.gnome.desktop.interface]
      clock-show-seconds=true
      color-scheme='prefer-dark'
      gtk-theme='Adwaita-dark'

      # wm tweaks
      [org.gnome.mutter]
      edge-tiling=true
      dynamic-workspaces=true

      # windows screenshot keybind (i'm used to it)
      [org.gnome.shell.keybindings]
      show-screenshot-ui=['<Shift><Super>s']

      # extensions
      [org.gnome.shell]
      enabled-extensions=['runcat@kolesnikov.se', 'appindicatorsupport@rgcjonas.gmail.com', 'clipboard-indicator@tudmotu.com']

      # favorites
      [org.gnome.shell]
      favorite-apps=['org.gnome.Nautilus.desktop', 'google-chrome.desktop', 'discord.desktop', 'code.desktop', 'xfce4-terminal.desktop']

      # MY EYES
      [org.gnome.settings-daemon.plugins.color]
      night-light-enabled=true
      night-light-schedule-automatic=true

      # no i don't want my pc to turn off 10 seconds after i leave
      [org.gnome.settings-daemon.plugins.power]
      sleep-inactive-ac-timeout=6000

      [org.gnome.desktop.session]
      idle-delay=uint32 0

      # recent files are annoying
      [org.gnome.desktop.privacy]
      remember-recent-files=false
    '';
    extraGSettingsOverridePackages = [
      pkgs.gsettings-desktop-schemas # org.gnome.desktop
      pkgs.gnome.gnome-shell # org.gnome.shell
      pkgs.gnome.mutter # org.gnome.mutter
      pkgs.gnome.gnome-settings-daemon # org.gnome.settings-daemon
    ];
  };

  environment.gnome.excludePackages = (with pkgs; [ gnome-tour gnome-photos ])
    ++ (with pkgs.gnome; [
      cheese # webcam tool
      gnome-music
      gnome-terminal
      gedit # text editor
      epiphany # web browser
      geary # email reader
      evince # document viewer
      totem # video player
      tali # poker game
      iagno # go game
      hitori # sudoku game
      atomix # puzzle game
      gnome-maps
      gnome-contacts
      gnome-clocks
      gnome-weather
      gnome-calculator
      gnome-calendar
    ]);

  environment.systemPackages = with pkgs; [
    gnome.gnome-boxes # gnome VNC etc. tool
    gnomeExtensions.appindicator
    gnomeExtensions.runcat
    gnomeExtensions.clipboard-indicator

    xfce.xfce4-terminal
  ];

}
