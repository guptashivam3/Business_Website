# Flowchart

## Full System Flow

```text
Admin Login
    ↓
Admin Dashboard
    ↓
Add/Edit Product
    ↓
Upload Image/Video
    ↓
Save Product in Supabase
    ↓
Product appears on Shop Page
    ↓
Customer opens website link
    ↓
Customer views product
    ↓
Customer clicks:
    ├── WhatsApp Order
    └── UPI QR Payment
```

## Admin Flow

```text
/admin
  ↓
Login with email/password
  ↓
Dashboard
  ↓
Options:
  ├── Add Product
  ├── Edit Product
  ├── Delete Product
  ├── Mark Sold Out
  ├── Change Price
  ├── Upload Photos
  └── Add Category
```

## Customer Flow

```text
Home / Shop
   ↓
Product Grid
   ↓
Product Details
   ↓
Customer sees:
   ├── Photos
   ├── Price
   ├── Description
   ├── Availability
   ├── WhatsApp Order button
   └── UPI QR
```
