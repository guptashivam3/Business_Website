<template>
  <div class="admin-page">
    <header class="admin-header">
      <div class="admin-header-inner">
        <div class="admin-brand">
          <span class="admin-brand-icon">LC</span>
          <div>
            <p class="admin-brand-name">{{ shopName }}</p>
            <p class="admin-brand-role">Admin Dashboard</p>
          </div>
        </div>
        <div class="admin-header-actions">
          <RouterLink to="/" class="admin-btn outline small" target="_blank">View Shop</RouterLink>
          <button class="admin-btn ghost small" type="button" @click="logout">Logout</button>
        </div>
      </div>
    </header>

    <main class="admin-body container">
      <section class="admin-overview" v-reveal>
        <div class="overview-card">
          <span>Total Products</span>
          <strong>{{ products.length }}</strong>
          <p>{{ availableProducts }} available</p>
        </div>
        <div class="overview-card">
          <span>Featured</span>
          <strong>{{ featuredProducts }}</strong>
          <p>Shown in premium sections</p>
        </div>
        <div class="overview-card">
          <span>Sold Out</span>
          <strong>{{ soldOutProducts }}</strong>
          <p>Hidden from ordering priority</p>
        </div>
        <div class="overview-card">
          <span>Gallery</span>
          <strong>{{ visibleGalleryItems }}</strong>
          <p>{{ hiddenGalleryItems }} hidden</p>
        </div>
      </section>

      <div class="admin-tabs">
        <button class="admin-tab" :class="{ active: tab === 'products' }" type="button" @click="tab = 'products'">
          Products <span class="tab-count">{{ products.length }}</span>
        </button>
        <button class="admin-tab" :class="{ active: tab === 'gallery' }" type="button" @click="tab = 'gallery'">
          Gallery <span class="tab-count">{{ galleryItems.length }}</span>
        </button>
      </div>

      <section v-if="tab === 'products'" class="tab-content" v-reveal="{ delay: 80 }">
        <div class="tab-header">
          <div>
            <h2 class="tab-title">Manage Products</h2>
            <p class="tab-sub">Add products, upload media, and update availability.</p>
          </div>
          <div class="tab-actions">
            <RouterLink to="/" class="admin-btn outline small" target="_blank">Preview Shop</RouterLink>
            <button class="admin-btn primary small" type="button" @click="openProductForm(null)">Add Product</button>
          </div>
        </div>

        <div class="admin-tools">
          <label class="admin-search">
            <span>Search Products</span>
            <input v-model.trim="productSearch" type="search" placeholder="Search by name, category, description..." />
          </label>
          <select v-model="productFilter" class="admin-filter">
            <option value="all">All products</option>
            <option value="available">Available only</option>
            <option value="sold">Sold out only</option>
            <option value="featured">Featured only</option>
            <option value="missingImage">Missing image</option>
          </select>
        </div>

        <div v-if="loadingProducts" class="loading-wrap"><div class="spinner"></div></div>

        <div v-else-if="products.length === 0" class="empty-state">
          <div class="empty-state-icon">New</div>
          <h3>No products yet</h3>
          <p>Add your first product so customers can see and order it.</p>
          <button class="admin-btn primary" type="button" @click="openProductForm(null)">Add First Product</button>
        </div>

        <div v-else-if="filteredProducts.length === 0" class="empty-state compact">
          <div class="empty-state-icon">Find</div>
          <h3>No matching products</h3>
          <p>Try a different search or filter.</p>
        </div>

        <div v-else class="products-table">
          <div class="products-table-head">
            <span>Product</span>
            <span>Price</span>
            <span>Status</span>
            <span>Actions</span>
          </div>
          <div v-for="product in filteredProducts" :key="product.id" class="products-row">
            <div class="products-row-info">
              <div class="products-row-img-wrap">
                <img v-if="product.image_url" :src="product.image_url" :alt="product.name" class="products-row-img" />
                <span v-else class="products-row-img-placeholder">Image</span>
              </div>
              <div>
                <p class="products-row-name">{{ product.name }}</p>
                <p class="products-row-cat">{{ product.category || 'Uncategorized' }}</p>
              </div>
            </div>
            <div class="products-row-price">Rs {{ Number(product.price).toFixed(2) }}</div>
            <div class="products-row-status">
              <span :class="product.is_available ? 'badge available' : 'badge sold'">
                {{ product.is_available ? 'Available' : 'Sold Out' }}
              </span>
              <span v-if="product.is_featured" class="badge featured">Featured</span>
            </div>
            <div class="products-row-actions">
              <button class="admin-btn outline small" type="button" @click="openProductForm(product)">Edit</button>
              <button class="admin-btn warning small" type="button" @click="toggleAvailable(product)">
                {{ product.is_available ? 'Mark Sold Out' : 'Mark Available' }}
              </button>
              <button class="admin-btn danger small" type="button" @click="confirmDelete(product)">Delete</button>
            </div>
          </div>
        </div>
      </section>

      <section v-if="tab === 'gallery'" class="tab-content" v-reveal="{ delay: 80 }">
        <div class="tab-header">
          <div>
            <h2 class="tab-title">Manage Gallery</h2>
            <p class="tab-sub">Show completed work as inspiration for custom orders.</p>
          </div>
          <div class="tab-actions">
            <RouterLink to="/gallery" class="admin-btn outline small" target="_blank">Preview Gallery</RouterLink>
            <button class="admin-btn primary small" type="button" @click="openGalleryForm(null)">Add Item</button>
          </div>
        </div>

        <div class="admin-tools">
          <label class="admin-search">
            <span>Search Gallery</span>
            <input v-model.trim="gallerySearch" type="search" placeholder="Search by title, category, description..." />
          </label>
          <select v-model="galleryFilter" class="admin-filter">
            <option value="all">All gallery items</option>
            <option value="visible">Visible only</option>
            <option value="hidden">Hidden only</option>
          </select>
        </div>

        <div v-if="loadingGallery" class="loading-wrap"><div class="spinner"></div></div>

        <div v-else-if="galleryItems.length === 0" class="empty-state">
          <div class="empty-state-icon">Work</div>
          <h3>Gallery is empty</h3>
          <p>Add photos of completed work to inspire customers.</p>
          <button class="admin-btn primary" type="button" @click="openGalleryForm(null)">Add First Item</button>
        </div>

        <div v-else-if="filteredGalleryItems.length === 0" class="empty-state compact">
          <div class="empty-state-icon">Find</div>
          <h3>No matching gallery items</h3>
          <p>Try a different search or filter.</p>
        </div>

        <div v-else class="gallery-admin-grid">
          <article v-for="item in filteredGalleryItems" :key="item.id" class="gallery-admin-card" :class="{ hidden: !item.is_visible }">
            <div class="gallery-admin-img-wrap">
              <img :src="item.image_url" :alt="item.title" class="gallery-admin-img" />
              <div v-if="!item.is_visible" class="gallery-hidden-label">Hidden</div>
            </div>
            <div class="gallery-admin-body">
              <p class="gallery-admin-cat">{{ item.category || 'Gallery' }}</p>
              <p class="gallery-admin-name">{{ item.title }}</p>
            </div>
            <div class="gallery-admin-actions">
              <button class="admin-btn outline small" type="button" @click="openGalleryForm(item)">Edit</button>
              <button class="admin-btn outline small" type="button" @click="toggleGalleryVisible(item)">
                {{ item.is_visible ? 'Hide' : 'Show' }}
              </button>
              <button class="admin-btn danger small" type="button" @click="deleteGalleryItem(item)">Delete</button>
            </div>
          </article>
        </div>
      </section>
    </main>

    <div v-if="showProductForm" class="modal-overlay" @click.self="closeProductForm">
      <div class="modal">
        <div class="modal-header">
          <h3 class="modal-title">{{ editingProduct ? 'Edit Product' : 'Add New Product' }}</h3>
          <button class="modal-close" type="button" @click="closeProductForm">Close</button>
        </div>
        <div class="modal-body">
          <div class="form-grid">
            <div class="field">
              <label>Product Name *</label>
              <input v-model="productForm.name" required placeholder="Handmade wall hanging" />
            </div>
            <div class="field">
              <label>Price (Rs) *</label>
              <input v-model.number="productForm.price" type="number" min="0" required placeholder="299" />
            </div>
            <div class="field full">
              <label>Description</label>
              <textarea v-model="productForm.description" rows="3" placeholder="Describe materials, size, and care instructions"></textarea>
            </div>
            <div class="field">
              <label>Category</label>
              <input v-model="productForm.category" placeholder="Jewelry, decor, gifts" />
            </div>
            <div class="field">
              <label>Availability</label>
              <select v-model="productForm.is_available">
                <option :value="true">Available</option>
                <option :value="false">Sold Out</option>
              </select>
            </div>
            <div class="field full">
              <label>Product Photo</label>
              <div class="upload-zone" :class="{ 'has-file': productForm.image_url }" @click="triggerUpload('image')">
                <input ref="imageInput" type="file" accept="image/*" @change="uploadFile($event, 'image')" />
                <div v-if="productForm.image_url" class="upload-preview">
                  <img :src="productForm.image_url" alt="Product preview" />
                  <button type="button" class="upload-remove" @click.stop="productForm.image_url = ''">Remove</button>
                </div>
                <div v-else class="upload-placeholder">
                  <strong>{{ uploadingImage ? 'Uploading...' : 'Click to upload photo' }}</strong>
                  <span>JPG or PNG recommended</span>
                </div>
              </div>
            </div>
            <div class="field full">
              <label>Product Video optional</label>
              <div class="upload-zone" :class="{ 'has-file': productForm.video_url }" @click="triggerUpload('video')">
                <input ref="videoInput" type="file" accept="video/*" @change="uploadFile($event, 'video')" />
                <div v-if="productForm.video_url" class="upload-preview">
                  <video :src="productForm.video_url" controls></video>
                  <button type="button" class="upload-remove" @click.stop="productForm.video_url = ''">Remove</button>
                </div>
                <div v-else class="upload-placeholder">
                  <strong>{{ uploadingVideo ? 'Uploading...' : 'Click to upload video' }}</strong>
                  <span>Short detail video, optional</span>
                </div>
              </div>
            </div>
            <div class="field full">
              <label class="toggle-label">
                <input v-model="productForm.is_featured" type="checkbox" />
                <span>Mark as Featured</span>
              </label>
            </div>
          </div>
          <p v-if="formError" class="form-error">{{ formError }}</p>
        </div>
        <div class="modal-footer">
          <button class="admin-btn outline" type="button" @click="closeProductForm">Cancel</button>
          <button class="admin-btn primary" type="button" :disabled="saving" @click="saveProduct">
            {{ saving ? 'Saving...' : editingProduct ? 'Save Changes' : 'Add Product' }}
          </button>
        </div>
      </div>
    </div>

    <div v-if="showGalleryForm" class="modal-overlay" @click.self="closeGalleryForm">
      <div class="modal">
        <div class="modal-header">
          <h3 class="modal-title">{{ editingGallery ? 'Edit Gallery Item' : 'Add Gallery Item' }}</h3>
          <button class="modal-close" type="button" @click="closeGalleryForm">Close</button>
        </div>
        <div class="modal-body">
          <div class="form-grid">
            <div class="field">
              <label>Title *</label>
              <input v-model="galleryForm.title" required placeholder="Custom festive hamper" />
            </div>
            <div class="field">
              <label>Category</label>
              <input v-model="galleryForm.category" placeholder="Jewelry, home decor, gifts" />
            </div>
            <div class="field full">
              <label>Description</label>
              <textarea v-model="galleryForm.description" rows="2" placeholder="Brief description of the piece"></textarea>
            </div>
            <div class="field full">
              <label>Photo *</label>
              <div class="upload-zone" :class="{ 'has-file': galleryForm.image_url }" @click="triggerUpload('gallery')">
                <input ref="galleryInput" type="file" accept="image/*" @change="uploadFile($event, 'gallery')" />
                <div v-if="galleryForm.image_url" class="upload-preview">
                  <img :src="galleryForm.image_url" alt="Gallery preview" />
                  <button type="button" class="upload-remove" @click.stop="galleryForm.image_url = ''">Remove</button>
                </div>
                <div v-else class="upload-placeholder">
                  <strong>{{ uploadingGallery ? 'Uploading...' : 'Click to upload photo' }}</strong>
                  <span>Finished work photo</span>
                </div>
              </div>
            </div>
            <div class="field full">
              <label class="toggle-label">
                <input v-model="galleryForm.is_visible" type="checkbox" />
                <span>Show in gallery</span>
              </label>
            </div>
          </div>
          <p v-if="formError" class="form-error">{{ formError }}</p>
        </div>
        <div class="modal-footer">
          <button class="admin-btn outline" type="button" @click="closeGalleryForm">Cancel</button>
          <button class="admin-btn primary" type="button" :disabled="saving" @click="saveGalleryItem">
            {{ saving ? 'Saving...' : editingGallery ? 'Save Changes' : 'Add to Gallery' }}
          </button>
        </div>
      </div>
    </div>

    <div v-if="deleteTarget" class="modal-overlay" @click.self="deleteTarget = null">
      <div class="modal modal-sm">
        <div class="modal-header">
          <h3 class="modal-title">Delete Product?</h3>
          <button class="modal-close" type="button" @click="deleteTarget = null">Close</button>
        </div>
        <div class="modal-body">
          <p class="confirm-text">Delete <strong>{{ deleteTarget.name }}</strong>? This cannot be undone.</p>
        </div>
        <div class="modal-footer">
          <button class="admin-btn outline" type="button" @click="deleteTarget = null">Cancel</button>
          <button class="admin-btn danger" type="button" :disabled="saving" @click="deleteProduct">
            {{ saving ? 'Deleting...' : 'Yes, Delete' }}
          </button>
        </div>
      </div>
    </div>

    <div v-if="toast" class="toast" :class="toast.type">{{ toast.message }}</div>
  </div>
