import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import './styles/main.css'

const app = createApp(App)

app.directive('reveal', {
  mounted(el, binding) {
    const delay = binding.value?.delay || 0
    el.classList.add('reveal')
    el.style.setProperty('--reveal-delay', `${delay}ms`)

    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
      el.classList.add('is-visible')
      return
    }

    const observer = new IntersectionObserver(
      ([entry]) => {
        if (!entry.isIntersecting) return
        el.classList.add('is-visible')
        clearTimeout(fallback)
        observer.disconnect()
      },
      { threshold: 0.01, rootMargin: '0px 0px 18% 0px' }
    )

    const fallback = setTimeout(() => {
      el.classList.add('is-visible')
      observer.disconnect()
    }, 900)

    observer.observe(el)
  }
})

app.use(router).mount('#app')
