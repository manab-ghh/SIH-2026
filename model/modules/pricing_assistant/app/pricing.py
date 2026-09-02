"""
pricing.py — Dynamic Pricing Assistant inference logic.

Loads the trained regression pipeline from the notebook and exposes a
single `suggest_price()` function that turns artisan-provided attributes
(optionally auto-filled from the Auto-Cataloger's predicted category and
the Image Studio's photo quality score) into a suggested price and a
sensible negotiation range.
"""

import os
import json

import joblib
import numpy as np

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MODEL_DIR = os.path.join(BASE_DIR, "model")

_pipeline = joblib.load(os.path.join(MODEL_DIR, "pricing_model.joblib"))

with open(os.path.join(MODEL_DIR, "pricing_model_metadata.json")) as f:
    PRICING_METADATA = json.load(f)

CATEGORIES = PRICING_METADATA["categories"]
MATERIAL_TIERS = PRICING_METADATA["material_tiers"]
SIZE_CATEGORIES = PRICING_METADATA["size_categories"]

# Category median price bands (approximate, derived from the training
# distribution) — used to contextualize the suggestion for the artisan.
CATEGORY_TYPICAL_RANGE = {
    "Textile": (600, 4500), "Pottery": (200, 2200), "Jewelry": (900, 7000),
    "Woodwork": (700, 5000), "Metalware": (800, 5500), "Painting": (450, 3800),
    "Leatherwork": (750, 5200), "BambooCane": (250, 2200),
}


def suggest_price(category, material_tier, size, labor_hours, complexity_score,
                   quality_score, market_saturation=0.4, hourly_wage=95.0,
                   material_cost=None):
    """Predict a suggested price and a negotiation range."""
    if category not in CATEGORIES:
        category = CATEGORIES[0]
    if material_tier not in MATERIAL_TIERS:
        material_tier = "Standard"
    if size not in SIZE_CATEGORIES:
        size = "Medium"

    BASE_MATERIAL_COST = {
        "Textile": 350, "Pottery": 120, "Jewelry": 600, "Woodwork": 400,
        "Metalware": 500, "Painting": 250, "Leatherwork": 450, "BambooCane": 150,
    }
    MATERIAL_TIER_MULT = {"Economy": 0.8, "Standard": 1.15, "Premium": 1.8}
    SIZE_MULT = {"Small": 0.7, "Medium": 1.0, "Large": 1.6}

    if material_cost is None:
        material_cost = BASE_MATERIAL_COST[category] * MATERIAL_TIER_MULT[material_tier] * SIZE_MULT[size]

    cost_per_hour = material_cost / max(labor_hours, 0.5)
    complexity_x_quality = complexity_score * quality_score / 100
    effective_labor_cost = labor_hours * hourly_wage

    import pandas as pd
    row = pd.DataFrame([{
        "category": category,
        "material_tier": material_tier,
        "size": size,
        "labor_hours": labor_hours,
        "complexity_score": complexity_score,
        "quality_score": quality_score,
        "market_saturation": market_saturation,
        "hourly_wage": hourly_wage,
        "material_cost": material_cost,
        "cost_per_hour": cost_per_hour,
        "complexity_x_quality": complexity_x_quality,
        "effective_labor_cost": effective_labor_cost,
    }])

    predicted_price = float(_pipeline.predict(row)[0])
    predicted_price = max(predicted_price, 80)

    low = round(predicted_price * 0.88, -1)
    high = round(predicted_price * 1.15, -1)

    typical_lo, typical_hi = CATEGORY_TYPICAL_RANGE.get(category, (200, 3000))
    if predicted_price < typical_lo * 0.7:
        market_note = f"This is on the lower end for {category.lower()} items — consider if your pricing reflects the true labor and material cost."
    elif predicted_price > typical_hi * 1.3:
        market_note = f"This is a premium price for {category.lower()} — make sure your listing highlights what makes this piece exceptional."
    else:
        market_note = f"This sits comfortably within the typical {category.lower()} price range for the Indian handicraft market."

    return {
        "predicted_price": round(predicted_price, -1),
        "price_range_low": low,
        "price_range_high": high,
        "market_note": market_note,
        "category_typical_range": {"low": typical_lo, "high": typical_hi},
        "inputs_used": {
            "category": category, "material_tier": material_tier, "size": size,
            "labor_hours": labor_hours, "complexity_score": complexity_score,
            "quality_score": quality_score, "material_cost": round(material_cost, 1),
        },
    }
