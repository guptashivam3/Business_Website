<template>
  <section class="social-follow-card" aria-label="Follow Laxmi Creations on social media">
    <div class="social-copy">
      <p class="social-label">{{ label }}</p>
      <h2>{{ title }}</h2>
      <p>{{ text }}</p>
    </div>
    <div class="social-actions">
      <a
        v-if="resolvedInstagramUrl"
        :href="resolvedInstagramUrl"
        target="_blank"
        rel="noopener"
        class="social-btn instagram"
        @click="trackSocial('instagram')"
      >
        Instagram
      </a>
      <a
        v-if="resolvedFacebookUrl"
        :href="resolvedFacebookUrl"
        target="_blank"
        rel="noopener"
        class="social-btn facebook"
        @click="trackSocial('facebook')"
      >
        Facebook
      </a>
    </div>
  </section>
</template>

<script setup>
import { computed } from 'vue'
import { trackEvent } from '../lib/analytics.js'

const props = defineProps({
  label: {
    type: String,
    default: 'Follow us'
  },
  title: {
    type: String,
    default: 'Follow Laxmi Creations'
  },
  text: {
    type: String,
    default: 'New designs, hampers, custom orders, and latest handmade updates.'
  },
  instagramUrl: {
    type: String,
    default: ''
  },
  facebookUrl: {
    type: String,
    default: ''
  },
  source: {
    type: String,
    default: 'social_card'
  }
})

const resolvedInstagramUrl = computed(() => normalizeInstagramUrl(props.instagramUrl || import.meta.env.VITE_INSTAGRAM_URL || ''))
const resolvedFacebookUrl = computed(() => normalizeAbsoluteUrl(props.facebookUrl || import.meta.env.VITE_FACEBOOK_URL || ''))

function normalizeInstagramUrl(value) {
  const input = String(value || '').trim()
  if (!input) return ''
  if (/^https?:\/\//i.test(input)) return input
  return `https://www.instagram.com/${input.replace(/^@/, '')}`
}

function normalizeAbsoluteUrl(value) {
  const input = String(value || '').trim()
  if (!input) return ''
  return /^https?:\/\//i.test(input) ? input : `https://${input}`
}

function trackSocial(platform) {
  trackEvent('social_click', {
    platform,
    source: props.source,
    page_path: window.location.pathname
  })
}
</script>

<style scoped>
.social-follow-card {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 24px;
  padding: 22px;
  border: 1px solid rgba(216, 200, 184, 0.95);
  border-radius: 24px;
  background:
    linear-gradient(135deg, rgba(255, 255, 255, 0.94), rgba(255, 250, 244, 0.82)),
    radial-gradient(circle at 92% 0%, rgba(184, 92, 56, 0.12), transparent 14rem);
  box-shadow: 0 18px 48px rgba(83, 58, 35, 0.08);
}

.social-copy {
  display: grid;
  gap: 6px;
}

.social-label {
  margin: 0;
  color: #79401f;
  font-size: 12px;
  font-weight: 900;
  letter-spacing: 0.1em;
  text-transform: uppercase;
}

.social-copy h2 {
  margin: 0;
  color: #241f1a;
  font-size: clamp(24px, 3vw, 36px);
  line-height: 1.02;
}

.social-copy p:last-child {
  max-width: 560px;
  margin: 0;
  color: #77695f;
  font-size: 16px;
  line-height: 1.6;
}

.social-actions {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.social-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-height: 44px;
  padding: 0 18px;
  border-radius: 999px;
  border: 1px solid #d8c8b8;
  color: #241f1a;
  font-size: 15px;
  font-weight: 900;
  text-decoration: none;
  transition: transform 180ms ease, box-shadow 180ms ease, border-color 180ms ease;
}

.social-btn:hover {
  transform: translateY(-2px);
  border-color: #a85f33;
  box-shadow: 0 14px 30px rgba(83, 58, 35, 0.12);
}

.social-btn.instagram {
  background: #241f1a;
  border-color: #241f1a;
  color: #ffffff;
}

.social-btn.facebook {
  background: #ffffff;
}

@media (max-width: 700px) {
  .social-follow-card {
    display: grid;
    gap: 18px;
    padding: 20px;
    border-radius: 22px;
  }

  .social-actions {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }

  .social-btn {
    width: 100%;
  }
}
  
@media (max-width: 420px) {
  .social-actions {
    grid-template-columns: 1fr;
  }
}
</style>
