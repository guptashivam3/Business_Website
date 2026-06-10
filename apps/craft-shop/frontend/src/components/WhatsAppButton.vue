<template>
  <a class="btn" :href="link" target="_blank" rel="noopener">
    Order on WhatsApp
  </a>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  product: {
    type: Object,
    required: true
  }
})

const phone = import.meta.env.VITE_WHATSAPP_PHONE || ''

const link = computed(() => {
  const text = `Hello, I want to order: ${props.product.name} - Rs ${props.product.price}`
  return `https://wa.me/${phone}?text=${encodeURIComponent(text)}`
})
</script>
