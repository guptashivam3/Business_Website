<template>
  <header class="header admin-header">
    <div class="container header-row">
      <div>
        <RouterLink to="/" class="eyebrow-link">View Shop</RouterLink>
        <div class="brand">Craft Shop Admin</div>
      </div>
      <button class="btn secondary" @click="logout">Logout</button>
    </div>
  </header>

  <main class="container page-section admin-page">
    <section class="admin-hero">
      <div>
        <p class="eyebrow">Dashboard</p>
        <h1>Manage the shop in one place</h1>
        <p class="muted">Add products, upload media, and keep the gallery fresh for customers.</p>
      </div>
      <div class="button-row">
        <button class="btn" type="button" @click="openAddProduct">Add Product</button>
        <button class="btn secondary" type="button" @click="activeSection = 'gallery'">Add Gallery Work</button>
      </div>
    </section>

    <section class="stats-grid">
      <div class="stat-card">
        <span>{{ products.length }}</span>
        <p>Products</p>
      </div>
      <div class="stat-card">
        <span>{{ availableCount }}</span>
        <p>Available</p>
      </div>
      <div class="stat-card">
        <span>{{ galleryItems.length }}</span>
        <p>Gallery Items</p>
      </div>
    </section>

    <div class="admin-tabs">
      <button :class="{ active: activeSection === 'products' }" type="button" @click="activeSection = 'products'">
        Products
      </button>
      <button :class="{ active: activeSection === 'gallery' }" type="button" @click="activeSection = 'gallery'">
        Gallery
      </button>
    </div>

    <section v-if="activeSection === 'products'" class="admin-section">
      <div class="section-heading">
        <div>
          <h2>Products</h2>
          <p class="muted">Create and update items shown on the shop page.</p>
        </div>
        <button class="btn" type="button" @click="openAddProduct">Add Product</button>
      </div>

      <div v-if="showProductForm" class="panel form-panel">
        <div class="section-heading compact">
          <div>
            <h3>{{ selectedProduct.id ? 'Edit Product' : 'Add Product' }}</h3>
            <p class="muted">Upload the product photo here. The public URL is saved automatically.</p>
          </div>
        </div>
        <ProductForm :product="selectedProduct" @save="saveProduct" @cancel="closeProductForm" />
      </div>

      <div v-if="!products.length" class="empty-state large-empty">
        <h3>No products yet</h3>
        <p>Add your first product with a photo, price, and availability.</p>
        <button class="btn" type="button" @click="openAddProduct">Add First Product</button>
      </div>

      <div v-else class="admin-list">
        <article v-for="product in products" :key="product.id" class="admin-item">
          <img class="admin-thumb" :src="product.image_url || placeholder" :alt="product.name" />
          <div class="admin-item-main">
            <div class="item-title-row">
              <h3>{{ product.name }}</h3>
              <span :class="['status-pill', product.is_available ? 'ok' : 'muted-status']">
                {{ product.is_available ? 'Available' : 'Sold out' }}
              </span>
            </div>
            <p class="price">Rs {{ Number(product.price).toFixed(2) }}</p>
            <p v-if="product.description" class="muted clamp">{{ product.description }}</p>
          </div>
          <div class="button-row admin-actions">
            <button class="btn secondary" type="button" @click="editProduct(product)">Edit</button>
            <button class="btn danger" type="button" @click="deleteProduct(product.id)">Delete</button>
          </div>
        </article>
      </div>
    </section>

    <section v-else class="admin-section">
      <div class="section-heading">
        <div>
          <h2>Gallery Management</h2>
          <p class="muted">Show completed work as inspiration, not for purchase.</p>
        </div>
      </div>

      <div class="panel form-panel">
        <form class="form" @submit.prevent="saveGalleryItem">
          <div class="form-grid two-col">
            <label class="field-label">
              Title
              <input v-model="galleryForm.title" class="input" placeholder="Custom festive hamper" required />
            </label>
            <label class="field-label">
              Category
              <input v-model="galleryForm.category" class="input" placeholder="Gifts, decor, jewelry" />
            </label>
          </div>
          <label class="field-label">
            Description
            <textarea v-model="galleryForm.description" rows="3" placeholder="Short note about the completed design"></textarea>
          </label>
          <label class="upload-box">
            <span>Gallery image</span>
            <small>Upload a finished work photo.</small>
            <input type="file" accept="image/*" required @change="selectGalleryImage" />
          </label>
          <img v-if="galleryPreview" class="media-preview" :src="galleryPreview" alt="Gallery image preview" />
          <button class="btn" type="submit" :disabled="savingGallery">
            {{ savingGallery ? 'Saving...' : 'Add Gallery Item' }}
          </button>
        </form>
      </div>

      <div v-if="!galleryItems.length" class="empty-state large-empty">
        <h3>No gallery items yet</h3>
        <p>Add completed work to help customers understand your craft style.</p>
      </div>

      <div v-else class="grid gallery-admin-grid">
        <div v-for="item in galleryItems" :key="item.id" class="card">
          <img class="product-img" :src="item.image_url" :alt="item.title" />
          <div class="card-body">
            <h3>{{ item.title }}</h3>
            <p v-if="item.category" class="muted">{{ item.category }}</p>
            <p>{{ item.description }}</p>
            <p class="muted">{{ item.is_visible ? 'Visible in gallery' : 'Hidden from gallery' }}</p>
            <div class="button-row">
              <button class="btn secondary" type="button" @click="toggleGalleryVisibility(item)">
                {{ item.is_visible ? 'Hide' : 'Show' }}
              </button>
              <button class="btn danger" type="button" @click="deleteGalleryItem(item.id)">Delete</button>
            </div>
          </div>
        </div>
      </div>
    </section>
  </main>
