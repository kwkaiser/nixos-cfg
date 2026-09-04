{ mkModuleOption, ... }:
let
  homelabHosts = ''
    127.0.0.1 kwkaiser-test.io
    127.0.0.1 auth.kwkaiser-test.io
    127.0.0.1 browser.kwkaiser-test.io
    127.0.0.1 food.kwkaiser-test.io
    127.0.0.1 git.kwkaiser-test.io
    127.0.0.1 irc.kwkaiser-test.io
    127.0.0.1 lib.kwkaiser-test.io
    127.0.0.1 movies.kwkaiser-test.io
    127.0.0.1 news.kwkaiser-test.io
    127.0.0.1 photos.kwkaiser-test.io
    127.0.0.1 scurvy.kwkaiser-test.io
    127.0.0.1 stats.kwkaiser-test.io
    127.0.0.1 sync.kwkaiser-test.io
    127.0.0.1 trackers.kwkaiser-test.io
    127.0.0.1 tv.kwkaiser-test.io
    127.0.0.1 users.kwkaiser-test.io
    127.0.0.1 watch.kwkaiser-test.io
    127.0.0.1 authentik.kwkaiser-test.io
    127.0.0.1 portal.kwkaiser-test.io
    127.0.0.1 budget.kwkaiser-test.io
  '';

  # Full hosts file content for Darwin (must be copied, not symlinked)
  darwinHostsContent = ''
    127.0.0.1       localhost
    255.255.255.255 broadcasthost
    ::1             localhost

    ${homelabHosts}
  '';
in
{
  options.nixos.modules.homelab-hosts-file = mkModuleOption { };
  options.darwin.modules.homelab-hosts-file = mkModuleOption { };

  # NixOS: extraHosts appends to the existing file
  config.nixos.modules.homelab-hosts-file = {
    networking.extraHosts = homelabHosts;
  };

  # Darwin: macOS doesn't support symlinked /etc/hosts (Network framework
  # ignores symlinks) - use an activation script to copy the file directly instead
  config.darwin.modules.homelab-hosts-file =
    { pkgs, ... }:
    let
      hostsFile = pkgs.writeText "hosts" darwinHostsContent;
    in
    {
      system.activationScripts.extraActivation.text = ''
        echo "Updating /etc/hosts with homelab entries..." >&2
        cp ${hostsFile} /etc/hosts
        chmod 644 /etc/hosts
      '';
    };
}
