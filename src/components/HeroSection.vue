<script setup lang="ts">
// No reactive state — static hero section.
</script>

<template>
  <section class="hero" aria-labelledby="hero-headline">
    <div class="hero__content">
      <p class="hero__eyebrow" aria-hidden="true">◆ On-chain tooling</p>
      <h1 id="hero-headline" class="hero__headline">
        Tooling for the<br />decentralised web
      </h1>
      <p class="hero__subheading">
        Protocol-agnostic infrastructure, developer tools, and on-chain primitives.
        <br class="hero__br" />
        Currently live on Sui.
      </p>
      <div class="hero__actions">
        <a href="https://dash.meddleware.co.uk" class="hero__cta hero__cta--primary">
          Open Dashboard
        </a>
        <a href="https://docs.meddleware.co.uk" class="hero__cta hero__cta--secondary"
           target="_blank" rel="noopener noreferrer">
          Documentation ↗
        </a>
      </div>
    </div>
    <div class="hero__glyph" aria-hidden="true">◆</div>
  </section>
</template>

<style scoped>
.hero {
  position: relative;
  min-height: calc(100dvh - var(--mw-header-height, 56px));
  display: flex;
  align-items: center;
  justify-content: center;
  padding: var(--space-xl) var(--space-sm);
  overflow: hidden;
  background:
    radial-gradient(ellipse 80% 60% at 50% 0%, color-mix(in srgb, var(--accent) 12%, transparent) 0%, transparent 70%),
    var(--bg);
}

.hero__content {
  position: relative;
  z-index: 1;
  max-width: 44rem;
  text-align: center;
}

.hero__eyebrow {
  margin: 0 0 var(--space-xs);
  font-size: var(--font-size-sm);
  font-weight: 600;
  letter-spacing: var(--tracking-wide);
  text-transform: uppercase;
  color: var(--accent);
  opacity: 0.85;
}

.hero__headline {
  margin: 0 0 var(--space-sm);
  font-size: clamp(var(--font-size-2xl), 7vw, var(--font-size-3xl));
  font-weight: 700;
  line-height: var(--leading-tight, 1.2);
  letter-spacing: var(--tracking-tight);
  color: var(--text);
}

.hero__subheading {
  margin: 0 0 var(--space-md);
  font-size: var(--font-size-md);
  line-height: var(--leading-relaxed, 1.6);
  color: var(--muted);
}

.hero__br {
  display: none;
}

@media (min-width: 600px) {
  .hero__br {
    display: inline;
  }
}

.hero__actions {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  justify-content: center;
  gap: var(--space-xs);
}

.hero__cta {
  display: inline-flex;
  align-items: center;
  padding: var(--space-2xs) var(--space-sm);
  border-radius: var(--radius);
  font-size: var(--font-size-sm);
  font-weight: 600;
  text-decoration: none;
  transition: opacity var(--transition-base, 150ms ease), transform var(--transition-base, 150ms ease);
}

.hero__cta:hover {
  opacity: 0.85;
  transform: translateY(-1px);
}

.hero__cta--primary {
  background: var(--accent);
  color: var(--accent-contrast);
}

.hero__cta--secondary {
  background: color-mix(in srgb, var(--text) 10%, transparent);
  color: var(--text);
  border: 1px solid var(--border);
}

/* Large decorative glyph — hidden on small screens to avoid clutter. */
.hero__glyph {
  position: absolute;
  right: -0.15em;
  bottom: -0.2em;
  font-size: 40vw;
  font-weight: 700;
  color: var(--accent);
  opacity: 0.03;
  pointer-events: none;
  user-select: none;
  line-height: 1;
}

@media (max-width: 480px) {
  .hero__glyph {
    display: none;
  }
}
</style>
