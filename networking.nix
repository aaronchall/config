{pkgs, lib, ...}:
{ # I prefer to avoid using networkmanager:
  /*networking.networkmanager = {
    enable=true;
    wifi.backend = "iwd";
  };*/
  #programs.nm-applet.enable = true;

  networking.wireless = {
  #### issues using eduroam - iwd doesn't do 801x auth very well still.
    iwd = { # use iwctl
      enable = true;
      settings = {
        IPv6.Enabled = true;
        Settings.AutoConnect = true;
        #Network.NameResolvingService = "systemd-resolved";
      };
    };
  };
  #systemd.services.iwd.serviceConfig.ReadOnlyPaths = [ "/etc/ssl/certs" ];
  systemd.services.iwd = {
    serviceConfig.ExecStart = [ 
      "" 
      "${pkgs.iwd}/libexec/iwd -d"
    ];
    environment = {
      IWD_DHCP_DEBUG = "debug"; # Most granular level: debug, info, warn, error
      IWD_TLS_DEBUG = "1";      # Trace TLS/EAP handshakes
      IWD_GENL_DEBUG = "1";     # Print all Generic Netlink (kernel) communication
      IWD_RTNL_DEBUG = "1";     # Trace routing netlink messages
    };
  };
  security.pki.certificateFiles = [
  #  "/etc/ssl/certs/ca-certificates.crt"
  ];
  ####
  /*
  services.unbound = {
    enable = true;
    settings = {
      server = {
        interface = [ "127.0.0.1" ];
        access-control = [ "127.0.0.0/8 allow" ];
        # This ensures the connection is actually secure
        tls-cert-bundle = "/etc/ssl/certs/ca-certificates.crt";
      };
      forward-zone = [
        {
          name = ".";
          # Forward to Cloudflare over TLS (Port 853)
          forward-addr = [ 
            "1.1.1.1@853#cloudflare-dns.com" 
            "1.0.0.1@853#cloudflare-dns.com" 
          ];
          forward-tls-upstream = "yes";
        }
      ];
    };
  };*/
  # Tell NixOS to use your new local Unbound server exclusively
  #networking.nameservers = [ "127.0.0.1" ];
  # Stop the router from "pushing" its own bad DNS to you
  #networking.networkmanager.dns = "none"; 
  #networking.dhcpcd.extraConfig = "nohook resolv.conf";

  #services.resolved = {
  #  enable = true;
  #  extraConfig = ''
  #    DNSOverHTTPS=yes
  #  '';
    #dnssec = "false";
    #domains = [ "~." ];
    /*
    fallbackDns = [
      "1.1.1.1#cloudflare-dns.com"
      "1.0.0.1#cloudflare-dns.com"
      "8.8.8.8#dns.google"
      "8.8.4.4#dns.google"
    ];
    dnsovertls = "true";
    extraConfig = ''
      DNS=1.1.1.1
    '';*/
 # };

  /*networking.hosts = {
    "162.159.135.232" = [ "discord.com" "www.discord.com" ];
    "162.159.129.233" = [ "gateway.discord.gg" ];
    "162.159.133.232" = [ "cdn.discordapp.com" ];
    "162.159.134.232" = [ "media.discordapp.net" ];
  };*/


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
  sops = {
    defaultSopsFile = ./secrets.yaml;
    validateSopsFiles = false;
    age.keyFile = "/home/aaron/.config/sops/age/keys.txt";
    #age.sshKeyPaths = [ "/home/aaron/.config/sops/age/keys.txt" ]; # TODO is there a better location?
    # to add SSIDs, add below, and update secrets with `sops secrets.yaml` 
    # test or just manually access with 
    # `iwctl station wlan0 connect SSID [security]` (8021x, psk, or open)
    secrets = let 
      escape = ssid: builtins.replaceStrings [ ] [ ] ssid; # tolerates alnum, " ", _, -
      # otherwise char is encoded as an equal sign followed by the lower-case hex encoding of the name
    in
      (lib.genAttrs [ # open SSID, probably capture portal?
        "Beachside_Guest"
        "Santa Rosa Guest Wireless"
        "UWF Guest"
        "HopFly Guest"
      ] (ssid: {path = "/var/lib/iwd/${escape ssid}.open";}))
      // (lib.genAttrs [ # PSKs:
        "The Residence MC"
        "Rustacm"
        "Cabin_Retreat"
        "5224" # "5224".path = "/var/lib/iwd/5224.psk";
        "A7Lite"
        "Hall Wifi" # "Hall Wifi".path = "/var/lib/iwd/Hall\\x20Wifi.psk";
        "ATHome_Guest"
        "JLGuest"
        "ATTvXW2TS2"
        "ATT6KtaHdR"
        "dd-wrt"
        "DKLB BKLN"
        "SETUP-F1E6"
        "Bayou319"
        "Lowden Home"
        "Lowdenwifi"
        "vGuest"
        "Clowntown"
        "JordanValley"
      ] (ssid: {path = "/var/lib/iwd/${escape ssid}.psk";}))
      # Pre-Shared Key (psk) above - 8021x below:
      // {"eduroam".path = "/var/lib/iwd/eduroam.8021x"; }
        # PEAP,Phase2 MSCHAPV2,CA system uwf.edu,id email,blank anon,pw
        # iwctl station wlan0 connect eduroam 8021x
    ;
  };
  environment.systemPackages = [ 
    pkgs.sops 
    pkgs.ssh-to-age 
    pkgs.networkmanagerapplet
  ];
}
