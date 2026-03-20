import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'crm_connection_service.dart';
import 'followupboss_auth_service.dart';

/// Wraps the Follow Up Boss v1 People API.
///
/// Supports both connection methods:
///  - **API key**: stored as `access_token`, uses Basic auth (`base64(key:)`)
///  - **OAuth**:   stored as Bearer `access_token` + `refresh_token`, uses
///                `Authorization: Bearer <token>`, auto-refreshes on 401.
class FollowUpBossContactService {
  static const String _baseUrl = 'https://api.followupboss.com/v1';

  final CrmConnectionService _crmService;
  final FollowUpBossAuthService _authService;

  FollowUpBossContactService({
    CrmConnectionService? crmService,
    FollowUpBossAuthService? authService,
  })  : _crmService = crmService ?? CrmConnectionService(),
        _authService = authService ?? FollowUpBossAuthService();

  // ── auth resolution ─────────────────────────────────────────────────────────

  /// Returns the correct HTTP headers for the stored connection, refreshing
  /// the OAuth token first if it is expired or within 60 seconds of expiry.
  Future<Map<String, String>> _resolveAuthHeaders() async {
    final conn = await _crmService.getCrmConnectionByProvider('followupboss');

    final accessToken = conn['access_token'] as String?;
    final refreshToken = conn['refresh_token'] as String?;
    final expiresAtRaw = conn['expires_at'] as String?;
    final metadata = conn['metadata'] as Map<String, dynamic>?;
    final authMethod = metadata?['auth_method'] as String?;

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception(
        'Follow Up Boss is not connected. Please connect your account first.',
      );
    }

    // API key path — no refresh token, auth_method explicitly 'api_key'
    final isApiKey = authMethod == 'api_key' || refreshToken == null || refreshToken.isEmpty;
    if (isApiKey) {
      return _basicAuthHeaders(accessToken);
    }

    // OAuth path — check expiry, refresh if needed
    String liveToken = accessToken;
    if (expiresAtRaw != null) {
      final expiresAt = DateTime.tryParse(expiresAtRaw);
      final now = DateTime.now().toUtc();
      final almostExpired = expiresAt != null &&
          expiresAt.isBefore(now.add(const Duration(seconds: 60)));
      if (almostExpired) {
        debugPrint('🔄 [FUB Contacts] Token near expiry — refreshing...');
        liveToken = await _authService.refreshToken();
      }
    }

