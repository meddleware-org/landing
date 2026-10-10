# Security Audit — `landing`

**Classification:** Internal security review
**Project:** `repos/landing` — the corporate landing page (`meddleware.co.uk`): hero, tool cards, links to the dashboard and docs
**Project type:** Vue app (static single-page site; no library entry)
**Template:** AUDIT_TEMPLATE.md (2026-10-08) + AUDIT_TEMPLATE_TS.md (2026-10-08) + AUDIT_TEMPLATE_VUE.md (2026-10-08) + AUDIT_TEMPLATE_IMG.md (2026-10-08)
**Package manager / lockfile:** npm 11, committed (also copied into the image for SBOM tools)   **Module format:** ESM   **Publish model:** image only (`private: true` from 0.0.7; not on npm)
**Runtime targets:** browser   **Peer dependencies:** none
**Build tool:** vite 8.3.3, `@vitejs/plugin-vue` 6.0.9, vue 3.5.43, vue-router 5.3.1, vue-tsc 3.3.12, TypeScript 6.0.3
**Hosting:** container image on static-server 0.1.7 (CSP and HSTS from the server); `public/_headers` and `public/CNAME` are vestigial static-host files that no host reads but static-server serves as plain files (F5)
**Embedding hosts:** none (no exported view)
**VITE_\* inventory:** none — `import.meta.env` is not read anywhere in `src/`
**Images:** `quay.io/meddleware-org/landing:0.0.11@sha256:392c4b1b…520a` (Docker Hub mirror; cosign keyless, SPDX SBOM attestation, build provenance; cosign-verified 2026-10-09, `verify-digests.sh` 16/16)
**Base images:** build `node:24-slim@sha256:0e0ff40c…f9b6`; runtime `quay.io/meddleware-org/static-server:0.1.7@sha256:2e227311…2379` (Go 1.26.9)
**Runtime user:** `USER 65534:65534`   **Runtime FS:** read-only root, no writable mounts
**Deployed by:** `post-bootstrap/landing/overlays/default`; digest from `config/images.yaml`
**Build args:** `CSP` only (the Content-Security-Policy string) — not secret, not a test switch; no `VITE_*`
**Deployment status:** image `quay.io/meddleware-org/landing` 0.0.11 serving `meddleware.co.uk` (`sha256:392c4b1b…`, deployed 2026-10-09; live page links the five live tool hosts, the dashboard and the docs). The package is not on npm (confirmed 404 again 2026-10-10).
**Review date:** 2026-10-03 (first pass) · re-verified 2026-10-09
**Reviewer:** Internal review
**Severity ceiling:** Low — a static page with no wallet, chain access, forms or user data.
**Status:** re-verified 2026-10-09

---

## Executive summary

A static Vue page: header, hero, five tool cards and a call to action, all linking to first-party
hosts. No wallet, no chain SDK, no `VITE_*` values, no storage beyond `@meddleware/ui`'s colour mode,
no forms.

This first pass found, and fixed in 0.0.7:

- **F1 (Low)** — the DAO card linked to `sui-dao.meddleware.co.uk`, which has had no DNS record since
  the DAO console was retired, and described governance that does not exist. It is now the live
  Treasury console.
- **F2 (Info)** — the app was publishable to npm and had been published by hand without provenance;
  nothing consumed it. It is now `private`, and the package is no longer on npm.
- **F3 (Info)** — `ToolCard` bound its `href` prop without `safeHref`.

Re-verified 2026-10-09 (0.0.11; `vue-tsc` clean, audit gate 1 allowlisted / 0 open; live site
`meddleware.co.uk` read 2026-10-10). F1–F4 hold:
the five card links and the dashboard, docs and developer-docs links all answer 200 and `sui-dao.` does not
resolve. Fixed since the first pass:

- **F8 (Low, RESOLVED 0.0.9–0.0.11)** — a push/PR CI workflow now exists, and the image release runs the
  full CI workflow, scans the published image before cosign signs it, ships the lockfile for SBOM tools,
  serves `/THIRD_PARTY_LICENSES` (HTTP 200 live), runs as an explicit `USER 65534:65534` on static-server
  0.1.7, and the pod sets `automountServiceAccountToken: false`.

