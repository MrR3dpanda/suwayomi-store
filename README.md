# Suwayomi — Umbrel community app store

Staged umbrelOS app package for [Suwayomi](https://suwayomi.github.io/), the
self-hosted manga reader/downloader server that runs Mihon/Tachiyomi extensions.

```
umbrel-app-store.yml      # store manifest (id: mangaserver)
mangaserver-suwayomi/     # app package; folder name == app id
  umbrel-app.yml
  docker-compose.yml
```

- Image: `ghcr.io/suwayomi/suwayomi-server:v2.4.2366`, pinned by multi-arch
  index digest (amd64 + arm64).
- Runs as root inside the container so the umbrelOS-created bind mount needs no
  manual `chown` (the upstream image defaults to UID 1000, which cannot write a
  root-owned data dir — that is why other community packages ask for an SSH fix).
- `PROXY_AUTH_WHITELIST=/api/graphql,/api/*,/opds/*` so Mihon/Tachiyomi phone
  clients and OPDS readers reach the server; everything else stays behind the
  Umbrel login.
- Persistence: `${APP_DATA_DIR}/data` -> `/home/suwayomi/.local/share/Tachidesk`.

See `INSTALL.md` for the publish + install clicks.
