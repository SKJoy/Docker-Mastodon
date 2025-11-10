# `Mastodon` with Docker
- All persistent data are stored in project path
- Meant to be used behind reverse proxy with SSL termination

## Installation
- Recommended to copy `Environment/.domain.tld.env` to another file matching the domain name
- Copy `.sample.env` to `.env` file
- Update `.env` file to match the previous **environment** file
- Update `USER_ID` and `USERGROUP_ID` according to the **user** running this Docker instance
- Create `Volume/Mastodon/Public`: `mkdir Volume/Mastodon/Public -p`
- Set **permission** for public path: `chmod -R 0777 Volume/Mastodon/Public`
- Modify network subnet `DOCKER_NETWORK_PREFIX` in `.env` file to avoid collision with existing Docker network
- ### Command
	- Setup: `docker compose run --rm web rake mastodon:setup` and follow the on screen instruction
	- #### Generate
		- **Encryption** secrets: `docker compose run --rm web rails db:encryption:init`
		- **VAPID** keys: `docker compose run --rm web rails mastodon:webpush:generate_vapid_key`
- ### Reverse proxy: `NginX`
	- Main site
		```
		# Not required for NginX Proxy Manager, just create a new proxy host
		# Assuming mastodon port is 3000

		location / {
			proxy_http_version 1.1;
			proxy_set_header Connection "upgrade";
			proxy_set_header Host $host;
			proxy_set_header Upgrade $http_upgrade;
			proxy_set_header X-Real-IP $remote_addr;
			proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
			proxy_set_header X-Forwarded-Proto $scheme;
			proxy_pass http://localhost:3000;
		}
		```
	- Streaming
		```
		# Assuming streaming port is 4000
		# Add a custom location for NginX Proxy Manager

		location /api/v1/streaming/ {
			proxy_set_header Connection "upgrade";

			# Not required for NginX Proxy Manager / Begin
			proxy_http_version 1.1;
			proxy_pass http://localhost:4000;
			proxy_set_header Host $host;
			proxy_set_header Upgrade $http_upgrade;
			proxy_set_header X-Real-IP $remote_addr;
			proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
			proxy_set_header X-Forwarded-Proto $scheme;
			# Not required for NginX Proxy Manager / End
		}
		```

## App
- **Android**: Check Google Play store for `Mastodon` app
- **iOS**: Check app store for `Mastodon` app

## Federate with other remote `Mastodon` instances
- Pick a **relay** server from `https://relaylist.com`
- Navigate to `More/Administration/Relays`
- Use `Add new relay` button
- **Block** specific `Mastodon` domain
	- Navigate to `More/Moderation/Federation`
	- Use `Add new domain block` to control posts

## Control
- **Block** contents for `unauthenticated` users: Set `MASTODON_DISALLOW_UNAUTHENTICATED_API_ACCESS` to `false` in `.env` file
- **Restrict** to `single` (admin) user only: Set `MASTODON_SINGLE_USER` to `true` in `.env` file
- **Customize** `OIDC` button label: Set value for `MASTODON_OIDC_NAME` in `.env` file
- **Upgrade**: Check official repository and set value for `MASTODON_VERSION` in `.env` file

## Utility
- ### Note
	- Utility scripts are to be run from within the **project path**
- ### Script
	- `Mastodon-Terminal.sh`: Open terminal within the `Mastodon web` container
	- `Restart.sh`: Stop and restart the project
	- `Recreate.sh`: Remove containers and recreate them back; no persistent data is lost
	- `Reset.sh`: Same as `Recreate` but all persistent data is lost; to create a fresh instance

## Documentation
- Official repository: `https://github.com/mastodon`
- Website: `https://docs.joinmastodon.org/`