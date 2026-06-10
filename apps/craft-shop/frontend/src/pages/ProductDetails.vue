<template>
  <header class="header">
    <div class="container header-row">
      <RouterLink to="/" class="brand">Back to Shop</RouterLink>
    </div>
  </header>

  <main class="container page-section" v-if="product">
    <div class="card">
      <img class="product-img" :src="product.image_url || placeholder" :alt="product.name" />
      <video v-if="product.video_url" class="detail-video" :src="product.video_url" controls></video>
      <div class="card-body">
        <h1>{{ product.name }}</h1>
        <p class="price">Rs {{ Number(product.price).toFixed(2) }}</p>
        <p>{{ product.description }}</p>
        <p v-if="!product.is_available" class="muted">Currently sold out</p>

        <div class="button-row detail-actions">
          <WhatsAppButton :product="product" />
          <button class="btn secondary" type="button">UPI: {{ upiId }}</button>
        </div>
      </div>
    </div>
  </main>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import { useRoute } from 'vue-router'
import { supabase } from '../lib/supabase'
import WhatsAppButton from '../components/WhatsAppButton.vue'

const route = useRoute()
const product = ref(null)
const upiId = import.meta.env.VITE_UPI_ID || 'yourupi@bank'
const placeholder = 'https://placehold.co/600x600?text=Handmade'

onMounted(loadProduct)

async function loadProduct() {
  const { data, error } = await supabase
    .from('products')
    .select('*')
    .eq('slug', route.params.slug)
    .single()

  if (error) console.error(error)
  product.value = data
}
</script>
