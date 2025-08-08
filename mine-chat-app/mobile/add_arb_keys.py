import glob
import json
import os

# Carpeta donde están los archivos .arb
ARB_FOLDER = "lib/l10n"

# Traducciones para cada clave y cada idioma/variante
translations = {
    "field_required": {
        "en": "Required",
        "es": "Requerido",
        "es_419": "Requerido",
        "fr": "Requis",
        "pt": "Obrigatório",
        "pt_BR": "Obrigatório",
        "de": "Erforderlich",
        "it": "Obbligatorio",
        "ar": "مطلوب",
        "ja": "必須",
        "zh": "必填",
        "ru": "Обязательно",
        "ko": "필수",
        "bg": "Задължително",
        "nl": "Vereist",
        "he": "נדרש",
        "hi": "आवश्यक",
        "el": "Απαιτείται",
        "hu": "Kötelező",
        "pl": "Wymagane",
        "tl": "Kailangan",
        "tr": "Gerekli",
        "vi": "Bắt buộc",
    },
    "field_optional": {
        "en": "Optional",
        "es": "Opcional",
        "es_419": "Opcional",
        "fr": "Optionnel",
        "pt": "Opcional",
        "pt_BR": "Opcional",
        "de": "Optional",
        "it": "Opzionale",
        "ar": "اختياري",
        "ja": "任意",
        "zh": "可选",
        "ru": "Необязательно",
        "ko": "선택 사항",
        "bg": "По избор",
        "nl": "Optioneel",
        "he": "אופציונלי",
        "hi": "वैकल्पिक",
        "el": "Προαιρετικό",
        "hu": "Opcionális",
        "pl": "Opcjonalne",
        "tl": "Opsyonal",
        "tr": "İsteğe bağlı",
        "vi": "Tùy chọn",
    }
}


def get_locale_from_filename(filename):
    base = os.path.basename(filename)
    # Ejemplo: app_es_419.arb o app_en.arb
    parts = base.replace('.arb', '').split('_')
    if len(parts) == 3:
        return f"{parts[1]}_{parts[2]}"
    elif len(parts) == 2:
        return parts[1]
    else:
        return "en"

for filename in glob.glob(f"{ARB_FOLDER}/*.arb"):
    with open(filename, "r", encoding="utf-8") as f:
        data = json.load(f)

    locale = data.get("@@locale") or get_locale_from_filename(filename)
    # Normalizar pt-BR, es-419, etc.
    locale = locale.replace("-", "_")

    updated = False

    for key, lang_dict in translations.items():
        # Buscar traducción por código exacto, luego por idioma base
        value = lang_dict.get(locale) or lang_dict.get(locale.split("_")[0])
        if value:
            if key not in data or data[key] != value:
                data[key] = value
                updated = True
                print(f"{filename}: clave '{key}' agregada/actualizada")


    if updated:
        with open(filename, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)

print("¡Listo! Revisa los archivos .arb actualizados.")
