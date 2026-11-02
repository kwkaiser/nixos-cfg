{
  inputs,
  lib,
  mkNixosModules,
  ...
}:
let
  vmTestModule =
    { lib, pkgs, ... }:
    {
      options.mine.vmTest = {
        tests = lib.mkOption {
          type = lib.types.attrsOf lib.types.bool;
          default = { };
          description = "Which modules' VM tests are enabled for this node. A module gates both its test-only config and its script on its own entry.";
        };

        sshKeys = lib.mkOption {
          type = lib.types.raw;
          readOnly = true;
          default = import "${pkgs.path}/nixos/tests/ssh-keys.nix" pkgs;
          description = "Well-known throwaway keypair; the private half is installed at /root/id on the test client node.";
        };

        scripts = lib.mkOption {
          type = lib.types.attrsOf lib.types.lines;
          default = { };
          description = "Per-module python test snippets, keyed by module name. Run against `machine` (this host) and `client` (a bare node on the same vlan).";
        };
      };
    };

  indent = script: lib.concatMapStringsSep "\n" (line: "    " + line) (lib.splitString "\n" script);

  mkHostTest =
    {
      name,
      hostModule,
      tests,
      machine ? { },
      client ? { },
    }:
    let
      pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
      selected = lib.attrNames (lib.filterAttrs (_: enabled: enabled) tests);
    in
    inputs.nixpkgs.lib.nixos.runTest {
      inherit name;
      hostPkgs = pkgs;
      node.specialArgs = { inherit inputs; };
      globalTimeout = 150 * 60;

      nodes.machine = {
        imports = mkNixosModules hostModule ++ [ machine ];
        mine.vmTest.tests = tests;
      };

      nodes.client =
        { pkgs, ... }:
        {
          imports = [ client ];
          environment.systemPackages = [ pkgs.curl ];
        };

      testScript =
        { nodes, ... }:
        let
          inherit (nodes.machine.mine.vmTest) scripts sshKeys;
          missing = lib.filter (test: !(scripts ? ${test})) selected;
        in
        assert lib.assertMsg (missing == [ ]) "${name}: no vm test defined for ${toString missing}";
        ''
          start_all()
          client.wait_for_unit("multi-user.target")
          client.succeed("install -m 600 ${sshKeys.snakeOilPrivateKey} /root/id")
          machine.wait_for_unit("multi-user.target")

          ${lib.concatMapStringsSep "\n" (test: ''
            with subtest("${test}"):
            ${indent scripts.${test}}
          '') selected}

          with subtest("no failed units"):
              machine.wait_until_succeeds("systemctl is-system-running --wait | grep -qE '^(running|degraded)$'")
              failed = machine.succeed("systemctl list-units --failed --plain --no-legend | awk '{print $1}'").split()
              assert not failed, f"failed units: {failed}"
        '';
    };
in
{
  config._module.args.vmTestModule = vmTestModule;
  config._module.args.mkHostTest = mkHostTest;
}