The newly applicable lens checks found defects that are **not yet fixed** (content and workflow changes
are outside this alignment; each is a one- or two-line change for the next patch release):
**F5 (Low, DEFERRED)** a vestigial `public/_headers` (with `script-src 'unsafe-inline'`) and `CNAME` are
shipped and served as files; **F6 (Info, DEFERRED)** unknown paths answer 200 with the page shell;
**F7 (Info, DEFERRED)** no build-time inline-script check; **F9 (Info, DEFERRED)** `node-ci.yml` has no
`npm test` step (the page has no tests today, so nothing is skipped); **F10 (Info, DEFERRED)** contrast of
the page's own dimmed links is not browser-checked. Accepted or maintainer items: **F11** blanket
`connect-src https:` and **F12** the cosign identity pins the repository not the workflow (ACCEPTED-RISK);
**F13** registry mirror and credential inventory (DEFERRED, maintainer).

The severity ceiling stays Low.

## Threat model / trust boundaries

| Actor | Holds / proves | Can do | Bounded by |
| --- | --- | --- | --- |
| Visitor | nothing | read, follow links | static content |
| Publish path | registry robot tokens | push an altered image | tag-gated CI; Trivy then cosign; SBOM and provenance attestations; digest pinning in the cluster |
| Retired or unowned hosts | — | serve content behind a stale link | links only to live first-party hosts (F1) |
| Embedding host / shared wallet | — | — | none: no wallet, no exported view |
| On-chain, relay and RPC data the UI renders | — | — | none: the page renders only its own literals |
| Static host / CDN | headers, served bytes | modify or strip them | CSP and HSTS from static-server, digest-pinned image (B.VUE-1); static-server adds a per-response script nonce for Cloudflare's injected script |
| Base-image publisher, registry | image layers, the manifest served for a tag | ship altered bytes | digest pinning (build and runtime base, deployment by digest); signature verified by `verify-digests.sh` |
| Whoever controls the build environment | the build mode and any `.env*` file | bake a value or a test hook into the bundle | no `VITE_*` is read; `.dockerignore` excludes `.env*.local`; `.gitignore` ignores `.env.*` |

## Severity scale

Critical / High / Medium / Low / Info / Positive.

## Scope

- **In scope (0.0.11):** `src/**`, `index.html`, `public/` (including `_headers`, `CNAME`), `vite.config.ts`,
  `Dockerfile`, `.dockerignore`, workflows, `.github/{audit-gate.mjs,audit-allowlist.json,dependabot.yml}`,
  `scripts/third-party-licenses.mjs`, `SECURITY.md`, `CLAUDE.md`, `package.json`, `post-bootstrap/landing/`
  (read-only).
- **Out of scope:** `@meddleware/ui`, `@meddleware/design-tokens`, static-server (own audits).
- **Environment (2026-10-09):** `vue-tsc --noEmit` (clean); audit gate (1 allowlisted advisory, 0 open);
  the built `dist/` read (one script, an external module; no source maps; `THIRD_PARTY_LICENSES` 250 KB);
  `npm pack --dry-run` (34 files; the package is `private`); live headers, `/THIRD_PARTY_LICENSES`,
  `/_headers`, an unknown path and the links of `meddleware.co.uk` (HTTP reads 2026-10-10). No unit tests
  (static content; `package.json` has no `test` script). Earlier (2026-10-03): stylelint, eslint
  (+ vuejs-a11y), html-validate and the production build green.

## Findings

### F1 — Link to a retired host

**Severity:** Low   **Disposition:** RESOLVED (0.0.7)
**Where:** `src/components/FeaturesGrid.vue`
**Issue / impact:** the "DAO Console" card pointed at `https://sui-dao.meddleware.co.uk`, which no
longer resolves (DNS removed with the retirement), and promised on-chain voting. A dead first-party
link misleads visitors, and a link to a name we no longer serve is the precondition for anyone who
later controls that name to receive our traffic.
**Remediation / evidence:** the card is now "Treasury" (`https://treasury.meddleware.co.uk`, 200),
matching the dashboard's five tools. Re-checked 2026-10-09: no `sui-dao` link remains in `src/` and the
host does not resolve; the docs site no longer links it either (docs audit F12, 0.0.25). Each card and
header/footer host answers 200 (`dash.`, `treasury.`, `sui-token-deployer.`, `sui-walrus.`, `sui-seal.`,
`sui-access-gate.`, `docs.`, `dev.`).

### F2 — App publishable to npm

**Severity:** Info   **Disposition:** RESOLVED (0.0.7; removed from npm by 2026-10-08)
**Where:** `package.json`
**Issue / impact:** without `private: true`, `npm publish` would ship the app; earlier hand-published
versions had no provenance and no consumers. A stray manual publish is an unreviewed release path.
**Remediation / evidence:** `private: true`; the repository has only the image workflow. The
hand-published versions have been removed from npm (404 on 2026-10-08), so nothing remains to
deprecate. Re-checked 2026-10-09: `private: true` is still set; `npm view @meddleware/landing` answers 404
(2026-10-10); the repository has only the image workflow and CI.