</template>

<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from '../lib/supabase'
import ProductForm from '../components/ProductForm.vue'

const router = useRouter()
const products = ref([])
const galleryItems = ref([])
const selectedProduct = ref({})
const showProductForm = ref(false)
const activeSection = ref('products')
const galleryFile = ref(null)
const galleryPreview = ref('')
const savingGallery = ref(false)
const placeholder = 'https://placehold.co/600x600?text=Handmade'

const galleryForm = reactive({
  title: '',
  description: '',
  category: ''
})

const availableCount = computed(() => products.value.filter((product) => product.is_available).length)

onMounted(async () => {
  await loadProducts()
  await loadGalleryItems()
})

function openAddProduct() {
  selectedProduct.value = {}
  showProductForm.value = true
  activeSection.value = 'products'
}

function editProduct(product) {
  selectedProduct.value = product
  showProductForm.value = true
  activeSection.value = 'products'
}

function closeProductForm() {
  selectedProduct.value = {}
  showProductForm.value = false
}

async function loadProducts() {
  const { data, error } = await supabase
    .from('products')
    .select('*')
    .order('created_at', { ascending: false })

  if (error) console.error(error)
  products.value = data || []
}

async function saveProduct(product) {
  const payload = {
    name: product.name,
    slug: product.slug,
    description: product.description,
    price: product.price,
    category: product.category,
    image_url: product.image_url,
    video_url: product.video_url,
    is_available: product.is_available,
    is_featured: product.is_featured,
    updated_at: new Date().toISOString()
  }

  const query = product.id
    ? supabase.from('products').update(payload).eq('id', product.id)
    : supabase.from('products').insert(payload)

  const { error } = await query
  if (error) {
    alert(error.message)
    return
  }

  closeProductForm()
  await loadProducts()
}

async function loadGalleryItems() {
  const { data, error } = await supabase
    .from('gallery_items')
    .select('*')
    .order('created_at', { ascending: false })

  if (error) {
    console.error(error)
    galleryItems.value = []
    return
  }

  galleryItems.value = data || []
}

function selectGalleryImage(event) {
  const [file] = event.target.files || []
  galleryFile.value = file || null
  galleryPreview.value = file ? URL.createObjectURL(file) : ''
}

function galleryPath(file) {
  const extension = file.name.split('.').pop() || 'jpg'
  const randomId = Math.random().toString(36).slice(2, 10)
  return `gallery/${Date.now()}-${randomId}.${extension}`
}

async function uploadGalleryImage(file) {
  const filePath = galleryPath(file)
  const { error } = await supabase.storage.from('product-media').upload(filePath, file)

  if (error) throw error

  const { data } = supabase.storage.from('product-media').getPublicUrl(filePath)
  return data.publicUrl
}

async function saveGalleryItem() {
  if (!galleryFile.value) {
    alert('Please choose a gallery image.')
    return
  }

  savingGallery.value = true

  try {
    const imageUrl = await uploadGalleryImage(galleryFile.value)
    const { error } = await supabase.from('gallery_items').insert({
      title: galleryForm.title,
      description: galleryForm.description,
      category: galleryForm.category,
      image_url: imageUrl,
      is_visible: true
    })

    if (error) throw error

    galleryForm.title = ''
    galleryForm.description = ''
    galleryForm.category = ''
    galleryFile.value = null
    galleryPreview.value = ''
    await loadGalleryItems()
  } catch (error) {
    alert(error.message)
  } finally {
    savingGallery.value = false
  }
}

async function toggleGalleryVisibility(item) {
  const { error } = await supabase
    .from('gallery_items')
    .update({ is_visible: !item.is_visible })
    .eq('id', item.id)

  if (error) alert(error.message)
  await loadGalleryItems()
}

async function deleteGalleryItem(id) {
  if (!confirm('Delete this gallery item?')) return
  const { error } = await supabase.from('gallery_items').delete().eq('id', id)
  if (error) alert(error.message)
  await loadGalleryItems()
}

async function deleteProduct(id) {
  if (!confirm('Delete this product?')) return
  const { error } = await supabase.from('products').delete().eq('id', id)
  if (error) alert(error.message)
  await loadProducts()
}

async function logout() {
  await supabase.auth.signOut()
  router.push('/admin/login')
}
</script>
