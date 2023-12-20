{ networking, modulesPath, lib, config, pkgs, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];
  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  fileSystems."/" = { 
    device = "/dev/disk/by-uuid/cf9a7695-02fa-4367-8ab1-a63521fe7c96";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/DC45-9E87";
    fsType = "vfat";
  };
  swapDevices = [
    { device = "/dev/disk/by-uuid/e55223ae-0e5c-4a4a-97e1-2ea4ac309d36"; }
  ];
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  #networking.interfaces.enp0s31f6.useDHCP = true; # old laptop
  networking.interfaces.wlp0s20f3.useDHCP = true;
  networking.hostName = "x1";
  networking.wireless.interfaces = [ "wlp0s20f3" ];

  programs.light.enable = true;
  #hardware.acpilight.enable = true; # TODO still desirable?
  services.actkbd = {
    enable = true;
    bindings = [
      # mute:
      { keys = [ 113 ]; events = [ "key" ]; command = "${pkgs.alsa-utils}/bin/amixer -q set Master toggle"; }
      # volume down
      { keys = [ 114 ]; events = [ "key" ]; command = "${pkgs.alsa-utils}/bin/amixer -q set Master 1%-"; }
      # volume up
      { keys = [ 115 ]; events = [ "key" ]; command = "${pkgs.alsa-utils}/bin/amixer -q set Master 1%+"; }
      # mute toggle microphone
      { keys = [ 190 ]; events = [ "key" ]; command = "${pkgs.alsa-utils}/bin/amixer -q set Capture toggle"; }
      # screen backlight, darker, brighter respectively:
      { keys = [ 224 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -U 10"; }
      { keys = [ 225 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -A 10"; }
    ];
  };
  # TODO consider factoring out to sitecheck.nix file?
  #### Services/Jobs
  # example here: https://discourse.nixos.org/t/syncthing-systemd-user-service/11199/6
  # verify running with `systemctl list-timers --user`
  systemd.user.services.site_check = {
    description = "Notify user if aaronhall.dev is down.";
    wantedBy = [ "default.target" "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
    };
    path = with pkgs; [ 
      libnotify
      curl
    ];
    script = ''
      curl --silent --show-error https://aaronhall.dev || \
        notify-send -t 57000 -c 'network' 'Site Down' \
        'aaronhall.dev is down!'
        # '<a href="https://aaronhall.dev">aaronhall.dev</a> is down!'
    ''; # TODO wayland notification not parsing html anchor tag
  };
  systemd.user.timers.site_check = {
    wantedBy = [ "default.target" ];
    partOf = [ "site_check.service" ];
    timerConfig.OnCalendar = "minutely";
  };
  services.k3s = {
    enable = true;
    # chmod?
    # role = "server";
    /* server by default, runs workloads as agent too 
      If it’s a server:
    By default it also runs workloads as an agent.
    Starts by default as a standalone server using an embedded sqlite datastore.
    Configure clusterInit = true to switch over to embedded etcd datastore and enable HA mode.
    Configure serverAddr to join an already-initialized HA cluster.
    If it’s an agent serverAddr is required.
    */
    clusterInit = true;
  };
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?
}