    return _bearerAuthHeaders(liveToken);
  }

  Map<String, String> _basicAuthHeaders(String apiKey) => {
        'Authorization': 'Basic ${base64Encode(utf8.encode('$apiKey:'))}',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Map<String, String> _bearerAuthHeaders(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // ── request helper ───────────────────────────────────────────────────────────

  /// Executes [call] with resolved auth headers. On a 401 response, refreshes
  /// the OAuth token once and retries. Re-throws on second failure.
  Future<http.Response> _send(
    Future<http.Response> Function(Map<String, String> headers) call,
  ) async {
    final headers = await _resolveAuthHeaders();
    final response = await call(headers);

    if (response.statusCode == 401) {
      // Try a forced refresh (covers the case where the token expired between
      // the expiry check and the actual API call)
      debugPrint('⚠️ [FUB Contacts] 401 received — attempting token refresh');
      try {
        final newToken = await _authService.refreshToken();
        return call(_bearerAuthHeaders(newToken));
      } catch (_) {
        // If refresh fails, return the original 401 so the caller can handle it
        return response;
      }
    }

    return response;
  }

  void _assertSuccess(http.Response response, String operation) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      debugPrint(
        '❌ [FUB Contacts] $operation failed (${response.statusCode}): ${response.body}',
      );
      throw Exception(
        '$operation failed with status ${response.statusCode}: ${response.body}',
      );
    }
  }

  // ── People ──────────────────────────────────────────────────────────────────

  /// Fetches a paginated list of people (contacts) from Follow Up Boss.
  Future<Map<String, dynamic>> getPeople({
    int limit = 20,
    int offset = 0,
    String? query,
  }) async {
    debugPrint('📡 [FUB Contacts] Fetching people (limit=$limit, offset=$offset)');

    final queryParams = <String, String>{
      'limit': '$limit',
      'offset': '$offset',
      if (query != null && query.isNotEmpty) 'q': query,
    };

    final uri = Uri.parse('$_baseUrl/people').replace(queryParameters: queryParams);

    final response = await _send((h) => http.get(uri, headers: h));
    _assertSuccess(response, 'getPeople');

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    debugPrint('✅ [FUB Contacts] Fetched ${(data['people'] as List?)?.length ?? 0} people');
    return data;
  }

  /// Fetches a single person by their Follow Up Boss [personId].
  Future<Map<String, dynamic>> getPersonById(int personId) async {
    debugPrint('📡 [FUB Contacts] Fetching person id=$personId');

    final uri = Uri.parse('$_baseUrl/people/$personId');
    final response = await _send((h) => http.get(uri, headers: h));
    _assertSuccess(response, 'getPersonById');

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    debugPrint('✅ [FUB Contacts] Fetched person: ${data['name']}');
    return data;
  }

  /// Creates a new contact in Follow Up Boss.
  Future<Map<String, dynamic>> createPerson({
    required String firstName,
    String? lastName,
    List<String> emails = const [],
    List<String> phones = const [],
    List<String> tags = const [],
    String? assignedTo,
    Map<String, dynamic> extraFields = const {},
  }) async {
    debugPrint('📡 [FUB Contacts] Creating person: $firstName $lastName');

    final body = <String, dynamic>{
      'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (emails.isNotEmpty) 'emails': emails.map((e) => {'value': e}).toList(),
      if (phones.isNotEmpty) 'phones': phones.map((p) => {'value': p}).toList(),
      if (tags.isNotEmpty) 'tags': tags,
      if (assignedTo != null) 'assignedTo': assignedTo,
      ...extraFields,
    };

    final uri = Uri.parse('$_baseUrl/people');
    final response = await _send(
      (h) => http.post(uri, headers: h, body: jsonEncode(body)),
    );
    _assertSuccess(response, 'createPerson');

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    debugPrint('✅ [FUB Contacts] Created person id=${data['id']}');
    return data;
  }

  /// Updates an existing contact by [personId] (PATCH semantics — only
  /// the fields present in [fields] are changed).
  Future<Map<String, dynamic>> updatePerson(
    int personId,
    Map<String, dynamic> fields,
  ) async {
    debugPrint('📡 [FUB Contacts] Updating person id=$personId');

    final uri = Uri.parse('$_baseUrl/people/$personId');
    final response = await _send(
      (h) => http.put(uri, headers: h, body: jsonEncode(fields)),
    );
    _assertSuccess(response, 'updatePerson');

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    debugPrint('✅ [FUB Contacts] Updated person id=$personId');
    return data;
  }

  /// Creates a note for an existing contact by [personId].
  ///
  /// [body] is the plain-text note content.
  Future<Map<String, dynamic>> createNote({
    required int personId,
    required String body,
  }) async {
    debugPrint('📡 [FUB Contacts] Creating note for person id=$personId');

    final uri = Uri.parse('$_baseUrl/notes');
    final payload = {'personId': personId, 'body': body};
    final response = await _send(
      (h) => http.post(uri, headers: h, body: jsonEncode(payload)),
    );
    _assertSuccess(response, 'createNote');

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    debugPrint('✅ [FUB Contacts] Created note id=${data['id']}');
    return data;
  }

  /// Deletes a contact by [personId].
  Future<void> deletePerson(int personId) async {
    debugPrint('📡 [FUB Contacts] Deleting person id=$personId');

    final uri = Uri.parse('$_baseUrl/people/$personId');
    final response = await _send((h) => http.delete(uri, headers: h));
    _assertSuccess(response, 'deletePerson');
    debugPrint('✅ [FUB Contacts] Deleted person id=$personId');
  }
}
