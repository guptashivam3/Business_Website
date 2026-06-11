<template>
  <div class="pd-page">
    <nav class="pd-nav">
      <div class="container pd-nav-inner">
        <RouterLink to="/" class="pd-nav-brand">
          <span class="pd-nav-brand-name">{{ shopName }}</span>
          <span class="pd-nav-brand-sub">Handmade with love</span>
        </RouterLink>
        <div class="pd-nav-links">
          <RouterLink to="/about" class="pd-btn ghost small">About</RouterLink>
          <RouterLink to="/" class="pd-btn ghost small">Back to Shop</RouterLink>
        </div>
      </div>
    </nav>

    <div v-if="loading" class="loading-wrap">
      <div class="spinner"></div>
      <span>Loading product...</span>
    </div>

    <div v-else-if="!product" class="pd-empty-state">
      <div class="empty-state-icon">Item</div>
      <h3>Product not found</h3>
      <p>This product may have been removed.</p>
      <RouterLink to="/" class="pd-btn">Back to Shop</RouterLink>
    </div>

    <main v-else class="pd-body container">
      <div class="breadcrumb">
        <RouterLink to="/">Shop</RouterLink>
        <span>/</span>
        <span>{{ product.name }}</span>
      </div>

      <div class="pd-layout">
        <div class="pd-media">
          <div class="pd-img-wrap">
            <img v-if="product.image_url" :src="product.image_url" :alt="product.name" class="pd-img" />
            <div v-else class="pd-img-placeholder">Image</div>
          </div>

          <div v-if="product.video_url" class="pd-video-wrap">
            <p class="pd-video-label">Product Video</p>
            <video :src="product.video_url" controls class="pd-video"></video>
          </div>
        </div>

        <div class="pd-info">
          <p v-if="product.category" class="pd-cat">{{ product.category }}</p>
          <h1 class="pd-name">{{ product.name }}</h1>

          <div class="pd-status-row">
            <span v-if="!product.is_available" class="pd-badge sold">Sold Out</span>
            <span v-else class="pd-badge available">Available</span>
            <span v-if="product.is_featured" class="pd-badge featured">Featured</span>
          </div>

          <div class="pd-price">Rs {{ Number(product.price).toFixed(2) }}</div>

          <div v-if="product.description" class="pd-desc">
            <p class="pd-desc-label">About this product</p>
            <p>{{ product.description }}</p>
          </div>

          <div class="pd-order-section">
            <p class="pd-order-title">How to Order</p>

            <div class="pd-order-btns">
              <a :href="waOrderLink" target="_blank" rel="noopener" class="pd-btn whatsapp full">
                Order on WhatsApp
              </a>

              <a :href="waEnquiryLink" target="_blank" rel="noopener" class="pd-btn outline full">
                Ask a Question
              </a>
            </div>

            <div v-if="showUpiPayment" class="upi-card">
              <div class="upi-header">
                <span class="upi-icon">UPI</span>
                <div>
                  <p class="upi-title">Pay via UPI</p>
                  <p class="upi-sub">Send Rs {{ Number(product.price).toFixed(2) }} to this UPI ID</p>
                </div>
              </div>
              <div class="upi-id-wrap">
                <code class="upi-id">{{ upiId }}</code>
                <button @click="copyUPI" class="upi-copy-btn" type="button">
                  {{ copied ? 'Copied' : 'Copy' }}
                </button>
              </div>
              <p class="upi-note">After payment, send the screenshot on WhatsApp to confirm your order.</p>
            </div>
          </div>

          <div class="pd-service-note">
            <p class="pd-service-title">What happens next</p>
            <div class="pd-service-steps">
              <span>Availability is confirmed personally.</span>
              <span>Custom colors or packing can be discussed.</span>
              <span>Payment and delivery details are shared on WhatsApp.</span>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import { useRoute } from 'vue-router'
import { supabase } from '../lib/supabase.js'

const route = useRoute()
const shopName = import.meta.env.VITE_SHOP_NAME || 'Handmade Craft Shop'
const phone = import.meta.env.VITE_WHATSAPP_PHONE || ''
const upiId = import.meta.env.VITE_UPI_ID || 'yourupi@upi'
const showUpiPayment = false

