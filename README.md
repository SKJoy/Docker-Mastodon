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
		- **Encryption** secrets (not required if setup ran): `docker compose run --rm web rails db:encryption:init`
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

## Hack
- Change `Mastodon` logo on top right
	- Navigate to `More/Administration/Server settings/Appearance`
	- Convert custom logo image into `Base64` ecoded string
	- Use the `Bse64` encoded image data with custom `CSS`
		```
		.column-link--logo{display: inline-block; width: 180px; height: 48px; background-size: auto;}
		.column-link--logo, .column-link--logo:hover{background-image: url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAALQAAAAwCAYAAAC47FD8AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAyJpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuMy1jMDExIDY2LjE0NTY2MSwgMjAxMi8wMi8wNi0xNDo1NjoyNyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RSZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENTNiAoV2luZG93cykiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6MUVEQ0Q4NDJCRTM4MTFGMEE2NDRBNDI2MDUwQzlENTUiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6MUVEQ0Q4NDNCRTM4MTFGMEE2NDRBNDI2MDUwQzlENTUiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDoxRURDRDg0MEJFMzgxMUYwQTY0NEE0MjYwNTBDOUQ1NSIgc3RSZWY6ZG9jdW1lbnRJRD0ieG1wLmRpZDoxRURDRDg0MUJFMzgxMUYwQTY0NEE0MjYwNTBDOUQ1NSIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/Pn2FeZgAAA0BSURBVHja7Fx7cBXV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);}
		.logo, .logo--wordmark{display: none;}
		```
	- Adjust `height` & `width` properties accordingly; `180px` height is recommended

## Documentation
- Official repository: `https://github.com/mastodon`
- Website: `https://docs.joinmastodon.org/`