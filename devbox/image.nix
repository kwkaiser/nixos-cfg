{ pkgs, inputs }:
let
  home = inputs.home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    extraSpecialArgs = {
      inherit inputs;
      isDarwin = false;
      # Standalone stand-in for the `bconfig = config` NixOS/darwin systems
      # pass in via modules/user.nix — only the fields git/home.nix reads.
      bconfig = {
        mine.email = "karl@kwkaiser.io";
        mine.git.signCommits = false;
      };
    };
    modules = [ ./home.nix ];
  };
in
pkgs.dockerTools.buildLayeredImage {
  name = "devbox";
  tag = "latest";

  contents = [
    pkgs.dockerTools.caCertificates
    pkgs.dockerTools.fakeNss
    pkgs.bashInteractive
    pkgs.coreutils
    home.activationPackage
  ];

  extraCommands = ''
    mkdir -m 1777 -p tmp
    mkdir -p root
  '';

  config = {
    # fly ssh console (and any real sshd added later) lands as root, so run
    # the home-manager activation once at boot to populate /root, then just
    # stay alive. Nothing here restarts activation on a later image update -
    # redeploying the image is what refreshes /root's contents from scratch.
    Cmd = [
      "${pkgs.bashInteractive}/bin/bash"
      "-lc"
      "${home.activationPackage}/activate && exec sleep infinity"
    ];
    Env = [
      "HOME=/root"
      "USER=root"
      "PATH=/root/.nix-profile/bin:${pkgs.coreutils}/bin:${pkgs.bashInteractive}/bin"
      "SSL_CERT_FILE=${pkgs.dockerTools.caCertificates}/etc/ssl/certs/ca-bundle.crt"
      "NIX_SSL_CERT_FILE=${pkgs.dockerTools.caCertificates}/etc/ssl/certs/ca-bundle.crt"
    ];
  };
}
