<template>
  <a class="btn" :href="link" target="_blank" rel="noopener" @click="trackProductClick">
    Order on WhatsApp
  </a>
</template>

<script setup>
import { computed } from 'vue'
import { makeWhatsAppLink, orderMessage, trackEvent } from '../lib/analytics.js'

const props = defineProps({
  product: {
    type: Object,
    required: true
  }
})

const link = computed(() => {
  return makeWhatsAppLink(orderMessage(props.product))
})

function trackProductClick() {
  trackEvent('whatsapp_click', {
    source: 'whatsapp_button',
    product_id: props.product.id,
    product_name: props.product.name,
    category: props.product.category
  })
}
</script>
