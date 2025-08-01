import glob
import json
import os

# Carpeta donde están los archivos .arb
ARB_FOLDER = "lib/l10n"

# Traducciones para cada clave y cada idioma/variante
translations = {
    "avatar_summary_greeting_audio": {
        "es": "Saludo inicial",
        "es_419": "Saludo inicial",
        "en": "Initial greeting",
        "fr": "Salutation initiale",
        "pt": "Saudação inicial",
        "pt_BR": "Saudação inicial",
        "de": "Begrüßung",
        "it": "Saluto iniziale",
        "ar": "التحية الأولية",
        "ja": "最初の挨拶",
        "zh": "初始问候",
        "ru": "Приветствие",
        "ko": "초기 인사",
        "bg": "Първоначален поздрав",
        "nl": "Eerste begroeting",
        "he": "ברכה ראשונית",
        "hi": "प्रारंभिक अभिवादन",
        "el": "Αρχικός χαιρετισμός",
        "hu": "Kezdő üdvözlet",
        "pl": "Powitanie początkowe",
        "tl": "Paunang pagbati",
        "tr": "Başlangıç selamı",
        "vi": "Lời chào đầu tiên",
    },
    "avatar_summary_play_audio": {
        "es": "Reproducir audio",
        "es_419": "Reproducir audio",
        "en": "Play audio",
        "fr": "Lire l’audio",
        "pt": "Reproduzir áudio",
        "pt_BR": "Reproduzir áudio",
        "de": "Audio abspielen",
        "it": "Riproduci audio",
        "ar": "تشغيل الصوت",
        "ja": "音声を再生",
        "zh": "播放音频",
        "ru": "Воспроизвести аудио",
        "ko": "오디오 재생",
        "bg": "Възпроизвеждане на аудио",
        "nl": "Audio afspelen",
        "he": "נגן אודיו",
        "hi": "ऑडियो चलाएं",
        "el": "Αναπαραγωγή ήχου",
        "hu": "Hang lejátszása",
        "pl": "Odtwórz dźwięk",
        "tl": "I-play ang audio",
        "tr": "Sesi oynat",
        "vi": "Phát âm thanh",
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
        if value and key not in data:
            data[key] = value
            updated = True
            print(f"{filename}: clave '{key}' agregada")

    if updated:
        with open(filename, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)

print("¡Listo! Revisa los archivos .arb actualizados.")
