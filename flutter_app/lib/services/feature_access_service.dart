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
    this.upgradeLabel = '',
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
  StaticFeatureAccessService({
    Set<AppFeature>? enabledFeatures,
    this.aiContextsEndpointConfigured = false,
    this.aiPracticeTextsEndpointConfigured = false,
  }) : _baseEnabledFeatures = enabledFeatures ?? _kBaseEnabledFeatures;

  static const Set<AppFeature> _kBaseEnabledFeatures = <AppFeature>{
    AppFeature.nightMode,
    AppFeature.advancedPractice,
    AppFeature.extraLessons,
    AppFeature.aiWordContexts,
    AppFeature.aiPracticeTexts,
  };

  final Set<AppFeature> _baseEnabledFeatures;
  final bool aiContextsEndpointConfigured;
  final bool aiPracticeTextsEndpointConfigured;

  @override
  FeatureAccessDecision accessFor(AppFeature feature) {
    final metadata = _metadataFor(feature);
    return FeatureAccessDecision(
      feature: feature,
      isEnabled: isEnabled(feature),
      title: metadata.title,
      description: metadata.description,
      upgradeLabel: metadata.upgradeLabel,
    );
  }

  @override
  bool isEnabled(AppFeature feature) {
    if (!_baseEnabledFeatures.contains(feature)) {
      return false;
    }
    return switch (feature) {
      AppFeature.aiWordContexts => aiContextsEndpointConfigured,
      AppFeature.aiPracticeTexts => aiPracticeTextsEndpointConfigured,
      _ => true,
    };
  }

  _FeatureAccessMetadata _metadataFor(AppFeature feature) {
    return switch (feature) {
      AppFeature.nightMode => const _FeatureAccessMetadata(
        title: 'Нічний режим',
        description: 'Нічний режим доступний у Pro-версії.',
        upgradeLabel: 'Перейти на Pro',
      ),
      AppFeature.advancedPractice => const _FeatureAccessMetadata(
        title: 'Розширена практика',
        description: 'Розширені режими практики доступні у Pro-версії.',
        upgradeLabel: 'Перейти на Pro',
      ),
      AppFeature.extraLessons => const _FeatureAccessMetadata(
        title: 'Додаткові уроки',
        description: 'Додаткові набори уроків доступні у Pro-версії.',
        upgradeLabel: 'Перейти на Pro',
      ),
      AppFeature.aiWordContexts => const _FeatureAccessMetadata(
        title: 'ШІ-контексти слів',
        description: 'AI-функції готуються до запуску. Скоро з\'являться.',
      ),
      AppFeature.aiPracticeTexts => const _FeatureAccessMetadata(
        title: 'ШІ-тексти для практики',
        description: 'AI-функції готуються до запуску. Скоро з\'являться.',
      ),
    };
  }
}

class _FeatureAccessMetadata {
  const _FeatureAccessMetadata({
    required this.title,
    required this.description,
    this.upgradeLabel = '',
  });

  final String title;
  final String description;
  final String upgradeLabel;
}
