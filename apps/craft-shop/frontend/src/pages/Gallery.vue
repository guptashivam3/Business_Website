<template>
  <div class="gallery-page">
    <nav class="gallery-nav">
      <div class="container gallery-nav-inner">
        <RouterLink to="/" class="gallery-nav-brand">
          <span class="gallery-nav-brand-name">{{ shopName }}</span>
          <span class="gallery-nav-brand-sub">Handmade with love</span>
        </RouterLink>
        <div class="gallery-nav-links">
          <RouterLink to="/about" class="gallery-btn outline small">About Us</RouterLink>
          <RouterLink to="/" class="gallery-btn outline small">Back to Shop</RouterLink>
        </div>
      </div>
    </nav>

    <section class="gallery-hero container" v-reveal>
      <p class="section-label">Our Work</p>
      <h1 class="section-title">Inspiration Gallery</h1>
      <p class="section-sub">
        A showcase of completed pieces and past designs. Like something? Message us for something similar.
      </p>
    </section>

    <main class="gallery-body container" v-reveal="{ delay: 90 }">
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
        <article
          v-for="item in items"
          :key="item.id"
          class="gallery-item"
          v-reveal
          role="button"
          tabindex="0"
          @click="openLightbox(item)"
          @keydown.enter.prevent="openLightbox(item)"
          @keydown.space.prevent="openLightbox(item)"
        >
          <div class="gallery-img-wrap">
            <img :src="mainGalleryImage(item)" :alt="item.title" class="gallery-img" loading="lazy" />
            <span v-if="galleryImages(item).length > 1" class="gallery-count">{{ galleryImages(item).length }} photos</span>
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
      <div class="lightbox-inner">
        <div class="lightbox-topbar">
          <span>{{ activeLightboxIndex + 1 }} / {{ lightboxImages.length }}</span>
          <button class="lightbox-close" type="button" aria-label="Close gallery preview" @click="closeLightbox">Close</button>
        </div>
        <div class="lightbox-media">
          <button
            v-if="lightboxImages.length > 1"
            class="lightbox-arrow left"
            type="button"
            aria-label="Previous photo"
            @click="showPreviousImage"
          >
            Prev
          </button>
          <img :src="activeLightboxImage" :alt="lightboxItem.title" class="lightbox-img" />
          <button
            v-if="lightboxImages.length > 1"
            class="lightbox-arrow right"
            type="button"
            aria-label="Next photo"
            @click="showNextImage"
          >
            Next
          </button>
          <div v-if="lightboxImages.length > 1" class="lightbox-thumbs" aria-label="Gallery photos">
            <button
              v-for="(url, index) in lightboxImages"
              :key="url"
              type="button"
              class="lightbox-thumb"
              :class="{ active: activeLightboxImage === url }"
              :aria-label="`Show gallery photo ${index + 1}`"
              @click="setActiveImage(url)"
            >
              <img :src="url" :alt="`${lightboxItem.title} photo ${index + 1}`" />
            </button>
          </div>
        </div>
        <div class="lightbox-info">
          <p v-if="lightboxItem.category" class="gallery-cat">{{ lightboxItem.category }}</p>
          <h3 class="lightbox-title">{{ lightboxItem.title }}</h3>
          <p v-if="lightboxItem.description" class="lightbox-desc">{{ lightboxItem.description }}</p>
          <a :href="customOrderLink(lightboxItem)" target="_blank" rel="noopener" class="gallery-btn whatsapp" @click="trackGalleryOrder(lightboxItem)">
            Order Something Similar
          </a>
        </div>
      </div>
    </div>

    <section class="gallery-cta" v-reveal>
      <div class="container gallery-cta-inner">
        <p class="section-label">Liked what you saw?</p>
        <h2 class="gallery-cta-title">We can make it for you</h2>
        <p class="gallery-cta-sub">Custom orders are welcome. Share your idea and we will confirm details on WhatsApp.</p>
        <div class="gallery-cta-btns">
          <a :href="customIdeaLink" target="_blank" rel="noopener" class="gallery-btn whatsapp large" @click="trackCustomIdea">Place a Custom Order</a>
          <RouterLink to="/" class="gallery-btn outline large">Browse Shop</RouterLink>
        </div>
      </div>
    </section>

    <footer class="footer">
      <div class="container footer-inner">
        <div class="footer-brand">
          <span class="footer-name">{{ shopName }}</span>
          <span class="footer-tagline">Inspiration gallery for custom handmade work.</span>
        </div>
        <div class="footer-links">
          <RouterLink to="/">Shop</RouterLink>
          <RouterLink to="/about">About Us</RouterLink>
          <a :href="customIdeaLink" target="_blank" rel="noopener" @click="trackCustomIdea">WhatsApp</a>
          <a :href="`mailto:${ownerEmail}`" class="footer-contact-link">
            <span class="footer-icon email" aria-hidden="true"></span>{{ ownerEmail }}
          </a>
          <a :href="instagramLink" target="_blank" rel="noopener" class="footer-contact-link">
            <span class="footer-icon instagram" aria-hidden="true"></span>{{ instagramHandle }}
          </a>
        </div>
      </div>
      <p class="footer-copy">Copyright {{ currentYear }} {{ shopName }}. All rights reserved.</p>
    </footer>
  </div>
