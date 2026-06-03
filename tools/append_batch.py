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

BATCH_NUMBER = 2
BATCH_DATE = "2026-06-03"

# 11 questions/quantifiers + 5 colors + 14 time + 20 abstract_common = 50 entries.
ENTRIES = [
    # questions_quantifiers (clears category)
    ("word_freq2k_eizo", "אֵיזוֹ", "which (f)", "яка", "eizo"),
    ("word_freq2k_haim", "הַאִם", "whether (yes/no marker)", "чи", "ha'im"),
    ("word_freq2k_meat_meat", "מְעַט מְעַט", "little by little", "потроху", "me'at me'at"),
    ("word_freq2k_maspik", "מַסְפִּיק", "enough", "достатньо", "maspik"),
    ("word_freq2k_yoter", "יוֹתֵר", "more", "більше", "yoter"),
    ("word_freq2k_pachot", "פָּחוֹת", "less", "менше", "pachot"),
    ("word_freq2k_haki", "הַכִּי", "the most", "найбільше", "haki"),
    ("word_freq2k_beyoter", "בְּיוֹתֵר", "most; extremely", "найбільш", "beyoter"),
    ("word_freq2k_kol_every", "כָּל", "every; all", "кожен; весь", "kol"),
    ("word_freq2k_eizeshehu", "אֵיזֶשֶׁהוּ", "some kind of (m)", "якийсь", "eizeshehu"),
    ("word_freq2k_eizoshehi", "אֵיזוֹשֶׁהִי", "some kind of (f)", "якась", "eizoshehi"),
    # colors (clears category)
    ("word_freq2k_gray", "אָפֹר", "gray", "сірий", "afor"),
    ("word_freq2k_purple", "סָגֹל", "purple", "фіолетовий", "sagol"),
    ("word_freq2k_beige", "בֵּז'", "beige", "бежевий", "bezh"),
    ("word_freq2k_turquoise", "טֻרְקִיז", "turquoise", "бірюзовий", "turkiz"),
    ("word_freq2k_burgundy", "בּוּרְגּוּנְדִי", "burgundy", "бордовий", "burgundi"),
    # time (clears category)
    ("word_freq2k_shilshom", "שִׁלְשׁוֹם", "day before yesterday", "позавчора", "shilshom"),
    ("word_freq2k_mochrotayim", "מָחֳרָתַיִם", "day after tomorrow", "післязавтра", "mochrotayim"),
    ("word_freq2k_tzohorayim", "צָהֳרַיִם", "noon", "полудень", "tzohorayim"),
    ("word_freq2k_afternoon", "אַחַר הַצָּהֳרַיִם", "afternoon", "після обіду", "achar hatzohorayim"),
    ("word_freq2k_chatzot", "חֲצוֹת", "midnight", "опівніч", "chatzot"),
    ("word_freq2k_paam", "פַּעַם", "once; a time", "раз", "pa'am"),
    ("word_freq2k_achar_kakh", "אַחַר כָּךְ", "afterwards", "потім", "achar kakh"),
    ("word_freq2k_lifnei_khen", "לִפְנֵי כֵן", "before that", "до того", "lifnei khen"),
    ("word_freq2k_miyad", "מִיָּד", "immediately", "негайно", "miyad"),
    ("word_freq2k_bekarov", "בְּקָרוֹב", "soon", "скоро", "bekarov"),
    ("word_freq2k_leat", "לְאַט", "slowly", "повільно", "le'at"),
    ("word_freq2k_maher", "מַהֵר", "quickly", "швидко", "maher"),
    ("word_freq2k_shabbat", "שַׁבָּת", "Saturday; Sabbath", "субота", "shabbat"),
    ("word_freq2k_stav", "סְתָו", "autumn", "осінь", "stav"),
    # abstract_common (20 of 27 — high-frequency picks)
    ("word_freq2k_life", "חַיִּים", "life", "життя", "chayim"),
    ("word_freq2k_freedom", "חֵרוּת", "freedom", "свобода", "cherut"),
    ("word_freq2k_beauty", "יֹפִי", "beauty", "краса", "yofi"),
    ("word_freq2k_power", "כֹּחַ", "power; strength", "сила", "koach"),
    ("word_freq2k_weakness", "חֻלְשָׁה", "weakness", "слабкість", "chulsha"),
    ("word_freq2k_reason", "סִבָּה", "reason; cause", "причина", "siba"),
    ("word_freq2k_difference", "הֶבְדֵּל", "difference", "різниця", "hevdel"),
    ("word_freq2k_fact", "עֻבְדָּה", "fact", "факт", "uvda"),
    ("word_freq2k_information", "מֵידָע", "information", "інформація", "meda"),
    ("word_freq2k_point", "נְקֻדָּה", "point; period", "крапка; пункт", "nekuda"),
    ("word_freq2k_size", "גֹּדֶל", "size", "розмір", "godel"),
    ("word_freq2k_height", "גֹּבַהּ", "height", "висота", "govah"),
    ("word_freq2k_length", "אֹרֶךְ", "length", "довжина", "orekh"),
    ("word_freq2k_distance", "מֶרְחָק", "distance", "відстань", "merchak"),
    ("word_freq2k_type", "סוּג", "type; kind", "тип", "sug"),
    ("word_freq2k_thing", "דָּבָר", "thing; matter", "річ", "davar"),
    ("word_freq2k_matter", "עִנְיָן", "matter; topic", "справа", "inyan"),
    ("word_freq2k_subject", "נוֹשֵׂא", "subject; topic", "тема", "nose"),
    ("word_freq2k_state", "מַצָּב", "situation; state", "ситуація", "matzav"),
    ("word_freq2k_change", "שִׁנּוּי", "change", "зміна", "shinui"),
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
