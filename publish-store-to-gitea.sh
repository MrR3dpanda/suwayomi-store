#!/bin/sh
# Publish a staged community app store folder to the Gitea that runs on the same Umbrel.
# Verified against Gitea 1.22 API semantics (create repo, create file, update file with sha).
# Needs only curl + base64 + sed (umbrelOS host may have no git/jq/python).
#
# Usage:  GITEA_TOKEN=<token> sh publish-store-to-gitea.sh [GITEA_URL] [OWNER] [REPO] [FILES...]
# Defaults: GITEA_URL=http://localhost:3000, REPO=<folder name>, OWNER read from the token.
# Token: Gitea -> Settings -> Applications -> Generate New Token, scope write:repository.

set -eu

URL=${1:-http://localhost:3000}
OWNER=${2:-}
REPO=${3:-}
shift 3 2>/dev/null || shift $#
: "${GITEA_TOKEN:?set GITEA_TOKEN to a Gitea access token with write:repository}"

API="$URL/api/v1"
SRC=$(dirname "$0")
[ -n "$REPO" ] || REPO=$(basename "$SRC")
AUTH="Authorization: token $GITEA_TOKEN"

jstr() { tr -d ' \t\n\r' | sed -n 's/.*"'"$1"'":"\([^"]*\)".*/\1/p' | head -1; }
req() { curl -fsS -H "$AUTH" -H 'Content-Type: application/json' "$@"; }

VER=$(curl -fsS "$API/version" | jstr version) || true
if [ -z "${VER:-}" ]; then echo "!! cannot reach $API/version at $URL" >&2; exit 1; fi
echo "== Gitea $VER at $URL"

if [ -z "$OWNER" ]; then OWNER=$(req "$API/user" | jstr login) || true; fi
if [ -z "${OWNER:-}" ]; then echo "!! could not read owner from the token; pass it as arg 2" >&2; exit 1; fi
echo "   owner $OWNER, repo $REPO"

# Gitea repos default to private; umbrelOS cannot clone those, so force public.
if resp=$(req -X POST "$API/user/repos" -d "{\"name\":\"$REPO\",\"private\":false,\"auto_init\":false}"); then
  BRANCH=$(printf '%s' "$resp" | jstr default_branch)
  echo "   created $OWNER/$REPO"
else
  resp=$(req "$API/repos/$OWNER/$REPO")
  BRANCH=$(printf '%s' "$resp" | jstr default_branch)
  echo "   repo already exists"
fi
if [ -z "${BRANCH:-}" ]; then BRANCH=main; fi
echo "   branch $BRANCH"

put() { # create the file, or update it in place using its current blob sha
  if [ ! -f "$SRC/$1" ]; then echo "   skip $1"; return 0; fi
  b64=$(base64 < "$SRC/$1" | tr -d '\n')
  sha=$(req "$API/repos/$OWNER/$REPO/contents/$1?ref=$BRANCH" 2>/dev/null | jstr sha) || sha=""
  extra=""
  if [ -n "${sha:-}" ]; then extra=",\"sha\":\"$sha\""; fi
  out=$(curl -sS -o /dev/null -w '%{http_code}' -X PUT \
      -H "$AUTH" -H 'Content-Type: application/json' \
      "$API/repos/$OWNER/$REPO/contents/$1" \
      -d "{\"branch\":\"$BRANCH\",\"message\":\"add $1\",\"content\":\"$b64\"$extra}") || out=000
  case "$out" in
    200|201) echo "   ok    $1" ;;
    *)       echo "   FAIL  $1 (HTTP $out)"; FAILED=1 ;;
  esac
}

FAILED=0
if [ $# -gt 0 ]; then
  for f in "$@"; do put "$f"; done
else
  for f in umbrel-app-store.yml README.md INSTALL.md; do put "$f"; done
  for f in $(cd "$SRC" && find . -mindepth 2 -type f ! -path './.git/*' | sed 's|^\./||'); do put "$f"; done
fi

echo
echo "Community app store URL (App Store -> ... -> Community App Stores -> Add):"
echo "   $URL/$OWNER/$REPO.git"
if [ "$FAILED" != 0 ]; then exit 1; fi
