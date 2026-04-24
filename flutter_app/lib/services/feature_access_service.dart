import 'package:flutter/foundation.dart';

enum AppFeature { nightMode, advancedPractice, extraLessons, aiWordContexts }

@immutable
class FeatureAccessDecision {
  const FeatureAccessDecision({
    required this.feature,
    required this.isEnabled,
    required this.title,
    required this.description,
    this.upgradeLabel = 'Upgrade to Pro',
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
        title: 'Night mode',
        description: 'Night mode is available in the Pro version.',
      ),
      AppFeature.advancedPractice => const _FeatureAccessMetadata(
        title: 'Advanced practice',
        description: 'Advanced practice modes are available in Pro.',
      ),
      AppFeature.extraLessons => const _FeatureAccessMetadata(
        title: 'Extra lessons',
        description: 'Extra lesson packs are available in Pro.',
      ),
      AppFeature.aiWordContexts => const _FeatureAccessMetadata(
        title: 'AI word contexts',
        description: 'AI-generated word contexts are available in Pro.',
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
