import glob
import json
import os

# Carpeta donde están los archivos .arb
ARB_FOLDER = "lib/l10n"

# Traducciones para cada clave y cada idioma/variante
translations = {
    "avatar_form_country_label": {
        "en": "What country is your avatar from?",
        "es": "¿De qué país es tu avatar?",
        "es_419": "¿De qué país es tu avatar?",
        "fr": "De quel pays vient votre avatar ?",
        "pt": "De que país é o seu avatar?",
        "pt_BR": "De que país é o seu avatar?",
        "de": "Aus welchem Land stammt dein Avatar?",
        "it": "Da quale paese proviene il tuo avatar?",
        "ar": "من أي بلد هو صورتك الرمزية؟",
        "ja": "あなたのアバターはどこの国のものですか？",
        "zh": "你的头像来自哪个国家？",
        "ru": "Из какой страны ваш аватар?",
        "ko": "아바타는 어느 나라 출신입니까?",
        "bg": "От коя държава е вашият аватар?",
        "nl": "Uit welk land komt je avatar?",
        "he": "מאיזו מדינה הדמות שלך?",
        "hi": "आपका अवतार किस देश का है?",
        "el": "Από ποια χώρα είναι το avatar σας;",
        "hu": "Melyik országból származik az avatarod?",
        "pl": "Z jakiego kraju pochodzi twój awatar?",
        "tl": "Mula saang bansa ang iyong avatar?",
        "tr": "Avatarınız hangi ülkeden?",
        "vi": "Avatar của bạn đến từ quốc gia nào?",
    },
    "avatar_form_phone_label": {
        "en": "Phone number",
        "es": "Número de teléfono",
        "es_419": "Número de teléfono",
        "fr": "Numéro de téléphone",
        "pt": "Número de telefone",
        "pt_BR": "Número de telefone",
        "de": "Telefonnummer",
        "it": "Numero di telefono",
        "ar": "رقم الهاتف",
        "ja": "電話番号",
        "zh": "电话号码",
        "ru": "Номер телефона",
        "ko": "전화번호",
        "bg": "Телефонен номер",
        "nl": "Telefoonnummer",
        "he": "מספר טלפון",
        "hi": "फ़ोन नंबर",
        "el": "Αριθμός τηλεφώνου",
        "hu": "Telefonszám",
        "pl": "Numer telefonu",
        "tl": "Numero ng telepono",
        "tr": "Telefon numarası",
        "vi": "Số điện thoại",
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
