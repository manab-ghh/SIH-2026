# ShilpSetu AI — Backend REST API

**Node.js + Express + MongoDB REST API & AI Service Layer for ShilpSetu AI**

## Overview
The ShilpSetu AI Backend powers the digital business manager for Indian artisans, weavers, and craftsmen. It provides JWT-authenticated REST APIs for product catalog management, AI photo enhancement, bilingual voice-to-catalog generation, smart dynamic handicraft pricing calculations, simulated ONDC & GeM marketplace publishing, visual similarity search, order tracking, and analytics.

---

## Tech Stack
- **Runtime**: Node.js (v18+)
- **Framework**: Express.js
- **Database**: MongoDB (Mongoose ODM)
- **Authentication**: JWT (JSON Web Tokens) + BcryptJS
- **Image Processing**: Sharp (1000x1000 standard e-commerce normalization & studio backdrop)
- **Security**: Helmet, CORS, Express-Rate-Limit, Joi input validation
- **Logging**: Morgan

---

## Directory Structure
```
backend/
├── src/
│   ├── config/          # Environment variables & MongoDB connection
│   ├── controllers/     # Express route handlers
│   ├── middleware/      # Auth, error, rate limiting & file upload middlewares
│   ├── models/          # Mongoose database models (User, Product, Order, etc.)
│   ├── routes/          # REST route declarations
│   ├── scripts/         # Seed database & automated endpoint tester
│   ├── services/        # AI engines, pricing calculations & marketplace simulators
│   ├── utils/           # Standard response formatters & token generators
│   ├── validators/      # Joi schema validation
│   ├── app.js           # Express app setup & middleware pipeline
│   └── server.js        # Server listener
├── uploads/             # Static file uploads
├── .env.example
├── package.json
└── README.md
```

---

## Setup & Running

### 1. Install Dependencies
```bash
npm install
```

### 2. Environment Configuration
Create a `.env` file from `.env.example`:
```env
PORT=8000
NODE_ENV=development
MONGO_URI=mongodb://127.0.0.1:27017/shilpsetu
JWT_SECRET=shilpsetu_super_secret_jwt_key_2026_artisan_empowerment
JWT_EXPIRES_IN=7d
CLIENT_URL=*
MAX_FILE_SIZE=10485760
AI_PROVIDER=mock
UPLOAD_DIR=uploads
```

### 3. Seed Demo Data
```bash
npm run seed
```
Creates:
- Demo Artisan account (`Phone: 9876543210`, `Password: demoPassword123`)
- 8 handcrafted products across categories (Chanderi Saree, Terracotta Vase, Dokra Art, Sheesham Box, etc.)
- 5 active orders with order timeline progressions
- Simulated ONDC and GeM listings

### 4. Start Server
```bash
# Production / Standard
npm start

# Development (with nodemon)
npm run dev
```

---

## API Endpoints

### Authentication (`/api/auth`)
- `POST /api/auth/register` — Register a new artisan account
- `POST /api/auth/login` — Login with phone & password
- `POST /api/auth/demo-artisan` — Quick 1-tap demo artisan login
- `GET /api/auth/me` — Fetch current user profile
- `PUT /api/auth/profile` — Update artisan profile & preferred language

### Products (`/api/products`)
- `GET /api/products` — List all artisan products (supports `status`, `category`, `search`, `sort`)
- `GET /api/products/:id` — Get single product details
- `POST /api/products` — Create a new artisan product
- `PUT /api/products/:id` — Update existing product
- `DELETE /api/products/:id` — Delete product
- `GET /api/products/stats/summary` — Analytics dashboard metrics (Products, Orders, Sales, Earnings)

### AI Services (`/api/ai`)
- `POST /api/ai/image-enhance` — AI Image Studio enhancement (Lighting, color balance, 1000x1000 e-commerce studio canvas)
- `POST /api/ai/catalog` — Generate bilingual (EN/HI) SEO title, description, keywords, craft story from voice or text
- `POST /api/ai/pricing` — Smart dynamic pricing engine (Total cost, Recommended, Minimum, Competitive, Premium tiers, Profit Margin %)
- `POST /api/ai/voice` — Process voice note & detect language

### Search (`/api/search`)
- `POST /api/search/visual` — Visual & category similarity search matching artisan products

### Orders (`/api/orders`)
- `GET /api/orders` — List artisan orders (filterable by `status`)
- `GET /api/orders/:id` — Get single order details with buyer info & timeline
- `POST /api/orders` — Create new order
- `PATCH /api/orders/:id/status` — Update order status & append to timeline

### Marketplace Simulation (`/api/marketplace`)
- `POST /api/marketplace/publish` — Simulate publishing to ONDC & GeM
- `GET /api/marketplace/listings` — List all active demo marketplace listings

---

## Automated Verification Test
```bash
npm test
```
Executes automated tests across all 10 core API endpoints.
