{pkgs, ...}: let

  # TODO remove screensharing hacks - put in accessory file, maybe? I don't even use them... OBS ftw
  # see https://nixos.wiki/wiki/Sway, below are added to systemPackages:
  dbus-sway-environment = pkgs.writeTextFile {
    name = "dbus-sway-environment";
    destination = "/bin/dbus-sway-environment";
    executable = true;
    text = ''
  dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
  systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
  systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
      '';
  };
  configure-gtk = pkgs.writeTextFile {
    name = "configure-gtk";
    destination = "/bin/configure-gtk";
    executable = true;
    text = let
      schema = pkgs.gsettings-desktop-schemas;
      datadir = "${schema}/share/gsettings-schemas/${schema.name}";
    in ''
      export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
      gnome_schema=org.gnome.desktop.interface
      gsettings set $gnome_schema gtk-theme 'Dracula'
      '';
  };
in {
  # hack to screenshare here:
  # https://github.com/NixOS/nixpkgs/issues/57602#issuecomment-677841677
  programs.sway = {
    # enable = true; # enabled already?
    wrapperFeatures.gtk = true; # adding because wiki
  };
  # attempt getting screensharing working in sway:
  xdg = {
    portal = {
      enable = true;
      # see https://github.com/NixOS/nixpkgs/blob/nixos-22.05/nixos/modules/config/xdg/portals/wlr.nix
      wlr.enable = true; # I thought this was wrong? see below link for supported values in settings
      extraPortals = with pkgs; [
        # see screencast example INI file at https://man.archlinux.org/man/xdg-desktop-portal-wlr.5
        xdg-desktop-portal-wlr # but is this redundant?
        xdg-desktop-portal-gtk # TODO test removing, because I don't want gnome...
      ];
      gtkUsePortal = true; #22.11 complains
    };
  };
  services.dbus.enable = true;  # from sway wiki entry
  environment.systemPackages = with pkgs; [
    dbus-sway-environment
    configure-gtk
  ];
}
