# Security Policy

## Scope

This policy covers the `landing` application (`meddleware.co.uk`): a static Vue landing page with no
wallet connection, no chain access and no forms that submit data.

## Security model (invariants)

These invariants are load-bearing. A report demonstrating that any is violated is in scope:

1. **Static only.** The page performs no network writes, holds no secrets and reads no user data.
2. **No secret in `VITE_*`.** Every build-time value ships in the public bundle.
3. **Outbound links only to first-party or documented hosts.**

## Content-Security-Policy

The container image serves `script-src 'self'` with no inline scripts, `object-src 'none'`,
`base-uri 'self'` and `frame-ancestors 'self'`.

## Supported versions

Only the latest published image receives security fixes.

## Reporting a vulnerability

Please **do not** open a public GitHub issue for security vulnerabilities. Report by emailing
**<security@meddleware.co.uk>** with a description, reproduction/PoC if available, and the image tag
or commit SHA tested. You will receive an acknowledgement within **3 business days** and a resolution
plan within **14 days** for confirmed issues; Critical issues (CVSS ≥ 9.0) are prioritised for
same-day acknowledgement.

## Disclosure

Once a fix is released, a security advisory will be published on the GitHub repository. Reporters may
be credited by name unless they prefer to remain anonymous.
