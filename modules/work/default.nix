{mkModuleOption, ...}: let
  hmModule = {
    pkgs,
    config,
    lib,
    inputs,
    ...
  }: let
    devbox = inputs.nixpkgs-devbox.legacyPackages.${pkgs.stdenv.hostPlatform.system}.devbox;

    lila-auth-cli = pkgs.buildGoModule rec {
      pname = "lila-auth-cli";
      version = "0.6.0";
      src = inputs.lila-auth-cli;
      vendorHash = "sha256-bCLdNyDvSKl6c3VE3wwoeIuFs8QnNUfaNbjo5UB/1OY=";
      ldflags = [
        "-s"
        "-w"
        "-X github.com/lilasci-dev/lila-auth-cli/cmd.Version=${version}"
      ];
      postInstall = "mv $out/bin/${pname} $out/bin/lila-auth";
    };

    defaultTmuxinatorWindows = [
      {claude = "clear && ccp";}
      {editor = "clear";}
      {driver = "clear";}
    ];

    mkTmuxinatorProject = name: root: {
      inherit name root;
      windows = defaultTmuxinatorWindows;
    };

    mkLimsMcp = url: {
      type = "http";
      inherit url;
      oauth = {
        clientId = "mcp-servers";
        callbackPort = 8080;
      };
    };

    chrome-devtools-mcp = pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
      pname = "chrome-devtools-mcp";
      version = "1.10.1";

      src = pkgs.fetchurl {
        url = "https://registry.npmjs.org/chrome-devtools-mcp/-/chrome-devtools-mcp-${finalAttrs.version}.tgz";
        hash = "sha256-ASy89ugy1PZwna0MIde+8XCJ6Ure6c8zF50V6gqa3ys=";
      };

      nativeBuildInputs = [pkgs.makeWrapper];
      dontBuild = true;

      installPhase = ''
        runHook preInstall

        mkdir -p $out/lib/chrome-devtools-mcp
        cp -r build skills package.json $out/lib/chrome-devtools-mcp/

        makeWrapper ${pkgs.nodejs}/bin/node $out/bin/chrome-devtools-mcp \
          --add-flags $out/lib/chrome-devtools-mcp/build/src/bin/chrome-devtools-mcp.js

        runHook postInstall
      '';

      meta = {
        description = "MCP server giving coding agents control over Chrome via the DevTools Protocol";
        homepage = "https://github.com/ChromeDevTools/chrome-devtools-mcp";
        license = lib.licenses.asl20;
        mainProgram = "chrome-devtools-mcp";
      };
    });

    chromeExecutable =
      if pkgs.stdenv.hostPlatform.isDarwin
      then "${pkgs.google-chrome}/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
      else "${pkgs.google-chrome}/bin/google-chrome-stable";

    chromeMcpStateDir = "${config.home.homeDirectory}/.cache/chrome-devtools-mcp";
    chromeMcpUserDataDir = "${chromeMcpStateDir}/chrome-profile";

    cursorOverlayDaemon = pkgs.writeText "mcp-cursor-overlay.mjs" ''
      import {readFileSync} from 'node:fs';

      const portFile = process.argv[2];

      function overlay() {
        const ID = '__mcp_cursor__';

        function disabled() {
          try {
            return window.localStorage.getItem('mcpCursor') === 'off';
          } catch (err) {
            return false;
          }
        }

        function mount() {
          if (disabled()) return true;
          if (document.getElementById(ID)) return true;
          if (!document.body) return false;

          const dot = document.createElement('div');
          dot.id = ID;
          Object.assign(dot.style, {
            position: 'fixed',
            left: '0px',
            top: '0px',
            width: '26px',
            height: '26px',
            marginLeft: '-13px',
            marginTop: '-13px',
            borderRadius: '50%',
            background: 'transparent',
            border: '3px solid rgba(255,45,70,0.95)',
            boxShadow: '0 0 0 1.5px rgba(255,255,255,0.9), 0 0 10px rgba(255,45,70,0.5)',
            pointerEvents: 'none',
            zIndex: '2147483647',
            transition: 'transform 260ms cubic-bezier(0.22,0.61,0.36,1)',
            transform: 'translate(-100px,-100px)'
          });
          document.body.appendChild(dot);

          window.addEventListener('mousemove', function (e) {
            dot.style.transform = 'translate(' + e.clientX + 'px, ' + e.clientY + 'px)';
          }, {capture: true, passive: true});

          window.addEventListener('mousedown', function (e) {
            const ring = document.createElement('div');
            Object.assign(ring.style, {
              position: 'fixed',
              left: e.clientX + 'px',
              top: e.clientY + 'px',
              width: '26px',
              height: '26px',
              marginLeft: '-13px',
              marginTop: '-13px',
              borderRadius: '50%',
              border: '3px solid rgba(255,45,70,0.9)',
              pointerEvents: 'none',
              zIndex: '2147483646',
              transition: 'transform 450ms ease-out, opacity 450ms ease-out'
            });
            document.body.appendChild(ring);
            requestAnimationFrame(function () {
              ring.style.transform = 'scale(3.2)';
              ring.style.opacity = '0';
            });
            setTimeout(function () {
              ring.remove();
            }, 500);
          }, {capture: true, passive: true});
        }

        const observer = new MutationObserver(function () {
          if (mount()) observer.disconnect();
        });
        observer.observe(document, {childList: true, subtree: true});
        if (mount()) observer.disconnect();
      }

      const source = '(' + overlay.toString() + ')()';

      const delay = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

      function readEndpoint() {
        const [port, path] = readFileSync(portFile, 'utf8').split('\n');
        if (!port || !path) return null;
        return 'ws://127.0.0.1:' + port.trim() + path.trim();
      }

      function log(...args) {
        console.log(new Date().toISOString(), ...args);
      }

      function session(endpoint) {
        return new Promise((resolve) => {
          const ws = new WebSocket(endpoint);
          let nextId = 1;

          const send = (method, params, sessionId) =>
            ws.send(JSON.stringify({id: nextId++, method, params, sessionId}));

          const inject = (sessionId, targetId) => {
            send('Page.enable', {}, sessionId);
            send('Page.addScriptToEvaluateOnNewDocument', {source}, sessionId);
            send('Runtime.evaluate', {expression: source}, sessionId);
            log('injected overlay into', targetId);
          };

          ws.addEventListener('open', () => {
            log('connected', endpoint);
            send('Target.setDiscoverTargets', {discover: true});
            send('Target.setAutoAttach', {
              autoAttach: true,
              waitForDebuggerOnStart: false,
              flatten: true
            });
            send('Target.getTargets', {});
          });

          ws.addEventListener('message', (event) => {
            const msg = JSON.parse(event.data);

            if (msg.method === 'Target.attachedToTarget') {
              const {sessionId, targetInfo} = msg.params;
              if (targetInfo.type === 'page') inject(sessionId, targetInfo.targetId);
              return;
            }

            if (msg.result?.targetInfos) {
              for (const info of msg.result.targetInfos) {
                if (info.type === 'page' && !info.attached) {
                  send('Target.attachToTarget', {targetId: info.targetId, flatten: true});
                }
              }
            }
          });

          ws.addEventListener('close', () => {
            log('disconnected');
            resolve();
          });
          ws.addEventListener('error', () => resolve());
        });
      }

      while (true) {
        let endpoint = null;
        try {
          endpoint = readEndpoint();
        } catch (err) {
          endpoint = null;
        }
        if (endpoint) await session(endpoint);
        await delay(1000);
      }
    '';

    chromeDevtoolsMcpWithOverlay = pkgs.writeShellScriptBin "chrome-devtools-mcp-with-overlay" ''
      mkdir -p ${lib.escapeShellArg chromeMcpStateDir}
      ${pkgs.nodejs}/bin/node ${cursorOverlayDaemon} \
        ${lib.escapeShellArg "${chromeMcpUserDataDir}/DevToolsActivePort"} \
        < /dev/null >> ${lib.escapeShellArg "${chromeMcpStateDir}/cursor-overlay.log"} 2>&1 &
      overlay_pid=$!
      trap 'kill "$overlay_pid" 2>/dev/null' EXIT
      ${chrome-devtools-mcp}/bin/chrome-devtools-mcp "$@"
    '';
  in {
    home.packages = with pkgs; [
      devbox
      lila-auth-cli
      gh
      gh-dash
      awscli2
      google-cloud-sdk
      typescript
      vtsls
      ssm-session-manager-plugin

      (writeShellScriptBin "work-init" ''
        tmuxinator start --no-attach primary
        tmuxinator start --no-attach wt-1
        tmuxinator start --no-attach wt-2
      '')
      (writeShellScriptBin "pccp" ''
        kitty --directory ~/Documents/pallet/copallet ccp &
        kitty --directory ~/Documents/pallet/copallet-wt-1 ccp &
        kitty --directory ~/Documents/pallet/copallet-wt-2 ccp &
      '')

      (writeShellScriptBin "asso" ''
        profile="''${1:-''${AWS_PROFILE:-}}"
        if [ -z "$profile" ]; then
          echo "usage: asso <profile> (or set AWS_PROFILE)" >&2
          exit 1
        fi

        if ! ${awscli2}/bin/aws configure export-credentials --profile "$profile" --format env 2>/dev/null; then
          ${awscli2}/bin/aws sso login --profile "$profile" >&2 || exit 1
          ${awscli2}/bin/aws configure export-credentials --profile "$profile" --format env
        fi
      '')

      (writeShellScriptBin "bind-mermaid" ''
        host="''${1:?usage: bind-mermaid <ssh-host>}"
        exec ssh -N -L 3737:localhost:3737 -L 3738:localhost:3738 -L 3739:localhost:3739 "$host"
      '')
    ];

    programs.zsh.initContent = ''
      asso() {
        local creds
        creds="$(command asso "$@")" || return
        eval "$creds"
      }
    '';

    mine.claude.extraMcpServers = {
      sentry = {
        type = "http";
        url = "https://mcp.sentry.dev/mcp";
      };

      chrome-devtools = {
        command = "${chromeDevtoolsMcpWithOverlay}/bin/chrome-devtools-mcp-with-overlay";
        args = [
          "--executablePath=${chromeExecutable}"
          "--userDataDir=${chromeMcpUserDataDir}"
          "--no-usage-statistics"
          "--no-performance-crux"
          "--chromeArg=--remote-debugging-port=0"
        ];
      };

      lims-dev = mkLimsMcp "https://lims-mcp-dev.solo.lilasci.io/mcp";
      lims-staging = mkLimsMcp "https://lims-mcp-staging.ripley.lilasci.io/mcp";
      lims-prod = mkLimsMcp "https://lims-mcp-prod.ride.lilasci.io/mcp";
    };

    # Tmuxinator project configs (only if tmux is enabled)
    programs.tmux.tmuxinator.projects = lib.mkIf config.programs.tmux.enable {
      primary = mkTmuxinatorProject "primary" "~/Documents/pallet/copallet";
      "wt-1" = mkTmuxinatorProject "wt-1" "~/Documents/pallet/copallet-wt-1";
      "wt-2" = mkTmuxinatorProject "wt-2" "~/Documents/pallet/copallet-wt-2";
      "pallet-iac" = mkTmuxinatorProject "pallet-iac" "~/Documents/pallet/pallet-iac";
    };
  };
in {
  options.nixos.modules.work = mkModuleOption {};
  options.darwin.modules.work = mkModuleOption {};
  options.homeManager.modules.work = mkModuleOption {};

  config.homeManager.modules.work = hmModule;

  config.nixos.modules.work = {config, ...}: {
    home-manager.users.${config.mine.username}.imports = [hmModule];
  };

  config.darwin.modules.work = {config, ...}: {
    home-manager.users.${config.mine.username}.imports = [hmModule];
    homebrew.taps = ["schpet/tap"];
    homebrew.brews = ["schpet/tap/linear"];
    homebrew.casks = ["linear"];
  };
}
