# ── build stage ───────────────────────────────────────────────────────────────
# Standalone build — the Docker context is this repo root. All @meddleware/*
# dependencies resolve from the npm registry, so they must be published before
# this image is built.
#
#   docker build -t landing:<tag> .
#
# No VITE_* build args are required — the landing page has no wallet, no chain
# SDK, and no operator-configurable runtime values.

FROM node:24-slim AS build
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
RUN npm run build

# ── runtime stage ─────────────────────────────────────────────────────────────
# static-server is a minimal Go binary image — no shell, no package manager.
# See https://github.com/meddleware-org/static-server for configuration details.

FROM quay.io/meddleware-org/static-server:0.1.1

COPY --from=build /app/dist /app/public

ENV SERVE_DIR=/app/public \
    SPA_FALLBACK=true \
    CACHE_IMMUTABLE_PREFIX=/assets/

EXPOSE 8080
