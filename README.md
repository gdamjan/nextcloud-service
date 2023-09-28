[![CI](https://github.com/gdamjan/nextcloud-service/actions/workflows/ci.yml/badge.svg)](https://github.com/gdamjan/nextcloud-service/actions/workflows/ci.yml)

# `Nextcloud as a systemd portable service`

Build an immutable [Nextcloud](https://nextcloud.com/) image for a systemd [portable service](https://systemd.io/PORTABLE_SERVICES/).
Made with uwsgi and nixos.

## Quick Start

Get the latest image from [Github releases](https://github.com/gdamjan/nextcloud-service/releases/), into
`/var/lib/portables` and then run:

```sh
portablectl attach nextcloud_<version>
systemctl enable --now nextcloud-uwsgi.socket nextcloud-cron.timer
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

## Units provided

The cron timer and service, periodically call `php -f cron.php` to run some
nextcloud bookkeeping jobs:
* `nextcloud-cron.timer`
* `nextcloud-cron.service`

The socket and uwsgi socket (`/run/nextcloud.sock`) is the main service:
* `nextcloud-uwsgi.socket`
* `nextcloud-uwsgi.service`

The firstrun service, scaffolds `/var/lib/nextcloud` with the minimal
configuration needed for a portable service to run successfully:
* `nextcloud-first-run.service`

## More info

See the [wiki](https://github.com/gdamjan/nextcloud-service/wiki/) for more info.

## Build and update

Have nix flakes enabled, and then:
```
nix flake update  # will update flake.lock
nix build         # will create an image in ./result/
```
