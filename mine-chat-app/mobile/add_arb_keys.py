import glob
import json
import os

# Carpeta donde están los archivos .arb
ARB_FOLDER = "lib/l10n"

# Traducciones para cada clave y cada idioma/variante
translations = {
    "statusListening": {
        "en": "Listening",
        "es": "Escuchando",
        "es_419": "Escuchando",
        "fr": "Écoute",
        "pt": "Ouvindo",
        "pt_BR": "Ouvindo",
        "de": "Zuhören",
        "it": "In ascolto",
        "ar": "يستمع",
        "ja": "聞いています",
        "zh": "正在聆听",
        "ru": "Слушает",
        "ko": "듣는 중",
        "bg": "Слуша",
        "nl": "Luisteren",
        "he": "מקשיב",
        "hi": "सुन रहा है",
        "el": "Ακούει",
        "hu": "Hallgat",
        "pl": "Słuchanie",
        "tl": "Nakikinig",
        "tr": "Dinliyor",
        "vi": "Đang nghe",
    },
    "statusThinking": {
        "en": "Thinking",
        "es": "Pensando",
        "es_419": "Pensando",
        "fr": "Réflexion",
        "pt": "Pensando",
        "pt_BR": "Pensando",
        "de": "Denkt nach",
        "it": "Sta pensando",
        "ar": "يفكر",
        "ja": "考えています",
        "zh": "思考中",
        "ru": "Думает",
        "ko": "생각 중",
        "bg": "Мисли",
        "nl": "Denkt na",
        "he": "חושב",
        "hi": "सोच रहा है",
        "el": "Σκέφτεται",
        "hu": "Gondolkodik",
        "pl": "Myśli",
        "tl": "Nag-iisip",
        "tr": "Düşünüyor",
        "vi": "Đang suy nghĩ",
    },
    "statusSpeaking": {
        "en": "Speaking",
        "es": "Hablando",
        "es_419": "Hablando",
        "fr": "Parle",
        "pt": "Falando",
        "pt_BR": "Falando",
        "de": "Spricht",
        "it": "Parlando",
        "ar": "يتحدث",
        "ja": "話しています",
        "zh": "正在说话",
        "ru": "Говорит",
        "ko": "말하는 중",
        "bg": "Говори",
        "nl": "Spreekt",
        "he": "מדבר",
        "hi": "बोल रहा है",
        "el": "Μιλάει",
        "hu": "Beszél",
        "pl": "Mówi",
        "tl": "Nagsasalita",
        "tr": "Konuşuyor",
        "vi": "Đang nói",
    },
    "statusWaiting": {
        "en": "Waiting",
        "es": "Esperando",
        "es_419": "Esperando",
        "fr": "En attente",
        "pt": "Aguardando",
        "pt_BR": "Aguardando",
        "de": "Wartet",
        "it": "In attesa",
        "ar": "ينتظر",
        "ja": "待機中",
        "zh": "等待中",
        "ru": "Ожидает",
        "ko": "기다리는 중",
        "bg": "Чака",
        "nl": "Wachten",
        "he": "ממתין",
        "hi": "इंतजार कर रहा है",
        "el": "Περιμένει",
        "hu": "Várakozik",
        "pl": "Czeka",
        "tl": "Naghihintay",
        "tr": "Bekliyor",
        "vi": "Đang chờ",
    },
    "enableVibration": {
        "en": "Enable vibration",
        "es": "Activar vibración",
        "es_419": "Activar vibración",
        "fr": "Activer la vibration",
        "pt": "Ativar vibração",
        "pt_BR": "Ativar vibração",
        "de": "Vibration aktivieren",
        "it": "Abilita vibrazione",
        "ar": "تفعيل الاهتزاز",
        "ja": "バイブレーションを有効にする",
        "zh": "启用振动",
        "ru": "Включить вибрацию",
        "ko": "진동 켜기",
        "bg": "Включване на вибрацията",
        "nl": "Trilling inschakelen",
        "he": "הפעל רטט",
        "hi": "वाइब्रेशन सक्षम करें",
        "el": "Ενεργοποίηση δόνησης",
        "hu": "Rezgés engedélyezése",
        "pl": "Włącz wibracje",
        "tl": "Paganahin ang vibration",
        "tr": "Titreşimi etkinleştir",
        "vi": "Bật rung",
    },
    "enableSound": {
        "en": "Enable sound",
        "es": "Activar sonido",
        "es_419": "Activar sonido",
        "fr": "Activer le son",
        "pt": "Ativar som",
        "pt_BR": "Ativar som",
        "de": "Ton aktivieren",
        "it": "Abilita suono",
        "ar": "تفعيل الصوت",
        "ja": "サウンドを有効にする",
        "zh": "启用声音",
        "ru": "Включить звук",
        "ko": "소리 켜기",
        "bg": "Включване на звука",
        "nl": "Geluid inschakelen",
        "he": "הפעל קול",
        "hi": "ध्वनि सक्षम करें",
        "el": "Ενεργοποίηση ήχου",
        "hu": "Hang engedélyezése",
        "pl": "Włącz dźwięk",
        "tl": "Paganahin ang tunog",
        "tr": "Sesi etkinleştir",
        "vi": "Bật âm thanh",
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
