# Sentence To Gloss API

This API converts English sentences into ASL gloss representation using NLP techniques.

## Technologies
- Python
- spaCy
- FastAPI

## Features
- Pronoun mapping
- Question detection
- Negation handling
- Time-word prioritization
- ASL gloss ordering


## Hosted API
https://malakrabie-gloss-api.hf.space/convert

## Example Input

```json
{
  "sentence": "I will go tomorrow"
}
```

## Example Output

```json
{
  "gloss": [
    "TOMORROW",
    "ME",
    "GO"
  ]
}
```