</template>

<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from '../lib/supabase.js'

const router = useRouter()
const shopName = import.meta.env.VITE_SHOP_NAME || 'Handmade Craft Shop'
const tab = ref('products')

const products = ref([])
const galleryItems = ref([])
const loadingProducts = ref(true)
const loadingGallery = ref(true)
const productSearch = ref('')
const productFilter = ref('all')
const gallerySearch = ref('')
const galleryFilter = ref('all')

const showProductForm = ref(false)
const editingProduct = ref(null)
const productForm = reactive(defaultProductForm())

const showGalleryForm = ref(false)
const editingGallery = ref(null)
const galleryForm = reactive(defaultGalleryForm())

const imageInput = ref(null)
const videoInput = ref(null)
const galleryInput = ref(null)
const uploadingImage = ref(false)
const uploadingVideo = ref(false)
const uploadingGallery = ref(false)

const saving = ref(false)
const formError = ref('')
const deleteTarget = ref(null)
const toast = ref(null)

const availableProducts = computed(() => products.value.filter((product) => product.is_available).length)
const soldOutProducts = computed(() => products.value.filter((product) => !product.is_available).length)
const featuredProducts = computed(() => products.value.filter((product) => product.is_featured).length)
const visibleGalleryItems = computed(() => galleryItems.value.filter((item) => item.is_visible).length)
const hiddenGalleryItems = computed(() => galleryItems.value.filter((item) => !item.is_visible).length)

