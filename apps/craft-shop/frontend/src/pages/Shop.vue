<template>
  <div class="shop-page">
    <nav class="shop-nav">
      <div class="container nav-inner">
        <RouterLink to="/" class="nav-brand">
          <span class="nav-brand-name">{{ shopName }}</span>
          <span class="nav-brand-sub">Handmade with love</span>
        </RouterLink>
        <div class="nav-links">
          <RouterLink to="/about" class="shop-btn ghost small">About Us</RouterLink>
          <RouterLink to="/gallery" class="shop-btn ghost small">Gallery</RouterLink>
          <RouterLink to="/admin/login" class="admin-icon-link" aria-label="Admin login" title="Admin login">
            <span aria-hidden="true">A</span>
          </RouterLink>
        </div>
      </div>
    </nav>

    <section class="hero" v-reveal>
      <div class="container hero-inner">
        <div class="hero-text">
          <p class="section-label">Handcrafted in India</p>
          <h1 class="hero-title">Beautiful things,<br /><em>made by hand</em></h1>
          <p class="hero-sub">
            Each piece is crafted with care. Browse the collection and order directly on WhatsApp.
          </p>
          <div v-if="!loading" class="hero-stats">
            <div>
              <strong>{{ products.length }}+</strong>
              <span>Ready designs</span>
            </div>
            <div>
              <strong>{{ featuredProducts.length }}</strong>
              <span>Featured picks</span>
            </div>
            <div>
              <strong>{{ categoryOptions.length - 1 }}</strong>
              <span>Craft categories</span>
            </div>
          </div>
          <div class="hero-actions">
            <a :href="whatsAppLink('Hi! I would like to place an order.')" target="_blank" rel="noopener" class="shop-btn whatsapp large">
              Chat to Order
            </a>
            <RouterLink to="/gallery" class="shop-btn outline large">View Gallery</RouterLink>
          </div>
        </div>
      </div>
    </section>

    <section class="promise-section container" v-reveal="{ delay: 80 }">
      <div class="promise-card primary">
        <p class="section-label">Made personally</p>
        <h2>Thoughtful gifts without the back-and-forth confusion.</h2>
        <p>
          Browse ready designs, send a reference, and confirm details directly with the maker.
          Each order can be adapted by color, budget, occasion, and packing style.
        </p>
      </div>

      <div class="process-slider">
        <Transition name="process-slide" mode="out-in">
          <div :key="activeProcessIndex" class="process-panel">
            <span>{{ processSteps[activeProcessIndex].number }}</span>
            <h3>{{ processSteps[activeProcessIndex].title }}</h3>
            <p>{{ processSteps[activeProcessIndex].description }}</p>
          </div>
        </Transition>
        <div class="process-dots" aria-label="Ordering steps">
          <button
            v-for="(step, index) in processSteps"
            :key="step.number"
            type="button"
            :class="{ active: activeProcessIndex === index }"
            :aria-label="`Show step ${step.number}`"
            @click="activeProcessIndex = index"
          ></button>
        </div>
      </div>
    </section>

    <section v-if="featuredProducts.length" class="featured-section container" v-reveal="{ delay: 120 }">
      <div class="shop-header">
        <div>
          <p class="section-label">Customer favourites</p>
          <h2 class="section-title">Featured Handmade Picks</h2>
        </div>
        <RouterLink to="/gallery" class="shop-btn outline small">See Inspiration</RouterLink>
      </div>

      <div class="featured-slider">
        <button class="featured-arrow left" type="button" aria-label="Previous featured products" @click="previousFeaturedSlide">
          Prev
        </button>
        <Transition name="featured-slide" mode="out-in">
          <div :key="activeFeaturedIndex" class="featured-row">
            <RouterLink
              v-for="product in visibleFeaturedProducts"
              :key="product.id"
              :to="`/product/${product.slug}`"
              class="featured-card"
            >
              <div class="featured-img-wrap">
                <img v-if="product.image_url" :src="product.image_url" :alt="product.name" loading="eager" />
                <span v-else>Image</span>
              </div>
              <div>
                <span>{{ categoryName(product) }}</span>
                <h3>{{ product.name }}</h3>
                <p>Rs {{ Number(product.price).toFixed(2) }}</p>
              </div>
            </RouterLink>
          </div>
        </Transition>
        <button class="featured-arrow right" type="button" aria-label="Next featured products" @click="nextFeaturedSlide">
          Next
        </button>
        <div v-if="featuredPageCount > 1" class="featured-dots" aria-label="Featured product slides">
          <button
            v-for="index in featuredPageCount"
            :key="index"
            type="button"
            :class="{ active: activeFeaturedIndex === index - 1 }"
            :aria-label="`Show featured slide ${index}`"
            @click="activeFeaturedIndex = index - 1"
          ></button>
        </div>
      </div>
    </section>

    <section class="shop-section container" v-reveal="{ delay: 140 }">
      <div class="shop-header">
        <div>
          <p class="section-label">Our Collection</p>
          <h2 class="section-title">Shop All Products</h2>
        </div>
        <div v-if="!loading" class="result-count">
          {{ filteredProducts.length }} item{{ filteredProducts.length !== 1 ? 's' : '' }}
        </div>
      </div>

      <div class="shop-tools">
        <label class="search-box">
          <span>Search collection</span>
          <input v-model.trim="searchQuery" type="search" placeholder="Search hampers, garlands, potlis..." />
        </label>
      </div>

      <div class="cat-wrap">
        <button
          v-for="category in categoryOptions"
          :key="category.name"
          class="cat-chip"
          :class="{ active: activeCategory === category.name }"
          type="button"
          @click="activeCategory = category.name"
        >
          <span>{{ category.name }}</span>
          <small>{{ category.count }}</small>
        </button>
      </div>

      <div v-if="loading" class="skeleton-grid" aria-label="Loading products">
        <div v-for="index in 6" :key="index" class="product-skeleton">
          <div class="skeleton-media"></div>
          <div class="skeleton-line short"></div>
          <div class="skeleton-line"></div>
          <div class="skeleton-line tiny"></div>
        </div>
      </div>

      <div v-else-if="filteredProducts.length === 0" class="shop-empty-state">
        <div class="empty-state-icon">Art</div>
        <h3>No products yet</h3>
        <p>Products will appear here once they are added from the admin dashboard.</p>
        <RouterLink to="/admin/login" class="shop-btn outline">Add Products</RouterLink>
      </div>

      <div v-else class="product-grid">
        <RouterLink v-for="product in filteredProducts" :key="product.id" :to="`/product/${product.slug}`" class="product-card" v-reveal>
          <div class="product-card-img-wrap">
            <img v-if="product.image_url" :src="product.image_url" :alt="product.name" class="product-card-img" loading="lazy" />
            <div v-else class="product-card-placeholder">Image</div>
            <div class="product-card-badges">
              <span v-if="!product.is_available" class="badge sold">Sold Out</span>
              <span v-else-if="product.is_featured" class="badge featured">Featured</span>
            </div>
          </div>
          <div class="product-card-body">
            <p class="product-card-cat">{{ categoryName(product) }}</p>
            <h3 class="product-card-name">{{ product.name }}</h3>
            <p v-if="product.description" class="product-card-desc">{{ product.description }}</p>
            <div class="product-card-footer">
              <span class="product-card-price">Rs {{ Number(product.price).toFixed(2) }}</span>
              <span class="product-card-cta">View Details</span>
            </div>
          </div>
        </RouterLink>
      </div>
    </section>

    <section class="cta-strip" v-reveal>
      <div class="container cta-strip-inner">
        <div>
          <h3>Have a custom order idea?</h3>
          <p>Send a message with your color, size, and occasion. The owner will confirm details personally.</p>
        </div>
        <div class="cta-btns">
          <a :href="whatsAppLink('Hi! I want to place an order.')" target="_blank" rel="noopener" class="shop-btn whatsapp">
            Place Order
          </a>
          <a :href="whatsAppLink('Hi! I have a question.')" target="_blank" rel="noopener" class="shop-btn dark-outline">
            Enquiry
          </a>
        </div>
      </div>
    </section>

    <footer class="footer">
      <div class="container footer-inner">
        <div class="footer-brand">
          <span class="footer-name">{{ shopName }}</span>
          <span class="footer-tagline">Handmade with love, delivered with care.</span>
        </div>
        <div class="footer-links">
          <RouterLink to="/about">About Us</RouterLink>
          <RouterLink to="/gallery">Gallery</RouterLink>
          <a :href="whatsAppLink('Hi!')" target="_blank" rel="noopener">WhatsApp</a>
        </div>
      </div>
      <p class="footer-copy">Copyright {{ currentYear }} {{ shopName }}. All rights reserved.</p>
    </footer>

    <a :href="whatsAppLink('Hi! I want to discuss a handmade order.')" target="_blank" rel="noopener" class="floating-wa">
      <span>WhatsApp</span>
      <strong>Custom Order</strong>
    </a>
  </div>
