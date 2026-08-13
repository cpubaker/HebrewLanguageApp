import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/services/feature_access_service.dart';

void main() {
  group('StaticFeatureAccessService', () {
    test('locks AI features when endpoint flags are false', () {
      final service = StaticFeatureAccessService();

      expect(service.isEnabled(AppFeature.aiWordContexts), isFalse);
      expect(service.isEnabled(AppFeature.aiPracticeTexts), isFalse);
      expect(service.isEnabled(AppFeature.nightMode), isTrue);
      expect(service.isEnabled(AppFeature.advancedPractice), isTrue);
      expect(service.isEnabled(AppFeature.extraLessons), isTrue);
    });

    test('unlocks AI features when their endpoint is configured', () {
      final service = StaticFeatureAccessService(
        aiContextsEndpointConfigured: true,
        aiPracticeTextsEndpointConfigured: true,
      );

      expect(service.isEnabled(AppFeature.aiWordContexts), isTrue);
      expect(service.isEnabled(AppFeature.aiPracticeTexts), isTrue);
    });

    test('treats AI endpoints independently', () {
      final service = StaticFeatureAccessService(
        aiContextsEndpointConfigured: true,
      );

      expect(service.isEnabled(AppFeature.aiWordContexts), isTrue);
      expect(service.isEnabled(AppFeature.aiPracticeTexts), isFalse);
    });

    test('accessFor identifies a locked AI feature', () {
      final service = StaticFeatureAccessService();

      final contextsDecision = service.accessFor(AppFeature.aiWordContexts);
      expect(contextsDecision.isEnabled, isFalse);
      expect(contextsDecision.feature, AppFeature.aiWordContexts);

      final textsDecision = service.accessFor(AppFeature.aiPracticeTexts);
      expect(textsDecision.isEnabled, isFalse);
      expect(textsDecision.feature, AppFeature.aiPracticeTexts);
    });

    test('accessFor identifies a locked Pro feature', () {
      final service = StaticFeatureAccessService(
        enabledFeatures: const <AppFeature>{},
      );

      final decision = service.accessFor(AppFeature.nightMode);
      expect(decision.isEnabled, isFalse);
      expect(decision.feature, AppFeature.nightMode);
    });

    test('respects explicit enabledFeatures override even when endpoint set', () {
      final service = StaticFeatureAccessService(
        enabledFeatures: const <AppFeature>{AppFeature.nightMode},
        aiContextsEndpointConfigured: true,
        aiPracticeTextsEndpointConfigured: true,
      );

      expect(service.isEnabled(AppFeature.aiWordContexts), isFalse);
      expect(service.isEnabled(AppFeature.aiPracticeTexts), isFalse);
      expect(service.isEnabled(AppFeature.nightMode), isTrue);
    });
  });
}