const filteredProducts = computed(() => {
  const query = productSearch.value.toLowerCase()
  return products.value.filter((product) => {
    const searchable = `${product.name} ${product.category || ''} ${product.description || ''}`.toLowerCase()
    const matchesSearch = !query || searchable.includes(query)
    const matchesFilter =
      productFilter.value === 'all' ||
      (productFilter.value === 'available' && product.is_available) ||
      (productFilter.value === 'sold' && !product.is_available) ||
      (productFilter.value === 'featured' && product.is_featured) ||
      (productFilter.value === 'missingImage' && !product.image_url)

    return matchesSearch && matchesFilter
  })
})

const filteredGalleryItems = computed(() => {
  const query = gallerySearch.value.toLowerCase()
  return galleryItems.value.filter((item) => {
    const searchable = `${item.title} ${item.category || ''} ${item.description || ''}`.toLowerCase()
    const matchesSearch = !query || searchable.includes(query)
    const matchesFilter =
      galleryFilter.value === 'all' ||
      (galleryFilter.value === 'visible' && item.is_visible) ||
      (galleryFilter.value === 'hidden' && !item.is_visible)

    return matchesSearch && matchesFilter
  })
})

function defaultProductForm() {
  return {
    id: null,
    name: '',
    slug: '',
    description: '',
    price: '',
    category: '',
    image_url: '',
    video_url: '',
    is_available: true,
    is_featured: false
  }
}

