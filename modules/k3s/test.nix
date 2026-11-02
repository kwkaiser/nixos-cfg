{
  config.nixos.modules.k3s =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      webImage = pkgs.dockerTools.buildLayeredImage {
        name = "test.local/web";
        tag = "local";
        contents = [
          pkgs.busybox
          (pkgs.writeTextDir "www/index.html" "k3s-nodeport-ok")
        ];
        config.Cmd = [
          "httpd"
          "-f"
          "-p"
          "8080"
          "-h"
          "/www"
        ];
      };

      webManifest = pkgs.writeText "web.yaml" ''
        apiVersion: apps/v1
        kind: Deployment
        metadata:
          name: web
        spec:
          selector:
            matchLabels:
              app: web
          template:
            metadata:
              labels:
                app: web
            spec:
              containers:
                - name: web
                  image: test.local/web:local
                  imagePullPolicy: Never
                  ports:
                    - containerPort: 8080
        ---
        apiVersion: v1
        kind: Service
        metadata:
          name: web
        spec:
          type: NodePort
          selector:
            app: web
          ports:
            - port: 80
              targetPort: 8080
              nodePort: 80
      '';
    in
    {
      config = lib.mkIf (config.mine.vmTest.tests.k3s or false) {
        services.k3s = {
          nodeIP = config.networking.primaryIPAddress;
          images = [
            config.services.k3s.package.airgap-images
            webImage
          ];
        };

        mine.vmTest.scripts.k3s = ''
          machine.wait_for_unit("k3s.service")
          machine.wait_until_succeeds("k3s kubectl get node ${config.networking.hostName} | grep -w Ready", timeout=3600)
          for deployment in ["coredns", "local-path-provisioner", "metrics-server"]:
              machine.wait_until_succeeds(
                  f"k3s kubectl -n kube-system rollout status deployment/{deployment} --timeout=10s",
                  timeout=3600,
              )
          machine.succeed("k3s kubectl apply -f ${webManifest}")
          machine.wait_until_succeeds("k3s kubectl rollout status deployment/web --timeout=10s", timeout=1800)
          client.wait_until_succeeds("curl -sf http://${config.networking.hostName}/ | grep -q k3s-nodeport-ok", timeout=600)
        '';
      };
    };
}
