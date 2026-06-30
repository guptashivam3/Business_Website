<template>
  <div class="about-page">
    <nav class="about-nav">
      <div class="container about-nav-inner">
        <RouterLink to="/" class="about-brand">
          <span class="about-brand-name">{{ shopName }}</span>
          <span class="about-brand-sub">Handmade with love</span>
        </RouterLink>
        <div class="about-links">
          <RouterLink to="/" class="about-link">Shop</RouterLink>
          <RouterLink to="/gallery" class="about-link">Gallery</RouterLink>
        </div>
      </div>
    </nav>

    <main>
      <section class="about-hero" v-reveal>
        <div class="container about-hero-inner">
          <div class="about-copy">
            <p class="about-label">Meet the maker</p>
            <h1>{{ siteSettings.about_heading }}</h1>
            <p class="about-lead">
              {{ siteSettings.about_intro }}
            </p>
            <div class="about-actions">
              <a :href="whatsAppLink('Namaste Laxmi ji,\n\nI saw Laxmi Creations and want to discuss a handmade order.\n\nPlease share available designs, customization options, pricing, and delivery timing.')" target="_blank" rel="noopener" class="about-btn primary" @click="trackAboutWhatsApp('about_hero')">
                Message on WhatsApp
              </a>
              <RouterLink to="/gallery" class="about-btn outline">View Work</RouterLink>
            </div>
          </div>

          <div class="owner-card" :class="{ compact: !siteSettings.owner_photo_url }">
            <div class="owner-photo-placeholder">
              <img v-if="siteSettings.owner_photo_url" :src="siteSettings.owner_photo_url" :alt="siteSettings.owner_name" />
              <template v-else>
                <span>LC</span>
              </template>
            </div>
            <div class="owner-info">
              <span>Founder & Maker</span>
              <h2>{{ siteSettings.owner_name }}</h2>
              <p>Designing personal, handmade pieces for gifts, rituals, family events, and celebrations.</p>
            </div>
          </div>
        </div>
      </section>

      <section class="about-story container" v-reveal="{ delay: 100 }">
        <div class="story-card main-story">
          <p class="about-label">What we do</p>
          <h2>Made for moments that deserve care</h2>
          <p>
            {{ siteSettings.about_story }}
          </p>
        </div>

        <div class="story-grid">
          <div class="story-card">
            <span>01</span>
            <h3>Custom gifting</h3>
            <p>Gift hampers, snack baskets, festive trays, and themed packing made around your occasion.</p>
          </div>
          <div class="story-card">
            <span>02</span>
            <h3>Festive craft work</h3>
            <p>Decorated potlis, pooja pieces, floral details, and handmade decor for family functions.</p>
          </div>
          <div class="story-card">
            <span>03</span>
            <h3>Direct confirmation</h3>
            <p>Orders are discussed on WhatsApp so color, budget, availability, and delivery stay clear.</p>
          </div>
        </div>
      </section>

      <section class="contact-section" v-reveal>
        <div class="container contact-inner">
          <div>
            <p class="about-label">Contact</p>
            <h2>Have an idea for a gift?</h2>
            <p>Share the occasion, budget, preferred colors, and delivery date. {{ siteSettings.owner_name }} will confirm what can be made.</p>
          </div>
          <div class="contact-actions">
            <a :href="whatsAppLink('Namaste Laxmi ji,\n\nI saw your website and want to place a custom handmade order.\n\nPlease help me with design options, budget, delivery timing, and what details you need from me.')" target="_blank" rel="noopener" class="contact-btn primary" @click="trackAboutWhatsApp('about_place_order')">
              Place Order
            </a>
            <a :href="whatsAppLink('Namaste Laxmi ji,\n\nI saw your About Us page and have an enquiry about handmade gifts.\n\nPlease share available designs, customization options, pricing, and delivery timing.')" target="_blank" rel="noopener" class="contact-btn outline" @click="trackAboutWhatsApp('about_enquiry')">
              Enquiry
            </a>
          </div>
        </div>
      </section>
    </main>

    <footer class="footer">
      <div class="container footer-inner">
        <div class="footer-brand">
          <span class="footer-name">{{ shopName }}</span>
          <span class="footer-tagline">Handmade gifts, festive craft work, and custom celebration pieces.</span>
        </div>
        <div class="footer-links">
          <RouterLink to="/">Shop</RouterLink>
          <RouterLink to="/gallery">Gallery</RouterLink>
          <a :href="whatsAppLink('Namaste Laxmi ji,\n\nI saw your About Us page and want to discuss a handmade order.\n\nPlease share design options, pricing, and delivery timing.')" target="_blank" rel="noopener" @click="trackAboutWhatsApp('about_footer_whatsapp')">WhatsApp</a>
          <a :href="`tel:${ownerPhone}`" class="footer-contact-link">
            <span class="footer-icon phone" aria-hidden="true"></span>{{ displayPhone }}
          </a>
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
import { computed, onMounted, reactive } from 'vue'
import { supabase } from '../lib/supabase.js'
import { makeWhatsAppLink, trackEvent } from '../lib/analytics.js'

