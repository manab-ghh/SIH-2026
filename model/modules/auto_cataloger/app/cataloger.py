"""
cataloger.py — Auto-Cataloger inference logic.

Pipeline:
 1. (Optional) Transcribe a voice note with faster-whisper — a genuine
    local, offline, multilingual speech model with NO API key and NO
    rate limit. Wrapped so that if the model can't be downloaded/loaded
    (e.g. no internet on first run), the app degrades gracefully to
    typed-text input instead of crashing.
 2. Extract canonical attribute tags from the text using a curated
    bilingual (English/Hindi) lexicon — works for either language.
 3. Classify the product category from the extracted tags with the
    trained model from the notebook.
 4. Generate a professional, SEO-friendly product description in BOTH
    English and Hindi from the extracted tags + predicted category using
    a bilingual template engine — no translation model required, so this
    step can never fail from a missing/blocked network call.
"""

import os
import json
import re

import joblib

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MODEL_DIR = os.path.join(BASE_DIR, "model")
DATA_DIR = os.path.join(BASE_DIR, "data")

_category_model = joblib.load(os.path.join(MODEL_DIR, "category_classifier.joblib"))
_tfidf = joblib.load(os.path.join(MODEL_DIR, "category_tfidf_vectorizer.joblib"))
_label_encoder = joblib.load(os.path.join(MODEL_DIR, "category_label_encoder.joblib"))

with open(os.path.join(DATA_DIR, "lexicon.json"), encoding="utf-8") as f:
    LEXICON = json.load(f)

with open(os.path.join(DATA_DIR, "categories.json"), encoding="utf-8") as f:
    CATEGORIES = json.load(f)

# Build a flat surface-form -> canonical-tag lookup for both languages
_SURFACE_TO_TAG = {}
for tag, info in LEXICON.items():
    for form in info["en"] + info["hi"]:
        _SURFACE_TO_TAG[form.lower()] = tag

# Sort longest-first so multi-word phrases match before single words
_SURFACE_FORMS_SORTED = sorted(_SURFACE_TO_TAG.keys(), key=len, reverse=True)

GENERIC_TAGS = {"handmade", "traditional", "colorful", "intricate", "eco_friendly", "gift", "festive"}

CATEGORY_DISPLAY_HI = {
    "Textile": "वस्त्र", "Pottery": "मिट्टी के बर्तन", "Jewelry": "आभूषण",
    "Woodwork": "लकड़ी का काम", "Metalware": "धातु शिल्प", "Painting": "चित्रकला",
    "Leatherwork": "चमड़े का काम", "BambooCane": "बांस व बेंत शिल्प",
}

# ---------------------------------------------------------------------------
# Optional speech-to-text (faster-whisper) — lazy-loaded, never crashes
# ---------------------------------------------------------------------------
_whisper_model = None
_whisper_available = None


def transcribe_audio(audio_path):
    """Best-effort local speech-to-text + translate-to-English via
    faster-whisper. Returns dict with status; NEVER raises."""
    global _whisper_model, _whisper_available

    if _whisper_available is False:
        return {"available": False, "reason": "Speech engine not available on this server. Please type your description instead."}

    try:
        if _whisper_model is None:
            from faster_whisper import WhisperModel
            _whisper_model = WhisperModel("tiny", device="cpu", compute_type="int8")

        segments, info = _whisper_model.transcribe(audio_path, task="translate", beam_size=1)
        english_text = " ".join(seg.text.strip() for seg in segments)

        segments2, _ = _whisper_model.transcribe(audio_path, task="transcribe", beam_size=1)
        original_text = " ".join(seg.text.strip() for seg in segments2)

        _whisper_available = True
        return {
            "available": True,
            "detected_language": info.language,
            "original_text": original_text,
            "english_text": english_text,
        }
    except Exception as e:
        _whisper_available = False
        return {"available": False, "reason": "Speech engine could not be loaded (this optional AI model needs an internet connection the first time it's used). Please type your description instead."}


def extract_tags(text):
    """Extract canonical attribute tags from raw text (Hindi or English)."""
    text_lower = " " + text.lower() + " "
    found = []
    for form in _SURFACE_FORMS_SORTED:
        pattern = re.escape(form)
        if re.search(pattern, text_lower):
            tag = _SURFACE_TO_TAG[form]
            if tag not in found:
                found.append(tag)
    return found


def predict_category(tags):
    if not tags:
        return None, 0.0
    tag_string = " ".join(tags)
    X = _tfidf.transform([tag_string])
    proba = _category_model.predict_proba(X)[0]
    pred_idx = proba.argmax()
    category = _label_encoder.inverse_transform([pred_idx])[0]
    confidence = round(float(proba[pred_idx]) * 100, 1)
    return category, confidence


