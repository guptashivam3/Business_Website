<template>
  <div class="gallery-page">
    <nav class="gallery-nav">
      <div class="container gallery-nav-inner">
        <RouterLink to="/" class="gallery-nav-brand">
          <span class="gallery-nav-brand-name">{{ shopName }}</span>
          <span class="gallery-nav-brand-sub">Handmade with love</span>
        </RouterLink>
        <RouterLink to="/" class="gallery-btn outline small">Back to Shop</RouterLink>
      </div>
    </nav>

    <section class="gallery-hero container">
      <p class="section-label">Our Work</p>
      <h1 class="section-title">Inspiration Gallery</h1>
      <p class="section-sub">
        A showcase of completed pieces and past designs. Like something? Message us for something similar.
      </p>
    </section>

    <main class="gallery-body container">
      <div v-if="loading" class="loading-wrap">
        <div class="spinner"></div>
        <span>Loading gallery...</span>
      </div>

      <div v-else-if="items.length === 0" class="gallery-empty-state">
        <div class="empty-state-icon">Art</div>
        <h3>Gallery coming soon</h3>
        <p>Photos of completed work will appear here once added from the admin dashboard.</p>
        <RouterLink to="/" class="gallery-btn outline">Browse Products</RouterLink>
      </div>

      <div v-else class="gallery-grid">
        <article v-for="item in items" :key="item.id" class="gallery-item" @click="openLightbox(item)">
          <div class="gallery-img-wrap">
            <img :src="item.image_url" :alt="item.title" class="gallery-img" loading="lazy" />
            <div class="gallery-overlay">
              <span class="gallery-zoom">View</span>
            </div>
          </div>
          <div class="gallery-caption">
            <p v-if="item.category" class="gallery-cat">{{ item.category }}</p>
            <h3 class="gallery-title">{{ item.title }}</h3>
            <p v-if="item.description" class="gallery-desc">{{ item.description }}</p>
          </div>
        </article>
      </div>
    </main>

    <div v-if="lightboxItem" class="lightbox" @click.self="closeLightbox">
      <button class="lightbox-close" type="button" @click="closeLightbox">Close</button>
      <div class="lightbox-inner">
        <img :src="lightboxItem.image_url" :alt="lightboxItem.title" class="lightbox-img" />
        <div class="lightbox-info">
          <p v-if="lightboxItem.category" class="gallery-cat">{{ lightboxItem.category }}</p>
          <h3 class="lightbox-title">{{ lightboxItem.title }}</h3>
          <p v-if="lightboxItem.description" class="lightbox-desc">{{ lightboxItem.description }}</p>
          <a :href="customOrderLink(lightboxItem.title)" target="_blank" rel="noopener" class="gallery-btn whatsapp">
            Order Something Similar
          </a>
        </div>
      </div>
    </div>

    <section class="gallery-cta container">
      <div class="gallery-cta-card">
        <p class="section-label">Liked what you saw?</p>
        <h2 class="gallery-cta-title">We can make it for you</h2>
        <p class="gallery-cta-sub">Custom orders are welcome. Share your idea and we will confirm details on WhatsApp.</p>
        <div class="gallery-cta-btns">
          <a :href="customIdeaLink" target="_blank" rel="noopener" class="gallery-btn whatsapp large">Place a Custom Order</a>
          <RouterLink to="/" class="gallery-btn outline large">Browse Shop</RouterLink>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup>
import { computed, onMounted, onUnmounted, ref } from 'vue'
import { supabase } from '../lib/supabase.js'

const shopName = import.meta.env.VITE_SHOP_NAME || 'Handmade Craft Shop'
const phone = import.meta.env.VITE_WHATSAPP_PHONE || ''
const items = ref([])
const loading = ref(true)
const lightboxItem = ref(null)

const customIdeaLink = computed(() => {
  const message = 'Hi! I saw your gallery and have a custom order idea.'
  return whatsAppLink(message)
})

function whatsAppLink(message) {
  return `https://wa.me/${phone}?text=${encodeURIComponent(message)}`
}

function customOrderLink(title) {
  return whatsAppLink(`Hi! I saw this in your gallery and would like something similar: ${title}`)
}

function openLightbox(item) {
  lightboxItem.value = item
  document.body.style.overflow = 'hidden'
}

function closeLightbox() {
  lightboxItem.value = null
  document.body.style.overflow = ''
}

onUnmounted(() => {
  document.body.style.overflow = ''
})

onMounted(loadGallery)

async function loadGallery() {
  loading.value = true
  const { data, error } = await supabase
    .from('gallery_items')
    .select('*')
    .eq('is_visible', true)
    .order('created_at', { ascending: false })

  if (error) console.error(error)
  items.value = data || []
  loading.value = false
}
</script>

<style scoped>
.gallery-page {
  min-height: 100vh;
  background: #fffaf4;
}

.gallery-nav {
  position: sticky;
  top: 0;
  z-index: 20;
  border-bottom: 1px solid #eadfd2;
  background: rgba(255, 250, 244, 0.96);
  backdrop-filter: blur(14px);
}

.gallery-nav-inner {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 16px;
  padding: 16px 0;
}

.gallery-nav-brand {
  display: grid;
  gap: 2px;
}

.gallery-nav-brand-name {
  color: #241f1a;
  font-size: 21px;
  font-weight: 900;
}

