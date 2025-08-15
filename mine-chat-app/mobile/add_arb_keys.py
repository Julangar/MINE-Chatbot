import glob
import json
import os

# Carpeta donde están los archivos .arb
ARB_FOLDER = "lib/l10n"

# Traducciones para cada clave y cada idioma/variante
translations = {
    "bad_phone_number": {
        "en": "Use digits only (4–15)",
        "es": "Usa solo dígitos (4–15)",
        "es_419": "Usa solo dígitos (4–15)",
        "fr": "Utilisez uniquement des chiffres (4–15)",
        "pt": "Use apenas dígitos (4–15)",
        "pt_BR": "Use apenas dígitos (4–15)",
        "de": "Nur Ziffern verwenden (4–15)",
        "it": "Usa solo cifre (4–15)",
        "ar": "استخدم الأرقام فقط (4–15)",
        "ja": "数字のみを使用 (4–15)",
        "zh": "仅使用数字 (4–15)",
        "ru": "Используйте только цифры (4–15)",
        "ko": "숫자만 사용 (4–15)",
        "bg": "Използвайте само цифри (4–15)",
        "nl": "Gebruik alleen cijfers (4–15)",
        "he": "השתמש רק בספרות (4–15)",
        "hi": "केवल अंक उपयोग करें (4–15)",
        "el": "Χρησιμοποιήστε μόνο ψηφία (4–15)",
        "hu": "Csak számjegyeket használjon (4–15)",
        "pl": "Używaj tylko cyfr (4–15)",
        "tl": "Gumamit lamang ng mga numero (4–15)",
        "tr": "Yalnızca rakam kullanın (4–15)",
        "vi": "Chỉ sử dụng chữ số (4–15)",
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