function defaultGalleryForm() {
  return {
    id: null,
    title: '',
    category: '',
    description: '',
    image_url: '',
    is_visible: true
  }
}

function resetReactive(target, source) {
  Object.keys(target).forEach((key) => delete target[key])
  Object.assign(target, source)
}

function showToast(message, type = 'success') {
  toast.value = { message, type }
  setTimeout(() => {
    toast.value = null
  }, 3000)
}

function slugify(value) {
  return value
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/(^-|-$)/g, '')
}

async function logout() {
  await supabase.auth.signOut()
  router.push('/admin/login')
}

function openProductForm(product) {
  editingProduct.value = product
  resetReactive(productForm, product ? { ...defaultProductForm(), ...product } : defaultProductForm())
  formError.value = ''
  showProductForm.value = true
}

function closeProductForm() {
  showProductForm.value = false
  editingProduct.value = null
  formError.value = ''
}

function productPayload(includeCategory = true) {
  const payload = {
    name: productForm.name,
    slug: slugify(productForm.name),
    description: productForm.description,
    price: Number(productForm.price || 0),
    image_url: productForm.image_url,
    video_url: productForm.video_url,
    is_available: productForm.is_available,
    is_featured: productForm.is_featured,
    updated_at: new Date().toISOString()
  }

  if (includeCategory) payload.category = productForm.category
  return payload
}

function isMissingCategoryError(error) {
  return error?.message?.includes("'category' column")
}

