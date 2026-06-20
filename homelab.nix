{ config, lib, pkgs, modulesPath, ... }:

{
  # hardware-configuration.nix stuff:
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];
  boot.initrd.availableKernelModules = [ "ehci_pci" "ahci" "uhci_hcd" "hpsa" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
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
      availableKernelModules = ["hpsa" "sg" "sd_mod" ]; # controller is in HBA mode
    };
    #zfsSupport = true; #required if /boot is zfs, but might not support modern features.
    zfs.devNodes = "/dev/disk/by-id";
    zfs.forceImportRoot = false;
    kernelParams = [
      "console=tty1"
      "intremap=off"
      "systemd.setenv=SYSTEMD_SULOGIN_FORCE=1"
    ];
    #boot.initrd.extraKernelModules = ["hpsa"];
  };
  networking = {
    hostName = "homelab";
    hostId = "f0e11b44";
    useDHCP = true; # or configure static IPs
  };
  services.zfs.autoScrub.enable = true;
  #services.zfs.trim.enable = true; only useful for SSDs.
  powerManagement.cpuFreqGovernor = "powersave";

  # Configure network connections interactively with nmcli or nmtui.
  #networking.networkmanager.enable = true;

  time.timeZone = "America/Chicago";
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };
  documentation = {
    enable = false;
    nixos.enable = false;
    man.enable = false;
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
  # Enable the X11 windowing system.
  # services.xserver.enable = true;




  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users = {
    root = {
      hashedPassword = "$6$D9as3MJfsNImsGLa$nlBjGHk1coGS66iY7EVUYVuDupvWfikYCBhAUr79Mhuxy/M5W39/l4xQSuxoh1XZMCjwU.UR1VIlFb/lcJ/5Q1";
    };
    aaron = {
      isNormalUser = true;
      hashedPassword = "$6$D9as3MJfsNImsGLa$nlBjGHk1coGS66iY7EVUYVuDupvWfikYCBhAUr79Mhuxy/M5W39/l4xQSuxoh1XZMCjwU.UR1VIlFb/lcJ/5Q1";
      extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
      packages = with pkgs; [
        nix-output-monitor
        nh
        tree
        git
        vim
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
  #users.users.root.hashedPassword = "$6$BWhc1sZlwbQCiS7B$2ydCryd.TpvzTB3TZOZCYL0uJCMvdHuXPYUyqCws850FiW4BCf8J5NiQODRmVyw6o7hzaA5YqBMqn/QsW8NT7.";
  #users.users.root.hashedPassword = "!"; #Keep root locked for security.
  environment.variables.EDITOR = "vim";

  # programs.firefox.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nanoeditor is also installed by default.
    wget
    lm_sensors # inspect temps`
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  services.openssh = {
    enable = true;
    #settings.PermitRootLogin = "no";
    # PasswordAuthentication = false;
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  networking.firewall.allowedUDPPorts = [ 53 ]; # why?
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;
  system.autoUpgrade = {
    enable = true;
    dates = "04:00"; # Run at 4 AM daily
    #flags = [ "--update-input" "nixpkgs" "--commit-lock-file" ];
  };

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?

}
