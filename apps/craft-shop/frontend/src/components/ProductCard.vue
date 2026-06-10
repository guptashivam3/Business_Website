<template>
  <RouterLink class="card product-card" :to="`/product/${product.slug}`">
    <div class="product-media">
      <img class="product-img" :src="product.image_url || placeholder" :alt="product.name" />
      <span v-if="!product.is_available" class="media-badge">Sold out</span>
      <span v-else-if="product.is_featured" class="media-badge">Featured</span>
    </div>
    <div class="card-body product-card-body">
      <p v-if="product.category" class="product-category">{{ product.category }}</p>
      <h3>{{ product.name }}</h3>
      <div class="product-card-footer">
        <p class="price">Rs {{ Number(product.price).toFixed(2) }}</p>
        <span>View</span>
      </div>
    </div>
  </RouterLink>
</template>

<script setup>
defineProps({
  product: {
    type: Object,
    required: true
  }
})

const placeholder = 'https://placehold.co/600x600?text=Handmade'
</script>