const product = ref(null)
const loading = ref(true)
const copied = ref(false)

const waOrderLink = computed(() => {
  const message = `Hi! I would like to order:\n\n${product.value?.name} - Rs ${product.value?.price}\n\nPlease confirm availability and delivery details.`
  return `https://wa.me/${phone}?text=${encodeURIComponent(message)}`
})

const waEnquiryLink = computed(() => {
  const message = `Hi! I have a question about: ${product.value?.name}`
  return `https://wa.me/${phone}?text=${encodeURIComponent(message)}`
})

async function copyUPI() {
  await navigator.clipboard.writeText(upiId)
  copied.value = true
  setTimeout(() => {
    copied.value = false
  }, 2000)
}

onMounted(loadProduct)

async function loadProduct() {
  loading.value = true
  const { data, error } = await supabase
    .from('products')
    .select('*')
    .eq('slug', route.params.slug)
    .single()

  if (error) console.error(error)
  product.value = data || null
  loading.value = false
}
</script>

<style scoped>
.pd-page {
  min-height: 100vh;
  background: #fffaf4;
}

.pd-nav {
  position: sticky;
  top: 0;
  z-index: 20;
  border-bottom: 1px solid #eadfd2;
  background: rgba(255, 250, 244, 0.96);
  backdrop-filter: blur(14px);
}

.pd-nav-inner {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 16px;
  padding: 16px 0;
}

