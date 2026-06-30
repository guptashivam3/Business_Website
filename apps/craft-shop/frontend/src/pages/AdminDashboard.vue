<template>
  <div class="admin-page">
    <!-- ============ TOP BAR ============ -->
    <header class="admin-header">
      <div class="admin-header-inner">
        <button class="nav-burger" type="button" aria-label="Open menu" @click="mobileNavOpen = true">
          <span></span><span></span><span></span>
        </button>
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
      <nav class="mobile-top-tabs" aria-label="Admin sections">
        <button
          v-for="item in navItems"
          :key="item.key"
          class="mobile-top-tab"
          :class="{ active: tab === item.key }"
          type="button"
          @click="selectTab(item.key)"
        >
          <span>{{ item.icon }}</span>{{ item.label }}
        </button>
        <RouterLink to="/" class="mobile-top-tab shop" target="_blank">Shop</RouterLink>
      </nav>
    </header>

    <div class="admin-shell">
      <!-- ============ SIDEBAR (desktop) / DRAWER (mobile) ============ -->
      <transition name="fade">
        <div v-if="mobileNavOpen" class="nav-scrim" @click="mobileNavOpen = false"></div>
      </transition>

      <aside class="admin-sidebar" :class="{ open: mobileNavOpen }">
        <div class="sidebar-top">
          <div class="admin-brand drawer-only">
            <span class="admin-brand-icon">LC</span>
            <div>
              <p class="admin-brand-name">{{ shopName }}</p>
              <p class="admin-brand-role">Admin</p>
            </div>
          </div>
          <button class="nav-close drawer-only" type="button" aria-label="Close menu" @click="mobileNavOpen = false">✕</button>
        </div>

        <nav class="sidebar-nav">
          <button
            v-for="item in navItems"
            :key="item.key"
            class="sidebar-link"
            :class="{ active: tab === item.key }"
            type="button"
            @click="selectTab(item.key)"
          >
            <span class="sidebar-link-icon">{{ item.icon }}</span>
            <span class="sidebar-link-label">{{ item.label }}</span>
            <span v-if="item.count !== undefined" class="sidebar-link-count">{{ item.count }}</span>
          </button>
        </nav>

        <div class="sidebar-foot drawer-only">
          <RouterLink to="/" class="admin-btn outline small" target="_blank">View Shop</RouterLink>
          <button class="admin-btn ghost small" type="button" @click="logout">Logout</button>
        </div>
      </aside>

      <!-- ============ MAIN CONTENT ============ -->
      <main class="admin-body">
        <!-- ---------------- DASHBOARD ---------------- -->
        <section v-if="tab === 'dashboard'" class="tab-content" v-reveal>
          <div class="tab-header">
            <div>
              <h2 class="tab-title">Welcome back</h2>
              <p class="tab-sub">Here's how customers are interacting with {{ shopName }} right now.</p>
            </div>
            <button class="admin-btn outline small dashboard-refresh-top" type="button" @click="loadAnalytics">Refresh</button>
          </div>

          <!-- Quick actions -->
          <div class="quick-actions">
            <button class="quick-action" type="button" @click="goAddProduct">
              <span class="quick-action-icon">+</span>
              <span>
                <strong>Add a product</strong>
                <small>List something new for sale</small>
              </span>
            </button>
            <button class="quick-action" type="button" @click="goAddGallery">
              <span class="quick-action-icon">🖼</span>
              <span>
                <strong>Add gallery photos</strong>
                <small>Show off finished work</small>
              </span>
            </button>
            <button class="quick-action" type="button" @click="tab = 'settings'">
              <span class="quick-action-icon">✎</span>
              <span>
                <strong>Edit site details</strong>
                <small>Update contact & About Us</small>
              </span>
            </button>
          </div>

          <!-- Key metrics -->
          <div class="mobile-refresh-row">
            <button class="admin-btn outline small" type="button" @click="loadAnalytics">Refresh dashboard</button>
          </div>
          <div class="metric-grid">
            <div class="metric-card">
              <span>Site Visits</span>
              <strong>{{ pageViewCount }}</strong>
              <p>Customer-facing page views</p>
            </div>
            <div class="metric-card">
              <span>Item Interest</span>
              <strong>{{ productViewCount }}</strong>
              <p>Product detail opens</p>
            </div>
            <div class="metric-card">
              <span>Order Leads</span>
              <strong>{{ whatsappClickCount }}</strong>
              <p>WhatsApp order starts</p>
            </div>
            <div class="metric-card accent">
              <span>Conversion</span>
              <strong>{{ conversionRate }}%</strong>
              <p>Views becoming WhatsApp leads</p>
            </div>
          </div>

          <!-- Needs attention -->
          <section v-if="needsAttention.length" class="attention-panel">
            <div class="panel-heading">
              <h3>Needs your attention</h3>
              <span>{{ needsAttention.length }} item{{ needsAttention.length === 1 ? '' : 's' }}</span>
            </div>
            <div class="attention-list">
              <button v-for="item in needsAttention" :key="item.key" class="attention-row" type="button" @click="item.action">
                <span class="attention-dot" :class="item.severity"></span>
                <span class="attention-text">
                  <strong>{{ item.title }}</strong>
                  <small>{{ item.detail }}</small>
                </span>
                <span class="attention-go">View →</span>
              </button>
            </div>
          </section>

          <div v-if="analyticsError" class="empty-state compact">
            <div class="empty-state-icon">SQL</div>
            <h3>Analytics setup needed</h3>
            <p>{{ analyticsError }}</p>
          </div>

          <template v-else>
            <section class="analytics-panel chart-panel">
              <div class="panel-heading trend-heading">
                <div>
                  <h3>Customer trend</h3>
                  <p class="panel-subtitle">Total customer activity across the last 14 days</p>
                </div>
                <span>Last 14 days</span>
              </div>

              <div class="trend-summary-strip" aria-label="Customer trend summary">
                <div class="trend-summary-card">
                  <span>Total activity</span>
                  <strong>{{ totalCustomerActivity }}</strong>
                </div>
                <div class="trend-summary-card">
                  <span>Best day</span>
                  <strong>{{ bestCustomerDay.label }}</strong>
                  <small>{{ bestCustomerDay.total }} actions</small>
                </div>
                <div class="trend-summary-card">
                  <span>Today</span>
                  <strong>{{ todayCustomerActivity }}</strong>
                  <small>actions</small>
                </div>
              </div>

              <div class="customer-trend-bars" aria-label="Daily customer activity bar chart">
                <div
                  v-for="day in trendBarItems"
                  :key="day.key"
                  class="customer-trend-day"
                  :class="{ empty: day.total === 0 }"
                  :data-tooltip="`${day.label}: ${day.total} total actions — ${day.page} page, ${day.product} product, ${day.whatsapp} WhatsApp`"
                  :title="`${day.label}: ${day.total} total actions (${day.page} page, ${day.product} product, ${day.whatsapp} WhatsApp)`"
                >
                  <div class="customer-trend-bar-wrap">
                    <span class="customer-trend-bar" :style="{ height: `${day.height}%` }"></span>
                  </div>
                  <small>{{ day.shortLabel }}</small>
                </div>
              </div>

              <div class="chart-legend simple trend-note">
                <span><i class="legend-dot total"></i>Hover a bar to see page, product, and WhatsApp details</span>
              </div>
            </section>

            <div class="analytics-panels">
              <section class="analytics-panel donut-panel">
                <div class="panel-heading">
                  <h3>Customer intent</h3>
                  <span>{{ filteredAnalytics.length }} events</span>
                </div>
                <div class="donut-layout">
                  <div class="donut-chart" :style="intentDonutStyle">
                    <div>
                      <strong>{{ filteredAnalytics.length }}</strong>
                      <span>Total</span>
                    </div>
                  </div>
                  <div class="donut-legend">
                    <span v-for="segment in intentSegments" :key="segment.label">
                      <i :style="{ background: segment.color }"></i>{{ segment.label }} <strong>{{ segment.count }}</strong>
                    </span>
                  </div>
                </div>
              </section>

              <section class="analytics-panel interest-panel">
                <div class="panel-heading">
                  <h3>Top interest</h3>
                  <span>{{ loadingAnalytics ? 'Loading...' : `${topInterestCount} actions` }}</span>
                </div>
                <div v-if="topProductSegments.length === 0" class="mini-empty">Product interest will appear after customers open product pages.</div>
                <div v-else class="top-interest-donut-layout">
                  <div class="top-interest-donut" :style="topProductDonutStyle" aria-label="Top product interest donut chart">
                    <div>
                      <strong>{{ topInterestCount }}</strong>
                      <span>Total</span>
                    </div>
                  </div>
                  <div class="top-interest-legend">
                    <span
                      v-for="segment in topProductSegments"
                      :key="segment.label"
                      :title="`${segment.label}: ${segment.count} total interest actions`"
                    >
                      <i :style="{ background: segment.color }"></i>
                      <em>{{ segment.label }}</em>
                      <strong>{{ segment.count }}</strong>
                    </span>
                  </div>
                </div>
              </section>
            </div>
          </template>
        </section>

        <!-- ---------------- PRODUCTS ---------------- -->
        <section v-if="tab === 'products'" class="tab-content" v-reveal="{ delay: 80 }">
          <div class="tab-header">
            <div>
              <h2 class="tab-title">Products</h2>
              <p class="tab-sub">Add products, upload media, and update availability.</p>
            </div>
            <div class="tab-actions">
              <RouterLink to="/" class="admin-btn outline small" target="_blank">Preview Shop</RouterLink>
              <button class="admin-btn primary small" type="button" @click="openProductForm(null)">+ Add Product</button>
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

          <div v-else class="gallery-admin-grid products-admin-grid">
            <article v-for="product in filteredProducts" :key="product.id" class="gallery-admin-card product-admin-card" :class="{ sold: !product.is_available, missing: !mainProductImage(product) }">
              <div class="gallery-admin-img-wrap product-admin-img-wrap">
                <img v-if="mainProductImage(product)" :src="mainProductImage(product)" :alt="product.name" class="gallery-admin-img" />
                <div v-else class="product-missing-image">
                  <span class="product-missing-icon">✦</span>
                  <strong>No photo yet</strong>
                  <small>Add a product image to improve customer interest.</small>
                </div>
                <div v-if="!product.is_available" class="gallery-hidden-label product-status-label">Sold Out</div>
              </div>
              <div class="gallery-admin-body product-admin-body">
                <p class="gallery-admin-cat">{{ product.category || 'Uncategorized' }}</p>
                <p class="gallery-admin-name">{{ product.name }}</p>
                <div class="product-card-meta">
                  <strong class="product-card-price">Rs {{ Number(product.price).toFixed(2) }}</strong>
                  <div class="product-badges">
                    <span :class="product.is_available ? 'badge available' : 'badge sold'">
                      {{ product.is_available ? 'Available' : 'Sold Out' }}
                    </span>
                    <span v-if="product.is_featured" class="badge featured">Featured</span>
                  </div>
                </div>
              </div>
              <div class="gallery-admin-actions product-admin-actions">
                <button class="admin-btn outline small" type="button" @click="openProductForm(product)">Edit</button>
                <button class="admin-btn warning small" type="button" @click="toggleAvailable(product)">
                  {{ product.is_available ? 'Mark Sold Out' : 'Mark Available' }}
                </button>
                <button class="admin-btn danger small" type="button" @click="confirmDelete(product)">Delete</button>
              </div>
            </article>
          </div>
        </section>

        <!-- ---------------- GALLERY ---------------- -->
        <section v-if="tab === 'gallery'" class="tab-content" v-reveal="{ delay: 80 }">
          <div class="tab-header">
            <div>
              <h2 class="tab-title">Gallery</h2>
              <p class="tab-sub">Upload finished work photos in batches for custom order inspiration.</p>
            </div>
            <div class="tab-actions">
              <RouterLink to="/gallery" class="admin-btn outline small" target="_blank">Preview Gallery</RouterLink>
              <button class="admin-btn primary small" type="button" @click="openGalleryForm(null)">+ Add Photos</button>
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

        <!-- ---------------- SETTINGS ---------------- -->
        <section v-if="tab === 'settings'" class="tab-content" v-reveal="{ delay: 80 }">
          <div class="tab-header">
            <div>
              <h2 class="tab-title">Site Details</h2>
              <p class="tab-sub">Update the About Us page, owner contact details, and profile photo.</p>
            </div>
            <RouterLink to="/about" class="admin-btn outline small" target="_blank">Preview About Us</RouterLink>
          </div>

          <div class="settings-layout">
            <div class="settings-panel">
              <div class="form-grid">
                <div class="field">
                  <label>Shop Name</label>
                  <input v-model="siteForm.shop_name" placeholder="Laxmi Creations" />
                </div>
                <div class="field">
                  <label>Owner Name</label>
                  <input v-model="siteForm.owner_name" placeholder="Laxmi Gupta" />
                </div>
                <div class="field">
                  <label>Phone</label>
                  <input v-model="siteForm.owner_phone" placeholder="+918793662673" />
                </div>
                <div class="field">
                  <label>Email</label>
                  <input v-model="siteForm.owner_email" type="email" placeholder="laxmigupta8888@gmail.com" />
                </div>
                <div class="field">
                  <label>Instagram</label>
                  <input v-model="siteForm.owner_instagram" placeholder="laxmi_creations" />
                </div>
                <div class="field full">
                  <label>About Heading</label>
                  <input v-model="siteForm.about_heading" placeholder="Handmade gifts crafted by Laxmi Gupta" />
                </div>
                <div class="field full">
                  <label>Intro Text</label>
                  <textarea v-model="siteForm.about_intro" rows="3" placeholder="Short intro for About Us"></textarea>
                </div>
                <div class="field full">
                  <label>Story Text</label>
                  <textarea v-model="siteForm.about_story" rows="4" placeholder="Longer story shown on About Us"></textarea>
                </div>
                <div class="field full">
                  <label>Owner Photo</label>
                  <div class="upload-zone" :class="{ 'has-file': siteForm.owner_photo_url }" @click="triggerUpload('owner')">
                    <input ref="ownerPhotoInput" type="file" accept="image/*" @change="uploadFile($event, 'owner')" />
                    <div v-if="siteForm.owner_photo_url" class="upload-preview">
                      <img :src="siteForm.owner_photo_url" alt="Owner preview" />
                      <button type="button" class="upload-remove" @click.stop="siteForm.owner_photo_url = ''">Remove</button>
                    </div>
                    <div v-else class="upload-placeholder">
                      <strong>{{ uploadingOwnerPhoto ? 'Uploading...' : 'Click to upload owner photo' }}</strong>
                      <span>Shown on About Us</span>
                    </div>
                  </div>
                </div>
              </div>

              <p v-if="formError" class="form-error">{{ formError }}</p>
              <div class="settings-actions">
                <button class="admin-btn primary" type="button" :disabled="saving" @click="saveSiteSettings">
                  {{ saving ? 'Saving...' : 'Save Site Details' }}
                </button>
              </div>
            </div>

          </div>
        </section>
      </main>
    </div>

    <!-- ============ MODALS (unchanged behaviour) ============ -->
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
              <label>Product Photos</label>
              <div class="upload-zone" :class="{ 'has-file': productForm.image_urls.length }" @click="triggerUpload('image')">
                <input ref="imageInput" type="file" accept="image/*" multiple @change="uploadFile($event, 'image')" />
                <div class="upload-placeholder">
                  <strong>{{ uploadingImage ? 'Uploading...' : productForm.image_urls.length ? 'Add more photos' : 'Click to upload photos' }}</strong>
                  <span>{{ productForm.image_urls.length ? 'Existing photos stay unless you remove them.' : 'Optional. Select one or more JPG/PNG photos.' }} First photo is the main shop image.</span>
                </div>
              </div>
              <div v-if="productForm.image_urls.length" class="photo-preview-grid">
                <div v-for="(url, index) in productForm.image_urls" :key="url" class="photo-preview">
                  <img :src="url" :alt="`Product photo ${index + 1}`" />
                  <span v-if="index === 0">Main</span>
                  <button type="button" class="upload-remove" @click.stop="removeProductPhoto(index)">Remove</button>
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
                  <span>Optional. Keep video under {{ videoUploadLimitLabel }} on the Free plan.</span>
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
              <label>Photos *</label>
              <div class="upload-zone" :class="{ 'has-file': galleryForm.image_urls.length }" @click="triggerUpload('gallery')">
                <input ref="galleryInput" type="file" accept="image/*" multiple @change="uploadFile($event, 'gallery')" />
                <div class="upload-placeholder">
                  <strong>{{ uploadingGallery ? 'Uploading...' : galleryForm.image_urls.length ? 'Add more photos' : 'Click to upload photos' }}</strong>
                  <span>{{ galleryForm.image_urls.length ? 'Existing gallery photos stay unless you remove them.' : 'Select one or more photos for this same gallery item.' }} First photo is the main image.</span>
                </div>
              </div>
              <div v-if="galleryForm.image_urls.length" class="photo-preview-grid">
                <div v-for="(url, index) in galleryForm.image_urls" :key="url" class="photo-preview">
                  <img :src="url" :alt="`Gallery photo ${index + 1}`" />
                  <span v-if="index === 0">Main</span>
                  <button type="button" class="upload-remove" @click.stop="removeGalleryPhoto(index)">Remove</button>
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
const shopName = import.meta.env.VITE_SHOP_NAME || 'Laxmi Creations'
const tab = ref('dashboard')
const mobileNavOpen = ref(false)

