<template>
  <router-view v-slot="{ Component }">
    <transition name="page" mode="out-in">
      <component :is="Component" />
    </transition>
  </router-view>

  <nav
    v-if="showMobileBar"
    class="mobile-action-bar"
    :style="{ '--active-index': activeMobileIndex }"
    aria-label="Quick actions"
  >
    <span class="mobile-action-indicator"></span>
    <RouterLink to="/" class="mobile-action" :class="{ active: activeMobileIndex === 0 }">Shop</RouterLink>
    <RouterLink to="/gallery" class="mobile-action" :class="{ active: activeMobileIndex === 1 }">Gallery</RouterLink>
    <a
      :href="whatsAppLink"
      target="_blank"
      rel="noopener"
      class="mobile-action"
      :class="{ active: activeMobileIndex === 2 }"
      @click="markWhatsAppActive"
    >
      WhatsApp
    </a>
  </nav>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import { useRoute } from 'vue-router'
import { makeWhatsAppLink, trackEvent } from './lib/analytics.js'

const route = useRoute()
const whatsAppActive = ref(false)
let whatsAppTimer = null

const showMobileBar = computed(() => !route.path.startsWith('/admin'))
const activeMobileIndex = computed(() => {
  if (whatsAppActive.value) return 2
  if (route.path.startsWith('/gallery')) return 1
  return 0
})
const whatsAppLink = computed(() => {
  const message = 'Namaste Laxmi ji,\n\nI saw Laxmi Creations and want to discuss a handmade order.\n\nPlease share available designs, customization options, pricing, and delivery timing.'
  return makeWhatsAppLink(message)
})

function markWhatsAppActive() {
  if (!route.path.startsWith('/admin')) {
    trackEvent('whatsapp_click', { source: 'mobile_action_bar', page_path: route.fullPath })
  }
  whatsAppActive.value = true
  clearTimeout(whatsAppTimer)
  whatsAppTimer = setTimeout(() => {
    whatsAppActive.value = false
  }, 1200)
}

watch(
  () => route.fullPath,
  (path) => {
    whatsAppActive.value = false
    clearTimeout(whatsAppTimer)
    if (!path.startsWith('/admin')) {
      trackEvent('page_view', { page_path: path, source: 'router' })
    }
  },
  {
    immediate: true
  }
)
</script>
