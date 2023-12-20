{config, pkgs, stdenv, lib, ...}:
let
    colors = import ./colors.nix;
in 
{
  # see https://nix-community.github.io/home-manager/index.html#sec-usage-configuration
  home.stateVersion = "22.11";

  # Home Manager Config goes here!
  # I'm going to mostly deal with dotfile stuff here.
  # gtk.theme.package = "adwaita-dark";
  programs.git = {
    enable = true;
    userName = "Aaron Hall";
    userEmail = "aaronchall@yahoo.com";
  };
  home.file.".config/git/ignore".text = ''
    [._].swp
    result
    \#*\#
  '';
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
    ];
  };
  home.file.".config/zathura/zathura.rc".text = ''
    set sandbox none
    set statusbar-h-padding 0
    set statusbar-v-padding 0
    set page-padding 1
    set selection-clipboard clipboard
    set recolor true
    
    map u scroll half-up
    map d scroll half-down
    map r reload
    map R rotate
    map = zoom in
    map - zoom out
    map ii recolor
    map q quit
    map g goto top
    
    set font "monospace 11"
  '';
  ## load-library - M-x loa-l
  ## ox-reveal
  ## org-tempo ;; templates for org source 
  ## htmlize
  ## evil mode 
  home.file.".emacs.d/init.el".text = ''
    ;; starting from from very small .emacs file
    ;; use vim keybindings, see https://www.emacswiki.org/emacs/Evil
    (require 'evil) ;; have to have installed first...
    ;;(require 'org-babel)
    (org-babel-do-load-languages
     'org-babel-load-languages
     '((emacs-lisp . t)
       (R . t)
       (python . t)
       (shell . t)
       (gnuplot . t)
       (C . t)
       (java . t)
       ))
    
    (evil-set-undo-system 'undo-redo) ;; XXX XXX will this work?
    ;;(require 'adwaita-dark-theme)
    ;;(load-theme 'adwaita-dark)
    ;;(require 'powerline) ;; see https://www.youtube.com/watch?v=kAA37BR2B1Y 26:00ish for moar...
    ;;(require 'doom-themes)
    ;;(require 'doom-modeline) ;; probably conflicts with above...
    ;;(doom-modeline-mode 1)
    ;;(load-theme 'doom-solarized-dark)
    ;;(load-theme 'doom-acario-dark)
    ;;(doom-themes-neotree-config)
    ;;(doom-themes-org-config)
    ;;(doom-themes-visual-bell-config)

    (require 'company)
    (add-hook 'after-init-hook 'global-company-mode)
    (add-hook 'org-mode-hook (lambda () (progn
      (require 'ox-reveal)
      (require 'org-tempo)
      (require 'htmlize)
    )))

    (evil-mode 1)
    (require 'fira-code-mode)
    (global-fira-code-mode)

    ;; new feature emacs 29
    ;;(setq initial-frame-alist '(
    ;;  (alpha-background . 70)
    ;; )
    ;;)
    ;; Clean up:
    ;; http://kb.mit.edu/confluence/display/istcontrib/Disabling+the+Emacs+menubar%2C+toolbar%2C+or+scrollbar
    (menu-bar-mode -1) ;; https://www.emacswiki.org/emacs/MenuBar
    (tool-bar-mode -1)
    (scroll-bar-mode -1)
    (display-time-mode 1) ;; 0 

    (global-display-line-numbers-mode)
    (setq display-line-numbers-type 'relative)

    (custom-set-variables
     '(custom-enabled-themes '(deeper-blue))
     ;;'(custom-safe-themes
       ;; adwaita-dark:
       ;;'("15601003d94d9ccc77766b132a4dfa5bdbf8b8d553311c3d70bfd223b0314882" default))
     '(package-archives
       '(("gnu" . "https://elpa.gnu.org/packages/")
         ("nongnu" . "https://elpa.nongnu.org/nongnu/")
         ("melpa" . "https://melpa.org/packages/")))
     '(package-selected-packages 'nil ;;'(
     ;; commented because installed with nixos:
     ;;evil ;; vim keybindings
     ;;htmlize ;; get org syntax highlighting in html 
     ;;ox-reveal ;; export ort to revealjs
    ;;)
    ))
    (custom-set-faces
     )
    ;;(set-default-coding-systems 'utf-8);; isn't this default? C-h shift-C indicates it is.
    ;;update appearance:
    (set-frame-parameter nil 'background-color "#000000")
    (add-to-list 'default-frame-alist '(background-color . "#000000"))
    (set-frame-parameter nil 'alpha-background 70)
    (add-to-list 'default-frame-alist '(alpha-background . 70))
    (add-to-list 'default-frame-alist '(font . "Fira Code"))
    '';
  home.file.".ssh/config".text = ''
    Host cs-ssh
        Hostname cs-ssh.uwf.edu
        User ach22

    Host ai
        Hostname ai-spark.hmcse.uwf.edu
        User ach22

    Host cs-235-11
        Hostname cs-235-11.cs.uwf.edu
        User ach22

    Host us-southeast dev
        Hostname 2600:3c02::f03c:92ff:fe93:3ace
        IdentityFile ~/.ssh/id_ed25519
        User aaron
    
    Host us-central
        Hostname 2600:3c00::f03c:92ff:fe93:a68d
        IdentityFile ~/.ssh/id_ed25519
        User aaron
    
    Host us-east linode
        Hostname 66.228.37.53
        IdentityFile ~/.ssh/id_ed25519
        User excelsiora
    
    Host *
        IdentitiesOnly yes
        VisualHostKey=yes
  '';
  home.file.".config/sway/config".text = ''
    # Default config for sway
    #
    # Copy this to ~/.config/sway/config and edit it to your liking.
    #
    # Read `man 5 sway` for a complete reference.
    # https://man.archlinux.org/man/sway.5.en
    
    ### Variables
    #
    # Logo key. Use Mod1 for Alt.
    set $mod Mod4
    # Home row direction keys, like vim
    set $left h
    set $down j
    set $up k
    set $right l
    # Your preferred terminal emulator
    set $term kitty
    # Your preferred application launcher
    # Note: pass the final command to swaymsg so that the resulting window can be opened
    # on the original workspace that the command was run on.
    # set $menu dmenu_path | dmenu | xargs swaymsg exec --
    # from wiki:
    set $menu bemenu-run
    default_border none
    gaps inner 5
    smart_gaps on
    # super-c screenshots, puts png in ~/Pictures
    bindsym $mod+c exec grim  -g "$(slurp)" ~/Pictures/$(date +'%H:%M:%S.png')
    
    ### Output configuration
    #
    # Default wallpaper (more resolutions are available in /run/current-system/sw/share/backgrounds/sway/)
    #output * bg /run/current-system/sw/share/backgrounds/sway/Sway_Wallpaper_Blue_1920x1080.png fill
    #output * bg ~/ .background-image fill
    output * bg ~/Pictures/AmericanFlagEaglePaintAbstract.jpg fill
    #output eDP-1 bg /dev/video1
    #
    # Example configuration:
    #
    #   output HDMI-A-1 resolution 1920x1080 position 1920,0
    #
    # You can get the names of your outputs by running: swaymsg -t get_outputs
    
    ### Idle configuration
    #
    # Example configuration:
    #
    # exec swayidle -w \
    #          timeout 300 'swaylock -f -c 000000' \
    #          timeout 600 'swaymsg "output * dpms off"' resume 'swaymsg "output * dpms on"' \
    #          before-sleep 'swaylock -f -c 000000'
    #
    # This will lock your screen after 300 seconds of inactivity, then turn off
    # your displays after another 300 seconds, and turn your screens back on when
    # resumed. It will also lock your screen before your computer goes to sleep.
    
    ### Input configuration
    # You can get the names of your inputs by running: swaymsg -t get_inputs
    # Read `man 5 sway-input` for more information about this section.
    input "1386:20606:Wacom_Pen_and_multitouch_sensor_Finger" map_to_output eDP-1
    input "1386:20606:Wacom_Pen_and_multitouch_sensor_Pen" map_to_output eDP-1
    
    ### Key bindings
    #
    # Basics:
    #
        # Start a terminal
        bindsym $mod+Return exec $term
    
        # Kill focused window
        bindsym $mod+Shift+q kill
    
        # Start your launcher
        bindsym $mod+d exec $menu
    
        # Drag floating windows by holding down $mod and left mouse button.
        # Resize them with right mouse button + $mod.
        # Despite the name, also works for non-floating windows.
        # Change normal to inverse to use left mouse button for resizing and right
        # mouse button for dragging.
        floating_modifier $mod normal
    
        # Reload the configuration file
        bindsym $mod+Shift+c reload
    
        # Exit sway (logs you out of your Wayland session)
        bindsym $mod+Shift+e exec swaynag -t warning -m 'You pressed the exit shortcut. Doyou really want to exit sway? This will end your Wayland session.' -B 'Yes, exit sway' 'swaymsg exit'
    #
    # Moving around:
    #
        # Move your focus around
        bindsym $mod+$left focus left
        bindsym $mod+$down focus down
        bindsym $mod+$up focus up
        bindsym $mod+$right focus right
        # Or use $mod+[up|down|left|right]
        bindsym $mod+Left focus left
        bindsym $mod+Down focus down
        bindsym $mod+Up focus up
        bindsym $mod+Right focus right
    
        # Move the focused window with the same, but add Shift
        bindsym $mod+Shift+$left move left
        bindsym $mod+Shift+$down move down
        bindsym $mod+Shift+$up move up
        bindsym $mod+Shift+$right move right
        # Ditto, with arrow keys
        bindsym $mod+Shift+Left move left
        bindsym $mod+Shift+Down move down
        bindsym $mod+Shift+Up move up
        bindsym $mod+Shift+Right move right
    #
    # Workspaces:
    #
        # Switch to workspace
        bindsym $mod+1 workspace number 1
        bindsym $mod+2 workspace number 2
        bindsym $mod+3 workspace number 3
        bindsym $mod+4 workspace number 4
        bindsym $mod+5 workspace number 5
        bindsym $mod+6 workspace number 6
        bindsym $mod+7 workspace number 7
        bindsym $mod+8 workspace number 8
        bindsym $mod+9 workspace number 9
        bindsym $mod+0 workspace number 10
        # Move focused container to workspace
        bindsym $mod+Shift+1 move container to workspace number 1
        bindsym $mod+Shift+2 move container to workspace number 2
        bindsym $mod+Shift+3 move container to workspace number 3
        bindsym $mod+Shift+4 move container to workspace number 4
        bindsym $mod+Shift+5 move container to workspace number 5
        bindsym $mod+Shift+6 move container to workspace number 6
        bindsym $mod+Shift+7 move container to workspace number 7
        bindsym $mod+Shift+8 move container to workspace number 8
        bindsym $mod+Shift+9 move container to workspace number 9
        bindsym $mod+Shift+0 move container to workspace number 10
        # Note: workspaces can have any name you want, not just numbers.
        # We just use 1-10 as the default.
    #
    # https://www.reddit.com/r/swaywm/comments/hd9r4e/comment/fvjv8yo/?context=3
    # Move Workspaces: 
    #
        bindsym $mod+Control+Shift+Right move workspace to output right
        bindsym $mod+Control+Shift+Left move workspace to output left
        bindsym $mod+Control+Shift+Down move workspace to output down
        bindsym $mod+Control+Shift+Up move workspace to output up

    #
    # Layout stuff:
    #
        # You can "split" the current object of your focus with
        # $mod+b or $mod+v, for horizontal and vertical splits
        # respectively.
        bindsym $mod+b splith
        bindsym $mod+v splitv
    
        # Switch the current container between different layout styles
        bindsym $mod+s layout stacking
        bindsym $mod+w layout tabbed
        bindsym $mod+e layout toggle split
    
        # Make the current focus fullscreen
        bindsym $mod+f fullscreen
    
        # Toggle the current focus between tiling and floating mode
        bindsym $mod+Shift+space floating toggle
    
        # Swap focus between the tiling area and the floating area
        bindsym $mod+space focus mode_toggle
    
        # Move focus to the parent container
        bindsym $mod+a focus parent
    #
    # Scratchpad:
    #
        # Sway has a "scratchpad", which is a bag of holding for windows.
        # You can send windows there and get them back later.
    
        # Move the currently focused window to the scratchpad
        bindsym $mod+Shift+minus move scratchpad
    
        # Show the next scratchpad window or hide the focused scratchpad window.
        # If there are multiple scratchpad windows, this command cycles through them.
        bindsym $mod+minus scratchpad show
        # use super-shift-space (floating toggle) to retile the window.
    #
    # Resizing containers:
    #
    mode "resize" {
        # left will shrink the containers width
        # right will grow the containers width
        # up will shrink the containers height
        # down will grow the containers height
        bindsym $left resize shrink width 10px
        bindsym $down resize grow height 10px
        bindsym $up resize shrink height 10px
        bindsym $right resize grow width 10px
    
        # Ditto, with arrow keys
        bindsym Left resize shrink width 10px
        bindsym Down resize grow height 10px
        bindsym Up resize shrink height 10px
        bindsym Right resize grow width 10px
    
        # Return to default mode
        bindsym Return mode "default"
        bindsym Escape mode "default"
    }
    bindsym $mod+r mode "resize"
    
    #
    # Status Bar:
    #
    # Read `man 5 sway-bar` for more information about this section.
    bar {
        position bottom
        height 14
        # font pango:Fira Code, Font Awesome 6 Free 10
        font pango:Font Awesome 6 Free 10
        # When the status_command prints a new line to stdout, swaybar updates.
        # The default just shows the current date and time.
        # status_command while date +'%Y-%m-%d %I:%M:%S %p'; do sleep 1; done
        # see https://github.com/greshake/i3status-rust
        status_command i3status-rs /etc/xdg/i3status-rust/config.toml
    
        colors {
            statusline #ffffff00
            background #32323200
            inactive_workspace #32323200 #32323200 #5c5c5c
        }
    }
    include /etc/sway/config.d/*
    # from wiki:
    # exec dbus-sway-environment
    # exec configure-gtk
  '';
}
