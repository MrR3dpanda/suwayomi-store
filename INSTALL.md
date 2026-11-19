# Install Suwayomi on this Umbrel

The store is published and public:

```
https://github.com/MrR3dpanda/suwayomi-store.git
```

1. App Store -> three dots (top right) -> **Community App Stores** -> paste that
   URL -> **Add**
2. Three dots -> **Open** -> install **Suwayomi**
3. Open the app, go to Browse -> Extensions and install the sources you want.
   If the extension list is empty, set the source in Settings to
   `https://raw.githubusercontent.com/keiyoushi/extensions/repo/index.min.json`

Notes:

- Suwayomi has no built-in authentication. It runs behind the Umbrel login
  except for `/api/*` and `/opds/*`, which are open on your LAN so Mihon /
  Tachiyomi on a phone can reach the server. Do not port-forward this app to
  the internet.
- The container runs as root on purpose: the upstream image defaults to UID
  1000, which cannot write the root-owned bind mount umbrelOS creates, and that
  is why other community packages ask for a manual `chown`.
- Data lives in `app-data/mangaserver-suwayomi/data` (settings, library,
  downloads). Back that folder up.
- Image is pinned: `ghcr.io/suwayomi/suwayomi-server:v2.4.2366@sha256:1fac27c3...`
  (multi-arch index, amd64 + arm64). To update, bump the tag and digest in
  `docker-compose.yml`, bump `version` + `releaseNotes` in
  `mangaserver-suwayomi/umbrel-app.yml`, push, then click Update in the App
  Store.

## Alternative store (not used)

`https://github.com/LoloMojo/umbrel-suwayomi-store` is a public package that
predates this one. It runs the container as UID 1000 and therefore needs a
one-time `sudo chown -R 1000:1000 /home/umbrel/umbrel/app-data/manga-suwayomi/data`,
and it does not whitelist `/api/graphql`, so Mihon on a phone cannot connect
through it.
