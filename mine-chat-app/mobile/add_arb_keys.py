import glob
import json
import os

# Carpeta donde están los archivos .arb
ARB_FOLDER = "lib/l10n"

# Traducciones para cada clave y cada idioma/variante
translations = {
    "welcome": {
        "en": "Welcome",
        "es": "Bienvenido",
        "es_419": "Bienvenido",
        "fr": "Bienvenue",
        "pt": "Bem-vindo",
        "pt_BR": "Bem-vindo",
        "de": "Willkommen",
        "it": "Benvenuto",
        "ar": "مرحبًا",
        "ja": "ようこそ",
        "zh": "欢迎",
        "ru": "Добро пожаловать",
        "ko": "환영합니다",
        "bg": "Добре дошли",
        "nl": "Welkom",
        "he": "ברוך הבא",
        "hi": "स्वागत है",
        "el": "Καλώς ήρθατε",
        "hu": "Üdvözöljük",
        "pl": "Witamy",
        "tl": "Maligayang pagdating",
        "tr": "Hoş geldiniz",
        "vi": "Chào mừng",
    },
    "slogan": {
        "en": "Recreate me, forever",
        "es": "Recréame, para siempre",
        "es_419": "Recréame, para siempre",
        "fr": "Recrée-moi, pour toujours",
        "pt": "Recrie-me, para sempre",
        "pt_BR": "Recrie-me, para sempre",
        "de": "Erschaffe mich neu, für immer",
        "it": "Ricreami, per sempre",
        "ar": "أعد إنشائي، إلى الأبد",
        "ja": "私を永遠に再現して",
        "zh": "永远重塑我",
        "ru": "Воссоздай меня навсегда",
        "ko": "영원히 나를 재창조해",
        "bg": "Пресъздай ме завинаги",
        "nl": "Recreëer mij, voor altijd",
        "he": "שחזר אותי, לנצח",
        "hi": "मुझे हमेशा के लिए फिर से बनाओ",
        "el": "Αναδημιούργησέ με, για πάντα",
        "hu": "Alkoss újra örökre",
        "pl": "Odtwórz mnie na zawsze",
        "tl": "Gawin muli ako, magpakailanman",
        "tr": "Beni sonsuza dek yeniden yarat",
        "vi": "Tái tạo tôi, mãi mãi",
    },
    "enterEmailToReset": {
        "en": "Enter your email to receive a password reset link.",
        "es": "Introduce tu correo electrónico para recibir un enlace de restablecimiento de contraseña.",
        "es_419": "Introduce tu correo electrónico para recibir un enlace de restablecimiento de contraseña.",
        "fr": "Entrez votre e-mail pour recevoir un lien de réinitialisation du mot de passe.",
        "pt": "Digite seu e-mail para receber um link de redefinição de senha.",
        "pt_BR": "Digite seu e-mail para receber um link de redefinição de senha.",
        "de": "Gib deine E-Mail ein, um einen Link zum Zurücksetzen des Passworts zu erhalten.",
        "it": "Inserisci la tua email per ricevere un link di reimpostazione della password.",
        "ar": "أدخل بريدك الإلكتروني لتلقي رابط إعادة تعيين كلمة المرور.",
        "ja": "パスワードリセットリンクを受け取るためにメールアドレスを入力してください。",
        "zh": "输入您的电子邮件以接收密码重置链接。",
        "ru": "Введите свою электронную почту, чтобы получить ссылку для сброса пароля.",
        "ko": "비밀번호 재설정 링크를 받으려면 이메일을 입력하세요.",
        "bg": "Въведете имейла си, за да получите връзка за нулиране на паролата.",
        "nl": "Voer je e-mailadres in om een link voor het opnieuw instellen van je wachtwoord te ontvangen.",
        "he": "הזן את האימייל שלך כדי לקבל קישור לאיפוס סיסמה.",
        "hi": "पासवर्ड रीसेट लिंक प्राप्त करने के लिए अपना ईमेल दर्ज करें।",
        "el": "Εισαγάγετε το email σας για να λάβετε σύνδεσμο επαναφοράς κωδικού πρόσβασης.",
        "hu": "Adja meg az e-mail címét a jelszó-visszaállítási link fogadásához.",
        "pl": "Wpisz swój adres e-mail, aby otrzymać link do resetowania hasła.",
        "tl": "Ilagay ang iyong email upang makatanggap ng link para i-reset ang password.",
        "tr": "Parola sıfırlama bağlantısı almak için e-postanızı girin.",
        "vi": "Nhập email của bạn để nhận liên kết đặt lại mật khẩu.",
    },
    "enterValidEmail": {
        "en": "Please enter a valid email.",
        "es": "Por favor introduce un correo electrónico válido.",
        "es_419": "Por favor introduce un correo electrónico válido.",
        "fr": "Veuillez entrer un e-mail valide.",
        "pt": "Por favor, insira um e-mail válido.",
        "pt_BR": "Por favor, insira um e-mail válido.",
        "de": "Bitte gib eine gültige E-Mail-Adresse ein.",
        "it": "Per favore inserisci un'email valida.",
        "ar": "يرجى إدخال بريد إلكتروني صالح.",
        "ja": "有効なメールアドレスを入力してください。",
        "zh": "请输入有效的电子邮件。",
        "ru": "Пожалуйста, введите действительный адрес электронной почты.",
        "ko": "유효한 이메일을 입력하세요.",
        "bg": "Моля, въведете валиден имейл.",
        "nl": "Voer alstublieft een geldig e-mailadres in.",
        "he": "אנא הזן אימייל חוקי.",
        "hi": "कृपया एक मान्य ईमेल दर्ज करें।",
        "el": "Παρακαλώ εισάγετε ένα έγκυρο email.",
        "hu": "Kérjük, adjon meg egy érvényes e-mail címet.",
        "pl": "Proszę wprowadzić prawidłowy adres e-mail.",
        "tl": "Pakilagay ang wastong email.",
        "tr": "Lütfen geçerli bir e-posta giriniz.",
        "vi": "Vui lòng nhập email hợp lệ.",
    },
    "completeAll": {
        "en": "All fields are required",
        "es": "Todos los campos son obligatorios",
        "es_419": "Todos los campos son obligatorios",
        "fr": "Tous les champs sont obligatoires",
        "pt": "Todos os campos são obrigatórios",
        "pt_BR": "Todos os campos são obrigatórios",
        "de": "Alle Felder sind erforderlich",
        "it": "Tutti i campi sono obbligatori",
        "ar": "جميع الحقول مطلوبة",
        "ja": "すべての項目は必須です",
        "zh": "所有字段均为必填",
        "ru": "Все поля обязательны для заполнения",
        "ko": "모든 필드는 필수입니다",
        "bg": "Всички полета са задължителни",
        "nl": "Alle velden zijn verplicht",
        "he": "כל השדות נדרשים",
        "hi": "सभी फ़ील्ड आवश्यक हैं",
        "el": "Όλα τα πεδία είναι υποχρεωτικά",
        "hu": "Minden mező kitöltése kötelező",
        "pl": "Wszystkie pola są wymagane",
        "tl": "Kinakailangan ang lahat ng patlang",
        "tr": "Tüm alanlar gereklidir",
        "vi": "Tất cả các trường là bắt buộc",
    },
    "badPassword": {
        "en": "Password must be at least 8 characters and require uppercase letters, special characters, and numeric characters for registration in the app.",
        "es": "La contraseña debe tener al menos 8 caracteres e incluir letras mayúsculas, caracteres especiales y números para el registro en la aplicación.",
        "es_419": "La contraseña debe tener al menos 8 caracteres e incluir letras mayúsculas, caracteres especiales y números para registrarse en la aplicación.",
        "fr": "Le mot de passe doit comporter au moins 8 caractères et inclure des lettres majuscules, des caractères spéciaux et des chiffres pour s'inscrire dans l'application.",
        "pt": "A senha deve ter pelo menos 8 caracteres e incluir letras maiúsculas, caracteres especiais e números para registro no aplicativo.",
        "pt_BR": "A senha deve ter pelo menos 8 caracteres e incluir letras maiúsculas, caracteres especiais e números para se registrar no aplicativo.",
        "de": "Das Passwort muss mindestens 8 Zeichen lang sein und Großbuchstaben, Sonderzeichen und Zahlen enthalten, um sich in der App zu registrieren.",
        "it": "La password deve contenere almeno 8 caratteri e includere lettere maiuscole, caratteri speciali e numeri per la registrazione nell'app.",
        "ar": "يجب أن تحتوي كلمة المرور على 8 أحرف على الأقل وتشمل أحرفًا كبيرة وأحرفًا خاصة وأرقامًا للتسجيل في التطبيق.",
        "ja": "パスワードは8文字以上で、大文字、特殊文字、数字を含める必要があります（アプリ登録用）。",
        "zh": "密码必须至少包含8个字符，并且包含大写字母、特殊字符和数字才能在应用中注册。",
        "ru": "Пароль должен содержать не менее 8 символов, включая заглавные буквы, специальные символы и цифры, для регистрации в приложении.",
        "ko": "비밀번호는 8자 이상이어야 하며, 대문자, 특수 문자, 숫자를 포함해야 앱에 등록할 수 있습니다.",
        "bg": "Паролата трябва да бъде поне 8 символа и да включва главни букви, специални символи и цифри за регистрация в приложението.",
        "nl": "Het wachtwoord moet minimaal 8 tekens bevatten en hoofdletters, speciale tekens en cijfers voor registratie in de app.",
        "he": "הסיסמה חייבת להכיל לפחות 8 תווים, כולל אותיות רישיות, תווים מיוחדים ומספרים, לצורך הרשמה לאפליקציה.",
        "hi": "पासवर्ड कम से कम 8 अक्षरों का होना चाहिए और इसमें बड़े अक्षर, विशेष अक्षर और अंक शामिल होने चाहिए ताकि ऐप में पंजीकरण किया जा सके।",
        "el": "Ο κωδικός πρόσβασης πρέπει να έχει τουλάχιστον 8 χαρακτήρες και να περιλαμβάνει κεφαλαία γράμματα, ειδικούς χαρακτήρες και αριθμούς για εγγραφή στην εφαρμογή.",
        "hu": "A jelszónak legalább 8 karakterből kell állnia, és tartalmaznia kell nagybetűt, speciális karaktert és számot az alkalmazásban való regisztrációhoz.",
        "pl": "Hasło musi mieć co najmniej 8 znaków i zawierać wielkie litery, znaki specjalne i cyfry, aby zarejestrować się w aplikacji.",
        "tl": "Ang password ay dapat may hindi bababa sa 8 character at may kasamang uppercase letters, special characters, at numeric characters para sa pagpaparehistro sa app.",
        "tr": "Parola en az 8 karakter olmalı ve uygulamaya kayıt için büyük harfler, özel karakterler ve rakamlar içermelidir.",
        "vi": "Mật khẩu phải có ít nhất 8 ký tự và bao gồm chữ hoa, ký tự đặc biệt và số để đăng ký trong ứng dụng.",
    },
    "haveUserAccount": {
        "en": "Already have an account? Sign In",
        "es": "¿Ya tienes una cuenta? Inicia sesión",
        "es_419": "¿Ya tienes una cuenta? Inicia sesión",
        "fr": "Vous avez déjà un compte ? Connectez-vous",
        "pt": "Já tem uma conta? Entrar",
        "pt_BR": "Já tem uma conta? Entrar",
        "de": "Hast du schon ein Konto? Anmelden",
        "it": "Hai già un account? Accedi",
        "ar": "هل لديك حساب بالفعل؟ تسجيل الدخول",
        "ja": "すでにアカウントをお持ちですか？ ログイン",
        "zh": "已经有账号？ 登录",
        "ru": "Уже есть аккаунт? Войти",
        "ko": "이미 계정이 있으신가요? 로그인",
        "bg": "Вече имате акаунт? Влезте",
        "nl": "Heb je al een account? Inloggen",
        "he": "כבר יש לך חשבון? התחבר",
        "hi": "क्या आपके पास पहले से एक खाता है? साइन इन करें",
        "el": "Έχετε ήδη λογαριασμό; Συνδεθείτε",
        "hu": "Már van fiókja? Jelentkezzen be",
        "pl": "Masz już konto? Zaloguj się",
        "tl": "May account ka na? Mag-sign in",
        "tr": "Zaten bir hesabınız var mı? Giriş yapın",
        "vi": "Đã có tài khoản? Đăng nhập",
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
