{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    }:
    flake-utils.lib.eachDefaultSystem
      (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        pushDockerImage = with pkgs; writeScriptBin "push-docker-image" ''
          set -euo pipefail
          ${skopeo}/bin/skopeo --insecure-policy copy docker-archive:$1 docker://$2
        '';
        pushDockerImages = with pkgs; writeScriptBin "push-docker-images" ''
          set -euo pipefail
          ${pushDockerImage}/bin/push-docker-image ${pushNixStoreDockerImage} dlip/push-nix-store-docker-image
        '';
        pushNixStoreDockerImage = with pkgs; dockerTools.buildLayeredImage {
          name = "dlip/push-nix-store-docker-image";
          tag = "latest";
          contents = [
            coreutils
            skopeo
            cacert
            nixUnstable
            (writeScriptBin "entrypoint" ''
              #!${runtimeShell}
              set -euo pipefail
              mkdir -p /var/tmp
              nix --experimental-features nix-command store cat --store $1 $2 | skopeo --insecure-policy copy docker-archive:/dev/stdin docker://$3
            '')
          ];
          config.Entrypoint = [ "entrypoint" ];
        };
      in
      rec {
        inherit pkgs;
        defaultApp = apps.repl;
        apps = {
          repl = flake-utils.lib.mkApp
            {
              drv = pkgs.writeShellScriptBin "repl" ''
                confnix=$(mktemp)
                echo "builtins.getFlake (toString $(git rev-parse --show-toplevel))" >$confnix
                trap "rm $confnix" EXIT
                nix repl $confnix
              '';
            };
        };
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [ pushDockerImage pushDockerImages skopeo ];
        };
      });
}
