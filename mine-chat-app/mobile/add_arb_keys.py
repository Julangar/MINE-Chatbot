import glob
import json
import os

# Carpeta donde están los archivos .arb
ARB_FOLDER = "lib/l10n"

# Traducciones para cada clave y cada idioma/variante
translations = {
    "avatar_summary_no_avatar": {
        "es": "No se ha encontrado el avatar",
        "es_419": "No se encontró el avatar",
        "en": "Avatar not found",
        "fr": "Avatar non trouvé",
        "pt": "Avatar não encontrado",
        "pt_BR": "Avatar não encontrado",
        "de": "Avatar nicht gefunden",
        "it": "Avatar non trovato",
        "ar": "لم يتم العثور على الصورة الرمزية",
        "ja": "アバターが見つかりませんでした",
        "zh": "未找到头像",
        "ru": "Аватар не найден",
        "ko": "아바타를 찾을 수 없습니다",
        "bg": "Аватарът не е намерен",
        "nl": "Avatar niet gevonden",
        "he": "האווטאר לא נמצא",
        "hi": "अवतार नहीं मिला",
        "el": "Δεν βρέθηκε το avatar",
        "hu": "Nem található avatar",
        "pl": "Nie znaleziono awatara",
        "tl": "Walang nahanap na avatar",
        "tr": "Avatar bulunamadı",
        "vi": "Không tìm thấy avatar",
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
