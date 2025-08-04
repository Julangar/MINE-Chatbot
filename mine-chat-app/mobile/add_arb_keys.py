import glob
import json
import os

# Carpeta donde están los archivos .arb
ARB_FOLDER = "lib/l10n"

# Traducciones para cada clave y cada idioma/variante
translations = {
    "avatar_warning_edit_locked": {
        "en": "The avatar has already been generated. You cannot edit the personality, image or audio again.",
        "es": "El avatar ya ha sido generado. No puedes editar la personalidad, imagen o audio nuevamente.",
        "es_419": "El avatar ya fue generado. No puedes editar la personalidad, imagen ni audio otra vez.",
        "fr": "L’avatar a déjà été généré. Vous ne pouvez plus modifier la personnalité, l’image ou l’audio.",
        "pt": "O avatar já foi gerado. Você não pode editar a personalidade, imagem ou áudio novamente.",
        "pt_BR": "O avatar já foi gerado. Você não pode editar a personalidade, imagem ou áudio novamente.",
        "de": "Der Avatar wurde bereits erstellt. Du kannst Persönlichkeit, Bild oder Audio nicht mehr bearbeiten.",
        "it": "L’avatar è già stato generato. Non puoi modificare di nuovo la personalità, l’immagine o l’audio.",
        "ar": "تم إنشاء الصورة الرمزية بالفعل. لا يمكنك تعديل الشخصية أو الصورة أو الصوت مرة أخرى.",
        "ja": "アバターはすでに生成されています。性格、画像、または音声は再編集できません。",
        "zh": "头像已生成，不能再次编辑个性、图片或音频。",
        "ru": "Аватар уже был создан. Вы не можете снова редактировать личность, изображение или аудио.",
        "ko": "아바타가 이미 생성되었습니다. 성격, 이미지 또는 오디오는 다시 편집할 수 없습니다.",
        "bg": "Аватарът вече е генериран. Не можете да редактирате личността, изображението или аудиото отново.",
        "nl": "De avatar is al gegenereerd. Je kunt persoonlijkheid, afbeelding of audio niet opnieuw bewerken.",
        "he": "הדמות כבר נוצרה. לא ניתן לערוך שוב את האישיות, התמונה או האודיו.",
        "hi": "अवतार पहले ही बनाया जा चुका है। आप व्यक्तित्व, छवि या ऑडियो को फिर से संपादित नहीं कर सकते।",
        "el": "Το avatar έχει ήδη δημιουργηθεί. Δεν μπορείτε να επεξεργαστείτε ξανά την προσωπικότητα, την εικόνα ή τον ήχο.",
        "hu": "Az avatar már létrejött. Nem lehet újra szerkeszteni a személyiséget, képet vagy hangot.",
        "pl": "Awatar został już wygenerowany. Nie możesz ponownie edytować osobowości, obrazu ani dźwięku.",
        "tl": "Ang avatar ay nagawa na. Hindi mo na maaaring i-edit muli ang personalidad, larawan o audio.",
        "tr": "Avatar zaten oluşturuldu. Kişilik, resim veya sesi tekrar düzenleyemezsiniz.",
        "vi": "Avatar đã được tạo. Bạn không thể chỉnh sửa lại tính cách, hình ảnh hoặc âm thanh.",
    },
    "avatar_original_audio": {
        "en": "User's original audio",
        "es": "Audio original del usuario",
        "es_419": "Audio original del usuario",
        "fr": "Audio original de l’utilisateur",
        "pt": "Áudio original do usuário",
        "pt_BR": "Áudio original do usuário",
        "de": "Original-Audio des Nutzers",
        "it": "Audio originale dell’utente",
        "ar": "الصوت الأصلي للمستخدم",
        "ja": "ユーザーの元の音声",
        "zh": "用户的原始音频",
        "ru": "Оригинальное аудио пользователя",
        "ko": "사용자의 원본 오디오",
        "bg": "Оригинално аудио на потребителя",
        "nl": "Oorspronkelijke audio van de gebruiker",
        "he": "הקלטה המקורית של המשתמש",
        "hi": "उपयोगकर्ता की मूल ऑडियो",
        "el": "Αρχικό ηχητικό χρήστη",
        "hu": "Felhasználó eredeti hangja",
        "pl": "Oryginalny dźwięk użytkownika",
        "tl": "Orihinal na audio ng user",
        "tr": "Kullanıcının orijinal sesi",
        "vi": "Âm thanh gốc của người dùng",
    },
    "avatar_cloned_audio": {
        "en": "AI-generated cloned voice",
        "es": "Voz clonada generada por IA",
        "es_419": "Voz clonada por IA",
        "fr": "Voix clonée générée par IA",
        "pt": "Voz clonada gerada por IA",
        "pt_BR": "Voz clonada gerada por IA",
        "de": "KI-generierte Klonstimme",
        "it": "Voce clonata generata dall’IA",
        "ar": "صوت مستنسخ تم إنشاؤه بالذكاء الاصطناعي",
        "ja": "AI生成のクローン音声",
        "zh": "AI生成的克隆语音",
        "ru": "Синтезированный голос, созданный ИИ",
        "ko": "AI로 생성된 클론 음성",
        "bg": "Клониран глас, генериран от ИИ",
        "nl": "Door AI gegenereerde gekloonde stem",
        "he": "קול משוכפל שנוצר על ידי בינה מלאכותית",
        "hi": "एआई द्वारा जनित क्लोन आवाज़",
        "el": "Κλωνοποιημένη φωνή από ΤΝ",
        "hu": "Mesterséges intelligencia által generált hang",
        "pl": "Sklonowany głos wygenerowany przez SI",
        "tl": "AI-generated na kinopyang boses",
        "tr": "Yapay zeka tarafından oluşturulan klon ses",
        "vi": "Giọng nói nhân bản do AI tạo ra",
    },
    "avatar_video_result": {
        "en": "Generated avatar video",
        "es": "Video de avatar generado",
        "es_419": "Video de avatar generado",
        "fr": "Vidéo d’avatar générée",
        "pt": "Vídeo de avatar gerado",
        "pt_BR": "Vídeo de avatar gerado",
        "de": "Generiertes Avatar-Video",
        "it": "Video avatar generato",
        "ar": "فيديو صورة رمزية تم إنشاؤه",
        "ja": "生成されたアバター動画",
        "zh": "生成的头像视频",
        "ru": "Сгенерированное видео аватара",
        "ko": "생성된 아바타 비디오",
        "bg": "Генерирано видео аватар",
        "nl": "Gegenereerde avatarvideo",
        "he": "וידאו דמות שנוצר",
        "hi": "जनित अवतार वीडियो",
        "el": "Δημιουργημένο βίντεο avatar",
        "hu": "Generált avatar videó",
        "pl": "Wygenerowane wideo awatara",
        "tl": "Nabuong avatar na video",
        "tr": "Oluşturulan avatar videosu",
        "vi": "Video avatar đã tạo",
    },
    "avatar_button_generate": {
        "en": "Generate avatar",
        "es": "Generar avatar",
        "es_419": "Generar avatar",
        "fr": "Générer un avatar",
        "pt": "Gerar avatar",
        "pt_BR": "Gerar avatar",
        "de": "Avatar generieren",
        "it": "Genera avatar",
        "ar": "إنشاء صورة رمزية",
        "ja": "アバターを生成",
        "zh": "生成头像",
        "ru": "Создать аватар",
        "ko": "아바타 생성",
        "bg": "Генерирай аватар",
        "nl": "Avatar genereren",
        "he": "צור דמות",
        "hi": "अवतार बनाएं",
        "el": "Δημιουργία avatar",
        "hu": "Avatar generálása",
        "pl": "Wygeneruj awatara",
        "tl": "Gumawa ng avatar",
        "tr": "Avatar oluştur",
        "vi": "Tạo avatar",
    },
    "avatar_summary_title": {
        "en": "Avatar Summary",
        "es": "Resumen del avatar",
        "es_419": "Resumen del avatar",
        "fr": "Résumé de l’avatar",
        "pt": "Resumo do avatar",
        "pt_BR": "Resumo do avatar",
        "de": "Avatar-Übersicht",
        "it": "Riepilogo avatar",
        "ar": "ملخص الصورة الرمزية",
        "ja": "アバター概要",
        "zh": "头像摘要",
        "ru": "Сводка по аватару",
        "ko": "아바타 요약",
        "bg": "Обобщение на аватара",
        "nl": "Avataroverzicht",
        "he": "סיכום דמות",
        "hi": "अवतार सारांश",
        "el": "Σύνοψη avatar",
        "hu": "Avatar összegzés",
        "pl": "Podsumowanie awatara",
        "tl": "Buod ng avatar",
        "tr": "Avatar Özeti",
        "vi": "Tóm tắt avatar",
    },
    "avatar_summary_no_avatar": {
        "en": "No avatar information found.",
        "es": "No se ha encontrado el avatar",
        "es_419": "No se encontró el avatar",
        "fr": "Aucune information d’avatar trouvée.",
        "pt": "Nenhuma informação de avatar encontrada.",
        "pt_BR": "Nenhuma informação de avatar encontrada.",
        "de": "Keine Avatar-Informationen gefunden.",
        "it": "Nessuna informazione sull’avatar trovata.",
        "ar": "لم يتم العثور على معلومات عن الصورة الرمزية",
        "ja": "アバター情報が見つかりませんでした",
        "zh": "未找到头像信息",
        "ru": "Информация об аватаре не найдена.",
        "ko": "아바타 정보를 찾을 수 없습니다",
        "bg": "Не са намерени данни за аватар",
        "nl": "Geen avatarinformatie gevonden.",
        "he": "לא נמצאה מידע על הדמות",
        "hi": "कोई अवतार जानकारी नहीं मिली।",
        "el": "Δεν βρέθηκαν πληροφορίες για το avatar.",
        "hu": "Nem található avatar információ",
        "pl": "Nie znaleziono informacji o awatarze.",
        "tl": "Walang impormasyon ng avatar na nahanap.",
        "tr": "Avatar bilgisi bulunamadı.",
        "vi": "Không tìm thấy thông tin avatar.",
    },
    "avatar_summary_interests": {
        "en": "Interests:",
        "es": "Intereses:",
        "es_419": "Intereses:",
        "fr": "Centres d’intérêt :",
        "pt": "Interesses:",
        "pt_BR": "Interesses:",
        "de": "Interessen:",
        "it": "Interessi:",
        "ar": "الاهتمامات:",
        "ja": "興味：",
        "zh": "兴趣：",
        "ru": "Интересы:",
        "ko": "관심사:",
        "bg": "Интереси:",
        "nl": "Interesses:",
        "he": "תחומי עניין:",
        "hi": "रुचियाँ:",
        "el": "Ενδιαφέροντα:",
        "hu": "Érdeklődési körök:",
        "pl": "Zainteresowania:",
        "tl": "Mga interes:",
        "tr": "İlgi alanları:",
        "vi": "Sở thích:",
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
