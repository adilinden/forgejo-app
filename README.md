# forgejo-app

Self-contained deployment of the Forgejo git forge at forgejo.cstl.one.
Clone, configure, deploy. Mirrors the structure of a Docker Compose stack —
everything lives in the repo directory.

## Layout

| Path | Purpose |
|------|---------|
| `deploy.sh` | Downloads pinned Forgejo binary, verifies checksum, installs systemd unit |
| `bin/` | Forgejo binary — gitignored, populated by deploy.sh |
| `etc/app.ini.example` | Config template — copy to `etc/app.ini` and fill values |
| `logs/` | Log directory — gitignored except .gitkeep |
| `repos/` | Git repositories — gitignored except .gitkeep |
| `systemd/forgejo.service` | systemd unit — paths fixed to /opt/forgejo-app |

Files never committed: `etc/app.ini`, `bin/forgejo`, `logs/*`, `repos/*`,
`versions.env`

## Deployment

Clone to `/opt/forgejo-app` as the git user:

    git clone https://github.com/adilinden/forgejo-app.git /opt/forgejo-app
    cd /opt/forgejo-app
    bash deploy.sh
    cp etc/app.ini.example etc/app.ini
    vim etc/app.ini    # fill in DB password and generated secrets
    systemctl enable --now forgejo

See runbook-forgejo.md for full build steps.

## Upgrading

Update `FORGEJO_VERSION` in `deploy.sh`, commit, then on the forgejo LXC:

    cd /opt/forgejo-app
    git pull
    bash deploy.sh
    systemctl restart forgejo

To test a new version locally before committing, copy `versions.env.example`
to `versions.env`, set the desired version, run `bash deploy.sh`.
`versions.env` is gitignored and will not be committed.

## Changelog

| Date | Change |
|------|--------|