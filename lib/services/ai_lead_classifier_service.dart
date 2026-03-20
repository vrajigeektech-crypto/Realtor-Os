// AI-powered lead classification service.
//
// Sends contact data to the `lead-classify` Supabase Edge Function which
// uses an LLM (GPT-4o-mini) to produce structured output:
//   { intent, urgency, budget, category, bucket, confidence, reason }
//
// Falls back to the local rule-based [LeadClassifier] if the edge function
// is unavailable, returns an error, or the OpenAI key is not configured.

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'lead_classifier.dart';

class AiLeadClassifierService {
  static const _functionName = 'lead-classify';

  /// Maximum contacts sent per AI batch (keeps prompt cost reasonable).
  static const _batchSize = 50;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Classify [contacts] using AI. Attaches `'_classification'` to each map
  /// in-place. Falls back to rule-based scoring when AI is unavailable.
  ///
  /// Returns the same [contacts] list for convenience.
  static Future<List<Map<String, dynamic>>> classifyAll(
    List<Map<String, dynamic>> contacts,
  ) async {
    if (contacts.isEmpty) return contacts;

    final unclassified = contacts
        .where((c) => c['_classification'] == null)
        .toList();

    try {
      // Process in batches so we stay under function timeout limits.
      for (int i = 0; i < unclassified.length; i += _batchSize) {
        final batch = unclassified.skip(i).take(_batchSize).toList();
        final results = await _callAiFunction(batch);
        _mergeAiResults(batch, results);
      }
      debugPrint(
          '✅ [AI Classifier] Classified ${unclassified.length} contacts via AI');
    } catch (e) {
      debugPrint(
          '⚠️ [AI Classifier] AI unavailable ($e) — using rule-based fallback');
      // Apply rule-based classifier only to contacts that were not yet tagged.
      for (final c in unclassified) {
        if (c['_classification'] == null) {
          c['_classification'] = LeadClassifier.classify(c);
        }
      }
    }

    return contacts;
  }

  // ---------------------------------------------------------------------------
  // Edge-function call
  // ---------------------------------------------------------------------------

  static Future<List<Map<String, dynamic>>> _callAiFunction(
    List<Map<String, dynamic>> contacts,
  ) async {
    final supabase = Supabase.instance.client;

    // Build slim payload — only the fields the prompt needs.
    final slim = contacts.map(_slim).toList();

    final response = await supabase.functions.invoke(
      _functionName,
      body: {'contacts': slim},
    );

    if (response.status != 200) {
      throw Exception(
          'lead-classify function returned status ${response.status}');
    }

    final data = response.data as Map<String, dynamic>;
    return (data['results'] as List).cast<Map<String, dynamic>>();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static Map<String, dynamic> _slim(Map<String, dynamic> c) => {
        'name':
            '${c['firstName'] ?? ''} ${c['lastName'] ?? ''}'.trim(),
        'stage': c['stage'],
        'tags': c['tags'],
        'source': c['source'],
        'emails': c['emails'],
        'phones': c['phones'],
        'lastActivity': c['lastActivity'] ?? c['updated'],
        'created': c['created'],
        'notes': c['backgroundInfo'] ?? c['notes'],
      };

  static void _mergeAiResults(
    List<Map<String, dynamic>> contacts,
    List<Map<String, dynamic>> aiResults,
  ) {
    for (int i = 0; i < contacts.length && i < aiResults.length; i++) {
      final ai = aiResults[i];
      final bucket = _parseBucket(ai['bucket'] as String? ?? 'cold');
      final confidence = (ai['confidence'] as num?)?.toInt() ?? 50;
      final reason = ai['reason'] as String? ?? '';

      contacts[i]['_classification'] = LeadClassification(
        bucket: bucket,
        confidence: confidence,
        signals: reason.isNotEmpty ? [reason] : [],
        intent: ai['intent'] as String? ?? 'unknown',
        urgency: ai['urgency'] as String? ?? 'medium',
        budget: ai['budget'] as String? ?? 'unknown',
        category: ai['category'] as String? ?? 'unknown',
        aiClassified: true,
      );
    }
  }

  static LeadBucket _parseBucket(String s) => switch (s.toLowerCase()) {
        'hot' => LeadBucket.hot,
        'warm' => LeadBucket.warm,
        'junk' => LeadBucket.junk,
        _ => LeadBucket.cold,
      };
}
