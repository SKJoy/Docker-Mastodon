#!/bin/bash

docker compose down
rm -rf Volume
docker compose run --rm web rake mastodon:setup
docker compose up -d
docker container logs mastodon-web-1 -f

