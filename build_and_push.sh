#!/bin/bash
docker build -t decrypt-init -f Dockerfile.decrypt .
docker tag decrypt-init localhost:5000/decrypt-init
docker push localhost:5000/decrypt-init
