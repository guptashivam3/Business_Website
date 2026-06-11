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
      @pointerdown="whatsAppActive = true"
      @blur="whatsAppActive = false"
    >
      WhatsApp
    </a>
  </nav>
</template>

<script setup>
import { computed, ref } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()
const phone = import.meta.env.VITE_WHATSAPP_PHONE || ''
const whatsAppActive = ref(false)

const showMobileBar = computed(() => !route.path.startsWith('/admin'))
const activeMobileIndex = computed(() => {
  if (whatsAppActive.value) return 2
  if (route.path.startsWith('/gallery')) return 1
  return 0
})
const whatsAppLink = computed(() => {
  const message = 'Hi! I want to discuss a handmade order.'
  return `https://wa.me/${phone}?text=${encodeURIComponent(message)}`
})
</script>
