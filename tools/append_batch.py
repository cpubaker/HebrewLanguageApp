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

BATCH_NUMBER = 5
BATCH_DATE = "2026-06-03"

# 16 food + 16 animals + 11 nature_weather + 6 abstract_common + 1 city = 50.
# Skipped from food: פֵּרֵר (not a standard Hebrew word for "berry") and
# קוּלִי (non-standard spelling for "kohlrabi"). Replaced with one city_places
# entry to keep the batch at 50.
ENTRIES = [
    # food (16 of 17 — see header note)
    ("word_freq2k_sour_cream", "שַׁמֶּנֶת", "sour cream", "сметана", "shamenet"),
    ("word_freq2k_rice", "אֹרֶז", "rice", "рис", "orez"),
    ("word_freq2k_chicken", "עוֹף", "chicken", "курка", "of"),
    ("word_freq2k_lamb", "בְּשַׂר טָלֶה", "lamb", "ягнятина", "bsar tale"),
    ("word_freq2k_sausage", "נַקְנִיק", "sausage", "ковбаса", "naknik"),
    ("word_freq2k_salted_fish", "דָּג מָלוּחַ", "salted fish", "солона риба", "dag maluach"),
    ("word_freq2k_fruits", "פֵּרוֹת", "fruits", "фрукти", "perot"),
    ("word_freq2k_vegetables", "יְרָקוֹת", "vegetables", "овочі", "yerakot"),
    ("word_freq2k_grapes", "עֲנָבִים", "grapes", "виноград", "anavim"),
    ("word_freq2k_cherry", "דֻּבְדְּבָן", "cherry", "вишня", "duvdevan"),
    ("word_freq2k_strawberry", "תּוּת", "strawberry", "полуниця", "tut"),
    ("word_freq2k_lettuce", "חַסָּה", "lettuce", "салат-латук", "chasa"),
    ("word_freq2k_green_pepper", "פִּלְפֵּל יָרֹק", "green pepper", "зелений перець", "pilpel yarok"),
    ("word_freq2k_meal", "אֲרוּחָה", "meal", "трапеза", "arucha"),
    ("word_freq2k_napkin", "מַפִּית", "napkin", "серветка", "mapit"),
    # animals (clears category)
    ("word_freq2k_ox", "שׁוֹר", "ox", "бик", "shor"),
    ("word_freq2k_sheep", "כֶּבֶשׂ", "sheep", "вівця", "keves"),
    ("word_freq2k_donkey", "חֲמוֹר", "donkey", "осел", "chamor"),
    ("word_freq2k_rabbit", "ארנב", "rabbit", "кролик", "arnav"),
    ("word_freq2k_rat", "חֻלְדָּה", "rat", "щур", "chulda"),
    ("word_freq2k_eagle", "נֶשֶׁר", "eagle", "орел", "nesher"),
    ("word_freq2k_fowl", "עוֹף", "fowl", "птиця", "of"),
    ("word_freq2k_rooster", "תַּרְנְגוֹל", "rooster", "півень", "tarnegol"),
    ("word_freq2k_hen", "תַּרְנְגֹלֶת", "hen", "курка", "tarnegolet"),
    ("word_freq2k_fish_pl", "דָּגִים", "fish (pl.)", "риби", "dagim"),
    ("word_freq2k_snake", "נָחָשׁ", "snake", "змія", "nachash"),
    ("word_freq2k_mosquito", "יַתּוּשׁ", "mosquito", "комар", "yatush"),
    ("word_freq2k_fly", "זְבוּב", "fly", "муха", "zvuv"),
    ("word_freq2k_spider", "עַכָּבִישׁ", "spider", "павук", "akavish"),
    ("word_freq2k_turtle", "צָב", "turtle", "черепаха", "tzav"),
    ("word_freq2k_leopard", "נָמֵר", "leopard", "леопард", "namer"),
    # nature_weather (clears category)
    ("word_freq2k_clouds", "עָנָנִים", "clouds", "хмари", "ananim"),
    ("word_freq2k_hail", "בָּרָד", "hail", "град", "barad"),
    ("word_freq2k_degree", "מַעֲלָה", "degree", "градус", "ma'ala"),
    ("word_freq2k_electricity", "חַשְׁמַל", "electricity", "електрика", "chashmal"),
    ("word_freq2k_root", "שֹׁרֶשׁ", "root", "корінь", "shoresh"),
    ("word_freq2k_green", "יָרֹק", "green", "зелений", "yarok"),
    ("word_freq2k_landscape", "נוֹף", "landscape; view", "пейзаж", "nof"),
    ("word_freq2k_inanimate", "דּוֹמֵם", "inanimate", "неживий", "domem"),
    ("word_freq2k_darkness", "חֹשֶׁךְ", "darkness", "темрява", "choshekh"),
    ("word_freq2k_spring_water", "מַעְיָן", "spring (water)", "джерело", "ma'ayan"),
    ("word_freq2k_flow", "שֶׁטֶף", "flow; flood", "потік", "shetef"),
    # abstract_common (clears category)
    ("word_freq2k_imagination", "דִּמְיוֹן", "imagination; similarity", "уява; схожість", "dimyon"),
    ("word_freq2k_column", "טוּר", "column; row", "колонка", "tur"),
    ("word_freq2k_dispute", "מַחְלוֹקֶת", "dispute", "суперечка", "machloket"),
    ("word_freq2k_importance", "חֲשִׁיבוּת", "importance", "важливість", "chashivut"),
    ("word_freq2k_continuation", "הֶמְשֵׁךְ", "continuation", "продовження", "hemshekh"),
    ("word_freq2k_progress", "הִתְקַדְּמוּת", "progress", "прогрес", "hitkadmut"),
    # city_places (1 entry to round to 50)
    ("word_freq2k_supermarket", "סוּפֶּרְמַרְקֶט", "supermarket", "супермаркет", "supermarket"),
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
