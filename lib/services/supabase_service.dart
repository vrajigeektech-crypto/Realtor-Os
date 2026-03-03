import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'rpc_client.dart';

/// Singleton service for Supabase client and RPC access
class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  SupabaseService._();

  SupabaseClient? _client;
  RpcClient? _rpcClient;

  /// Initialize Supabase with URL and anon key
  /// Must be called before using any RPC methods
  Future<void> initialize({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) async {
    debugPrint('🔧 [Supabase] Initializing...');
    debugPrint('   URL: $supabaseUrl');
    debugPrint('   Anon Key: ${supabaseAnonKey.substring(0, 20)}...');
    
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      _client = Supabase.instance.client;
      _rpcClient = RpcClient();
      
      debugPrint('✅ [Supabase] Initialized successfully');
      
      // Check initial auth state
      final currentUser = _client!.auth.currentUser;
      final session = _client!.auth.currentSession;
      debugPrint('   Initial auth state:');
      debugPrint('   - User: ${currentUser?.email ?? "null"}');
      debugPrint('   - Session: ${session != null ? "exists" : "null"}');
    } catch (e, stackTrace) {
      debugPrint('❌ [Supabase] Initialization failed: $e');
      debugPrint('   Stack: $stackTrace');
      rethrow;
    }
  }

  /// Get the RPC client
  /// Throws if not initialized
  RpcClient get rpc {
    if (_rpcClient == null) {
      throw Exception(
        'SupabaseService not initialized. Call initialize() first.',
      );
    }
    return _rpcClient!;
  }

  /// Get the Supabase client directly (if needed)
  SupabaseClient get client {
    if (_client == null) {
      throw Exception(
        'SupabaseService not initialized. Call initialize() first.',
      );
    }
    return _client!;
  }
}
