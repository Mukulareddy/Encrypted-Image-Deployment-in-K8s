
#  Encrypted Nginx Image Deployment on K3s using Init Container

This guide explains how to securely deploy an encrypted Nginx image on a K3s cluster. The image is decrypted at runtime using an `initContainer`.

---

##  Steps

### 1. Pull the Nginx Image

```bash
docker pull nginx:alpine
```

### 2. Save the Image as a `.tar` File

```bash
docker save nginx:alpine -o nginx.tar
```

### 3. Generate a Symmetric Key

```bash
openssl rand -base64 32 > image.key
```

### 4. Encrypt the Image

```bash
openssl enc -aes-256-cbc -salt -in nginx.tar -out nginx.tar.enc -pass file:./image.key
```

### 5. Host Encrypted Files via HTTP

```bash
python3 -m http.server 8080
```

> Ensure `nginx.tar.enc` and `image.key` are in the current directory before starting the server.

---

##  Init Container Setup

To run the `decrypt.sh` script, a custom image called `decrypt-init` is created using a `Dockerfile`. This image includes all required dependencies such as `curl`, `openssl`, and `ctr`.

### 6. Start a Local Docker Registry

```bash
docker run -d -p 5000:5000 --restart=always --name registry registry:2
```

### 7. Build and Push the `decrypt-init` Image

```bash
chmod +x build_and_push.sh
./build_and_push.sh
```

### 8. Verify the Image in the Registry

```bash
curl http://localhost:5000/v2/_catalog
```

---

##  Deploy to K3s

### 9. Apply the YAML File

```bash
kubectl apply -f secure-nginx.yaml
```

---

##  Debug & Verification

### Check Pod Status

```bash
kubectl get pods
```

### Describe Pod

```bash
kubectl describe pod secure-nginx
```

### View Init Container Logs

```bash
kubectl logs secure-nginx -c decrypt-init
```

### Delete the Pod (if needed)

```bash
kubectl delete pod secure-nginx
```

### Verify the Decrypted Image in containerd

```bash
sudo ctr --address /run/k3s/containerd/containerd.sock -n k8s.io images list | grep nginx-decrypted
```

---

##  Output

You will see the decrypted image (`nginx-decrypted:latest`) successfully imported into the K3s containerd and used by your running pod.

---