.gallery-nav-brand-sub {
  color: #77695f;
  font-size: 13px;
  font-weight: 700;
}

.gallery-btn {
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

.gallery-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 12px 28px rgba(65, 42, 24, 0.14);
}

.gallery-btn.small {
  min-height: 38px;
  padding: 8px 14px;
}

.gallery-btn.large {
  min-height: 48px;
  padding: 13px 20px;
}

.gallery-btn.outline {
  border-color: #d8c8b8;
  background: #ffffff;
  color: #261f1a;
}

.gallery-btn.whatsapp {
  background: #1f9d57;
}

.gallery-hero {
  padding: 58px 0 28px;
}

.section-label {
  margin: 0 0 10px;
  color: #79401f;
  font-size: 13px;
  font-weight: 900;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.section-title {
  margin: 0 0 12px;
  color: #241f1a;
  font-size: clamp(42px, 7vw, 72px);
  line-height: 1;
  letter-spacing: 0;
}

.section-sub {
  max-width: 650px;
  color: #77695f;
  font-size: 18px;
  line-height: 1.7;
}

.gallery-body {
  padding-bottom: 58px;
}

.loading-wrap,
.gallery-empty-state {
  display: grid;
  place-items: center;
  gap: 12px;
  min-height: 300px;
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

.gallery-grid {
  columns: 3;
  column-gap: 18px;
}

.gallery-item {
  break-inside: avoid;
  margin-bottom: 18px;
  cursor: pointer;
}

.gallery-img-wrap {
  position: relative;
  overflow: hidden;
  border: 1px solid #eadfd2;
  border-radius: 18px;
  background: #f2e5d7;
  box-shadow: 0 16px 42px rgba(65, 42, 24, 0.08);
}

.gallery-img {
  display: block;
  width: 100%;
  transition: transform 240ms ease;
}

.gallery-item:hover .gallery-img {
  transform: scale(1.04);
}

.gallery-overlay {
  position: absolute;
  inset: 0;
  display: grid;
  place-items: center;
  background: rgba(26, 23, 20, 0);
  transition: background 180ms ease;
}

.gallery-item:hover .gallery-overlay {
  background: rgba(26, 23, 20, 0.34);
}

.gallery-zoom {
  border-radius: 999px;
  padding: 8px 14px;
  background: rgba(26, 23, 20, 0.76);
  color: #ffffff;
  font-size: 13px;
  font-weight: 900;
  opacity: 0;
  transition: opacity 180ms ease;
}

.gallery-item:hover .gallery-zoom {
  opacity: 1;
}

.gallery-caption {
  padding: 10px 4px 0;
}

.gallery-cat {
  margin: 0 0 4px;
  color: #79401f;
  font-size: 12px;
  font-weight: 900;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.gallery-title {
  margin: 0 0 4px;
  color: #261f1a;
  font-size: 17px;
}

.gallery-desc {
  margin: 0;
  color: #77695f;
  font-size: 14px;
  line-height: 1.55;
}

.lightbox {
  position: fixed;
  inset: 0;
  z-index: 999;
  display: grid;
  place-items: center;
  padding: 28px;
  background: rgba(0, 0, 0, 0.86);
}

.lightbox-close {
  position: absolute;
  top: 18px;
  right: 18px;
  border: 1px solid rgba(255, 255, 255, 0.24);
  border-radius: 999px;
  padding: 9px 14px;
  background: rgba(255, 255, 255, 0.12);
  color: #ffffff;
  cursor: pointer;
  font-weight: 900;
}

.lightbox-inner {
  display: grid;
  grid-template-columns: minmax(0, 520px) minmax(240px, 1fr);
  gap: 28px;
  align-items: center;
  width: min(100%, 920px);
}

.lightbox-img {
  width: 100%;
  max-height: 76vh;
  object-fit: contain;
  border-radius: 18px;
}

.lightbox-info {
  color: #ffffff;
}

.lightbox-info .gallery-cat {
  color: #f2d7c2;
}

.lightbox-title {
  margin: 6px 0 10px;
  font-size: 28px;
}

.lightbox-desc {
  color: rgba(255, 255, 255, 0.76);
  line-height: 1.65;
}

.gallery-cta {
  padding-bottom: 64px;
}

.gallery-cta-card {
  padding: 38px;
  border: 1px solid #eadfd2;
  border-radius: 24px;
  background: #fff3e4;
  text-align: center;
  box-shadow: 0 18px 50px rgba(65, 42, 24, 0.09);
}

.gallery-cta-title {
  margin: 0 0 10px;
  color: #241f1a;
  font-size: clamp(30px, 5vw, 48px);
}

.gallery-cta-sub {
  max-width: 520px;
  margin: 0 auto 22px;
  color: #77695f;
  line-height: 1.7;
}

.gallery-cta-btns {
  display: flex;
  justify-content: center;
  gap: 12px;
  flex-wrap: wrap;
}

@media (max-width: 820px) {
  .gallery-grid {
    columns: 2;
  }

  .lightbox-inner {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 520px) {
  .gallery-nav-inner {
    align-items: flex-start;
    flex-direction: column;
  }

  .gallery-grid {
    columns: 1;
  }

  .gallery-hero {
    padding-top: 38px;
  }

  .gallery-cta-card {
    padding: 26px 18px;
  }
}
</style>
