# #!/bin/bash
# set -e

# # Use K3s's containerd socket
# CTR="ctr --address /run/k3s/containerd/containerd.sock"
# NAMESPACE="-n k8s.io"

# echo "[*] Downloading encrypted image and key..."
# curl -fsSL -o /tmp/nginx.tar.enc http://172.31.46.214:8080/nginx.tar.enc
# curl -fsSL -o /tmp/image.key http://172.31.46.214:8080/image.key

# echo "[*] Decrypting..."
# openssl enc -d -aes-256-cbc -in /tmp/nginx.tar.enc -out /tmp/nginx.tar -pass file:/tmp/image.key || {
#     echo "[!] Decryption failed"
#     exit 1
# }

# echo "[*] Importing into K3s containerd..."
# $CTR $NAMESPACE images import --digests /tmp/nginx.tar

# echo "[*] Tagging imported image..."
# imported=$($CTR $NAMESPACE images list | awk '$1 ~ /^import-/ {print $1}' | tail -n1)

# # Tag as docker.io/library/nginx-decrypted:latest
# $CTR $NAMESPACE images tag "$imported" docker.io/library/nginx-decrypted:latest
# $CTR $NAMESPACE images tag docker.io/library/nginx-decrypted:latest nginx-decrypted:latest

# #  Set CRI label so Kubelet in K3s recognizes the image
# $CTR $NAMESPACE image label docker.io/library/nginx-decrypted:latest "io.cri-containerd.image=managed"

# echo "[*] Done."




#!/bin/bash
set -e

# Use K3s's containerd socket
CTR="ctr --address /run/k3s/containerd/containerd.sock"
NAMESPACE="-n k8s.io"

echo "[*] Downloading encrypted image and key..."
curl -fsSL -o /tmp/nginx.tar.enc  http://172.31.46.214:8080/nginx.tar.enc
curl -fsSL -o /tmp/image.key      http://172.31.46.214:8080/image.key

echo "[*] Decrypting..."
openssl enc -d -aes-256-cbc \
        -in  /tmp/nginx.tar.enc \
        -out /tmp/nginx.tar      \
        -pass file:/tmp/image.key

echo "[*] Importing into K3s containerd with explicit name..."
$CTR $NAMESPACE images import --digests \
      --index-name docker.io/library/nginx-decrypted:latest \
      /tmp/nginx.tar


# Mark image “managed” so K3s’s CRI plugin sees it
$CTR $NAMESPACE image label docker.io/library/nginx-decrypted:latest \
      "io.cri-containerd.image=managed"

echo "[*] Done."
