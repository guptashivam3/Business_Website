# Admin, Analytics, and Environment Setup

## What the Website Does

Laxmi Creations is a Vue 3 and Supabase handmade craft shop. Customers browse products, view gallery inspiration, open product details, and start an order on WhatsApp. The owner manages products, gallery items, site details, and owner profile content from the admin dashboard.

## Why Analytics Uses Supabase

There is no Node.js backend in version 1. Supabase is already the database and authentication system, so website analytics are stored in the `analytics_events` table with Row Level Security.

The public website can only insert limited event types:

- `page_view`
- `product_view`
- `whatsapp_click`
- `gallery_view`
- `custom_order_click`

Only admin users can read those analytics in the admin dashboard. This keeps the setup simple and avoids adding paid analytics tools or a backend.

## What the Admin Dashboard Shows

The Dashboard tab shows:

- website page views
- product detail views
- WhatsApp order/enquiry clicks
- gallery and custom-order interest
- activity trend by day
- customer intent donut chart
- product status donut chart
- top product interest

Admin routes such as `/admin` and `/admin/login` are intentionally excluded from customer analytics so owner activity does not pollute customer traffic reports.

Analytics start from the day the `analytics_events` table is created. Past visitors cannot be recovered because they were not previously tracked.

## WhatsApp Number

All customer WhatsApp buttons are centralized in `frontend/src/lib/analytics.js` and currently send customers to:

```text
+91 8793662673
```

The code stores this as:

```text
918793662673
```

This prevents old buttons from accidentally using another number.

## `.env` vs `.env.example`

`.env` is the real local environment file. It is used by Vite when running locally with `npm run dev`. It can contain actual project values and should not be committed.

`.env.example` is a safe template for developers and deployment setup. It shows which variables are needed but should not contain private secrets.

For this project:

- `apps/craft-shop/frontend/.env` is used for local frontend development.
- `apps/craft-shop/frontend/.env.example` documents frontend variables.
- `apps/craft-shop/.env.example` documents the app-level variables.

Vercel does not automatically read your local `.env`; production values must be added in Vercel Project Settings > Environment Variables.

## Required Supabase Setup

Run `apps/craft-shop/sql/schema.sql` in Supabase SQL Editor after pulling new code. It creates or updates:

- products
- categories
- gallery items
- site settings
- admin allowlist
- analytics events
- Row Level Security policies
- storage policies for `product-media`

Also keep these Supabase settings:

- Disable public signup.
- Use one trusted admin user.
- Keep MFA enabled for the admin account if available.
- Never put a Supabase service-role key in frontend code.

## Codebase Cleanup Notes

Current folders:

- `frontend`: active Vue app.
- `sql`: active Supabase schema.
- `docs`: project documentation.
- `backend`: placeholder only; keep empty unless version 2 needs a backend.
- `tests`: placeholder only; can stay for future tests.
- `_incoming_photos`: local photo import/source folder; do not deploy unless intentionally needed.

Do not delete `frontend`, `sql`, or `docs`. The placeholder `backend` and `tests` folders are harmless but not used in version 1.

Removed cleanup:

- Old unused component files under `frontend/src/components` were removed after the active pages stopped importing them.