### F3 — Card link bound without a scheme check

**Severity:** Info   **Disposition:** RESOLVED (0.0.7)
**Where:** `src/components/ToolCard.vue`
**Issue / impact:** the `href` prop went straight to `:href`. All values are literals today, but the
component is the place that must sanitise its own input (the `templateUrlRestrictions` rule exempts
component props on that basis).
**Remediation / evidence:** the link renders only when `safeHref(href)` allows it. Re-read 2026-10-09:
`ToolCard.vue` renders the anchor only through `safeHref`; the other links (`App.vue`, `HeroSection.vue`,
`CtaSection.vue`) are literals; all six `target="_blank"` anchors carry `rel="noopener noreferrer"`.

### F4 — Static content, strict CSP

**Severity:** Positive — no `v-html`, no `VITE_*`, no fetches; external links carry
`rel="noopener noreferrer"`; the image serves `script-src 'self'` with no inline scripts. Re-checked
2026-10-09: `grep` over `src/` finds no `v-html`, `innerHTML`, `eval`, `fetch`, `localStorage` or
`import.meta.env`; `dist/index.html` has a single external module script; no source maps are emitted; the
live header adds only static-server's per-response nonce (for Cloudflare's script injection). The weaker
`_headers` file is F5.

### F5 — A vestigial `_headers` file is shipped and served

**Severity:** Low   **Disposition:** DEFERRED (next patch release; delete `public/_headers` and `public/CNAME`)
**Where:** `public/_headers`, `public/CNAME` (copied into `dist/` by Vite and into the image)
**Issue:** `_headers` is a static-host (Cloudflare Pages / Netlify) file: it sets `script-src 'self'
'unsafe-inline'` (the VUE lens forbids `'unsafe-inline'` for scripts), `X-Frame-Options: DENY`, a
`connect-src` list and no `frame-ancestors`, none of which match the image's real policy
(`script-src 'self'` plus a nonce, `X-Frame-Options: SAMEORIGIN`, `frame-ancestors 'self'`). No static host
serves it — the only hosting path is the static-server image — but static-server serves it as an ordinary
file: `https://meddleware.co.uk/_headers` answers 200 `text/plain` (read 2026-10-10), as does `/CNAME`
(a GitHub Pages custom-domain marker).
**Impact:** no browser enforces the file, so no weaker policy is in effect; the risk is a reviewer or an
operator reading it as the site's policy, and the page advertising a configuration it does not use. A
future move to a static host would silently apply the weaker script policy.
**Remediation / evidence:** delete both files; the headers are the image's `CSP` argument and
static-server's fixed set (B.VUE-1). Read: `public/_headers`, `public/CNAME`, the live `/_headers`.

### F6 — Unknown paths answer 200 with the page shell

**Severity:** Info   **Disposition:** DEFERRED (next patch release; a 404 page)
**Where:** `Dockerfile` (`SPA_FALLBACK=true`), `post-bootstrap/landing/base/deployment.yaml`,
`src/main.ts` (one route, no catch-all)
**Issue:** the image serves every unknown path with `index.html` and status 200 (live `/no/such` answers
200 `text/html`); the router has no catch-all, so the visitor sees the header and footer around an empty
main area. The page has one route, so the fallback buys nothing. This is the class of docs audit F11.
**Impact:** mistyped or retired links to `meddleware.co.uk/...` look healthy to crawlers and link
checkers; no security effect.
**Remediation / evidence:** add a `public/404.html`, drop `SPA_FALLBACK`, and set `NOT_FOUND_PAGE=/404.html`
(static-server 0.1.4+, as the docs and dev sites do), or add a not-found route and accept the 200.

### F7 — No build-time check that every inline script is covered by the CSP

**Severity:** Info   **Disposition:** DEFERRED (next patch release; copy `check-csp-inline.mjs`)
**Where:** `Dockerfile`; `scripts/`
**Issue:** B.VUE-1 asks for a build-time check that fails on an inline script the policy does not allow.
The policy is `script-src 'self'` (no hashes) and today's `dist/index.html` has exactly one script, the
external module `/assets/index-….js`. If a plugin or a dependency began emitting an inline script, the
browser would block it and the page would break at runtime, not at build time. The docs and dev images run
`scripts/check-csp-inline.mjs` for this.
**Impact:** a silent breakage rather than a vulnerability (the CSP fails closed).
**Remediation / evidence:** add the script and the `RUN node scripts/check-csp-inline.mjs "${CSP}" dist`
line after the build. Read: `dist/index.html` (2026-10-09) and the Dockerfile.