const products = ref([])
const galleryItems = ref([])
const analyticsEvents = ref([])
const loadingProducts = ref(true)
const loadingGallery = ref(true)
const loadingAnalytics = ref(true)
const analyticsError = ref('')
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
const siteForm = reactive(defaultSiteForm())

const imageInput = ref(null)
const videoInput = ref(null)
const galleryInput = ref(null)
const ownerPhotoInput = ref(null)
const uploadingImage = ref(false)
const uploadingVideo = ref(false)
const uploadingGallery = ref(false)
const uploadingOwnerPhoto = ref(false)

const saving = ref(false)
const formError = ref('')
const deleteTarget = ref(null)
const toast = ref(null)
const maxVideoUploadBytes = 50 * 1024 * 1024
const videoUploadLimitLabel = formatFileSize(maxVideoUploadBytes)

const availableProducts = computed(() => products.value.filter((product) => product.is_available).length)
const soldOutProducts = computed(() => products.value.filter((product) => !product.is_available).length)
const featuredProducts = computed(() => products.value.filter((product) => product.is_featured).length)
const visibleGalleryItems = computed(() => galleryItems.value.filter((item) => item.is_visible).length)
const hiddenGalleryItems = computed(() => galleryItems.value.filter((item) => !item.is_visible).length)
const missingImageProducts = computed(() => products.value.filter((product) => !mainProductImage(product)).length)

