# CLAUDE.md — @meddleware/landing

## What this app is

A Vue 3 + Vite SPA serving as the corporate landing page at `meddleware.co.uk`. It presents
Meddleware's tool suite to first-time visitors and links them to the chain-agnostic dashboard
(`dash.meddleware.co.uk`) and standalone tool subdomains.

The landing page has **no wallet, no blockchain SDK, no accounting logic** — it is a pure
marketing/navigation page. Keep it that way.

## Architecture

```
src/
  App.vue             AppHeader (transparent) + RouterView + AppFooter (dark)
  views/
    HomeView.vue      Composes HeroSection + FeaturesGrid + CtaSection
  components/
    HeroSection.vue   Full-viewport hero with gradient, headline, CTAs
    FeaturesGrid.vue  Responsive grid of ToolCard entries — one per live tool
    ToolCard.vue      Emoji icon + title + description + optional link
    CtaSection.vue    Secondary CTA strip with dashboard and docs links
  styles/
    main.css          Layout resets; imports after design-tokens + ui base.css
  env.d.ts            Vite client types + *.vue shim
```

## Styling rules

All colours and spacing come from `@meddleware/design-tokens` role tokens (`--bg`, `--surface`,
`--text`, `--muted`, `--accent`, `--border`, `--focus-ring`, `--space-*`, `--font-size-*`,
`--tracking-*`). Never hardcode hex/rem values — see `@meddleware/ui` CLAUDE.md for the full
theming contract.

The hero gradient uses `color-mix(in srgb, var(--accent) 12%, transparent)` to produce a
subtle radial wash without referencing any colour-named ramps.

## Adding a new tool card

Add an entry to the `tools` array in `src/components/FeaturesGrid.vue`:

```ts
{
  icon: '⚙',
  title: 'New Tool',
  description: 'One or two sentences.',
  href: 'https://new-tool.meddleware.co.uk',
}
```

## Deployment

Served by `static-server` in k8s namespace `apps`, service name `landing`, port 80.
Ingress: `meddleware.co.uk` → `post-bootstrap/landing/base/ingress.yaml`.
Cloudflare Tunnel: `meddleware.co.uk` → `https://nginx-ingress-controller.nginx-ingress.svc:443`
(No TLS Verify; HTTP Host Header `meddleware.co.uk`).

Legal files (`public/legal/`) must be copied from `repos/ui/public/legal/` before deploying
so the `CopyrightLine` component's symbol links resolve correctly.

## Build

```bash
npm install
npm run type-check  # vue-tsc
npm run build       # type-check + vite build → dist/
npm run dev         # local dev server at http://localhost:5173
```
