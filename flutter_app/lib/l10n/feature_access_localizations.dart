import '../services/feature_access_service.dart';
import 'generated/app_localizations.dart';

extension FeatureAccessDecisionLocalization on FeatureAccessDecision {
  String localizedTitle(AppLocalizations localizations) {
    return switch (feature) {
      AppFeature.nightMode => localizations.featureNightModeTitle,
      AppFeature.advancedPractice => localizations.featureAdvancedPracticeTitle,
      AppFeature.extraLessons => localizations.featureExtraLessonsTitle,
      AppFeature.aiWordContexts => localizations.featureAiContextsTitle,
      AppFeature.aiPracticeTexts => localizations.featureAiTextsTitle,
    };
  }

  String localizedDescription(AppLocalizations localizations) {
    return switch (feature) {
      AppFeature.nightMode => localizations.featureNightModeDescription,
      AppFeature.advancedPractice => localizations.featureAdvancedPracticeDescription,
      AppFeature.extraLessons => localizations.featureExtraLessonsDescription,
      AppFeature.aiWordContexts || AppFeature.aiPracticeTexts =>
        localizations.featureAiDescription,
    };
  }

  String get localizedUpgradeKey => switch (feature) {
    AppFeature.nightMode || AppFeature.advancedPractice || AppFeature.extraLessons => 'pro',
    AppFeature.aiWordContexts || AppFeature.aiPracticeTexts => '',
  };
}
