import glob
import json
import os

# Carpeta donde están los archivos .arb
ARB_FOLDER = "lib/l10n"

# Traducciones para cada clave y cada idioma/variante
translations = {
    "interest_sports": {
        "en": "Sports",
        "es": "Deportes",
        "es_419": "Deportes",
        "fr": "Sports",
        "pt": "Esportes",
        "pt_BR": "Esportes",
        "de": "Sport",
        "it": "Sport",
        "ar": "رياضة",
        "ja": "スポーツ",
        "zh": "运动",
        "ru": "Спорт",
        "ko": "스포츠",
        "bg": "Спорт",
        "nl": "Sport",
        "he": "ספורט",
        "hi": "खेल",
        "el": "Αθλήματα",
        "hu": "Sport",
        "pl": "Sport",
        "tl": "Palakasan",
        "tr": "Spor",
        "vi": "Thể thao",
    },
    "interest_art": {
        "en": "Art",
        "es": "Arte",
        "es_419": "Arte",
        "fr": "Art",
        "pt": "Arte",
        "pt_BR": "Arte",
        "de": "Kunst",
        "it": "Arte",
        "ar": "فن",
        "ja": "アート",
        "zh": "艺术",
        "ru": "Искусство",
        "ko": "예술",
        "bg": "Изкуство",
        "nl": "Kunst",
        "he": "אומנות",
        "hi": "कला",
        "el": "Τέχνη",
        "hu": "Művészet",
        "pl": "Sztuka",
        "tl": "Sining",
        "tr": "Sanat",
        "vi": "Nghệ thuật",
    },
    "interest_cooking": {
        "en": "Cooking",
        "es": "Cocina",
        "es_419": "Cocina",
        "fr": "Cuisine",
        "pt": "Culinária",
        "pt_BR": "Culinária",
        "de": "Kochen",
        "it": "Cucina",
        "ar": "طبخ",
        "ja": "料理",
        "zh": "烹饪",
        "ru": "Кулинария",
        "ko": "요리",
        "bg": "Готвене",
        "nl": "Koken",
        "he": "בישול",
        "hi": "खाना बनाना",
        "el": "Μαγειρική",
        "hu": "Főzés",
        "pl": "Gotowanie",
        "tl": "Pagluluto",
        "tr": "Yemek pişirme",
        "vi": "Nấu ăn",
    },
    "interest_science": {
        "en": "Science",
        "es": "Ciencia",
        "es_419": "Ciencia",
        "fr": "Science",
        "pt": "Ciência",
        "pt_BR": "Ciência",
        "de": "Wissenschaft",
        "it": "Scienza",
        "ar": "علوم",
        "ja": "科学",
        "zh": "科学",
        "ru": "Наука",
        "ko": "과학",
        "bg": "Наука",
        "nl": "Wetenschap",
        "he": "מדע",
        "hi": "विज्ञान",
        "el": "Επιστήμη",
        "hu": "Tudomány",
        "pl": "Nauka",
        "tl": "Agham",
        "tr": "Bilim",
        "vi": "Khoa học",
    },
    "style_serio": {
        "en": "Serious",
        "es": "Serio",
        "es_419": "Serio",
        "fr": "Sérieux",
        "pt": "Sério",
        "pt_BR": "Sério",
        "de": "Ernst",
        "it": "Serio",
        "ar": "جاد",
        "ja": "真面目",
        "zh": "严肃",
        "ru": "Серьезный",
        "ko": "진지한",
        "bg": "Сериозен",
        "nl": "Serieus",
        "he": "רציני",
        "hi": "गंभीर",
        "el": "Σοβαρός",
        "hu": "Komoly",
        "pl": "Poważny",
        "tl": "Seryoso",
        "tr": "Ciddi",
        "vi": "Nghiêm túc",
    },
    "style_amistoso": {
        "en": "Friendly",
        "es": "Amistoso",
        "es_419": "Amistoso",
        "fr": "Amical",
        "pt": "Amigável",
        "pt_BR": "Amigável",
        "de": "Freundlich",
        "it": "Amichevole",
        "ar": "ودود",
        "ja": "フレンドリー",
        "zh": "友好",
        "ru": "Дружелюбный",
        "ko": "친근한",
        "bg": "Приятелски",
        "nl": "Vriendelijk",
        "he": "ידידותי",
        "hi": "मित्रतापूर्ण",
        "el": "Φιλικός",
        "hu": "Barátságos",
        "pl": "Przyjazny",
        "tl": "Magiliw",
        "tr": "Samimi",
        "vi": "Thân thiện",
    },
    "style_profesional": {
        "en": "Professional",
        "es": "Profesional",
        "es_419": "Profesional",
        "fr": "Professionnel",
        "pt": "Profissional",
        "pt_BR": "Profissional",
        "de": "Professionell",
        "it": "Professionale",
        "ar": "محترف",
        "ja": "プロフェッショナル",
        "zh": "专业",
        "ru": "Профессиональный",
        "ko": "전문적인",
        "bg": "Професионален",
        "nl": "Professioneel",
        "he": "מקצועי",
        "hi": "पेशेवर",
        "el": "Επαγγελματικός",
        "hu": "Professzionális",
        "pl": "Profesjonalny",
        "tl": "Propesyonal",
        "tr": "Profesyonel",
        "vi": "Chuyên nghiệp",
    },
    "style_humoristico": {
        "en": "Humorous",
        "es": "Humorístico",
        "es_419": "Humorístico",
        "fr": "Humoristique",
        "pt": "Humorístico",
        "pt_BR": "Humorístico",
        "de": "Humorvoll",
        "it": "Divertente",
        "ar": "فكاهي",
        "ja": "ユーモラス",
        "zh": "幽默",
        "ru": "Юмористический",
        "ko": "유머러스한",
        "bg": "Хумористичен",
        "nl": "Humoristisch",
        "he": "הומוריסטי",
        "hi": "हास्यपूर्ण",
        "el": "Χιουμοριστικός",
        "hu": "Humoros",
        "pl": "Humorystyczny",
        "tl": "Nakakatawa",
        "tr": "Esprili",
        "vi": "Hài hước",
    },
    "avatar_form_add_phrase_hint": {
        "en": "e.g. Be brave, I miss you, Hello!, I love you!",
        "es": "p. ej., Sé valiente, Te extraño, ¡Hola!, Te amo",
        "es_419": "p. ej., Sé valiente, Te extraño, ¡Hola!, Te amo",
        "fr": "ex. Soyez courageux, Tu me manques, Bonjour !, Je t'aime",
        "pt": "ex.: Seja corajoso, Sinto sua falta, Olá!, Eu te amo",
        "pt_BR": "ex.: Seja corajoso, Sinto sua falta, Olá!, Eu te amo",
        "de": "z. B. Sei mutig, Ich vermisse dich, Hallo!, Ich liebe dich",
        "it": "es.: Sii coraggioso, Mi manchi, Ciao!, Ti amo",
        "ar": "مثال: كن شجاعًا، أفتقدك، مرحبًا!، أحبك",
        "ja": "例: 勇気を出して、会いたい、こんにちは！、愛してる",
        "zh": "例如：勇敢点，我想你，你好！，我爱你",
        "ru": "например: Будь храбр, Я скучаю по тебе, Привет!, Я тебя люблю",
        "ko": "예: 용감해져, 보고 싶어, 안녕!, 사랑해",
        "bg": "напр.: Бъди смел, Липсваш ми, Здравей!, Обичам те",
        "nl": "bijv. Wees moedig, Ik mis je, Hallo!, Ik hou van je",
        "he": "לדוגמה: היה אמיץ, אני מתגעגע אליך, שלום!, אני אוהב אותך",
        "hi": "उदाहरण: साहसी बनो, मुझे तुम्हारी याद आती है, नमस्ते!, मैं तुमसे प्यार करता हूँ",
        "el": "π.χ. Να είσαι γενναίος, Μου λείπεις, Γειά!, Σ' αγαπώ",
        "hu": "pl.: Légy bátor, Hiányzol, Helló!, Szeretlek",
        "pl": "np. Bądź odważny, Tęsknię za tobą, Cześć!, Kocham cię",
        "tl": "hal. Maging matapang, Miss kita, Kumusta!, Mahal kita",
        "tr": "ör. Cesur ol, Seni özledim, Merhaba!, Seni seviyorum",
        "vi": "ví dụ: Hãy dũng cảm, Anh nhớ em, Xin chào!, Anh yêu em",
    },
    "avatar_form_relationship_label": {
        "en": "Relationship or role (e.g. friend, coach, sibling, fiance)",
        "es": "Relación o rol (p. ej., amigo, entrenador, hermano, prometido)",
        "es_419": "Relación o rol (p. ej., amigo, entrenador, hermano, prometido)",
        "fr": "Relation ou rôle (ex. ami, entraîneur, frère/soeur, fiancé)",
        "pt": "Relação ou papel (ex.: amigo, treinador, irmão, noivo)",
        "pt_BR": "Relação ou papel (ex.: amigo, treinador, irmão, noivo)",
        "de": "Beziehung oder Rolle (z. B. Freund, Trainer, Geschwister, Verlobter)",
        "it": "Relazione o ruolo (es. amico, allenatore, fratello/sorella, fidanzato)",
        "ar": "العلاقة أو الدور (مثال: صديق، مدرب، شقيق، خطيب)",
        "ja": "関係または役割（例：友達、コーチ、兄弟姉妹、婚約者）",
        "zh": "关系或角色（例如：朋友、教练、兄弟姐妹、未婚夫）",
        "ru": "Отношения или роль (например, друг, тренер, брат/сестра, жених)",
        "ko": "관계 또는 역할 (예: 친구, 코치, 형제자매, 약혼자)",
        "bg": "Връзка или роля (напр. приятел, треньор, брат/сестра, годеник)",
        "nl": "Relatie of rol (bijv. vriend, coach, broer/zus, verloofde)",
        "he": "קשר או תפקיד (לדוגמה: חבר, מאמן, אח, ארוס)",
        "hi": "संबंध या भूमिका (जैसे दोस्त, कोच, भाई/बहन, मंगेतर)",
        "el": "Σχέση ή ρόλος (π.χ. φίλος, προπονητής, αδελφός/αδελφή, μνηστήρας)",
        "hu": "Kapcsolat vagy szerep (pl.: barát, edző, testvér, jegyes)",
        "pl": "Relacja lub rola (np. przyjaciel, trener, rodzeństwo, narzeczony)",
        "tl": "Relasyon o papel (hal. kaibigan, coach, kapatid, kasintahan)",
        "tr": "İlişki veya rol (ör. arkadaş, koç, kardeş, nişanlı)",
        "vi": "Mối quan hệ hoặc vai trò (ví dụ: bạn bè, huấn luyện viên, anh/chị em, hôn phu)",
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
