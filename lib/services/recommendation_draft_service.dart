import 'package:supabase_flutter/supabase_flutter.dart';

class RecommendationDraftService {
  static final RecommendationDraftService _instance =
      RecommendationDraftService._internal();
  factory RecommendationDraftService() => _instance;
  RecommendationDraftService._internal();

  final SupabaseClient _client = Supabase.instance.client;

  Future<Map<String, List<String>>> getDraftImagesForUser(String userId) async {
    final rows = await _client
        .from('recommendation_drafts')
        .select('recommendation_id, image_urls')
        .eq('user_id', userId);

    final map = <String, List<String>>{};
    for (final r in rows) {
      final id = (r['recommendation_id'] ?? '').toString();
      if (id.isEmpty) continue;
      final urls = (r['image_urls'] is List)
          ? List<String>.from(r['image_urls'] as List)
          : const <String>[];
      map[id] = urls;
    }
    return map;
  }

  Future<void> upsertDraftImages({
    required String userId,
    required String recommendationId,
    required List<String> imageUrls,
  }) async {
    await _client.from('recommendation_drafts').upsert({
      'user_id': userId,
      'recommendation_id': recommendationId,
      'image_urls': imageUrls,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deleteDraft({
    required String userId,
    required String recommendationId,
  }) async {
    await _client
        .from('recommendation_drafts')
        .delete()
        .eq('user_id', userId)
        .eq('recommendation_id', recommendationId);
  }
}