</template>

<script setup>
import { computed, onMounted, onUnmounted, ref } from 'vue'
import { supabase } from '../lib/supabase.js'

const shopName = import.meta.env.VITE_SHOP_NAME || 'Handmade Craft Shop'
const phone = import.meta.env.VITE_WHATSAPP_PHONE || ''
const products = ref([])
const activeCategory = ref('All')
const searchQuery = ref('')
const loading = ref(true)
const currentYear = new Date().getFullYear()
const activeFeaturedIndex = ref(0)
const activeProcessIndex = ref(0)
let featuredTimer = null
let processTimer = null
const isMobile = ref(false)

const featuredPageSize = computed(() => (isMobile.value ? 1 : 4))

const processSteps = [
  {
    number: '01',
    title: 'Choose a design',
    description: 'Pick from ready products or select an inspiration photo from the gallery.'
  },
  {
    number: '02',
    title: 'Confirm on WhatsApp',
    description: 'Discuss budget, colors, packing, availability, timing, and delivery details.'
  },
  {
    number: '03',
    title: 'Receive handmade work',
    description: 'Your piece is prepared with care for gifting, rituals, and family celebrations.'
  }
]

function categoryName(product) {
  return product.category || 'Gifts'
}

const categoryOptions = computed(() => {
  const counts = products.value.reduce((acc, product) => {
    const name = categoryName(product)
    acc[name] = (acc[name] || 0) + 1
    return acc
  }, {})

  return [
    { name: 'All', count: products.value.length },
    ...Object.entries(counts).map(([name, count]) => ({ name, count }))
  ]
})

