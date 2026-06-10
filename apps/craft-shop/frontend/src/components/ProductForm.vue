<template>
  <form class="form product-form" @submit.prevent="submitForm">
    <div class="form-grid two-col">
      <label class="field-label">
        Product name
        <input v-model="local.name" class="input" placeholder="Handmade clay earrings" required />
      </label>

      <label class="field-label">
        Price
        <input v-model.number="local.price" class="input" type="number" step="0.01" min="0" placeholder="499" required />
      </label>
    </div>

    <label class="field-label">
      Description
      <textarea v-model="local.description" rows="4" placeholder="Materials, size, color, and care instructions"></textarea>
    </label>

    <label class="field-label">
      Category
      <input v-model="local.category" class="input" placeholder="Jewelry, decor, gifts" />
    </label>

    <div class="form-grid two-col">
      <label class="upload-box">
        <span>Product image</span>
        <small>Upload a clear square or portrait photo.</small>
        <input type="file" accept="image/*" @change="selectImage" />
      </label>

      <label class="upload-box">
        <span>Product video optional</span>
        <small>Add a short making or detail video.</small>
        <input type="file" accept="video/*" @change="selectVideo" />
      </label>
    </div>

    <div v-if="imagePreview || videoPreview" class="preview-grid">
      <img v-if="imagePreview" class="media-preview" :src="imagePreview" alt="Product image preview" />
      <video v-if="videoPreview" class="media-preview" :src="videoPreview" controls></video>
    </div>

    <div class="toggle-grid">
      <label class="toggle-card">
        <input v-model="local.is_available" type="checkbox" />
        <span>
          <strong>Available</strong>
          <small>Customers can order this item.</small>
        </span>
      </label>

      <label class="toggle-card">
        <input v-model="local.is_featured" type="checkbox" />
        <span>
          <strong>Featured</strong>
          <small>Highlight this product in the shop.</small>
        </span>
      </label>
    </div>

    <div class="button-row form-actions">
      <button class="btn" type="submit" :disabled="saving">
        {{ saving ? 'Saving...' : 'Save Product' }}
      </button>
      <button class="btn secondary" type="button" @click="emit('cancel')">Cancel</button>
    </div>
  </form>
</template>

<script setup>
import { reactive, ref, watch } from 'vue'
import { supabase } from '../lib/supabase'

const props = defineProps({
  product: {
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits(['save', 'cancel'])

const local = reactive({
  name: '',
  description: '',
  price: 0,
  category: '',
  image_url: '',
  video_url: '',
  is_available: true,
  is_featured: false
})

const imageFile = ref(null)
const videoFile = ref(null)
const imagePreview = ref('')
const videoPreview = ref('')
const saving = ref(false)

watch(
  () => props.product,
  (value) => {
    Object.assign(local, {
      name: '',
      description: '',
      price: 0,
      category: '',
      image_url: '',
      video_url: '',
      is_available: true,
      is_featured: false,
      ...(value || {})
    })
    imageFile.value = null
    videoFile.value = null
    imagePreview.value = local.image_url || ''
    videoPreview.value = local.video_url || ''
  },
  { immediate: true }
)

function slugify(value) {
  return value
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/(^-|-$)/g, '')
}

function selectImage(event) {
  const [file] = event.target.files || []
  imageFile.value = file || null
  imagePreview.value = file ? URL.createObjectURL(file) : local.image_url
}

function selectVideo(event) {
  const [file] = event.target.files || []
  videoFile.value = file || null
  videoPreview.value = file ? URL.createObjectURL(file) : local.video_url
}

function uniquePath(folder, file) {
  const extension = file.name.split('.').pop() || 'file'
  const randomId = Math.random().toString(36).slice(2, 10)
  return `${folder}/${Date.now()}-${randomId}.${extension}`
}

async function uploadMedia(file, folder) {
  const filePath = uniquePath(folder, file)
  const { error } = await supabase.storage.from('product-media').upload(filePath, file)

  if (error) throw error

  const { data } = supabase.storage.from('product-media').getPublicUrl(filePath)
  return data.publicUrl
}

async function submitForm() {
  saving.value = true

  try {
    const imageUrl = imageFile.value
      ? await uploadMedia(imageFile.value, 'products')
      : local.image_url

    const videoUrl = videoFile.value
      ? await uploadMedia(videoFile.value, 'videos')
      : local.video_url

    emit('save', {
      ...local,
      image_url: imageUrl,
      video_url: videoUrl,
      slug: slugify(local.name)
    })
  } catch (error) {
    alert(error.message)
  } finally {
    saving.value = false
  }
}
</script>
