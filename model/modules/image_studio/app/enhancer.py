"""
enhancer.py — Image Studio inference logic.

Pipeline:
 1. Extract handcrafted quality features -> trained classifier flags the
    dominant issue (blurry / dark / cluttered / good).
 2. Apply targeted classical-CV corrections based on that flag (always
    available, zero dependencies, zero risk of failure).
 3. Attempt AI background removal via `rembg` (U^2-Net, genuine deep
    learning model) with a classical OpenCV GrabCut fallback if rembg
    isn't available or its model can't be downloaded — the app NEVER
    crashes because of this optional step.
 4. Composite the product onto a clean, e-commerce-standard square canvas.
"""

import os
import io

import cv2
import numpy as np
import joblib
from PIL import Image

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MODEL_DIR = os.path.join(BASE_DIR, "model")

_quality_model = joblib.load(os.path.join(MODEL_DIR, "quality_classifier.joblib"))
_quality_scaler = joblib.load(os.path.join(MODEL_DIR, "quality_scaler.joblib"))
_quality_label_encoder = joblib.load(os.path.join(MODEL_DIR, "quality_label_encoder.joblib"))
_feature_names = joblib.load(os.path.join(MODEL_DIR, "quality_feature_names.joblib"))

# Lazily-initialized rembg session (only attempted once, cached after)
_rembg_session = None
_rembg_available = None  # None = not yet tried, True/False after first attempt


def _extract_features(img_bgr):
    gray = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2GRAY)
    hsv = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2HSV)

    brightness_mean = gray.mean()
    brightness_std = gray.std()
    blur_var = cv2.Laplacian(gray, cv2.CV_64F).var()
    edges = cv2.Canny(gray, 80, 160)
    edge_density = edges.mean()

    hist = cv2.calcHist([hsv], [0], None, [32], [0, 180]).flatten()
    hist_norm = hist / (hist.sum() + 1e-6)
    hue_entropy = -np.sum(hist_norm * np.log2(hist_norm + 1e-9))

    saturation_mean = hsv[:, :, 1].mean()
    small = cv2.resize(gray, (16, 16))
    local_contrast = small.std()

    return [brightness_mean, brightness_std, blur_var, edge_density, hue_entropy, saturation_mean, local_contrast]


def classify_quality(img_bgr):
    feats = np.array([_extract_features(img_bgr)])
    feats_scaled = _quality_scaler.transform(feats)
    pred_idx = _quality_model.predict(feats_scaled)[0]
    proba = _quality_model.predict_proba(feats_scaled)[0]
    label = _quality_label_encoder.inverse_transform([pred_idx])[0]
    confidence = round(float(proba[pred_idx]) * 100, 1)
    return label, confidence


def _apply_brightness_correction(img_bgr):
    """CLAHE + gamma correction to lift dark/underexposed photos."""
    lab = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2LAB)
    l, a, b = cv2.split(lab)
    clahe = cv2.createCLAHE(clipLimit=2.5, tileGridSize=(8, 8))
    l = clahe.apply(l)
    lab = cv2.merge((l, a, b))
    out = cv2.cvtColor(lab, cv2.COLOR_LAB2BGR)

    mean_brightness = cv2.cvtColor(out, cv2.COLOR_BGR2GRAY).mean()
    target = 130
    gamma = np.clip(np.log(target / 255.0) / np.log(max(mean_brightness, 1) / 255.0), 0.4, 2.5)
    inv_gamma = 1.0 / gamma
    table = np.array([(i / 255.0) ** inv_gamma * 255 for i in range(256)]).astype("uint8")
    out = cv2.LUT(out, table)
    return out


def _apply_sharpen(img_bgr):
    """Unsharp mask to recover perceived sharpness on slightly soft photos."""
    blurred = cv2.GaussianBlur(img_bgr, (0, 0), sigmaX=3)
    sharpened = cv2.addWeighted(img_bgr, 1.6, blurred, -0.6, 0)
    return sharpened


def _white_balance(img_bgr):
    """Simple gray-world white balance."""
    result = img_bgr.astype(np.float32)
    avg_b, avg_g, avg_r = result[:, :, 0].mean(), result[:, :, 1].mean(), result[:, :, 2].mean()
    avg_gray = (avg_b + avg_g + avg_r) / 3
    result[:, :, 0] *= (avg_gray / (avg_b + 1e-6))
    result[:, :, 1] *= (avg_gray / (avg_g + 1e-6))
    result[:, :, 2] *= (avg_gray / (avg_r + 1e-6))
    return np.clip(result, 0, 255).astype(np.uint8)


