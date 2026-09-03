{ pkgs, inputs }:
let
  # claude-code is unfree-licensed; hostPkgs (what this flake output builds
  # with) never has allowUnfree set - that only happens inside the
  # NixOS/Darwin module system's shared `allowUnfree` module, which this
  # standalone image build bypasses entirely.
  homePkgs = import inputs.nixpkgs {
    inherit (pkgs) system;
    config.allowUnfree = true;
  };

  home = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = homePkgs;
    extraSpecialArgs = {
      inherit inputs;
      isDarwin = false;
      # Standalone stand-in for the `bconfig = config` NixOS/darwin systems
      # pass in via modules/user.nix — only the fields git/home.nix reads.
      bconfig = {
        mine.email = "karl@kwkaiser.io";
        mine.git.signCommits = true;
      };
    };
    modules = [ ./home.nix ];
  };

  contentsList = [
    pkgs.dockerTools.caCertificates
    pkgs.dockerTools.fakeNss
    pkgs.bashInteractive
    pkgs.coreutils
    pkgs.nix
    home.activationPackage
  ];

  # home-manager's standalone activation script unconditionally runs
  # `nix-build --expr '{}' --no-out-link` as a store sanity check, and later
  # registers the new generation as a GC root via nix-store - both need a Nix
  # that recognizes this image's baked-in store paths as valid.
  # dockerTools.buildLayeredImage only copies the files in; it never
  # registers them in a store database, so a freshly booted Nix starts with
  # an empty db. Seed the db at image-build time instead of on every boot,
  # mirroring dockerTools.buildImageWithNixDb's mkDbExtraCommand.
  closureInfo = pkgs.closureInfo { rootPaths = contentsList; };
in
pkgs.dockerTools.buildLayeredImage {
  name = "devbox";
  tag = "latest";

  contents = contentsList;

  extraCommands = ''
    mkdir -m 1777 -p tmp
    mkdir -p root

    # No nixbld users exist in this image (it's single-user, root-only), and
    # sandboxed builds need user namespaces we don't need to rely on here -
    # nix-env still does a real local build at activation time (see below).
    mkdir -p etc/nix
    cat > etc/nix/nix.conf <<'EOF'
    build-users-group =
    sandbox = false
    filter-syscalls = false
    EOF

    export NIX_REMOTE=local?root=$PWD
    export USER=nobody
    ${pkgs.buildPackages.nix}/bin/nix-store --load-db < ${closureInfo}/registration
    ${pkgs.buildPackages.sqlite}/bin/sqlite3 nix/var/nix/db/db.sqlite \
      "UPDATE ValidPaths SET registrationTime = ''${SOURCE_DATE_EPOCH}"
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
      "PATH=/root/.nix-profile/bin:${pkgs.nix}/bin:${pkgs.coreutils}/bin:${pkgs.bashInteractive}/bin"
      "SSL_CERT_FILE=${pkgs.dockerTools.caCertificates}/etc/ssl/certs/ca-bundle.crt"
      "NIX_SSL_CERT_FILE=${pkgs.dockerTools.caCertificates}/etc/ssl/certs/ca-bundle.crt"
    ];
  };
}
