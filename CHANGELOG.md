# Changelog

All notable changes to landing are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.14] - 2026-10-24

### Changed

- Renamed from `landing` to `landing-site` (workspace naming convention, `docs/architecture/ADR-0003-naming.md`). No code change beyond names, paths, hostnames and dependency names; the history below keeps the old names.

## [0.0.13] - 2026-10-22

### Changed

- Image base: static-server 0.1.11 (Go 1.26.10 standard library, CVE-2026-111943, so the scan-before-sign gate passes)

## [0.0.12] - 2026-10-18

### Added

- A real 404 page (`404.html`, a second Vite entry running the same app with a catch-all not-found view); the image serves it with status 404 for unknown paths (`NOT_FOUND_PAGE=/404.html`, no SPA fallback)
- Build-time inline-script check (`scripts/check-csp-inline.mjs`, `npm run check:csp`): the image build and CI fail if `dist/` carries an inline `<script>` the CSP does not allow
- Unit tests (`npm test`, vitest) for the inline-script check and the route table, run in CI and in the release gate
- Real-browser accessibility gate (`npm run test:e2e`, Playwright + axe): the home and 404 pages in every theme x season, and a load under the served CSP with no violation
- Container probe in CI (`scripts/smoke.sh`): the built image runs read-only and non-root; headers, bundle cache, licences, the 404 and the absent static-host files are checked

### Changed

- Depends on design-tokens ^0.1.10; image base moved to static-server 0.1.8
- CSP `connect-src`, `img-src` and `worker-src` narrowed to `'self'` (plus `data:` for images): the page makes no cross-origin request
- Footer links no longer dim with opacity (contrast was 4.12:1 in the dark footer; now the footer's own muted token)

### Removed

- The vestigial static-host files `public/_headers` and `public/CNAME` (they were served as plain files)

### Security

- The weaker, unused `script-src 'unsafe-inline'` policy in `_headers` is gone
