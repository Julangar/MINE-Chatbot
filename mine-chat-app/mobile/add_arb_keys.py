import glob
import json
import os

# Carpeta donde están los archivos .arb
ARB_FOLDER = "lib/l10n"

# Traducciones para cada clave y cada idioma/variante
translations = {
    "avatarGuideTitle": {
        "en": "Guide to upload the avatar",
        "es": "Guía para subir el avatar",
        "es_419": "Guía para subir el avatar",
        "fr": "Guide pour télécharger l'avatar",
        "pt": "Guia para enviar o avatar",
        "pt_BR": "Guia para enviar o avatar",
        "de": "Anleitung zum Hochladen des Avatars",
        "it": "Guida per caricare l'avatar",
        "ar": "دليل لرفع الصورة الرمزية",
        "ja": "アバターをアップロードするガイド",
        "zh": "上传头像指南",
        "ru": "Руководство по загрузке аватара",
        "ko": "아바타 업로드 가이드",
        "bg": "Ръководство за качване на аватар",
        "nl": "Handleiding voor het uploaden van de avatar",
        "he": "מדריך להעלאת האווטאר",
        "hi": "अवतार अपलोड करने के लिए मार्गदर्शिका",
        "el": "Οδηγός για να ανεβάσετε το avatar",
        "hu": "Útmutató az avatar feltöltéséhez",
        "pl": "Przewodnik po przesyłaniu awatara",
        "tl": "Gabay para mag-upload ng avatar",
        "tr": "Avatar yükleme rehberi",
        "vi": "Hướng dẫn tải lên avatar",
    },
    "avatarGuideImage": {
        "en": "Use a clear front-facing photo of the face with good lighting and a neutral background.",
        "es": "Utiliza una foto frontal clara del rostro con buena iluminación y fondo neutro.",
        "es_419": "Utiliza una foto frontal clara del rostro con buena iluminación y fondo neutro.",
        "fr": "Utilisez une photo claire du visage prise de face, avec un bon éclairage et un fond neutre.",
        "pt": "Use uma foto frontal nítida do rosto com boa iluminação e fundo neutro.",
        "pt_BR": "Use uma foto frontal nítida do rosto com boa iluminação e fundo neutro.",
        "de": "Verwenden Sie ein klares Frontalfoto des Gesichts mit guter Beleuchtung und neutralem Hintergrund.",
        "it": "Utilizza una foto frontale chiara del viso con buona illuminazione e sfondo neutro.",
        "ar": "استخدم صورة أمامية واضحة للوجه بإضاءة جيدة وخلفية محايدة.",
        "ja": "良い照明と中立的な背景で顔の正面写真を使用してください。",
        "zh": "使用光线良好、背景中性的清晰正面头像。",
        "ru": "Используйте четкое фото лица анфас с хорошим освещением и нейтральным фоном.",
        "ko": "좋은 조명과 중립적인 배경에서 얼굴 정면 사진을 사용하세요.",
        "bg": "Използвайте ясна снимка на лицето отпред с добро осветление и неутрален фон.",
        "nl": "Gebruik een duidelijke vooraanzichtfoto van het gezicht met goede verlichting en neutrale achtergrond.",
        "he": "השתמש בתמונה קדמית ברורה של הפנים עם תאורה טובה ורקע ניטרלי.",
        "hi": "अच्छी रोशनी और तटस्थ पृष्ठभूमि के साथ चेहरे की स्पष्ट फ्रंट फोटो का उपयोग करें।",
        "el": "Χρησιμοποιήστε μια καθαρή φωτογραφία προσώπου από μπροστά με καλό φωτισμό και ουδέτερο φόντο.",
        "hu": "Használjon jó megvilágítású, semleges hátterű, tiszta szemből készült arcképet.",
        "pl": "Użyj wyraźnego zdjęcia twarzy z przodu, z dobrym oświetleniem i neutralnym tłem.",
        "tl": "Gumamit ng malinaw na front-facing na larawan ng mukha na may magandang ilaw at neutral na background.",
        "tr": "İyi aydınlatmalı ve nötr arka planlı net bir yüzün önden fotoğrafını kullanın.",
        "vi": "Sử dụng ảnh chụp khuôn mặt chính diện rõ ràng với ánh sáng tốt và nền trung tính.",
    },
    "avatarGuideAudio": {
        "en": "Upload or record at least 15 seconds of clear voice without background noise.",
        "es": "Sube o graba al menos 15 segundos de voz clara sin ruido de fondo.",
        "es_419": "Sube o graba al menos 15 segundos de voz clara sin ruido de fondo.",
        "fr": "Téléchargez ou enregistrez au moins 15 secondes de voix claire sans bruit de fond.",
        "pt": "Envie ou grave pelo menos 15 segundos de voz clara sem ruído de fundo.",
        "pt_BR": "Envie ou grave pelo menos 15 segundos de voz clara sem ruído de fundo.",
        "de": "Laden Sie mindestens 15 Sekunden klare Stimme ohne Hintergrundgeräusche hoch oder nehmen Sie sie auf.",
        "it": "Carica o registra almeno 15 secondi di voce chiara senza rumore di fondo.",
        "ar": "قم بتحميل أو تسجيل ما لا يقل عن 15 ثانية من الصوت الواضح بدون ضوضاء خلفية.",
        "ja": "背景雑音のない15秒以上の明瞭な声をアップロードまたは録音してください。",
        "zh": "上传或录制至少15秒清晰无背景噪音的语音。",
        "ru": "Загрузите или запишите не менее 15 секунд четкого голоса без фонового шума.",
        "ko": "배경 소음 없이 15초 이상의 깨끗한 목소리를 업로드하거나 녹음하세요.",
        "bg": "Качете или запишете поне 15 секунди ясен глас без фонов шум.",
        "nl": "Upload of neem minstens 15 seconden duidelijke stem op zonder achtergrondgeluid.",
        "he": "העלה או הקלט לפחות 15 שניות של קול ברור ללא רעשי רקע.",
        "hi": "कम से कम 15 सेकंड की स्पष्ट आवाज़ बिना पृष्ठभूमि शोर के अपलोड या रिकॉर्ड करें।",
        "el": "Ανεβάστε ή ηχογραφήστε τουλάχιστον 15 δευτερόλεπτα καθαρής φωνής χωρίς θόρυβο στο παρασκήνιο.",
        "hu": "Töltsön fel vagy rögzítsen legalább 15 másodperc tiszta hangot háttérzaj nélkül.",
        "pl": "Prześlij lub nagraj co najmniej 15 sekund czystego głosu bez szumów w tle.",
        "tl": "Mag-upload o mag-record ng hindi bababa sa 15 segundo ng malinaw na boses na walang ingay sa background.",
        "tr": "Arka plan gürültüsü olmadan en az 15 saniye net ses yükleyin veya kaydedin.",
        "vi": "Tải lên hoặc ghi âm ít nhất 15 giây giọng nói rõ ràng không có tiếng ồn nền.",
    },
    "avatarGuideVideo": {
        "en": "If you upload a video, make sure only one person appears and there is no background noise.",
        "es": "Si subes un vídeo, asegúrate de que solo aparezca una persona y sin ruido de fondo.",
        "es_419": "Si subes un video, asegúrate de que solo aparezca una persona y sin ruido de fondo.",
        "fr": "Si vous téléchargez une vidéo, assurez-vous qu'une seule personne apparaisse et qu'il n'y ait pas de bruit de fond.",
        "pt": "Se enviar um vídeo, certifique-se de que apenas uma pessoa apareça e não haja ruído de fundo.",
        "pt_BR": "Se enviar um vídeo, certifique-se de que apenas uma pessoa apareça e não haja ruído de fundo.",
        "de": "Wenn Sie ein Video hochladen, stellen Sie sicher, dass nur eine Person zu sehen ist und keine Hintergrundgeräusche vorhanden sind.",
        "it": "Se carichi un video, assicurati che compaia solo una persona e che non ci sia rumore di fondo.",
        "ar": "إذا قمت بتحميل مقطع فيديو، فتأكد من ظهور شخص واحد فقط وعدم وجود ضوضاء في الخلفية.",
        "ja": "動画をアップロードする場合は、1人だけが映っていて背景雑音がないことを確認してください。",
        "zh": "如果上传视频，请确保只出现一个人且没有背景噪音。",
        "ru": "Если вы загружаете видео, убедитесь, что в нем только один человек и нет фонового шума.",
        "ko": "동영상을 업로드할 경우 한 사람만 나오고 배경 소음이 없도록 하세요.",
        "bg": "Ако качвате видео, уверете се, че се вижда само един човек и няма фонов шум.",
        "nl": "Als je een video uploadt, zorg er dan voor dat er slechts één persoon te zien is en geen achtergrondgeluid.",
        "he": "אם אתה מעלה סרטון, ודא שמופיעה בו רק אדם אחד ואין רעשי רקע.",
        "hi": "यदि आप वीडियो अपलोड करते हैं, तो सुनिश्चित करें कि केवल एक व्यक्ति दिखाई दे और कोई पृष्ठभूमि शोर न हो।",
        "el": "Αν ανεβάσετε βίντεο, βεβαιωθείτε ότι εμφανίζεται μόνο ένα άτομο και δεν υπάρχει θόρυβος στο παρασκήνιο.",
        "hu": "Ha videót tölt fel, győződjön meg róla, hogy csak egy személy szerepel benne, és nincs háttérzaj.",
        "pl": "Jeśli przesyłasz wideo, upewnij się, że pojawia się tylko jedna osoba i nie ma szumów w tle.",
        "tl": "Kung mag-upload ka ng video, tiyakin na iisang tao lang ang makikita at walang ingay sa background.",
        "tr": "Video yüklüyorsanız yalnızca bir kişinin göründüğünden ve arka plan gürültüsü olmadığından emin olun.",
        "vi": "Nếu bạn tải lên video, hãy đảm bảo chỉ có một người xuất hiện và không có tiếng ồn nền.",
    },
    "audioPreviewInfo": {
        "en": "Use the player to review your audio. Trimming is not available in this version.",
        "es": "Utiliza el reproductor para revisar tu audio. El recorte no está disponible en esta versión.",
        "es_419": "Utiliza el reproductor para revisar tu audio. El recorte no está disponible en esta versión.",
        "fr": "Utilisez le lecteur pour écouter votre audio. La coupe n'est pas disponible dans cette version.",
        "pt": "Use o reprodutor para revisar seu áudio. O corte não está disponível nesta versão.",
        "pt_BR": "Use o reprodutor para revisar seu áudio. O corte não está disponível nesta versão.",
        "de": "Verwenden Sie den Player, um Ihr Audio zu überprüfen. Zuschneiden ist in dieser Version nicht verfügbar.",
        "it": "Usa il lettore per rivedere il tuo audio. Il taglio non è disponibile in questa versione.",
        "ar": "استخدم المشغل لمراجعة الصوت. القص غير متاح في هذا الإصدار.",
        "ja": "プレーヤーを使用してオーディオを確認してください。このバージョンではトリミングは利用できません。",
        "zh": "使用播放器查看您的音频。本版本不提供剪辑功能。",
        "ru": "Используйте плеер для прослушивания аудио. Обрезка в этой версии недоступна.",
        "ko": "플레이어를 사용하여 오디오를 검토하세요. 이 버전에서는 자르기가 지원되지 않습니다.",
        "bg": "Използвайте плейъра, за да прегледате аудиото си. Подрязването не е налично в тази версия.",
        "nl": "Gebruik de speler om je audio te beoordelen. Bijsnijden is niet beschikbaar in deze versie.",
        "he": "השתמש בנגן כדי לבדוק את האודיו שלך. החיתוך אינו זמין בגרסה זו.",
        "hi": "अपने ऑडियो की समीक्षा करने के लिए प्लेयर का उपयोग करें। इस संस्करण में ट्रिमिंग उपलब्ध नहीं है।",
        "el": "Χρησιμοποιήστε το πρόγραμμα αναπαραγωγής για να ελέγξετε τον ήχο σας. Η περικοπή δεν είναι διαθέσιμη σε αυτήν την έκδοση.",
        "hu": "Használja a lejátszót a hang ellenőrzéséhez. A vágás ebben a verzióban nem érhető el.",
        "pl": "Użyj odtwarzacza, aby odsłuchać swoje nagranie. Przycinanie nie jest dostępne w tej wersji.",
        "tl": "Gamitin ang player para suriin ang iyong audio. Ang pag-trim ay hindi available sa bersyong ito.",
        "tr": "Sesinizi incelemek için oynatıcıyı kullanın. Kırpma bu sürümde mevcut değildir.",
        "vi": "Sử dụng trình phát để xem lại âm thanh của bạn. Tính năng cắt không khả dụng trong phiên bản này.",
    },
    "audioTooShort": {
        "en": "The audio must be at least 15 seconds long.",
        "es": "El audio debe durar al menos 15 segundos.",
        "es_419": "El audio debe durar al menos 15 segundos.",
        "fr": "L'audio doit durer au moins 15 secondes.",
        "pt": "O áudio deve ter pelo menos 15 segundos.",
        "pt_BR": "O áudio deve ter pelo menos 15 segundos.",
        "de": "Das Audio muss mindestens 15 Sekunden lang sein.",
        "it": "L'audio deve durare almeno 15 secondi.",
        "ar": "يجب أن يكون طول الصوت 15 ثانية على الأقل.",
        "ja": "音声は少なくとも15秒である必要があります。",
        "zh": "音频长度必须至少为15秒。",
        "ru": "Аудио должно длиться не менее 15 секунд.",
        "ko": "오디오 길이는 최소 15초여야 합니다.",
        "bg": "Аудиото трябва да е с дължина поне 15 секунди.",
        "nl": "De audio moet minstens 15 seconden lang zijn.",
        "he": "האודיו חייב להיות לפחות 15 שניות.",
        "hi": "ऑडियो कम से कम 15 सेकंड का होना चाहिए।",
        "el": "Ο ήχος πρέπει να διαρκεί τουλάχιστον 15 δευτερόλεπτα.",
        "hu": "A hang legalább 15 másodperc hosszú legyen.",
        "pl": "Dźwięk musi trwać co najmniej 15 sekund.",
        "tl": "Ang audio ay dapat hindi bababa sa 15 segundo.",
        "tr": "Ses en az 15 saniye uzunluğunda olmalıdır.",
        "vi": "Âm thanh phải dài ít nhất 15 giây.",
    },
    "successUpload": {
        "en": "Files uploaded successfully!",
        "es": "¡Archivos subidos correctamente!",
        "es_419": "¡Archivos subidos correctamente!",
        "fr": "Fichiers téléchargés avec succès !",
        "pt": "Arquivos enviados com sucesso!",
        "pt_BR": "Arquivos enviados com sucesso!",
        "de": "Dateien erfolgreich hochgeladen!",
        "it": "File caricati con successo!",
        "ar": "تم رفع الملفات بنجاح!",
        "ja": "ファイルが正常にアップロードされました！",
        "zh": "文件上传成功！",
        "ru": "Файлы успешно загружены!",
        "ko": "파일이 성공적으로 업로드되었습니다!",
        "bg": "Файловете бяха качени успешно!",
        "nl": "Bestanden succesvol geüpload!",
        "he": "הקבצים הועלו בהצלחה!",
        "hi": "फ़ाइलें सफलतापूर्वक अपलोड हो गईं!",
        "el": "Τα αρχεία ανέβηκαν με επιτυχία!",
        "hu": "A fájlok sikeresen feltöltve!",
        "pl": "Pliki przesłane pomyślnie!",
        "tl": "Matagumpay na na-upload ang mga file!",
        "tr": "Dosyalar başarıyla yüklendi!",
        "vi": "Tệp đã được tải lên thành công!",
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
