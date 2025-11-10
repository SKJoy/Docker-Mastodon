#!/bin/bash

docker compose down
docker compose up -d
docker container logs mastodon-web-1 -f

