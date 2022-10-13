[![CI](https://github.com/gdamjan/nextcloud-service/actions/workflows/ci.yml/badge.svg)](https://github.com/gdamjan/nextcloud-service/actions/workflows/ci.yml)

# `Nextcloud as a systemd portable service`

Build an immutable [Nextcloud](https://nextcloud.com/) image for a systemd [portable service](https://systemd.io/PORTABLE_SERVICES/).
Made with uwsgi and nixos.

## Quick Start

Get the latest image from [Github releases](https://github.com/gdamjan/nextcloud-service/releases/), into
`/var/lib/portables` and then run:

```sh
portablectl attach --enable --now nextcloud…
```

## Nginx configuration

The portable service will operate on the `/run/nextcloud.sock` uwsgi socket. We gonna let the host nginx handle
all the http, https and letsencrypt work. The config is simple, just proxy everything back to the uwsgi socket:
```
server {
    …
    location / {
        include uwsgi_params;
        uwsgi_pass unix:/run/nextcloud.sock;
        uwsgi_intercept_errors on;
        uwsgi_request_buffering off;
    }
    …
}
```
> Note: even static files are served by the uwsgi server, but uwsgi has a good enough static files server, which doesn't
> block the application workers

## More info

See the [wiki](https://github.com/gdamjan/nextcloud-service/wiki/) for more info.
