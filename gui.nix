{ config, pkgs, ... }:
let
  colors = import ./colors.nix;
in
{
  #imports = [ 
    # don't want screensharing hacks on right now:
    #./screensharing-hacks.nix
  #];
  # TODO re-enable for screensharing
  boot.kernelModules = [ "v4l2loopback" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
  '';

  programs.virt-manager.enable = true;
  programs.sway.enable = true;
  programs.chromium = {
    enable = true; # chromium policies, not install...
    extensions = [ # list of plugin IDs.
      # see ID in url of extensions on chrome web store page
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
      "dhdgffkkebhmkfjojejmpbldmpobfkfo" # tampermonkey
      "clngdbkpkpeebahjckkjfobafhncgmne" # stylus
    ];
  };

# Review below again and delete: 
# https://raw.githubusercontent.com/greshake/i3status-rust/master/examples/config.toml
# https://man.archlinux.org/man/community/i3status-rust/i3status-rs.1.en
# block docs: https://github.com/greshake/i3status-rust/blob/master/doc/blocks.md
# time formatting: https://docs.rs/chrono/0.4.19/chrono/format/strftime/index.html#specifiers
  environment.etc."xdg/i3status-rust/config.toml".text = /* toml */''
    icons_format = "{icon}"

    [theme]
    theme = "plain"

    [icons]
    icons = "awesome6"

    [[block]]
    block = "sound"
    step_width = 1

    [[block]]
    block = "net"
    device = "wlp0s20f3"
    format = "$icon $speed_down $graph_down $speed_up $graph_up $signal_strength $frequency"
    format_alt = "$icon $ssid $frequency $signal_strength $bitrate ip $ipv6"

    [[block]]
    block = "disk_space"
    path = "/"
    info_type = "available"
    alert_unit = "GB"
    interval = 60
    warning = 50.0
    alert = 20.0
    format = "$icon $available "
    format_alt = "disk available: $available / $total"

    [[block]]
    block = "memory"
    format = "$icon $mem_used ($mem_used_percents.eng(w:1))"
    format_alt = "$icon_swap $swap_free.eng(w:3,u:B,p:M)/$swap_total.eng(w:3,u:B,p:M)($swap_used_percents.eng(w:2))"

    [[block]]
    block = "cpu"
    interval = 1
    format = "$icon $barchart $utilization $frequency"

    [[block]]
    block = "load"
    interval = 1
    format = "load: 1m $1m - 5m $5m"


    [[block]]
    block = "temperature"
    scale = "fahrenheit"
    format = "$average avg, $max max"

    [[block]]
    block = "time"
    interval = 1
    format = " $timestamp.datetime(f:'%a %Y/%m/%d %T') "

    [[block]]
    block = "battery"
    format = "$icon $percentage $time $power"
  '';
  ## TODO - is this working? webcam microphone isn't showing as source in wpctl status
  ## but still have integrated camera listed as a source...
  ## see https://www.reactivated.net/writing_udev_rules.html:
  services.udev.extraRules = /* udev */''
    # remove internal webcam, see https://wiki.archlinux.org/title/webcam_setup
    # ACTION=="ADD", ATTR{idVendor}=="04f2", ATTR{idProduct}=="b6ea", RUN="sh -c 'echo 1 > /sys/\$devpath/remove'"

    # remove microphone ability from external webcam, see https://www.mjt.me.uk/posts/blacklisting-certain-microphones-linux/
    SUBSYSTEM=="usb", DRIVER=="snd-usb-audio", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="0843", ATTR{authorized}="0"
  '';
  ## TODO Factor into printing.nix:
  # Below enables printing (CUPS), print drivers (Dell), 
  services.printing = {
    enable = false;
    drivers = [ pkgs.gutenprint ];
  };
  # check out systemd print manager?
  # from https://nixos.wiki/wiki/Printing#Client_.28Linux.29 - attempt to find shared printers
  # network discovery of printers:
  services.avahi = {
    enable = true;
  # Important to resolve .local domains of printers, otherwise you get an error
  # like  "Impossible to connect to XXX.local: Name or service not known"
    nssmdns4 = true;
  };

  ## TODO Factor into pipewire.nix?
  # enable real-time scheduling priority for processes like pulseaudio:
  security.rtkit.enable = true; # Pipewire uses this, required for VMWare Horizon 
  security.polkit.enable = true; # allows OBS to use v4l2loopback
  services.pipewire = { # required by wayland for audio ?
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };

  #### User and Environment Setup
  environment.shellAliases = {
    start_sway = "exec sway";
    list_sway_get_outputs = "swaymsg -t get_outputs";
    ssh = "kitty +kitten ssh"; # documented in kitty docs
    restart_pipewire = "systemctl --user restart pipewire";
    # see https://prabuselva.github.io/linux/hacks/ffmpeg-webcam-streaming/
    udp_serve_webcam = "ffmpeg -r 10 -video_size 640x480 -i /dev/video2 -c:v libx264 -b:a 2048k -preset ultrafast -tune zerolatency -r 10 -f h264 udp://127.0.0.1:12345";
    udp_show_webcam = "mpv udp://127.0.0.1:12345";
    udp_background_webcam = "mpvpaper --layer=bottom eDP-1 udp://127.0.0.1:12345";
    obs_v4l2_setup = "sudo modprobe v4l2loopback devices=1 video_nr=1 card_label=\"OBS Cam\" exclusive_caps=1"; # no longer needed?
    video_device_list = "v4l2-ctl --list-devices";
    # see https://gitlab.unimelb.edu.au/jli15/asclinic-system/-/blob/encoder_counts_multi_threaded/docs/software/workflow_usb_camera_settings.rst
    video_device_format = "v4l2-ctl --get-fmt-video --device=5";
    #background_webcam = "mpvpaper -v -l bottom eDP-1 av://v4l2:/dev/video5 -- -profile=low-latency";
    background_webcam = "mpvpaper -v -l bottom eDP-1 av://v4l2:/dev/video5 -- --profile=low-latency --untimed --framedrop=no --speed=1.01 --opengl-glfinish=yes --opengl-swapinterval=0 --vo=xv";
    mpv_webcam = "mpv --demuxer-lavf-format=video4linux2 -profile=low-latency --demuxer-lavf-o-set=input_format=mjpeg av://v4l2:/dev/video5";
  };
  environment.systemPackages = with pkgs; [
    (rstudioWrapper.override { packages = import ./RPackages.nix {inherit pkgs; }; })
    mesa
    mesa-demos
    # pulseaudioFull # for pactl list clients etc... # commenting for collision, supposed to use wpctl status or pw-cli ls or pw-dump
    jmtpfs # mount android - mkdir mountpoint ; jmtpfs mountpoint ; fusermount -u # to unmount
    #virt-manager # vm manager, gui for libvirt, kvm
    hplipWithPlugin # to scan, in new dir, hp-scan each page, 
    img2pdf #         then:    img2pdf *.png -o outputname.pdf
    cheese # webcam app
    # zoneminder # Video surveillance software system
    # gphoto2 # camera software applications (unused?)
    evince # pdf reader
    zathura # pdf reader (supposedly better) vim keybindings, :open, Ctrl-R inverts colors
    zotero # citation store and manager
    grim slurp # screenshot with Super-c - puts .png in ~/Pictures
    wl-clipboard # clipboard functionality - wl for Wayland TODO look into this more
    bemenu # like dmenu
    mako # notifications system! :)
    taskjuggler # Project management beyond Gantt chart drawing
    wf-recorder
    swaybg # ?
    v4l-utils # ?
    mpv # minimal video viewer
    mpvpaper # video wallpaper! but hasn't got ffmpeg with v4l2.
    #youtube-dl
    yt-dlp
    # carla # GUI maybe manages wireplumber via Jack? never got it to work.
    geteltorito # extract img for thumbdrive from thinkpad iso's (for CDs)
    wev # wayland event viewer - was like xorg.xev
    xorg.xmodmap
    irssi # terminal irc client TODO move to console.nix
    #dolphin # GUI file browser
    #kdePackages.kio-extras # libs for thumbnails in dolphin
    kdePackages.dolphin # and yet things can't find dolphin?
    i3status-rust # status bar for sway!
    kdenlive # video editing/processing GUI
    ffmpeg-full # video processing on command line
    helvum # manages wireplumber (pipewire)
    #pw-viz # another wireplubmer/pipewire manager - build fails
    qpwgraph # PipeWire Graph Qt GUI https://gitlab.freedesktop.org/rncbc/qpwgraph
    easyeffects # why do I need easyeffects? Don't think I do?
    jamesdsp # An audio effect processor for PipeWire clients
    noisetorch # Virtual microphone device with noise supression for PulseAudio
    feh # originally used to set background - can also view images from startup console
    xlsx2csv # Convert xlsx to csv
    blender # 3D Creation/Animation/Publishing System
    libnotify # terminal but only used for guis???
    xournal # Note-taking application (supposes stylus)
    texlive.combined.scheme-full # tex - for latex # see https://nixos.wiki/wiki/TexLive
    graphviz
    gnuplot # don't use gnuplot, too esoteric - use Python and Matplotlib instead
    # Games: (do I need a games.nix?)
    # openra # Red Alert game - disabled until dotnet upgraded
    oh-my-git # An interactive Git learning game TODO Try it.
    mindustry # sandbox tower defense game
    libremines # minesweeper game
    yquake2-all-games # Yamagi Quake II with all add-on games
    zeroad # A free, open-source game of ancient warfare
    wipeout-rewrite # A re-implementation of the 1995 PSX game wipEout
    vectoroids # Clone of the classic arcade game Asteroids by Atari
    torus-trooper # Fast-paced abstract scrolling shooter game
    #factorio # build and maintain factories # if fails, see instructions when fails
    dwarf-fortress # 
    pioneer # space adventure game set in the Milky Way galaxy at the turn of the 31st century
    mame # arcade emulator
    snes9x-gtk
    zsnes
    # End of games - probably should move to another module.
    kitty
    vmware-horizon-client
    libv4l
    gimp-with-plugins
    xf86_input_wacom
    wacomtablet
    libwacom
    #fbreader
    chromium # (not redundant to enable policies)
    firefox
    fstl # fast stl viewer (gui program, 3d printing files)
    k4dirstat
  ];
  nixpkgs.overlays = with pkgs; [
    (self: super: {
      mpv-unwrapped = super.mpv-unwrapped.override {
        ffmpeg = ffmpeg-full;
      };
    })
    /*(self: super: { # avoid error when trying to view youtube videos?
      mpv = super.mpv.override {
        yt-dlp = youtube-dl;
      };
    })*/
  ];
  fonts.fontconfig.defaultFonts.monospace = ["Fira Code"];
  fonts.packages = with pkgs; [
    corefonts # Times New Roman et al
    lmodern
    dejavu_fonts
    google-fonts
    powerline-fonts
    emacs-all-the-icons-fonts
    noto-fonts-extra
    liberation_ttf
    source-code-pro
    fira-code
    fira-code-symbols
  ];
  # why I have kitty - that is, ligatures:
  # -> --> => ==> . .. ... /== //= /= != == !=
  # this is defined in-line because the syntax is very simple
  # not much to be gained from splitting to different file
  # https://sw.kovidgoyal.net/kitty/conf/ (`#` as first character is comment)
  environment.etc."xdg/kitty/kitty.conf".text = with colors; /* ini */ ''
    font_family Fira Code
    bold_font auto
    italic_font auto
    bold_italic_font auto
    strip_trailing_spaces smart
    color0 #${black}
    color1 #${red}
    color2 #${green}
    color3 #${yellow}
    color4 #${blue}
    color5 #${magenta}
    color6 #${cyan}
    color7 #${white}
    color8 #${brightblack}
    color9 #${brightred}
    color10 #${brightgreen}
    color11 #${brightyellow}
    color12 #${brightblue}
    color13 #${brightmagenta}
    color14 #${brightcyan}
    color15 #${brightwhite}
    foreground #${white}
    background #${black}
    #select_fg #${black}
    #select_bg #${cyan}
    mark1_foreground #${black}
    mark1_background #${blue}
    mark2_foreground #${black}
    mark2_background #${yellow}
    mark3_foreground #${black}
    mark3_background #${magenta}
    allow_remote_control yes
    scrollback_lines 10000
    dynamic_background_opacity yes
    background_opacity 0.7
    selection_foreground #${yellow}
    selection_background #${brightblack}
    repaint_delay 40
    cursor_trail 2
  '';
  # TODO: syntax highlighting with `editorconfig` (instead of ini) looks wrong...
  # see https://github.com/nvim-treesitter/nvim-treesitter?tab=readme-ov-file#supported-languages
}