const navItems = computed(() => [
  { key: 'dashboard', label: 'Dashboard', icon: '◆' },
  { key: 'products', label: 'Products', icon: '▣', count: products.value.length },
  { key: 'gallery', label: 'Gallery', icon: '◫', count: galleryItems.value.length },
  { key: 'settings', label: 'Settings', icon: '⚙' }
])

const needsAttention = computed(() => {
  const items = []
  if (soldOutProducts.value > 0) {
    items.push({
      key: 'sold-out',
      severity: 'warn',
      title: `${soldOutProducts.value} product${soldOutProducts.value === 1 ? '' : 's'} marked sold out`,
      detail: 'Restock or remove so customers see what is actually available.',
      action: () => {
        tab.value = 'products'
        productFilter.value = 'sold'
      }
    })
  }
  if (missingImageProducts.value > 0) {
    items.push({
      key: 'missing-image',
      severity: 'danger',
      title: `${missingImageProducts.value} product${missingImageProducts.value === 1 ? '' : 's'} missing a photo`,
      detail: 'Products without photos are far less likely to get clicks.',
      action: () => {
        tab.value = 'products'
        productFilter.value = 'missingImage'
      }
    })
  }
  if (hiddenGalleryItems.value > 0) {
    items.push({
      key: 'hidden-gallery',
      severity: 'info',
      title: `${hiddenGalleryItems.value} gallery item${hiddenGalleryItems.value === 1 ? '' : 's'} hidden`,
      detail: 'Hidden items will not show up on the public gallery page.',
      action: () => {
        tab.value = 'gallery'
        galleryFilter.value = 'hidden'
      }
    })
  }
  return items
})

function selectTab(key) {
  tab.value = key
  mobileNavOpen.value = false
}

function goAddProduct() {
  tab.value = 'products'
  openProductForm(null)
}

function goAddGallery() {
  tab.value = 'gallery'
  openGalleryForm(null)
}

const filteredAnalytics = computed(() => {
  return analyticsEvents.value.filter(isCustomerEvent)
})

const pageViewCount = computed(() => filteredAnalytics.value.filter((event) => event.event_type === 'page_view').length)
const productViewCount = computed(() => filteredAnalytics.value.filter((event) => event.event_type === 'product_view').length)
const whatsappClickCount = computed(() => filteredAnalytics.value.filter((event) => event.event_type === 'whatsapp_click' || event.event_type === 'custom_order_click').length)
const galleryInterestCount = computed(() => filteredAnalytics.value.filter((event) => event.event_type === 'gallery_view' || event.event_type === 'custom_order_click').length)
const conversionRate = computed(() => {
  if (!productViewCount.value) return 0
  return Math.round((whatsappClickCount.value / productViewCount.value) * 100)
})

const intentSegments = computed(() => [
  { label: 'Page', count: pageViewCount.value, color: '#d7c6b4' },
  { label: 'Product', count: productViewCount.value, color: '#a85f33' },
  { label: 'WhatsApp', count: whatsappClickCount.value, color: '#1f9d57' },
  { label: 'Gallery', count: galleryInterestCount.value, color: '#7b6fb0' }
])

const intentDonutStyle = computed(() => ({ background: donutGradient(intentSegments.value) }))

const topProducts = computed(() => {
  const grouped = new Map()
  filteredAnalytics.value
    .filter((event) => event.product_name || event.product_id)
    .forEach((event) => {
      const name = cleanAnalyticsName(event.product_name || event.metadata?.title || 'Unnamed product')
      if (name === 'Unnamed product') return
      const current = grouped.get(name) || { name, views: 0, clicks: 0, total: 0 }
      if (event.event_type === 'product_view') current.views += 1
      if (event.event_type === 'whatsapp_click') current.clicks += 1
      current.total += 1
      grouped.set(name, current)
    })

  const list = Array.from(grouped.values()).sort((a, b) => b.total - a.total).slice(0, 4)
  const max = Math.max(1, ...list.map((item) => item.total))
  return list.map((item) => ({ ...item, percent: Math.max(8, Math.round((item.total / max) * 100)) }))
})

const productInterestItems = computed(() => {
  const grouped = new Map()
  filteredAnalytics.value
    .filter((event) => event.product_name || event.product_id)
    .forEach((event) => {
      const name = cleanAnalyticsName(event.product_name || event.metadata?.title || 'Unnamed product')
      if (name === 'Unnamed product') return
      const current = grouped.get(name) || { label: name, views: 0, clicks: 0, count: 0 }
      if (event.event_type === 'product_view') current.views += 1
      if (event.event_type === 'whatsapp_click') current.clicks += 1
      current.count += 1
      grouped.set(name, current)
    })

  return Array.from(grouped.values()).sort((a, b) => b.count - a.count)
})

const topProductSegments = computed(() => {
  const colors = ['#a85f33', '#1f9d57', '#7b6fb0', '#d39a1f', '#d7c6b4']
  const items = productInterestItems.value
  const top = items.slice(0, 4).map((item, index) => ({ ...item, color: colors[index] }))
  const otherCount = items.slice(4).reduce((sum, item) => sum + item.count, 0)

  if (otherCount > 0) {
    top.push({ label: 'Other', count: otherCount, views: 0, clicks: 0, color: colors[4] })
  }

  return top
})

const topInterestCount = computed(() => topProductSegments.value.reduce((sum, segment) => sum + segment.count, 0))
const topProductDonutStyle = computed(() => ({ background: donutGradient(topProductSegments.value) }))

const dailyTrend = computed(() => {
  const daysToShow = 14
  const buckets = Array.from({ length: daysToShow }, (_, index) => {
    const date = new Date()
    date.setHours(0, 0, 0, 0)
    date.setDate(date.getDate() - (daysToShow - index - 1))
    const key = date.toISOString().slice(0, 10)
    return { key, label: date.toLocaleDateString('en-IN', { day: '2-digit', month: 'short' }), page: 0, product: 0, whatsapp: 0, total: 0 }
  })
  const byKey = new Map(buckets.map((day) => [day.key, day]))

  filteredAnalytics.value.forEach((event) => {
    const key = new Date(event.created_at).toISOString().slice(0, 10)
    const day = byKey.get(key)
    if (!day) return
    if (event.event_type === 'page_view') day.page += 1
    if (event.event_type === 'product_view') day.product += 1
    if (event.event_type === 'whatsapp_click' || event.event_type === 'custom_order_click') day.whatsapp += 1
    day.total += 1
  })

  const max = Math.max(1, ...buckets.map((day) => day.total))
  return buckets.map((day) => ({
    ...day,
    pagePercent: day.page ? Math.max(8, Math.round((day.page / max) * 100)) : 0,
    productPercent: day.product ? Math.max(8, Math.round((day.product / max) * 100)) : 0,
    whatsappPercent: day.whatsapp ? Math.max(8, Math.round((day.whatsapp / max) * 100)) : 0
  }))
})

const totalCustomerActivity = computed(() => dailyTrend.value.reduce((sum, day) => sum + day.total, 0))
const todayCustomerActivity = computed(() => dailyTrend.value.at(-1)?.total || 0)
const bestCustomerDay = computed(() => {
  return dailyTrend.value.reduce((best, day) => (day.total > best.total ? day : best), dailyTrend.value[0] || { label: 'Today', total: 0 })
})
const trendBarItems = computed(() => {
  const max = Math.max(1, ...dailyTrend.value.map((day) => day.total))
  return dailyTrend.value.map((day, index) => ({
    ...day,
    shortLabel: index % 3 === 0 || index === dailyTrend.value.length - 1 ? day.label : '',
    height: day.total ? Math.max(10, Math.round((day.total / max) * 100)) : 3
  }))
})


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
      (productFilter.value === 'missingImage' && !mainProductImage(product))

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
    image_urls: [],
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
    image_urls: [],
    is_visible: true
  }
}