</template>

<script setup>
import { computed, onMounted, onUnmounted, reactive, ref } from 'vue'
import { supabase } from '../lib/supabase.js'
import { makeWhatsAppLink, trackEvent } from '../lib/analytics.js'

const shopName = import.meta.env.VITE_SHOP_NAME || 'Laxmi Creations'
const items = ref([])
const loading = ref(true)
const lightboxItem = ref(null)
const activeLightboxImage = ref('')
const currentYear = new Date().getFullYear()
const siteSettings = reactive({
  owner_email: 'laxmigupta8888@gmail.com',
  owner_instagram: 'laxmi_creations'
})

const lightboxImages = computed(() => (lightboxItem.value ? galleryImages(lightboxItem.value) : []))
const activeLightboxIndex = computed(() => Math.max(0, lightboxImages.value.indexOf(activeLightboxImage.value)))
const ownerEmail = computed(() => siteSettings.owner_email || 'laxmigupta8888@gmail.com')
const instagramHandle = computed(() => cleanInstagramHandle(siteSettings.owner_instagram || 'laxmi_creations'))
const instagramLink = computed(() => `https://www.instagram.com/${instagramHandle.value.replace('@', '')}`)

const customIdeaLink = computed(() => {
  const message = 'Namaste Laxmi ji,\n\nI saw your gallery and have a custom handmade order idea.\n\nPlease help me plan the design, budget, timeline, and delivery details.'
  return whatsAppLink(message)
})

function whatsAppLink(message) {
  return makeWhatsAppLink(message)
}

function customOrderLink(item) {
  return whatsAppLink(
    `Namaste Laxmi ji,\n\nI saw this inspiration design in your gallery and would like something similar.\n\nDesign: ${item.title}\nCategory: ${item.category || 'Custom handmade work'}\nImage reference: ${mainGalleryImage(item)}\n\nPlease share possible options, price range, customization details, and delivery timing.`
  )
}

function trackGalleryOrder(item) {
  trackEvent('custom_order_click', {
    source: 'gallery_lightbox',
    title: item?.title,
    category: item?.category,
    page_path: '/gallery'
  })
}

function trackCustomIdea() {
  trackEvent('custom_order_click', { source: 'gallery_cta', page_path: '/gallery' })
}

function openLightbox(item) {
  lightboxItem.value = item
  activeLightboxImage.value = mainGalleryImage(item)
  trackEvent('gallery_view', {
    source: 'gallery_card',
    title: item.title,
    category: item.category,
    page_path: '/gallery'
  })
  document.body.style.overflow = 'hidden'
}

