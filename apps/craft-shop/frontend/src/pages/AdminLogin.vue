<template>
  <div class="login-page">
    <div class="login-shell" v-reveal>
      <aside class="login-panel">
        <p class="login-panel-kicker">Owner workspace</p>
        <h2>Manage products, gallery, and availability in one focused place.</h2>
        <div class="login-panel-list">
          <span>Upload product photos and videos</span>
          <span>Mark items available, featured, or sold out</span>
          <span>Keep customer-facing pages fresh without code</span>
        </div>
      </aside>

    <div class="login-card">
      <div class="login-brand">
        <h1 class="login-title">{{ shopName }}</h1>
        <p class="login-sub">Admin Access</p>
      </div>

      <form class="login-form" @submit.prevent="login">
        <div class="field">
          <label>Email Address</label>
          <input v-model="email" type="email" required placeholder="you@email.com" autocomplete="email" />
        </div>

        <div class="field">
          <label>Password</label>
          <div class="pw-wrap">
            <input
              v-model="password"
              :type="showPw ? 'text' : 'password'"
              required
              placeholder="Password"
              autocomplete="current-password"
            />
            <button type="button" class="pw-toggle" @click="showPw = !showPw">
              {{ showPw ? 'Hide' : 'Show' }}
            </button>
          </div>
        </div>

        <div v-if="error" class="login-error">{{ error }}</div>

        <button type="submit" class="login-btn" :disabled="loading">
          {{ loading ? 'Signing in...' : 'Sign In' }}
        </button>
      </form>

      <RouterLink to="/" class="login-back">Back to Shop</RouterLink>
    </div>
    </div>
  </div>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from '../lib/supabase.js'

const router = useRouter()
const shopName = import.meta.env.VITE_SHOP_NAME || 'Handmade Craft Shop'
const email = ref('')
const password = ref('')
const loading = ref(false)
const error = ref('')
const showPw = ref(false)

onMounted(async () => {
  window.setTimeout(async () => {
    const { data } = await supabase.auth.getSession()
    if (data.session) router.replace('/admin')
  }, 0)
})

async function login() {
  loading.value = true
  error.value = ''

  const { error: err } = await supabase.auth.signInWithPassword({
    email: email.value,
    password: password.value
  })

  loading.value = false

  if (err) {
    error.value = 'Incorrect email or password. Please try again.'
    return
  }

  router.replace('/admin')
}
</script>

<style scoped>
.login-page {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 100vh;
  padding: 32px 20px;
  background:
    radial-gradient(circle at 18% 12%, rgba(242, 215, 194, 0.9) 0, transparent 32%),
    radial-gradient(circle at 80% 76%, rgba(201, 168, 76, 0.18) 0, transparent 30%),
    #fff3e4;
}

.login-shell {
  display: grid;
  grid-template-columns: minmax(0, 1fr) minmax(340px, 420px);
  width: min(960px, 100%);
  overflow: hidden;
  border: 1px solid #eadfd2;
  border-radius: 28px;
  background: rgba(255, 253, 248, 0.92);
  box-shadow: 0 28px 80px rgba(65, 42, 24, 0.16);
  animation: riseIn 560ms ease both;
}

.login-panel {
  display: flex;
  flex-direction: column;
  justify-content: center;
  padding: 42px;
  background:
    linear-gradient(135deg, rgba(38, 31, 26, 0.96), rgba(121, 64, 31, 0.92)),
    #261f1a;
  color: #ffffff;
}

.login-panel-kicker {
  margin: 0 0 14px;
  color: #f2d7c2;
  font-size: 12px;
  font-weight: 900;
  letter-spacing: 0.14em;
  text-transform: uppercase;
}

.login-panel h2 {
  margin: 0 0 24px;
  font-size: clamp(30px, 4vw, 48px);
  line-height: 1.08;
}

.login-panel-list {
  display: grid;
  gap: 12px;
}

.login-panel-list span {
  position: relative;
  padding-left: 18px;
  color: rgba(255, 255, 255, 0.78);
  line-height: 1.5;
}

.login-panel-list span::before {
  content: "";
  position: absolute;
  top: 0.65em;
  left: 0;
  width: 7px;
  height: 7px;
  border-radius: 99px;
  background: #c9a84c;
}

.login-card {
  width: 100%;
  padding: 38px 30px;
  background: #ffffff;
}

.login-brand {
  margin-bottom: 30px;
}
.login-title {
  margin: 0;
  color: #241f1a;
  font-size: 28px;
  line-height: 1.1;
}

.login-sub {
  margin: 8px 0 0;
  color: #77695f;
  font-size: 13px;
  font-weight: 900;
  letter-spacing: 0.1em;
  text-transform: uppercase;
}

.login-form {
  display: flex;
  flex-direction: column;
  gap: 18px;
  margin-bottom: 22px;
}

.field {
  display: grid;
  gap: 8px;
}

.field label {
  color: #261f1a;
  font-weight: 850;
}

.field input {
  width: 100%;
  min-height: 46px;
  border: 1px solid #eadfd2;
  border-radius: 12px;
  padding: 12px 14px;
  color: #261f1a;
  background: #fffdf8;
  outline: none;
}

.field input:focus {
  border-color: #a85f33;
  box-shadow: 0 0 0 3px rgba(168, 95, 51, 0.12);
}

.pw-wrap {
  position: relative;
}

.pw-wrap input {
  padding-right: 76px;
}

.pw-toggle {
  position: absolute;
  top: 50%;
  right: 10px;
  border: 0;
  border-radius: 999px;
  padding: 6px 10px;
  background: #f2e5d7;
  color: #261f1a;
  cursor: pointer;
  font-size: 12px;
  font-weight: 900;
  transform: translateY(-50%);
}

.login-error {
  border: 1px solid #f2c0bc;
  border-radius: 12px;
  padding: 11px 13px;
  background: #fff0ef;
  color: #a33b2f;
  font-size: 14px;
  font-weight: 800;
}

.login-btn {
  min-height: 48px;
  border: 0;
  border-radius: 999px;
  padding: 13px 18px;
  background: #a85f33;
  color: #ffffff;
  cursor: pointer;
  font-weight: 900;
}

.login-btn:disabled {
  cursor: not-allowed;
  opacity: 0.65;
}

.login-back {
  display: block;
  color: #77695f;
  text-align: center;
  font-size: 14px;
  font-weight: 850;
  transition: color 160ms ease;
}

.login-back:hover {
  color: #a85f33;
}

@keyframes riseIn {
  from {
    opacity: 0;
    transform: translateY(18px);
  }

  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@media (max-width: 760px) {
  .login-shell {
    grid-template-columns: 1fr;
  }

  .login-panel {
    padding: 28px;
  }
}

@media (prefers-reduced-motion: reduce) {
  .login-shell {
    animation: none;
  }
}
</style>
