[![Build Status](https://github.com/gdamjan/nextcloud-service/workflows/Make%20a%20release/badge.svg)](https://github.com/gdamjan/nextcloud-service/actions)

# `Nextcloud as a systemd portable service`

Build an immutable [Nextcloud](https://nextcloud.com/) image for a systemd [portable service](https://systemd.io/PORTABLE_SERVICES/).
Made with uwsgi and nixos.

## Quick Start

Get the latest image from [Github releases](https://github.com/gdamjan/nextcloud-service/releases/), into
`/var/lib/portables` and then run:

```sh
portablectl attach --enable --now nextcloud
```

See the [wiki](https://github.com/gdamjan/nextcloud-service/wiki/) for more info.
