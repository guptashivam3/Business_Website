<template>
  <router-view v-slot="{ Component }">
    <transition name="page" mode="out-in">
      <component :is="Component" />
    </transition>
  </router-view>

  <nav v-if="showMobileBar" class="mobile-action-bar" aria-label="Quick actions">
    <RouterLink to="/" class="mobile-action">Shop</RouterLink>
    <RouterLink to="/gallery" class="mobile-action">Gallery</RouterLink>
    <a :href="whatsAppLink" target="_blank" rel="noopener" class="mobile-action primary">WhatsApp</a>
  </nav>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()
const phone = import.meta.env.VITE_WHATSAPP_PHONE || ''

const showMobileBar = computed(() => !route.path.startsWith('/admin'))
const whatsAppLink = computed(() => {
  const message = 'Hi! I want to discuss a handmade order.'
  return `https://wa.me/${phone}?text=${encodeURIComponent(message)}`
})
</script>
