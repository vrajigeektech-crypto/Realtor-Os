import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'dart:convert';

/// Deploy wallet schema functions directly to Supabase
/// Run this script to fix missing RPC functions
Future<void> main() async {
  // Read SQL files
  final schemaFile = File('create_new_wallet_schema.sql');
  final updateFile = File('update_wallet_commitments_logic.sql');
  
  if (!await schemaFile.exists()) {
    print('❌ create_new_wallet_schema.sql not found');
    return;
  }
  
  if (!await updateFile.exists()) {
    print('❌ update_wallet_commitments_logic.sql not found');
    return;
  }
  
  final schemaSql = await schemaFile.readAsString();
  final updateSql = await updateFile.readAsString();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://macenrukodfgfeowrqqf.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1hY2VucnVrb2RmZm93cnJxcWYiLCJpYXQiOjE3Mzc2MjM4MDAsImV4cCI6MjA1MzE4NzgwMH0.B1KqLrQ5wJnQzLxT9F3nYD8a2wJkX2v7s9X3fY2w',
  );
  
  final client = Supabase.instance.client;
  
  try {
    print('🔧 Deploying wallet schema...');
    
    // Execute schema SQL
    final schemaResult = await client.rpc('exec_sql', params: {
      'sql': schemaSql,
    });
    
    print('✅ Schema deployed: $schemaResult');
    
    // Execute update SQL
    final updateResult = await client.rpc('exec_sql', params: {
      'sql': updateSql,
    });
    
    print('✅ Updates deployed: $updateResult');
    
    print('🎉 Wallet schema deployment completed!');
    
  } catch (e) {
    print('❌ Deployment failed: $e');
    print('💡 You may need to run SQL manually in Supabase dashboard');
  }
}