function defaultSiteForm() {
  return {
    id: 'about',
    shop_name: 'Laxmi Creations',
    owner_name: 'Laxmi Gupta',
    owner_phone: '+918793662673',
    owner_email: 'laxmigupta8888@gmail.com',
    owner_instagram: 'laxmi_creations',
    owner_photo_url: '',
    about_heading: 'Handmade gifts crafted by Laxmi Gupta',
    about_intro: 'Laxmi Creations is a small handmade craft studio for thoughtful gifting, festive hampers, chocolate garlands, decorated trays, potli favors, and custom celebration pieces.',
    about_story: 'Every order is handled personally, from choosing the color theme to arranging the final packing. The goal is simple: make gifting feel warm, beautiful, and easy for families who want something more personal than a ready-made store item.'
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

function mainProductImage(product) {
  return product.image_url || (Array.isArray(product.image_urls) ? product.image_urls[0] : '')
}

async function logout() {
  await supabase.auth.signOut()
  router.push('/admin/login')
}

function openProductForm(product) {
  editingProduct.value = product
  const nextProduct = product ? { ...defaultProductForm(), ...product } : defaultProductForm()
  nextProduct.image_urls = normalizeProductPhotos(nextProduct)
  nextProduct.image_url = nextProduct.image_urls[0] || ''
  resetReactive(productForm, nextProduct)
  formError.value = ''
  showProductForm.value = true
}

function closeProductForm() {
  showProductForm.value = false
  editingProduct.value = null
  formError.value = ''
}

function productPayload(includeCategory = true) {
  const imageUrls = normalizeProductPhotos(productForm)
  const payload = {
    name: productForm.name,
    slug: slugify(productForm.name),
    description: productForm.description,
    price: Number(productForm.price || 0),
    image_url: imageUrls[0] || '',
    image_urls: imageUrls,
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

function isMissingImageUrlsError(error) {
  return error?.message?.includes("'image_urls' column") || error?.message?.includes("Could not find the 'image_urls'")
}

function imageUrlsSchemaMessage(kind) {
  return `Multiple ${kind} photos need the image_urls column in Supabase. Run the latest schema.sql, then try saving again.`
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

  if (isMissingImageUrlsError(error)) {
    saving.value = false
    formError.value = imageUrlsSchemaMessage('product')
    return
  }

  if (isMissingCategoryError(error)) {
    const fallbackPayload = productPayload(false)
    const fallbackResult = editingProduct.value
      ? await supabase.from('products').update(fallbackPayload).eq('id', editingProduct.value.id)
      : await supabase.from('products').insert([fallbackPayload])
    error = fallbackResult.error

    if (isMissingImageUrlsError(error)) {
      saving.value = false
      formError.value = imageUrlsSchemaMessage('product')
      return
    }
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
  const nextItem = item ? { ...defaultGalleryForm(), ...item } : defaultGalleryForm()
  nextItem.image_urls = normalizeGalleryPhotos(nextItem)
  nextItem.image_url = nextItem.image_urls[0] || ''
  resetReactive(galleryForm, nextItem)
  formError.value = ''
  showGalleryForm.value = true
}

function closeGalleryForm() {
  showGalleryForm.value = false
  editingGallery.value = null
  formError.value = ''
}

async function saveGalleryItem() {
  const imageUrls = normalizeGalleryPhotos(galleryForm)

  if (!galleryForm.title || imageUrls.length === 0) {
    formError.value = 'Title and at least one photo are required.'
    return
  }

  saving.value = true
  formError.value = ''

  const basePayload = {
    title: galleryForm.title,
    category: galleryForm.category,
    description: galleryForm.description,
    is_visible: galleryForm.is_visible
  }

  const payload = {
    ...basePayload,
    image_url: imageUrls[0],
    image_urls: imageUrls
  }

  let result = editingGallery.value
    ? await supabase.from('gallery_items').update(payload).eq('id', editingGallery.value.id)
    : await supabase.from('gallery_items').insert([payload])

  if (isMissingImageUrlsError(result.error)) {
    saving.value = false
    formError.value = imageUrlsSchemaMessage('gallery')
    return
  }

  const { error } = result

  saving.value = false

  if (error) {
    formError.value = error.message
    return
  }

  const wasEditing = Boolean(editingGallery.value)
  closeGalleryForm()
  showToast(wasEditing ? 'Gallery item updated.' : 'Gallery item added.')
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
  if (type === 'owner') ownerPhotoInput.value?.click()
}

async function uploadFile(event, type) {
  const files = Array.from(event.target.files || [])
  if (!files.length) return

  const invalidFile = files.find((file) => type === 'video' && file.size > maxVideoUploadBytes)
  if (invalidFile) {
    event.target.value = ''
    showToast(`${invalidFile.name} is ${formatFileSize(invalidFile.size)}. Video must be under ${videoUploadLimitLabel}. Compress or trim it first.`, 'error')
    return
  }

  if (type === 'image') uploadingImage.value = true
  if (type === 'video') uploadingVideo.value = true
  if (type === 'gallery') uploadingGallery.value = true
  if (type === 'owner') uploadingOwnerPhoto.value = true

  try {
    const uploadedUrls = []
    for (const file of files) {
      const extension = file.name.split('.').pop() || 'file'
      const folder = type === 'video' ? 'videos' : type === 'gallery' ? 'gallery' : type === 'owner' ? 'site' : 'products'
      const path = `${folder}/${Date.now()}-${Math.random().toString(36).slice(2, 10)}.${extension}`
      const { error: uploadError } = await supabase.storage.from('product-media').upload(path, file)

      if (uploadError) {
        applyUploadedUrls(type, uploadedUrls)
        showToast(uploadErrorMessage(uploadError, type), 'error')
        return
      }

      const { data } = supabase.storage.from('product-media').getPublicUrl(path)
      uploadedUrls.push(data.publicUrl)
    }

    applyUploadedUrls(type, uploadedUrls)
  } finally {
    event.target.value = ''
    if (type === 'image') uploadingImage.value = false
    if (type === 'video') uploadingVideo.value = false
    if (type === 'gallery') uploadingGallery.value = false
    if (type === 'owner') uploadingOwnerPhoto.value = false
  }
}

function applyUploadedUrls(type, uploadedUrls) {
  if (!uploadedUrls.length) return

  if (type === 'image') {
    productForm.image_urls = [...normalizeProductPhotos(productForm), ...uploadedUrls]
    productForm.image_url = productForm.image_urls[0] || ''
  }
  if (type === 'video') productForm.video_url = uploadedUrls[0] || ''
  if (type === 'gallery') {
    galleryForm.image_urls = [...normalizeGalleryPhotos(galleryForm), ...uploadedUrls]
    galleryForm.image_url = galleryForm.image_urls[0] || ''
  }
  if (type === 'owner') siteForm.owner_photo_url = uploadedUrls[0] || ''
}

function normalizeProductPhotos(product) {
  return [...new Set([...(Array.isArray(product.image_urls) ? product.image_urls : []), product.image_url].filter(Boolean))]
}

function removeProductPhoto(index) {
  productForm.image_urls.splice(index, 1)
  productForm.image_url = productForm.image_urls[0] || ''
}

function normalizeGalleryPhotos(item) {
  return [...new Set([...(Array.isArray(item.image_urls) ? item.image_urls : []), item.image_url].filter(Boolean))]
}

function removeGalleryPhoto(index) {
  galleryForm.image_urls.splice(index, 1)
  galleryForm.image_url = galleryForm.image_urls[0] || ''
}

function uploadErrorMessage(error, type) {
  const message = error?.message || 'Upload failed.'
  if (type === 'video' && message.toLowerCase().includes('limit')) {
    return `Video exceeds the storage upload limit. Keep it under ${videoUploadLimitLabel}, or trim/compress it and upload again.`
  }
  return message
}

function formatFileSize(bytes) {
  if (!bytes) return '0 MB'
  return `${(bytes / 1024 / 1024).toFixed(bytes >= 10 * 1024 * 1024 ? 0 : 1)} MB`
}

async function loadSiteSettings() {
  const { data, error } = await supabase.from('site_settings').select('*').eq('id', 'about').maybeSingle()
  if (error) {
    showToast('Run the latest schema.sql to enable Site Details.', 'error')
    return
  }
  if (data) resetReactive(siteForm, { ...defaultSiteForm(), ...data })
}

async function saveSiteSettings() {
  saving.value = true
  formError.value = ''

  const payload = {
    ...siteForm,
    id: 'about',
    updated_at: new Date().toISOString()
  }

  let { error } = await supabase.from('site_settings').upsert(payload)

  if (error?.message?.includes('owner_instagram')) {
    delete payload.owner_instagram
    const fallback = await supabase.from('site_settings').upsert(payload)
    error = fallback.error
  }

  saving.value = false

  if (error) {
    formError.value = `${error.message}. If this is the first time, run the latest schema.sql in Supabase.`
    return
  }

  showToast('Site details updated.')
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

async function loadAnalytics() {
  loadingAnalytics.value = true
  analyticsError.value = ''
  const { data, error } = await supabase
    .from('analytics_events')
    .select('*')
    .order('created_at', { ascending: false })
    .limit(500)

  if (error) {
    analyticsEvents.value = []
    analyticsError.value = `${error.message}. Run the latest schema.sql in Supabase to enable analytics.`
  } else {
    analyticsEvents.value = data || []
  }
  loadingAnalytics.value = false
}

function donutGradient(segments) {
  const total = segments.reduce((sum, segment) => sum + segment.count, 0)
  if (!total) return 'conic-gradient(#eadfd2 0deg 360deg)'

  let start = 0
  const stops = segments
    .filter((segment) => segment.count > 0)
    .map((segment) => {
      const end = start + (segment.count / total) * 360
      const stop = `${segment.color} ${start}deg ${end}deg`
      start = end
      return stop
    })

  return `conic-gradient(${stops.join(', ')})`
}

function isCustomerEvent(event) {
  const path = normalizePagePath(event.page_path || '')
  return !path.startsWith('/admin')
}

function normalizePagePath(path) {
  const clean = String(path || '/').split('?')[0].replace(/\/$/, '')
  return clean || '/'
}

function cleanAnalyticsName(value) {
  const text = String(value || '').trim()
  if (!text || text.toLowerCase() === 'undefined' || text.toLowerCase() === 'null') return 'Unnamed product'
  return text
}

onMounted(async () => {
  await Promise.all([loadProducts(), loadGallery(), loadSiteSettings(), loadAnalytics()])
})
</script>

<style scoped>
/* ============ design tokens ============ */
.admin-page {
  --ink: #241f1a;
  --ink-soft: #77695f;
  --paper: #fffaf4;
  --card: #ffffff;
  --card-soft: #fffdf8;
  --line: #eadfd2;
  --accent: #a85f33;
  --accent-deep: #79401f;
  --accent-tint: #f2e5d7;
  --good: #1f9d57;
  --good-tint: #e5f4e8;
  --bad: #a33b2f;
  --bad-tint: #fff0ef;
  --warn-tint: #fff7d8;
  --violet: #7b6fb0;

  min-height: 100vh;
  background: var(--paper);
  color: var(--ink);
}

* {
  box-sizing: border-box;
}

/* ============ header ============ */
.admin-header {
  position: sticky;
  top: 0;
  z-index: 100;
  border-bottom: 1px solid var(--line);
  background: rgba(255, 253, 248, 0.96);
  box-shadow: 0 8px 24px rgba(65, 42, 24, 0.05);
  backdrop-filter: blur(12px);
}

.admin-header-inner {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 14px;
  width: min(1280px, 94vw);
  margin: 0 auto;
  padding: 14px 0;
}

.nav-burger {
  display: none;
  flex-direction: column;
  gap: 4px;
  border: 0;
  background: none;
  cursor: pointer;
  padding: 6px;
}

.nav-burger span {
  width: 20px;
  height: 2px;
  background: var(--ink);
  border-radius: 2px;
}

.admin-brand {
  display: flex;
  gap: 12px;
  align-items: center;
  margin-right: auto;
}

.admin-brand-icon {
  display: grid;
  place-items: center;
  width: 42px;
  height: 42px;
  border-radius: 999px;
  background: var(--accent);
  color: #ffffff;
  font-weight: 900;
  flex: 0 0 auto;
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
  color: var(--ink);
  font-size: 18px;
  font-weight: 900;
}

.admin-brand-role {
  color: var(--ink-soft);
  font-size: 12px;
  font-weight: 900;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.admin-header-actions {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
  align-items: center;
}

.mobile-top-tabs {
  display: none;
}

.mobile-refresh-row {
  display: none;
}

/* ============ shell: sidebar + main ============ */
.admin-shell {
  display: grid;
  grid-template-columns: 240px minmax(0, 1fr);
  gap: 0;
  width: min(1280px, 94vw);
  margin: 0 auto;
}

.admin-sidebar {
  position: sticky;
  top: 76px;
  align-self: start;
  height: calc(100vh - 100px);
  display: flex;
  flex-direction: column;
  gap: 18px;
  padding: 22px 14px 22px 0;
}

.sidebar-top {
  display: none;
}

.sidebar-nav {
  display: grid;
  gap: 4px;
}

.sidebar-link {
  display: flex;
  align-items: center;
  gap: 12px;
  border: 0;
  border-radius: 14px;
  padding: 11px 12px;
  background: transparent;
  color: var(--ink-soft);
  cursor: pointer;
  font-weight: 850;
  text-align: left;
  transition: background 140ms ease, color 140ms ease;
}

.sidebar-link:hover {
  background: var(--accent-tint);
  color: var(--accent-deep);
}

.sidebar-link.active {
  background: var(--accent);
  color: #ffffff;
}

.sidebar-link-icon {
  display: grid;
  place-items: center;
  width: 22px;
  flex: 0 0 auto;
  font-size: 15px;
}

.sidebar-link-label {
  flex: 1;
}

.sidebar-link-count {
  border-radius: 999px;
  padding: 2px 8px;
  background: rgba(255, 255, 255, 0.25);
  font-size: 12px;
}

.sidebar-link:not(.active) .sidebar-link-count {
  background: var(--accent-tint);
  color: var(--accent-deep);
}

.sidebar-foot {
  display: none;
}

.nav-scrim {
  display: none;
}

/* ============ main body ============ */
.admin-body {
  min-width: 0;
  padding: 28px 0 100px 24px;
  border-left: 1px solid var(--line);
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
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
}

.tab-title {
  margin: 0 0 6px;
  color: var(--ink);
  font-size: 28px;
}

.tab-sub {
  margin: 0;
  color: var(--ink-soft);
}

/* ============ buttons ============ */
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
  transition: background 160ms ease, border-color 160ms ease, box-shadow 160ms ease, color 160ms ease, transform 160ms ease;
}

.admin-btn:hover {
  box-shadow: 0 10px 24px rgba(65, 42, 24, 0.1);
  transform: translateY(-1px);
}

.admin-btn:focus-visible,
.sidebar-link:focus-visible,
.mobile-top-tab:focus-visible,
.modal-close:focus-visible,
.upload-zone:focus-within,
.quick-action:focus-visible,
.attention-row:focus-visible {
  outline: 3px solid rgba(168, 95, 51, 0.24);
  outline-offset: 3px;
}

.admin-btn.small {
  min-height: 36px;
  padding: 7px 12px;
  font-size: 13px;
}

.admin-btn.primary {
  background: var(--accent);
  color: #ffffff;
}

.admin-btn.outline {
  border-color: #d8c8b8;
  background: var(--card);
  color: var(--ink);
}

.admin-btn.ghost {
  background: var(--accent-tint);
  color: var(--ink);
}

.admin-btn.warning {
  border-color: #eed987;
  background: var(--warn-tint);
  color: var(--accent-deep);
}

.admin-btn.danger {
  background: var(--bad-tint);
  color: var(--bad);
}

.admin-btn:disabled {
  cursor: not-allowed;
  opacity: 0.65;
}

/* ============ quick actions ============ */
.quick-actions {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 12px;
  margin-bottom: 20px;
}

.quick-action {
  display: flex;
  align-items: center;
  gap: 12px;
  text-align: left;
  border: 1px solid var(--line);
  border-radius: 16px;
  padding: 14px 16px;
  background: var(--card);
  cursor: pointer;
  transition: border-color 140ms ease, box-shadow 140ms ease, transform 140ms ease;
}

.quick-action:hover {
  border-color: var(--accent);
  box-shadow: 0 14px 30px rgba(65, 42, 24, 0.08);
  transform: translateY(-1px);
}

.quick-action-icon {
  display: grid;
  place-items: center;
  width: 38px;
  height: 38px;
  flex: 0 0 auto;
  border-radius: 12px;
  background: var(--accent-tint);
  color: var(--accent-deep);
  font-weight: 900;
}

.quick-action strong {
  display: block;
  color: var(--ink);
  font-size: 14px;
}

.quick-action small {
  display: block;
  margin-top: 2px;
  color: var(--ink-soft);
  font-size: 12px;
}

/* ============ metric grid ============ */
.metric-grid {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 14px;
  margin-bottom: 18px;
}

.metric-card {
  padding: 18px;
  border: 1px solid var(--line);
  border-radius: 18px;
  background: linear-gradient(180deg, var(--card), var(--card-soft));
  box-shadow: 0 14px 34px rgba(65, 42, 24, 0.07);
}

.metric-card.accent {
  border-color: #d8c8b8;
  background: linear-gradient(180deg, #fff6ec, #fff0e0);
}

.metric-card span {
  color: var(--accent-deep);
  font-size: 12px;
  font-weight: 900;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.metric-card strong {
  display: block;
  margin: 6px 0 4px;
  color: var(--ink);
  font-size: 30px;
  line-height: 1;
}

.metric-card p {
  margin: 0;
  color: var(--ink-soft);
  font-size: 13px;
  font-weight: 700;
}

/* ============ needs attention ============ */
.attention-panel {
  border: 1px solid var(--line);
  border-radius: 18px;
  background: var(--card);
  padding: 18px;
  margin-bottom: 18px;
}

.attention-list {
  display: grid;
  gap: 8px;
}

.attention-row {
  display: flex;
  align-items: center;
  gap: 12px;
  width: 100%;
  border: 1px solid var(--line);
  border-radius: 14px;
  padding: 12px 14px;
  background: var(--card-soft);
  cursor: pointer;
  text-align: left;
  transition: border-color 140ms ease, background 140ms ease;
}

.attention-row:hover {
  border-color: var(--accent);
  background: #ffffff;
}

.attention-dot {
  width: 10px;
  height: 10px;
  flex: 0 0 auto;
  border-radius: 999px;
}

.attention-dot.warn {
  background: #d39a1f;
}

.attention-dot.danger {
  background: var(--bad);
}

.attention-dot.info {
  background: var(--violet);
}

.attention-text {
  flex: 1;
  min-width: 0;
}

.attention-text strong {
  display: block;
  color: var(--ink);
  font-size: 14px;
}

.attention-text small {
  display: block;
  margin-top: 2px;
  color: var(--ink-soft);
  font-size: 12px;
}

.attention-go {
  flex: 0 0 auto;
  color: var(--accent);
  font-size: 13px;
  font-weight: 900;
}

/* ============ analytics ============ */
.analytics-panel {
  border: 1px solid var(--line);
  border-radius: 18px;
  background: linear-gradient(180deg, var(--card-soft) 0%, #fff9f1 100%);
  box-shadow: 0 14px 34px rgba(65, 42, 24, 0.07);
  padding: 18px;
  margin-bottom: 16px;
}

.analytics-panels {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 16px;
}

.analytics-panels .analytics-panel {
  margin-bottom: 0;
}

.panel-heading {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  margin-bottom: 16px;
}

.panel-heading h3 {
  margin: 0;
  color: var(--ink);
  font-size: 18px;
}

.panel-heading span {
  color: var(--accent-deep);
  font-size: 12px;
  font-weight: 900;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.trend-chart {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(18px, 1fr));
  align-items: end;
  gap: 9px;
  min-height: 220px;
  padding: 18px 10px 6px;
  border: 1px solid var(--line);
  border-radius: 18px;
  background:
    linear-gradient(180deg, rgba(234, 223, 210, 0.35) 1px, transparent 1px) 0 0 / 100% 25%,
    linear-gradient(180deg, var(--card-soft), #fff8ef);
}

.trend-day {
  display: grid;
  align-items: end;
  gap: 8px;
  min-width: 0;
  height: 100%;
}

.trend-bar-stack {
  display: flex;
  align-items: end;
  justify-content: center;
  gap: 2px;
  height: 160px;
}

.trend-bar-stack span {
  display: block;
  width: 8px;
  min-height: 0;
  border-radius: 999px 999px 3px 3px;
  box-shadow: 0 5px 14px rgba(65, 42, 24, 0.08);
}

.trend-page {
  background: #d7c6b4;
}

.trend-product {
  background: var(--accent);
}

.trend-whatsapp {
  background: var(--good);
}

.trend-day small {
  overflow: hidden;
  color: var(--ink-soft);
  font-size: 10px;
  font-weight: 800;
  text-align: center;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.trend-line-chart {
  min-height: 236px;
  border: 1px solid var(--line);
  border-radius: 18px;
  padding: 16px 12px 8px;
  background:
    linear-gradient(180deg, rgba(234, 223, 210, 0.35) 1px, transparent 1px) 0 18px / 100% 25%,
    linear-gradient(180deg, var(--card-soft), #fff8ef);
}

.trend-line-chart svg {
  display: block;
  width: 100%;
  height: 178px;
  overflow: visible;
}

.trend-grid-line {
  stroke: rgba(119, 105, 95, 0.14);
  stroke-width: 0.5;
}

.trend-line {
  fill: none;
  stroke-linecap: round;
  stroke-linejoin: round;
  stroke-width: 2.8;
  vector-effect: non-scaling-stroke;
}

.trend-line.page,
.trend-dot.page {
  stroke: #d7c6b4;
  fill: #d7c6b4;
}

.trend-line.product,
.trend-dot.product {
  stroke: var(--accent);
  fill: var(--accent);
}

.trend-line.whatsapp,
.trend-dot.whatsapp {
  stroke: var(--good);
  fill: var(--good);
}

.trend-line.total,
.trend-dot.total,
.legend-dot.total {
  stroke: var(--accent);
  fill: var(--accent);
  background: var(--accent);
}

.trend-line-chart.simple svg {
  height: 158px;
}

.chart-legend.simple {
  justify-content: flex-start;
}

.trend-dot {
  cursor: help;
  vector-effect: non-scaling-stroke;
}

.trend-dot:hover {
  stroke: var(--ink);
  stroke-width: 1.2;
}

.trend-axis {
  display: grid;
  grid-template-columns: repeat(14, minmax(0, 1fr));
  gap: 4px;
  margin-top: 8px;
}

.trend-axis span {
  overflow: hidden;
  color: var(--ink-soft);
  font-size: 10px;
  font-weight: 800;
  text-align: center;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.chart-legend {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  margin-top: 12px;
  color: var(--ink-soft);
  font-size: 13px;
  font-weight: 800;
}

.chart-legend span {
  display: inline-flex;
  align-items: center;
  gap: 6px;
}

.legend-dot {
  width: 9px;
  height: 9px;
  border-radius: 99px;
}

.legend-dot.page {
  background: #d7c6b4;
}

.legend-dot.product {
  background: var(--accent);
}

.legend-dot.whatsapp {
  background: var(--good);
}

.donut-layout {
  display: grid;
  grid-template-columns: 120px minmax(0, 1fr);
  gap: 16px;
  align-items: center;
}

.donut-chart {
  display: grid;
  place-items: center;
  width: 120px;
  height: 120px;
  border-radius: 50%;
  box-shadow: inset 0 0 0 1px rgba(65, 42, 24, 0.08), 0 14px 28px rgba(65, 42, 24, 0.08);
}

.donut-chart > div {
  display: grid;
  place-items: center;
  width: 72px;
  height: 72px;
  border-radius: 50%;
  background: var(--card-soft);
  text-align: center;
}

.donut-chart strong {
  color: var(--ink);
  font-size: 22px;
  line-height: 1;
}

.donut-chart span {
  color: var(--ink-soft);
  font-size: 11px;
  font-weight: 900;
  letter-spacing: 0.06em;
  text-transform: uppercase;
}

.donut-legend {
  display: grid;
  gap: 9px;
}

.donut-legend span {
  display: grid;
  grid-template-columns: 10px minmax(0, 1fr) auto;
  gap: 8px;
  align-items: center;
  color: #5f5147;
  font-size: 13px;
  font-weight: 800;
}

.donut-legend i {
  width: 10px;
  height: 10px;
  border-radius: 50%;
}

.donut-legend strong {
  color: var(--ink);
}

.interest-list {
  display: grid;
  gap: 8px;
}

.interest-row {
  display: flex;
  justify-content: space-between;
  gap: 12px;
  min-width: 0;
  border: 1px solid var(--line);
  border-radius: 14px;
  padding: 12px;
  background: var(--card);
}

.interest-row div {
  min-width: 0;
}

.interest-row strong {
  display: block;
  overflow: hidden;
  color: var(--ink);
  font-size: 14px;
  line-height: 1.25;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.interest-row span {
  display: block;
  margin-top: 5px;
  color: var(--ink-soft);
  font-size: 12px;
  font-weight: 800;
}

.interest-row em {
  flex: 0 0 auto;
  display: grid;
  place-items: center;
  width: 34px;
  height: 34px;
  border-radius: 50%;
  background: var(--accent-tint);
  color: var(--accent-deep);
  font-style: normal;
  font-weight: 900;
}

.interest-bars {
  display: grid;
  gap: 12px;
}

.interest-bar-row {
  display: grid;
  grid-template-columns: minmax(180px, 0.55fr) minmax(120px, 1fr) 42px;
  gap: 12px;
  align-items: center;
  border: 1px solid var(--line);
  border-radius: 14px;
  padding: 12px;
  background: var(--card);
  cursor: help;
  transition: border-color 160ms ease, box-shadow 160ms ease, transform 160ms ease;
}

.interest-bar-row:hover {
  border-color: rgba(168, 95, 51, 0.42);
  box-shadow: 0 12px 28px rgba(65, 42, 24, 0.08);
  transform: translateY(-1px);
}

.interest-bar-meta {
  min-width: 0;
}

.interest-bar-meta strong {
  display: block;
  overflow: hidden;
  color: var(--ink);
  font-size: 14px;
  line-height: 1.25;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.interest-bar-meta span {
  display: block;
  margin-top: 5px;
  color: var(--ink-soft);
  font-size: 12px;
  font-weight: 800;
}

.interest-bar-track {
  overflow: hidden;
  height: 14px;
  border-radius: 999px;
  background: var(--accent-tint);
}

.interest-bar-track span {
  display: block;
  height: 100%;
  border-radius: inherit;
  background: linear-gradient(90deg, var(--accent), var(--good));
}

.interest-bar-row em {
  display: grid;
  place-items: center;
  width: 34px;
  height: 34px;
  border-radius: 50%;
  background: var(--accent-tint);
  color: var(--accent-deep);
  font-style: normal;
  font-weight: 900;
}

.mini-empty {
  margin: 0;
  color: var(--ink-soft);
  font-size: 14px;
}

/* ============ search/filter toolbar ============ */
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
  color: var(--accent-deep);
  font-size: 12px;
  font-weight: 900;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.admin-search input,
.admin-filter {
  width: 100%;
  min-height: 44px;
  border: 1px solid var(--line);
  border-radius: 999px;
  padding: 0 15px;
  background: var(--card);
  color: var(--ink);
  outline: none;
  box-shadow: 0 10px 26px rgba(65, 42, 24, 0.05);
}

.admin-search input:focus,
.admin-filter:focus {
  border-color: var(--accent);
  box-shadow: 0 0 0 3px rgba(168, 95, 51, 0.12);
}

/* ============ states ============ */
.loading-wrap,
.empty-state {
  display: grid;
  place-items: center;
  gap: 12px;
  min-height: 260px;
  padding: 34px;
  border: 1px dashed var(--line);
  border-radius: 20px;
  background: var(--card-soft);
  color: var(--ink-soft);
  text-align: center;
}

.empty-state.compact {
  min-height: 180px;
}

.spinner {
  width: 28px;
  height: 28px;
  border: 3px solid var(--line);
  border-top-color: var(--accent);
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
  background: var(--accent-tint);
  color: var(--accent-deep);
  font-weight: 900;
}

/* ============ products table ============ */
.products-table {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
  gap: 16px;
}

.products-table-head {
  display: none;
}

.products-row {
  display: grid;
  grid-template-rows: auto auto auto 1fr;
  gap: 12px;
  overflow: hidden;
  border: 1px solid var(--line);
  border-radius: 18px;
  padding: 12px;
  background: var(--card);
  box-shadow: 0 16px 42px rgba(65, 42, 24, 0.08);
}

.products-row-info {
  display: grid;
  gap: 10px;
}

.products-row-img-wrap {
  display: grid;
  place-items: center;
  width: 100%;
  aspect-ratio: 4 / 3;
  overflow: hidden;
  border-radius: 14px;
  background: var(--accent-tint);
}

.products-row-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.products-row-img-placeholder {
  color: var(--accent-deep);
  font-size: 11px;
  font-weight: 900;
  text-align: center;
}

.products-row-name {
  color: var(--ink);
  font-size: 17px;
  line-height: 1.25;
  font-weight: 900;
}

.products-row-cat {
  color: var(--ink-soft);
  font-size: 13px;
}

.products-row-price {
  color: var(--accent-deep);
  font-size: 20px;
  font-weight: 900;
}

.products-row-status,
.products-row-actions {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
  align-items: center;
}

.products-row-actions {
  align-self: end;
}

.badge {
  display: inline-flex;
  border-radius: 999px;
  padding: 5px 9px;
  font-size: 12px;
  font-weight: 900;
}

.badge.available {
  background: var(--good-tint);
  color: #266b35;
}

.badge.sold {
  background: var(--bad-tint);
  color: var(--bad);
}

.badge.featured {
  background: var(--accent-tint);
  color: var(--accent-deep);
}

/* ============ product/gallery card shared UI ============ */
.products-admin-grid {
  grid-template-columns: repeat(auto-fill, minmax(230px, 1fr));
}

.product-admin-card.sold {
  opacity: 0.82;
}

.product-admin-img-wrap {
  min-height: 220px;
}

.product-missing-image {
  display: grid;
  place-items: center;
  align-content: center;
  gap: 6px;
  width: 100%;
  height: 100%;
  padding: 22px;
  color: var(--accent-deep);
  text-align: center;
  background:
    radial-gradient(circle at 30% 22%, rgba(255, 255, 255, 0.9), transparent 34%),
    linear-gradient(135deg, #fff7eb, var(--accent-tint));
}

.product-missing-icon {
  display: grid;
  place-items: center;
  width: 46px;
  height: 46px;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.78);
  box-shadow: 0 10px 24px rgba(65, 42, 24, 0.08);
  font-size: 22px;
}

.product-missing-image strong {
  font-size: 14px;
  font-weight: 950;
}

.product-missing-image small {
  max-width: 180px;
  color: var(--ink-soft);
  font-size: 12px;
  font-weight: 750;
  line-height: 1.35;
}

.product-admin-body {
  display: grid;
  gap: 8px;
}

.product-card-meta {
  display: grid;
  gap: 10px;
  margin-top: 2px;
}

.product-card-price {
  color: var(--accent-deep);
  font-size: 20px;
  line-height: 1;
}

.product-badges {
  display: flex;
  flex-wrap: wrap;
  gap: 7px;
  align-items: center;
}

.product-status-label {
  background: rgba(163, 59, 47, 0.88);
}

.product-admin-actions .admin-btn {
  flex: 1 1 auto;
  white-space: nowrap;
}

/* ============ gallery grid ============ */
.gallery-admin-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(210px, 1fr));
  gap: 16px;
}

.gallery-admin-card {
  overflow: hidden;
  border: 1px solid var(--line);
  border-radius: 18px;
  background: var(--card);
  box-shadow: 0 16px 42px rgba(65, 42, 24, 0.08);
}

.gallery-admin-card.hidden {
  opacity: 0.58;
}

.gallery-admin-img-wrap {
  position: relative;
  overflow: hidden;
  aspect-ratio: 1 / 1;
  background: var(--accent-tint);
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
  color: var(--accent-deep);
  font-size: 12px;
  font-weight: 900;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.gallery-admin-name {
  color: var(--ink);
  font-weight: 900;
}

.gallery-admin-actions {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
  padding: 12px 14px;
  border-top: 1px solid var(--line);
}

/* ============ settings ============ */
.settings-layout {
  display: grid;
  grid-template-columns: minmax(0, 1fr);
  gap: 18px;
  align-items: start;
}

.settings-panel {
  border: 1px solid var(--line);
  border-radius: 20px;
  padding: 22px;
  background: var(--card);
  box-shadow: 0 16px 42px rgba(65, 42, 24, 0.08);
}

.settings-actions {
  display: flex;
  justify-content: flex-end;
  margin-top: 18px;
}

.settings-preview {
  position: sticky;
  top: 96px;
}

.preview-label {
  margin: 0 0 8px;
  color: var(--accent-deep);
  font-size: 12px;
  font-weight: 900;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.preview-card {
  border: 1px solid var(--line);
  border-radius: 18px;
  padding: 18px;
  background: linear-gradient(180deg, var(--card), var(--card-soft));
  box-shadow: 0 14px 34px rgba(65, 42, 24, 0.07);
}

.preview-photo {
  width: 100%;
  aspect-ratio: 4 / 3;
  border-radius: 12px;
  object-fit: cover;
  margin-bottom: 14px;
}

.preview-photo.placeholder {
  display: grid;
  place-items: center;
  background: var(--accent-tint);
  color: var(--accent-deep);
  font-weight: 900;
}

.preview-card h4 {
  margin: 0 0 8px;
  color: var(--ink);
  font-size: 17px;
}

.preview-card p {
  margin: 0 0 14px;
  color: var(--ink-soft);
  font-size: 13px;
  line-height: 1.5;
}

.preview-contact {
  display: flex;
  flex-direction: column;
  gap: 4px;
  padding-top: 12px;
  border-top: 1px solid var(--line);
  font-size: 13px;
  font-weight: 800;
  color: var(--ink);
}

.preview-note {
  margin: 10px 2px 0;
  color: var(--ink-soft);
  font-size: 12px;
}

/* ============ forms / modals ============ */
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
  color: var(--ink);
  font-weight: 850;
}

.field input,
.field textarea,
.field select {
  width: 100%;
  min-height: 44px;
  border: 1px solid var(--line);
  border-radius: 12px;
  padding: 12px 13px;
  color: var(--ink);
  background: var(--card-soft);
  outline: none;
  transition: border-color 160ms ease, box-shadow 160ms ease, background 160ms ease;
}

.field input:focus,
.field textarea:focus,
.field select:focus {
  border-color: var(--accent);
  background: #ffffff;
  box-shadow: 0 0 0 3px rgba(168, 95, 51, 0.12);
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
  background: var(--paper);
  cursor: pointer;
  transition: border-color 160ms ease, background 160ms ease, box-shadow 160ms ease;
}

.upload-zone:hover {
  border-color: var(--accent);
  background: #fff8ef;
  box-shadow: 0 12px 30px rgba(65, 42, 24, 0.06);
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
  color: var(--ink-soft);
  padding: 14px;
  text-align: center;
}

.upload-placeholder span {
  max-width: 340px;
  line-height: 1.45;
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

.photo-preview-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(110px, 1fr));
  gap: 10px;
  margin-top: 10px;
}

.photo-preview {
  position: relative;
  overflow: hidden;
  border: 1px solid var(--line);
  border-radius: 14px;
  aspect-ratio: 1 / 1;
  background: var(--accent-tint);
  box-shadow: 0 10px 24px rgba(65, 42, 24, 0.08);
}

.photo-preview img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.photo-preview span {
  position: absolute;
  top: 8px;
  left: 8px;
  border-radius: 999px;
  padding: 4px 8px;
  background: var(--accent);
  color: #ffffff;
  font-size: 11px;
  font-weight: 900;
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
  min-height: 32px;
}

.form-error {
  margin: 14px 0 0;
  color: var(--bad);
  font-weight: 850;
}

.confirm-text {
  color: #5f5147;
  line-height: 1.65;
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
  position: sticky;
  top: 0;
  z-index: 2;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid var(--line);
  background: #ffffff;
}

.modal-title {
  margin: 0;
  color: var(--ink);
  font-size: 21px;
}

.modal-close {
  border: 0;
  border-radius: 999px;
  padding: 8px 12px;
  background: var(--accent-tint);
  color: var(--ink);
  cursor: pointer;
  font-weight: 900;
}

.modal-body {
  overflow-y: auto;
  padding: 22px;
}

.modal-footer {
  position: sticky;
  bottom: 0;
  z-index: 2;
  display: flex;
  gap: 8px;
  justify-content: flex-end;
  border-top: 1px solid var(--line);
  background: #ffffff;
}

.toast {
  position: fixed;
  right: 22px;
  bottom: 90px;
  z-index: 800;
  border-radius: 999px;
  padding: 12px 16px;
  background: var(--good);
  color: #ffffff;
  font-weight: 900;
  box-shadow: 0 16px 42px rgba(65, 42, 24, 0.18);
}

.toast.error {
  background: var(--bad);
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 160ms ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

/* ============ responsive ============ */
@media (max-width: 980px) {
  .admin-shell {
    grid-template-columns: 1fr;
  }

  .nav-burger {
    display: flex;
  }

  .admin-sidebar {
    position: fixed;
    top: 0;
    left: 0;
    z-index: 600;
    width: min(280px, 84vw);
    height: 100dvh;
    background: #ffffff;
    box-shadow: 0 24px 60px rgba(0, 0, 0, 0.22);
    padding: 18px;
    transform: translateX(-100%);
    transition: transform 220ms ease;
  }

  .admin-sidebar.open {
    transform: translateX(0);
  }

  .sidebar-top {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 6px;
  }

  .drawer-only {
    display: flex;
  }

  .nav-close {
    border: 0;
    background: transparent;
    width: auto;
    height: auto;
    padding: 4px;
    color: var(--accent);
    cursor: pointer;
    font-size: 22px;
    line-height: 1;
    font-weight: 900;
  }

  .sidebar-foot {
    display: flex;
    flex-direction: column;
    gap: 8px;
    margin-top: auto;
  }

  .nav-scrim {
    display: block;
    position: fixed;
    inset: 0;
    z-index: 590;
    background: rgba(26, 23, 20, 0.45);
  }

  .admin-header-actions {
    display: none;
  }

  .dashboard-refresh-top {
    display: none;
  }

  .mobile-refresh-row {
    display: flex;
    justify-content: flex-start;
    margin: -4px 0 12px;
  }

  .mobile-top-tabs {
    display: flex;
    gap: 8px;
    overflow-x: auto;
    border-top: 1px solid rgba(234, 223, 210, 0.62);
    padding: 8px 14px 10px;
    scrollbar-width: none;
  }

  .mobile-top-tabs::-webkit-scrollbar {
    display: none;
  }

  .mobile-top-tab {
    flex: 0 0 auto;
    display: inline-flex;
    align-items: center;
    gap: 6px;
    border: 1px solid var(--line);
    border-radius: 999px;
    padding: 9px 12px;
    background: #ffffff;
    color: var(--ink-soft);
    cursor: pointer;
    font-size: 13px;
    font-weight: 900;
    text-decoration: none;
  }

  .mobile-top-tab.active {
    border-color: var(--accent);
    background: var(--accent);
    color: #ffffff;
  }

  .mobile-top-tab.shop {
    border-color: rgba(31, 157, 87, 0.28);
    background: #effaf3;
    color: #207942;
  }

  .admin-body {
    border-left: 0;
    padding: 22px 0 34px;
  }

  .quick-actions {
    grid-template-columns: 1fr;
  }

  .metric-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }

  .analytics-panels {
    grid-template-columns: 1fr;
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

  .settings-layout {
    grid-template-columns: 1fr;
  }

}

@media (max-width: 560px) {
  .metric-grid {
    gap: 10px;
  }

  .metric-card {
    min-height: 120px;
    padding: 15px;
  }

  .metric-card span {
    font-size: 10px;
  }

  .metric-card strong {
    font-size: 28px;
  }

  .trend-chart {
    min-height: 170px;
  }

  .trend-bar-stack {
    height: 110px;
  }

  .trend-line-chart {
    min-height: 178px;
    padding: 12px 10px 8px;
  }

  .trend-line-chart svg {
    height: 120px;
  }

  .trend-axis span {
    font-size: 9px;
  }

  .donut-layout {
    grid-template-columns: 100px minmax(0, 1fr);
    gap: 12px;
  }

  .donut-chart {
    width: 100px;
    height: 100px;
  }

  .donut-chart > div {
    width: 62px;
    height: 62px;
  }

  .donut-chart strong {
    font-size: 18px;
  }

  .interest-bar-row {
    grid-template-columns: 1fr 44px;
    gap: 8px;
  }

  .interest-bar-track {
    grid-column: 1 / -1;
    grid-row: 2;
  }

  .tab-header {
    align-items: flex-start;
    flex-direction: column;
  }

  .tab-actions {
    width: 100%;
    align-items: stretch;
    flex-direction: column;
  }

  .admin-btn {
    flex: 1;
  }

  .tab-title {
    font-size: 30px;
    line-height: 1.1;
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
    border: 1px solid var(--line);
    border-radius: 18px;
    padding: 14px;
    background: #ffffff;
    box-shadow: 0 12px 30px rgba(65, 42, 24, 0.06);
  }

  .products-row-info {
    align-items: flex-start;
  }

  .products-row-img-wrap {
    width: 100%;
    height: auto;
    aspect-ratio: 4 / 3;
  }

  .products-row-name {
    font-size: 18px;
    line-height: 1.18;
  }

  .products-row-price {
    font-size: 20px;
  }

  .products-row-actions {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
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

  .products-admin-grid {
    grid-template-columns: 1fr;
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

  .settings-panel {
    padding: 16px;
    border-radius: 18px;
  }

  .settings-actions .admin-btn {
    width: 100%;
  }

  .modal-overlay {
    padding: 12px;
    align-items: flex-end;
  }

  .modal {
    width: 100%;
    max-height: calc(100dvh - 24px);
    border-radius: 18px;
  }

  .modal-header,
  .modal-footer {
    padding: 14px 16px;
  }

  .modal-body {
    padding: 16px;
  }

  .modal-title {
    font-size: 19px;
  }

  .modal-footer {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 8px;
  }

  .modal-footer .admin-btn {
    width: 100%;
  }

  .upload-zone {
    min-height: 118px;
  }

  .photo-preview-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 8px;
  }

  .photo-preview {
    border-radius: 12px;
  }

  .photo-preview span {
    top: 7px;
    left: 7px;
    padding: 4px 7px;
    font-size: 10px;
  }

  .photo-preview .upload-remove {
    right: 7px;
    bottom: 7px;
    top: auto;
    min-height: 34px;
    padding: 7px 10px;
    font-size: 12px;
  }
}


/* ============ updated customer trend bar chart ============ */
.panel-subtitle {
  margin: 4px 0 0;
  color: var(--ink-soft);
  font-size: 13px;
  font-weight: 750;
}

.trend-heading {
  align-items: flex-start;
}

.trend-summary-strip {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 10px;
  margin-bottom: 14px;
}

.trend-summary-card {
  border: 1px solid var(--line);
  border-radius: 16px;
  padding: 12px 14px;
  background: rgba(255, 255, 255, 0.72);
}

.trend-summary-card span {
  display: block;
  color: var(--accent-deep);
  font-size: 10px;
  font-weight: 950;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.trend-summary-card strong {
  display: block;
  margin-top: 5px;
  color: var(--ink);
  font-size: 22px;
  line-height: 1.05;
}

.trend-summary-card small {
  display: block;
  margin-top: 3px;
  color: var(--ink-soft);
  font-size: 11px;
  font-weight: 800;
}

.customer-trend-bars {
  display: grid;
  grid-template-columns: repeat(14, minmax(0, 1fr));
  align-items: end;
  gap: 8px;
  min-height: 210px;
  border: 1px solid var(--line);
  border-radius: 18px;
  padding: 18px 14px 10px;
  background:
    linear-gradient(180deg, rgba(234, 223, 210, 0.34) 1px, transparent 1px) 0 18px / 100% 25%,
    linear-gradient(180deg, var(--card-soft), #fff8ef);
}

.customer-trend-day {
  position: relative;
  display: grid;
  grid-template-rows: 1fr 18px;
  align-items: end;
  gap: 8px;
  min-width: 0;
  height: 100%;
}

.customer-trend-bar-wrap {
  position: relative;
  display: flex;
  align-items: end;
  justify-content: center;
  height: 156px;
}

.customer-trend-bar {
  display: block;
  width: min(100%, 22px);
  min-height: 4px;
  border-radius: 999px 999px 6px 6px;
  background: linear-gradient(180deg, var(--accent), #d79b63);
  box-shadow: 0 8px 18px rgba(168, 95, 51, 0.18);
  transition: transform 160ms ease, filter 160ms ease, box-shadow 160ms ease;
}

.customer-trend-day.empty .customer-trend-bar {
  background: #eadfd2;
  box-shadow: none;
}

.customer-trend-day:hover .customer-trend-bar,
.customer-trend-day:focus-within .customer-trend-bar {
  filter: brightness(0.98);
  transform: translateY(-3px);
  box-shadow: 0 12px 24px rgba(168, 95, 51, 0.25);
}

.customer-trend-day::after {
  content: attr(data-tooltip);
  position: absolute;
  left: 50%;
  bottom: calc(100% + 10px);
  z-index: 3;
  width: max-content;
  max-width: 240px;
  padding: 9px 11px;
  border: 1px solid var(--line);
  border-radius: 12px;
  background: var(--ink);
  color: #ffffff;
  font-size: 11px;
  font-weight: 850;
  line-height: 1.35;
  opacity: 0;
  pointer-events: none;
  transform: translate(-50%, 6px);
  transition: opacity 140ms ease, transform 140ms ease;
  white-space: normal;
}

.customer-trend-day:hover::after,
.customer-trend-day:focus-within::after {
  opacity: 1;
  transform: translate(-50%, 0);
}

.customer-trend-day small {
  overflow: hidden;
  color: var(--ink-soft);
  font-size: 10px;
  font-weight: 850;
  text-align: center;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.trend-note {
  margin-top: 10px;
}

/* ============ updated top interest donut ============ */
.top-interest-donut-layout {
  display: grid;
  grid-template-columns: 160px minmax(0, 1fr);
  align-items: center;
  gap: 18px;
}

.top-interest-donut {
  display: grid;
  place-items: center;
  width: 154px;
  height: 154px;
  border-radius: 50%;
  box-shadow: inset 0 0 0 1px rgba(65, 42, 24, 0.08), 0 18px 34px rgba(65, 42, 24, 0.08);
}

.top-interest-donut > div {
  display: grid;
  place-items: center;
  width: 92px;
  height: 92px;
  border-radius: 50%;
  background: var(--card-soft);
  text-align: center;
}

.top-interest-donut strong {
  color: var(--ink);
  font-size: 26px;
  line-height: 1;
}

.top-interest-donut span {
  margin-top: 4px;
  color: var(--ink-soft);
  font-size: 11px;
  font-weight: 950;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.top-interest-legend {
  display: grid;
  gap: 10px;
  min-width: 0;
}

.top-interest-legend span {
  display: grid;
  grid-template-columns: 12px minmax(0, 1fr) auto;
  align-items: center;
  gap: 9px;
  min-width: 0;
  border: 1px solid var(--line);
  border-radius: 999px;
  padding: 9px 10px;
  background: rgba(255, 255, 255, 0.68);
}

.top-interest-legend i {
  width: 10px;
  height: 10px;
  border-radius: 50%;
}

.top-interest-legend em {
  overflow: hidden;
  color: var(--ink);
  font-style: normal;
  font-size: 13px;
  font-weight: 850;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.top-interest-legend strong {
  display: grid;
  place-items: center;
  min-width: 30px;
  height: 30px;
  border-radius: 999px;
  background: var(--accent-tint);
  color: var(--accent-deep);
  font-size: 13px;
}

@media (max-width: 720px) {
  .trend-summary-strip {
    grid-template-columns: 1fr;
  }

  .customer-trend-bars {
    gap: 5px;
    min-height: 178px;
    padding: 14px 10px 8px;
  }

  .customer-trend-bar-wrap {
    height: 122px;
  }

  .customer-trend-bar {
    width: min(100%, 16px);
  }

  .customer-trend-day::after {
    display: none;
  }

  .top-interest-donut-layout {
    grid-template-columns: 1fr;
    justify-items: center;
  }

  .top-interest-legend {
    width: 100%;
  }
}
</style>
