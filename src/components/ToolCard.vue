<script setup lang="ts">
/**
 * ToolCard — one feature / tool card in the FeaturesGrid.
 *
 * Renders as a `<UiCard>`-styled article with an emoji icon, title, description,
 * and an optional link. The link is applied to the whole card surface when provided.
 */
defineProps<{
  /** Emoji or single character used as the visual icon. Rendered `aria-hidden`. */
  icon: string
  /** Tool name — rendered as the card heading. */
  title: string
  /** One or two sentences describing the tool. */
  description: string
  /** Optional link URL. When set, the card title becomes an anchor. */
  href?: string
}>()
</script>

<template>
  <article class="tool-card">
    <div class="tool-card__icon" aria-hidden="true">{{ icon }}</div>
    <div class="tool-card__body">
      <h3 class="tool-card__title">
        <a v-if="href" :href="href" class="tool-card__link" target="_blank" rel="noopener noreferrer">
          {{ title }} <span aria-hidden="true">↗</span>
        </a>
        <template v-else>{{ title }}</template>
      </h3>
      <p class="tool-card__description">{{ description }}</p>
    </div>
  </article>
</template>

<style scoped>
.tool-card {
  display: flex;
  gap: var(--space-xs);
  padding: var(--space-sm);
  border-radius: var(--radius);
  border: 1px solid var(--border);
  background: var(--surface);
  transition: border-color var(--transition-base, 150ms ease);
}

.tool-card:has(.tool-card__link:hover) {
  border-color: color-mix(in srgb, var(--accent) 50%, var(--border));
}

.tool-card__icon {
  flex-shrink: 0;
  font-size: var(--font-size-lg);
  line-height: 1;
  padding-top: 0.1em;
}

.tool-card__body {
  min-width: 0;
}

.tool-card__title {
  margin: 0 0 var(--space-3xs);
  font-size: var(--font-size-sm);
  font-weight: 650;
  color: var(--text);
}

.tool-card__link {
  color: inherit;
  text-decoration: none;
}

.tool-card__link:hover {
  color: var(--accent);
}

.tool-card__link:focus-visible {
  outline: 2px solid var(--focus-ring);
  outline-offset: 2px;
  border-radius: 2px;
}

.tool-card__description {
  margin: 0;
  font-size: var(--font-size-sm);
  line-height: var(--leading-relaxed, 1.6);
  color: var(--muted);
}
</style>
