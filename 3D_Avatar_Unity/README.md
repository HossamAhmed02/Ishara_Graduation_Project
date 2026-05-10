## Overview

The Unity module in ISHARA APP is responsible for delivering an interactive 3D experience designed to translating sign language and communication assistance.

This module integrates animated 3D characters, gesture visualization, and real-time interaction to create a more engaging and accessible environment for users.

## Features

- 3D avatar animations for sign language gestures
- Real-time gesture visualization
- Smooth UI/UX integration with the mobile application

## Technologies Used

| Technology | Version | Purpose |
| --- | --- | --- |
| **Unity** | 6000.0.41f1 | Core 3D rendering engine |
| **C#** | — | Scripting (WordPassLogic , WordPlayer ,WordsData) |
| **Blender** | 3.6 LTS | Editing motion of Avatar & FBX export  |
| **DeepMotion** | — | Source of FBX motion capture animation files |
| **FBX Format** | — | Animation clip format for all 100 ASL signs |
| **flutter_embed_unity ** | 2.0.0 | Embedding Unity view inside Flutter (Android) |
| **Google Drive** | — | Hosting FBX animation files |
| **Animator Controller** | — | State machine بـ `signID` integer parameter |
| **ScriptableObject** (`WordsData`) | — | Dictionary of words and IDs |
| **JsonUtility** | — | Parse the JSON coming from Flutter |
|  |  |  |


## Project Structure

```bash
Assets/
│── Example/
│── FlutterEmbed/
│── Motion/
│── Resources/
│── Scenes/
│── Scripts/
│── Settings/
│── Textures/
│── TutorialInfo/
│
│── InputSystem_Actions.inputactions
│── Readme.asset
│── SignAnimator.controller
```
## Main Responsibilities

1. User Input (Flutter)
2. Gloss Conversion 
3. Flutter → Unity Communication
4. WordPassLogic.cs — Receiving & Parsing
5. WordsData.cs — Word to ID Lookup
6. WordPlayer.cs — Queue & Playback
7. Animator Controller — Sign Playback

## Setup Instructions

### Prerequisites

- Unity Hub
- Unity Version (6000.0.41f1)
    - [Unity 6000.0.41f1](https://unity.com/releases/editor/whats-new/6000.0.41f1)
- Android Build Support module installed in Unity Hub
- **flutter_embed_unity 2.0.0** package must be installed in the Unity project
    - ([flutter_embed_unity | Flutter package](https://pub.dev/packages/flutter_embed_unity))
- **Assets \ Packages \ ProjectSettings** from our GitHub

## Running the Project

1. Open Unity Hub
2. Select the project folder
3. if you want to test the project in unity add this function at (WordPassLogic) script. 
    
    ```python
    void Start()    {     
       string testJson = "{\"gloss\":\"hello how are you\"}";   
            ReceiveGloss(testJson); 
               }
    ```
    
4. Press `Play`
