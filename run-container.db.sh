#!/bin/sh
docker container stop sp-db
docker container rm sp-db
docker network rm sp-net

docker network create --driver bridge sp-net
docker build  --no-cache  -t sp-db -f Dockerfile.db .
docker run -d --name=sp-db --publish=3306:3306  --network sp-net  sp-db:latest   