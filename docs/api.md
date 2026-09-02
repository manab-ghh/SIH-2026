# ShilpSetu AI — API Reference

**Base URL:** `http://localhost:8000/api`  
**Health Check:** `GET /api/health`  
**Auth:** Bearer JWT token in `Authorization` header (all protected routes)

---

## Authentication

### POST `/auth/register`
Register a new artisan account.

**Body:**
```json
{
  "name": "Ramu Weaver",
  "phone": "9876543210",
  "password": "mypassword123",
  "email": "ramu@example.com",
  "preferredLanguage": "hi",
  "location": "Varanasi, Uttar Pradesh",
  "craftSpecialty": "Banarasi Silk Weaving"
}
```
**Response:** `{ success, data: { user, token } }`

---

### POST `/auth/login`
Login with phone and password.

**Body:**
```json
{ "phone": "9876543210", "password": "mypassword123" }
```
**Response:** `{ success, data: { user, token } }`

---

### POST `/auth/demo-artisan`
One-tap demo artisan login (creates or returns demo account).

**Response:** `{ success, data: { user, token } }`

---

### GET `/auth/me` 🔒
Get authenticated user profile.

**Response:** `{ success, data: { user } }`

---

### PUT `/auth/profile` 🔒
Update artisan profile.

**Body (partial):**
```json
{ "name": "...", "preferredLanguage": "en", "location": "...", "craftSpecialty": "..." }
```
**Response:** `{ success, data: { user } }`

---

## Products

### GET `/products` 🔒
Get all products for the authenticated artisan.

**Query params:** `status`, `category`, `search`, `sort`

**Response:** `{ success, data: { count, products[] } }`

---

### POST `/products` 🔒
Create a new product.

**Body:** Product fields (name, description, category, craftType, material, images[], rawMaterialCost, productionCost, etc.)

**Response:** `{ success, data: { product } }` — `201`

---

### GET `/products/stats/summary` 🔒
Get dashboard analytics for the artisan.

**Response:** `{ success, data: { stats: { totalProducts, publishedProducts, draftProducts, totalOrders, totalSales, estimatedEarnings }, recentProducts[] } }`

---

### GET `/products/:id` 🔒
Get a single product by ID.

**Response:** `{ success, data: { product } }`

---

### PUT `/products/:id` 🔒
Update a product.

**Response:** `{ success, data: { product } }`

---

### DELETE `/products/:id` 🔒
Delete a product.

**Response:** `{ success, data: null }`

---

## AI Services

### POST `/ai/image-enhance` 🔒
Enhance a product image (background removal, lighting, colors).

**Body:** `multipart/form-data` with `image` file, or JSON with `imagePath`.  
Options: `removeBackground`, `enhanceLighting`, `enhanceColors`, `eCommerceCrop` (bool)

**Response:** `{ success, data: { enhancedImage, qualityScore, qualityDiagnosis, correctionsApplied[] } }`

---

### POST `/ai/catalog` 🔒
Generate bilingual catalog from voice/text description.

**Body:**
```json
{ "inputText": "यह हाथ से बुनी हुई साड़ी है...", "inputLanguage": "hi", "productId": "optional" }
```
**Response:** `{ success, data: { catalog: { name, description, descriptionHindi, keywords[], material, craftType, color, size, confidence }, recordId } }`

---

### POST `/ai/pricing` 🔒
Calculate smart pricing recommendations.

**Body:**
```json
{ "rawMaterialCost": 800, "productionCost": 500, "otherCost": 200, "category": "Textile", "craftType": "Handloom" }
```
**Response:** `{ success, data: { pricing: { minimumPrice, competitivePrice, recommendedPrice, premiumPrice, profitMargin, estimatedProfit, marketTrend, explanation }, recordId } }`

---

### POST `/ai/voice` 🔒
Process voice text input.

**Body:** `{ "voiceText": "...", "language": "hi" }`

**Response:** `{ success, data: { ... } }`

---

## Orders

### GET `/orders` 🔒
Get all orders for the artisan.

**Query params:** `status` (pending | confirmed | processing | shipped | delivered | cancelled)

**Response:** `{ success, data: { count, orders[] } }`

---

### GET `/orders/:id` 🔒
Get a single order by ID.

**Response:** `{ success, data: { order } }`

---

### POST `/orders` 🔒
Create a new order (buyer simulation).

**Body:** `{ "productId": "...", "quantity": 1, "buyerName": "...", "buyerPhone": "...", "shippingAddress": {...} }`

**Response:** `{ success, data: { order } }` — `201`

---

### PATCH `/orders/:id/status` 🔒
Update order status and append to timeline.

**Body:** `{ "status": "confirmed", "note": "optional message" }`

Valid statuses: `pending | confirmed | processing | shipped | delivered | cancelled`

**Response:** `{ success, data: { order } }`

---

## Search

### POST `/search/visual` 🔒
Visual similarity search using product image.

**Body:** `{ "imagePath": "...", "category": "Textile" }`

**Response:** `{ success, data: { results[] } }`

---

## Marketplace

### POST `/marketplace/publish` 🔒
Publish product to simulated ONDC and GeM marketplaces.

**Body:** `{ "productId": "...", "marketplaces": ["ONDC", "GeM"] }`

**Response:** `{ success, data: { listings[] } }`

> ⚠️ **Simulation Only**: No real marketplace transactions are created.

---

### GET `/marketplace/listings` 🔒
Get all active marketplace listings.

**Response:** `{ success, data: { stats, listings[], statusBadge } }`

---

## Error Response Format

All errors return:
```json
{
  "success": false,
  "message": "Human-readable error description",
  "data": null
}
```

Common HTTP status codes: `400` Bad Request · `401` Unauthorized · `403` Forbidden · `404` Not Found · `429` Rate Limited · `500` Server Error
