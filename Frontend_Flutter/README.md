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

## UI & Screens

The application contains multiple UI screens including:

* Splash Screen
* Login Screen
* Create Account Screen
* Home Screen
* Chat List Screen
* Chat Screen
* Live Chat Screen
* Avatar Screen
* Settings Screen

---

# Technologies Used

## Framework

* Flutter

## Programming Language

* Dart

## State Management

* flutter_bloc ^8.1.6

## Networking

* dio ^5.7.0
* http ^1.2.1

## Real-time Communication

* signalr_netcore ^1.3.6

## Local Storage

* shared_preferences ^2.2.2

## 3D & Avatar Integration

* flutter_embed_unity ^1.3.1
* flutter_embed_unity_6000_0_android ^1.2.2
* o3d ^3.1.3

## Camera Integration

* camera ^0.12.0

## Fonts & UI

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

---

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

Configuration & Setup
Prerequisites

Flutter SDK ^3.11.0
Dart SDK ^3.11.0
Android Studio or VS Code
A running instance of the Ishara Backend API
