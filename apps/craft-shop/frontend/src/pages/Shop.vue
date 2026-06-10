<template>
  <header class="header">
    <div class="container header-row">
      <div>
        <p class="location-label">Made to order and ready stock</p>
        <div class="brand">{{ shopName }}</div>
      </div>
      <nav class="nav-links">
        <RouterLink to="/gallery" class="btn secondary">Gallery</RouterLink>
        <RouterLink to="/admin/login" class="btn secondary">Admin</RouterLink>
      </nav>
    </div>
  </header>

  <main>
    <section class="shop-hero">
      <div class="container shop-hero-inner">
        <div class="hero-copy">
          <p class="eyebrow">Small batch handmade pieces</p>
          <h1>Handmade gifts and decor, ready to order on WhatsApp.</h1>
          <p class="muted">Browse by category, open a product for details, and send your order directly to the owner.</p>
          <div class="button-row">
            <a class="btn" href="#products">Browse Products</a>
            <a class="btn secondary" :href="storeWhatsAppLink" target="_blank" rel="noopener">Send WhatsApp</a>
          </div>
        </div>
        <div class="hero-note">
          <strong>Simple ordering</strong>
          <span>No customer login or cart. Confirm availability, custom changes, and payment directly with the owner.</span>
        </div>
      </div>
    </section>

    <section class="store-strip">
      <div class="container store-strip-inner">
        <div>
          <strong>Need a custom piece?</strong>
          <span>Message the owner with your color, size, and occasion.</span>
        </div>
        <div class="button-row">
          <a class="btn secondary" :href="storeWhatsAppLink" target="_blank" rel="noopener">WhatsApp Store</a>
          <RouterLink class="btn secondary" to="/gallery">Past Designs</RouterLink>
        </div>
      </div>
    </section>

    <section id="products" class="container page-section">
      <div class="section-heading">
        <div>
          <p class="eyebrow">Shop</p>
          <h2>Available Products</h2>
          <p class="muted">{{ filteredProducts.length }} items shown{{ selectedCategory !== 'All' ? ` in ${selectedCategory}` : '' }}</p>
        </div>
      </div>

      <div v-if="categories.length" class="category-scroller" aria-label="Product categories">
        <button
          v-for="category in categories"
          :key="category"
          :class="{ active: selectedCategory === category }"
          type="button"
          @click="selectedCategory = category"
        >
          {{ category }}
        </button>
      </div>

      <div v-if="loading" class="empty-state">Loading products...</div>
      <div v-else-if="!products.length" class="empty-state large-empty">
        <h3>No products published yet</h3>
        <p>The shop is ready. Add products from the admin dashboard and they will appear here automatically.</p>
        <RouterLink to="/admin/login" class="btn">Go to Admin</RouterLink>
      </div>
      <div v-else-if="!filteredProducts.length" class="empty-state large-empty">
        <h3>No products in this category</h3>
        <p>Choose another category or check the gallery for design ideas.</p>
        <button class="btn" type="button" @click="selectedCategory = 'All'">Show All</button>
      </div>
      <div v-else class="grid product-grid">
        <ProductCard v-for="product in filteredProducts" :key="product.id" :product="product" />
      </div>
    </section>
  </main>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import { supabase } from '../lib/supabase'
import ProductCard from '../components/ProductCard.vue'

const shopName = import.meta.env.VITE_SHOP_NAME || 'Handmade Craft Shop'
const phone = import.meta.env.VITE_WHATSAPP_PHONE || ''
const products = ref([])
const loading = ref(true)
const selectedCategory = ref('All')

const storeWhatsAppLink = computed(() => {
  const message = `Hello, I want to know more about ${shopName}.`
  return `https://wa.me/${phone}?text=${encodeURIComponent(message)}`
})

const categories = computed(() => {
  const categoryNames = products.value
    .map((product) => product.category)
    .filter(Boolean)
  return ['All', ...new Set(categoryNames)]
})

const filteredProducts = computed(() => {
  if (selectedCategory.value === 'All') return products.value
  return products.value.filter((product) => product.category === selectedCategory.value)
})

onMounted(loadProducts)

async function loadProducts() {
  loading.value = true
  const { data, error } = await supabase
    .from('products')
    .select('*')
    .order('sort_order', { ascending: true })
    .order('created_at', { ascending: false })

  if (error) console.error(error)
  products.value = data || []
  loading.value = false
}
</script>
