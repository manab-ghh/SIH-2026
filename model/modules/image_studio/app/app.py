"""
Standalone demo app for the Image Studio module — lets you test the AI
photo enhancement pipeline in isolation, independent of the main ShilpSetu
app. Uses the exact same trained model and enhancement logic.

Run:
    cd modules/image_studio/app
    python app.py
Then open http://127.0.0.1:5060
"""

import os
import sys
import uuid

from flask import Flask, request, redirect, url_for, render_template_string, flash

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import enhancer  # noqa: E402

UPLOAD_FOLDER = os.path.join(os.path.dirname(os.path.abspath(__file__)), "uploads")
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

app = Flask(__name__)
app.secret_key = "image-studio-standalone-demo"
app.config["UPLOAD_FOLDER"] = UPLOAD_FOLDER

PAGE = """
<!DOCTYPE html>
<html><head><title>Image Studio — Standalone Demo</title>
<style>
body { font-family: -apple-system, sans-serif; max-width: 900px; margin: 40px auto; padding: 0 20px; background: #14283C; color: #F7F2E7; }
h1 { color: #DD7A52; }
.card { background: #1D3A54; border: 1px solid #2E5170; border-radius: 12px; padding: 24px; margin-bottom: 20px; }
.flash { background: #E1685A33; border: 1px solid #E1685A; padding: 10px 14px; border-radius: 8px; margin-bottom: 16px; }
img { max-width: 45%; border-radius: 8px; margin-right: 10px; }
button { background: #C05B36; color: white; border: none; padding: 12px 24px; border-radius: 999px; cursor: pointer; font-size: 1rem; }
a { color: #E3A73B; }
</style></head>
<body>
<h1>🖼️ Image Studio — Standalone Demo</h1>
<p>This is an isolated test harness for the Image Studio AI module. The full experience (with navigation, listing, and pricing) lives in the main <code>/app</code> Flask application.</p>

{% with messages = get_flashed_messages() %}
  {% if messages %}{% for m in messages %}<div class="flash">⚠️ {{ m }}</div>{% endfor %}{% endif %}
{% endwith %}

<div class="card">
<form action="/enhance" method="POST" enctype="multipart/form-data">
  <p><input type="file" name="product_image" accept=".png,.jpg,.jpeg,.webp" required></p>
  <p><label><input type="checkbox" name="remove_background" value="yes" checked> Remove background</label></p>
  <button type="submit">Enhance Photo</button>
</form>
</div>

{% if result %}
<div class="card">
  <h3>Quality: {{ result.quality_label }} ({{ result.quality_confidence }}%)</h3>
  <p>Corrections applied: {{ result.corrections_applied | join(', ') }}</p>
  <p>AI background removal used: {{ result.used_ai_bg_removal }}</p>
  <img src="{{ original_url }}" alt="original"><img src="{{ enhanced_url }}" alt="enhanced">
</div>
{% endif %}
</body></html>
"""


@app.route("/")
def index():
    return render_template_string(PAGE, result=None)


@app.route("/enhance", methods=["POST"])
def enhance():
    file = request.files.get("product_image")
    if not file or file.filename == "":
        flash("Please choose an image file.")
        return redirect(url_for("index"))

    ext = file.filename.rsplit(".", 1)[-1].lower()
    orig_name = f"{uuid.uuid4().hex}_original.{ext}"
    orig_path = os.path.join(app.config["UPLOAD_FOLDER"], orig_name)
    file.save(orig_path)

    remove_bg = request.form.get("remove_background") == "yes"

    try:
        result = enhancer.enhance_image(orig_path, remove_background=remove_bg)
    except ValueError as e:
        flash(str(e))
        return redirect(url_for("index"))

    enhanced_name = f"{uuid.uuid4().hex}_enhanced.jpg"
    enhanced_path = os.path.join(app.config["UPLOAD_FOLDER"], enhanced_name)
    with open(enhanced_path, "wb") as f:
        f.write(result["image_bytes"])

    return render_template_string(
        PAGE, result=result,
        original_url=f"/uploads/{orig_name}",
        enhanced_url=f"/uploads/{enhanced_name}",
    )


@app.route("/uploads/<path:filename>")
def uploaded_file(filename):
    from flask import send_from_directory
    return send_from_directory(app.config["UPLOAD_FOLDER"], filename)


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5061))
    app.run(debug=True, host="0.0.0.0", port=port)
