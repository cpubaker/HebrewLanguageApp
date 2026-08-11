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
  });

  final AppFeature feature;
  final bool isEnabled;
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
    return FeatureAccessDecision(
      feature: feature,
      isEnabled: isEnabled(feature),
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

}