const filteredProducts = computed(() => {
  const query = searchQuery.value.toLowerCase()

  return products.value.filter((product) => {
    const category = categoryName(product)
    const matchesCategory = activeCategory.value === 'All' || category === activeCategory.value
    const searchable = `${product.name} ${category} ${product.description || ''}`.toLowerCase()
    return matchesCategory && (!query || searchable.includes(query))
  })
})

const featuredProducts = computed(() => {
  return products.value.filter((product) => product.is_featured && product.is_available)
})

const featuredPageCount = computed(() => {
  return Math.max(1, Math.ceil(featuredProducts.value.length / featuredPageSize.value))
})

const visibleFeaturedProducts = computed(() => {
  const start = activeFeaturedIndex.value * featuredPageSize.value
  return featuredProducts.value.slice(start, start + featuredPageSize.value)
})

function syncViewport() {
  isMobile.value = window.matchMedia('(max-width: 700px)').matches
  if (activeFeaturedIndex.value >= featuredPageCount.value) {
    activeFeaturedIndex.value = 0
  }
}

function nextFeaturedSlide() {
  activeFeaturedIndex.value = (activeFeaturedIndex.value + 1) % featuredPageCount.value
}

function previousFeaturedSlide() {
  activeFeaturedIndex.value = (activeFeaturedIndex.value - 1 + featuredPageCount.value) % featuredPageCount.value
}

function whatsAppLink(message) {
  return `https://wa.me/${phone}?text=${encodeURIComponent(message)}`
}