async function saveProduct() {
  if (!productForm.name || productForm.price === '') {
    formError.value = 'Name and price are required.'
    return
  }

  saving.value = true
  formError.value = ''

  let error
  const payload = productPayload(true)

  if (editingProduct.value) {
    const result = await supabase.from('products').update(payload).eq('id', editingProduct.value.id)
    error = result.error
  } else {
    const result = await supabase.from('products').insert([payload])
    error = result.error
  }

  if (isMissingCategoryError(error)) {
    const fallbackPayload = productPayload(false)
    const fallbackResult = editingProduct.value
      ? await supabase.from('products').update(fallbackPayload).eq('id', editingProduct.value.id)
      : await supabase.from('products').insert([fallbackPayload])
    error = fallbackResult.error
  }

  saving.value = false

  if (error) {
    formError.value = error.message
    return
  }

  const wasEditing = Boolean(editingProduct.value)
  closeProductForm()
  showToast(wasEditing ? 'Product updated.' : 'Product added.')
  await loadProducts()
}

async function toggleAvailable(product) {
  const { error } = await supabase
    .from('products')
    .update({ is_available: !product.is_available })
    .eq('id', product.id)

  if (error) {
    showToast(error.message, 'error')
    return
  }

  product.is_available = !product.is_available
  showToast(product.is_available ? 'Marked as available.' : 'Marked as sold out.')
}

function confirmDelete(product) {
  deleteTarget.value = product
}

async function deleteProduct() {
  if (!deleteTarget.value) return
  saving.value = true
  const { error } = await supabase.from('products').delete().eq('id', deleteTarget.value.id)
  saving.value = false

  if (error) {
    showToast(error.message, 'error')
    return
  }

  deleteTarget.value = null
  showToast('Product deleted.')
  await loadProducts()
}

function openGalleryForm(item) {
  editingGallery.value = item
  resetReactive(galleryForm, item ? { ...defaultGalleryForm(), ...item } : defaultGalleryForm())
  formError.value = ''
  showGalleryForm.value = true
}

function closeGalleryForm() {
  showGalleryForm.value = false
  editingGallery.value = null
  formError.value = ''
}

async function saveGalleryItem() {
  if (!galleryForm.title || !galleryForm.image_url) {
    formError.value = 'Title and photo are required.'
    return
  }

  saving.value = true
  formError.value = ''

  const payload = {
    title: galleryForm.title,
    category: galleryForm.category,
    description: galleryForm.description,
    image_url: galleryForm.image_url,
    is_visible: galleryForm.is_visible
  }

  const { error } = editingGallery.value
    ? await supabase.from('gallery_items').update(payload).eq('id', editingGallery.value.id)
    : await supabase.from('gallery_items').insert([payload])

  saving.value = false

  if (error) {
    formError.value = error.message
    return
  }

  const wasEditing = Boolean(editingGallery.value)
  closeGalleryForm()
  showToast(wasEditing ? 'Gallery item updated.' : 'Added to gallery.')
  await loadGallery()
}

async function toggleGalleryVisible(item) {
  const { error } = await supabase
    .from('gallery_items')
    .update({ is_visible: !item.is_visible })
    .eq('id', item.id)

  if (error) {
    showToast(error.message, 'error')
    return
  }

  item.is_visible = !item.is_visible
  showToast(item.is_visible ? 'Now visible in gallery.' : 'Hidden from gallery.')
}

async function deleteGalleryItem(item) {
  if (!confirm(`Delete "${item.title}"?`)) return

  const { error } = await supabase.from('gallery_items').delete().eq('id', item.id)
  if (error) {
    showToast(error.message, 'error')
    return
  }

  showToast('Gallery item deleted.')
  await loadGallery()
}

function triggerUpload(type) {
  if (type === 'image') imageInput.value?.click()
  if (type === 'video') videoInput.value?.click()
  if (type === 'gallery') galleryInput.value?.click()
}

async function uploadFile(event, type) {
  const [file] = event.target.files || []
  if (!file) return

  if (type === 'image') uploadingImage.value = true
  if (type === 'video') uploadingVideo.value = true
  if (type === 'gallery') uploadingGallery.value = true

  const extension = file.name.split('.').pop() || 'file'
  const folder = type === 'video' ? 'videos' : type === 'gallery' ? 'gallery' : 'products'
  const path = `${folder}/${Date.now()}-${Math.random().toString(36).slice(2, 10)}.${extension}`
  const { error: uploadError } = await supabase.storage.from('product-media').upload(path, file)

  if (type === 'image') uploadingImage.value = false
  if (type === 'video') uploadingVideo.value = false
  if (type === 'gallery') uploadingGallery.value = false

  if (uploadError) {
    showToast(uploadError.message, 'error')
    return
  }

  const { data } = supabase.storage.from('product-media').getPublicUrl(path)
  if (type === 'image') productForm.image_url = data.publicUrl
  if (type === 'video') productForm.video_url = data.publicUrl
  if (type === 'gallery') galleryForm.image_url = data.publicUrl
}

async function loadProducts() {
  loadingProducts.value = true
  const { data, error } = await supabase
    .from('products')
    .select('*')
    .order('created_at', { ascending: false })

  if (error) showToast(error.message, 'error')
  products.value = data || []
  loadingProducts.value = false
}

