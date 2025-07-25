
# 🧪 Documentación de Pruebas Backend – MINE Chat App

Este documento describe cómo probar los principales flujos del backend de la aplicación MINE utilizando Postman.

---

## ✅ Requisitos previos

- Node.js y el backend corriendo en `http://localhost:3000`
- Firebase configurado (Firestore + Storage + Auth)
- API Keys válidas para:
  - OpenAI
  - ElevenLabs
  - D-ID
- Postman instalado ([descargar](https://www.postman.com/downloads/))

---

## 📦 Archivo de pruebas

Importa esta colección en Postman:

- `MINE_Backend_Tests.postman_collection.json`

Contiene pruebas para:

1. Crear avatar
2. Clonar voz
3. Enviar mensaje (OpenAI)
4. Generar video del avatar
5. Obtener perfil completo

---

## 📋 Variables de ejemplo

```json
{
  "userId": "test_user",
  "avatarType": "love_avatar",
  "avatarName": "Avatar de prueba"
}
```

---

## 🔍 Detalle de endpoints

### 1. Crear Avatar

**POST** `/api/avatars/create`

```json
{
  "userId": "test_user",
  "type": "love_avatar",
  "avatarName": "Avatar de prueba",
  "personality": {
    "traits": {
      "extroversion": 0.8,
      "agreeableness": 0.7,
      "conscientiousness": 0.6
    },
    "interests": ["tecnología", "música"],
    "speakingStyle": "casual",
    "commonPhrases": ["¡Claro que sí!", "Vamos allá"]
  }
}
```

---

### 2. Clonar Voz

**POST** `/api/voice/clone`

```json
{
  "userId": "test_user",
  "avatarType": "love_avatar",
  "audioUrl": "https://storage.googleapis.com/mine-app-test/avatars/test_user/audio.mp3"
}
```

---

### 3. Enviar mensaje (chat con IA)

**POST** `/api/chat/send-message`

```json
{
  "userId": "test_user",
  "avatarType": "love_avatar",
  "message": "¿Cuál es tu hobby favorito?"
}
```

---

### 4. Generar video con D-ID

**POST** `/api/avatar/generate-video`

```json
{
  "userId": "test_user",
  "avatarType": "love_avatar"
}
```

---

### 5. Obtener Perfil

**GET** `/api/avatar-profile/test_user/love_avatar`

---

## ✅ Recomendaciones

- Usa Firebase Storage para subir previamente:
  - Imagen facial clara
  - Audio `.mp3` con al menos 30 segundos
- Revisa Firestore para ver si los datos se escriben correctamente
- Puedes usar Firebase Emulator para pruebas locales si lo deseas

---

## 🧼 Limpieza de datos

Puedes eliminar perfiles con:

**DELETE** `/api/avatar-profile/test_user/love_avatar`

---

## ✨ Resultado Esperado

Al completar las pruebas deberías ver:

- JSON con `success: true` o `response` del avatar
- Archivos creados en Storage
- Documentos visibles en Firestore

---

## 📬 Soporte

Desarrollado por: Julián Andrés García Guerrero  
Correo: jagarciaguer@msn.com