onMounted(() => {
  syncViewport()
  window.addEventListener('resize', syncViewport)
  loadProducts()
  featuredTimer = setInterval(() => {
    if (featuredPageCount.value > 1) {
      nextFeaturedSlide()
    }
  }, 4600)
  processTimer = setInterval(() => {
    activeProcessIndex.value = (activeProcessIndex.value + 1) % processSteps.length
  }, 3600)
})

onUnmounted(() => {
  clearInterval(featuredTimer)
  clearInterval(processTimer)
  window.removeEventListener('resize', syncViewport)
})

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

<style scoped>
.shop-page {
  min-height: 100vh;
  background:
    radial-gradient(circle at 12% 8%, rgba(184, 92, 56, 0.12), transparent 28rem),
    linear-gradient(180deg, #fffaf4 0%, #f8efe5 50%, #fffaf4 100%);
}

.shop-nav {
  position: sticky;
  top: 0;
  z-index: 20;
  border-bottom: 1px solid #eadfd2;
  background: rgba(255, 250, 244, 0.96);
  backdrop-filter: blur(14px);
}

.nav-inner {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 16px;
  padding: 16px 0;
}

.nav-brand {
  display: grid;
  gap: 2px;
}

.nav-brand-name {
  color: #241f1a;
  font-size: 21px;
  font-weight: 900;
}

.nav-brand-sub {
  color: #77695f;
  font-size: 13px;
  font-weight: 700;
}

.nav-links,
.hero-actions,
.cta-btns {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
  align-items: center;
}

.shop-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-height: 44px;
  border: 1px solid transparent;
  border-radius: 999px;
  padding: 11px 18px;
  color: #ffffff;
  background: #a85f33;
  font-weight: 850;
  transition: transform 160ms ease, box-shadow 160ms ease, background 160ms ease;
}

.shop-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 12px 28px rgba(65, 42, 24, 0.14);
}

.shop-btn.small {
  min-height: 38px;
  padding: 8px 14px;
}

.shop-btn.large {
  min-height: 48px;
  padding: 13px 20px;
}

.shop-btn.ghost {
  background: #f2e5d7;
  color: #261f1a;
}

.shop-btn.outline {
  border-color: #d8c8b8;
  background: #ffffff;
  color: #261f1a;
}

.shop-btn.whatsapp {
  background: #1f9d57;
}

.shop-btn.dark-outline {
  border-color: rgba(255, 255, 255, 0.28);
  background: transparent;
  color: #ffffff;
}

.admin-icon-link {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  flex: 0 0 auto;
  width: 38px;
  height: 38px;
  border: 1px solid #d8c8b8;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.76);
  color: #77695f;
  font-size: 13px;
  font-weight: 900;
  line-height: 1;
  transition: transform 160ms ease, box-shadow 160ms ease, border-color 160ms ease;
}

.admin-icon-link:hover {
  border-color: #a85f33;
  color: #a85f33;
  box-shadow: 0 10px 24px rgba(65, 42, 24, 0.12);
  transform: translateY(-1px);
}

.hero {
  position: relative;
  overflow: hidden;
  padding: 72px 0 60px;
  border-bottom: 1px solid #eadfd2;
  background:
    linear-gradient(90deg, rgba(255, 250, 244, 0.98), rgba(255, 250, 244, 0.78)),
    radial-gradient(circle at 82% 18%, rgba(242, 215, 194, 0.95) 0, transparent 34%),
    radial-gradient(circle at 74% 85%, rgba(201, 168, 76, 0.22) 0, transparent 30%),
    #fff3e4;
}

.hero-inner {
  display: grid;
  grid-template-columns: minmax(0, 760px);
  gap: 48px;
  align-items: center;
}

.hero-text,
.promise-card,
.featured-card,
.product-card {
  animation: riseIn 560ms ease both;
}

