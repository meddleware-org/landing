<script setup lang="ts">
import ToolCard from './ToolCard.vue'

const tools = [
  {
    icon: '🗄',
    title: 'Walrus Storage',
    description:
      'Decentralised, tamper-proof blob storage on Sui. Upload, manage, and extend the lifetime of blobs — no backend required.',
    href: 'https://sui-walrus.meddleware.co.uk',
  },
  {
    icon: '🔒',
    title: 'Sealed Storage',
    description:
      'End-to-end encrypted blobs with Sui-based access control. Only holders of the matching on-chain NFT can decrypt.',
    href: 'https://sui-seal.meddleware.co.uk',
  },
  {
    icon: '🔐',
    title: 'Access Gate',
    description:
      'NFT-based access control for any HTTP service. Gate uploads, APIs, and content behind a soulbound Sui NFT.',
    href: 'https://sui-access-gate.meddleware.co.uk',
  },
  {
    icon: '🪙',
    title: 'Token Deployer',
    description:
      'Deploy your own Sui coin fully client-side in under a minute. Your wallet signs, your keys — no intermediaries.',
    href: 'https://sui-token-deployer.meddleware.co.uk',
  },
  {
    icon: '🏛',
    title: 'DAO Console',
    description:
      'Govern your vault on-chain. Propose, vote, and execute DAO actions through a clean browser interface.',
    href: 'https://sui-dao.meddleware.co.uk',
  },
] as const
</script>

<template>
  <section class="features" aria-labelledby="features-heading">
    <div class="features__inner">
      <header class="features__header">
        <h2 id="features-heading" class="features__title">What's in the dashboard</h2>
        <p class="features__subtitle">
          Five on-chain tools — all accessible via a single wallet connection at
          <a href="https://dash.meddleware.co.uk">dash.meddleware.co.uk</a>,
          or as standalone micro-apps on their own subdomains.
        </p>
      </header>
      <ul class="features__grid" role="list">
        <li v-for="tool in tools" :key="tool.title">
          <ToolCard v-bind="tool" />
        </li>
      </ul>
    </div>
  </section>
</template>

<style scoped>
.features {
  padding: var(--space-xl) var(--space-sm);
  background: var(--surface);
  border-top: 1px solid var(--border);
  border-bottom: 1px solid var(--border);
}

.features__inner {
  max-width: 56rem;
  margin-inline: auto;
}

.features__header {
  text-align: center;
  margin-bottom: var(--space-lg);
}

.features__title {
  margin: 0 0 var(--space-xs);
  font-size: var(--font-size-xl);
  font-weight: 700;
  line-height: var(--leading-tight, 1.2);
  color: var(--text);
}

.features__subtitle {
  margin: 0;
  font-size: var(--font-size-sm);
  color: var(--muted);
  line-height: var(--leading-relaxed, 1.6);
}

.features__grid {
  list-style: none;
  margin: 0;
  padding: 0;
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(18rem, 1fr));
  gap: var(--space-xs);
}
</style>
