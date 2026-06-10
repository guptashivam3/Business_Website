<template>
  <header class="header">
    <div class="container header-row">
      <RouterLink to="/" class="brand">Handmade Gallery</RouterLink>
      <RouterLink to="/" class="btn secondary">Back to Shop</RouterLink>
    </div>
  </header>

  <main class="container page-section">
    <div class="page-intro">
      <h1>Past designs and custom inspiration</h1>
      <p class="muted">A collection of completed handmade work for ideas and reference only.</p>
    </div>

    <div v-if="loading">Loading gallery...</div>
    <div v-else-if="!galleryItems.length" class="empty-state">
      Gallery items will appear here soon.
    </div>
    <div v-else class="grid gallery-grid">
      <article v-for="item in galleryItems" :key="item.id" class="card gallery-card">
        <img class="product-img" :src="item.image_url" :alt="item.title" />
        <div class="card-body">
          <p v-if="item.category" class="pill">{{ item.category }}</p>
          <h3>{{ item.title }}</h3>
          <p v-if="item.description" class="muted">{{ item.description }}</p>
          <p class="inspiration-note">Inspiration only</p>
        </div>
      </article>
    </div>
  </main>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import { supabase } from '../lib/supabase'

const galleryItems = ref([])
const loading = ref(true)

onMounted(loadGallery)

async function loadGallery() {
  loading.value = true
  const { data, error } = await supabase
    .from('gallery_items')
    .select('*')
    .eq('is_visible', true)
    .order('created_at', { ascending: false })

  if (error) console.error(error)
  galleryItems.value = data || []
  loading.value = false
}
</script>
