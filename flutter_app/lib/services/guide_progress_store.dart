import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/guide_lesson_status.dart';

abstract class GuideProgressStore {
  Future<Map<String, GuideLessonStatus>> loadLessonStatuses();

  Future<void> setLessonStatus(
    String assetPath,
    GuideLessonStatus status,
  );
}

class SharedPreferencesGuideProgressStore implements GuideProgressStore {
  static const String _legacyReadLessonsKey = 'guide_read_lessons_v1';
  static const String _storageKey = 'guide_lesson_statuses_v2';
  static const Map<String, String> _renamedGuidePaths = <String, String>{
    'assets/learning/input/guide/08_verbs_intro.md':
        'assets/learning/input/guide/20_verbs_intro.md',
    'assets/learning/input/guide/09_more_on_verbs.md':
        'assets/learning/input/guide/21_more_on_verbs.md',
    'assets/learning/input/guide/10_negation_and_questions.md':
        'assets/learning/input/guide/14_negation_and_questions.md',
    'assets/learning/input/guide/11_more_on_questions.md':
        'assets/learning/input/guide/15_more_on_questions.md',
    'assets/learning/input/guide/12_personal_pronouns.md':
        'assets/learning/input/guide/08_personal_pronouns.md',
    'assets/learning/input/guide/13_nominal_sentences.md':
        'assets/learning/input/guide/09_nominal_sentences.md',
    'assets/learning/input/guide/14_possession.md':
        'assets/learning/input/guide/10_possession.md',
    'assets/learning/input/guide/15_shel_possession.md':
        'assets/learning/input/guide/11_shel_possession.md',
    'assets/learning/input/guide/16_et_direct_object.md':
        'assets/learning/input/guide/12_et_direct_object.md',
    'assets/learning/input/guide/17_word_order.md':
        'assets/learning/input/guide/13_word_order.md',
    'assets/learning/input/guide/18_numbers.md':
        'assets/learning/input/guide/16_numbers.md',
    'assets/learning/input/guide/19_time_dates.md':
        'assets/learning/input/guide/17_time_dates.md',
    'assets/learning/input/guide/20_past_tense_intro.md':
        'assets/learning/input/guide/22_past_tense_intro.md',
    'assets/learning/input/guide/21_future_tense_intro.md':
        'assets/learning/input/guide/23_future_tense_intro.md',
    'assets/learning/input/guide/22_modal_verbs.md':
        'assets/learning/input/guide/25_modal_verbs.md',
    'assets/learning/input/guide/23_basic_prepositions.md':
        'assets/learning/input/guide/18_basic_prepositions.md',
    'assets/learning/input/guide/24_prepositions_with_suffixes.md':
        'assets/learning/input/guide/19_prepositions_with_suffixes.md',
    'assets/learning/input/guide/25_imperative_requests.md':
        'assets/learning/input/guide/26_imperative_requests.md',
    'assets/learning/input/guide/26_connectors_and_story_flow.md':
        'assets/learning/input/guide/37_connectors_and_story_flow.md',
    'assets/learning/input/guide/27_three_tenses_compared.md':
        'assets/learning/input/guide/24_three_tenses_compared.md',
    'assets/learning/input/guide/28_irregular_common_verbs.md':
        'assets/learning/input/guide/31_irregular_common_verbs.md',
    'assets/learning/input/guide/29_gender_sound_changes.md':
        'assets/learning/input/guide/32_gender_sound_changes.md',
    'assets/learning/input/guide/30_typical_mistakes_ukrainians.md':
        'assets/learning/input/guide/36_typical_mistakes_ukrainians.md',
    'assets/learning/input/guide/31_verb_system_root_binyanim.md':
        'assets/learning/input/guide/27_verb_system_root_binyanim.md',
    'assets/learning/input/guide/32_past_tense_patterns.md':
        'assets/learning/input/guide/29_past_tense_patterns.md',
    'assets/learning/input/guide/33_future_tense_patterns.md':
        'assets/learning/input/guide/30_future_tense_patterns.md',
    'assets/learning/input/guide/34_subordinate_clauses_basics.md':
        'assets/learning/input/guide/38_subordinate_clauses_basics.md',
    'assets/learning/input/guide/35_relative_and_she.md':
        'assets/learning/input/guide/39_relative_and_she.md',
    'assets/learning/input/guide/36_comparison_and_degrees.md':
        'assets/learning/input/guide/41_comparison_and_degrees.md',
    'assets/learning/input/guide/37_extended_numbers_and_ordinals.md':
        'assets/learning/input/guide/42_extended_numbers_and_ordinals.md',
    'assets/learning/input/guide/38_extended_prepositions_space_time.md':
        'assets/learning/input/guide/43_extended_prepositions_space_time.md',
    'assets/learning/input/guide/39_adverbs_and_particles.md':
        'assets/learning/input/guide/44_adverbs_and_particles.md',
    'assets/learning/input/guide/40_present_tense_patterns.md':
        'assets/learning/input/guide/28_present_tense_patterns.md',
    'assets/learning/input/guide/41_et_with_pronoun_objects.md':
        'assets/learning/input/guide/33_et_with_pronoun_objects.md',
    'assets/learning/input/guide/42_infinitive_constructions.md':
        'assets/learning/input/guide/34_infinitive_constructions.md',
    'assets/learning/input/guide/43_construct_state_advanced.md':
        'assets/learning/input/guide/45_construct_state_advanced.md',
    'assets/learning/input/guide/44_question_particles_and_intonation.md':
        'assets/learning/input/guide/57_question_particles_and_intonation.md',
    'assets/learning/input/guide/45_conversation_fillers_and_discourse_markers.md':
        'assets/learning/input/guide/58_conversation_fillers_and_discourse_markers.md',
    'assets/learning/input/guide/46_common_verb_preposition_pairs.md':
        'assets/learning/input/guide/35_common_verb_preposition_pairs.md',
    'assets/learning/input/guide/47_relative_clause_expansion.md':
        'assets/learning/input/guide/39_relative_and_she.md',
    'assets/learning/input/guide/48_negation_advanced.md':
        'assets/learning/input/guide/40_negation_advanced.md',
    'assets/learning/input/guide/49_register_formal_vs_spoken.md':
        'assets/learning/input/guide/59_register_formal_vs_spoken.md',
    'assets/learning/input/guide/50_perception_thought_speech_patterns.md':
        'assets/learning/input/guide/63_perception_thought_speech_patterns.md',
    'assets/learning/input/guide/51_cause_result_concession.md':
        'assets/learning/input/guide/65_cause_result_concession.md',
    'assets/learning/input/guide/52_conditions_beyond_basic_im.md':
        'assets/learning/input/guide/66_conditions_beyond_basic_im.md',
    'assets/learning/input/guide/53_bookish_vs_natural_syntax.md':
        'assets/learning/input/guide/60_bookish_vs_natural_syntax.md',
    'assets/learning/input/guide/54_being_existence_beyond_present.md':
        'assets/learning/input/guide/46_being_existence_beyond_present.md',
    'assets/learning/input/guide/55_dative_experiencer_patterns.md':
        'assets/learning/input/guide/47_dative_experiencer_patterns.md',
    'assets/learning/input/guide/56_passive_reflexive_real_usage.md':
        'assets/learning/input/guide/50_passive_reflexive_real_usage.md',
    'assets/learning/input/guide/57_infinitive_purpose_and_clause_choice.md':
        'assets/learning/input/guide/49_infinitive_purpose_and_clause_choice.md',
    'assets/learning/input/guide/58_word_order_focus_and_emphasis.md':
        'assets/learning/input/guide/51_word_order_focus_and_emphasis.md',
    'assets/learning/input/guide/59_predicative_words_and_complements.md':
        'assets/learning/input/guide/48_predicative_words_and_complements.md',
    'assets/learning/input/guide/60_action_timing_and_phase.md':
        'assets/learning/input/guide/52_action_timing_and_phase.md',
    'assets/learning/input/guide/61_motion_direction_and_transfer.md':
        'assets/learning/input/guide/53_motion_direction_and_transfer.md',
    'assets/learning/input/guide/62_change_of_state_and_result.md':
        'assets/learning/input/guide/54_change_of_state_and_result.md',
    'assets/learning/input/guide/63_soft_requests_and_polite_mitigation.md':
        'assets/learning/input/guide/56_soft_requests_and_polite_mitigation.md',
    'assets/learning/input/guide/64_phone_service_and_help_patterns.md':
        'assets/learning/input/guide/61_phone_service_and_help_patterns.md',
    'assets/learning/input/guide/65_chat_coordination_and_followup_patterns.md':
        'assets/learning/input/guide/62_chat_coordination_and_followup_patterns.md',
    'assets/learning/input/guide/66_social_formulas_and_everyday_politeness.md':
        'assets/learning/input/guide/55_social_formulas_and_everyday_politeness.md',
    'assets/learning/input/guide/67_uncertainty_agreement_and_soft_disagreement.md':
        'assets/learning/input/guide/64_uncertainty_agreement_and_soft_disagreement.md',
    'assets/learning/input/guide/68_quantity_approximation_and_scope.md':
        'assets/learning/input/guide/67_quantity_approximation_and_scope.md',
    'assets/learning/input/guide/69_formal_writing_email_and_requests.md':
        'assets/learning/input/guide/73_formal_writing_email_and_requests.md',
    'assets/learning/input/guide/70_position_argument_and_stance_markers.md':
        'assets/learning/input/guide/68_position_argument_and_stance_markers.md',
    'assets/learning/input/guide/71_clarification_reformulation_and_precision.md':
        'assets/learning/input/guide/69_clarification_reformulation_and_precision.md',
    'assets/learning/input/guide/72_examples_evidence_and_supporting_points.md':
        'assets/learning/input/guide/70_examples_evidence_and_supporting_points.md',
    'assets/learning/input/guide/73_comparing_options_tradeoffs_and_preferences.md':
        'assets/learning/input/guide/71_comparing_options_tradeoffs_and_preferences.md',
    'assets/learning/input/guide/74_constraints_requirements_and_priorities.md':
        'assets/learning/input/guide/72_constraints_requirements_and_priorities.md',
    'assets/learning/input/guide/77_followups_attachments_status_and_reminders.md':
        'assets/learning/input/guide/74_followups_attachments_status_and_reminders.md',
  };