@keyframes riseIn {
  from {
    opacity: 0;
    transform: translateY(18px);
  }

  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.section-label {
  margin: 0 0 10px;
  color: #79401f;
  font-size: 13px;
  font-weight: 900;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.hero-title {
  margin: 0 0 16px;
  color: #241f1a;
  font-size: clamp(42px, 7vw, 76px);
  line-height: 1;
  letter-spacing: 0;
}

.hero-title em {
  color: #a85f33;
  font-style: italic;
}

.hero-sub {
  max-width: 560px;
  margin-bottom: 24px;
  color: #77695f;
  font-size: 18px;
  line-height: 1.7;
}

.hero-stats {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
  margin-bottom: 24px;
}

.hero-stats div {
  min-width: 120px;
  padding: 12px 14px;
  border: 1px solid rgba(234, 223, 210, 0.9);
  border-radius: 16px;
  background: rgba(255, 255, 255, 0.72);
  box-shadow: 0 12px 30px rgba(65, 42, 24, 0.06);
}

.hero-stats strong {
  display: block;
  color: #79401f;
  font-size: 22px;
  line-height: 1;
}

.hero-stats span {
  color: #77695f;
  font-size: 12px;
  font-weight: 800;
}

.featured-slide-enter-active,
.featured-slide-leave-active,
.process-slide-enter-active,
.process-slide-leave-active {
  transition: opacity 360ms ease, transform 360ms ease;
}

.featured-slide-enter-from,
.process-slide-enter-from {
  opacity: 0;
  transform: translateX(24px);
}

.featured-slide-leave-to,
.process-slide-leave-to {
  opacity: 0;
  transform: translateX(-24px);
}

.featured-dots,
.process-dots {
  display: flex;
  justify-content: center;
  gap: 8px;
}

.featured-dots button,
.process-dots button {
  width: 8px;
  height: 8px;
  border: 0;
  border-radius: 999px;
  background: #d8c8b8;
  cursor: pointer;
  transition: width 180ms ease, background 180ms ease;
}

.featured-dots button.active,
.process-dots button.active {
  width: 24px;
  background: #a85f33;
}

.promise-section {
  display: grid;
  grid-template-columns: minmax(0, 1fr) minmax(300px, 0.74fr);
  gap: 16px;
  padding: 42px 0 6px;
}

.promise-card {
  min-height: 240px;
  border: 1px solid #eadfd2;
  border-radius: 22px;
  padding: 26px;
  background: rgba(255, 255, 255, 0.82);
  box-shadow: 0 14px 34px rgba(65, 42, 24, 0.07);
}

.promise-card.primary {
  background:
    linear-gradient(135deg, rgba(255, 253, 248, 0.98), rgba(255, 243, 228, 0.92)),
    #ffffff;
}

.process-slider {
  position: relative;
  display: grid;
  align-items: stretch;
  min-height: 240px;
  overflow: hidden;
  border: 1px solid #eadfd2;
  border-radius: 22px;
  background:
    radial-gradient(circle at 90% 10%, rgba(201, 168, 76, 0.18), transparent 10rem),
    #ffffff;
  box-shadow: 0 14px 34px rgba(65, 42, 24, 0.07);
}

.process-panel {
  display: flex;
  flex-direction: column;
  justify-content: center;
  min-height: 240px;
  padding: 28px;
}

.process-panel span {
  display: grid;
  place-items: center;
  width: 36px;
  height: 36px;
  margin-bottom: 14px;
  border-radius: 999px;
  background: #fff3e4;
  color: #79401f;
  font-size: 12px;
  font-weight: 900;
}

.promise-card h2 {
  margin: 0 0 10px;
  color: #241f1a;
  font-size: clamp(24px, 3vw, 34px);
  line-height: 1.14;
}

.process-panel h3 {
  margin: 0 0 8px;
  color: #241f1a;
  font-size: clamp(26px, 4vw, 38px);
  line-height: 1.1;
}

.promise-card p,
.process-panel p {
  margin: 0;
  color: #6f6258;
  font-size: 15px;
  line-height: 1.65;
}

.process-dots {
  position: absolute;
  right: 0;
  bottom: 18px;
  left: 0;
}

.featured-section {
  padding: 46px 0 8px;
}

.featured-slider {
  position: relative;
  padding: 0 44px 34px;
}

.featured-row {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 16px;
}

.featured-dots {
  margin-top: 18px;
}

.featured-arrow {
  position: absolute;
  top: 38%;
  z-index: 2;
  display: grid;
  place-items: center;
  width: 38px;
  height: 38px;
  overflow: hidden;
  border: 1px solid #d8c8b8;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.9);
  color: transparent;
  cursor: pointer;
  font-size: 0;
  box-shadow: 0 12px 26px rgba(65, 42, 24, 0.1);
}

.featured-arrow::before {
  content: "";
  width: 10px;
  height: 10px;
  border-top: 2px solid #79401f;
  border-left: 2px solid #79401f;
}

.featured-arrow.left {
  left: 0;
}

.featured-arrow.left::before {
  transform: rotate(-45deg) translate(1px, 1px);
}

.featured-arrow.right {
  right: 0;
}

.featured-arrow.right::before {
  transform: rotate(135deg) translate(1px, 1px);
}

.featured-card {
  display: grid;
  overflow: hidden;
  border: 1px solid #eadfd2;
  border-radius: 20px;
  background: rgba(255, 255, 255, 0.84);
  box-shadow: 0 16px 40px rgba(65, 42, 24, 0.08);
  transition: transform 180ms ease, box-shadow 180ms ease;
}

.featured-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 22px 54px rgba(65, 42, 24, 0.13);
}

.featured-img-wrap {
  position: relative;
  overflow: hidden;
  background: #f2e5d7;
}

.featured-img-wrap img {
  width: 100%;
  height: 100%;
  aspect-ratio: 1 / 1;
  object-fit: cover;
}

.featured-img-wrap span {
  position: absolute;
  inset: 0;
  display: grid;
  place-items: center;
  color: #79401f;
  font-weight: 900;
}

.featured-card div {
  padding: 14px;
}

.featured-card span {
  color: #79401f;
  font-size: 11px;
  font-weight: 900;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.featured-card h3 {
  margin: 5px 0 8px;
  color: #261f1a;
  font-size: 16px;
  line-height: 1.25;
}

.featured-card p {
  margin: 0;
  color: #a85f33;
  font-weight: 900;
}

.shop-section {
  padding: 46px 0 64px;
}

.shop-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  gap: 20px;
  margin-bottom: 18px;
}

.section-title {
  margin: 0;
  color: #261f1a;
  font-size: clamp(28px, 4vw, 42px);
}

.result-count {
  color: #77695f;
  font-weight: 800;
}

.shop-tools {
  margin-bottom: 14px;
}

.search-box {
  display: grid;
  gap: 6px;
  max-width: 560px;
}

.search-box span {
  color: #79401f;
  font-size: 12px;
  font-weight: 900;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.search-box input {
  width: 100%;
  min-height: 48px;
  border: 1px solid #eadfd2;
  border-radius: 999px;
  padding: 0 18px;
  background: rgba(255, 255, 255, 0.92);
  color: #261f1a;
  box-shadow: 0 12px 30px rgba(65, 42, 24, 0.06);
}

.search-box input:focus {
  border-color: #a85f33;
  outline: none;
  box-shadow: 0 0 0 3px rgba(168, 95, 51, 0.12);
}

.cat-wrap {
  display: flex;
  gap: 10px;
  overflow-x: auto;
  padding: 4px 0 22px;
}

.cat-chip {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  flex: 0 0 auto;
  border: 1px solid #eadfd2;
  border-radius: 999px;
  padding: 10px 16px;
  background: #ffffff;
  color: #261f1a;
  cursor: pointer;
  font-weight: 850;
}

.cat-chip small {
  display: grid;
  place-items: center;
  min-width: 24px;
  height: 24px;
  border-radius: 999px;
  background: #f2e5d7;
  color: #79401f;
  font-size: 12px;
  font-weight: 900;
}

.cat-chip.active {
  border-color: #a85f33;
  background: #a85f33;
  color: #ffffff;
}

.cat-chip.active small {
  background: rgba(255, 255, 255, 0.22);
  color: #ffffff;
}

.loading-wrap,
.shop-empty-state {
  display: grid;
  place-items: center;
  gap: 12px;
  min-height: 240px;
  padding: 34px;
  border: 1px dashed #eadfd2;
  border-radius: 20px;
  background: #fffdf8;
  color: #77695f;
  text-align: center;
}

.skeleton-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(230px, 1fr));
  gap: 20px;
}

