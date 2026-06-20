{pkgs, ...}:
{
  virtualisation.libvirtd.enable = true;

  programs.virt-manager.enable = true;

  users.users.aaron.extraGroups = [
    "libvirtd"
    "kvm"
  ];

  environment.systemPackages = with pkgs; [
    qemu_kvm
    virt-manager
    libvirt
    #virt-install
    #python3Packages.virtinst
  ];
  nixpkgs.config.permittedInsecurePackages = [ 
    #"electron-38.8.4"
    #"python3.12-pypdf2-3.0.1"
    #"openssl-1.1.1w"
  ];
}
