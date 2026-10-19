# ── build stage ───────────────────────────────────────────────────────────────
# Standalone build — the Docker context is this repo root. All @meddleware/*
# dependencies resolve from the npm registry, so they must be published before
# this image is built.
#
#   docker build -t landing:<tag> .
#
# No VITE_* build args are required — the landing page has no wallet, no chain
# SDK, and no operator-configurable runtime values.

# Content-Security-Policy served by static-server. The page makes no request at all (no fetch, no storage but the
# colour mode, no remote image or font), so every fetch directive stays on 'self' (connect-src, img-src and
# worker-src are no longer opened to any https origin). e2e/csp.spec.ts loads the built pages under exactly this
# policy and fails on any violation; scripts/check-csp-inline.mjs fails the build on an inline script.
ARG CSP="default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; font-src 'self' data:; connect-src 'self'; object-src 'none'; base-uri 'self'; form-action 'self'; frame-ancestors 'self'; upgrade-insecure-requests"

FROM node:26-slim@sha256:0d1e33586362bb9e608c4e751e7a9e7edb55c9ac11461ed5666af696cc461dd4 AS build
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
RUN npm run build && npm run licenses
ARG CSP
# The CSP has no 'unsafe-inline' for scripts: the build fails if dist/ ever carries an inline <script>.
RUN node scripts/check-csp-inline.mjs "${CSP}" dist

# ── runtime stage ─────────────────────────────────────────────────────────────
# static-server is a minimal Go binary image — no shell, no package manager.
# See https://github.com/meddleware-org/static-server for configuration details.

FROM quay.io/meddleware-org/static-server:0.1.9@sha256:af6cc284dace0d7bcacca61765f1e5efa0681da503c607f6e13ea35ce19edc72
ARG CSP
ENV CONTENT_SECURITY_POLICY="${CSP}"

COPY --from=build /app/dist /app/public
# The lockfile lets SBOM scanners see the npm packages the bundle was built from (the bundle itself carries no
# package metadata). It sits outside the served directory; THIRD_PARTY_LICENSES is served with the site.
COPY --from=build /app/package-lock.json /usr/share/doc/landing/package-lock.json

# One route, so no SPA fallback: an unknown path gets the 404 page (404.html, which runs the same app) with a
# real 404 status instead of the home page with a 200.
ENV SERVE_DIR=/app/public \
    NOT_FOUND_PAGE=/404.html \
    CACHE_IMMUTABLE_PREFIX=/assets/

# The base image already runs as nobody; say so here too so the Dockerfile is self-describing.
USER 65534:65534

EXPOSE 8080
