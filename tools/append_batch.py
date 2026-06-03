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

BATCH_NUMBER = 4
BATCH_DATE = "2026-06-03"

# 16 family + 18 body_health + 16 clothing = 50 entries. Clears 3 categories.
ENTRIES = [
    # family (clears category)
    ("word_freq2k_grandson", "נֶכֶד", "grandson", "онук", "nekhed"),
    ("word_freq2k_granddaughter", "נֶכְדָּה", "granddaughter", "онука", "nekhda"),
    ("word_freq2k_nephew", "אַחְיָן", "nephew", "племінник", "achyan"),
    ("word_freq2k_niece", "אַחְיָנִית", "niece", "племінниця", "achyanit"),
    ("word_freq2k_cousin_m", "בֶּן דּוֹד", "cousin (m)", "двоюрідний брат", "ben dod"),
    ("word_freq2k_cousin_f", "בַּת דּוֹדָה", "cousin (f)", "двоюрідна сестра", "bat doda"),
    ("word_freq2k_groom", "חָתָן", "groom; son-in-law", "наречений; зять", "chatan"),
    ("word_freq2k_bride", "כַּלָּה", "bride; daughter-in-law", "наречена; невістка", "kala"),
    ("word_freq2k_mother_in_law", "חָמוֹת", "mother-in-law", "теща; свекруха", "chamot"),
    ("word_freq2k_parents", "הוֹרִים", "parents", "батьки", "horim"),
    ("word_freq2k_baby_girl", "תִּינוֹקֶת", "baby girl", "немовля (ж.)", "tinoket"),
    ("word_freq2k_naara", "נַעֲרָה", "girl; youth", "дівчина", "na'ara"),
    ("word_freq2k_neighbor_f", "שְׁכֵנָה", "neighbor (f)", "сусідка", "shkhena"),
    ("word_freq2k_relative", "קְרוֹב מִשְׁפָּחָה", "relative", "родич", "krov mishpacha"),
    ("word_freq2k_widow", "אַלְמָנָה", "widow", "вдова", "almana"),
    ("word_freq2k_divorced", "גָּרוּשׁ", "divorced", "розлучений", "garush"),
    # body_health (clears category)
    ("word_freq2k_nail", "צִפֹּרֶן", "nail", "ніготь", "tziporen"),
    ("word_freq2k_hips", "מָתְנַיִם", "hips; waist", "стегна; талія", "motnayim"),
    ("word_freq2k_ankle", "קַרְסֹל", "ankle", "щиколотка", "karsol"),
    ("word_freq2k_lung", "רֵאָה", "lung", "легеня", "rea"),
    ("word_freq2k_kidney", "כִּלְיָה", "kidney", "нирка", "kilya"),
    ("word_freq2k_stomach", "קֵבָה", "stomach (organ)", "шлунок", "keva"),
    ("word_freq2k_muscle", "שְׁרִיר", "muscle", "м'яз", "shrir"),
    ("word_freq2k_brain", "מֹחַ", "brain", "мозок", "moach"),
    ("word_freq2k_flu", "שַׁפַּעַת", "flu", "грип", "shapaat"),
    ("word_freq2k_cold_illness", "צִנּוּן", "cold (illness)", "застуда", "tzinun"),
    ("word_freq2k_headache", "כְּאֵב רֹאשׁ", "headache", "головний біль", "ke'ev rosh"),
    ("word_freq2k_cough", "שִׁעוּל", "cough", "кашель", "shi'ul"),
    ("word_freq2k_nausea", "בְּחִילָה", "nausea", "нудота", "bechila"),
    ("word_freq2k_fracture", "שֶׁבֶר", "fracture", "перелом", "shever"),
    ("word_freq2k_pharmacy", "בֵּית מִרְקַחַת", "pharmacy", "аптека", "beit mirkachat"),
    ("word_freq2k_syringe", "מַזְרֵק", "syringe", "шприц", "mazrek"),
    ("word_freq2k_vaccination", "חִסּוּן", "vaccination", "щеплення", "chisun"),
    ("word_freq2k_diet", "דִּיאֵטָה", "diet", "дієта", "dieta"),
    # clothing (clears category)
    ("word_freq2k_shirt", "חֻלְצָה", "shirt", "сорочка", "chultza"),
    ("word_freq2k_jeans", "מִכְנְסֵי גִּ'ינְס", "jeans", "джинси", "mikhnesei jeans"),
    ("word_freq2k_tshirt", "חֻלְצַת טְרִיקוֹ", "T-shirt", "футболка", "chultzat triko"),
    ("word_freq2k_jacket", "גֶּ'קֶט", "jacket", "куртка", "jeket"),
    ("word_freq2k_boots", "מַגָּפַיִם", "boots", "чоботи", "magafayim"),
    ("word_freq2k_sandals", "סַנְדָּלִים", "sandals", "сандалі", "sandalim"),
    ("word_freq2k_sneakers", "נַעֲלֵי סְפּוֹרְט", "sneakers", "кросівки", "na'alei sport"),
    ("word_freq2k_tights", "גַּרְבּוֹנִים", "tights", "колготки", "garbonim"),
    ("word_freq2k_tie", "עֲנִיבָה", "tie", "краватка", "aniva"),
    ("word_freq2k_sunglasses", "מִשְׁקְפֵי שֶׁמֶשׁ", "sunglasses", "сонячні окуляри", "mishkefei shemesh"),
    ("word_freq2k_earring", "עָגִיל", "earring", "сережка", "agil"),
    ("word_freq2k_wristwatch", "שָׁעוֹן יָד", "wristwatch", "наручний годинник", "sha'on yad"),
    ("word_freq2k_swimsuit", "חֲלִיפַת יָם", "swimsuit", "купальник", "chalifat yam"),
    ("word_freq2k_pajamas", "פִּיגָ'מָה", "pajamas", "піжама", "pijama"),
    ("word_freq2k_bra", "חֲזִיָּה", "bra", "бюстгальтер", "chaziya"),
    ("word_freq2k_wardrobe", "אֲרוֹן בְּגָדִים", "wardrobe", "шафа", "aron begadim"),
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
