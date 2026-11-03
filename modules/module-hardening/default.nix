{ mkModuleOption, ... }:
{
  options.nixos.modules.module-hardening = mkModuleOption { };

  config.nixos.modules.module-hardening =
    { lib, pkgs, ... }:
    let
      unusedKernelModules = [
        "dccp"
        "sctp"
        "rds"
        "tipc"
        "n-hdlc"
        "n_gsm"
        "ax25"
        "netrom"
        "x25"
        "rose"
        "decnet"
        "econet"
        "af_802154"
        "ipx"
        "appletalk"
        "psnap"
        "p8022"
        "p8023"
        "llc2"
        "atm"
        "can"
        "bluetooth"
        "btusb"
        "firewire-core"
        "thunderbolt"
        "cramfs"
        "freevxfs"
        "jffs2"
        "hfs"
        "hfsplus"
        "udf"
        "ksmbd"
      ];
    in
    {
      boot.blacklistedKernelModules = unusedKernelModules;
      boot.extraModprobeConfig = lib.concatMapStringsSep "\n" (
        module: "install ${module} ${pkgs.coreutils}/bin/false"
      ) unusedKernelModules;

      boot.kernel.sysctl = {
        "kernel.kptr_restrict" = 2;
        "kernel.dmesg_restrict" = 1;
        "kernel.unprivileged_bpf_disabled" = 1;
        "net.core.bpf_jit_harden" = 2;
        "kernel.yama.ptrace_scope" = 1;
        "dev.tty.ldisc_autoload" = 0;
        "fs.suid_dumpable" = 0;
        "fs.protected_fifos" = 2;
        "fs.protected_regular" = 2;
        "net.ipv4.conf.all.accept_redirects" = 0;
        "net.ipv4.conf.default.accept_redirects" = 0;
        "net.ipv4.conf.all.secure_redirects" = 0;
        "net.ipv4.conf.default.secure_redirects" = 0;
        "net.ipv4.conf.all.send_redirects" = 0;
        "net.ipv4.conf.default.send_redirects" = 0;
        "net.ipv6.conf.all.accept_redirects" = 0;
        "net.ipv6.conf.default.accept_redirects" = 0;
      };
    };
}
