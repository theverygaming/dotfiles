{
  config,
  lib,
  pkgs,
  ...
}:
{

  # Make sure graphics drivers are enabled
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Tell Xorg to use the nvidia driver (also valid for Wayland)
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {

    # Modesetting is needed for most Wayland compositors
    modesetting.enable = true;

    # Can apparently break sleep a bit, so lets not for now
    powerManagement.enable = false;

    # can't use the open kernel module because it doesn't support my 1070 sob
    open = false;

    # Enable the nvidia settings menu (nvidia-settings)
    nvidiaSettings = true;

    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}