.pd-nav-links {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

.pd-nav-brand {
  display: grid;
  gap: 2px;
}

.pd-nav-brand-name {
  color: #241f1a;
  font-size: 21px;
  font-weight: 900;
}

.pd-nav-brand-sub {
  color: #77695f;
  font-size: 13px;
  font-weight: 700;
}

.pd-btn {
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

.pd-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 12px 28px rgba(65, 42, 24, 0.14);
}

.pd-btn.small {
  min-height: 38px;
  padding: 8px 14px;
}

.pd-btn.ghost {
  background: #f2e5d7;
  color: #261f1a;
}

.pd-btn.outline {
  border-color: #d8c8b8;
  background: #ffffff;
  color: #261f1a;
}

.pd-btn.whatsapp {
  background: #1f9d57;
}

.pd-btn.full {
  width: 100%;
}

.loading-wrap,
.pd-empty-state {
  display: grid;
  place-items: center;
  gap: 12px;
  min-height: 360px;
  padding: 34px;
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

.pd-body {
  padding: 28px 0 64px;
}

.breadcrumb {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 24px;
  color: #77695f;
  font-size: 14px;
  font-weight: 700;
}

.breadcrumb a {
  color: #a85f33;
}

.pd-layout {
  display: grid;
  grid-template-columns: minmax(0, 1fr) minmax(360px, 0.88fr);
  gap: 44px;
  align-items: start;
}

.pd-media {
  position: sticky;
  top: 92px;
  display: grid;
  gap: 16px;
}

.pd-img-wrap {
  overflow: hidden;
  border: 1px solid #eadfd2;
  border-radius: 24px;
  aspect-ratio: 1 / 1;
  background: #f2e5d7;
  box-shadow: 0 22px 56px rgba(65, 42, 24, 0.12);
}

.pd-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.pd-img-placeholder {
  display: grid;
  place-items: center;
  width: 100%;
  height: 100%;
  color: #a85f33;
  font-size: 22px;
  font-weight: 900;
}

.pd-video-wrap {
  padding: 16px;
  border: 1px solid #eadfd2;
  border-radius: 18px;
  background: #ffffff;
  box-shadow: 0 16px 42px rgba(65, 42, 24, 0.08);
}

.pd-video-label {
  margin-bottom: 8px;
  color: #77695f;
  font-size: 13px;
  font-weight: 900;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.pd-video {
  width: 100%;
  border-radius: 12px;
}

.pd-info {
  padding: 28px;
  border: 1px solid #eadfd2;
  border-radius: 24px;
  background: #fffdf8;
  box-shadow: 0 18px 50px rgba(65, 42, 24, 0.09);
}

.pd-cat {
  margin-bottom: 8px;
  color: #79401f;
  font-size: 13px;
  font-weight: 900;
  letter-spacing: 0.1em;
  text-transform: uppercase;
}

.pd-name {
  margin-bottom: 14px;
  color: #241f1a;
  font-size: clamp(34px, 5vw, 52px);
  line-height: 1.04;
  letter-spacing: 0;
}

.pd-status-row {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
  margin-bottom: 18px;
}

.pd-badge {
  border-radius: 999px;
  padding: 7px 11px;
  color: #ffffff;
  font-size: 13px;
  font-weight: 900;
}

.pd-badge.available {
  background: #2f8f4f;
}

.pd-badge.sold {
  background: #a33b2f;
}

.pd-badge.featured {
  background: #79401f;
}

.pd-price {
  margin-bottom: 22px;
  color: #79401f;
  font-size: 38px;
  font-weight: 900;
}

.pd-desc {
  margin-bottom: 22px;
  padding: 18px;
  border-left: 4px solid #a85f33;
  border-radius: 16px;
  background: #fff3e4;
}

.pd-desc-label,
.pd-order-title {
  margin-bottom: 8px;
  color: #77695f;
  font-size: 13px;
  font-weight: 900;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.pd-desc p:last-child {
  margin-bottom: 0;
  color: #5f5147;
  line-height: 1.75;
}

.pd-order-section {
  margin-bottom: 22px;
}

.pd-order-btns {
  display: grid;
  gap: 10px;
  margin-bottom: 14px;
}

.upi-card {
  padding: 18px;
  border: 1px solid #eac96a;
  border-radius: 18px;
  background: #fff7d8;
}

.upi-header {
  display: flex;
  gap: 12px;
  align-items: center;
  margin-bottom: 12px;
}

.upi-icon {
  display: grid;
  place-items: center;
  width: 44px;
  height: 44px;
  border-radius: 999px;
  background: #ffffff;
  color: #79401f;
  font-size: 13px;
  font-weight: 900;
}

.upi-title {
  margin-bottom: 2px;
  color: #261f1a;
  font-weight: 900;
}

.upi-sub {
  margin: 0;
  color: #77695f;
  font-size: 14px;
}

.upi-id-wrap {
  display: flex;
  gap: 8px;
  align-items: center;
  margin-bottom: 10px;
  padding: 10px;
  border: 1px solid #eed987;
  border-radius: 12px;
  background: #ffffff;
}

.upi-id {
  flex: 1;
  color: #261f1a;
  font-size: 15px;
  font-weight: 900;
}

.upi-copy-btn {
  border: 0;
  border-radius: 999px;
  padding: 8px 12px;
  background: #a85f33;
  color: #ffffff;
  cursor: pointer;
  font-weight: 900;
}

.upi-note {
  margin: 0;
  color: #8a6d11;
  font-size: 13px;
  line-height: 1.5;
}

.pd-service-note {
  padding: 16px;
  border: 1px solid #eadfd2;
  border-radius: 18px;
  background: linear-gradient(180deg, #ffffff, #fff8ef);
}

.pd-service-title {
  margin: 0 0 10px;
  color: #79401f;
  font-size: 13px;
  font-weight: 900;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.pd-service-steps {
  display: grid;
  gap: 9px;
}

.pd-service-steps span {
  position: relative;
  padding-left: 18px;
  color: #5f5147;
  font-size: 14px;
  line-height: 1.55;
}

.pd-service-steps span::before {
  content: "";
  position: absolute;
  top: 0.65em;
  left: 0;
  width: 7px;
  height: 7px;
  border-radius: 99px;
  background: #a85f33;
}

@media (max-width: 820px) {
  .pd-layout {
    grid-template-columns: 1fr;
    gap: 24px;
  }

  .pd-media {
    position: static;
  }
}

@media (max-width: 560px) {
  .pd-nav-inner {
    align-items: flex-start;
    flex-direction: column;
  }

  .pd-body {
    padding: 18px 0 42px;
  }

  .pd-info {
    padding: 20px;
  }

  .pd-price {
    font-size: 30px;
  }

  .upi-id-wrap {
    align-items: stretch;
    flex-direction: column;
  }
}
</style>
