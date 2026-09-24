<script setup lang="ts">
import { RouterView } from 'vue-router'
import { AppHeader, AppFooter, CopyrightLine, useColorMode } from '@meddleware/ui'

const { mode } = useColorMode('dark')
</script>

<template>
  <a class="skip-link" href="#main-content">Skip to main content</a>

  <AppHeader variant="transparent" :sticky="true">
    <template #brand>
      <a href="/" class="brand-link" aria-label="Meddleware home">
        <span class="brand-mark" aria-hidden="true">◆</span>
        <span>Meddleware</span>
      </a>
    </template>
    <template #actions>
      <nav class="header-nav" aria-label="Site">
        <a href="https://dash.meddleware.co.uk" class="header-nav__link">Dashboard</a>
        <a href="https://docs.meddleware.co.uk" class="header-nav__link" target="_blank" rel="noopener noreferrer">Docs</a>
      </nav>
    </template>
  </AppHeader>

  <main id="main-content">
    <RouterView />
  </main>

  <AppFooter variant="dark">
    <template #start>
      <CopyrightLine symbolVariant="kopimi" organisation-name="Meddleware" rightsStatement="jam" />
    </template>
    <template #end>
      <a href="https://dash.meddleware.co.uk" class="footer-link">Dashboard</a>
      <a href="https://docs.meddleware.co.uk" class="footer-link" target="_blank" rel="noopener noreferrer">Documentation</a>
      <a href="https://dev.meddleware.co.uk" class="footer-link" target="_blank" rel="noopener noreferrer">Developer docs</a>
    </template>
  </AppFooter>
</template>

<style scoped>
.skip-link {
  position: absolute;
  top: -100%;
  left: 0;
  padding: var(--space-2xs) var(--space-xs);
  background: var(--accent);
  color: var(--accent-contrast);
  font-size: var(--font-size-sm);
  z-index: 100;
}

.skip-link:focus {
  top: 0;
}

.brand-link {
  display: flex;
  align-items: center;
  gap: var(--space-2xs);
  color: inherit;
  text-decoration: none;
  font-weight: 650;
  letter-spacing: var(--tracking-wide);
}

.brand-mark {
  color: var(--accent);
}

.header-nav {
  display: flex;
  align-items: center;
  gap: var(--space-sm);
}

.header-nav__link {
  color: inherit;
  text-decoration: none;
  font-size: var(--font-size-sm);
  opacity: 0.8;
  transition: opacity var(--transition-base, 150ms ease);
}

.header-nav__link:hover {
  opacity: 1;
}

.footer-link {
  color: inherit;
  text-decoration: none;
  font-size: var(--font-size-sm);
  opacity: 0.65;
  transition: opacity var(--transition-base, 150ms ease);
}

.footer-link:hover {
  opacity: 1;
}
</style>