.product-skeleton {
  overflow: hidden;
  border: 1px solid #eadfd2;
  border-radius: 18px;
  padding: 14px;
  background: rgba(255, 255, 255, 0.8);
  box-shadow: 0 14px 34px rgba(65, 42, 24, 0.06);
}

.skeleton-media,
.skeleton-line {
  position: relative;
  overflow: hidden;
  border-radius: 12px;
  background: #f2e5d7;
}

.skeleton-media {
  aspect-ratio: 1 / 1;
  margin-bottom: 14px;
}

.skeleton-line {
  height: 13px;
  margin-bottom: 10px;
}

.skeleton-line.short {
  width: 44%;
}

.skeleton-line.tiny {
  width: 32%;
}

.skeleton-media::after,
.skeleton-line::after {
  content: "";
  position: absolute;
  inset: 0;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.64), transparent);
  animation: shimmer 1.2s infinite;
  transform: translateX(-100%);
}

@keyframes shimmer {
  to {
    transform: translateX(100%);
  }
}

.spinner {
  width: 28px;
  height: 28px;
  border: 3px solid #eadfd2;
  border-top-color: #a85f33;
  border-radius: 999px;
  animation: spin 850ms linear infinite;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

.empty-state-icon {
  display: grid;
  place-items: center;
  width: 58px;
  height: 58px;
  border-radius: 999px;
  background: #f2e5d7;
  color: #79401f;
  font-weight: 900;
}

.product-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(230px, 1fr));
  gap: 20px;
}

