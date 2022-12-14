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

> ⚠️ Warning ⚠️
>
> On the first install wizard, don't enable the "Default Applications" in nextcloud (click cancel).
> For more info see [issues](https://github.com/gdamjan/nextcloud-service/issues/2).

## Nginx configuration

The portable service will operate on the `/run/nextcloud.sock` uwsgi socket. We gonna let the host nginx handle
all the http, https and letsencrypt work. The config is simple, just proxy everything back to the uwsgi socket:
```
server {
    …
    client_body_buffer_size 512k;
    client_max_body_size 512M;
    client_body_timeout 300s;
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
> block the application workers.

> Note²: Consult the [nextcloud nginx installation docs](https://docs.nextcloud.com/server/latest/admin_manual/installation/nginx.html)
> for non-fastcgi nginx parameters.

## More info

See the [wiki](https://github.com/gdamjan/nextcloud-service/wiki/) for more info.
