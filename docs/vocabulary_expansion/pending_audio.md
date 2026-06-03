# Pending audio for new vocabulary

Words added to `hebrew_words.json` without an `audio_file` value live here until audio is generated.

## How to use

When adding a frequency-batch entry to `hebrew_words.json`:

1. Add the entry without an `audio_file` field (the field is optional per `flutter_app/assets/learning/input/AGENTS.md`).
2. Append the `word_id` to the **Queue** table below with batch number and date.
3. After running `scripts/generate_word_audio_elevenlabs.py` for the queued ids, move the rows to the **Done** section and add the `audio_file` field to the JSON entries.

## Queue

| Batch | Date added | word_id | Hebrew | Transcription |
|---|---|---|---|---|
| 1 | 2026-06-03 | word_freq2k_but | אֲבָל | aval |
| 1 | 2026-06-03 | word_freq2k_or | אוֹ | o |
| 1 | 2026-06-03 | word_freq2k_ki | כִּי | ki |
| 1 | 2026-06-03 | word_freq2k_she | שֶׁ | she |
| 1 | 2026-06-03 | word_freq2k_gam | גַּם | gam |
| 1 | 2026-06-03 | word_freq2k_only | רַק | rak |
| 1 | 2026-06-03 | word_freq2k_od | עוֹד | od |
| 1 | 2026-06-03 | word_freq2k_already | כְּבָר | kvar |
| 1 | 2026-06-03 | word_freq2k_however | אוּלָם | ulam |
| 1 | 2026-06-03 | word_freq2k_bekhol_zot | בְּכָל זֹאת | bekhol zot |
| 1 | 2026-06-03 | word_freq2k_therefore | לָכֵן | lakhen |
| 1 | 2026-06-03 | word_freq2k_mipnei_she | מִפְּנֵי שֶׁ | mipnei she |
| 1 | 2026-06-03 | word_freq2k_keivan_she | כֵּיוָן שֶׁ | keivan she |
| 1 | 2026-06-03 | word_freq2k_bizman_she | בִּזְמַן שֶׁ | bizman she |
| 1 | 2026-06-03 | word_freq2k_kshe | כְּשֶׁ | kshe |
| 1 | 2026-06-03 | word_freq2k_lifnei_she | לִפְנֵי שֶׁ | lifnei she |
| 1 | 2026-06-03 | word_freq2k_acharei_she | אַחֲרֵי שֶׁ | acharei she |
| 1 | 2026-06-03 | word_freq2k_beod_she | בְּעוֹד שֶׁ | be'od she |
| 1 | 2026-06-03 | word_freq2k_kedei | כְּדֵי | kedei |
| 1 | 2026-06-03 | word_freq2k_kedei_she | כְּדֵי שֶׁ | kedei she |
| 1 | 2026-06-03 | word_freq2k_beetzem | בְּעֶצֶם | be'etzem |
| 1 | 2026-06-03 | word_freq2k_beemet | בֶּאֱמֶת | be'emet |
| 1 | 2026-06-03 | word_freq2k_bediyuk | בְּדִיּוּק | bediyuk |
| 1 | 2026-06-03 | word_freq2k_beikar | בְּעִקָּר | be'ikar |
| 1 | 2026-06-03 | word_freq2k_bimyukhad | בִּמְיֻחָד | bimyukhad |
| 1 | 2026-06-03 | word_freq2k_bekhol_ofen | בְּכָל אֹפֶן | bekhol ofen |
| 1 | 2026-06-03 | word_freq2k_bekhol_mikre | בְּכָל מִקְרֶה | bekhol mikre |
| 1 | 2026-06-03 | word_freq2k_af_al_pi_khen | אַף עַל פִּי כֵן | af al pi khen |
| 1 | 2026-06-03 | word_freq2k_klomar | כְּלוֹמַר | klomar |
| 1 | 2026-06-03 | word_freq2k_lemashal | לְמָשָׁל | lemashal |
| 1 | 2026-06-03 | word_freq2k_kemo_khen | כְּמוֹ כֵן | kemo khen |
| 1 | 2026-06-03 | word_freq2k_chutz_mi | חוּץ מִ | chutz mi |
| 1 | 2026-06-03 | word_freq2k_milvad | מִלְּבַד | milvad |
| 1 | 2026-06-03 | word_freq2k_leumat | לְעֻמַּת | le'umat |
| 1 | 2026-06-03 | word_freq2k_mitokh | מִתּוֹךְ | mitokh |
| 1 | 2026-06-03 | word_freq2k_harei | הֲרֵי | harei |
| 1 | 2026-06-03 | word_freq2k_davka | דַּוְקָא | davka |
| 1 | 2026-06-03 | word_freq2k_afilu | אֲפִילּוּ | afilu |
| 1 | 2026-06-03 | word_freq2k_we | אֲנַחְנוּ | anachnu |
| 1 | 2026-06-03 | word_freq2k_this_m | הַזֶּה | hazeh |
| 1 | 2026-06-03 | word_freq2k_this_f | הַזֹּאת | hazot |
| 1 | 2026-06-03 | word_freq2k_that_m | הַהוּא | hahu |
| 1 | 2026-06-03 | word_freq2k_that_f | הַהִיא | hahi |
| 1 | 2026-06-03 | word_freq2k_here | כָּאן | kan |
| 1 | 2026-06-03 | word_freq2k_meayin | מֵאַיִן | me'ayin |
| 1 | 2026-06-03 | word_freq2k_kakha | כָּכָה | kakha |
| 1 | 2026-06-03 | word_freq2k_kakh | כָּךְ | kakh |
| 1 | 2026-06-03 | word_freq2k_other_f | אַחֶרֶת | akheret |
| 1 | 2026-06-03 | word_freq2k_atzmi | עַצְמִי | atzmi |
| 1 | 2026-06-03 | word_freq2k_mashehu | מַשֶּׁהוּ | mashehu |

## Done

| Batch | Date generated | word_id | audio_file |
|---|---|---|---|