### F8 — Image release gate, scan, notices and runtime user

**Severity:** Low   **Disposition:** RESOLVED (0.0.9 `96c88db`/`17cadd9`, 0.0.11 `f270057`)
**Where:** `.github/workflows/{node-ci,docker-publish}.yml`, `Dockerfile`, `scripts/third-party-licenses.mjs`, `post-bootstrap/landing/base/deployment.yaml`
**Issue:** the checks ran only inside the release workflow (no push/PR CI until `96c88db`, 0.0.9), the image
release was gated by a subset of them, the published image was not scanned before signing, the lockfile was not in the image (the SBOM saw
only the base), no third-party licence texts were served with the bundled npm code, and the runtime user
was only inherited from the base.
**Impact:** a tag could ship what CI would have refused; an SBOM that misses the bundled dependencies;
redistributed MIT/Apache code without its notices.
**Remediation / evidence:** `node-ci.yml` (push, PR, `workflow_call`) runs the audit gate, `vue-tsc`, the
three linters, the build, the licence check and a Trivy filesystem scan (vulnerabilities, misconfiguration,
secrets); `docker-publish.yml` `verify` calls it and all four build jobs `need` it; the public job runs
Trivy on the pushed digest (CRITICAL/HIGH, fixable only, `exit-code: 1`) before `cosign sign`, then an SPDX
SBOM attestation and build provenance for quay.io and Docker Hub, with no `continue-on-error` on the
public path; the Dockerfile runs `npm run licenses` in the build stage and copies `package-lock.json` to
`/usr/share/doc/landing/`; `/THIRD_PARTY_LICENSES` returns HTTP 200 live (2026-10-10); the runtime base is
static-server 0.1.7 (Go 1.26.9) with an explicit `USER 65534:65534`; the pod sets
`automountServiceAccountToken: false`, `runAsNonRoot` uid 65534, read-only root, all capabilities dropped,
`RuntimeDefault` seccomp, probes and limits; the digest is identical in `config/images.yaml` and the
overlay; all images cosign-verified 2026-10-09 (`verify-digests.sh`, 16/16). Not run: a Trivy *config*
scan of the Dockerfile (the filesystem scan includes misconfiguration checks).

### F9 — The CI workflow has no `npm test` step

