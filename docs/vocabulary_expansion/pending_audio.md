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
| 5 | 2026-06-03 | word_freq2k_sour_cream | שַׁמֶּנֶת | shamenet |
| 5 | 2026-06-03 | word_freq2k_rice | אֹרֶז | orez |
| 5 | 2026-06-03 | word_freq2k_chicken | עוֹף | of |
| 5 | 2026-06-03 | word_freq2k_lamb | בְּשַׂר טָלֶה | bsar tale |
| 5 | 2026-06-03 | word_freq2k_sausage | נַקְנִיק | naknik |
| 5 | 2026-06-03 | word_freq2k_salted_fish | דָּג מָלוּחַ | dag maluach |
| 5 | 2026-06-03 | word_freq2k_fruits | פֵּרוֹת | perot |
| 5 | 2026-06-03 | word_freq2k_vegetables | יְרָקוֹת | yerakot |
| 5 | 2026-06-03 | word_freq2k_grapes | עֲנָבִים | anavim |
| 5 | 2026-06-03 | word_freq2k_cherry | דֻּבְדְּבָן | duvdevan |
| 5 | 2026-06-03 | word_freq2k_strawberry | תּוּת | tut |
| 5 | 2026-06-03 | word_freq2k_lettuce | חַסָּה | chasa |
| 5 | 2026-06-03 | word_freq2k_green_pepper | פִּלְפֵּל יָרֹק | pilpel yarok |
| 5 | 2026-06-03 | word_freq2k_meal | אֲרוּחָה | arucha |
| 5 | 2026-06-03 | word_freq2k_napkin | מַפִּית | mapit |
| 5 | 2026-06-03 | word_freq2k_ox | שׁוֹר | shor |
| 5 | 2026-06-03 | word_freq2k_sheep | כֶּבֶשׂ | keves |
| 5 | 2026-06-03 | word_freq2k_donkey | חֲמוֹר | chamor |
| 5 | 2026-06-03 | word_freq2k_rabbit | ארנב | arnav |
| 5 | 2026-06-03 | word_freq2k_rat | חֻלְדָּה | chulda |
| 5 | 2026-06-03 | word_freq2k_eagle | נֶשֶׁר | nesher |
| 5 | 2026-06-03 | word_freq2k_fowl | עוֹף | of |
| 5 | 2026-06-03 | word_freq2k_rooster | תַּרְנְגוֹל | tarnegol |
| 5 | 2026-06-03 | word_freq2k_hen | תַּרְנְגֹלֶת | tarnegolet |
| 5 | 2026-06-03 | word_freq2k_fish_pl | דָּגִים | dagim |
| 5 | 2026-06-03 | word_freq2k_snake | נָחָשׁ | nachash |
| 5 | 2026-06-03 | word_freq2k_mosquito | יַתּוּשׁ | yatush |
| 5 | 2026-06-03 | word_freq2k_fly | זְבוּב | zvuv |
| 5 | 2026-06-03 | word_freq2k_spider | עַכָּבִישׁ | akavish |
| 5 | 2026-06-03 | word_freq2k_turtle | צָב | tzav |
| 5 | 2026-06-03 | word_freq2k_leopard | נָמֵר | namer |
| 5 | 2026-06-03 | word_freq2k_clouds | עָנָנִים | ananim |
| 5 | 2026-06-03 | word_freq2k_hail | בָּרָד | barad |
| 5 | 2026-06-03 | word_freq2k_degree | מַעֲלָה | ma'ala |
| 5 | 2026-06-03 | word_freq2k_electricity | חַשְׁמַל | chashmal |
| 5 | 2026-06-03 | word_freq2k_root | שֹׁרֶשׁ | shoresh |
| 5 | 2026-06-03 | word_freq2k_green | יָרֹק | yarok |
| 5 | 2026-06-03 | word_freq2k_landscape | נוֹף | nof |
| 5 | 2026-06-03 | word_freq2k_inanimate | דּוֹמֵם | domem |
| 5 | 2026-06-03 | word_freq2k_darkness | חֹשֶׁךְ | choshekh |
| 5 | 2026-06-03 | word_freq2k_spring_water | מַעְיָן | ma'ayan |
| 5 | 2026-06-03 | word_freq2k_flow | שֶׁטֶף | shetef |
| 5 | 2026-06-03 | word_freq2k_imagination | דִּמְיוֹן | dimyon |
| 5 | 2026-06-03 | word_freq2k_column | טוּר | tur |
| 5 | 2026-06-03 | word_freq2k_dispute | מַחְלוֹקֶת | machloket |
| 5 | 2026-06-03 | word_freq2k_importance | חֲשִׁיבוּת | chashivut |
| 5 | 2026-06-03 | word_freq2k_continuation | הֶמְשֵׁךְ | hemshekh |
| 5 | 2026-06-03 | word_freq2k_progress | הִתְקַדְּמוּת | hitkadmut |
| 5 | 2026-06-03 | word_freq2k_supermarket | סוּפֶּרְמַרְקֶט | supermarket |
| 4 | 2026-06-03 | word_freq2k_grandson | נֶכֶד | nekhed |
| 4 | 2026-06-03 | word_freq2k_granddaughter | נֶכְדָּה | nekhda |
| 4 | 2026-06-03 | word_freq2k_nephew | אַחְיָן | achyan |
| 4 | 2026-06-03 | word_freq2k_niece | אַחְיָנִית | achyanit |
| 4 | 2026-06-03 | word_freq2k_cousin_m | בֶּן דּוֹד | ben dod |
| 4 | 2026-06-03 | word_freq2k_cousin_f | בַּת דּוֹדָה | bat doda |
| 4 | 2026-06-03 | word_freq2k_groom | חָתָן | chatan |
| 4 | 2026-06-03 | word_freq2k_bride | כַּלָּה | kala |
| 4 | 2026-06-03 | word_freq2k_mother_in_law | חָמוֹת | chamot |
| 4 | 2026-06-03 | word_freq2k_parents | הוֹרִים | horim |
| 4 | 2026-06-03 | word_freq2k_baby_girl | תִּינוֹקֶת | tinoket |
| 4 | 2026-06-03 | word_freq2k_naara | נַעֲרָה | na'ara |
| 4 | 2026-06-03 | word_freq2k_neighbor_f | שְׁכֵנָה | shkhena |
| 4 | 2026-06-03 | word_freq2k_relative | קְרוֹב מִשְׁפָּחָה | krov mishpacha |
| 4 | 2026-06-03 | word_freq2k_widow | אַלְמָנָה | almana |
| 4 | 2026-06-03 | word_freq2k_divorced | גָּרוּשׁ | garush |
| 4 | 2026-06-03 | word_freq2k_nail | צִפֹּרֶן | tziporen |
| 4 | 2026-06-03 | word_freq2k_hips | מָתְנַיִם | motnayim |
| 4 | 2026-06-03 | word_freq2k_ankle | קַרְסֹל | karsol |
| 4 | 2026-06-03 | word_freq2k_lung | רֵאָה | rea |
| 4 | 2026-06-03 | word_freq2k_kidney | כִּלְיָה | kilya |
| 4 | 2026-06-03 | word_freq2k_stomach | קֵבָה | keva |
| 4 | 2026-06-03 | word_freq2k_muscle | שְׁרִיר | shrir |
| 4 | 2026-06-03 | word_freq2k_brain | מֹחַ | moach |
| 4 | 2026-06-03 | word_freq2k_flu | שַׁפַּעַת | shapaat |
| 4 | 2026-06-03 | word_freq2k_cold_illness | צִנּוּן | tzinun |
| 4 | 2026-06-03 | word_freq2k_headache | כְּאֵב רֹאשׁ | ke'ev rosh |
| 4 | 2026-06-03 | word_freq2k_cough | שִׁעוּל | shi'ul |
| 4 | 2026-06-03 | word_freq2k_nausea | בְּחִילָה | bechila |
| 4 | 2026-06-03 | word_freq2k_fracture | שֶׁבֶר | shever |
| 4 | 2026-06-03 | word_freq2k_pharmacy | בֵּית מִרְקַחַת | beit mirkachat |
| 4 | 2026-06-03 | word_freq2k_syringe | מַזְרֵק | mazrek |
| 4 | 2026-06-03 | word_freq2k_vaccination | חִסּוּן | chisun |
| 4 | 2026-06-03 | word_freq2k_diet | דִּיאֵטָה | dieta |
| 4 | 2026-06-03 | word_freq2k_shirt | חֻלְצָה | chultza |
| 4 | 2026-06-03 | word_freq2k_jeans | מִכְנְסֵי גִּ'ינְס | mikhnesei jeans |
| 4 | 2026-06-03 | word_freq2k_tshirt | חֻלְצַת טְרִיקוֹ | chultzat triko |
| 4 | 2026-06-03 | word_freq2k_jacket | גֶּ'קֶט | jeket |
| 4 | 2026-06-03 | word_freq2k_boots | מַגָּפַיִם | magafayim |
| 4 | 2026-06-03 | word_freq2k_sandals | סַנְדָּלִים | sandalim |
| 4 | 2026-06-03 | word_freq2k_sneakers | נַעֲלֵי סְפּוֹרְט | na'alei sport |
| 4 | 2026-06-03 | word_freq2k_tights | גַּרְבּוֹנִים | garbonim |
| 4 | 2026-06-03 | word_freq2k_tie | עֲנִיבָה | aniva |
| 4 | 2026-06-03 | word_freq2k_sunglasses | מִשְׁקְפֵי שֶׁמֶשׁ | mishkefei shemesh |
| 4 | 2026-06-03 | word_freq2k_earring | עָגִיל | agil |
| 4 | 2026-06-03 | word_freq2k_wristwatch | שָׁעוֹן יָד | sha'on yad |
| 4 | 2026-06-03 | word_freq2k_swimsuit | חֲלִיפַת יָם | chalifat yam |
| 4 | 2026-06-03 | word_freq2k_pajamas | פִּיגָ'מָה | pijama |
| 4 | 2026-06-03 | word_freq2k_bra | חֲזִיָּה | chaziya |
| 4 | 2026-06-03 | word_freq2k_wardrobe | אֲרוֹן בְּגָדִים | aron begadim |
| 3 | 2026-06-03 | word_freq2k_cool_adj | קָרִיר | karir |
| 3 | 2026-06-03 | word_freq2k_wet | רָטֹב | ratov |
| 3 | 2026-06-03 | word_freq2k_dirty | מְלֻכְלָךְ | melukhlakh |
| 3 | 2026-06-03 | word_freq2k_confused | מְבֻלְבָּל | mevulbal |
| 3 | 2026-06-03 | word_freq2k_boring | מְשַׁעֲמֵם | mesha'amem |
| 3 | 2026-06-03 | word_freq2k_complicated | מְסֻבָּךְ | mesubakh |
| 3 | 2026-06-03 | word_freq2k_famous | מְפֻרְסָם | mefursam |
| 3 | 2026-06-03 | word_freq2k_real | אֲמִיתִי | amiti |
| 3 | 2026-06-03 | word_freq2k_suitable | מַתְאִים | matim |
| 3 | 2026-06-03 | word_freq2k_similar | דּוֹמֶה | domeh |
| 3 | 2026-06-03 | word_freq2k_shared | מְשֻׁתָּף | meshutaf |
| 3 | 2026-06-03 | word_freq2k_whole_adj | שָׁלֵם | shalem |
| 3 | 2026-06-03 | word_freq2k_broken | שָׁבוּר | shavur |
| 3 | 2026-06-03 | word_freq2k_free_adj | חָפְשִׁי | chofshi |
| 3 | 2026-06-03 | word_freq2k_occupied | תָּפוּס | tafus |
| 3 | 2026-06-03 | word_freq2k_delicious | טָעִים | ta'im |
| 3 | 2026-06-03 | word_freq2k_ripe | בָּשֵׁל | bashel |
| 3 | 2026-06-03 | word_freq2k_polite | אַדִּיב | adiv |
| 3 | 2026-06-03 | word_freq2k_rude | גַּס | gas |
| 3 | 2026-06-03 | word_freq2k_stingy | קַמְצָן | kamtzan |
| 3 | 2026-06-03 | word_freq2k_coward | פַּחְדָן | pachdan |
| 3 | 2026-06-03 | word_freq2k_dangerous | מְסֻכָּן | mesukan |
| 3 | 2026-06-03 | word_freq2k_funny | מַצְחִיק | matzchik |
| 3 | 2026-06-03 | word_freq2k_rude_spirit | גַּס רוּחַ | gas ruach |
| 3 | 2026-06-03 | word_freq2k_stubborn | עָקֵב | aqev |
| 3 | 2026-06-03 | word_freq2k_lazy | עַצְלָן | atzlan |
| 3 | 2026-06-03 | word_freq2k_diligent | חָרוּץ | charutz |
| 3 | 2026-06-03 | word_freq2k_main_adj | עִקָּרִי | ikari |
| 3 | 2026-06-03 | word_freq2k_special | מְיֻחָד | meyuchad |
| 3 | 2026-06-03 | word_freq2k_wonderful | נֶהְדָּר | nehedar |
| 3 | 2026-06-03 | word_freq2k_hatred | שִׂנְאָה | sina |
| 3 | 2026-06-03 | word_freq2k_joy | שִׂמְחָה | simcha |
| 3 | 2026-06-03 | word_freq2k_sadness | עֶצֶב | etzev |
| 3 | 2026-06-03 | word_freq2k_anger | כַּעַס | ka'as |
| 3 | 2026-06-03 | word_freq2k_anxiety | חֲרָדָה | charada |
| 3 | 2026-06-03 | word_freq2k_worry | דְּאָגָה | de'aga |
| 3 | 2026-06-03 | word_freq2k_faith | אֱמוּנָה | emuna |
| 3 | 2026-06-03 | word_freq2k_confidence | בִּטָּחוֹן | bitachon |
| 3 | 2026-06-03 | word_freq2k_pride | גַּאֲוָה | ga'ava |
| 3 | 2026-06-03 | word_freq2k_shame | בּוּשָׁה | busha |
| 3 | 2026-06-03 | word_freq2k_disgrace | חֶרְפָּה | cherpa |
| 3 | 2026-06-03 | word_freq2k_enthusiasm | הִתְלַהֲבוּת | hitlahavut |
| 3 | 2026-06-03 | word_freq2k_feeling | הַרְגָּשָׁה | hargasha |
| 3 | 2026-06-03 | word_freq2k_fatigue | יְגִיעוּת | yegi'ut |
| 3 | 2026-06-03 | word_freq2k_rest | מְנוּחָה | menucha |
| 3 | 2026-06-03 | word_freq2k_desire | רָצוֹן | ratzon |
| 3 | 2026-06-03 | word_freq2k_sorrow | צַעַר | tza'ar |
| 3 | 2026-06-03 | word_freq2k_compassion | רַחֲמִים | rachamim |
| 3 | 2026-06-03 | word_freq2k_patience | סַבְלָנוּת | savlanut |
| 3 | 2026-06-03 | word_freq2k_tranquility | שַׁלְוָה | shalva |
| 2 | 2026-06-03 | word_freq2k_eizo | אֵיזוֹ | eizo |
| 2 | 2026-06-03 | word_freq2k_haim | הַאִם | ha'im |
| 2 | 2026-06-03 | word_freq2k_meat_meat | מְעַט מְעַט | me'at me'at |
| 2 | 2026-06-03 | word_freq2k_maspik | מַסְפִּיק | maspik |
| 2 | 2026-06-03 | word_freq2k_yoter | יוֹתֵר | yoter |
| 2 | 2026-06-03 | word_freq2k_pachot | פָּחוֹת | pachot |
| 2 | 2026-06-03 | word_freq2k_haki | הַכִּי | haki |
| 2 | 2026-06-03 | word_freq2k_beyoter | בְּיוֹתֵר | beyoter |
| 2 | 2026-06-03 | word_freq2k_kol_every | כָּל | kol |
| 2 | 2026-06-03 | word_freq2k_eizeshehu | אֵיזֶשֶׁהוּ | eizeshehu |
| 2 | 2026-06-03 | word_freq2k_eizoshehi | אֵיזוֹשֶׁהִי | eizoshehi |
| 2 | 2026-06-03 | word_freq2k_gray | אָפֹר | afor |
| 2 | 2026-06-03 | word_freq2k_purple | סָגֹל | sagol |
| 2 | 2026-06-03 | word_freq2k_beige | בֵּז' | bezh |
| 2 | 2026-06-03 | word_freq2k_turquoise | טֻרְקִיז | turkiz |
| 2 | 2026-06-03 | word_freq2k_burgundy | בּוּרְגּוּנְדִי | burgundi |
| 2 | 2026-06-03 | word_freq2k_shilshom | שִׁלְשׁוֹם | shilshom |
| 2 | 2026-06-03 | word_freq2k_mochrotayim | מָחֳרָתַיִם | mochrotayim |
| 2 | 2026-06-03 | word_freq2k_tzohorayim | צָהֳרַיִם | tzohorayim |
| 2 | 2026-06-03 | word_freq2k_afternoon | אַחַר הַצָּהֳרַיִם | achar hatzohorayim |
| 2 | 2026-06-03 | word_freq2k_chatzot | חֲצוֹת | chatzot |
| 2 | 2026-06-03 | word_freq2k_paam | פַּעַם | pa'am |
| 2 | 2026-06-03 | word_freq2k_achar_kakh | אַחַר כָּךְ | achar kakh |
| 2 | 2026-06-03 | word_freq2k_lifnei_khen | לִפְנֵי כֵן | lifnei khen |
| 2 | 2026-06-03 | word_freq2k_miyad | מִיָּד | miyad |
| 2 | 2026-06-03 | word_freq2k_bekarov | בְּקָרוֹב | bekarov |
| 2 | 2026-06-03 | word_freq2k_leat | לְאַט | le'at |
| 2 | 2026-06-03 | word_freq2k_maher | מַהֵר | maher |
| 2 | 2026-06-03 | word_freq2k_shabbat | שַׁבָּת | shabbat |
| 2 | 2026-06-03 | word_freq2k_stav | סְתָו | stav |
| 2 | 2026-06-03 | word_freq2k_life | חַיִּים | chayim |
| 2 | 2026-06-03 | word_freq2k_freedom | חֵרוּת | cherut |
| 2 | 2026-06-03 | word_freq2k_beauty | יֹפִי | yofi |
| 2 | 2026-06-03 | word_freq2k_power | כֹּחַ | koach |
| 2 | 2026-06-03 | word_freq2k_weakness | חֻלְשָׁה | chulsha |
| 2 | 2026-06-03 | word_freq2k_reason | סִבָּה | siba |
| 2 | 2026-06-03 | word_freq2k_difference | הֶבְדֵּל | hevdel |
| 2 | 2026-06-03 | word_freq2k_fact | עֻבְדָּה | uvda |
| 2 | 2026-06-03 | word_freq2k_information | מֵידָע | meda |
| 2 | 2026-06-03 | word_freq2k_point | נְקֻדָּה | nekuda |
| 2 | 2026-06-03 | word_freq2k_size | גֹּדֶל | godel |
| 2 | 2026-06-03 | word_freq2k_height | גֹּבַהּ | govah |
| 2 | 2026-06-03 | word_freq2k_length | אֹרֶךְ | orekh |
| 2 | 2026-06-03 | word_freq2k_distance | מֶרְחָק | merchak |
| 2 | 2026-06-03 | word_freq2k_type | סוּג | sug |
| 2 | 2026-06-03 | word_freq2k_thing | דָּבָר | davar |
| 2 | 2026-06-03 | word_freq2k_matter | עִנְיָן | inyan |
| 2 | 2026-06-03 | word_freq2k_subject | נוֹשֵׂא | nose |
| 2 | 2026-06-03 | word_freq2k_state | מַצָּב | matzav |
| 2 | 2026-06-03 | word_freq2k_change | שִׁנּוּי | shinui |
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
