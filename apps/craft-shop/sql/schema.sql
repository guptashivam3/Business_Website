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

alter table public.products
add column if not exists category_id uuid references public.categories(id) on delete set null;

alter table public.products
add column if not exists video_url text;

alter table public.products
add column if not exists sort_order integer default 0;

alter table public.products
add column if not exists updated_at timestamptz default now();

create table if not exists public.gallery_items (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text,
  category text,
  image_url text not null,
  is_visible boolean default true,
  created_at timestamptz default now()
);

create table if not exists public.site_settings (
  id text primary key default 'about',
  shop_name text default 'Laxmi Creations',
  owner_name text default 'Laxmi Gupta',
  owner_phone text default '+918793662673',
  owner_email text default 'laxmigupta8888@gmail.com',
  owner_photo_url text,
  about_heading text default 'Handmade gifts crafted by Laxmi Gupta',
  about_intro text default 'Laxmi Creations is a small handmade craft studio for thoughtful gifting, festive hampers, chocolate garlands, decorated trays, potli favors, and custom celebration pieces.',
  about_story text default 'Every order is handled personally, from choosing the color theme to arranging the final packing. The goal is simple: make gifting feel warm, beautiful, and easy for families who want something more personal than a ready-made store item.',
  updated_at timestamptz default now()
);

create table if not exists public.admin_users (
  email text primary key,
  created_at timestamptz default now()
);

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.admin_users
    where lower(email) = lower(coalesce(auth.jwt() ->> 'email', ''))
  );
$$;

create table if not exists public.gallery (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  category text,
  description text,
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
alter table public.site_settings enable row level security;
alter table public.admin_users enable row level security;
alter table public.gallery enable row level security;
alter table public.orders enable row level security;

drop policy if exists "Public can read categories" on public.categories;
drop policy if exists "Public can read products" on public.products;
drop policy if exists "Public can read visible gallery items" on public.gallery_items;
drop policy if exists "Public can read site settings" on public.site_settings;
drop policy if exists "Authenticated admins can read admin users" on public.admin_users;
drop policy if exists "Authenticated admins can manage admin users" on public.admin_users;
drop policy if exists "Public can view visible gallery" on public.gallery;
drop policy if exists "Authenticated users can manage categories" on public.categories;
drop policy if exists "Authenticated users can manage products" on public.products;
drop policy if exists "Authenticated users can manage gallery items" on public.gallery_items;
drop policy if exists "Authenticated users can manage site settings" on public.site_settings;
drop policy if exists "Admin can manage gallery" on public.gallery;
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
using (is_visible = true or public.is_admin());

create policy "Public can read site settings"
on public.site_settings for select
using (true);

create policy "Authenticated admins can read admin users"
on public.admin_users for select
using (public.is_admin());

create policy "Authenticated admins can manage admin users"
on public.admin_users for all
using (public.is_admin())
with check (public.is_admin());

create policy "Public can view visible gallery"
on public.gallery for select
using (is_visible = true or public.is_admin());

-- Authenticated admin can manage data.
-- For v1, only create one trusted admin user in Supabase Auth.
create policy "Authenticated users can manage categories"
on public.categories for all
using (public.is_admin())
with check (public.is_admin());

create policy "Authenticated users can manage products"
on public.products for all
using (public.is_admin())
with check (public.is_admin());

create policy "Authenticated users can manage gallery items"
on public.gallery_items for all
using (public.is_admin())
with check (public.is_admin());

create policy "Authenticated users can manage site settings"
on public.site_settings for all
using (public.is_admin())
with check (public.is_admin());

create policy "Admin can manage gallery"
on public.gallery for all
using (public.is_admin())
with check (public.is_admin());

create policy "Authenticated users can read orders"
on public.orders for select
using (public.is_admin());

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
with check (bucket_id = 'product-media' and public.is_admin());

create policy "Authenticated users can update product media"
on storage.objects for update
using (bucket_id = 'product-media' and public.is_admin())
with check (bucket_id = 'product-media' and public.is_admin());

create policy "Authenticated users can delete product media"
on storage.objects for delete
using (bucket_id = 'product-media' and public.is_admin());

insert into public.categories (name, slug)
values
  ('Jewellery', 'jewellery'),
  ('Home Decor', 'home-decor'),
  ('Bags & Pouches', 'bags-pouches'),
  ('Gifts', 'gifts'),
  ('Clothing', 'clothing')
on conflict (slug) do nothing;

insert into public.site_settings (id)
values ('about')
on conflict (id) do nothing;

insert into public.admin_users (email)
values ('laxmigupta8888@gmail.com')
on conflict (email) do nothing;
