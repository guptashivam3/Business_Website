import { supabase } from './supabase.js'

export const OFFICIAL_WHATSAPP_PHONE = '918793662673'

function createSessionId() {
  if (typeof crypto !== 'undefined' && typeof crypto.randomUUID === 'function') {
    return crypto.randomUUID()
  }
  return `${Date.now()}-${Math.random().toString(36).slice(2)}`
}

function getSessionId() {
  if (typeof sessionStorage === 'undefined') return createSessionId()

  const existing = sessionStorage.getItem('craft_shop_session_id')
  if (existing) return existing

  const next = createSessionId()
  sessionStorage.setItem('craft_shop_session_id', next)
  return next
}

export function makeWhatsAppLink(message) {
  return `https://wa.me/${OFFICIAL_WHATSAPP_PHONE}?text=${encodeURIComponent(message)}`
}

export function orderMessage(product) {
  const name = product?.name || 'this handmade item'
  const price = product?.price ? `Rs ${Number(product.price).toFixed(2)}` : 'price to be confirmed'
  const image = product?.image_url ? `\nPhoto reference: ${product.image_url}` : ''

  return `Namaste Laxmi ji,\n\nI saw this on Laxmi Creations and would like to order it.\n\nProduct: ${name}\nPrice shown: ${price}${image}\n\nPlease confirm availability, final price, customization options, payment details, and delivery timing.`
}

export function enquiryMessage(product) {
  const name = product?.name || 'a handmade item'
  return `Namaste Laxmi ji,\n\nI have a question about ${name} from Laxmi Creations.\n\nPlease share available options, customization details, and delivery timing.`
}

export async function trackEvent(eventType, payload = {}) {
  try {
    const event = {
      event_type: eventType,
      page_path: payload.page_path || window.location.pathname,
      product_id: payload.product_id || null,
      product_name: payload.product_name || null,
      metadata: {
        session_id: getSessionId(),
        source: payload.source || null,
        title: payload.title || null,
        category: payload.category || null
      }
    }

    const { error } = await supabase.from('analytics_events').insert(event)
    if (error && !String(error.message).includes('analytics_events')) {
      console.warn('Analytics event failed:', error.message)
    }
  } catch {
    // Analytics should never block shopping or ordering.
  }
}
