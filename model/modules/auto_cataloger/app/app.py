"""
Standalone demo app for the Auto-Cataloger module — test the multilingual
attribute extraction, category classification, and bilingual SEO listing
generation in isolation from the main ShilpSetu app.

Run:
    cd modules/auto_cataloger/app
    python app.py
Then open http://127.0.0.1:5060
"""

import os
import sys

from flask import Flask, request, redirect, url_for, render_template_string, flash

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import cataloger  # noqa: E402

app = Flask(__name__)
app.secret_key = "auto-cataloger-standalone-demo"

PAGE = """
<!DOCTYPE html>
<html><head><title>Auto-Cataloger — Standalone Demo</title>
<style>
body { font-family: -apple-system, sans-serif; max-width: 900px; margin: 40px auto; padding: 0 20px; background: #14283C; color: #F7F2E7; }
h1 { color: #DD7A52; }
.card { background: #1D3A54; border: 1px solid #2E5170; border-radius: 12px; padding: 24px; margin-bottom: 20px; }
.flash { background: #E1685A33; border: 1px solid #E1685A; padding: 10px 14px; border-radius: 8px; margin-bottom: 16px; }
textarea { width: 100%; min-height: 90px; padding: 10px; border-radius: 8px; border: 1px solid #2E5170; background: #14283C; color: white; font-size: 1rem; }
button { background: #C05B36; color: white; border: none; padding: 12px 24px; border-radius: 999px; cursor: pointer; font-size: 1rem; margin-top: 10px; }
.chip { display: inline-block; background: #14283C; border: 1px solid #2E5170; border-radius: 999px; padding: 4px 12px; margin: 3px; font-size: 0.85rem; color: #E3A73B; }
.title { color: #E3A73B; font-size: 1.2rem; margin-bottom: 8px; }
</style></head>
<body>
<h1>🎙️ Auto-Cataloger — Standalone Demo</h1>
<p>Type a product description in Hindi or English (voice recording is available in the main app). This is an isolated test harness for the Auto-Cataloger AI module.</p>

{% with messages = get_flashed_messages() %}
  {% if messages %}{% for m in messages %}<div class="flash">⚠️ {{ m }}</div>{% endfor %}{% endif %}
{% endwith %}

<div class="card">
<form action="/generate" method="POST">
  <textarea name="description_text" placeholder="e.g. handwoven cotton saree with traditional embroidery, or यह टेराकोटा से बना हस्तनिर्मित फूलदान है">{{ input_text or '' }}</textarea>
  <br><button type="submit">Generate Listing</button>
</form>
</div>

{% if result %}
<div class="card">
  <h3>Category: {{ result.category }} ({{ result.category_confidence }}%)</h3>
  <div>{% for t in result.tags %}<span class="chip">{{ t }}</span>{% endfor %}</div>
</div>
<div class="card">
  <div class="title">{{ result.seo_title_en }}</div>
  <p>{{ result.description_en }}</p>
</div>
<div class="card">
  <div class="title">{{ result.seo_title_hi }}</div>
  <p>{{ result.description_hi }}</p>
</div>
{% endif %}
</body></html>
"""


@app.route("/")
def index():
    return render_template_string(PAGE, result=None)


@app.route("/generate", methods=["POST"])
def generate():
    text = request.form.get("description_text", "").strip()
    if not text:
        flash("Please enter a description.")
        return redirect(url_for("index"))

    result = cataloger.full_pipeline(text)
    if not result.get("success"):
        flash(result.get("message"))
        return redirect(url_for("index"))

    return render_template_string(PAGE, result=result, input_text=text)


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5063))
    app.run(debug=True, host="0.0.0.0", port=port)
