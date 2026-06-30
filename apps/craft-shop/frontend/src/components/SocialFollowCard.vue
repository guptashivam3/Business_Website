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
        :aria-label="`Follow on Instagram: ${instagramDisplay}`"
        @click="trackSocial('instagram')"
      >
        <span class="social-icon instagram" aria-hidden="true"></span>
        <span>{{ instagramDisplay }}</span>
      </a>
      <a
        v-if="resolvedFacebookUrl"
        :href="resolvedFacebookUrl"
        target="_blank"
        rel="noopener"
        class="social-btn facebook"
        aria-label="Follow on Facebook"
        @click="trackSocial('facebook')"
      >
        <span class="social-icon facebook" aria-hidden="true"></span>
        <span>Facebook</span>
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
const instagramDisplay = computed(() => {
  const url = resolvedInstagramUrl.value
  if (!url) return 'Instagram'
  const handle = url.replace(/^https?:\/\/(www\.)?instagram\.com\//i, '').replace(/\/$/, '')
  return handle ? `@${handle.replace(/^@/, '')}` : 'Instagram'
})

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
  gap: 16px;
  padding: 14px 16px;
  border: 1px solid rgba(216, 200, 184, 0.95);
  border-radius: 18px;
  background:
    linear-gradient(135deg, rgba(255, 255, 255, 0.82), rgba(255, 250, 244, 0.64)),
    radial-gradient(circle at 100% 0%, rgba(184, 92, 56, 0.08), transparent 10rem);
  box-shadow: 0 12px 28px rgba(83, 58, 35, 0.05);
}

.social-copy {
  display: grid;
  gap: 3px;
}

.social-label {
  margin: 0;
  color: #79401f;
  font-size: 10px;
  font-weight: 900;
  letter-spacing: 0.11em;
  text-transform: uppercase;
}

.social-copy h2 {
  margin: 0;
  color: #241f1a;
  font-size: clamp(17px, 1.7vw, 21px);
  line-height: 1.12;
}

.social-copy p:last-child {
  max-width: 560px;
  margin: 0;
  color: #77695f;
  font-size: 13px;
  line-height: 1.45;
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
  gap: 7px;
  min-height: 44px;
  padding: 0 14px;
  border-radius: 999px;
  border: 1px solid #d8c8b8;
  color: #241f1a;
  font-size: 13px;
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
  background: #ffffff;
  border-color: #d8c8b8;
  color: #241f1a;
}

.social-btn.facebook {
  background: #ffffff;
}

.social-icon {
  display: inline-block;
  width: 18px;
  height: 18px;
  background-color: currentColor;
  -webkit-mask-position: center;
  -webkit-mask-repeat: no-repeat;
  -webkit-mask-size: contain;
  mask-position: center;
  mask-repeat: no-repeat;
  mask-size: contain;
}

.social-icon.instagram {
  -webkit-mask-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 24 24' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M7.8 2h8.4A5.8 5.8 0 0 1 22 7.8v8.4a5.8 5.8 0 0 1-5.8 5.8H7.8A5.8 5.8 0 0 1 2 16.2V7.8A5.8 5.8 0 0 1 7.8 2Zm0 2A3.8 3.8 0 0 0 4 7.8v8.4A3.8 3.8 0 0 0 7.8 20h8.4a3.8 3.8 0 0 0 3.8-3.8V7.8A3.8 3.8 0 0 0 16.2 4H7.8Zm8.8 2.3a1.1 1.1 0 1 1 0 2.2 1.1 1.1 0 0 1 0-2.2ZM12 7.2a4.8 4.8 0 1 1 0 9.6 4.8 4.8 0 0 1 0-9.6Zm0 2a2.8 2.8 0 1 0 0 5.6 2.8 2.8 0 0 0 0-5.6Z'/%3E%3C/svg%3E");
  mask-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 24 24' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M7.8 2h8.4A5.8 5.8 0 0 1 22 7.8v8.4a5.8 5.8 0 0 1-5.8 5.8H7.8A5.8 5.8 0 0 1 2 16.2V7.8A5.8 5.8 0 0 1 7.8 2Zm0 2A3.8 3.8 0 0 0 4 7.8v8.4A3.8 3.8 0 0 0 7.8 20h8.4a3.8 3.8 0 0 0 3.8-3.8V7.8A3.8 3.8 0 0 0 16.2 4H7.8Zm8.8 2.3a1.1 1.1 0 1 1 0 2.2 1.1 1.1 0 0 1 0-2.2ZM12 7.2a4.8 4.8 0 1 1 0 9.6 4.8 4.8 0 0 1 0-9.6Zm0 2a2.8 2.8 0 1 0 0 5.6 2.8 2.8 0 0 0 0-5.6Z'/%3E%3C/svg%3E");
}

.social-icon.facebook {
  -webkit-mask-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 24 24' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M14 8h3V4h-3c-3.3 0-5 2-5 5v2H6v4h3v7h4v-7h3.2l.8-4h-4V9c0-.7.3-1 1-1Z'/%3E%3C/svg%3E");
  mask-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 24 24' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M14 8h3V4h-3c-3.3 0-5 2-5 5v2H6v4h3v7h4v-7h3.2l.8-4h-4V9c0-.7.3-1 1-1Z'/%3E%3C/svg%3E");
}

@media (max-width: 700px) {
  .social-follow-card {
    gap: 12px;
    padding: 13px;
    border-radius: 16px;
  }

  .social-actions {
    flex: 0 0 auto;
  }

  .social-btn {
    min-height: 40px;
    padding: 0 12px;
  }
}
  
@media (max-width: 420px) {
  .social-follow-card {
    align-items: flex-start;
  }

  .social-copy p:last-child {
    display: none;
  }

  .social-actions {
    justify-content: flex-end;
  }
}
</style>
