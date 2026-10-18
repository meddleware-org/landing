#!/usr/bin/env bash
# Smoke test of the built landing image: bash scripts/smoke.sh <image>
#
# Runs the image the way the cluster does (the image's own user, read-only root filesystem, no capabilities,
# no privilege escalation) and checks what must hold for the page to be served safely:
#   - the image is configured to run as 65534:65534 (not root);
#   - the in-image `-healthcheck` mode succeeds;
#   - `/` answers 200 with the page shell (`<div id="app">`), `Cache-Control: no-cache`, and the security
#     headers: nosniff, X-Frame-Options, Referrer-Policy, HSTS, Permissions-Policy and the Dockerfile CSP
#     (`script-src 'self'` plus a fresh nonce, `connect-src 'self'`, no 'unsafe-inline' for scripts);
#   - the bundle referenced by the shell is served from /assets/ with an immutable Cache-Control;
#   - `/THIRD_PARTY_LICENSES` is served; an unknown route is a 404 with the 404 page shell (NOT_FOUND_PAGE); the old
#     static-host files `_headers` and `CNAME` are not served;
#   - a missing file under /assets/ is a 404 without Cache-Control; dot-files are refused; POST is a 405.
#
# Build first: `docker build -t landing:ci .` (CONTAINER_ENGINE=podman for rootless podman). The engine is
# $CONTAINER_ENGINE, else docker when its daemon answers, else podman. Needs curl; nothing else.
set -euo pipefail

image="${1:?usage: smoke.sh <image>}"

engine="${CONTAINER_ENGINE:-}"
if [ -z "$engine" ]; then
  if command -v docker > /dev/null 2>&1 && docker info > /dev/null 2>&1; then
    engine=docker
  elif command -v podman > /dev/null 2>&1; then
    engine=podman
  else
    echo "no usable container engine (set CONTAINER_ENGINE)" >&2
    exit 1
  fi
fi

fail() {
  echo "smoke test FAILED: $*" >&2
  exit 1
}

user="$("$engine" image inspect --format '{{.Config.User}}' "$image")"
[ "$user" = "65534:65534" ] || fail "image runs as '${user}', want 65534:65534"

work="$(mktemp -d)"
cid="$("$engine" run -d --rm --read-only --cap-drop ALL --security-opt no-new-privileges \
  -p 127.0.0.1::8080 "$image")"
trap '"$engine" logs "$cid" 2>&1 | tail -20; "$engine" rm -f "$cid" > /dev/null 2>&1 || true; rm -rf "$work"' EXIT

hostport="$("$engine" port "$cid" 8080/tcp | head -n 1)"
base="http://${hostport}"

# fetch <method> <path>: sets $code and writes $work/headers and $work/body.
fetch() {
  code="$(curl -sS -X "$1" -D "$work/headers" -o "$work/body" -w '%{http_code}' "${base}$2")"
}
# header <name>: prints the value of a response header from the last fetch (case-insensitive).
header() {
  { grep -i "^$1:" "$work/headers" || true; } | head -n 1 | cut -d: -f2- | tr -d '\r' | sed 's/^ *//'
}
# require_header <name> <pattern> <method> <path>: the header must exist and match the extended regex.
require_header() {
  local v
  v="$(header "$1")"
  [[ "$v" =~ $2 ]] || fail "$3 $4: header $1 is '${v}', want match for $2"
}
security_headers() { # <method> <path>
  require_header X-Content-Type-Options '^nosniff$' "$1" "$2"
  require_header X-Frame-Options '^SAMEORIGIN$' "$1" "$2"
  require_header Referrer-Policy '^strict-origin-when-cross-origin$' "$1" "$2"
  require_header Strict-Transport-Security '^max-age=31536000; includeSubDomains$' "$1" "$2"
  require_header Permissions-Policy '^camera=\(\), geolocation=\(\), microphone=\(\), payment=\(\)$' "$1" "$2"
  require_header Content-Security-Policy "default-src 'self'; script-src 'self' 'nonce-[A-Za-z0-9+/]{22}=='; style-src 'self' 'unsafe-inline'; .*connect-src 'self'[^;]*; .*frame-ancestors 'self'" "$1" "$2"
  local csp
  csp="$(header Content-Security-Policy)"
  [[ "$csp" != *"script-src 'self' 'unsafe-inline'"* ]] || fail "$1 $2: CSP allows inline scripts"
}

# Wait for the server (the in-image healthcheck mode doubles as the readiness probe).
ready=""
for _ in $(seq 1 30); do
  if "$engine" exec "$cid" /server -healthcheck > /dev/null 2>&1; then
    ready=1
    break
  fi
  sleep 1
done
[ -n "$ready" ] || fail "the in-image -healthcheck never succeeded"

fetch GET /
[ "$code" = 200 ] || fail "/ answered ${code}, want 200"
grep -q '<div id="app">' "$work/body" || fail "/ is not the SPA shell"
require_header Cache-Control '^no-cache$' GET /
security_headers GET /

# The bundle the shell references is served from /assets/ and cached as immutable.
bundle="$(grep -o 'src="/assets/[^"]*\.js"' "$work/body" | head -n 1 | sed 's/^src="//; s/"$//')"
[ -n "$bundle" ] || fail "the shell references no /assets/ bundle"
fetch GET "$bundle"
[ "$code" = 200 ] || fail "${bundle} answered ${code}, want 200"
require_header Cache-Control 'immutable' GET "$bundle"
security_headers GET "$bundle"

fetch GET /THIRD_PARTY_LICENSES
[ "$code" = 200 ] || fail "/THIRD_PARTY_LICENSES answered ${code}, want 200"
[ -s "$work/body" ] || fail "/THIRD_PARTY_LICENSES is empty"
security_headers GET /THIRD_PARTY_LICENSES

# An unknown route is a real 404 carrying the page shell (the 404 entry), not a 200 (NOT_FOUND_PAGE, no SPA fallback).
fetch GET /some/client/route
[ "$code" = 404 ] || fail "an unknown route answered ${code}, want 404"
grep -q '<div id="app">' "$work/body" || fail "the 404 response is not the 404 page shell"
security_headers GET /some/client/route

# The vestigial static-host files are gone (audit F5).
for stale in /_headers /CNAME; do
  fetch GET "$stale"
  [ "$code" = 404 ] || fail "${stale} answered ${code}, want 404"
done

fetch GET /assets/missing.abc123.js
[ "$code" = 404 ] || fail "/assets/missing.abc123.js answered ${code}, want 404"
[ -z "$(header Cache-Control)" ] || fail "404 under /assets/ carries Cache-Control: $(header Cache-Control)"
security_headers GET /assets/missing.abc123.js

fetch GET /.env
[ "$code" = 404 ] || fail "/.env answered ${code}, want 404"

fetch POST /
[ "$code" = 405 ] || fail "POST / answered ${code}, want 405"
security_headers POST /

echo "smoke test passed (${engine}, ${image})"
