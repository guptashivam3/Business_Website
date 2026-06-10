-- Handmade Craft Shop Supabase Schema

create extension if not exists "uuid-ossp";
create extension if not exists "pgcrypto";

create table if not exists public.categories (
  id uuid primary key default uuid_generate_v4(),
  name text not null unique,
  slug text not null unique,
  sort_order integer default 0,
  created_at timestamptz default now()
);

create table if not exists public.products (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  slug text not null unique,
  description text,
  price numeric(10,2) not null default 0,
  category text,
  category_id uuid references public.categories(id) on delete set null,
  image_url text,
  video_url text,
  is_available boolean default true,
  is_featured boolean default false,
  sort_order integer default 0,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table public.products
add column if not exists category text;

create table if not exists public.gallery_items (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text,
  category text,
  image_url text not null,
  is_visible boolean default true,
  created_at timestamptz default now()
);

create table if not exists public.orders (
  id uuid primary key default uuid_generate_v4(),
  product_id uuid references public.products(id) on delete set null,
  customer_name text,
  customer_phone text,
  message text,
  status text default 'new',
  created_at timestamptz default now()
);

alter table public.categories enable row level security;
alter table public.products enable row level security;
alter table public.gallery_items enable row level security;
alter table public.orders enable row level security;

drop policy if exists "Public can read categories" on public.categories;
drop policy if exists "Public can read products" on public.products;
drop policy if exists "Public can read visible gallery items" on public.gallery_items;
drop policy if exists "Authenticated users can manage categories" on public.categories;
drop policy if exists "Authenticated users can manage products" on public.products;
drop policy if exists "Authenticated users can manage gallery items" on public.gallery_items;
drop policy if exists "Authenticated users can read orders" on public.orders;
drop policy if exists "Anyone can create order inquiry" on public.orders;

-- Public can read categories and available products
create policy "Public can read categories"
on public.categories for select
using (true);

create policy "Public can read products"
on public.products for select
using (true);

create policy "Public can read visible gallery items"
on public.gallery_items for select
using (is_visible = true or auth.role() = 'authenticated');

-- Authenticated admin can manage data.
-- For v1, only create one trusted admin user in Supabase Auth.
create policy "Authenticated users can manage categories"
on public.categories for all
using (auth.role() = 'authenticated')
with check (auth.role() = 'authenticated');

create policy "Authenticated users can manage products"
on public.products for all
using (auth.role() = 'authenticated')
with check (auth.role() = 'authenticated');

create policy "Authenticated users can manage gallery items"
on public.gallery_items for all
using (auth.role() = 'authenticated')
with check (auth.role() = 'authenticated');

create policy "Authenticated users can read orders"
on public.orders for select
using (auth.role() = 'authenticated');

create policy "Anyone can create order inquiry"
on public.orders for insert
with check (true);

-- Storage bucket must be created in Supabase UI:
-- Bucket name: product-media
-- Public bucket: yes, for product images/videos

drop policy if exists "Public can read product media" on storage.objects;
drop policy if exists "Authenticated users can upload product media" on storage.objects;
drop policy if exists "Authenticated users can update product media" on storage.objects;
drop policy if exists "Authenticated users can delete product media" on storage.objects;

create policy "Public can read product media"
on storage.objects for select
using (bucket_id = 'product-media');

create policy "Authenticated users can upload product media"
on storage.objects for insert
with check (bucket_id = 'product-media' and auth.role() = 'authenticated');

create policy "Authenticated users can update product media"
on storage.objects for update
using (bucket_id = 'product-media' and auth.role() = 'authenticated')
with check (bucket_id = 'product-media' and auth.role() = 'authenticated');

create policy "Authenticated users can delete product media"
on storage.objects for delete
using (bucket_id = 'product-media' and auth.role() = 'authenticated');
