{ config, lib, pkgs, modulesPath, ... }:

{
  system.stateVersion = "26.05";
  # hardware-configuration.nix stuff:
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];
  fileSystems."/" =
    { device = "rootpool/root";
      fsType = "zfs";
    };
  fileSystems."/backups" =
    { device = "datapool/backups";
      fsType = "zfs";
    };
  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/7b747b7b-826f-48c0-9313-acc057c03263";
      fsType = "ext4";
    };
  fileSystems."/data" =
    { device = "datapool/data";
      fsType = "zfs";
    };
  fileSystems."/home" =
    { device = "rootpool/home";
      fsType = "zfs";
    };
  fileSystems."/nix" =
    { device = "rootpool/nix";
      fsType = "zfs";
    };
  fileSystems."/var" =
    { device = "rootpool/var";
      fsType = "zfs";
    };
  fileSystems."/var/lib/containers" =
    { device = "datapool/containers";
      fsType = "zfs";
    };
  fileSystems."/var/lib/libvirt/images" =
    { device = "datapool/vm";
      fsType = "zfs";
    };
  swapDevices = [ ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  #### configuration.nix stuff: 
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 90d";
    };
  };
  nixpkgs.config.allowUnfree = true;

  # Use the GRUB 2 boot loader.
  boot = {
    loader.grub = {
      enable = true;
      efiSupport = false;
      device = "/dev/disk/by-id/usb-HP_iLO_Internal_SD-CARD_000002660A01-0:0";
    };
    supportedFilesystems = ["zfs"];
    initrd = {
      supportedFilesystems = ["zfs"];
      kernelModules = ["hpsa"];
      availableKernelModules = [
        "hpsa" "sg" "sd_mod" # controller is in HBA mode
        "hpilo" # hp ilo interface kernel.
        "ipmi_si"     # IPMI System Interface
        "ipmi_devintf" # IPMI Device Interface
        "ehci_pci" "ahci" "uhci_hcd" "usb_storage" ]
      ;
    };
    #zfsSupport = true; #required if /boot is zfs, but might not support modern features.
    zfs.devNodes = "/dev/disk/by-id";
    zfs.forceImportRoot = false;
    kernelParams = [
      "console=tty1"
      "intremap=off"
      "systemd.setenv=SYSTEMD_SULOGIN_FORCE=1"
    ];
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };
  networking = {
    hostName = "homelab";
    hostId = "f0e11b44";
    useDHCP = true; # or configure static IPs
  };
  services.zfs.autoScrub.enable = true;
  #services.zfs.trim.enable = true; only useful for SSDs.
  powerManagement.cpuFreqGovernor = "powersave";

  time.timeZone = "America/Chicago";
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  documentation = {
    enable = true;
    nixos.enable = true;
    man.enable = true;
  };

  services = {
    fail2ban = {
      enable = true;
      maxretry = 5; # ban after 5 attempts
      ignoreIP = [
        "192.168.12.0/24"
        "127.0.0.1/8"
        "::1" # IPv6 loopback
        "192.168.12.0/24"
      ];
    };
  };
  # services.printing.enable = true; # CUPS - why?
  # services.pipewire = { # audio - why?
  #   enable = true;
  #   pulse.enable = true;
  # };

  users.users = {
    aaron = { # redundant to console.nix, but has packages - merge manually later?
      isNormalUser = true;
      extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
      packages = with pkgs; [
        nix-output-monitor
        nh
        tree
        git
        wget
        curl
        acpi # battery info, thermals, ac adapter
        dmidecode # determine memory configuration
        smartmontools # SMART disk health
        fastfetch # Better than neofetch
        lsof # list open files
        #ecryptfs # removed, need replacement? Enterprise-class stacked cryptographic filesystem
        age # age-keygen to generate keys for SOPS
        pstree # Show the set of running processes as a tree
        coreutils # fileutils, shellutils and textutils (ls, sort, head) https://www.gnu.org/software/coreutils/
        pciutils # lspci
        hwinfo # hardware info
        lshw # list hardware
        usbutils # lsusb
        tcpdump
        bind # "Domain name server" for nslookup
        file # info on files
        bat # better cat, line numbers - short files -> stdout, large files -> pager (less)
        eza # ls improvement, written in rust
        bottom # btm - written in rust, doesn't crash when low system resources like btop does.
        tmux # terminal multiplexer # see zelij
        rustscan # scan ports fast https://rustscan.github.io/RustScan/
        nmap # rustscan requires this. So why doesn't it *require* it so I don't have to list this then?
        gnutar gzip gawk gnused gnugrep patchelf findutils
        fwts # Firmware Test Suite
        wget # e.g. wget -c http://example.com/bigfile.tar.gz
      ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAwDpOLreCqJut0wDlxbIJGcnaZB5lPJ00MfUs5GQay3 aaron@nixos"
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    wget
    lm_sensors # inspect temps
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
    # PasswordAuthentication = false;
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
  networking.firewall.allowedUDPPorts = [ 53 ]; # DNS

  system.autoUpgrade = {
    enable = true;
    dates = "04:00"; # Run at 4 AM daily
    #flags = [ "--update-input" "nixpkgs" "--commit-lock-file" ];
  };


}
