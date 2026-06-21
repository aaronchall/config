{pkgs, lib, ...}:
let
  colors = import ./colors.nix; # for terminal and neovim, and kitty in gui.nix
in {
  # provides faster swap performance by compressing data in RAM rather than 
  # writing it to a disk, effectively increasing available memory without 
  # slow disk I/O. Really good for low memory systems.
  #zramSwap = {
  #  enable = true;
  #  memoryPercent = 25;
  #};

  # Below daemon handles power-related events like lid switches or button presses.
  # You can define specific handlers for ACPI events, for instance handling AC adapter status changes.
  # services.acpid.enable = true; # run scripts on events? maybe need: services.acpid.acEventCommands -> "" - 

  # broadcast on the server, make it easy to ssh into e.g. 
  # ssh idea.local (double check this?):
  services.lldpd.enable = lib.mkDefault true;
  services.lldpd.extraArgs= ["-d"];

  # services.gvfs.enable = true; # use android devices MTP, dolphin apparently doesn't use?

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

  programs = {
    mtr.enable = true; # my traceroute, combines ping with traceroute
    tmux.enable = true;
    /*
    nix-ld = { # give FHS to Python compiled for other linuxes:
      enable = true;
      libraries = with pkgs; [
        # nothing added yet...
      ];
    };
    */
    /*neovim = { # We could nest neovim config here, but instead, just below:
      enable = true;
      vimAlias = true;... 
    }*/
  };

  programs.neovim = { # I switched from vim to neovim for lsp and *treesitter*:
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
        " let g:netrw_banner=0
        " let g:netrw_liststyle=3
        " let g:netrw_browse_split=4
        " let g:netrw_altv=1
        " let g:netrw_winsize=25
        """" Vexplore launches when opening a file.
        " augroup ProjectDrawer
        "   autocmd!
        "   autocmd VimEnter * :Vexplore
        " augroup END
        " :Diff to see diff on current versus saved:
        command! -nargs=0 Diff w !diff % -
        " below works but commented to test - add python config later?
        " lua vim.lsp.config['pyright'] = {}
        lua vim.lsp.enable('pyright')
        lua << EOF
        require('nvim-treesitter.config').setup{
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
        -- Use my ANSI colors
        vim.g.terminal_color_0  = "#${colors.black}"
        vim.g.terminal_color_1  = "#${colors.red}"
        vim.g.terminal_color_2  = "#${colors.green}"
        vim.g.terminal_color_3  = "#${colors.yellow}"
        vim.g.terminal_color_4  = "#${colors.blue}"
        vim.g.terminal_color_5  = "#${colors.magenta}"
        vim.g.terminal_color_6  = "#${colors.cyan}"
        vim.g.terminal_color_7  = "#${colors.white}"
        vim.g.terminal_color_8  = "#${colors.brightblack}"
        vim.g.terminal_color_9  = "#${colors.brightred}"
        vim.g.terminal_color_10 = "#${colors.brightgreen}"
        vim.g.terminal_color_11 = "#${colors.brightyellow}"
        vim.g.terminal_color_12 = "#${colors.brightblue}"
        vim.g.terminal_color_13 = "#${colors.brightmagenta}"
        vim.g.terminal_color_14 = "#${colors.brightcyan}"
        vim.g.terminal_color_15 = "#${colors.brightwhite}"
        vim.opt.termguicolors = true
        -- Force main windows and status line to use your true black and gray
        local custom_palette = {
          Normal       = { fg = "#${colors.white}", bg = "#${colors.black}" },
          SignColumn   = { bg = "#${colors.black}" },
          LineNr       = { fg = "#${colors.brightblack}", bg = "#${colors.black}" },
          StatusLine   = { fg = "#${colors.brightblack}", bg = "#${colors.black}" },
        }
        for group, options in pairs(custom_palette) do
          vim.api.nvim_set_hl(0, group, options)
        end
        vim.api.nvim_set_hl(0, "@keyword", { fg = "#${colors.cyan}" })
        EOF
        "hi Normal guibg=black
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
      "networkmanager" # temporary while using nm-applet
    ];
  };
  users.motd = ''
    Welcome to NixOS! (start_sway)
  '';
  environment.variables = {
    PROMPT_COMMAND = "history -a; history -n";
    # EDITOR = "vim"; # stuff like this is handled in programs.neovim
    # use the terminal colors we are defining in colors.nix:
    BAT_THEME = "ansi"; 
    HISTSIZE = 10000;
    HISTFILESIZE = 10000;
  };
  nix = {
    gc = {
      automatic = true;
      dates = "weekly"; # mkDefault: low priority default (mkForce higher)
      options = lib.mkDefault "--delete-older-than 30d";
    };
    settings = {
      auto-optimise-store = true; # saves tons of space, note "s" spelling.
      experimental-features = [ "nix-command" "flakes" ];
      #substituters = [ "https://hydra.nixos.org/" ];
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
    # each nh call uses hostname for flake by default.
    # each update_and_... function updates lock file first.
    build () {
      nh -v os build ~/config --fallback ;
    }
    update_and_build () {
      nh -v os build --update ~/config --fallback ;
    }
    switch () {
      nh -v os switch ~/config --fallback ;
    }
    update_and_switch () {
      nh -v os switch --update ~/config --fallback ;
    }
    boot () { # switches on boot
      nh -v os boot ~/config --fallback ;
    }
    update_and_boot () {
      nh -v os boot --update ~/config --fallback ;
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

  virtualisation.podman = {
    enable = true;
  };
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
    #upower # D-Bus service for power management - run service insead
    batmon # terminal dashboard for power info
    lm_sensors # required by temperature block for i3status-rs
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
    #odoo # not available anymore?
  ];
}
