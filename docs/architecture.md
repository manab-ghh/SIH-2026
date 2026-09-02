# ShilpSetu AI — System Architecture

## Overview

ShilpSetu AI is a full-stack cross-platform application built as a monorepo with a Flutter frontend and a Node.js/Express.js backend connected to MongoDB.

---

## High-Level Architecture

```
                 ┌─────────────────────────────┐
                 │        Flutter App           │
                 │                              │
                 │  UI → Riverpod State         │
                 │  Repository → Dio HTTP       │
                 └────────────┬─────────────────┘
                              │
                         REST API / JWT
                              │
                              ▼
                 ┌─────────────────────────────┐
                 │    Node.js + Express.js      │
                 │                              │
                 │  Routes → Controllers        │
                 │  Middleware → Services       │
                 │  Validators → Utils          │
                 └────────────┬─────────────────┘
                              │
              ┌───────────────┼────────────────┐
              │               │                │
              ▼               ▼                ▼
        ┌──────────┐   ┌─────────────┐  ┌───────────────┐
        │ MongoDB  │   │  AI Layer   │  │  Marketplace  │
        │ Mongoose │   │  Services   │  │  Simulation   │
        └──────────┘   └─────────────┘  └───────────────┘
                              │
                    ┌─────────┼──────────┐
                    ▼         ▼          ▼
                 Voice    Catalog    Pricing
                Service   Service   Service
```

---

## Frontend Architecture

**Framework:** Flutter (Dart)  
**State Management:** flutter_riverpod  
**Navigation:** go_router  
**Networking:** Dio with Interceptors  
**Storage:** flutter_secure_storage + shared_preferences  

### Layered Structure

```
lib/
├── app/           — App root, theme, router
├── core/          — Shared infrastructure
│   ├── config/    — AI and app configuration
│   ├── constants/ — API constants
│   ├── localization/ — Language providers
│   ├── mock/      — Offline mock interceptor (dev only)
│   ├── network/   — Dio ApiClient
│   ├── services/  — AI service integrations
│   ├── storage/   — Secure token storage
│   └── widgets/   — Reusable UI components
├── features/      — Feature modules (screen + provider + repository)
│   ├── auth/
│   ├── home/
│   ├── products/
│   ├── catalog/
│   ├── image_studio/
│   ├── pricing/
│   ├── orders/
│   ├── marketplace/
│   ├── search/
│   ├── chatbot/
│   ├── profile/
│   ├── onboarding/
│   └── splash/
└── shared/        — Shared data models
    └── models/
```

### State Management Pattern

Each feature follows a consistent pattern:
```
Screen (ConsumerWidget)
  └── Riverpod Provider (StateNotifierProvider)
        └── Notifier (StateNotifier<State>)
              └── Repository / ApiClient
                    └── Backend REST API
```

---

## Backend Architecture

**Runtime:** Node.js 18+  
**Framework:** Express.js  
**Database:** MongoDB + Mongoose ODM  
**Auth:** JWT (jsonwebtoken) + bcryptjs  
**Security:** Helmet, CORS, Rate Limiting  
**File Upload:** Multer + Sharp  

### Layer Responsibilities

| Layer | Responsibility |
|---|---|
| Routes | URL mapping and middleware chaining |
| Controllers | Request handling, response formatting |
| Services | Business logic, AI service calls |
| Models | MongoDB schema definitions |
| Middleware | Auth, upload, rate limiting, error handling |
| Validators | Joi-based input validation |
| Utils | Token generation, response formatting, logging |

---

## Authentication Flow

```
Client                    Backend                     MongoDB
  │                          │                            │
  │── POST /auth/login ──────▶│                            │
  │                          │── User.findOne({phone}) ──▶│
  │                          │◀─ User document ───────────│
  │                          │── bcrypt.compare() ────────│
  │                          │── generateToken(userId) ───│
  │◀── { token, user } ──────│                            │
  │                          │                            │
  │── GET /api/me ───────────▶│                            │
  │  Authorization: Bearer ── ▶ authMiddleware             │
  │                          │── verify(token) ───────────│
  │                          │── User.findById() ─────────▶│
  │◀── { user } ─────────────│                            │
```

---

## Data Models

| Model | Key Fields |
|---|---|
| User | name, phone, email, password (hashed), role, preferredLanguage, craftSpecialty |
| Product | name, description, category, craftType, material, images[], status, recommendedPrice, artisanId |
| Order | orderNumber, productId, buyerName, quantity, price, status, timeline[], shippingAddress |
| AICatalog | inputText, inputLanguage, generatedName, generatedDescription, keywords, craftType |
| Pricing | rawMaterialCost, productionCost, totalCost, recommendedPrice, profitMargin |
| MarketplaceListing | productId, marketplace, listingId, status, marketplaceCategory |
