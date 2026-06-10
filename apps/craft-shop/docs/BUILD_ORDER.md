# Build Order

## Step 1: Supabase Setup

- Create Supabase project
- Create tables using `apps/craft-shop/sql/schema.sql`
- Create storage bucket named `product-media`
- Enable email/password auth
- Create one admin user manually in Supabase Auth

## Step 2: Frontend Setup

```bash
cd apps/craft-shop/frontend
npm install
npm run dev
```

## Step 3: Admin Login

Build `/admin/login`.

## Step 4: Admin Dashboard

Build product CRUD first.

## Step 5: Shop Page

Build public product grid.

## Step 6: Product Page

Build product detail page with WhatsApp and UPI.

## Step 7: Deploy

Deploy frontend to Vercel.
