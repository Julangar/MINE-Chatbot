import glob
import json
import os

# Carpeta donde están los archivos .arb
ARB_FOLDER = "lib/l10n"

# Traducciones para cada clave y cada idioma/variante
translations = {
    "play": {
    "en": "Play",
    "es": "Reproducir",
    "es_419": "Reproducir",
    "fr": "Lire",
    "pt": "Reproduzir",
    "pt_BR": "Reproduzir",
    "de": "Abspielen",
    "it": "Riproduci",
    "ar": "تشغيل",
    "ja": "再生",
    "zh": "播放",
    "ru": "Воспроизвести",
    "ko": "재생",
    "bg": "Пусни",
    "nl": "Afspelen",
    "he": "נגן",
    "hi": "चलाएं",
    "el": "Αναπαραγωγή",
    "hu": "Lejátszás",
    "pl": "Odtwórz",
    "tl": "I-play",
    "tr": "Oynat",
    "vi": "Phát",
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
