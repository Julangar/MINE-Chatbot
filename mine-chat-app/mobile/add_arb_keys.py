import glob
import json
import os

# Carpeta donde están los archivos .arb
ARB_FOLDER = "lib/l10n"

# Traducciones para cada clave y cada idioma/variante
translations = {
    "cameraPermissionDenied": {
        "en": "Camera permission is required to take photos or record videos.",
        "es": "Se requiere permiso de la cámara para tomar fotos o grabar videos.",
        "es_419": "Se requiere permiso de la cámara para tomar fotos o grabar videos.",
        "fr": "L'autorisation de la caméra est requise pour prendre des photos ou enregistrer des vidéos.",
        "pt": "A permissão da câmera é necessária para tirar fotos ou gravar vídeos.",
        "pt_BR": "A permissão da câmera é necessária para tirar fotos ou gravar vídeos.",
        "de": "Die Kameraberechtigung ist erforderlich, um Fotos zu machen oder Videos aufzunehmen.",
        "it": "È necessario il permesso della fotocamera per scattare foto o registrare video.",
        "ar": "مطلوب إذن الكاميرا لالتقاط الصور أو تسجيل مقاطع الفيديو.",
        "ja": "写真を撮ったりビデオを録画するにはカメラの許可が必要です。",
        "zh": "需要相机权限才能拍照或录制视频。",
        "ru": "Для съемки фото или записи видео требуется разрешение на использование камеры.",
        "ko": "사진을 찍거나 동영상을 녹화하려면 카메라 권한이 필요합니다.",
        "bg": "Необходимо е разрешение за камера, за да правите снимки или да записвате видеоклипове.",
        "nl": "Cameratoestemming is vereist om foto's te maken of video's op te nemen.",
        "he": "נדרשת הרשאת מצלמה כדי לצלם תמונות או להקליט סרטונים.",
        "hi": "फोटो लेने या वीडियो रिकॉर्ड करने के लिए कैमरा अनुमति आवश्यक है।",
        "el": "Απαιτείται άδεια κάμερας για τη λήψη φωτογραφιών ή την εγγραφή βίντεο.",
        "hu": "A fényképek készítéséhez vagy videók rögzítéséhez kamerajogosultság szükséges.",
        "pl": "Wymagane jest zezwolenie na korzystanie z aparatu, aby robić zdjęcia lub nagrywać filmy.",
        "tl": "Kinakailangan ang pahintulot sa camera upang kumuha ng mga larawan o mag-record ng mga video.",
        "tr": "Fotoğraf çekmek veya video kaydetmek için kamera izni gereklidir.",
        "vi": "Cần quyền truy cập máy ảnh để chụp ảnh hoặc quay video.",
    },
    "storagePermissionDenied": {
        "en": "Storage permission is required to pick files from your gallery.",
        "es": "Se requiere permiso de almacenamiento para seleccionar archivos de tu galería.",
        "es_419": "Se requiere permiso de almacenamiento para seleccionar archivos de tu galería.",
        "fr": "L'autorisation de stockage est requise pour sélectionner des fichiers depuis votre galerie.",
        "pt": "A permissão de armazenamento é necessária para selecionar arquivos da sua galeria.",
        "pt_BR": "A permissão de armazenamento é necessária para selecionar arquivos da sua galeria.",
        "de": "Die Speicherberechtigung ist erforderlich, um Dateien aus Ihrer Galerie auszuwählen.",
        "it": "È necessario il permesso di archiviazione per selezionare file dalla galleria.",
        "ar": "مطلوب إذن التخزين لاختيار الملفات من معرض الصور الخاص بك.",
        "ja": "ギャラリーからファイルを選択するにはストレージの許可が必要です。",
        "zh": "需要存储权限才能从图库中选择文件。",
        "ru": "Для выбора файлов из галереи требуется разрешение на доступ к хранилищу.",
        "ko": "갤러리에서 파일을 선택하려면 저장소 권한이 필요합니다.",
        "bg": "Необходимо е разрешение за съхранение, за да изберете файлове от галерията си.",
        "nl": "Opslagtoestemming is vereist om bestanden uit uw galerij te selecteren.",
        "he": "נדרשת הרשאת אחסון כדי לבחור קבצים מהגלריה שלך.",
        "hi": "गैलरी से फ़ाइलें चुनने के लिए स्टोरेज अनुमति आवश्यक है।",
        "el": "Απαιτείται άδεια αποθήκευσης για την επιλογή αρχείων από τη συλλογή σας.",
        "hu": "A galériából való fájlkiválasztáshoz tárhelyhozzáférési engedély szükséges.",
        "pl": "Wymagane jest zezwolenie na dostęp do pamięci, aby wybrać pliki z galerii.",
        "tl": "Kinakailangan ang pahintulot sa storage upang pumili ng mga file mula sa iyong gallery.",
        "tr": "Galerinizden dosya seçmek için depolama izni gereklidir.",
        "vi": "Cần quyền lưu trữ để chọn tệp từ thư viện của bạn.",
    },
    "microphonePermissionDenied": {
        "en": "Microphone permission is required to record audio or video.",
        "es": "Se requiere permiso del micrófono para grabar audio o video.",
        "es_419": "Se requiere permiso del micrófono para grabar audio o video.",
        "fr": "L'autorisation du microphone est requise pour enregistrer de l'audio ou de la vidéo.",
        "pt": "A permissão do microfone é necessária para gravar áudio ou vídeo.",
        "pt_BR": "A permissão do microfone é necessária para gravar áudio ou vídeo.",
        "de": "Die Mikrofonberechtigung ist erforderlich, um Audio oder Video aufzunehmen.",
        "it": "È necessario il permesso del microfono per registrare audio o video.",
        "ar": "مطلوب إذن الميكروفون لتسجيل الصوت أو الفيديو.",
        "ja": "音声やビデオを録音するにはマイクの許可が必要です。",
        "zh": "需要麦克风权限才能录制音频或视频。",
        "ru": "Для записи аудио или видео требуется разрешение на использование микрофона.",
        "ko": "오디오 또는 비디오를 녹음하려면 마이크 권한이 필요합니다.",
        "bg": "Необходимо е разрешение за микрофон, за да записвате аудио или видео.",
        "nl": "Microfoontoestemming is vereist om audio of video op te nemen.",
        "he": "נדרשת הרשאת מיקרופון כדי להקליט אודיו או וידאו.",
        "hi": "ऑडियो या वीडियो रिकॉर्ड करने के लिए माइक्रोफ़ोन अनुमति आवश्यक है।",
        "el": "Απαιτείται άδεια μικροφώνου για την εγγραφή ήχου ή βίντεο.",
        "hu": "Hang vagy videó rögzítéséhez mikrofonengedély szükséges.",
        "pl": "Wymagane jest zezwolenie na korzystanie z mikrofonu, aby nagrywać dźwięk lub wideo.",
        "tl": "Kinakailangan ang pahintulot sa mikropono upang mag-record ng audio o video.",
        "tr": "Ses veya video kaydetmek için mikrofon izni gereklidir.",
        "vi": "Cần quyền truy cập micro để ghi âm hoặc quay video.",
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
