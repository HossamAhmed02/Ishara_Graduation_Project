import spacy

# =========================
# Load spaCy model safely
# =========================
try:
    nlp = spacy.load("en_core_web_sm")
except OSError:
    print("Model 'en_core_web_sm' not found.")
    print("Run this command first:")
    print("python -m spacy download en_core_web_sm")
    exit()

# =========================
# Pronoun mapping
# =========================
PRONOUN_MAP = {
    "i": "ME",
    "me": "ME",
    "my": "MY",
    "myself": "ME",

    "you": "YOU",
    "your": "YOUR",
    "yourself": "YOU",
    "yourselves": "YOU",

    "he": "HE",
    "him": "HIM",
    "his": "HIS",
    "himself": "HE",

    "she": "SHE",
    "her": "HER",
    "hers": "HERS",
    "herself": "SHE",

    "they": "THEY",
    "them": "THEM",
    "their": "THEIR",
    "themselves": "THEY",

    "we": "WE",
    "us": "US",
    "our": "OUR",
    "ourselves": "WE",

    "it": "IT",
    "its": "ITS"
}

# =========================
# Words to remove
# =========================
REMOVE_LEMMAS = {
    "be", "have", "do",
    "can", "could", "will", "would",
    "shall", "should", "may", "might", "must"
}

# FIX 1+2+3: added "that", prepositions, and "every"
REMOVE_TOKENS = {
    "a", "an", "the",
    "that",                                      # FIX 1: demonstrative "that"
    "for", "with", "as", "of",                  # FIX 2: common prepositions
    "in", "on", "at", "by", "about", "from",    # FIX 2: more prepositions
    "every",                                     # FIX 3: "every day" → keep only DAY
}

# =========================
# Question words
# =========================
WH_WORDS = {
    "what", "where", "when",
    "who", "why", "how", "which"
}

# =========================
# Time-related words
# =========================
TIME_WORDS = {
    "today", "tomorrow", "yesterday", "now",
    "later", "soon", "never", "always",
    "sometimes", "tonight", "morning",
    "afternoon", "evening", "night",

    "week", "month", "year",
    "day", "hour", "minute",

    "monday", "tuesday", "wednesday",
    "thursday", "friday", "saturday", "sunday"
}

# =========================
# Main function
# =========================
def english_to_asl_gloss(sentence: str) -> list:
    doc = nlp(sentence.strip())
    tokens = list(doc)

    is_question = sentence.strip().endswith("?")

    time_glosses = []
    subject_glosses = []
    object_glosses = []
    verb_glosses = []
    other_glosses = []

    wh_gloss = None

    # FIX 4: detect negation — now also catches "no" used as determiner
    has_negation = any(
        t.lower_ in {"not", "n't"}
        or t.dep_ == "neg"
        or (t.lower_ == "no" and t.dep_ == "det")
        for t in tokens
    )

    for tok in tokens:
        low = tok.lower_
        lemma = tok.lemma_.lower()

        # Skip punctuation
        if tok.is_punct:
            continue

        # Handle WH words
        if low in WH_WORDS and is_question:
            wh_gloss = low.upper()
            continue

        # Skip articles, prepositions, "that", "every"
        if low in REMOVE_TOKENS:
            continue

        # Skip helper verbs
        if lemma in REMOVE_LEMMAS:
            continue

        # Skip infinitive "to"
        if low == "to":
            continue

        # Skip negation words (handled separately)
        if low in {"not", "n't", "no"}:
            continue

        # FIX 5: skip expletive "there" (e.g. "there are")
        if low == "there" and tok.dep_ == "expl":
            continue

        # Preserve named entities like New York
        if tok.ent_type_:
            gloss = tok.text.upper()
        elif low in PRONOUN_MAP:
            gloss = PRONOUN_MAP[low]
        else:
            gloss = tok.lemma_.upper()

        # Put time words first
        if low in TIME_WORDS:
            time_glosses.append(gloss)
            continue

        # Categorize based on dependency
        if tok.dep_ in {"nsubj", "nsubjpass"}:
            subject_glosses.append(gloss)

        elif tok.dep_ in {"dobj", "pobj", "attr", "dative"}:
            object_glosses.append(gloss)

        elif tok.pos_ in {"VERB", "AUX"}:
            verb_glosses.append(gloss)

        else:
            other_glosses.append(gloss)

    # Build ASL order: TIME + SUBJECT + OBJECT + VERB + OTHER
    result = []
    result.extend(time_glosses)
    result.extend(subject_glosses)
    result.extend(object_glosses)
    result.extend(verb_glosses)

    # Add NOT after first verb if negation detected
    if has_negation:
        inserted = False
        temp_result = []

        for gloss in result:
            temp_result.append(gloss)

            if not inserted and gloss in verb_glosses:
                temp_result.append("NOT")
                inserted = True

        if not inserted:
            temp_result.append("NOT")

        result = temp_result

    result.extend(other_glosses)

    # Remove duplicate TO if it slipped through
    result = [g for g in result if g != "TO"]

    # Add question marker
    if wh_gloss:
        result.append(wh_gloss)
    elif is_question:
        result.append("Q")

    return result

# =========================
# Interactive loop
# =========================
while True:
    sentence = input("Enter sentence (or 'quit' to exit): ").strip()

    if sentence.lower() == "quit":
        print("Goodbye!")
        break

    if not sentence:
        continue

    gloss = english_to_asl_gloss(sentence)

    print("ASL Gloss:", " ".join(gloss))
    print()