<template>
  <div class="about-page">
    <div class="site-marquee">
      <div class="site-marquee-track">
        <span>Meet Laxmi Gupta, founder and maker</span>
        <span>Custom handmade gifting for celebrations</span>
        <span>Contact directly for ideas, budget and timing</span>
      </div>
    </div>

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
            <h1>Handmade gifts crafted by Laxmi Gupta</h1>
            <p class="about-lead">
              Laxmi Creations is a small handmade craft studio for thoughtful gifting, festive hampers,
              chocolate garlands, decorated trays, potli favors, and custom celebration pieces.
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
              <span>Photo</span>
              <p>Owner photo can be added here later</p>
            </div>
            <div class="owner-info">
              <span>Founder & Maker</span>
              <h2>Laxmi Gupta</h2>
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
            Every order is handled personally, from choosing the color theme to arranging the final packing.
            The goal is simple: make gifting feel warm, beautiful, and easy for families who want something
            more personal than a ready-made store item.
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
            <p>Share the occasion, budget, preferred colors, and delivery date. Laxmi will confirm what can be made.</p>
          </div>
          <div class="contact-cards">
            <a :href="`tel:${ownerPhone}`" class="contact-card">
              <span>Phone</span>
              <strong>+91 8793662673</strong>
            </a>
            <a :href="`mailto:${ownerEmail}`" class="contact-card">
              <span>Email</span>
              <strong>{{ ownerEmail }}</strong>
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
const shopName = import.meta.env.VITE_SHOP_NAME || 'Laxmi Creations'
const ownerPhone = '+918793662673'
const ownerEmail = 'laxmigupta8888@gmail.com'

function whatsAppLink(message) {
  return `https://wa.me/${ownerPhone.replace('+', '')}?text=${encodeURIComponent(message)}`
}
</script>

<style scoped>
.about-page {
  min-height: 100vh;
  background:
    radial-gradient(circle at 10% 8%, rgba(184, 92, 56, 0.12), transparent 28rem),
    linear-gradient(180deg, #fffaf4 0%, #f8efe5 55%, #fffaf4 100%);
}

.site-marquee {
  overflow: hidden;
  min-height: 38px;
  background: #261f1a;
  color: #f8efe5;
  font-size: 13px;
  font-weight: 800;
  white-space: nowrap;
}

.site-marquee-track {
  display: inline-flex;
  gap: 42px;
  min-width: max-content;
  padding: 8px 0;
  animation: marquee 24s linear infinite;
}

.site-marquee-track span {
  position: relative;
}

.site-marquee-track span::after {
  content: "";
  position: absolute;
  top: 50%;
  right: -24px;
  width: 5px;
  height: 5px;
  border-radius: 99px;
  background: #c9a84c;
  transform: translateY(-50%);
}

@keyframes marquee {
  from {
    transform: translateX(100vw);
  }

  to {
    transform: translateX(-100%);
  }
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
    grid-template-columns: 1fr;
  }
}

@media (max-width: 560px) {
  .about-hero {
    padding: 38px 0 36px;
  }

  .about-actions {
    align-items: stretch;
    flex-direction: column;
  }

  .owner-photo-placeholder {
    min-height: 300px;
  }
}

@media (prefers-reduced-motion: reduce) {
  .site-marquee-track,
  .about-copy,
  .owner-card,
  .story-card,
  .contact-card {
    animation: none;
  }
}
</style>