def _grabcut_remove_background(img_bgr):
    """Classical, dependency-free background removal fallback."""
    h, w = img_bgr.shape[:2]
    mask = np.zeros((h, w), np.uint8)
    bgd_model = np.zeros((1, 65), np.float64)
    fgd_model = np.zeros((1, 65), np.float64)

    margin_x, margin_y = int(w * 0.06), int(h * 0.06)
    rect = (margin_x, margin_y, w - 2 * margin_x, h - 2 * margin_y)

    try:
        cv2.grabCut(img_bgr, mask, rect, bgd_model, fgd_model, 5, cv2.GC_INIT_WITH_RECT)
        mask2 = np.where((mask == 2) | (mask == 0), 0, 1).astype("uint8")
    except cv2.error:
        # If GrabCut fails for any reason, treat the whole image as foreground
        mask2 = np.ones((h, w), dtype=np.uint8)

    rgba = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2BGRA)
    rgba[:, :, 3] = mask2 * 255
    return rgba


def _try_rembg_remove(img_bgr):
    """Attempt AI background removal via rembg. Returns None on any failure
    so the caller can fall back to GrabCut — this function NEVER raises."""
    global _rembg_session, _rembg_available

    if _rembg_available is False:
        return None

    try:
        if _rembg_session is None:
            from rembg import new_session
            _rembg_session = new_session("u2netp")

        from rembg import remove
        rgb = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2RGB)
        pil_img = Image.fromarray(rgb)
        out_pil = remove(pil_img, session=_rembg_session)
        out_rgba = cv2.cvtColor(np.array(out_pil), cv2.COLOR_RGBA2BGRA)
        _rembg_available = True
        return out_rgba
    except Exception:
        _rembg_available = False
        return None


def _composite_on_canvas(rgba_img, canvas_size=1000, bg_color=(246, 244, 238)):
    """Place the (possibly transparent) product image centered on a clean
    square e-commerce-standard canvas."""
    h, w = rgba_img.shape[:2]
    scale = (canvas_size * 0.82) / max(h, w)
    new_w, new_h = int(w * scale), int(h * scale)
    resized = cv2.resize(rgba_img, (new_w, new_h), interpolation=cv2.INTER_AREA)

    canvas = np.full((canvas_size, canvas_size, 3), bg_color, dtype=np.uint8)
    x_off = (canvas_size - new_w) // 2
    y_off = (canvas_size - new_h) // 2

    if resized.shape[2] == 4:
        alpha = resized[:, :, 3:4].astype(np.float32) / 255.0
        fg = resized[:, :, :3].astype(np.float32)
        roi = canvas[y_off:y_off + new_h, x_off:x_off + new_w].astype(np.float32)
        blended = fg * alpha + roi * (1 - alpha)
        canvas[y_off:y_off + new_h, x_off:x_off + new_w] = blended.astype(np.uint8)
    else:
        canvas[y_off:y_off + new_h, x_off:x_off + new_w] = resized[:, :, :3]

    return canvas


def enhance_image(image_path, remove_background=True):
    """Full Image Studio pipeline. Returns a dict with the enhanced image
    (as bytes), the quality diagnosis, and which corrections were applied."""
    img_bgr = cv2.imread(image_path)
    if img_bgr is None:
        raise ValueError("Could not read the uploaded image. Please upload a valid JPG/PNG photo.")

    # Downscale very large uploads for speed
    h, w = img_bgr.shape[:2]
    if max(h, w) > 1600:
        scale = 1600 / max(h, w)
        img_bgr = cv2.resize(img_bgr, (int(w * scale), int(h * scale)))

    quality_label, quality_confidence = classify_quality(img_bgr)

    corrections_applied = []
    working = img_bgr.copy()

    if quality_label in ("dark",):
        working = _apply_brightness_correction(working)
        corrections_applied.append("Brightness & contrast correction")
    if quality_label in ("blurry",):
        working = _apply_sharpen(working)
        corrections_applied.append("Sharpness enhancement")

    working = _white_balance(working)
    corrections_applied.append("Auto white balance")

    used_ai_bg_removal = False
    if remove_background:
        ai_result = _try_rembg_remove(working)
        if ai_result is not None:
            rgba = ai_result
            used_ai_bg_removal = True
            corrections_applied.append("AI background removal (U²-Net)")
        else:
            rgba = _grabcut_remove_background(working)
            corrections_applied.append("Background cleanup (classical CV)")
    else:
        rgba = cv2.cvtColor(working, cv2.COLOR_BGR2BGRA)
        rgba[:, :, 3] = 255

    canvas = _composite_on_canvas(rgba, canvas_size=1000)
    corrections_applied.append("Formatted to 1000×1000 e-commerce canvas")

    # Quality score for downstream pricing model (0-100)
    quality_score_map = {"good": 92, "blurry": 55, "dark": 58, "cluttered": 62}
    base_score = quality_score_map.get(quality_label, 70)
    quality_score = min(100, base_score + int(quality_confidence / 10))

    success, buf = cv2.imencode(".jpg", canvas, [cv2.IMWRITE_JPEG_QUALITY, 92])
    image_bytes = buf.tobytes()

    return {
        "image_bytes": image_bytes,
        "quality_label": quality_label,
        "quality_confidence": quality_confidence,
        "quality_score": quality_score,
        "corrections_applied": corrections_applied,
        "used_ai_bg_removal": used_ai_bg_removal,
    }
