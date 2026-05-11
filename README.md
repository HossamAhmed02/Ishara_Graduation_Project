# Ishara App - Sign Language Translator

Project Overview
ISHARA is a comprehensive mobile application designed to bridge the communication gap between deaf and normal individuals. The system integrates a **Flutter** frontend, a **Unity 3D Avatar** embedded directly into the app, a robust **.NET 8 Backend API** using Clean Architecture, and a deep learning **AI Engine** (PyTorch/FastAPI) for accurate sign language recognition and natural language generation. Users can register as either a "Deaf" or "Normal" user to access tailored real-time communication features.

---
Prerequisites
* A computer running Windows or macOS
* Android Studio installed and configured
* Flutter SDK (^3.11.0) and Dart SDK (^3.11.0)
* .NET 8 SDK and SQL Server
* Python 3.x
* Unity Hub with Unity version 6000.0.41f1 (Android Build Support installed)
* An Android mobile device (Developer Mode & USB Debugging enabled)

---
Setup Instructions

1. Run the Backend API (.NET 8)
Navigate to the `Backend_DotNet/Ishara.Api` directory. Rename `appsettings.Example.json` to `appsettings.json` and configure your SQL Server connection string and JWT keys.
Run the following commands to apply migrations and start the server:
```bash
  dotnet ef database update --project ../Ishara.Persistence
  dotnet run
Start the AI Engine (FastAPI)
Download the required heavy model files from the Google Drive link (provided below).
Place the .pt file in LSTM_weights/ and the NLP files in model_qwen_files/.
Open a terminal inside the MachineLearning_Models folder and run:

Bash
  pip install -r requirements.txt
  python -m spacy download en_core_web_sm
  uvicorn main:app --host 0.0.0.0 --port 8000
Run the Mobile App & 3D Avatar (Flutter & Unity)
The Unity 3D Avatar is fully integrated into the Flutter app via flutter_embed_unity.
Connect your Android device via USB, open a terminal in the Frontend_Flutter directory, and run:

Bash
  flutter pub get
  flutter run
(Note: To test the Unity module standalone, open the 3D_Avatar_Unity folder in Unity Hub and press Play).

Troubleshooting

Database Connection Error: Verify your SQL Server instance is running and the connection string in appsettings.json is correct.

AI Model Not Found: Ensure the downloaded models from Drive are placed in their exact respective folders before starting the Uvicorn server.

Flutter/Unity Build Fails: Ensure your Android SDK paths are correct in Android Studio and that the flutter_embed_unity package is properly fetched.

Device not detected: Reconnect the USB cable and verify Developer Mode and USB Debugging are active.

Links and Resources

AI Models & Weights (Google Drive): [https://drive.google.com/drive/folders/1gA8WJQbAjMX5PAX0Fa-nUOYYWrGePYdl?usp=drive_link]

App APK (Download & Test): [https://drive.google.com/file/d/1YC2bFSioGLBTUhhEOziVkcIlIrBwRRCA/view]

Contact
For help or inquiries, contact:
Hossam Ahmed — [hossam.a7med02@gmail.com]