**Severity:** Info   **Disposition:** DEFERRED (one line in `node-ci.yml`, when the page gains a test)
**Where:** `.github/workflows/node-ci.yml`; `docker-publish.yml` `verify` calls it
**Issue:** `node-ci.yml` has no `npm test` step, and the comment in `docker-publish.yml` ("type-check, lint,
tests, build, licences") overstates what the release runs.
**Impact:** none today: `package.json` defines no `test` script and the repository has no test files, so
no test is skipped. The first test added would not run in CI or in the release gate (TS lens: every test
project that exists runs in CI).
**Remediation / evidence:** add `- run: npm test --if-present` to `node-ci.yml` and correct the comment.
Verified by reading both workflows and `package.json` 2026-10-09.

### F10 — Contrast of the page's own text is not checked in a browser

**Severity:** Info   **Disposition:** DEFERRED (next patch release; an axe run of the built page)
**Where:** `src/App.vue` (`.header-nav__link` opacity 0.8, `.footer-link` opacity 0.65), `src/components/*.vue`
(`--muted` text, `opacity: 0.85` hover states)
**Issue:** the VUE lens requires WCAG AA contrast in every theme × season, checked in a real browser (axe)
over the real tokens. The `@meddleware/ui` gallery run covers the shared components only; this page's own
dimmed links and muted text have no browser check, and opacity is applied on top of the token colours.
The running-text link in the features subtitle keeps the default underline (`main.css`).
**Impact:** unknown; possible low-contrast dimmed footer and header links in some theme/season. All the
information is also in the heading and card text.
**Remediation / evidence:** load the built page in Playwright with `@axe-core/playwright` for each theme ×
season (as `ui/e2e/contrast.spec.ts` does for the gallery) and replace opacity dimming with tokens if it
fails. Not run for this pass.

### F11 — `connect-src` allows any https origin

**Severity:** Info   **Disposition:** ACCEPTED-RISK
**Where:** `Dockerfile` (`CSP` argument); live header read 2026-10-10
**Issue:** `connect-src 'self' https:` and `img-src 'self' data: blob: https:` are blanket allowances,
copied from the application images; the Dockerfile comment justifies them with operator-configured RPC and
relay hosts, which this page does not have: it makes no request at all (no `fetch`, no storage but the
colour mode).
**Impact:** an injected script could send data to any https host. Script injection is the prerequisite,
and `script-src 'self'` with a nonce, no inline script and no `v-html`/`eval` (F4) is the control on that;
the page holds no secret or session.
**Remediation / evidence:** accepted for now; `connect-src 'self'` and a narrower `img-src` are a
suggestion that needs a browser probe first (not done).

### F12 — The cosign identity pins the repository, not the workflow

**Severity:** Info   **Disposition:** ACCEPTED-RISK
**Where:** `bootstrap/images/verify-digests.sh` (workspace); this repository publishes no verify command
**Issue:** the cluster check accepts any workflow identity of `github.com/meddleware-org/landing`.
**Impact:** a workflow added by someone with write access could sign an image the check would accept.
**Remediation / evidence:** the repository is the signing boundary; anchoring to
`docker-publish.yml@refs/tags/v*` is a `COSIGN_IDENTITY_REGEXP` override in the workspace script. The
deployed digest verified 2026-10-09 (16/16).

### F13 — Self-hosted registry mirror and registry credentials

**Severity:** Info   **Disposition:** DEFERRED (maintainer; `OPERATOR_TASKS.md` "Image registry credentials — record scope and rotation")
**Where:** `docker-publish.yml` private build and merge jobs (`continue-on-error: true`); `QUAY_TOKEN`, `DOCKERHUB_TOKEN`
**Issue:** the mirror jobs fail without registry credentials and never sign; the quay.io and Docker Hub
tokens are long-lived and not yet inventoried.
**Impact:** the mirror may lag; a leaked token could push an unsigned tag (the cluster pins digests and
verifies signatures, so it would not run).
**Remediation / evidence:** the mirror is listed as best-effort; the public jobs have no
`continue-on-error`. The credential inventory (scope, holder, expiry, rotation) is the maintainer item.

## Section A — Invariant verification matrix

| # | Invariant | Enforced at | Proven by | Status |
| --- | --- | --- | --- | --- |
| I1 | Static only: no writes, secrets or user data | source | grep; build | HOLDS (F4) |
| I2 | Links go only to live first-party hosts | `App.vue`, `HeroSection`, `CtaSection`, `FeaturesGrid` | source; probe of each host | HOLDS (F1) |
| I3 | Bound links pass a scheme check | `ToolCard` | source | HOLDS (F3) |
| I4 | The only release path is the signed image | `private: true`; image workflow | `package.json`; workflows | HOLDS (F2) |
| I5 | The release ships only what full CI accepted, scanned and signed | `docker-publish.yml` `verify` → `node-ci.yml`; Trivy before cosign | workflow read 2026-10-09 | HOLDS (F8) |
| I6 | The served policy is the one the audit describes | image `CSP` argument + static-server; `public/_headers` is a second, weaker description | live header read 2026-10-10; the live `/_headers` file | HOLDS for the policy in force — GAP for the stray file, see F5 |
| I7 | The unit tests run on every change and every release | none (`node-ci.yml` has no test step) | none; the page has no tests | GAP (nothing to run today) — see F9 |
| I8 | The page emits no inline script (the CSP allows none) | `script-src 'self'` in the image; Vite emits one external module script | `dist/index.html` read by hand; no build-time check | HOLDS (code-only) — F7 |

### Lens categories

| Lens | Category | Status |
| --- | --- | --- |
| TS | Compiler strictness, assertions, validation, money, network I/O, encoding, dynamic code | HOLDS — `strict: true` (`vue-tsc --noEmit` in CI); `noUncheckedIndexedAccess` not enabled (the page parses no untrusted data); `skipLibCheck: true` hides nothing in `src/`; no `any`, `!`, `eval`, `fetch` or amounts in `src/` |
| TS | Supply chain | HOLDS — `npm ci`, audit gate in CI (1 allowlisted, 0 open), lockfile, Dependabot weekly and grouped |
| TS | Publishing / packaging | HOLDS (F2) — `private: true`; no `files`/`exports` to check |
| TS | Test projects in CI | N/A today — the page has no tests; the CI workflow has no test step (F9) |
| VUE | Untrusted rendering | HOLDS (F3, F4) — no untrusted input; the one dynamic `:href` passes `safeHref`; no `v-html` |
| VUE | Colour & links | not verified in a browser (F10) — the running-text link keeps the default underline; header and footer links are dimmed with `opacity` |
| VUE | Build-time configuration | HOLDS — no `VITE_*`; no `.env` file is read or committed; ids: none (no chain access) |
| VUE | Test hooks | N/A — no test mode, mock or `window.__*` hook exists |
| VUE | Signing UX, shared-wallet state | N/A — no wallet |
| VUE | Browser storage | through `@meddleware/ui` colour mode only (ui audit); no value is trusted for access or money |
| VUE | Lazy boundaries | N/A — no heavy SDK or wasm |
| VUE | Dual app / library | N/A — the app exports no view |
| VUE | Estimates, chain-access layering | N/A — no chain logic |
| IMG | Base images, build context, reproducible build, no secrets, runtime user, scan, SBOM and notices | HOLDS (F8) — digest-pinned `node:24-slim` and static-server 0.1.7; `.dockerignore` excludes `node_modules`, `dist`, `.git`, `.github` and `.env*.local`; `npm ci`; the only `ARG` is the public `CSP`; Trivy before cosign; lockfile in the image; `/THIRD_PARTY_LICENSES` served |
| IMG | Verification command | GAP accepted — the identity pins the repository (F12) |
| IMG | Deployment pinning | HOLDS — digest in `config/images.yaml` and the overlay; the base manifest's tag (`0.1.0`) is overridden by the overlay digest and is cosmetic |

## Section B — Supply-chain, publish-authority & capability matrix

### B.1 Dependency & CVE risk

| Dependency | Pinned version | Liveness dependency? | CVE / audit status | Notes |
| --- | --- | --- | --- | --- |
| `@meddleware/ui` / `design-tokens` | `^0.1.31` / `^0.1.9` (installed 0.1.31 / 0.1.9) | rendering | clean | latest published |
| `vue`, `vue-router` | `^3.5.43`, `^5.3.1` (installed 3.5.43, 5.3.1) | rendering | clean | ADR-0001 matrix: vue matches the workspace baseline |
| `vite`, `@vitejs/plugin-vue`, `vue-tsc`, `typescript` | `^8.3.3`, `^6.0.9`, `~3.3.12`, `^6.0.0` (installed 8.3.3, 6.0.9, 3.3.12, 6.0.3) | build | clean | `typescript` is a caret range (siblings use `~6.0.0`); it does not admit 7, which is deferred (decision); no vitest, no `@mysten/*` |
| `static-server` / `node:24-slim` | 0.1.7 / digest-pinned | runtime / build | Trivy at release (F8); Go 1.26.9 | — |
| dev tooling | lockfile | no | GHSA-vfj7-8cjw-p6xm allowlisted to 2027-01-01 | TS lens B.TS-3 |

Install-time code (TS B.TS-2): the lockfile has one lifecycle script, `fsevents` (dev, optional, macOS
only); no `allowScripts`, no `overrides`, no `prepare`/`postinstall` in `package.json`. Node range
`^22.18.0 || >=24.12.0`; CI and the image use 24.

### B.2 Publish authority, capabilities & secret custody

| Authority / secret | Where held | Custody | Gates | Rotation |
| --- | --- | --- | --- | --- |
| `QUAY_TOKEN`, `DOCKERHUB_TOKEN`, `PRIVATE_REGISTRY_*` | GitHub secrets | long-lived robot accounts (inventory: `OPERATOR_TASKS.md`) | image push | F13 |
| image signing | GitHub Actions | cosign keyless | images | n/a |
| npm `@meddleware/landing` | — | not published (`private`) | none | n/a (F2) |

CI & release integrity: actions pinned by SHA (workflows read 2026-10-09); explicit `permissions:` per
workflow and job (`id-token`/`attestations` only on the signing job); tag-gated image release (`v*`);
image release = full CI via `workflow_call` + Trivy + cosign + SPDX SBOM attestation + provenance, no
`continue-on-error` on the public path (F8; the CI workflow has no test step, F9); `npm ci` everywhere;
audit gate in CI; Dependabot weekly and grouped for npm, Docker and Actions (`.github/dependabot.yml`);
no npm release path; no test-only build mode exists; no job spends real funds.

### B.VUE-1 Hosting headers

Live headers on `meddleware.co.uk`, read 2026-10-10: `Content-Security-Policy` (`default-src 'self'`,
`script-src 'self'` with a per-response nonce, `style-src 'self' 'unsafe-inline'`, `img-src 'self' data:
blob: https:`, `connect-src 'self' https:`, `worker-src 'self' blob:`, `object-src 'none'`, `base-uri
'self'`, `form-action 'self'`, `frame-ancestors 'self'`, `upgrade-insecure-requests`),
`Strict-Transport-Security` (1 year, includeSubDomains), `X-Content-Type-Options: nosniff`,
`Referrer-Policy: strict-origin-when-cross-origin`, `Permissions-Policy`, `X-Frame-Options: SAMEORIGIN`.
The CSP is static-server's (`CONTENT_SECURITY_POLICY` from the `CSP` build argument). There is one
hosting path, but the repository also holds a static-host `public/_headers` (F5) whose policy differs
(`'unsafe-inline'` scripts, `DENY` framing) and which no host applies. `'unsafe-inline'` in the live policy
is for styles only; the page emits no inline script (F7 for the missing build check). The blanket `https:`
in `connect-src` and `img-src` is F11. No wasm, so no `'wasm-unsafe-eval'`. Framing is `'self'` only; the
page is not embedded.

### B.VUE-2 / B.IMG Build inputs and artifacts

Production sourcemaps are not emitted (Vite default; `dist/` has no `.map`); no `VITE_*` and no test mode.
`node:24-slim@sha256:0e0ff40c…` builder and `static-server:0.1.7@sha256:2e227311…` runtime, both
digest-pinned (Dependabot Docker group); `npm ci`; `.dockerignore` excludes local installs, build output,
VCS data and every `.env*.local`; `npm run build && npm run licenses` run in the build stage; the runtime
stage copies `dist` and the lockfile only (the `docs/` tree, including this audit, never reaches it);
`USER 65534:65534`; the only `ARG` is the public `CSP`; the deployment is read-only root, `runAsNonRoot`
uid 65534, no privilege escalation, all capabilities dropped, `RuntimeDefault` seccomp,
`automountServiceAccountToken: false`, readiness and liveness probes on `/`, requests 5m/16Mi and limits
100m/48Mi; digest `sha256:392c4b1b…` in both `config/images.yaml` and the overlay; cosign signature
verified 2026-10-09 (F12). Not run: a Trivy *config* scan of the Dockerfile on its own (F8).

## Section C — Test-coverage & hermetic/live split

### C.1 Coverage grade — N/A (static content)

No unit tests exist (framework: none; `package.json` has no `test` script), and no Playwright suite. The
gates are `vue-tsc`, three linters (stylelint, eslint with vuejs-accessibility, html-validate over the
SFC templates), the build, the licence-notice check and a Trivy filesystem scan (vulnerabilities,
misconfiguration, secrets), all in `node-ci.yml`. The production build runs from a clean checkout in CI.
There is no test mode, so there is no test-hook scan to run.

### C.2 Hermetic vs. live paths

| Path | Hermetic? | Deferred to | Tracking |
| --- | --- | --- | --- |
| Build and lint | yes | — | CI |
| Served page, links, headers, notices | no | deployment | live probe 2026-10-09/10 (headers, `/THIRD_PARTY_LICENSES` 200, tool hosts 200, `sui-dao.` unresolved) |
| Contrast of the page in each theme and season | no | browser run | F10 |

## Section D — Deployment-readiness gates

### pre-localnet

- [x] builds; type-check and three linters green; no secrets in source (2026-10-09)
- [x] no `v-html`; the one dynamic `:href` is allowlisted (F3); no `VITE_*` (so none secret, and the inventory matches the absent `.env.example`)

### pre-testnet

- [x] deployed with digest pinning; CSP and HSTS verified; `SECURITY.md` present
- [x] 0.0.11 deployed by digest; live headers, `/THIRD_PARTY_LICENSES` and links probed (2026-10-10)
- [x] image: digest-pinned bases, non-root, restricted pod, probes and limits, signed with SBOM and provenance, scanned before signing (F8)
- [x] test-mode guards: not applicable (no test mode); signing UX and storage keys: not applicable (no wallet; colour mode only)
- [ ] every test project runs in CI — F9 (nothing to run today; next patch)
- [ ] inline scripts checked at build time — F7 (next patch)
- [ ] only one description of the served headers exists — F5 (next patch)

### pre-mainnet


- [x] no npm release path (`private`; package absent from npm, 2026-10-08 and 2026-10-10)
- [x] CSP and HSTS on the one hosting path (B.VUE-1); no wallet events or irreversible actions to guard (VUE-M4–M6 not applicable)
- [ ] contrast checked in a browser in every theme × season — F10 (next patch)
- [ ] registry credential inventory and rotation (F13) — `OPERATOR_TASKS.md` "Image registry credentials"
- [ ] external review — maintainer item (`OPERATOR_TASKS.md` "Funding, grants and an external audit")

## Cross-project themes

- **Supply chain & release integrity** — lockfile (also shipped in the image); first-party libraries at
  their latest versions; signed digest-pinned image with SBOM and provenance, Trivy before signing,
  SHA-pinned actions, grouped Dependabot, expiring audit allowlist; no npm release path (F2).
- **Wire-format coupling** — none: the page speaks no protocol.
- **On-chain-truth boundary** — none: the page states no on-chain fact, price or id.
- **Deployment readiness** — Section D.
- **Chain-access layering** — none: no chain access, so no ids to trace.
- **Retired features** — every first-party link to a retired host must go when the host does (F1;
  the docs site's links were fixed in docs 0.0.25).

## Normative requirements (MUST / MUST NOT)

- **TS-M1–TS-M9** — hold where applicable (TS-M9: no `@mysten/*` peer; the lens's rule that every test
  project runs in CI is vacuous today, F9).
- **VUE-M1, M2, M3, M7, M9** — hold (no untrusted input; no `VITE_*`; no test mode; no storage of its own;
  no embedded library); **VUE-M4–M6** not applicable (no wallet); **VUE-M8** holds on the one hosting path
  (B.VUE-1), with the stray `_headers` file as F5; the *Colour & links* category is unverified (F10).
- **IMG-M1–IMG-M8** — hold; IMG-M8's verification command pins the repository only (F12).

## Implementation suggestions (SHOULD / MAY)

- MAY derive the tool list from one shared source with the dashboard, so a retired tool disappears
  from both at once.
- SHOULD tighten `connect-src` to `'self'` after a browser probe (F11).
- MAY run a Trivy configuration scan of the Dockerfile on its own in CI.

## Open questions (`OQ#`)

None.

## Risks

- **Stale links** — tool hosts are listed by hand.
- **Registry tokens** — long-lived robot tokens for image pushes (F13).
- **Third-party UI packages** — the page trusts `@meddleware/ui` and `design-tokens` at the versions the
  lockfile pins (own audits), including the colour-mode storage.

## Re-verification log

- 2026-10-03 — first full pass under AUDIT_TEMPLATE.md + TS + VUE + IMG (Phase 7). F1–F3 RESOLVED in
  0.0.7 (with ui 0.1.30, design-tokens 0.1.8); F2's npm deprecation is a maintainer task.
- 2026-10-03 — 0.0.7 deployed; the bundle links `treasury.` and not `sui-dao.`; live sweep clean.
- 2026-10-08 — Lens dates reconciled with the registry (`check-template-dates.mjs`): base 2026-10-08, and SUI_CLIENT/GO 2026-10-08 and TS 2026-10-03 where cited. The changes (AUTH/PLATFORM/MCP/DB registered, the GO token row moved to AUTH, JSR in trusted publishing, layered injection guards) alter no disposition here.
- 2026-10-08 — the hand-published npm versions are gone (registry 404); F2 closed, gate ticked, deprecation task removed from the operator register.
- 2026-10-09 — re-verified against 0.0.11 (releases 0.0.8 to 0.0.11): every finding re-checked against the
  code, the built `dist/`, workflows, manifests and the live site. The page is a Vue app, so the full VUE
  lens now applies (it was cited with N/A rows); template dates cite the registry (TS, VUE, IMG
  2026-10-08); front matter gained the VUE and IMG fields and a current deployment status (0.0.11,
  `sha256:392c4b1b…`). F1–F4 hold with fresh evidence (links probed live; F2 re-confirmed 404 on npm).
  New: F5 (a stale `public/_headers` with `'unsafe-inline'` and a `CNAME` are served as files; DEFERRED),
  F6 (unknown paths answer 200; DEFERRED), F7 (no build-time inline-script check; DEFERRED), F8 (CI
  workflow, release gate, Trivy, lockfile, notices, `USER 65534`; RESOLVED 0.0.9–0.0.11), F9
  (`node-ci.yml` has no `npm test` step — the known gap; the page has no tests, so nothing is skipped
  today; DEFERRED), F10 (contrast not browser-checked; DEFERRED), F11 (blanket `connect-src`;
  ACCEPTED-RISK), F12 (cosign identity; ACCEPTED-RISK), F13 (mirror and credentials; DEFERRED,
  maintainer). Section D ticked with evidence; unticked: the next-patch items and the mainnet/maintainer
  items.
