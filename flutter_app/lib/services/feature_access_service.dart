import 'package:flutter/foundation.dart';

enum AppFeature {
  nightMode,
  advancedPractice,
  extraLessons,
  aiWordContexts,
  aiPracticeTexts,
}

@immutable
class FeatureAccessDecision {
  const FeatureAccessDecision({
    required this.feature,
    required this.isEnabled,
    required this.title,
    required this.description,
    this.upgradeLabel = 'Перейти на Pro',
  });

  final AppFeature feature;
  final bool isEnabled;
  final String title;
  final String description;
  final String upgradeLabel;
}

abstract interface class FeatureAccessService {
  FeatureAccessDecision accessFor(AppFeature feature);

  bool isEnabled(AppFeature feature);
}

class StaticFeatureAccessService implements FeatureAccessService {
  const StaticFeatureAccessService({
    this.enabledFeatures = const <AppFeature>{
      AppFeature.nightMode,
      AppFeature.advancedPractice,
      AppFeature.extraLessons,
      AppFeature.aiWordContexts,
      AppFeature.aiPracticeTexts,
    },
  });

  final Set<AppFeature> enabledFeatures;

  @override
  FeatureAccessDecision accessFor(AppFeature feature) {
    final metadata = _metadataFor(feature);
    return FeatureAccessDecision(
      feature: feature,
      isEnabled: enabledFeatures.contains(feature),
      title: metadata.title,
      description: metadata.description,
    );
  }

  @override
  bool isEnabled(AppFeature feature) {
    return enabledFeatures.contains(feature);
  }

  _FeatureAccessMetadata _metadataFor(AppFeature feature) {
    return switch (feature) {
      AppFeature.nightMode => const _FeatureAccessMetadata(
        title: 'Нічний режим',
        description: 'Нічний режим доступний у Pro-версії.',
      ),
      AppFeature.advancedPractice => const _FeatureAccessMetadata(
        title: 'Розширена практика',
        description: 'Розширені режими практики доступні у Pro-версії.',
      ),
      AppFeature.extraLessons => const _FeatureAccessMetadata(
        title: 'Додаткові уроки',
        description: 'Додаткові набори уроків доступні у Pro-версії.',
      ),
      AppFeature.aiWordContexts => const _FeatureAccessMetadata(
        title: 'ШІ-контексти слів',
        description: 'ШІ-контексти для слів доступні у Pro-версії.',
      ),
      AppFeature.aiPracticeTexts => const _FeatureAccessMetadata(
        title: 'ШІ-тексти для практики',
        description: 'ШІ-тексти для практики доступні у Pro-версії.',
      ),
    };
  }
}

class _FeatureAccessMetadata {
  const _FeatureAccessMetadata({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;
}