  @override
  Future<Map<String, GuideLessonStatus>> loadLessonStatuses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedStatuses = prefs.getString(_storageKey);
      if (storedStatuses != null && storedStatuses.trim().isNotEmpty) {
        return _decodeStatuses(storedStatuses);
      }

      return _loadLegacyReadLessons(prefs);
    } catch (error) {
      debugPrint(
        'Ignoring guide progress for $_storageKey because it could not be loaded: $error',
      );
      return <String, GuideLessonStatus>{};
    }
  }

  @override
  Future<void> setLessonStatus(
    String assetPath,
    GuideLessonStatus status,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final storedStatuses = await loadLessonStatuses();
    final sanitizedAssetPath = _canonicalGuideAssetPath(assetPath);
    if (sanitizedAssetPath.isEmpty) {
      return;
    }

    if (status == GuideLessonStatus.unread) {
      storedStatuses.remove(sanitizedAssetPath);
    } else {
      storedStatuses[sanitizedAssetPath] = status;
    }

    final encodedStatuses = <String, String>{
      for (final entry in storedStatuses.entries)
        entry.key: entry.value.storageValue,
    };

    await prefs.setString(_storageKey, jsonEncode(encodedStatuses));
  }

  Map<String, GuideLessonStatus> _decodeStatuses(String rawPayload) {
    final decodedPayload = jsonDecode(rawPayload);
    if (decodedPayload is! Map) {
      return <String, GuideLessonStatus>{};
    }

    final statuses = <String, GuideLessonStatus>{};
    for (final entry in decodedPayload.entries) {
      final rawPath = entry.key?.toString().trim() ?? '';
      final rawStatus = entry.value?.toString() ?? '';
      final status = GuideLessonStatus.fromStorageValue(rawStatus);
      final canonicalPath = _canonicalGuideAssetPath(rawPath);
      if (canonicalPath.isEmpty ||
          status == null ||
          status == GuideLessonStatus.unread) {
        continue;
      }

      statuses[canonicalPath] = _mergeStatus(statuses[canonicalPath], status);
    }

    return statuses;
  }

  Map<String, GuideLessonStatus> _loadLegacyReadLessons(
    SharedPreferences prefs,
  ) {
    final storedLessons =
        prefs.getStringList(_legacyReadLessonsKey) ?? const <String>[];
    final statuses = <String, GuideLessonStatus>{};
    for (final lessonPath in storedLessons) {
      final canonicalPath = _canonicalGuideAssetPath(lessonPath);
      if (canonicalPath.isEmpty) {
        continue;
      }

      statuses[canonicalPath] = _mergeStatus(
        statuses[canonicalPath],
        GuideLessonStatus.read,
      );
    }

    return statuses;
  }

  String _canonicalGuideAssetPath(String rawPath) {
    final sanitizedPath = rawPath.trim();
    if (sanitizedPath.isEmpty) {
      return '';
    }

    return _renamedGuidePaths[sanitizedPath] ?? sanitizedPath;
  }

  GuideLessonStatus _mergeStatus(
    GuideLessonStatus? existing,
    GuideLessonStatus incoming,
  ) {
    if (existing == null) {
      return incoming;
    }

    if (existing == GuideLessonStatus.read ||
        incoming == GuideLessonStatus.read) {
      return GuideLessonStatus.read;
    }

    if (existing == GuideLessonStatus.studying ||
        incoming == GuideLessonStatus.studying) {
      return GuideLessonStatus.studying;
    }

    return incoming;
  }
}
