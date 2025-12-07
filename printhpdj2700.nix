{pkgs, ...}:
{
  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = [ pkgs.hplipWithPlugin ];
    browsing = true;
  };
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
  hardware.printers = {
    ensurePrinters = [
      { # discovered with lpinfo -v and similar to lpadmin command:
        name = "HPDeskJet2700";
        model = "everywhere";
        deviceUri = "dnssd://HP%20DeskJet%202700%20series%20%5BAD448E%5D._ipp._tcp.local/?uuid=41bd5d60-0822-58f9-8ede-0c1f12beb0bc";
        description = "HP DeskJet 2700";
        location = "home";
        ppdOptions = {
          PageSize = "Letter";
        };
      }
    ];
  };
}