.product-card {
  display: flex;
  flex-direction: column;
  overflow: hidden;
  border: 1px solid #eadfd2;
  border-radius: 18px;
  background: #ffffff;
  box-shadow: 0 16px 42px rgba(65, 42, 24, 0.08);
  transition: transform 180ms ease, box-shadow 180ms ease;
}

.product-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 22px 56px rgba(65, 42, 24, 0.12);
}

.product-card-img-wrap {
  position: relative;
  overflow: hidden;
  aspect-ratio: 1 / 1;
  background: #f2e5d7;
}

.product-card-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 240ms ease;
}

.product-card:hover .product-card-img {
  transform: scale(1.05);
}

.product-card-placeholder {
  position: absolute;
  inset: 0;
  display: grid;
  place-items: center;
  color: #a85f33;
  font-weight: 900;
}

.product-card-badges {
  position: absolute;
  top: 10px;
  left: 10px;
  display: grid;
  gap: 6px;
}

.badge {
  border-radius: 999px;
  padding: 6px 10px;
  color: #ffffff;
  font-size: 12px;
  font-weight: 900;
}

.badge.sold {
  background: #a33b2f;
}

.badge.featured {
  background: #79401f;
}

.product-card-body {
  display: flex;
  flex: 1;
  flex-direction: column;
  padding: 16px;
}

.product-card-cat {
  margin: 0 0 6px;
  color: #77695f;
  font-size: 12px;
  font-weight: 900;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.product-card-name {
  margin: 0 0 8px;
  color: #261f1a;
  font-size: 18px;
  line-height: 1.25;
}

.product-card-desc {
  display: -webkit-box;
  flex: 1;
  overflow: hidden;
  margin: 0 0 12px;
  color: #77695f;
  font-size: 14px;
  line-height: 1.55;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
}

.product-card-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
  margin-top: auto;
  padding-top: 12px;
  border-top: 1px solid #eadfd2;
}

.product-card-price {
  color: #79401f;
  font-size: 18px;
  font-weight: 900;
}

.product-card-cta {
  color: #77695f;
  font-size: 13px;
  font-weight: 900;
}

.cta-strip {
  padding: 42px 0;
  background: #261f1a;
}

.cta-strip-inner {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 24px;
  flex-wrap: wrap;
}

.cta-strip h3 {
  margin-bottom: 6px;
  color: #ffffff;
  font-size: 26px;
}

.cta-strip p {
  margin: 0;
  color: #b5aaa1;
}

