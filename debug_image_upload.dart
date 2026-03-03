// =====================================================
// DEBUG IMAGE UPLOAD - Run this to test upload issues
// Add this to your Flutter app and call from a button
// =====================================================

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';

class DebugImageUpload {
  static Future<void> debugUploadProcess() async {
    debugPrint('🔍 [DEBUG] Starting image upload debug...');
    
    try {
      // 1. Check Supabase client
      final supabase = Supabase.instance.client;
      debugPrint('✅ [DEBUG] Supabase client initialized');
      
      // 2. Check authentication
      final user = supabase.auth.currentUser;
      if (user == null) {
        debugPrint('❌ [DEBUG] User not authenticated');
        return;
      }
      debugPrint('✅ [DEBUG] User authenticated: ${user.email}');
      debugPrint('✅ [DEBUG] User ID: ${user.id}');
      
      // 3. Check if bucket exists (this will show the error)
      try {
        final bucket = supabase.storage.from('user_assets');
        debugPrint('✅ [DEBUG] Bucket reference created');
        
        // Try to list files (this tests permissions)
        final files = await bucket.list();
        debugPrint('✅ [DEBUG] Can list files: ${files.length} files found');
      } catch (e) {
        debugPrint('❌ [DEBUG] Bucket access failed: $e');
        debugPrint('❌ [DEBUG] This means bucket doesn\'t exist or no permissions');
        return;
      }
      
      // 4. Test file picker
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );
      
      if (result == null || result.files.isEmpty) {
        debugPrint('❌ [DEBUG] No file selected');
        return;
      }
      
      final file = result.files.first;
      if (file.bytes == null) {
        debugPrint('❌ [DEBUG] File bytes null - file too large?');
        return;
      }
      
      debugPrint('✅ [DEBUG] File selected: ${file.name}');
      debugPrint('✅ [DEBUG] File size: ${file.bytes!.length} bytes');
      
      // 5. Test upload
      final bucket = supabase.storage.from('user_assets');
      final path = '${user.id}/debug_test.png';
      
      debugPrint('📤 [DEBUG] Uploading to: $path');
      
      await bucket.uploadBinary(
        path,
        file.bytes!,
        fileOptions: FileOptions(
          contentType: 'image/png',
          upsert: true,
        ),
      );
      
      debugPrint('✅ [DEBUG] Upload successful!');
      
      // 6. Test public URL
      final publicUrl = bucket.getPublicUrl(path);
      debugPrint('✅ [DEBUG] Public URL: $publicUrl');
      
      // 7. Test saving to database
      await supabase
          .from('users')
          .update({'gallery_urls': [publicUrl]})
          .eq('id', user.id);
      
      debugPrint('✅ [DEBUG] URLs saved to database');
      
      // 8. Test RPC function
      await supabase.rpc(
        'complete_onboarding_step',
        params: {'p_step': 'upload_selfies', 'p_user_id': user.id},
      );
      
      debugPrint('✅ [DEBUG] RPC function called successfully');
      debugPrint('🎉 [DEBUG] Complete upload process works!');
      
    } catch (e, stackTrace) {
      debugPrint('❌ [DEBUG] Error: $e');
      debugPrint('❌ [DEBUG] Stack trace: $stackTrace');
    }
  }
  
  static Future<void> checkDatabaseSetup() async {
    debugPrint('🔍 [DEBUG] Checking database setup...');
    
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      
      if (user == null) {
        debugPrint('❌ [DEBUG] Not authenticated');
        return;
      }
      
      // Check users table
      final userData = await supabase
          .from('users')
          .select('id, email, gallery_urls, onboarding_completed, onboarding_step')
          .eq('id', user.id)
          .single();
      
      debugPrint('✅ [DEBUG] User data: $userData');
      
      // Check RPC function exists
      try {
        await supabase.rpc('complete_onboarding_step', params: {'p_step': 'test'});
        debugPrint('✅ [DEBUG] RPC function exists');
      } catch (e) {
        debugPrint('❌ [DEBUG] RPC function error: $e');
      }
      
    } catch (e) {
      debugPrint('❌ [DEBUG] Database check error: $e');
    }
  }
}

// HOW TO USE:
// 1. Add this file to your lib/ folder
// 2. Import it where you want to test
// 3. Call DebugImageUpload.debugUploadProcess() from a button
// 4. Call DebugImageUpload.checkDatabaseSetup() to verify setup
// 5. Check the debug console for detailed output
