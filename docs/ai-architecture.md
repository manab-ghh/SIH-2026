# ShilpSetu AI — AI Architecture

## Design Philosophy

ShilpSetu AI uses a **modular, swappable AI service layer**. All AI features work with built-in mock/simulation services for offline/demo use, and can be replaced with real AI providers (Gemini, OpenAI, HuggingFace, etc.) by updating the service implementations.

The frontend also integrates real AI services directly for certain features (background removal via HuggingFace, descriptions via Gemini).

---

## 1. Voice-to-Catalog Pipeline

```
Artisan speaks in native language
          ↓
Speech-to-Text (device / service)
          ↓
Language Detection (hi/en/bn/ta/te/mr)
          ↓
Translation to English (if needed)
          ↓
NLP — Product Attribute Extraction
   ├── Craft technique
   ├── Material
   ├── Color
   ├── Dimensions
   └── Category
          ↓
Catalog Generation Engine
          ↓
┌──────────────────────────────────┐
│  English Product Description     │
│  Hindi Product Description       │
│  SEO Keywords []                 │
│  Category + CraftType            │
│  Material + Color + Size         │
│  Confidence Score                │
└──────────────────────────────────┘
```

**Backend service:** `src/services/ai/catalogService.js`  
**Translation:** `src/services/ai/translationService.js`  
**Speech processing:** `src/services/ai/speechService.js`

---

## 2. Smart Pricing Engine

```
Input
├── Raw Material Cost (₹)
├── Production / Labor Cost (₹)
├── Other Cost (₹)
├── Product Category
├── Craft Type
└── Material Type
          ↓
Cost Aggregation → Total Cost
          ↓
Market Benchmark Analysis (simulated)
   └── Category-based multiplier
          ↓
4-Tier Price Recommendation
┌─────────────────────────────────────┐
│  Minimum Price  — Living wage floor │
│  Competitive    — High volume tier  │
│  Recommended ★  — Optimal margin   │
│  Premium        — Boutique/collect  │
└─────────────────────────────────────┘
          ↓
Profit Margin % + Estimated Profit (₹)
          ↓
Market Trend Signal + Explanation
```

**Backend service:** `src/services/pricing/pricingService.js`

---

## 3. AI Image Studio Pipeline

```
Product Photo (local file or URL)
          ↓
File Upload (Multer → Sharp)
          ↓
┌─────────────────────────────────────┐
│  Background Removal (RMBG / Sharp)  │
│  Lighting Normalization             │
│  Color Enhancement                  │
│  E-commerce Crop & Centering        │
└─────────────────────────────────────┘
          ↓
Quality Score Calculation (0–100)
          ↓
Corrections Applied List
          ↓
Enhanced Image URL → stored in /uploads
```

**Backend service:** `src/services/ai/imageService.js`  
**Frontend integration:** HuggingFace RMBG-2.0 (direct API)

---

## 4. Visual Search Pipeline

```
Query Image (camera / gallery)
          ↓
Category Selection
          ↓
Feature Extraction (simulated)
          ↓
Similarity Matching
   └── Against product database
          ↓
Ranked Results with Similarity % Score
```

**Backend service:** `src/services/search/visualSearchService.js`

---

## 5. Multilingual Support

Supported input languages:

| Code | Language  |
|------|-----------|
| `hi` | Hindi     |
| `en` | English   |
| `bn` | Bengali   |
| `ta` | Tamil     |
| `te` | Telugu    |
| `mr` | Marathi   |

Output is always generated in both **English** and **Hindi** for maximum marketplace compatibility.

---

## Replacing Mock AI with Real Providers

To replace mock services with real AI:

1. Set `AI_PROVIDER=gemini` (or `openai`) in `.env`
2. Add the API key to `.env`
3. Update the relevant service file in `src/services/ai/`

The interface contract (input/output shape) remains the same — only the implementation changes.

Example for Catalog Service:
```javascript
// src/services/ai/catalogService.js
// Replace the mock implementation with real API calls
// while keeping the same return shape:
// { name, description, descriptionHindi, keywords, material, craftType, color, size, confidence }
```