const shopName = import.meta.env.VITE_SHOP_NAME || 'Laxmi Creations'
const currentYear = new Date().getFullYear()
const siteSettings = reactive({
  shop_name: 'Laxmi Creations',
  owner_name: 'Laxmi Gupta',
  owner_phone: '+918793662673',
  owner_email: 'laxmigupta8888@gmail.com',
  owner_instagram: 'laxmi_creations',
  owner_photo_url: '',
  about_heading: 'Handmade gifts crafted by Laxmi Gupta',
  about_intro: 'Laxmi Creations is a small handmade craft studio for thoughtful gifting, festive hampers, chocolate garlands, decorated trays, potli favors, and custom celebration pieces.',
  about_story: 'Every order is handled personally, from choosing the color theme to arranging the final packing. The goal is simple: make gifting feel warm, beautiful, and easy for families who want something more personal than a ready-made store item.'
})

const ownerPhone = computed(() => siteSettings.owner_phone || '+918793662673')
const ownerEmail = computed(() => siteSettings.owner_email || 'laxmigupta8888@gmail.com')
const displayPhone = computed(() => ownerPhone.value.replace(/^(\+91)(\d{5})(\d{5})$/, '$1 $2 $3'))
const instagramHandle = computed(() => cleanHandle(siteSettings.owner_instagram || 'laxmi_creations'))
const instagramLink = computed(() => `https://www.instagram.com/${instagramHandle.value.replace('@', '')}`)

function whatsAppLink(message) {
  return makeWhatsAppLink(message)
}

function trackAboutWhatsApp(source) {
  trackEvent('whatsapp_click', { source, page_path: '/about' })
}

