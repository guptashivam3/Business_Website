# SKILLS.md

## Skill: Understand the Business Flow

The shop flow is:

```text
Owner logs into admin
↓
Adds products/photos/prices
↓
Customer opens shared link
↓
Customer browses products
↓
Customer orders through WhatsApp or pays using UPI
```

Always protect this simple flow.

## Skill: Supabase Usage

Use Supabase for:

- Auth
- Product database
- Category database
- Image/video storage

Frontend should use:

- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_ANON_KEY`

Never expose:

- Supabase service role key
- private admin keys

## Skill: Product Model

Products should support:

- name
- slug
- description
- price
- category
- image_url
- video_url
- is_available
- is_featured
- sort_order

## Skill: Admin Experience

The admin should be easy enough for a non-technical person.

Good admin UX means:

- clear labels
- large buttons
- preview image after upload
- simple save button
- no technical words
- sold out toggle
- featured toggle

## Skill: Customer Experience

The shop must feel clean and trustworthy.

Important:

- mobile-first layout
- fast loading
- clear product images
- visible price
- visible availability
- direct WhatsApp order button
- simple UPI payment instructions

## Skill: When to Add Node.js

Do not add Node.js in Version 1.

Add Node.js later only for:

- Razorpay/Stripe payment verification
- WhatsApp Business API automation
- email/SMS notifications
- invoice generation
- scheduled jobs
- private API integrations
- advanced reporting

## Skill: Deployment

Frontend deploys to Vercel.
Supabase remains cloud-hosted.

No backend deployment is needed in Version 1.
