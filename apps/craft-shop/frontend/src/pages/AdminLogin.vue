<template>
  <header class="header">
    <div class="container header-row">
      <RouterLink to="/" class="brand">Handmade Craft Shop</RouterLink>
      <RouterLink to="/" class="btn secondary">Back to Shop</RouterLink>
    </div>
  </header>

  <main class="container login-page">
    <section class="login-card">
      <p class="eyebrow">Owner Access</p>
      <h1>Admin Login</h1>
      <p class="muted">Sign in to add products, upload photos, and manage the gallery.</p>

      <form class="form" @submit.prevent="login">
        <label class="field-label">
          Email
          <input v-model="email" class="input" type="email" placeholder="owner@example.com" required />
        </label>
        <label class="field-label">
          Password
          <input v-model="password" class="input" type="password" placeholder="Your password" required />
        </label>
        <button class="btn" type="submit">Login</button>
        <p v-if="errorMessage" class="error-message">{{ errorMessage }}</p>
      </form>
    </section>
  </main>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from '../lib/supabase'

const router = useRouter()
const email = ref('')
const password = ref('')
const errorMessage = ref('')

async function login() {
  errorMessage.value = ''
  const { error } = await supabase.auth.signInWithPassword({
    email: email.value,
    password: password.value
  })

  if (error) {
    errorMessage.value = error.message
    return
  }

  router.push('/admin')
}
</script>
