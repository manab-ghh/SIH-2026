# ShilpSetu AI (शिल्पसेतु) - Frontend (Standalone / Offline Dummy Mode)

> **"आपके हुनर का डिजिटल साथी"** — AI-Powered Digital Business Manager for Indian Artisans & Craft Communities.

This project is configured in **Full-Fidelity Standalone / Dummy Mode**, allowing 100% of all features to run completely offline without needing a live backend server. All changes (new products, orders status updates, profile edits, marketplace listings) are persisted locally via `SharedPreferences`.

---

## 🌟 Key Features (100% Functional Without Backend)

1. **Authentication & Profile**
   - 1-Tap **"Continue as Demo Artisan ✨"** (Ramkishan Verma - Master Banarasi Weaver).
   - Full registration and login flow.
   - Multilingual support: **हिंदी (Hindi)**, **English**, **বাংলা (Bengali)**, **தமிழ் (Tamil)**, **తెలుగు (Telugu)**, **मराठी (Marathi)**.
   - Profile editing (Artisan Name, Location, Craft Specialty) with local persistence.

2. **Dashboard & Market Intelligence**
   - Dynamic real-time metrics (Total Products, Published, Drafts, Out of Stock, Orders, Sales Volume, Estimated Earnings).
   - Quick launch action hub.
   - Recent products carousel & artisan tips.

3. **Product Hub & Catalog Management**
   - Filter tabs: *All*, *Drafts*, *Published*, *Out of Stock*.
   - Live search by craft type, material, or keyword.
   - Full product CRUD (Create, Edit, Delete, View Detail, E-commerce Preview).
   - Pre-loaded with 10 master Indian craft items (Banarasi Sarees, Jaipur Blue Pottery, Bastar Dokra Art, Kashmiri Pashmina, Channapatna Toys, Tanjore Paintings, Moradabad Brassware, Assam Bamboo, Terracotta, Kutch Rogan Art).

4. **AI Image Studio 📸**
   - Before/After interactive comparison.
   - Quality score rating (95%) & studio lighting diagnostic.
   - Toggles: Background Removal, Studio Lighting, Color Vibrancy, 1:1 E-commerce Center Crop.
   - Direct export to product catalog.

5. **AI Voice Catalog Maker 🎙**
   - Multi-language voice recording simulation.
   - Generates bilingual descriptions (Hindi & English), materials, craft heritage story, keywords, and prices.
   - 1-tap transfer to Product Form.

6. **Smart Pricing Assistant 💰**
   - Cost inputs for Raw Materials, Production/Labor, Packaging/Transport.
   - Dynamic formula calculating Minimum Viable Price, Competitive Market Price, AI Recommended Price, and Premium Price with profit margin %.
   - Direct price application to product.

7. **Visual Craft Search 🔎**
   - Camera / gallery image matching against Indian handicraft database.
   - Visual similarity scores and benchmark craft comparisons.

8. **ONDC & GeM Marketplace Integration 🌐**
   - 1-Click Multi-Marketplace publisher with animated sync pipeline.
   - Generates live listing IDs (`ONDC-IN-XXXXXX` and `GEM-CRAFT-XXXXXX`).
   - Marketplace network monitoring dashboard.

9. **Order Management & Timeline Tracking 📦**
   - Status filters: *All*, *Pending*, *Confirmed*, *Shipped*, *Delivered*.
   - Interactive 1-tap status advancement with tracking timeline updates.

---

## 🚀 How to Run

### Run on Chrome (Web)
```bash
flutter run -d chrome
```

### Run on Mobile / Desktop
```bash
flutter run
```

### Run Automated Test Suite
```bash
flutter test
```

### Check Static Analysis
```bash
flutter analyze
```