async function loadGallery() {
  loadingGallery.value = true
  const { data, error } = await supabase
    .from('gallery_items')
    .select('*')
    .order('created_at', { ascending: false })

  if (error) showToast(error.message, 'error')
  galleryItems.value = data || []
  loadingGallery.value = false
}

onMounted(async () => {
  await Promise.all([loadProducts(), loadGallery()])
})
</script>

<style scoped>
.admin-page {
  min-height: 100vh;
  background: #fffaf4;
}

.admin-header {
  position: sticky;
  top: 0;
  z-index: 100;
  border-bottom: 1px solid #eadfd2;
  background: rgba(255, 253, 248, 0.96);
  box-shadow: 0 8px 24px rgba(65, 42, 24, 0.05);
  backdrop-filter: blur(12px);
}

.admin-header-inner {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 16px;
  width: min(1120px, 92vw);
  margin: 0 auto;
  padding: 14px 0;
}

.admin-brand {
  display: flex;
  gap: 12px;
  align-items: center;
}

.admin-brand-icon {
  display: grid;
  place-items: center;
  width: 42px;
  height: 42px;
  border-radius: 999px;
  background: #a85f33;
  color: #ffffff;
  font-weight: 900;
}

.admin-brand-name,
.admin-brand-role,
.products-row-name,
.products-row-cat,
.gallery-admin-cat,
.gallery-admin-name {
  margin: 0;
}

.admin-brand-name {
  color: #241f1a;
  font-size: 18px;
  font-weight: 900;
}