function cleanHandle(value) {
  const handle = String(value || '').trim().replace(/^https?:\/\/(www\.)?instagram\.com\//, '').replace(/\/$/, '')
  return handle.startsWith('@') ? handle : `@${handle}`
}

onMounted(loadSiteSettings)

async function loadSiteSettings() {
  const { data, error } = await supabase.from('site_settings').select('*').eq('id', 'about').maybeSingle()
  if (!error && data) Object.assign(siteSettings, data)
}
</script>

<style scoped>
.about-page {
  min-height: 100vh;
  background:
    radial-gradient(circle at 10% 8%, rgba(184, 92, 56, 0.12), transparent 28rem),
    linear-gradient(180deg, #fffaf4 0%, #f8efe5 55%, #fffaf4 100%);
}

.about-nav {
  position: sticky;
  top: 0;
  z-index: 20;
  border-bottom: 1px solid #eadfd2;
  background: rgba(255, 250, 244, 0.96);
  backdrop-filter: blur(14px);
}

.about-nav-inner,
.about-links,
.about-actions {
  display: flex;
  align-items: center;
  gap: 12px;
}

.about-nav-inner {
  justify-content: space-between;
  padding: 16px 0;
}

.about-brand {
  display: grid;
  gap: 2px;
}

.about-brand-name {
  color: #241f1a;
  font-size: 21px;
  font-weight: 900;
}

.about-brand-sub {
  color: #77695f;
  font-size: 12px;
  font-weight: 800;
  letter-spacing: 0.1em;
  text-transform: uppercase;
}

.about-link {
  border: 1px solid #d8c8b8;
  border-radius: 999px;
  padding: 8px 14px;
  background: #ffffff;
  color: #261f1a;
  font-weight: 850;
}

.about-hero {
  padding: 68px 0 54px;
  border-bottom: 1px solid #eadfd2;
}

.about-hero-inner {
  display: grid;
  grid-template-columns: minmax(0, 1fr) minmax(320px, 420px);
  gap: 48px;
  align-items: center;
}

.about-label {
  margin: 0 0 10px;
  color: #79401f;
  font-size: 12px;
  font-weight: 900;
  letter-spacing: 0.12em;
  text-transform: uppercase;
}

.about-copy h1 {
  max-width: 680px;
  margin: 0 0 18px;
  color: #1f1a16;
  font-size: clamp(42px, 7vw, 76px);
  line-height: 0.98;
}

.about-copy,
.owner-card,
.story-card,
.contact-btn {
  animation: riseIn 560ms ease both;
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

.about-lead {
  max-width: 620px;
  margin-bottom: 26px;
  color: #6f6258;
  font-size: 18px;
  line-height: 1.75;
}

.about-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-height: 46px;
  border: 1px solid transparent;
  border-radius: 999px;
  padding: 12px 18px;
  font-weight: 900;
}

.about-btn.primary {
  background: #1f9d57;
  color: #ffffff;
}

.about-btn.outline {
  border-color: #d8c8b8;
  background: #ffffff;
  color: #261f1a;
}

.owner-card {
  overflow: hidden;
  border: 1px solid #eadfd2;
  border-radius: 28px;
  background: rgba(255, 253, 248, 0.9);
  box-shadow: 0 24px 64px rgba(65, 42, 24, 0.14);
}

.owner-card.compact {
  display: grid;
  grid-template-columns: 132px 1fr;
}

.owner-card.compact .owner-photo-placeholder {
  min-height: auto;
}

.owner-photo-placeholder {
  display: grid;
  place-items: center;
  min-height: 380px;
  padding: 28px;
  background:
    linear-gradient(135deg, rgba(168, 95, 51, 0.12), rgba(255, 243, 228, 0.92)),
    #fff3e4;
  color: #79401f;
  text-align: center;
}

.owner-photo-placeholder img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.owner-photo-placeholder span {
  display: grid;
  place-items: center;
  width: 92px;
  height: 92px;
  margin-bottom: 12px;
  border: 1px dashed #c9a84c;
  border-radius: 999px;
  background: #ffffff;
  font-weight: 900;
}

.owner-photo-placeholder p {
  max-width: 220px;
  margin: 0;
  color: #77695f;
  font-size: 14px;
}

.owner-info {
  padding: 22px;
}

.owner-info span,
.story-card span,
.owner-info h2,
.story-card h2,
.contact-inner h2 {
  margin: 6px 0 10px;
  color: #241f1a;
  font-size: clamp(30px, 4vw, 44px);
}

.owner-info p,
.story-card p,
.contact-inner p {
  margin: 0;
  color: #6f6258;
  line-height: 1.7;
}

.about-story {
  padding: 54px 0;
}

.story-card {
  border: 1px solid #eadfd2;
  border-radius: 22px;
  padding: 24px;
  background: rgba(255, 255, 255, 0.84);
  box-shadow: 0 16px 40px rgba(65, 42, 24, 0.08);
}

.main-story {
  margin-bottom: 18px;
}

.story-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 18px;
}

.story-card h3 {
  margin: 8px 0 8px;
  color: #261f1a;
  font-size: 20px;
}

.contact-section {
  padding: 54px 0 64px;
  background:
    radial-gradient(circle at 86% 18%, rgba(31, 157, 87, 0.16), transparent 24rem),
    #261f1a;
}

.contact-inner {
  display: grid;
  grid-template-columns: minmax(0, 0.8fr) minmax(320px, 1fr);
  gap: 34px;
  align-items: start;
}

.contact-inner h2 {
  color: #ffffff;
}

.contact-inner p {
  color: #c8bdb3;
}

.contact-actions {
  display: flex;
  justify-content: flex-end;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
}

.contact-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-height: 50px;
  border: 1px solid rgba(255, 255, 255, 0.18);
  border-radius: 999px;
  padding: 0 24px;
  color: #ffffff;
  font-weight: 900;
  transition: transform 160ms ease, border-color 160ms ease, background 160ms ease;
}

.contact-btn:hover {
  border-color: rgba(255, 255, 255, 0.22);
  transform: translateY(-1px);
}

.contact-btn.primary {
  background: #1f9d57;
  border-color: #1f9d57;
}

.contact-btn.primary:hover {
  background: #178f52;
}

