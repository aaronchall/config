{pkgs, lib, ...}:
let 
  colors = import ./colors.nix; # reused in multiple locations
  networks = import ./networks.nix; # hide secrets when demoing
in {
  nixpkgs.config.allowBroken = true;
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  #boot.kernelPackages = pkgs.linuxPackages_6_7;
  # TODO switch back later:
  #boot.kernelPackages = pkgs.linuxPackages_latest;
  # below won't boot :(
  #boot.kernelPackages = pkgs.linuxPackages-rt_latest;
  # why do these feel redundant?
  # see /etc/resolv.conf   [ cloudflare DNS     ,     Google DNS     ]
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" "8.8.8.8" "8.8.4.4" ];
  # see networks.nix for wifi network configuration:
  # can I get this in my hardware-configuration.nix?
  /*networking.wireless.interfaces = [ "wlp0s20f3" 
                                     #"wlp3s0" 
    ]; # must tweak for multiple laptop installs (grep for wlp)
  */
  #networking.useNetworkd = true;
  networking.wireless = {
    enable = true; # Enables wpa_supplicant.
    /*iwd = { # use iwctl, 
      enable = false;
      settings = {
        IPv6.Enabled = true;
        Settings.AutoConnect = true;
      };
    };*/
    networks = networks;
    userControlled = { # wpa_cli
      enable = true;
      group = "wheel";
    };
    allowAuxiliaryImperativeNetworks = true; # allow both static and dynamic e.g. wpa_supplicant_gui
  };
  /*networking.extraHosts = ''
    # Productivity Blacklist
    127.0.0.1    old.reddit.com
    127.0.0.1    www.reddit.com
    127.0.0.1    reddit.com
    127.0.0.1    www.facebook.com
    127.0.0.1    facebook.com
    127.0.0.1    www.twitter.com
    127.0.0.1    twitter.com
    127.0.0.1    www.x.com
    127.0.0.1    x.com
    127.0.0.1    www.linkedin.com
    127.0.0.1    linkedin.com
    127.0.0.1    www.youtube.com
    127.0.0.1    youtube.com
    127.0.0.1    i.ytimg.com
    127.0.0.1    i9.ytimg.com
    127.0.0.1    yt3.ggpht.com
    127.0.0.1    www.4chan.org
    127.0.0.1    4chan.org
    127.0.0.1    boards.4chan.org
    127.0.0.1    news.ycombinator.com
    127.0.0.1    ycombinator.com
    127.0.0.1    www.discord.com
    127.0.0.1    discord.com
    127.0.0.1    www.discord.gg
    127.0.0.1    discord.gg
    127.0.0.1    discordapp.com
    127.0.0.1    www.discordapp.com
    127.0.0.1    discordapp.net
    127.0.0.1    www.discordapp.net
    # can run `systemctl status nscd.service` to restart, but happens automatically on switching.
  '';*/
  services.acpid.enable = true; # maybe need: services.acpid.acEventCommands -> ""
  # services.gvfs.enable = true; # use android devices MTP, dolphin apparently doesn't use?
  time.timeZone = "US/Eastern";

  networking.useDHCP = false; ## this is default on all of my systems.

  i18n.defaultLocale = "en_US.UTF-8";
  console = { # sets /etc/vconsole.conf
    # see `ls /etc/static/kbd/consolefonts/ | grep .psfu.gz` for fonts
    # samples: https://adeverteuil.github.io/linux-console-fonts-screenshots/
    font = "Lat2-Terminus16"; # check out open dyslexic?
    # or maybe see kmscon? https://search.nixos.org/options?query=kmscon
    keyMap = "us";
    colors = with colors;
      [ black red green yellow blue magenta cyan white 
        brightblack brightred brightgreen brightyellow brightblue
        brightmagenta brightcyan brightwhite ];
  };

  # VM - grep for virt to find all relevant entries
  virtualisation = {
    libvirtd = {
      enable = true;
    };
  };
  #virtualisation = {
    #qemu.drives = {
    #  nixosvm = {
    #    name = "nixosvm";
    #    # the file image used for this drive
    #    file = "nixos-minimal-23.11.4976.79baff8812a0-x86_64-linux.iso";
    #    driveExtraOpts = {}; # extra options passed to drive flag
    #    deviceExtraOpts = {}; # Extra options passed to device flag
    #  };
    #};
   # virtualbox.host = {
   #   enable = true;
   #   enableExtensionPack = true;
   # };
   # libvirtd.enable = true;
  #};

  #users.extraGroups.bvoxusers.members = [ "aaron" ]; # ???
  # virtualisation.libvirtd.enable = true;# sudo virsh net-start default
  # users.users.user = { # for build-vm?
  #   group = [ "wheel" ];
  #   isSystemUser = true;
  #   initialPassword = "pw";
  # };

  programs = {
    mtr.enable = true; # my traceroute, combines ping with traceroute
    tmux.enable = true;
    nix-ld = { # give FHS to Python compiled for other linuxes:
      enable = true;
      libraries = with pkgs; [
        # nothing added yet...
      ];
    };
    /*neovim = {
      enable = true;
      vimAlias = true;... 
    }*/
  };

  programs.neovim = { # use neovim for lsp support
    enable = true;
    vimAlias = true;
    viAlias = true;
    defaultEditor = true;
    withNodeJs = true; # python3 true by default
    configure = {
      customRC = /* vim */ ''
        scriptencoding utf-8
        set encoding=utf-8
        syntax on
        filetype on
        set relativenumber
        set number
        set shiftwidth=4 expandtab
        autocmd BufRead,BufNewFile *.nix set shiftwidth=2
        set hidden
        set ruler
        set colorcolumn=80
        " view tabs and trailing spaces:
        set list
        set listchars=tab:»·,trail:·
        " below uses color 17 here: https://www.ditig.com/256-colors-cheat-sheet
        highlight ColorColumn ctermbg=NONE ctermfg=red 
        set backspace=indent,eol,start
        let g:elm_format_autosave = 1
        " https://shapeshed.com/vim-netrw/autoformattr
        let g:netrw_banner=0
        let g:netrw_liststyle=3
        let g:netrw_browse_split=4
        let g:netrw_altv=1
        let g:netrw_winsize=25
        augroup ProjectDrawer
          autocmd!
          autocmd VimEnter * :Vexplore
        augroup END
        " :Diff to see diff on current versus saved:
        command! -nargs=0 Diff w !diff % -
        " below works but commented to test - add python config later?
        " lua vim.lsp.config['pyright'] = {}
        lua vim.lsp.enable('pyright')
        lua << EOF
        require('nvim-treesitter.configs').setup{
            highlight = {enable = true,},
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<CR>",
                    node_incremental = "<CR>",
                    node_decremental = "<BS>",
                },
            },
        }
        EOF
        hi Normal guibg=black
      '';
      packages.myVimPackage = with pkgs.vimPlugins; {
        start = [
          #vim-lsp # need LSP now? 
          #YouCompleteMe elm-vim vim-nix haskell-vim 
          #jedi-vim typescript-vim rust-vim vim-polyglot
          nvim-treesitter.withAllGrammars
          coc-pyright # completion and uses typescript - Python
          nvim-lspconfig
        ];
      };
    };
  };

  users.users.aaron = {
    isNormalUser = true;
    extraGroups = [
      "wheel" # I'm the big wheel on my machine, the big cheese. 
      "video" # I don't remember why? from hacks for screensharing?
      "audio" # IDK if actually needed?
      "libvirtd" # to manage virtual machines
    ];
  };
  users.motd = ''
    Welcome to NixOS! (start_sway)
  '';
  environment.variables = {
    PROMPT_COMMAND = "history -a; history -n";
    #EDITOR = "vim";
    # use the terminal colors we are defining in colors.nix:
    BAT_THEME = "ansi"; 
    HISTSIZE = 10000;
    HISTFILESIZE = 10000;
  };
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    settings = {
      auto-optimise-store = true; # saves tons of space, note "s" spelling.
      experimental-features = [ "nix-command" "flakes" ];
    };
  };
  # Bash config:
  # https://www.gnu.org/software/bash/manual/bash.html
  programs.bash.promptInit = builtins.readFile ./prompt.sh;
  programs.bash.interactiveShellInit = /* bash */ ''
    mount_android () {
    mkdir -p ~/androidmount
    cat <<DOC
    attempt mtp mount creation with `jmtpfs ~/androidmount`
    Don't forget to give permission on device 
    and unmount_android when done.
    DOC
    jmtpfs ~/androidmount || cat <<ERR
    Error!
    Is the device connected?
    ERR
    }
    unmount_android () {
      fusermount -u ~/androidmount
    }
    ___mount_old_home () {  # avoid cluttering namespace, kinda defunct fn...
      sudo mount /dev/sdb5 /mnt 
      cd /mnt/home/.ecryptfs/excelsiora/ # needed else fails
      sudo ecryptfs-manager              # seems redundant but needed?
      sudo ecryptfs-recover-private --rw .Private/
      cd -  # go back to where we were
    }

    ___setup_watch_site() # see https://nixos.org/manual/nixos/unstable/index.html#sect-nixos-systemd-nixos
    {
      mkdir -p ~/.config/systemd/user/default.target.wants
      ln -s /run/current-system/sw/lib/systemd/user/site_check.service \
        ~/.config/systemd/user/default.target.wants/
      mkdir -p ~/.config/systemd/user/timers.target.wants
      ln -s /run/current-system/sw/lib/systemd/user/site_check.timer \
        ~/.config/systemd/user/timers.target.wants/
    }
    ___watch_site () {
      systemctl --user daemon-reload
      # systemctl --user enable site_check.service site_check.timer
      systemctl --user start site_check.timer site_check.service
    }
    ___watch_site_verify() {
      systemctl list-timers --user
    }
    ___follow_site_check_log() { journalctl --user -fu site_check ; }
    restart_wpa() { systemctl restart wpa_supplicant-wlp0s20f3.service ; }
    ___set_terminal_name() { printf '\033]0;%s\007' "$*" ; }
    fix_touchpad() { sudo modprobe -r psmouse && sudo modprobe psmouse ; }
    store_location () { readlink $(which $1) ; }

    display_colors () {
        # see https://www.man7.org/linux/man-pages/man5/terminal-colors.d.5.html
        for x in {0..8}; do
            for i in {30..37}; do
                for a in {40..47}; do
                    echo -ne "\e[$x;$i;$a""m\\\e[$x;$i;$a""m\e[0;37;40m "
                done
                echo
            done
        done
    echo ""
    }
    find_config () {
      grep -r $1 ~/config ;
    }
    find_file () {
      find . -type f -name "$1" ;
    }
    find_dir () {
      find . -type d -name "$1" ;
    }
    # PATH manipulation convenience functions:
    list_paths() {
      echo $PATH | tr : "\n" ; 
    }
    # These are from Linux From Scratch http://www.linuxfromscratch.org/blfs/view/6.3/postlfs/profile.html
    # Functions to help us manage paths.  Second argument is the name of the
    # path variable to be modified (default: PATH) $$'s are doubled up to escape from nix:
    pathremove () {
        local IFS=':'
        local NEWPATH
        local DIR
        local PATHVARIABLE=$${2:-PATH}
        for DIR in $${!PATHVARIABLE} ; do
            if [ "$DIR" != "$1" ] ; then
                NEWPATH=$${NEWPATH:+$$NEWPATH:}$$DIR
            fi
        done
        export $$PATHVARIABLE="$$NEWPATH"
    }
    pathprepend () {
        pathremove $$1 $$2
        local PATHVARIABLE=$${2:-PATH}
        export $$PATHVARIABLE="$$1$${!PATHVARIABLE:+:$${!PATHVARIABLE}}"
    }
    pathappend () {
        pathremove $$1 $$2
        local PATHVARIABLE=$${2:-PATH}
        export $$PATHVARIABLE="$${!PATHVARIABLE:+$${!PATHVARIABLE}:}$$1"
    }

    # Nix OS convenience functions:
    ___switch_old () { # usage: switch x1  *or* switch knode
      sudo nixos-rebuild switch -L --flake ~/config#$1 ;
    }
    # --fallback gives ability to build if not connected (e.g. adding wifi after arriving to new location)
    # (--offline builds without connecting at all)
    switch () {
      nh -v os switch ~/config --fallback ; # uses hostname for flake.
    }
    build () {
      nh -v os build ~/config --fallback ;
    }
    switch_boot () {
      nh -v os boot ~/config --fallback ;
    }
    switch_and_update () { # update & switch - uses hostname for flake.
      nh -v os switch --update ~/config ;
    }
    build_old () {
      sudo nixos-rebuild build -L --flake ~/config#$1 ;
    }
    update () {
      echo "used to run 'nix flake update ~/config', now just 'switch'" ;
    }
    rollback () { #TODO find nh version of this?
      sudo nixos-rebuild --rollback switch ;
    }
    cleanup () {
      sudo nix-collect-garbage --delete-older-than 30d ;
    }
  '';
  # Firewall: check with 
  # nix eval .#nixosConfigurations.x1.config.networking.firewall.allowedTCPPorts
  networking.firewall.allowedTCPPorts = [ ];
  networking.firewall.allowedUDPPorts = [ ];

  # virtualisation.docker.enable = true;
  virtualisation.podman.enable = true;

  nixpkgs.config.allowUnfree = true;
  environment.shellAliases = {
    ssh_idea = "ssh idea.local";
    docker = "podman";
    reboot_history = "last reboot";
    ls = "eza";
    list_generations = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
    #edit_config = "vi ~/config/configuration.nix"; # defunct
    build_config = "cd ~/config && sudo nixos-rebuild build --flake ~/config/#x1 ; cd -";
    switch_config = "cd ~/config && sudo nixos-rebuild switch --flake ~/config/#x1 ; cd -";
    update_config = "cd ~/config && nix flake update ; cd -";
    rollback_one_generation = "sudo nixos-rebuild --rollback switch";
    collect_all_garbage = "sudo nix-collect-garbage -d";
    collect_some_garbage = "sudo nix-collect-garbage";
    follow_all_user_logging = "journalctl -f";
    follow_site_check = "journalctl --user -fu site_check.service";
    follow_wpa_log = "journalctl -fu wpa.supplicant.service";
  };
  environment.systemPackages = with pkgs; [
    yazi # console file browser written in rust
    ed # just for fun - it's the standard editor, duh
    #nano # Standard in NixOS - use the nano container to show off?
    nh # "nix helper" features for builds like trees etc
    nix-output-monitor # same API as nix command, but better output???
    acpi # battery info, thermals, ac adapter
    upower # D-Bus service for power management
    lm_sensors # required by temperature block for i3status-rs
    dmidecode # determine memory configuration
    smartmontools # SMART disk health
    neofetch # see my system details
    fastfetch # Better than neofetch
    lsof # list open files
    ecryptfs # Enterprise-class stacked cryptographic filesystem
    pstree # Show the set of running processes as a tree
    coreutils # fileutils, shellutils and textutils (ls, sort, head) https://www.gnu.org/software/coreutils/
    pciutils # lspci
    hwinfo # hardware info
    lshw # list hardware
    usbutils # lsusb
    bind # "Domain name server" for nslookup
    file # info on files
    bat # better cat
    eza # ls improvement, written in rust
    bottom # btm - written in rust, doesn't seem to crash like btop does.
    tmux # terminal multiplexer # see zelij
    rustscan # scan ports fast https://rustscan.github.io/RustScan/
    nmap # rustscan requires this. So why doesn't it *require* it so I don't have to list this then?
    gnutar gzip gawk gnused gnugrep patchelf findutils 
    fwts # Firmware Test Suite
    wget # e.g. wget -c http://example.com/bigfile.tar.gz
    lynx # terminal web browser
    w3m # another terminal web browser - nixos-help uses, so installing
    ispell # interactive spell-checking program for Unix (emacs)
    #librsvg # A small library to render SVG images to Cairo surfaces (using for svg in emacs)
    inkscape # for svg emacs... sigh...
    man
    man-pages
    pinfo # browse info pages with pinfo 
    tree
    git
    lazygit
    angband # direct descendant of rogue (-> moria -> angband)
    zip # needed for fce course?
    unzip
    p7zip
    cowsay
    odoo
  ];
}
