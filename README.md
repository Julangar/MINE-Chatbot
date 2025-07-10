# 🤖 MINE: Chatbot Hiperrealista con Avatar Personalizado

MINE es una aplicación móvil que permite a los usuarios crear un **compañero digital hiperrealista**, basado en su propia imagen, voz y estilo comunicativo. Integra tecnologías avanzadas de inteligencia artificial para ofrecer una experiencia de conversación fluida, personalizada y visualmente inmersiva.

## 🚀 Características principales

- 👤 Avatar visual generado a partir de fotos reales
- 🔊 Voz clonada con entonación natural (ElevenLabs)
- 🧠 Personalidad configurable mediante cuestionario
- 🗣️ Chat en tiempo real con memoria contextual (OpenAI GPT)
- 🎬 Respuestas animadas con video (D-ID/HeyGen)
- ☁️ Sincronización en la nube con Firebase

## 🛠️ Tecnologías Utilizadas

- **Frontend:** Flutter (Dart)
- **Backend:** Node.js (Express)
- **Servicios Cloud:** Firebase (Auth, Firestore, Storage)
- **IA / APIs:**
  - OpenAI GPT (conversación)
  - ElevenLabs (voz)
  - D-ID o HeyGen (avatar animado)

## 🧰 Herramientas necesarias para modificar el proyecto

Para realizar cambios y contribuir al desarrollo de MINE-Chatbot, necesitas instalar y configurar las siguientes herramientas:

- **Git:** Control de versiones y gestión de repositorios.  
  [Descargar Git](https://git-scm.com/downloads)

- **Visual Studio Code:** Editor de código recomendado para editar archivos, depurar y gestionar el proyecto.  
  [Descargar VS Code](https://code.visualstudio.com/)

- **Flutter SDK:** Framework para desarrollar la aplicación móvil.  
  [Instalación Flutter](https://docs.flutter.dev/get-started/install)

- **Node.js y npm:** Entorno de ejecución para el backend y gestor de paquetes.  
  [Descargar Node.js](https://nodejs.org/)

- **Firebase CLI:** Herramienta para administrar servicios de Firebase desde la terminal.  
  Instala con:  
  ```
  npm install -g firebase-tools
  ```

- **Acceso a APIs externas:**  
  - OpenAI (GPT): Necesitas una clave de API.
  - ElevenLabs: Necesitas una clave de API.
  - D-ID o HeyGen: Necesitas una clave de API.

**Recomendación:** Consulta la documentación oficial de cada herramienta para detalles de instalación y configuración según tu sistema operativo.

## 📁 Estructura del Proyecto
root/
- backend/        # API Node.js (Express)
    - index.js
    - package.json
    - config/
        - firebase.js
        - index.js
        - serviceAccountKey.json
    - controllers/
        - avatarController.js
        - chatController.js
        - healthController.js
        - userController.js
        - voiceController.js
    - middlewares/
        - errorHandler.js
    - routes/
        - avatar.js
        - chat.js
        - health.js
        - user.js
        - voice.js
    - services/
        - didService.js
        - elevenlabsService.js
        - openaiService.js
    - utils/
        - logger.js
    - test-did.js
    - test-elevenlabs.js
    - test-firebase.js
    - test-openai.js
- mobile/         # App Flutter
    - main.dart
- docs/           # Documentación técnica y de usuario
    - curl test endpoints.txt
    - Plan Paso a Paso.docx
    - Propuesta de Desarrollo.docx
    - Readme_plan.md

## 📅 Plan de Desarrollo (40 días)

Consulta el documento `docs/Plan Paso a Paso.pdf` para ver el cronograma completo por días y entregables.

## 🧪 Estado del Proyecto

| Día | Actividad                                                                                 | Estado      |
|-----|-------------------------------------------------------------------------------------------|-------------|
| 01  | Instalación de herramientas, Flutter, Git, VSCode, estructura de carpetas y GitHub       | ✅ Completado |
| 02  | Configuración de APIs (OpenAI, ElevenLabs, D-ID/HeyGen), Firebase                        | ✅ Completado |
| 03  | Inicialización de proyecto backend con Express, estructura de carpetas y .env            | ✅ Completado |
| 04  | Conexión de backend con Firebase y servicios IA                                          | ✅ Completado |
| 05  | Diseño de wireframes, inicio de proyecto Flutter y estructura base                       |  |
## 🔐 Licencia

Este proyecto está licenciado bajo la **APACHE License**. Consulta el archivo [LICENSE](LICENSE) para más detalles.

## 🙌 Contribuciones

¡Las contribuciones son bienvenidas! Por favor abre un _issue_ o _pull request_ si quieres colaborar o proponer mejoras.

## 📬 Contacto

Proyecto desarrollado por Su Gestión SAS.  

Equipo de trabajo:
Julian Andres Garcia Guerrero
📧 Correo: jagarciaguer@msn.com


