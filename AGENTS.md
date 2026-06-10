# AGENTS.md

## Project Mission

Build a simple, reliable, mobile-first handmade craft shop for a non-technical owner.

The owner should be able to manage products from the admin panel without touching code.

## Current Architecture Decision

Use Vue 3 + Supabase only for Version 1.

Do not add Node.js backend unless a future feature clearly needs it.

## Core Rules

1. Keep the app simple.
2. Build admin usability first.
3. Avoid over-engineering.
4. Every product change must be possible from the admin dashboard.
5. Customer checkout should be simple: WhatsApp order or UPI payment.
6. Mobile-first design is required.
7. No paid dependencies unless clearly approved.
8. Do not store secret service-role keys in frontend code.
9. Use Supabase anon key only in frontend.
10. Use Supabase Row Level Security policies.

## Version 1 Features

### Customer

- View products
- Filter by category
- Open product detail page
- See price, description, availability
- Click WhatsApp order button
- View UPI QR/payment instruction

### Admin

- Login with Supabase Auth
- Add product
- Edit product
- Delete product
- Upload image/video
- Mark product as sold out
- Mark product as featured
- Manage categories

## Do Not Build Yet

- Node.js backend
- Full cart system
- Online payment gateway
- Customer login
- Shipping integration
- Invoice automation
- AI features
- Complex analytics

These belong to Version 2 or later.

## Preferred File Style

- Vue Composition API
- Simple readable components
- Minimal external libraries
- Clear function names
- Small reusable components
- CSS should be clean and mobile-first

## Development Priority

1. Supabase schema
2. Supabase Auth setup
3. Product table and storage bucket
4. Admin login
5. Admin dashboard product CRUD
6. Public shop page
7. Product details page
8. WhatsApp order link
9. UPI QR/payment section
10. Deploy to Vercel

## Business Goal Reminder

This website is not just a portfolio project.
It should help the owner avoid missed WhatsApp orders and manage products independently.
