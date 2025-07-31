import glob
import json
import os

# Carpeta donde están los archivos .arb
ARB_FOLDER = "lib/l10n"

# Traducciones para cada clave y cada idioma/variante
translations = {
    "avatar_button_generate": {
        "en": "Generate Video",
        "es": "Generar video",
        "es_419": "Generar video",
        "pt": "Gerar vídeo",
        "pt_BR": "Gerar vídeo",
        "fr": "Générer une vidéo",
        "it": "Genera video",
        "de": "Video generieren",
        "ar": "إنشاء فيديو",
        "ja": "ビデオを生成",
        "zh": "生成视频",
        "ru": "Создать видео",
        "ko": "비디오 생성",
        "bg": "Генерирай видео",
        "he": "צור וידאו",
        "hi": "वीडियो बनाएं",
        "el": "Δημιουργία βίντεο",
        "hu": "Videó generálása",
        "pl": "Generuj wideo",
        "tl": "Gumawa ng video",
        "tr": "Video oluştur",
        "vi": "Tạo video",
    },
    # Puedes agregar más claves aquí, ej.:
    # "change_avatar_type": {...},
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
        if value and key not in data:
            data[key] = value
            updated = True
            print(f"{filename}: clave '{key}' agregada")

    if updated:
        with open(filename, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)

print("¡Listo! Revisa los archivos .arb actualizados.")