function closeLightbox() {
  lightboxItem.value = null
  activeLightboxImage.value = ''
  document.body.style.overflow = ''
}

function galleryImages(item) {
  return [...new Set([...(Array.isArray(item.image_urls) ? item.image_urls : []), item.image_url].filter(Boolean))]
}

function mainGalleryImage(item) {
  return galleryImages(item)[0] || ''
}

function setActiveImage(url) {
  activeLightboxImage.value = url
}

function showNextImage() {
  if (!lightboxImages.value.length) return
  const nextIndex = (activeLightboxIndex.value + 1) % lightboxImages.value.length
  activeLightboxImage.value = lightboxImages.value[nextIndex]
}

function showPreviousImage() {
  if (!lightboxImages.value.length) return
  const nextIndex = (activeLightboxIndex.value - 1 + lightboxImages.value.length) % lightboxImages.value.length
  activeLightboxImage.value = lightboxImages.value[nextIndex]
}

function cleanInstagramHandle(value) {
  const handle = String(value || '').trim().replace(/^https?:\/\/(www\.)?instagram\.com\//, '').replace(/\/$/, '')
  return handle.startsWith('@') ? handle : `@${handle}`
}

onUnmounted(() => {
  document.body.style.overflow = ''
})

onMounted(() => {
  loadGallery()
  loadSiteSettings()
})

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

async function loadSiteSettings() {
  const { data, error } = await supabase.from('site_settings').select('owner_email, owner_instagram').eq('id', 'about').maybeSingle()
  if (!error && data) Object.assign(siteSettings, data)
}
</script>

<style scoped>
.gallery-page {
  min-height: 100vh;
  background:
    radial-gradient(circle at top left, rgba(184, 92, 56, 0.12), transparent 32rem),
    linear-gradient(180deg, #fffaf4 0%, #f8efe5 52%, #fffaf4 100%);
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

.gallery-nav-links {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
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

.gallery-btn:focus-visible,
.gallery-item:focus-visible,
.lightbox-close:focus-visible,
.lightbox-arrow:focus-visible,
.lightbox-thumb:focus-visible {
  outline: 3px solid rgba(168, 95, 51, 0.24);
  outline-offset: 3px;
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
  padding: 46px 0 22px;
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
  font-size: clamp(34px, 6vw, 58px);
  line-height: 1.04;
  letter-spacing: 0;
}

.section-sub {
  max-width: 650px;
  color: #77695f;
  font-size: 16px;
  line-height: 1.65;
}

.gallery-body {
  padding-bottom: 42px;
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
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(190px, 1fr));
  gap: 16px;
  align-items: start;
}

.gallery-item {
  cursor: pointer;
  overflow: hidden;
  border: 1px solid rgba(234, 223, 210, 0.92);
  border-radius: 18px;
  background: rgba(255, 253, 248, 0.82);
  box-shadow: 0 14px 34px rgba(65, 42, 24, 0.08);
  backdrop-filter: blur(14px);
  transition: transform 180ms ease, box-shadow 180ms ease, border-color 180ms ease;
  animation: riseIn 520ms ease both;
}

.gallery-item:focus-visible {
  border-color: rgba(184, 92, 56, 0.5);
  box-shadow: 0 0 0 4px rgba(168, 95, 51, 0.12), 0 18px 42px rgba(65, 42, 24, 0.13);
}

@keyframes riseIn {
  from {
    opacity: 0;
    transform: translateY(16px);
  }

  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.gallery-item:hover {
  border-color: rgba(184, 92, 56, 0.28);
  box-shadow: 0 18px 42px rgba(65, 42, 24, 0.13);
  transform: translateY(-3px);
}

.gallery-img-wrap {
  position: relative;
  overflow: hidden;
  aspect-ratio: 4 / 5;
  background: #f2e5d7;
}

.gallery-count {
  position: absolute;
  top: 10px;
  left: 10px;
  z-index: 1;
  border-radius: 999px;
  padding: 5px 9px;
  background: rgba(26, 23, 20, 0.72);
  color: #ffffff;
  font-size: 12px;
  font-weight: 900;
}

.gallery-img {
  display: block;
  width: 100%;
  height: 100%;
  object-fit: cover;
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
  background: linear-gradient(180deg, rgba(26, 23, 20, 0), rgba(26, 23, 20, 0.12));
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
  padding: 12px 12px 14px;
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
  font-size: 15px;
  line-height: 1.28;
}

.gallery-desc {
  margin: 0;
  color: #77695f;
  display: -webkit-box;
  overflow: hidden;
  font-size: 13px;
  line-height: 1.5;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 2;
}

.lightbox {
  position: fixed;
  inset: 0;
  z-index: 999;
  display: grid;
  place-items: center;
  padding: 18px;
  background: rgba(18, 15, 12, 0.78);
  backdrop-filter: blur(16px);
}

.lightbox-inner {
  display: grid;
  grid-template-columns: minmax(0, 560px) minmax(260px, 1fr);
  grid-template-rows: auto minmax(0, 1fr);
  gap: 0;
  width: min(100%, 920px);
  max-height: calc(100vh - 36px);
  overflow: hidden;
  border: 1px solid rgba(255, 255, 255, 0.18);
  border-radius: 24px;
  background: rgba(255, 253, 248, 0.96);
  box-shadow: 0 28px 80px rgba(0, 0, 0, 0.34);
}

.lightbox-topbar {
  grid-column: 1 / -1;
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
  min-height: 58px;
  padding: 10px 14px 10px 18px;
  border-bottom: 1px solid #eadfd2;
  background: #fffdf8;
}

.lightbox-topbar span {
  color: #79401f;
  font-size: 13px;
  font-weight: 900;
}

.lightbox-close {
  min-height: 40px;
  border: 1px solid #d8c8b8;
  border-radius: 999px;
  padding: 8px 14px;
  background: #ffffff;
  color: #261f1a;
  cursor: pointer;
  font-weight: 900;
}

.lightbox-media {
  position: relative;
  display: grid;
  align-content: start;
  min-height: 0;
  background: #f2e5d7;
}

.lightbox-img {
  display: block;
  width: 100%;
  height: min(68vh, 640px);
  object-fit: contain;
  background: #f2e5d7;
}

.lightbox-arrow {
  position: absolute;
  top: calc(50% - 38px);
  z-index: 2;
  display: grid;
  place-items: center;
  width: 42px;
  height: 42px;
  overflow: hidden;
  border: 1px solid rgba(255, 255, 255, 0.62);
  border-radius: 999px;
  background: rgba(38, 31, 26, 0.58);
  color: transparent;
  cursor: pointer;
  font-size: 0;
  backdrop-filter: blur(10px);
  transition: background 160ms ease, transform 160ms ease;
}

.lightbox-arrow:hover {
  background: rgba(38, 31, 26, 0.72);
  transform: translateY(-1px);
}

.lightbox-arrow::before {
  content: "";
  width: 12px;
  height: 12px;
  border-top: 2px solid #ffffff;
  border-left: 2px solid #ffffff;
}

.lightbox-arrow.left {
  left: 12px;
}

.lightbox-arrow.left::before {
  transform: rotate(-45deg) translate(1px, 1px);
}

.lightbox-arrow.right {
  right: 12px;
}

.lightbox-arrow.right::before {
  transform: rotate(135deg) translate(1px, 1px);
}

.lightbox-thumbs {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(64px, 1fr));
  gap: 8px;
  padding: 10px;
  overflow-x: auto;
  background: rgba(255, 253, 248, 0.96);
}

.lightbox-thumb {
  overflow: hidden;
  border: 2px solid transparent;
  border-radius: 10px;
  aspect-ratio: 1 / 1;
  padding: 0;
  background: #f2e5d7;
  cursor: pointer;
}

.lightbox-thumb.active {
  border-color: #a85f33;
}

.lightbox-thumb img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.lightbox-info {
  min-height: 0;
  overflow: auto;
  padding: 26px;
  color: #241f1a;
}

.lightbox-info .gallery-cat {
  color: #79401f;
}

.lightbox-title {
  margin: 6px 0 10px;
  font-size: 28px;
}

.lightbox-desc {
  color: #77695f;
  line-height: 1.65;
}

.gallery-cta {
  padding: 44px 0;
  background: #261f1a;
}

.gallery-cta-inner {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 24px;
  flex-wrap: wrap;
}

.gallery-cta-inner > p,
.gallery-cta-inner > h2 {
  flex: 1 1 100%;
}

.gallery-cta-inner .section-label {
  margin-bottom: -8px;
  color: #d7b981;
}

.gallery-cta-title {
  max-width: 760px;
  margin: 0;
  color: #ffffff;
  font-size: clamp(30px, 5vw, 44px);
}

.gallery-cta-sub {
  max-width: 520px;
  margin: 0;
  color: #b5aaa1;
  line-height: 1.65;
}

.gallery-cta-btns {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  flex-wrap: wrap;
}

.footer {
  padding: 34px 0 20px;
  border-top: 1px solid #eadfd2;
  background:
    radial-gradient(circle at 15% 0%, rgba(184, 92, 56, 0.1), transparent 28rem),
    linear-gradient(180deg, #fffaf4 0%, #f3e7da 100%);
}

.footer-inner {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 18px;
  flex-wrap: wrap;
  padding-bottom: 18px;
  border-bottom: 1px solid #e1d2c2;
}

.footer-brand {
  display: grid;
  gap: 4px;
}

.footer-name {
  color: #241f1a;
  font-weight: 900;
}

.footer-tagline,
.footer-copy {
  color: #77695f;
  font-size: 13px;
}

.footer-links {
  display: flex;
  align-items: center;
  gap: 18px;
  flex-wrap: wrap;
}

.footer-links a {
  border-radius: 999px;
  color: #6f6258;
  font-weight: 800;
  transition: color 160ms ease, background 160ms ease;
}

.footer-links a:hover {
  background: rgba(168, 95, 51, 0.09);
  color: #79401f;
}

.footer-links .footer-contact-link:hover {
  background: transparent;
}

.footer-contact-link {
  display: inline-flex;
  align-items: center;
  gap: 7px;
}

.footer-icon {
  display: inline-block;
  width: 25px;
  height: 25px;
  border-radius: 999px;
  background-color: #79401f;
  opacity: 0.92;
  -webkit-mask-position: center;
  -webkit-mask-repeat: no-repeat;
  -webkit-mask-size: 19px 19px;
  mask-position: center;
  mask-repeat: no-repeat;
  mask-size: 19px 19px;
}

.footer-icon.email {
  -webkit-mask-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 24 24' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M4 5h16c1.1 0 2 .9 2 2v10c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V7c0-1.1.9-2 2-2Zm0 3.2V17h16V8.2l-8 5.2-8-5.2Zm1.2-1.2 6.8 4.4L18.8 7H5.2Z'/%3E%3C/svg%3E");
  mask-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 24 24' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M4 5h16c1.1 0 2 .9 2 2v10c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V7c0-1.1.9-2 2-2Zm0 3.2V17h16V8.2l-8 5.2-8-5.2Zm1.2-1.2 6.8 4.4L18.8 7H5.2Z'/%3E%3C/svg%3E");
}

.footer-icon.instagram {
  -webkit-mask-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 24 24' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M7.8 2h8.4A5.8 5.8 0 0 1 22 7.8v8.4a5.8 5.8 0 0 1-5.8 5.8H7.8A5.8 5.8 0 0 1 2 16.2V7.8A5.8 5.8 0 0 1 7.8 2Zm0 2A3.8 3.8 0 0 0 4 7.8v8.4A3.8 3.8 0 0 0 7.8 20h8.4a3.8 3.8 0 0 0 3.8-3.8V7.8A3.8 3.8 0 0 0 16.2 4H7.8Zm8.8 2.3a1.1 1.1 0 1 1 0 2.2 1.1 1.1 0 0 1 0-2.2ZM12 7.2a4.8 4.8 0 1 1 0 9.6 4.8 4.8 0 0 1 0-9.6Zm0 2a2.8 2.8 0 1 0 0 5.6 2.8 2.8 0 0 0 0-5.6Z'/%3E%3C/svg%3E");
  mask-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 24 24' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M7.8 2h8.4A5.8 5.8 0 0 1 22 7.8v8.4a5.8 5.8 0 0 1-5.8 5.8H7.8A5.8 5.8 0 0 1 2 16.2V7.8A5.8 5.8 0 0 1 7.8 2Zm0 2A3.8 3.8 0 0 0 4 7.8v8.4A3.8 3.8 0 0 0 7.8 20h8.4a3.8 3.8 0 0 0 3.8-3.8V7.8A3.8 3.8 0 0 0 16.2 4H7.8Zm8.8 2.3a1.1 1.1 0 1 1 0 2.2 1.1 1.1 0 0 1 0-2.2ZM12 7.2a4.8 4.8 0 1 1 0 9.6 4.8 4.8 0 0 1 0-9.6Zm0 2a2.8 2.8 0 1 0 0 5.6 2.8 2.8 0 0 0 0-5.6Z'/%3E%3C/svg%3E");
}

.footer-copy {
  margin: 16px 0 0;
  text-align: center;
}

@media (max-width: 820px) {
  .gallery-grid {
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 12px;
  }

  .lightbox-inner {
    grid-template-columns: 1fr;
    max-height: calc(100dvh - 36px);
  }

  .lightbox-img {
    height: min(56vh, 520px);
  }
}

@media (max-width: 520px) {
  .gallery-nav-inner {
    align-items: flex-start;
    flex-direction: column;
  }

  .gallery-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 10px;
  }

  .gallery-nav-links {
    width: 100%;
  }

  .gallery-nav-links .gallery-btn {
    flex: 1;
  }

  .gallery-hero {
    padding-top: 30px;
  }

  .gallery-caption {
    padding: 9px 9px 11px;
  }

  .gallery-cat {
    font-size: 10px;
  }

  .gallery-title {
    font-size: 13px;
  }

  .gallery-desc {
    display: none;
  }

  .gallery-overlay {
    display: none;
  }

  .lightbox {
    align-items: end;
    padding: 10px;
  }

  .lightbox-inner {
    border-radius: 18px;
    max-height: calc(100dvh - 20px);
  }

  .lightbox-topbar {
    min-height: 52px;
    padding: 8px 10px 8px 14px;
  }

  .lightbox-img {
    height: min(52vh, 460px);
  }

  .lightbox-arrow {
    top: calc(50% - 44px);
    width: 38px;
    height: 38px;
  }

  .lightbox-arrow.left {
    left: 8px;
  }

  .lightbox-arrow.right {
    right: 8px;
  }

  .lightbox-thumbs {
    display: flex;
    gap: 8px;
    padding: 9px;
  }

  .lightbox-thumb {
    flex: 0 0 58px;
  }

  .lightbox-info {
    padding: 18px 18px 22px;
  }

  .lightbox-info .gallery-btn {
    width: 100%;
  }

  .lightbox-title {
    font-size: 22px;
  }

  .gallery-cta {
    padding: 36px 0;
  }

  .gallery-cta-inner {
    align-items: flex-start;
    flex-direction: column;
  }

  .gallery-cta-btns {
    justify-content: flex-start;
  }

  .footer-inner {
    align-items: flex-start;
    flex-direction: column;
  }

  .footer-links {
    gap: 12px;
  }
}

@media (prefers-reduced-motion: reduce) {
  .gallery-item {
    animation: none;
  }
}
</style>
