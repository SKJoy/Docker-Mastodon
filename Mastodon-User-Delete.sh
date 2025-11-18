#!/bin/bash

docker compose run --rm web tootctl accounts delete $1

