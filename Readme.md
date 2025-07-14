1. Pull the nginx image from the docker hub :
docker pull nginx:apline

2. Save the image in the .tar file :
docker save nginx:alpine -o nginx.tar

3. Key Generation :
openssl rand -base64 32 > image.key

4. Encrypt the image tar using the key : 
openssl enc -aes-256-cbc -salt -in nginx.tar -out nginx.tar.enc -pass file:./image.key

5. Host the image and the key over http server  for the initContainer :
python3 -m http.server 8080

To run the decrypt.sh all dependencies are installed in the image decryp-inti through Dockerfile 
so creating the decrypt-init image and pushing it into the registry i.e local

6. Running the docker resgistry :
docker run -d -p 5000:5000 --restart=always --name registry registry:2

7. Building the decrypt-init image and pushing into registry :
chmod +x build_and_push.sh
./build_and_push.sh

8. Verify the image present in the registry or not :
curl http://localhost:5000/v2/_catalog

9. Apply the yaml file :
kubectl apply -f secure-nginx.yaml




Checking the status and debugging if there are any errors :
kubectl get pods
kubectl describe pod secure-nginx
kubectl logs secure-nginx -c decrypt-init
kubectl delete pod secure-nginx

To verify it is present :
sudo ctr --address /run/k3s/containerd/containerd.sock -n k8s.io images list | grep nginx-decrypted






import-2025-07-14@sha256:a78117786f04639e944a8c8d943b4c7de7e9983dc24c1f5cf413987fba115bfc                          application/vnd.oci.image.manifest.v1+json                sha256:a78117786f04639e944a8c8d943b4c7de7e9983dc24c1f5cf413987fba115bfc 51.9 MiB  linux/arm64                                                    io.cri-containerd.image=managed 