.contact-btn.outline {
  background: transparent;
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

.footer-icon.phone {
  -webkit-mask-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 24 24' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M6.6 10.8c1.5 3 3.9 5.4 6.6 6.6l2.2-2.2c.3-.3.8-.4 1.2-.2 1.3.4 2.6.6 4 .6.7 0 1.2.5 1.2 1.2v3.5c0 .7-.5 1.2-1.2 1.2C10.5 21.5 2.5 13.5 2.5 3.4c0-.7.5-1.2 1.2-1.2h3.5c.7 0 1.2.5 1.2 1.2 0 1.4.2 2.8.6 4 .1.4 0 .8-.3 1.1l-2.1 2.3Z'/%3E%3C/svg%3E");
  mask-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 24 24' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M6.6 10.8c1.5 3 3.9 5.4 6.6 6.6l2.2-2.2c.3-.3.8-.4 1.2-.2 1.3.4 2.6.6 4 .6.7 0 1.2.5 1.2 1.2v3.5c0 .7-.5 1.2-1.2 1.2C10.5 21.5 2.5 13.5 2.5 3.4c0-.7.5-1.2 1.2-1.2h3.5c.7 0 1.2.5 1.2 1.2 0 1.4.2 2.8.6 4 .1.4 0 .8-.3 1.1l-2.1 2.3Z'/%3E%3C/svg%3E");
}

.footer-icon.instagram {
  -webkit-mask-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 24 24' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M7.8 2h8.4A5.8 5.8 0 0 1 22 7.8v8.4a5.8 5.8 0 0 1-5.8 5.8H7.8A5.8 5.8 0 0 1 2 16.2V7.8A5.8 5.8 0 0 1 7.8 2Zm0 2A3.8 3.8 0 0 0 4 7.8v8.4A3.8 3.8 0 0 0 7.8 20h8.4a3.8 3.8 0 0 0 3.8-3.8V7.8A3.8 3.8 0 0 0 16.2 4H7.8Zm8.8 2.3a1.1 1.1 0 1 1 0 2.2 1.1 1.1 0 0 1 0-2.2ZM12 7.2a4.8 4.8 0 1 1 0 9.6 4.8 4.8 0 0 1 0-9.6Zm0 2a2.8 2.8 0 1 0 0 5.6 2.8 2.8 0 0 0 0-5.6Z'/%3E%3C/svg%3E");
  mask-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 24 24' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M7.8 2h8.4A5.8 5.8 0 0 1 22 7.8v8.4a5.8 5.8 0 0 1-5.8 5.8H7.8A5.8 5.8 0 0 1 2 16.2V7.8A5.8 5.8 0 0 1 7.8 2Zm0 2A3.8 3.8 0 0 0 4 7.8v8.4A3.8 3.8 0 0 0 7.8 20h8.4a3.8 3.8 0 0 0 3.8-3.8V7.8A3.8 3.8 0 0 0 16.2 4H7.8Zm8.8 2.3a1.1 1.1 0 1 1 0 2.2 1.1 1.1 0 0 1 0-2.2ZM12 7.2a4.8 4.8 0 1 1 0 9.6 4.8 4.8 0 0 1 0-9.6Zm0 2a2.8 2.8 0 1 0 0 5.6 2.8 2.8 0 0 0 0-5.6Z'/%3E%3C/svg%3E");
}

.footer-copy {
  margin: 16px 0 0;
  text-align: center;
}

@media (max-width: 780px) {
  .about-nav-inner,
  .about-hero-inner,
  .contact-inner {
    grid-template-columns: 1fr;
  }

  .about-nav-inner {
    display: grid;
    align-items: start;
  }

  .story-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 12px;
  }
}

@media (max-width: 560px) {
  .about-hero {
    padding: 34px 0 34px;
  }

  .about-copy h1 {
    font-size: clamp(42px, 13vw, 58px);
    line-height: 1.02;
  }

  .about-lead {
    font-size: 19px;
    line-height: 1.65;
  }

  .about-actions {
    align-items: stretch;
    flex-direction: column;
  }

  .about-actions .about-btn {
    width: 100%;
  }

  .owner-card {
    display: grid;
    grid-template-columns: 42% 1fr;
    border-radius: 22px;
  }

  .owner-photo-placeholder {
    min-height: 220px;
    padding: 16px;
  }

  .owner-photo-placeholder span {
    width: 72px;
    height: 72px;
  }

  .owner-photo-placeholder p {
    display: none;
  }

  .owner-info {
    display: flex;
    flex-direction: column;
    justify-content: center;
    padding: 18px;
  }

  .owner-info h2 {
    font-size: 28px;
  }

  .story-card {
    padding: 16px;
  }

  .story-card h2 {
    font-size: 32px;
  }

  .story-grid .story-card h3 {
    font-size: 18px;
  }

  .story-grid .story-card p {
    font-size: 14px;
    line-height: 1.55;
  }

  .story-grid .story-card:last-child {
    grid-column: 1 / -1;
  }

  .contact-section {
    padding-bottom: calc(92px + env(safe-area-inset-bottom));
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
  .about-copy,
  .owner-card,
  .story-card,
  .contact-btn {
    animation: none;
  }
}
</style>
