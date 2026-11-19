# Install Suwayomi on this Umbrel

Two paths. Path A needs no terminal. Path B uses the staged package in this
folder (no `chown` step, Mihon/Tachiyomi API whitelisted through the proxy).

## Path A — the one-click community store (fastest)

1. App Store -> three dots (top right) -> **Community App Stores** -> paste
   `https://github.com/LoloMojo/umbrel-suwayomi-store` -> **Add**
2. Three dots -> **Open** -> install **Suwayomi**
3. If the app goes "ready" but the page will not load (0 MB RAM, connection
   refused), the data folder is root-owned and the container runs as UID 1000.
   Fix once from the umbrelOS terminal (Settings -> Advanced Settings ->
   Terminal -> App -> Host):
   ```bash
   sudo chown -R 1000:1000 /home/umbrel/umbrel/app-data/manga-suwayomi/data
   ```
   Then right-click the Suwayomi icon -> Restart.
4. Mihon/Tachiyomi on your phone will not connect through this package: the
   Umbrel login intercepts `/api/graphql`. Browser reading works fine.

## Path B — this staged package (recommended if you want phone clients)

Publish this folder to the Gitea that already runs on your Umbrel, then add it
as a community store.

On the umbrelOS host terminal (Settings -> Advanced Settings -> Terminal ->
App -> Host):

```bash
# 1. one-time Gitea token: Gitea -> Settings -> Applications -> Generate New Token (write:repository)
export GITEA_TOKEN=<paste-token>

# 2. publish (files live in the Hermes app data directory)
cd /home/umbrel/umbrel/app-data/hermes-agent/data/hermes/suwayomi-store
sh publish-store-to-gitea.sh http://localhost:3000 <your-gitea-user> suwayomi-store
```

The script prints the store URL, e.g.
`http://localhost:3000/<user>/suwayomi-store.git`.

Then: App Store -> three dots -> **Community App Stores** -> paste that URL ->
**Add** -> three dots -> **Open** -> install **Suwayomi**.

Notes:

- Suwayomi has no built-in authentication. Path B runs it behind the Umbrel
  login except for `/api/*` and `/opds/*`, which are open on your LAN so Mihon
  can reach the server. Do not port-forward this app to the internet.
- Data lives in `app-data/mangaserver-suwayomi/data` (settings, library,
  downloads). Back that folder up.
- Update by editing `mangaserver-suwayomi/umbrel-app.yml` (version +
  releaseNotes) and the pinned image tag/digest in `docker-compose.yml`, then
  re-run the publish script and click Update in the App Store.
