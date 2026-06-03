"""Append a frequency-batch of new entries to hebrew_words.json.

Each batch is a list of (word_id, hebrew, english, ukrainian, transcription)
tuples. We append (no audio_file yet), preserving the existing 4-space indent
and the trailing newline. Run vocab_diff.py afterward to confirm the new
entries closed the expected gaps.
"""
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
TARGET = ROOT / "flutter_app" / "assets" / "learning" / "input" / "hebrew_words.json"
PENDING_AUDIO = ROOT / "docs" / "vocabulary_expansion" / "pending_audio.md"

BATCH_NUMBER = 1
BATCH_DATE = "2026-06-03"

# 38 function words + 12 pronouns/demonstratives = 50 entries.
ENTRIES = [
    # function_words
    ("word_freq2k_but", "אֲבָל", "but", "але", "aval"),
    ("word_freq2k_or", "אוֹ", "or", "або", "o"),
    ("word_freq2k_ki", "כִּי", "because; that", "бо; що", "ki"),
    ("word_freq2k_she", "שֶׁ", "that (subordinator)", "що", "she"),
    ("word_freq2k_gam", "גַּם", "also; too", "теж; також", "gam"),
    ("word_freq2k_only", "רַק", "only", "лише", "rak"),
    ("word_freq2k_od", "עוֹד", "still; more", "ще", "od"),
    ("word_freq2k_already", "כְּבָר", "already", "вже", "kvar"),
    ("word_freq2k_however", "אוּלָם", "however", "проте", "ulam"),
    ("word_freq2k_bekhol_zot", "בְּכָל זֹאת", "nevertheless", "усе ж", "bekhol zot"),
    ("word_freq2k_therefore", "לָכֵן", "therefore", "тому", "lakhen"),
    ("word_freq2k_mipnei_she", "מִפְּנֵי שֶׁ", "because", "через те що", "mipnei she"),
    ("word_freq2k_keivan_she", "כֵּיוָן שֶׁ", "since", "оскільки", "keivan she"),
    ("word_freq2k_bizman_she", "בִּזְמַן שֶׁ", "while", "поки", "bizman she"),
    ("word_freq2k_kshe", "כְּשֶׁ", "when (conj.)", "коли", "kshe"),
    ("word_freq2k_lifnei_she", "לִפְנֵי שֶׁ", "before (conj.)", "до того як", "lifnei she"),
    ("word_freq2k_acharei_she", "אַחֲרֵי שֶׁ", "after (conj.)", "після того як", "acharei she"),
    ("word_freq2k_beod_she", "בְּעוֹד שֶׁ", "whereas; while", "тоді як", "be'od she"),
    ("word_freq2k_kedei", "כְּדֵי", "in order to", "щоб", "kedei"),
    ("word_freq2k_kedei_she", "כְּדֵי שֶׁ", "so that", "щоб", "kedei she"),
    ("word_freq2k_beetzem", "בְּעֶצֶם", "actually", "насправді", "be'etzem"),
    ("word_freq2k_beemet", "בֶּאֱמֶת", "really", "справді", "be'emet"),
    ("word_freq2k_bediyuk", "בְּדִיּוּק", "exactly", "саме; точно", "bediyuk"),
    ("word_freq2k_beikar", "בְּעִקָּר", "mainly", "переважно", "be'ikar"),
    ("word_freq2k_bimyukhad", "בִּמְיֻחָד", "especially", "особливо", "bimyukhad"),
    ("word_freq2k_bekhol_ofen", "בְּכָל אֹפֶן", "anyway", "у всякому разі", "bekhol ofen"),
    ("word_freq2k_bekhol_mikre", "בְּכָל מִקְרֶה", "in any case", "у будь-якому разі", "bekhol mikre"),
    ("word_freq2k_af_al_pi_khen", "אַף עַל פִּי כֵן", "nevertheless", "однак", "af al pi khen"),
    ("word_freq2k_klomar", "כְּלוֹמַר", "that is; meaning", "тобто", "klomar"),
    ("word_freq2k_lemashal", "לְמָשָׁל", "for example", "наприклад", "lemashal"),
    ("word_freq2k_kemo_khen", "כְּמוֹ כֵן", "likewise", "так само", "kemo khen"),
    ("word_freq2k_chutz_mi", "חוּץ מִ", "except for", "крім", "chutz mi"),
    ("word_freq2k_milvad", "מִלְּבַד", "except", "окрім", "milvad"),
    ("word_freq2k_leumat", "לְעֻמַּת", "compared to", "порівняно з", "le'umat"),
    ("word_freq2k_mitokh", "מִתּוֹךְ", "out of; from within", "із; з", "mitokh"),
    ("word_freq2k_harei", "הֲרֵי", "indeed; after all", "адже", "harei"),
    ("word_freq2k_davka", "דַּוְקָא", "specifically; just", "якраз", "davka"),
    ("word_freq2k_afilu", "אֲפִילּוּ", "even", "навіть", "afilu"),
    # pronouns_demonstratives
    ("word_freq2k_we", "אֲנַחְנוּ", "we", "ми", "anachnu"),
    ("word_freq2k_this_m", "הַזֶּה", "this (m)", "цей", "hazeh"),
    ("word_freq2k_this_f", "הַזֹּאת", "this (f)", "ця", "hazot"),
    ("word_freq2k_that_m", "הַהוּא", "that (m)", "той", "hahu"),
    ("word_freq2k_that_f", "הַהִיא", "that (f)", "та", "hahi"),
    ("word_freq2k_here", "כָּאן", "here", "тут", "kan"),
    ("word_freq2k_meayin", "מֵאַיִן", "from where", "звідки", "me'ayin"),
    ("word_freq2k_kakha", "כָּכָה", "so; like that", "так", "kakha"),
    ("word_freq2k_kakh", "כָּךְ", "so; thus", "так", "kakh"),
    ("word_freq2k_other_f", "אַחֶרֶת", "other (f)", "інша", "akheret"),
    ("word_freq2k_atzmi", "עַצְמִי", "myself", "сам", "atzmi"),
    ("word_freq2k_mashehu", "מַשֶּׁהוּ", "something", "щось", "mashehu"),
]


