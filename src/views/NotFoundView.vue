<script setup lang="ts">
// Static not-found view — no reactive state. Served with a 404 status by the server (see 404.html).
</script>

<template>
  <section class="not-found" aria-labelledby="not-found-heading">
    <p class="not-found__code" aria-hidden="true">404</p>
    <h1 id="not-found-heading" class="not-found__title">Page not found</h1>
    <p class="not-found__body">There is nothing at this address.</p>
    <a href="/" class="not-found__link">Back to the home page</a>
  </section>
</template>

<style scoped>
.not-found {
  min-height: calc(100dvh - var(--mw-header-height, 56px));
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: var(--space-xs);
  padding: var(--space-xl) var(--space-sm);
  text-align: center;
  background: var(--bg);
}

.not-found__code {
  margin: 0;
  font-size: var(--font-size-sm);
  font-weight: 600;
  letter-spacing: var(--tracking-wide);
  color: var(--accent);
}

.not-found__title {
  margin: 0;
  font-size: var(--font-size-2xl);
  font-weight: 700;
  letter-spacing: var(--tracking-tight);
  color: var(--text);
}

.not-found__body {
  margin: 0;
  font-size: var(--font-size-md);
  color: var(--muted);
}

.not-found__link {
  font-size: var(--font-size-sm);
  font-weight: 600;
}
</style>
