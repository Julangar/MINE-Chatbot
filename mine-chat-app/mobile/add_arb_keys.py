import glob
import json
import os

# Carpeta donde están los archivos .arb
ARB_FOLDER = "lib/l10n"

# Traducciones para cada clave y cada idioma/variante
translations = {
    "chatTitle": {
        "en": "Chat",
        "es": "Chat",
        "es_419": "Chat",
        "fr": "Discussion",
        "pt": "Chat",
        "pt_BR": "Chat",
        "de": "Chat",
        "it": "Chat",
        "ar": "الدردشة",
        "ja": "チャット",
        "zh": "聊天",
        "ru": "Чат",
        "ko": "채팅",
        "bg": "Чат",
        "nl": "Chat",
        "he": "צ׳אט",
        "hi": "चैट",
        "el": "Συνομιλία",
        "hu": "Csevegés",
        "pl": "Czat",
        "tl": "Chat",
        "tr": "Sohbet",
        "vi": "Trò chuyện",
    },
    "replyLabel": {
        "en": "Response:",
        "es": "Respuesta:",
        "es_419": "Respuesta:",
        "fr": "Réponse :",
        "pt": "Resposta:",
        "pt_BR": "Resposta:",
        "de": "Antwort:",
        "it": "Risposta:",
        "ar": "الرد:",
        "ja": "返答：",
        "zh": "回复：",
        "ru": "Ответ:",
        "ko": "응답:",
        "bg": "Отговор:",
        "nl": "Antwoord:",
        "he": "תגובה:",
        "hi": "प्रतिक्रिया:",
        "el": "Απάντηση:",
        "hu": "Válasz:",
        "pl": "Odpowiedź:",
        "tl": "Sagot:",
        "tr": "Yanıt:",
        "vi": "Phản hồi:",
    },
    "textOption": {
        "en": "Text",
        "es": "Texto",
        "es_419": "Texto",
        "fr": "Texte",
        "pt": "Texto",
        "pt_BR": "Texto",
        "de": "Text",
        "it": "Testo",
        "ar": "نص",
        "ja": "テキスト",
        "zh": "文字",
        "ru": "Текст",
        "ko": "텍스트",
        "bg": "Текст",
        "nl": "Tekst",
        "he": "טקסט",
        "hi": "पाठ",
        "el": "Κείμενο",
        "hu": "Szöveg",
        "pl": "Tekst",
        "tl": "Teksto",
        "tr": "Metin",
        "vi": "Văn bản",
    },
    "audioOption": {
        "en": "Audio",
        "es": "Audio",
        "es_419": "Audio",
        "fr": "Audio",
        "pt": "Áudio",
        "pt_BR": "Áudio",
        "de": "Audio",
        "it": "Audio",
        "ar": "صوت",
        "ja": "オーディオ",
        "zh": "音频",
        "ru": "Аудио",
        "ko": "오디오",
        "bg": "Аудио",
        "nl": "Audio",
        "he": "שמע",
        "hi": "ऑडियो",
        "el": "Ήχος",
        "hu": "Hang",
        "pl": "Dźwięk",
        "tl": "Audio",
        "tr": "Ses",
        "vi": "Âm thanh",
    },
    "videoOption": {
        "en": "Video",
        "es": "Video",
        "es_419": "Video",
        "fr": "Vidéo",
        "pt": "Vídeo",
        "pt_BR": "Vídeo",
        "de": "Video",
        "it": "Video",
        "ar": "فيديو",
        "ja": "ビデオ",
        "zh": "视频",
        "ru": "Видео",
        "ko": "비디오",
        "bg": "Видео",
        "nl": "Video",
        "he": "וידאו",
        "hi": "वीडियो",
        "el": "Βίντεο",
        "hu": "Videó",
        "pl": "Wideo",
        "tl": "Video",
        "tr": "Video",
        "vi": "Video",
    },
    "inputHint": {
        "en": "Type your message...",
        "es": "Escribe tu mensaje...",
        "es_419": "Escribe tu mensaje...",
        "fr": "Tapez votre message...",
        "pt": "Digite sua mensagem...",
        "pt_BR": "Digite sua mensagem...",
        "de": "Gib deine Nachricht ein...",
        "it": "Scrivi il tuo messaggio...",
        "ar": "اكتب رسالتك...",
        "ja": "メッセージを入力してください...",
        "zh": "输入你的消息...",
        "ru": "Введите сообщение...",
        "ko": "메시지를 입력하세요...",
        "bg": "Въведете съобщението си...",
        "nl": "Typ je bericht...",
        "he": "הקלד את ההודעה שלך...",
        "hi": "अपना संदेश लिखें...",
        "el": "Πληκτρολογήστε το μήνυμά σας...",
        "hu": "Írd be az üzeneted...",
        "pl": "Wpisz swoją wiadomość...",
        "tl": "I-type ang iyong mensahe...",
        "tr": "Mesajınızı yazın...",
        "vi": "Nhập tin nhắn của bạn...",
    },
    "noResponse": {
        "en": "[No response]",
        "es": "[Sin respuesta]",
        "es_419": "[Sin respuesta]",
        "fr": "[Pas de réponse]",
        "pt": "[Sem resposta]",
        "pt_BR": "[Sem resposta]",
        "de": "[Keine Antwort]",
        "it": "[Nessuna risposta]",
        "ar": "[لا توجد استجابة]",
        "ja": "[応答なし]",
        "zh": "[无响应]",
        "ru": "[Нет ответа]",
        "ko": "[응답 없음]",
        "bg": "[Няма отговор]",
        "nl": "[Geen antwoord]",
        "he": "[אין תגובה]",
        "hi": "[कोई उत्तर नहीं]",
        "el": "[Χωρίς απάντηση]",
        "hu": "[Nincs válasz]",
        "pl": "[Brak odpowiedzi]",
        "tl": "[Walang tugon]",
        "tr": "[Yanıt yok]",
        "vi": "[Không có phản hồi]",
    },
    "audioGenerated": {
        "en": "Generated audio",
        "es": "Audio generado",
        "es_419": "Audio generado",
        "fr": "Audio généré",
        "pt": "Áudio gerado",
        "pt_BR": "Áudio gerado",
        "de": "Erzeugtes Audio",
        "it": "Audio generato",
        "ar": "الصوت الناتج",
        "ja": "生成された音声",
        "zh": "生成的音频",
        "ru": "Сгенерированное аудио",
        "ko": "생성된 오디오",
        "bg": "Генерирано аудио",
        "nl": "Gegenereerde audio",
        "he": "שמע שנוצר",
        "hi": "जनित ऑडियो",
        "el": "Δημιουργημένος ήχος",
        "hu": "Generált hang",
        "pl": "Wygenerowany dźwięk",
        "tl": "Nabuo na audio",
        "tr": "Oluşturulan ses",
        "vi": "Âm thanh đã tạo",
    },
    "videoGenerated": {
        "en": "Generated video",
        "es": "Video generado",
        "es_419": "Video generado",
        "fr": "Vidéo générée",
        "pt": "Vídeo gerado",
        "pt_BR": "Vídeo gerado",
        "de": "Erzeugtes Video",
        "it": "Video generato",
        "ar": "الفيديو الناتج",
        "ja": "生成されたビデオ",
        "zh": "生成的视频",
        "ru": "Сгенерированное видео",
        "ko": "생성된 비디오",
        "bg": "Генерирано видео",
        "nl": "Gegenereerde video",
        "he": "וידאו שנוצר",
        "hi": "जनित वीडियो",
        "el": "Δημιουργημένο βίντεο",
        "hu": "Generált videó",
        "pl": "Wygenerowane wideo",
        "tl": "Nabuo na video",
        "tr": "Oluşturulan video",
        "vi": "Video đã tạo",
    },
    "error": {
        "en": "Error: {error}",
        "es": "Error: {error}",
        "es_419": "Error: {error}",
        "fr": "Erreur : {error}",
        "pt": "Erro: {error}",
        "pt_BR": "Erro: {error}",
        "de": "Fehler: {error}",
        "it": "Errore: {error}",
        "ar": "خطأ: {error}",
        "ja": "エラー：{error}",
        "zh": "错误：{error}",
        "ru": "Ошибка: {error}",
        "ko": "오류: {error}",
        "bg": "Грешка: {error}",
        "nl": "Fout: {error}",
        "he": "שגיאה: {error}",
        "hi": "त्रुटि: {error}",
        "el": "Σφάλμα: {error}",
        "hu": "Hiba: {error}",
        "pl": "Błąd: {error}",
        "tl": "Error: {error}",
        "tr": "Hata: {error}",
        "vi": "Lỗi: {error}",
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
