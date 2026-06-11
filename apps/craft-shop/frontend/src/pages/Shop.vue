<template>
  <div class="shop-page">
    <nav class="shop-nav">
      <div class="container nav-inner">
        <RouterLink to="/" class="nav-brand">
          <span class="nav-brand-name">{{ shopName }}</span>
          <span class="nav-brand-sub">Handmade with love</span>
        </RouterLink>
        <div class="nav-links">
          <RouterLink to="/gallery" class="shop-btn ghost small">Gallery</RouterLink>
          <RouterLink to="/admin/login" class="shop-btn outline small">Admin</RouterLink>
        </div>
      </div>
    </nav>

    <section class="hero">
      <div class="container hero-inner">
        <div class="hero-text">
          <p class="section-label">Handcrafted in India</p>
          <h1 class="hero-title">Beautiful things,<br /><em>made by hand</em></h1>
          <p class="hero-sub">
            Each piece is crafted with care. Browse the collection and order directly on WhatsApp.
          </p>
          <div class="hero-actions">
            <a :href="whatsAppLink('Hi! I would like to place an order.')" target="_blank" rel="noopener" class="shop-btn whatsapp large">
              Chat to Order
            </a>
            <RouterLink to="/gallery" class="shop-btn outline large">View Gallery</RouterLink>
          </div>
        </div>

        <div class="hero-order-card">
          <p class="hero-order-label">Easy ordering</p>
          <h2>Choose, customise, confirm.</h2>
          <div class="hero-order-steps">
            <div>
              <span>01</span>
              <p>Pick a ready design or share a similar reference.</p>
            </div>
            <div>
              <span>02</span>
              <p>Confirm color, size, packing and delivery details.</p>
            </div>
            <div>
              <span>03</span>
              <p>Place the final order directly with the owner on WhatsApp.</p>
            </div>
          </div>
        </div>
      </div>
    </section>

    <section class="shop-section container">
      <div class="shop-header">
        <div>
          <p class="section-label">Our Collection</p>
          <h2 class="section-title">Shop All Products</h2>
        </div>
        <div v-if="!loading" class="result-count">
          {{ filteredProducts.length }} item{{ filteredProducts.length !== 1 ? 's' : '' }}
        </div>
      </div>

      <div class="cat-wrap">
        <button
          v-for="category in categories"
          :key="category"
          class="cat-chip"
          :class="{ active: activeCategory === category }"
          type="button"
          @click="activeCategory = category"
        >
          {{ category }}
        </button>
      </div>

      <div v-if="loading" class="loading-wrap">
        <div class="spinner"></div>
        <span>Loading products...</span>
      </div>

      <div v-else-if="filteredProducts.length === 0" class="shop-empty-state">
        <div class="empty-state-icon">Art</div>
        <h3>No products yet</h3>
        <p>Products will appear here once they are added from the admin dashboard.</p>
        <RouterLink to="/admin/login" class="shop-btn outline">Add Products</RouterLink>
      </div>

      <div v-else class="product-grid">
        <RouterLink v-for="product in filteredProducts" :key="product.id" :to="`/product/${product.slug}`" class="product-card">
          <div class="product-card-img-wrap">
            <img v-if="product.image_url" :src="product.image_url" :alt="product.name" class="product-card-img" loading="lazy" />
            <div v-else class="product-card-placeholder">Image</div>
            <div class="product-card-badges">
              <span v-if="!product.is_available" class="badge sold">Sold Out</span>
              <span v-else-if="product.is_featured" class="badge featured">Featured</span>
            </div>
          </div>
          <div class="product-card-body">
            <p v-if="product.category" class="product-card-cat">{{ product.category }}</p>
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

    <section class="cta-strip">
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
          <RouterLink to="/gallery">Gallery</RouterLink>
          <a :href="whatsAppLink('Hi!')" target="_blank" rel="noopener">WhatsApp</a>
        </div>
      </div>
      <p class="footer-copy">Copyright {{ currentYear }} {{ shopName }}. All rights reserved.</p>
    </footer>
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import { supabase } from '../lib/supabase.js'

const shopName = import.meta.env.VITE_SHOP_NAME || 'Handmade Craft Shop'
const phone = import.meta.env.VITE_WHATSAPP_PHONE || ''
const products = ref([])
const activeCategory = ref('All')
const loading = ref(true)
const currentYear = new Date().getFullYear()

const categories = computed(() => {
  const names = products.value.map((product) => product.category).filter(Boolean)
  return ['All', ...new Set(names)]
})

const filteredProducts = computed(() => {
  if (activeCategory.value === 'All') return products.value
  return products.value.filter((product) => product.category === activeCategory.value)
})

function whatsAppLink(message) {
  return `https://wa.me/${phone}?text=${encodeURIComponent(message)}`
}

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

<style scoped>
.shop-page {
  min-height: 100vh;
  background: #fffaf4;
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

.hero {
  padding: 68px 0 54px;
  border-bottom: 1px solid #eadfd2;
  background:
    linear-gradient(90deg, rgba(255, 250, 244, 0.96), rgba(255, 250, 244, 0.8)),
    radial-gradient(circle at 82% 18%, #f2d7c2 0, transparent 34%),
    #fff3e4;
}

.hero-inner {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 320px;
  gap: 34px;
  align-items: end;
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

.hero-order-card {
  display: grid;
  gap: 16px;
  padding: 22px;
  border: 1px solid rgba(234, 223, 210, 0.9);
  border-radius: 22px;
  background: rgba(255, 255, 255, 0.82);
  box-shadow: 0 18px 50px rgba(65, 42, 24, 0.09);
  backdrop-filter: blur(14px);
}

.hero-order-label {
  margin: 0;
  color: #79401f;
  font-size: 12px;
  font-weight: 900;
  letter-spacing: 0.12em;
  text-transform: uppercase;
}

.hero-order-card h2 {
  margin: 0;
  color: #241f1a;
  font-size: 28px;
  line-height: 1.1;
  font-weight: 900;
}

.hero-order-steps {
  display: grid;
  gap: 12px;
}

.hero-order-steps div {
  display: grid;
  grid-template-columns: 38px 1fr;
  gap: 12px;
  align-items: start;
  padding-top: 12px;
  border-top: 1px solid #eadfd2;
}

.hero-order-steps span {
  display: grid;
  place-items: center;
  width: 34px;
  height: 34px;
  border-radius: 999px;
  background: #fff3e4;
  color: #79401f;
  font-size: 12px;
  font-weight: 900;
}

.hero-order-steps p {
  margin: 0;
  color: #5f5147;
  font-size: 14px;
  line-height: 1.55;
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

.cat-wrap {
  display: flex;
  gap: 10px;
  overflow-x: auto;
  padding: 4px 0 22px;
}

.cat-chip {
  flex: 0 0 auto;
  border: 1px solid #eadfd2;
  border-radius: 999px;
  padding: 10px 16px;
  background: #ffffff;
  color: #261f1a;
  cursor: pointer;
  font-weight: 850;
}

.cat-chip.active {
  border-color: #a85f33;
  background: #a85f33;
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

  .hero-order-card {
    padding: 18px;
  }
}

@media (max-width: 600px) {
  .product-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 12px;
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
}
</style>
