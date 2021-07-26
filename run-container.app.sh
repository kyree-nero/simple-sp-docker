#!/bin/sh

docker container stop sp-app
docker container rm sp-app

docker build  --no-cache  --network=host -t sp-app -f Dockerfile.app .
docker run -it --name=sp-app --publish=8080:8080  --network sp-net  sp-app:latest   