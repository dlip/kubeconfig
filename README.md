```sh
nix run .#dockerLogin
nix run .#pushDockerImages
export GITHUB_TOKEN=<GITHUB_TOKEN>
flux bootstrap github \
  --owner=dlip \
  --repository=kubeconfig \
  --path=cluster \
  --personal
```
