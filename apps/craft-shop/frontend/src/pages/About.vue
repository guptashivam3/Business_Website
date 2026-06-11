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
              <a :href="whatsAppLink('Hi Laxmi ji, I want to discuss a handmade order.')" target="_blank" rel="noopener" class="about-btn primary">
                Message on WhatsApp
              </a>
              <RouterLink to="/gallery" class="about-btn outline">View Work</RouterLink>
            </div>
          </div>

          <div class="owner-card">
            <div class="owner-photo-placeholder">
              <img v-if="siteSettings.owner_photo_url" :src="siteSettings.owner_photo_url" :alt="siteSettings.owner_name" />
              <template v-else>
                <span>Photo</span>
                <p>Owner photo can be added here later</p>
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
          <div class="contact-cards">
            <a :href="`tel:${ownerPhone}`" class="contact-card">
              <span>Phone</span>
              <strong>{{ displayPhone }}</strong>
            </a>
            <a :href="`mailto:${ownerEmail}`" class="contact-card">
              <span>Email</span>
              <strong>{{ siteSettings.owner_email }}</strong>
            </a>
            <a :href="whatsAppLink('Hi Laxmi ji, I saw your website and want to place a custom order.')" target="_blank" rel="noopener" class="contact-card highlight">
              <span>WhatsApp</span>
              <strong>Start an order</strong>
            </a>
          </div>
        </div>
      </section>
    </main>
  </div>
</template>

<script setup>
import { computed, onMounted, reactive } from 'vue'
import { supabase } from '../lib/supabase.js'

const shopName = import.meta.env.VITE_SHOP_NAME || 'Laxmi Creations'
const siteSettings = reactive({
  shop_name: 'Laxmi Creations',
  owner_name: 'Laxmi Gupta',
  owner_phone: '+918793662673',
  owner_email: 'laxmigupta8888@gmail.com',
  owner_photo_url: '',
  about_heading: 'Handmade gifts crafted by Laxmi Gupta',
  about_intro: 'Laxmi Creations is a small handmade craft studio for thoughtful gifting, festive hampers, chocolate garlands, decorated trays, potli favors, and custom celebration pieces.',
  about_story: 'Every order is handled personally, from choosing the color theme to arranging the final packing. The goal is simple: make gifting feel warm, beautiful, and easy for families who want something more personal than a ready-made store item.'
})

const ownerPhone = computed(() => siteSettings.owner_phone || '+918793662673')
const ownerEmail = computed(() => siteSettings.owner_email || 'laxmigupta8888@gmail.com')
const displayPhone = computed(() => ownerPhone.value.replace(/^(\+91)(\d{5})(\d{5})$/, '$1 $2 $3'))

function whatsAppLink(message) {
  return `https://wa.me/${ownerPhone.value.replace('+', '')}?text=${encodeURIComponent(message)}`
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
.contact-card {
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
.contact-card span {
  color: #79401f;
  font-size: 12px;
  font-weight: 900;
  letter-spacing: 0.1em;
  text-transform: uppercase;
}

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
  background: #261f1a;
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

.contact-cards {
  display: grid;
  gap: 12px;
}

.contact-card {
  display: grid;
  gap: 5px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 18px;
  padding: 18px;
  background: rgba(255, 255, 255, 0.06);
  color: #ffffff;
}

.contact-card.highlight {
  background: #1f9d57;
}

.contact-card strong {
  overflow-wrap: anywhere;
  font-size: 18px;
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
}

@media (prefers-reduced-motion: reduce) {
  .about-copy,
  .owner-card,
  .story-card,
  .contact-card {
    animation: none;
  }
}
</style>
