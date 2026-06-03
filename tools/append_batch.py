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

BATCH_NUMBER = 3
BATCH_DATE = "2026-06-03"

# 30 adjectives + 20 emotions_states = 50 entries. Clears both categories.
ENTRIES = [
    # adjectives (clears category)
    ("word_freq2k_cool_adj", "קָרִיר", "cool", "прохолодний", "karir"),
    ("word_freq2k_wet", "רָטֹב", "wet", "мокрий", "ratov"),
    ("word_freq2k_dirty", "מְלֻכְלָךְ", "dirty", "брудний", "melukhlakh"),
    ("word_freq2k_confused", "מְבֻלְבָּל", "confused", "розгублений", "mevulbal"),
    ("word_freq2k_boring", "מְשַׁעֲמֵם", "boring", "нудний", "mesha'amem"),
    ("word_freq2k_complicated", "מְסֻבָּךְ", "complicated", "складний", "mesubakh"),
    ("word_freq2k_famous", "מְפֻרְסָם", "famous", "відомий", "mefursam"),
    ("word_freq2k_real", "אֲמִיתִי", "real; true", "справжній", "amiti"),
    ("word_freq2k_suitable", "מַתְאִים", "suitable", "придатний", "matim"),
    ("word_freq2k_similar", "דּוֹמֶה", "similar", "схожий", "domeh"),
    ("word_freq2k_shared", "מְשֻׁתָּף", "shared; common", "спільний", "meshutaf"),
    ("word_freq2k_whole_adj", "שָׁלֵם", "whole", "цілий", "shalem"),
    ("word_freq2k_broken", "שָׁבוּר", "broken", "зламаний", "shavur"),
    ("word_freq2k_free_adj", "חָפְשִׁי", "free", "вільний", "chofshi"),
    ("word_freq2k_occupied", "תָּפוּס", "occupied", "зайнятий", "tafus"),
    ("word_freq2k_delicious", "טָעִים", "delicious", "смачний", "ta'im"),
    ("word_freq2k_ripe", "בָּשֵׁל", "ripe", "стиглий", "bashel"),
    ("word_freq2k_polite", "אַדִּיב", "polite", "ввічливий", "adiv"),
    ("word_freq2k_rude", "גַּס", "rude", "грубий", "gas"),
    ("word_freq2k_stingy", "קַמְצָן", "stingy", "скнара", "kamtzan"),
    ("word_freq2k_coward", "פַּחְדָן", "coward", "боягуз", "pachdan"),
    ("word_freq2k_dangerous", "מְסֻכָּן", "dangerous", "небезпечний", "mesukan"),
    ("word_freq2k_funny", "מַצְחִיק", "funny", "смішний", "matzchik"),
    ("word_freq2k_rude_spirit", "גַּס רוּחַ", "rude (in spirit)", "хам", "gas ruach"),
    ("word_freq2k_stubborn", "עָקֵב", "stubborn", "впертий", "aqev"),
    ("word_freq2k_lazy", "עַצְלָן", "lazy", "лінивий", "atzlan"),
    ("word_freq2k_diligent", "חָרוּץ", "diligent", "старанний", "charutz"),
    ("word_freq2k_main_adj", "עִקָּרִי", "main; principal", "головний", "ikari"),
    ("word_freq2k_special", "מְיֻחָד", "special", "особливий", "meyuchad"),
    ("word_freq2k_wonderful", "נֶהְדָּר", "wonderful", "чудовий", "nehedar"),
    # emotions_states (clears category)
    ("word_freq2k_hatred", "שִׂנְאָה", "hatred", "ненависть", "sina"),
    ("word_freq2k_joy", "שִׂמְחָה", "joy", "радість", "simcha"),
    ("word_freq2k_sadness", "עֶצֶב", "sadness", "сум", "etzev"),
    ("word_freq2k_anger", "כַּעַס", "anger", "гнів", "ka'as"),
    ("word_freq2k_anxiety", "חֲרָדָה", "anxiety", "тривога", "charada"),
    ("word_freq2k_worry", "דְּאָגָה", "worry", "турбота", "de'aga"),
    ("word_freq2k_faith", "אֱמוּנָה", "faith; belief", "віра", "emuna"),
    ("word_freq2k_confidence", "בִּטָּחוֹן", "confidence; security", "впевненість", "bitachon"),
    ("word_freq2k_pride", "גַּאֲוָה", "pride", "гордість", "ga'ava"),
    ("word_freq2k_shame", "בּוּשָׁה", "shame", "сором", "busha"),
    ("word_freq2k_disgrace", "חֶרְפָּה", "disgrace", "ганьба", "cherpa"),
    ("word_freq2k_enthusiasm", "הִתְלַהֲבוּת", "enthusiasm", "захоплення", "hitlahavut"),
    ("word_freq2k_feeling", "הַרְגָּשָׁה", "feeling", "відчуття", "hargasha"),
    ("word_freq2k_fatigue", "יְגִיעוּת", "fatigue", "втома", "yegi'ut"),
    ("word_freq2k_rest", "מְנוּחָה", "rest", "відпочинок", "menucha"),
    ("word_freq2k_desire", "רָצוֹן", "desire; will", "бажання", "ratzon"),
    ("word_freq2k_sorrow", "צַעַר", "sorrow", "горе", "tza'ar"),
    ("word_freq2k_compassion", "רַחֲמִים", "compassion", "співчуття", "rachamim"),
    ("word_freq2k_patience", "סַבְלָנוּת", "patience", "терпіння", "savlanut"),
    ("word_freq2k_tranquility", "שַׁלְוָה", "tranquility", "спокій", "shalva"),
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