.footer {
  padding: 32px 0 18px;
  background: #1a1714;
}

.footer-inner {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 18px;
  flex-wrap: wrap;
  padding-bottom: 18px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.08);
}

.footer-brand {
  display: grid;
  gap: 4px;
}

.footer-name {
  color: #ffffff;
  font-weight: 900;
}

.footer-tagline,
.footer-copy {
  color: #7a7068;
  font-size: 13px;
}

.footer-links {
  display: flex;
  gap: 18px;
}

.footer-links a {
  color: #b5aaa1;
  font-weight: 800;
}

.footer-copy {
  margin: 16px 0 0;
  text-align: center;
}

.floating-wa {
  position: fixed;
  right: 18px;
  bottom: 18px;
  z-index: 50;
  display: grid;
  gap: 1px;
  min-width: 154px;
  border: 1px solid rgba(255, 255, 255, 0.36);
  border-radius: 999px;
  padding: 11px 18px;
  background: #1f9d57;
  color: #ffffff;
  box-shadow: 0 18px 44px rgba(24, 111, 64, 0.28);
}

.floating-wa span {
  font-size: 11px;
  font-weight: 800;
  opacity: 0.85;
}

.floating-wa strong {
  font-size: 14px;
  line-height: 1.1;
}

@media (max-width: 760px) {
  .nav-inner,
  .shop-header,
  .cta-strip-inner,
  .footer-inner {
    align-items: flex-start;
    flex-direction: column;
  }

  .hero {
    padding: 46px 0 34px;
  }

  .hero-inner {
    grid-template-columns: 1fr;
  }

  .featured-row {
    grid-template-columns: 1fr;
  }

  .featured-slider {
    padding: 0 0 42px;
  }

  .featured-arrow {
    top: auto;
    bottom: -2px;
  }

  .featured-arrow.left {
    left: 14px;
  }

  .featured-arrow.right {
    right: 14px;
  }

  .featured-card {
    grid-template-columns: 46% minmax(0, 1fr);
    min-height: 210px;
    border-radius: 24px;
  }

  .featured-img-wrap {
    height: 100%;
    min-height: 210px;
  }

  .featured-img-wrap img {
    aspect-ratio: auto;
  }

  .featured-card div {
    display: flex;
    flex-direction: column;
    justify-content: center;
    padding: 18px;
  }

  .featured-card h3 {
    font-size: 20px;
  }

  .featured-card p {
    font-size: 18px;
  }

  .promise-section {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 600px) {
  .hero {
    padding-top: 36px;
  }

  .hero-stats {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 8px;
  }

  .hero-stats div {
    min-width: 0;
    padding: 10px;
  }

  .hero-stats strong {
    font-size: 18px;
  }

  .hero-stats span {
    font-size: 10px;
  }

  .promise-section {
    padding-top: 34px;
  }

  .promise-card,
  .process-slider,
  .process-panel {
    min-height: 220px;
  }

  .process-panel {
    padding: 22px;
    padding-bottom: 48px;
  }

  .process-panel h3 {
    font-size: 26px;
  }

  .product-grid,
  .skeleton-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 12px;
  }

  .featured-row {
    grid-template-columns: 1fr;
  }

  .product-card-body {
    padding: 12px;
  }

  .product-card-name {
    font-size: 15px;
  }

  .product-card-desc {
    display: none;
  }

  .product-card-footer {
    align-items: flex-start;
    flex-direction: column;
    gap: 4px;
  }

  .floating-wa {
    right: 12px;
    bottom: 12px;
    min-width: 132px;
    padding: 10px 14px;
  }
}

@media (prefers-reduced-motion: reduce) {
  .hero-text,
  .promise-card,
  .process-panel,
  .featured-card,
  .product-card,
  .skeleton-media::after,
  .skeleton-line::after {
    animation: none;
  }

  .featured-slide-enter-active,
  .featured-slide-leave-active,
  .process-slide-enter-active,
  .process-slide-leave-active {
    transition: none;
  }

  .shop-btn,
  .product-card,
  .featured-card {
    transition: none;
  }
}
</style>
