{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.graphical-desktop;
  xcfg = config.services.xserver;
  dmcfg = config.services.displayManager;
in
{
  options = {
    services.graphical-desktop.enable =
      lib.mkEnableOption "bits and pieces required for a graphical desktop session"
      // {
        default = xcfg.enable || dmcfg.enable;
        defaultText = lib.literalExpression "(config.services.xserver.enable || config.services.displayManager.enable)";
        internal = true;
      };
  };

  config = lib.mkIf cfg.enable {
    environment = {
      # localectl looks into 00-keyboard.conf
      etc."X11/xorg.conf.d/00-keyboard.conf".text = ''
        Section "InputClass"
          Identifier "Keyboard catchall"
          MatchIsKeyboard "on"
          Option "XkbModel" "${xcfg.xkb.model}"
          Option "XkbLayout" "${xcfg.xkb.layout}"
          Option "XkbOptions" "${xcfg.xkb.options}"
          Option "XkbVariant" "${xcfg.xkb.variant}"
        EndSection
      '';
      systemPackages = with pkgs; [
        nixos-icons # needed for gnome and pantheon about dialog, nixos-manual and maybe more
        xdg-utils
      ];
    };

    fonts.enableDefaultPackages = lib.mkDefault true;

    hardware.graphics.enable = lib.mkDefault true;

    programs.gnupg.agent.pinentryPackage = lib.mkOverride 1100 pkgs.pinentry-gnome3;

    services.speechd.enable = lib.mkDefault true;

    services.pipewire = {
      enable = lib.mkDefault true;
      pulse.enable = lib.mkDefault true;
      alsa.enable = lib.mkDefault true;
    };

    systemd.defaultUnit = lib.mkIf (xcfg.autorun || dmcfg.enable) "graphical.target";

    xdg = {
      autostart.enable = true;
      menus.enable = true;
      mime.enable = true;
      icons.enable = true;
      sounds.enable = true;
    };
  };
}
