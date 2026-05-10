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

##  Technical Stack
* **Architecture:** Dual-Stream LSTM for 3D landmark processing.
* **Accuracy:** Reached **66%** on complex ASL datasets.
* **Linguistic Refinement:** Integrated **SpaCy** and **Qwen LLM** for grammatical sentence construction.

---

## Setup & Execution Guide

### 1. Linking Models
After downloading the files from Drive, your local directory must look like this to match the code paths:

```text
/MachineLearning_Models
├── main.py
├── requirements.txt
├── mapping/
│   └── sign_to_prediction_index_map.json
├── LSTM_weights/           <-- (Place .pt file here)
└── model_qwen_files/       <-- (Place Qwen files here)


 ### 2. Installation
Bash
pip install -r requirements.txt
python -m spacy download en_core_web_sm


### 3. Local Inference
Bash
uvicorn main:app --host 0.0.0.0 --port 8000


API Endpoints
POST /translate: Receives video/landmarks and returns the predicted sentence.

GET /docs: Interactive Swagger documentation.



GET /docs: Interactive Swagger documentation.