.admin-brand-role {
  color: #77695f;
  font-size: 12px;
  font-weight: 900;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.admin-header-actions,
.products-row-actions,
.gallery-admin-actions,
.modal-footer {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
  align-items: center;
}

.admin-body {
  padding: 32px 0 64px;
}

.admin-overview {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 14px;
  margin-bottom: 24px;
}

.overview-card {
  padding: 18px;
  border: 1px solid #eadfd2;
  border-radius: 18px;
  background: linear-gradient(180deg, #ffffff, #fff8ef);
  box-shadow: 0 14px 34px rgba(65, 42, 24, 0.07);
}

.overview-card span {
  color: #79401f;
  font-size: 12px;
  font-weight: 900;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.overview-card strong {
  display: block;
  margin: 6px 0 4px;
  color: #241f1a;
  font-size: 32px;
  line-height: 1;
}

.overview-card p {
  margin: 0;
  color: #77695f;
  font-size: 13px;
  font-weight: 700;
}

.admin-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-height: 42px;
  border: 1px solid transparent;
  border-radius: 999px;
  padding: 10px 16px;
  cursor: pointer;
  font-weight: 850;
}

.admin-btn.small {
  min-height: 36px;
  padding: 7px 12px;
  font-size: 13px;
}

.admin-btn.primary {
  background: #a85f33;
  color: #ffffff;
}

.admin-btn.outline {
  border-color: #d8c8b8;
  background: #ffffff;
  color: #261f1a;
}

.admin-btn.ghost {
  background: #f2e5d7;
  color: #261f1a;
}

.admin-btn.warning {
  border-color: #eed987;
  background: #fff7d8;
  color: #79401f;
}

.admin-btn.danger {
  background: #fff0ef;
  color: #a33b2f;
}

.admin-btn:disabled {
  cursor: not-allowed;
  opacity: 0.65;
}

.admin-tabs {
  display: flex;
  gap: 0;
  margin-bottom: 28px;
  border-bottom: 2px solid #eadfd2;
}

.admin-tab {
  display: flex;
  gap: 8px;
  align-items: center;
  margin-bottom: -2px;
  border: 0;
  border-bottom: 2px solid transparent;
  padding: 12px 18px;
  background: transparent;
  color: #77695f;
  cursor: pointer;
  font-weight: 900;
}

.admin-tab.active {
  border-bottom-color: #a85f33;
  color: #a85f33;
}

.tab-count {
  border-radius: 999px;
  padding: 2px 8px;
  background: #f2e5d7;
  color: #79401f;
  font-size: 12px;
}

.tab-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  gap: 18px;
  margin-bottom: 20px;
}

.tab-actions {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.tab-title {
  margin: 0 0 6px;
  color: #241f1a;
  font-size: 30px;
}

.tab-sub {
  margin: 0;
  color: #77695f;
}

.admin-tools {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 220px;
  gap: 12px;
  align-items: end;
  margin-bottom: 18px;
}

.admin-search {
  display: grid;
  gap: 6px;
}

.admin-search span {
  color: #79401f;
  font-size: 12px;
  font-weight: 900;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.admin-search input,
.admin-filter {
  width: 100%;
  min-height: 44px;
  border: 1px solid #eadfd2;
  border-radius: 999px;
  padding: 0 15px;
  background: #ffffff;
  color: #261f1a;
  outline: none;
  box-shadow: 0 10px 26px rgba(65, 42, 24, 0.05);
}

.admin-search input:focus,
.admin-filter:focus {
  border-color: #a85f33;
  box-shadow: 0 0 0 3px rgba(168, 95, 51, 0.12);
}

.loading-wrap,
.empty-state {
  display: grid;
  place-items: center;
  gap: 12px;
  min-height: 260px;
  padding: 34px;
  border: 1px dashed #eadfd2;
  border-radius: 20px;
  background: #fffdf8;
  color: #77695f;
  text-align: center;
}

.empty-state.compact {
  min-height: 180px;
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

.products-table {
  overflow: hidden;
  border: 1px solid #eadfd2;
  border-radius: 18px;
  background: #ffffff;
  box-shadow: 0 16px 42px rgba(65, 42, 24, 0.08);
}

.products-table-head,
.products-row {
  display: grid;
  grid-template-columns: 2fr 0.75fr 1fr 2fr;
  gap: 16px;
  align-items: center;
}

.products-table-head {
  padding: 13px 18px;
  border-bottom: 1px solid #eadfd2;
  background: #fff3e4;
  color: #77695f;
  font-size: 12px;
  font-weight: 900;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.products-row {
  padding: 14px 18px;
  border-bottom: 1px solid #f0e8df;
}

.products-row:last-child {
  border-bottom: 0;
}

.products-row-info {
  display: flex;
  gap: 12px;
  align-items: center;
}

.products-row-img-wrap {
  display: grid;
  flex: 0 0 auto;
  place-items: center;
  width: 52px;
  height: 52px;
  overflow: hidden;
  border-radius: 12px;
  background: #f2e5d7;
}

.products-row-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.products-row-img-placeholder {
  color: #79401f;
  font-size: 12px;
  font-weight: 900;
}

.products-row-name {
  color: #241f1a;
  font-weight: 900;
}

.products-row-cat {
  color: #77695f;
  font-size: 13px;
}

.products-row-price {
  color: #79401f;
  font-weight: 900;
}

.badge {
  display: inline-flex;
  border-radius: 999px;
  padding: 5px 9px;
  font-size: 12px;
  font-weight: 900;
}

.badge.available {
  background: #e5f4e8;
  color: #266b35;
}

.badge.sold {
  background: #fff0ef;
  color: #a33b2f;
}

.badge.featured {
  margin-left: 4px;
  background: #f2e5d7;
  color: #79401f;
}

.gallery-admin-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(210px, 1fr));
  gap: 16px;
}

.gallery-admin-card {
  overflow: hidden;
  border: 1px solid #eadfd2;
  border-radius: 18px;
  background: #ffffff;
  box-shadow: 0 16px 42px rgba(65, 42, 24, 0.08);
}

.gallery-admin-card.hidden {
  opacity: 0.58;
}

.gallery-admin-img-wrap {
  position: relative;
  overflow: hidden;
  aspect-ratio: 1 / 1;
  background: #f2e5d7;
}

.gallery-admin-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.gallery-hidden-label {
  position: absolute;
  top: 10px;
  right: 10px;
  border-radius: 999px;
  padding: 5px 9px;
  background: rgba(38, 31, 26, 0.78);
  color: #ffffff;
  font-size: 12px;
  font-weight: 900;
}

.gallery-admin-body {
  padding: 12px 14px 8px;
}

.gallery-admin-cat {
  color: #79401f;
  font-size: 12px;
  font-weight: 900;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.gallery-admin-name {
  color: #261f1a;
  font-weight: 900;
}

.gallery-admin-actions {
  padding: 12px 14px;
  border-top: 1px solid #eadfd2;
}

.modal-overlay {
  position: fixed;
  inset: 0;
  z-index: 500;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow-y: auto;
  padding: 24px;
  background: rgba(26, 23, 20, 0.58);
}

.modal {
  display: flex;
  flex-direction: column;
  width: min(100%, 620px);
  max-height: 90vh;
  border-radius: 22px;
  background: #ffffff;
  box-shadow: 0 24px 70px rgba(0, 0, 0, 0.22);
}

.modal-sm {
  width: min(100%, 420px);
}

.modal-header,
.modal-footer {
  padding: 18px 22px;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid #eadfd2;
}

.modal-title {
  margin: 0;
  color: #241f1a;
  font-size: 21px;
}

.modal-close {
  border: 0;
  border-radius: 999px;
  padding: 8px 12px;
  background: #f2e5d7;
  color: #261f1a;
  cursor: pointer;
  font-weight: 900;
}

.modal-body {
  overflow-y: auto;
  padding: 22px;
}

.modal-footer {
  justify-content: flex-end;
  border-top: 1px solid #eadfd2;
}

.form-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 16px;
}

.field {
  display: grid;
  gap: 8px;
}

.field.full {
  grid-column: 1 / -1;
}

.field label {
  color: #261f1a;
  font-weight: 850;
}

.field input,
.field textarea,
.field select {
  width: 100%;
  min-height: 44px;
  border: 1px solid #eadfd2;
  border-radius: 12px;
  padding: 12px 13px;
  color: #261f1a;
  background: #fffdf8;
  outline: none;
}

.field textarea {
  resize: vertical;
}

.toggle-label {
  display: flex;
  gap: 10px;
  align-items: center;
}

.upload-zone {
  position: relative;
  display: grid;
  place-items: center;
  min-height: 138px;
  overflow: hidden;
  border: 2px dashed #d8c8b8;
  border-radius: 16px;
  background: #fffaf4;
  cursor: pointer;
}

.upload-zone input[type="file"] {
  display: none;
}

.upload-zone.has-file {
  border-style: solid;
}

.upload-placeholder {
  display: grid;
  gap: 4px;
  place-items: center;
  color: #77695f;
}

.upload-preview {
  position: relative;
  width: 100%;
}

.upload-preview img,
.upload-preview video {
  display: block;
  width: 100%;
  max-height: 220px;
  object-fit: cover;
}

.upload-remove {
  position: absolute;
  top: 10px;
  right: 10px;
  border: 0;
  border-radius: 999px;
  padding: 6px 10px;
  background: rgba(38, 31, 26, 0.78);
  color: #ffffff;
  cursor: pointer;
  font-weight: 900;
}

.form-error {
  margin: 14px 0 0;
  color: #a33b2f;
  font-weight: 850;
}

.confirm-text {
  color: #5f5147;
  line-height: 1.65;
}

.toast {
  position: fixed;
  right: 22px;
  bottom: 22px;
  z-index: 800;
  border-radius: 999px;
  padding: 12px 16px;
  background: #2f8f4f;
  color: #ffffff;
  font-weight: 900;
  box-shadow: 0 16px 42px rgba(65, 42, 24, 0.18);
}

.toast.error {
  background: #a33b2f;
}

@media (max-width: 820px) {
  .admin-overview {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }

  .admin-tools {
    grid-template-columns: 1fr;
  }

  .products-table-head {
    display: none;
  }

  .products-row {
    grid-template-columns: 1fr;
    gap: 10px;
  }

  .form-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 560px) {
  .admin-overview {
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 10px;
  }

  .overview-card {
    min-height: 136px;
    padding: 15px;
  }

  .overview-card span {
    font-size: 10px;
  }

  .overview-card strong {
    font-size: 34px;
  }

  .overview-card p {
    font-size: 12px;
  }

  .admin-header-inner,
  .tab-header {
    align-items: flex-start;
    flex-direction: column;
  }

  .admin-header-actions,
  .products-row-actions,
  .gallery-admin-actions {
    width: 100%;
  }

  .admin-btn {
    flex: 1;
  }

  .admin-body {
    padding-top: 20px;
  }

  .tab-title {
    font-size: 40px;
    line-height: 1.05;
  }

  .products-table {
    border-radius: 20px;
    background: transparent;
    box-shadow: none;
    border: 0;
    display: grid;
    gap: 12px;
  }

  .products-row {
    border: 1px solid #eadfd2;
    border-radius: 18px;
    padding: 14px;
    background: #ffffff;
    box-shadow: 0 12px 30px rgba(65, 42, 24, 0.06);
  }

  .products-row-info {
    align-items: flex-start;
  }

  .products-row-img-wrap {
    width: 64px;
    height: 64px;
  }

  .products-row-name {
    font-size: 20px;
    line-height: 1.18;
  }

  .products-row-price {
    font-size: 22px;
  }

  .products-row-status {
    display: flex;
    gap: 6px;
    flex-wrap: wrap;
  }

  .products-row-actions {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 8px;
  }

  .products-row-actions .admin-btn {
    min-height: 44px;
    padding: 8px;
    font-size: 12px;
    white-space: normal;
  }

  .gallery-admin-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 12px;
  }

  .gallery-admin-card {
    border-radius: 16px;
  }

  .gallery-admin-body {
    padding: 10px;
  }

  .gallery-admin-name {
    font-size: 14px;
    line-height: 1.25;
  }

  .gallery-admin-actions {
    display: grid;
    grid-template-columns: 1fr;
    gap: 7px;
    padding: 10px;
  }

  .gallery-admin-actions .admin-btn {
    min-height: 36px;
    font-size: 12px;
  }

  .modal-overlay {
    padding: 12px;
  }
}
</style>
