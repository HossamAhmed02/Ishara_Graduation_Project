# ISHARA Project - Flutter Frontend

ISHARA is a mobile application designed to support communication for deaf and hard-of-hearing users through sign language translation using an interactive avatar and real-time features.

This repository contains the **Flutter Frontend** implementation of the ISHARA project.

---

# Frontend Development - ISHARA Project

The frontend application was developed using **Flutter** and **Dart** to provide a modern, responsive, and cross-platform mobile experience.

The application includes:

* Authentication screens
* Real-time messaging system
* Avatar interaction screens
* Sign language visualization
* Unity integration for avatar rendering
* 3D model rendering using O3D
* Responsive UI/UX implementation
* Custom typography system using Fraunces font

---

# Project Structure

ishara/
├── assets/
│   ├── images/
│   │   ├── videoCamera.png
│   │   ├── group.png
│   │   ├── messaging.png
│   │   ├── question.png
│   │   ├── avatar.jpeg
│   │   └── avatar2.png
│   ├── models/
│   │   └── all_signs.glb          
│   └── fonts/
│       ├── Fraunces_72pt-Regular.ttf
│       ├── Fraunces_72pt-Bold.ttf
│       └── Fraunces_72pt-Light.ttf
│
└── lib/
    ├── main.dart
    │
    ├── core/
    │   ├── constants/
    │   │   ├── api_constants.dart       
    │   │   └── constants.dart           
    │   ├── network/
    │   │   └── api_client.dart          
    │   ├── services/
    │   │   └── token_service.dart       
    │   ├── theme/
    │   │   └── theme.dart               
    │   └── widgets/
    │       ├── custom_textfield.dart    
    │       ├── help_button.dart         
    │       └── primary_button.dart      
    │
    └── features/
        │
        ├── auth/
        │   ├── cubit/
        │   │   ├── login_cubit.dart
        │   │   ├── login_state.dart
        │   │   ├── register_cubit.dart
        │   │   ├── register_state.dart
        │   │   ├── forgot_password_cubit.dart
        │   │   ├── forgot_password_state.dart
        │   │   ├── reset_password_cubit.dart
        │   │   ├── reset_password_state.dart
        │   │   ├── verify_otp_cubit.dart
        │   │   ├── verify_otp_state.dart
        │   │   ├── verify_reset_otp_cubit.dart
        │   │   └── verify_reset_otp_state.dart
        │   ├── data/
        │   │   ├── models/
        │   │   │   ├── login_request.dart
        │   │   │   ├── login_response.dart
        │   │   │   ├── register_request.dart
        │   │   │   ├── register_response.dart
        │   │   │   ├── forgot_password_request.dart
        │   │   │   ├── forgot_password_response.dart
        │   │   │   ├── reset_password_request.dart
        │   │   │   ├── reset_password_response.dart
        │   │   │   ├── verify_otp_request.dart
        │   │   │   ├── verify_otp_response.dart
        │   │   │   ├── verify_reset_otp_request.dart
        │   │   │   ├── verify_reset_otp_response.dart
        │   │   │   ├── refresh_token_request.dart
        │   │   │   └── refresh_token_response.dart
        │   │   └── repositories/
        │   │       └── auth_repository.dart   
        │   └── pages/
        │       ├── login.dart                 
        │       ├── create_account.dart        
        │       ├── forgot_password.dart       
        │       ├── otp_for_signup.dart        
        │       ├── otp_screen.dart            
        │       ├── reset_password.dart        
        │       └── reset_successful.dart      
        │
        ├── home/
        │   ├── cubit/
        │   │   ├── profile_cubit.dart
        │   │   └── profile_state.dart
        │   ├── models/
        │   │   └── profile_models.dart
        │   └── pages/
        │       ├── splash_screen.dart        
        │       ├── home.dart                  
        │       ├── starting_chat.dart         
        │       └── settings.dart              
        │
        ├── avatar/
        │   ├── cubit/
        │   │   ├── avatar_cubit.dart
        │   │   └── avatar_state.dart
        │   ├── services/
        │   │   └── api_service.dart          
        │   └── pages/
        │       └── avatar_screen.dart         
        │
        ├── live_chat/
        │   ├── cubit/
        │   │   ├── translation_cubit.dart
        │   │   └── translation_state.dart
        │   └── pages/
        │       └── live_chat.dart           
        │
        └── messaging/
            ├── cubit/
            │   ├── chat_cubit.dart
            │   ├── chat_list_cubit.dart
            │   ├── contacts_cubit.dart
            │   ├── contacts_state.dart
            │   ├── search_contacts_cubit.dart
            │   └── search_contacts_state.dart
            ├── data/
            │   ├── models/
            │   │   ├── contact_model.dart
            │   │   ├── message_model.dart
            │   │   └── user_model.dart
            │   ├── repositories/
            │   │   └── contacts_repository.dart
            │   └── services/
            │       ├── messages_api_service.dart  
            │       └── signalr_service.dart       
            └── pages/
                ├── chat_list_screen.dart           
                └── chat_screen.dart                

---
## Configuration & Setup
Prerequisites

* Flutter SDK ^3.11.0
* Dart SDK ^3.11.0
* Android Studio or VS Code
* A running instance of the Ishara Backend API
---
# Technologies Used
* Flutter
* Dart
* flutter_bloc ^8.1.6
* signalr_netcore ^1.3.6
* shared_preferences ^2.2.2
* flutter_embed_unity ^1.3.1
* flutter_embed_unity_6000_0_android ^1.2.2
* o3d ^3.1.3
* camera ^0.12.0
* google_fonts ^8.0.2

---

# Packages & Versions

```yaml
dependencies:
  flutter:
    sdk: flutter

  cupertino_icons: ^1.0.8
  google_fonts: ^8.0.2
  camera: ^0.12.0
  dio: ^5.7.0
  flutter_bloc: ^8.1.6
  equatable: ^2.0.5
  shared_preferences: ^2.2.2
  flutter_embed_unity: ^1.3.1
  flutter_embed_unity_6000_0_android: ^1.2.2
  http: ^1.2.1
  signalr_netcore: ^1.3.6
  o3d: ^3.1.3

dev_dependencies:
  flutter_test:
    sdk: flutter

  flutter_lints: ^6.0.0
```

# Technical Features

## Authentication System

Implemented authentication UI including:

* Login
* Create Account
* Remember Me functionality
* Password visibility toggle
* Responsive form validation UI

---

## Real-Time Chat System

Implemented a WhatsApp-like real-time messaging experience using:

* SignalR
* Dynamic chat bubbles
* Chat list screen
* Real-time message updates
* User-based conversations

---

## Avatar Integration

The project integrates sign language avatars using:

### Unity Integration

Used:

```text
flutter_embed_unity
flutter_embed_unity_6000_0_android
```

To embed Unity scenes inside Flutter screens.

### O3D Integration

Used:

```text
o3d
```

To render and display 3D avatar models directly inside Flutter UI.

---

## Camera Features

Implemented camera functionality using:

```text
camera ^0.12.0
```

Features include:

* Front/back camera switching
* Live camera preview
* Camera integration inside live chat screens

---

## Typography System

Created a custom typography system using:

* Fraunces Font
* Google Fonts

Applied selectively across:

* Titles
* Headers
* Branding text
* Panel labels

---

## Responsive Design

The UI was designed to work across multiple mobile screen sizes using:

* MediaQuery
* Flexible / Expanded widgets
* Responsive spacing techniques
