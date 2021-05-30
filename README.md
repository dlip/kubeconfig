# Kubeconfig

My Kubernetes cluster config

## Setup

### Import Encryption key

```sh
export KEY=DF0D30534A2926B559D22776ECE0E5FB0260172D
gpg --export-secret-keys \
 --armor $KEY |
Add encryption key to file
gpg --import key.pgp
gpg --edit-key $KEY
trust
5
q
kubectl create namespace flux-system
gpg --export-secret-keys \
  --armor $KEY |
kubectl create secret generic sops-gpg \
  --namespace=flux-system \
  --from-file=sops.asc=/dev/stdin
```

### Bootstrap Cluster

```sh
export GITHUB_TOKEN=<GITHUB_TOKEN>
flux bootstrap github \
  --owner=dlip \
  --repository=kubeconfig \
  --path=cluster \
  --personal
```

## Tasks

### Build docker images

```sh
nix run .#dockerLogin
nix run .#pushDockerImages
```
