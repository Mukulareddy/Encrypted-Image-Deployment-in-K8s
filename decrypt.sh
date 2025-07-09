# #!/bin/bash
# set -e

# echo "[*] Downloading encrypted image and key..."
# curl -fsSL -o /tmp/nginx.tar.enc http://172.31.46.214:8080/nginx.tar.enc
# curl -fsSL -o /tmp/image.key http://172.31.46.214:8080/image.key

# echo "[*] Decrypting..."
# openssl enc -d -aes-256-cbc -in /tmp/nginx.tar.enc -out /tmp/nginx.tar -pass file:/tmp/image.key || {
#     echo "[!] Decryption failed"
#     exit 1
# }

# # Check if image already exists
# if ctr -n k8s.io images list | grep -q "localhost/nginx-decrypted:latest"; then
#     echo "[*] Image already exists, skipping import and tag..."
# else
#     echo "[*] Importing into containerd..."
#     ctr -n k8s.io images import --digests --all-platforms /tmp/nginx.tar

#     echo "[*] Finding newly imported image..."
#     imported_image=$(ctr -n k8s.io images list | awk '$1 ~ /^import-[0-9]{4}-[0-9]{2}-[0-9]{2}@sha256:/ {print $1}' | sort | tail -n 1)

#     echo "[*] Tagging $imported_image as localhost/nginx-decrypted:latest"
#     ctr -n k8s.io images tag "$imported_image" localhost/nginx-decrypted:latest
# fi

# echo "[*] Final image list:"
# ctr -n k8s.io images list | grep nginx

# echo "[*] Done."
# exit 0

#!/bin/bash
# set -e

# echo "[*] Downloading encrypted image and key..."
# curl -fsSL -o /tmp/nginx.tar.enc http://172.31.46.214:8080/nginx.tar.enc
# curl -fsSL -o /tmp/image.key http://172.31.46.214:8080/image.key

# echo "[*] Decrypting..."
# openssl enc -d -aes-256-cbc -in /tmp/nginx.tar.enc -out /tmp/nginx.tar -pass file:/tmp/image.key || {
#     echo "[!] Decryption failed"
#     exit 1
# }


# echo "[*] Importing into containerd..."
# ctr -n k8s.io images import --digests --all-platforms /tmp/nginx.tar

# echo "[*] Finding newly imported image..."
# imported_image=$(ctr -n k8s.io images list | awk '$1 ~ /^import-[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]@sha256:/' | tail -n 1 | awk '{print $1}')

# echo "[*] Imported image found: '$imported_image'"

# if [[ -n "$imported_image" ]]; then
#   echo "[*] Tagging $imported_image as localhost/nginx-decrypted:latest"
#   ctr -n k8s.io images tag "$imported_image" localhost/nginx-decrypted:latest
# else
#   echo "[!] No imported image found to tag."
# fi

# sleep 5
# exit 0


#!/bin/bash
set -e

echo "[*] Downloading encrypted image and key..."
curl -fsSL -o /tmp/nginx.tar.enc http://172.31.46.214:8080/nginx.tar.enc
curl -fsSL -o /tmp/image.key http://172.31.46.214:8080/image.key

echo "[*] Decrypting..."
openssl enc -d -aes-256-cbc -in /tmp/nginx.tar.enc -out /tmp/nginx.tar -pass file:/tmp/image.key || {
    echo "[!] Decryption failed"
    exit 1
}

echo "[*] Importing and tagging image as localhost/nginx-decrypted:latest..."
# This ensures Kubernetes (via CRI) can recognize the image
ctr --namespace k8s.io image import --digests --base-name localhost/nginx-decrypted /tmp/nginx.tar

echo "[*] Final image list (filtered):"
ctr -n k8s.io images list | grep nginx || true

echo "[*] Done."
exit 0

