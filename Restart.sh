#!/bin/bash

docker compose stop
docker compose start
docker container logs mastodon-web-1 -f

