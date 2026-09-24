<script setup lang="ts">
// Static CTA strip — no reactive state.
</script>

<template>
  <section class="cta" aria-labelledby="cta-heading">
    <div class="cta__inner">
      <h2 id="cta-heading" class="cta__title">Ready to build on-chain?</h2>
      <p class="cta__body">
        All tools are live on Sui testnet and mainnet. Connect a wallet and get started.
      </p>
      <div class="cta__actions">
        <a href="https://dash.meddleware.co.uk" class="cta__btn cta__btn--primary">
          Open Dashboard
        </a>
        <a href="https://docs.meddleware.co.uk" class="cta__btn cta__btn--secondary"
           target="_blank" rel="noopener noreferrer">
          Read the docs ↗
        </a>
      </div>
    </div>
  </section>
</template>

<style scoped>
.cta {
  padding: var(--space-xl) var(--space-sm);
  background: var(--bg);
  text-align: center;
}

.cta__inner {
  max-width: 36rem;
  margin-inline: auto;
}

.cta__title {
  margin: 0 0 var(--space-xs);
  font-size: var(--font-size-xl);
  font-weight: 700;
  line-height: var(--leading-tight, 1.2);
  color: var(--text);
}

.cta__body {
  margin: 0 0 var(--space-md);
  font-size: var(--font-size-sm);
  color: var(--muted);
  line-height: var(--leading-relaxed, 1.6);
}

.cta__actions {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  justify-content: center;
  gap: var(--space-xs);
}

.cta__btn {
  display: inline-flex;
  align-items: center;
  padding: var(--space-2xs) var(--space-sm);
  border-radius: var(--radius);
  font-size: var(--font-size-sm);
  font-weight: 600;
  text-decoration: none;
  transition: opacity var(--transition-base, 150ms ease), transform var(--transition-base, 150ms ease);
}

.cta__btn:hover {
  opacity: 0.85;
  transform: translateY(-1px);
}

.cta__btn--primary {
  background: var(--accent);
  color: var(--accent-contrast);
}

.cta__btn--secondary {
  background: color-mix(in srgb, var(--text) 10%, transparent);
  color: var(--text);
  border: 1px solid var(--border);
}
</style>
