"""
Standalone demo app for the Dynamic Pricing Assistant module — test the
trained pricing regression model in isolation from the main ShilpSetu app.

Run:
    cd modules/pricing_assistant/app
    python app.py
Then open http://127.0.0.1:5060
"""

import os
import sys

from flask import Flask, request, redirect, url_for, render_template_string, flash

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pricing  # noqa: E402

app = Flask(__name__)
app.secret_key = "pricing-assistant-standalone-demo"

PAGE = """
<!DOCTYPE html>
<html><head><title>Pricing Assistant — Standalone Demo</title>
<style>
body { font-family: -apple-system, sans-serif; max-width: 900px; margin: 40px auto; padding: 0 20px; background: #14283C; color: #F7F2E7; }
h1 { color: #DD7A52; }
.card { background: #1D3A54; border: 1px solid #2E5170; border-radius: 12px; padding: 24px; margin-bottom: 20px; }
.flash { background: #E1685A33; border: 1px solid #E1685A; padding: 10px 14px; border-radius: 8px; margin-bottom: 16px; }
label { display: block; margin-top: 12px; font-size: 0.85rem; color: #A9BECF; }
select, input { width: 100%; padding: 10px; border-radius: 8px; border: 1px solid #2E5170; background: #14283C; color: white; font-size: 1rem; margin-top: 4px; }
button { background: #C05B36; color: white; border: none; padding: 12px 24px; border-radius: 999px; cursor: pointer; font-size: 1rem; margin-top: 16px; }
.price { font-size: 2.2rem; color: #E3A73B; font-weight: bold; }
</style></head>
<body>
<h1>💰 Pricing Assistant — Standalone Demo</h1>
<p>This is an isolated test harness for the Dynamic Pricing Assistant AI module.</p>

{% with messages = get_flashed_messages() %}
  {% if messages %}{% for m in messages %}<div class="flash">⚠️ {{ m }}</div>{% endfor %}{% endif %}
{% endwith %}

<div class="card">
<form action="/estimate" method="POST">
  <label>Category</label>
  <select name="category">{% for c in categories %}<option value="{{ c }}">{{ c }}</option>{% endfor %}</select>
  <label>Material Tier</label>
  <select name="material_tier">{% for t in tiers %}<option value="{{ t }}" {{ 'selected' if t == 'Standard' }}>{{ t }}</option>{% endfor %}</select>
  <label>Size</label>
  <select name="size">{% for s in sizes %}<option value="{{ s }}" {{ 'selected' if s == 'Medium' }}>{{ s }}</option>{% endfor %}</select>
  <label>Labor Hours</label>
  <input type="number" name="labor_hours" value="10" min="1" max="60">
  <label>Complexity Score (1-10)</label>
  <input type="number" name="complexity_score" value="5" min="1" max="10">
  <label>Quality Score (0-100)</label>
  <input type="number" name="quality_score" value="75" min="0" max="100">
  <button type="submit">Suggest Price</button>
</form>
</div>

{% if result %}
<div class="card">
  <div class="price">₹{{ "{:,.0f}".format(result.predicted_price) }}</div>
  <p>Range: ₹{{ "{:,.0f}".format(result.price_range_low) }} – ₹{{ "{:,.0f}".format(result.price_range_high) }}</p>
  <p>{{ result.market_note }}</p>
</div>
{% endif %}
</body></html>
"""


@app.route("/")
def index():
    return render_template_string(
        PAGE, result=None,
        categories=pricing.CATEGORIES, tiers=pricing.MATERIAL_TIERS, sizes=pricing.SIZE_CATEGORIES,
    )


@app.route("/estimate", methods=["POST"])
def estimate():
    try:
        result = pricing.suggest_price(
            category=request.form.get("category"),
            material_tier=request.form.get("material_tier"),
            size=request.form.get("size"),
            labor_hours=float(request.form.get("labor_hours", 10)),
            complexity_score=float(request.form.get("complexity_score", 5)),
            quality_score=float(request.form.get("quality_score", 75)),
        )
    except (ValueError, TypeError) as e:
        flash(f"Please check your inputs — {e}")
        return redirect(url_for("index"))

    return render_template_string(
        PAGE, result=result,
        categories=pricing.CATEGORIES, tiers=pricing.MATERIAL_TIERS, sizes=pricing.SIZE_CATEGORIES,
    )


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5062))
    app.run(debug=True, host="0.0.0.0", port=port)
