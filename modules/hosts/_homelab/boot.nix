{pkgs, ...}: {
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  environment.systemPackages = with pkgs; [fuse ipvsadm];
  boot.kernelModules = [
    "9p"
    "9pnet"
    "9pnet_virtio"
    "virtio_gpu"
    "ip_vs"
    "ip_vs_rr"
    "ip_vs_wrr"
    "ip_vs_sh"
    "nf_nat"
    "nf_conntrack"
    "br_netfilter"
  ];
}
