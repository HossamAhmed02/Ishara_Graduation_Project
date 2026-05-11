# Ishara_Graduation_Project
Our graduation project which help deaf people to communicate with normal people
---
# Ishara Project - Backend API

This is the backend service for the "Ishara" project, built using **Clean Architecture** to ensure scalability, maintainability, and a clear separation of concerns.

## Tech Stack & Versions
This project is built using the latest Microsoft technologies:
* **Framework:** ASP.NET Core Web API `v8.0`
* **ORM:** Entity Framework Core `v8.0.0`
* **Database:** SQL Server
* **Authentication:** * JWT Bearer Token `v8.0.0`
  * Google Authentication `v8.0.0`
* **Real-time Communication:** SignalR (for instant messaging)
* **Machine Learning Integration:** `HttpClient` (to communicate with the project's AI engine)
* **API Documentation:** Swashbuckle.AspNetCore (Swagger) `v6.6.2`

---

## Configuration & Setup
For privacy and security reasons, the original `appsettings.json` file is not included in this repository. To run the project locally, please follow these steps:

1. Create a copy of the `appsettings.Example.json` file and rename it to `appsettings.json`.
2. Open the new file and fill in your specific credentials:
   * **`ConnectionStrings:IsharaDB`**: Provide your SQL Server connection string.
   * **`Jwt:Key`**: Provide a strong secret key (minimum of 32 characters).
   * **`Authentication:Google`**: (Optional) Add your Google `ClientId` and `ClientSecret`.
   * **`EmailSettings`**: Provide your email and App Password to enable OTP email verification.
   * **`MLSettings:ModelPath`**: The URL of the AI translation service.

> ** Note for Local ML Execution:**
> If the Machine Learning engineer is running the translation server locally on their machine, make sure to update the model URL in `appsettings.json` to match the local port (usually, it looks like this):
> `"ModelPath": "http://127.0.0.1:8000/"`

---

## Getting Started
To run the server on your local machine:

1. Open a Terminal/Command Prompt inside the `Ishara.Api` folder.
2. Ensure you have the **.NET 8 SDK** installed on your machine.
3. Update and build the database (make sure your Connection String is already set in `appsettings.json`):

---
#  Ishara AI Engine

##  Project Overview
This folder contains the core intelligence of the **Ishara** project. It includes the deep learning architectures for sign language recognition and the Natural Language Generation (NLG) system.

---

##  Large Files Access (Google Drive)
Due to size limits, the heavy model files must be downloaded from Google Drive and placed in their respective folders as shown below:

 **[Download Models & Weights from Google Drive](https://drive.google.com/drive/folders/1gA8WJQbAjMX5PAX0Fa-nUOYYWrGePYdl?usp=drive_link)**

###  Required Folders from Drive:
* **LSTM_weights/** — Contains the trained LSTM weights (`.pt` file).
* **model_qwen_files/** — Contains the Qwen NLP model files.

---
### Technical Stack
* **Deep Learning Framework:** `PyTorch` (Used for the Dual-Stream LSTM architecture).
* **Computer Vision:** `MediaPipe Holistic` (For 3D landmark extraction: Face, Hands, and Pose).
* **NLP & Language Modeling:** * `Qwen LLM`: For natural sentence generation.
    * `SpaCy` & `contextualSpellCheck`: For grammatical refinement[cite: 2].
* **Backend API:** `FastAPI` & `Uvicorn`[cite: 2].
* **Data Processing:** `NumPy` & `Pandas`[cite: 2]
---

## Setup & Execution Guide

### 1. Linking Models
After downloading the files from Drive, your local directory must look like this to match the code paths:

```text
/MachineLearning_Models
├── main.py
├── requirements.txt
├── models/
│   └── model_utils.py                    <-- [Training logic & Model helpers]
├── mapping/
│   └── sign_to_prediction_index_map.json
├── LSTM_weights/                          <-- [Place .pt file here]
│   └── best_asl_model_avg_66_modified.pt  <-- [Download from Drive]
└── model_qwen_files/                      <-- [Place Qwen files here]
    ├── config.json                        <-- [Download from Drive]
    ├── model.safetensors                  <-- [Download from Drive]
    ├── tokenizer.json                     <-- [Download from Drive]
    └── generation_config.json             <-- [Download from Drive]
```

2.Installation
```bash
pip install -r requirements.txt
python -m spacy download en_core_web_sm
```




3. Local Inference
```Bash
uvicorn main:app --host 0.0.0.0 --port 8000
```


API Endpoints :

POST /translate: Receives video/landmarks and returns the predicted sentence.

GET /docs: Interactive Swagger documentation.

   ```bash
   dotnet ef database update --project ../Ishara.Persistence

---

## Overview

The Unity module in ISHARA APP is responsible for delivering an interactive 3D experience designed to translating sign language and communication assistance.

This module integrates animated 3D characters, gesture visualization, and real-time interaction to create a more engaging and accessible environment for users.

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
- **get Assets \ Packages \ ProjectSettings** from our GitHub

## Running the Project

1. Open Unity Hub
2. Select the project folder
3. if you want to test the project in unity add this function at (WordPassLogic) script. 
    
    ```python
    void Start()    {     
       string testJson = "{\"gloss\":\"heelo\"}";   
            ReceiveGloss(testJson); 
               }
    ```
    
4. Press `Play`

---