def main() -> int:
    data = json.loads(TARGET.read_text(encoding="utf-8"))

    # Guard against duplicate word_ids.
    existing_ids = {e["word_id"] for e in data}
    new_entries = []
    skipped = []
    for word_id, hebrew, english, ukrainian, transcription in ENTRIES:
        if word_id in existing_ids:
            skipped.append(word_id)
            continue
        new_entries.append({
            "word_id": word_id,
            "hebrew": hebrew,
            "english": english,
            "ukrainian": ukrainian,
            "transcription": transcription,
        })

    data.extend(new_entries)
    TARGET.write_text(
        json.dumps(data, ensure_ascii=False, indent=4) + "\n",
        encoding="utf-8",
    )

    # Append queue rows to pending_audio.md (preserve everything before the
    # Queue section). We assume the file already contains the Queue and Done
    # headers from the initial scaffold.
    md = PENDING_AUDIO.read_text(encoding="utf-8")
    queue_marker = "| Batch | Date added | word_id | Hebrew | Transcription |\n|---|---|---|---|---|\n"
    if queue_marker in md:
        rows = "".join(
            f"| {BATCH_NUMBER} | {BATCH_DATE} | {e['word_id']} | {e['hebrew']} | {e['transcription']} |\n"
            for e in new_entries
        )
        md = md.replace(queue_marker, queue_marker + rows, 1)
        PENDING_AUDIO.write_text(md, encoding="utf-8")

    print(f"Appended {len(new_entries)} entries; skipped duplicates: {len(skipped)}")
    if skipped:
        for s in skipped:
            print(f"  duplicate: {s}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