def _terms_for(tag, lang):
    info = LEXICON.get(tag)
    if not info:
        return tag
    forms = info.get(lang, [])
    return forms[0] if forms else tag


CATEGORY_OPENERS_EN = {
    "Textile": "This exquisite handwoven textile piece",
    "Pottery": "This beautifully crafted pottery piece",
    "Jewelry": "This stunning handcrafted jewelry piece",
    "Woodwork": "This finely carved wooden piece",
    "Metalware": "This intricately worked metal piece",
    "Painting": "This vibrant hand-painted artwork",
    "Leatherwork": "This premium handcrafted leather piece",
    "BambooCane": "This eco-friendly bamboo & cane piece",
}

CATEGORY_OPENERS_HI = {
    "Textile": "यह उत्कृष्ट हस्तनिर्मित वस्त्र",
    "Pottery": "यह खूबसूरती से तैयार मिट्टी का बर्तन",
    "Jewelry": "यह शानदार हस्तनिर्मित आभूषण",
    "Woodwork": "यह बारीकी से नक्काशीदार लकड़ी की वस्तु",
    "Metalware": "यह जटिल धातु शिल्प कृति",
    "Painting": "यह जीवंत हस्तनिर्मित कलाकृति",
    "Leatherwork": "यह प्रीमियम हस्तनिर्मित चमड़े की वस्तु",
    "BambooCane": "यह पर्यावरण-अनुकूल बांस व बेंत की वस्तु",
}


def generate_listing(tags, category, artisan_location=None):
    """Bilingual (EN + HI) SEO-friendly listing generator — purely
    template + lexicon driven, so it can never fail or need a network call."""
    specific = [t for t in tags if t not in GENERIC_TAGS]
    generic = [t for t in tags if t in GENERIC_TAGS]

    materials_en = [_terms_for(t, "en") for t in specific]
    materials_hi = [_terms_for(t, "hi") for t in specific]
    generic_en = [_terms_for(t, "en") for t in generic]
    generic_hi = [_terms_for(t, "hi") for t in generic]

    opener_en = CATEGORY_OPENERS_EN.get(category, "This handcrafted piece")
    opener_hi = CATEGORY_OPENERS_HI.get(category, "यह हस्तनिर्मित वस्तु")

    # --- English description ---
    en_parts = [opener_en]
    if materials_en:
        en_parts.append(f"features {', '.join(materials_en[:-1]) + ' and ' + materials_en[-1] if len(materials_en) > 1 else materials_en[0]}")
    if generic_en:
        en_parts.append(f"— {', '.join(generic_en)} and made with genuine artisan skill")
    location_note = f" Proudly handcrafted in {artisan_location}." if artisan_location else ""
    english_description = " ".join(en_parts).strip() + "." + location_note
    english_description += f" A perfect addition for those who value authentic {category.lower()} craftsmanship and support India's heritage artisan community."

    seo_title_en = f"{'Handmade ' if 'handmade' in tags else ''}{category} — {', '.join([m.title() for m in materials_en[:2]]) if materials_en else 'Handcrafted Piece'}".strip(" —")

    # --- Hindi description ---
    hi_parts = [opener_hi]
    if materials_hi:
        hi_parts.append(f"में {', '.join(materials_hi)} की झलक मिलती है")
    if generic_hi:
        hi_parts.append(f"यह {', '.join(generic_hi)} है")
    hindi_description = " ".join(hi_parts).strip() + "।"
    hindi_description += f" यह भारत की समृद्ध शिल्प विरासत और कारीगरों के कौशल का प्रतीक है।"

    seo_title_hi = f"{CATEGORY_DISPLAY_HI.get(category, category)} — {', '.join(materials_hi[:2]) if materials_hi else 'हस्तनिर्मित वस्तु'}"

    # SEO keywords (English) — useful for e-marketplace listing metadata
    seo_keywords = list(dict.fromkeys(
        [category.lower()] + materials_en + generic_en + ["handmade in india", "artisan made", "heritage craft"]
    ))

    return {
        "seo_title_en": seo_title_en,
        "description_en": english_description,
        "seo_title_hi": seo_title_hi,
        "description_hi": hindi_description,
        "seo_keywords": seo_keywords,
    }


def full_pipeline(text, artisan_location=None):
    """End-to-end: raw text (Hindi or English) -> tags -> category -> listing."""
    tags = extract_tags(text)
    category, confidence = predict_category(tags)
    if category is None:
        return {
            "success": False,
            "message": "We couldn't detect any recognizable product details. Try mentioning the material (e.g. cotton, brass, terracotta), technique (e.g. handwoven, carved), or product type.",
        }
    listing = generate_listing(tags, category, artisan_location)
    return {
        "success": True,
        "tags": tags,
        "category": category,
        "category_confidence": confidence,
        **listing,
    }
