import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recommendation_models.dart';
import '../services/wallet_dashboard_service.dart';

class RecommendationService {
  static final RecommendationService _instance = RecommendationService._internal();
  factory RecommendationService() => _instance;
  RecommendationService._internal();

  final List<PromotionItem> _mockPromotions = [
    PromotionItem(
      id: 'linkedin_post',
      title: 'LinkedIn Post Promotion',
      description: 'Promote your listing on LinkedIn with professional targeting',
      tokenCost: 10,
      category: 'Social Media',
      icon: '💼',
      tags: ['professional', 'networking', 'business'],
      popularityScore: 85,
      isFeatured: true,
    ),
    PromotionItem(
      id: 'tiktok_video',
      title: 'TikTok Video Promotion',
      description: 'Create viral TikTok content for your property listing',
      tokenCost: 15,
      category: 'Social Media',
      icon: '🎵',
      tags: ['viral', 'video', 'young_audience'],
      popularityScore: 92,
    ),
    PromotionItem(
      id: 'featured_listing',
      title: 'Featured Listing Boost',
      description: 'Get your property featured on the homepage for 7 days',
      tokenCost: 20,
      category: 'Platform',
      icon: '🏡',
      tags: ['visibility', 'premium', 'homepage'],
      popularityScore: 78,
      isFeatured: true,
    ),
    PromotionItem(
      id: 'social_blast',
      title: 'Social Media Blast',
      description: 'Post across all major social media platforms simultaneously',
      tokenCost: 12,
      category: 'Social Media',
      icon: '📸',
      tags: ['multi_platform', 'reach', 'exposure'],
      popularityScore: 88,
    ),
    PromotionItem(
      id: 'premium_visibility',
      title: 'Premium Visibility Upgrade',
      description: 'Enhanced listing with premium placement and badges',
      tokenCost: 25,
      category: 'Platform',
      icon: '⭐',
      tags: ['premium', 'placement', 'badges'],
      popularityScore: 95,
      isFeatured: true,
    ),
    PromotionItem(
      id: 'instagram_story',
      title: 'Instagram Story Campaign',
      description: 'Professional Instagram stories with swipe-up links',
      tokenCost: 8,
      category: 'Social Media',
      icon: '📱',
      tags: ['visual', 'stories', 'engagement'],
      popularityScore: 76,
    ),
    PromotionItem(
      id: 'facebook_boost',
      title: 'Facebook Ad Boost',
      description: 'Targeted Facebook advertising for your listing',
      tokenCost: 18,
      category: 'Social Media',
      icon: '📘',
      tags: ['targeted', 'facebook', 'ads'],
      popularityScore: 82,
    ),
    PromotionItem(
      id: 'youtube_tour',
      title: 'YouTube Video Tour',
      description: 'Professional video tour uploaded to YouTube',
      tokenCost: 30,
      category: 'Video',
      icon: '🎥',
      tags: ['video', 'professional', 'tour'],
      popularityScore: 90,
    ),
    PromotionItem(
      id: 'email_blast',
      title: 'Email Campaign Blast',
      description: 'Send your listing to 10,000 potential buyers',
      tokenCost: 14,
      category: 'Email',
      icon: '📧',
      tags: ['email', 'campaign', 'direct'],
      popularityScore: 70,
    ),
    PromotionItem(
      id: 'google_ads',
      title: 'Google Ads Campaign',
      description: 'Top Google search placement for relevant keywords',
      tokenCost: 35,
      category: 'Search',
      icon: '🔍',
      tags: ['google', 'search', 'top_placement'],
      popularityScore: 94,
      isFeatured: true,
    ),
  ];

  Future<List<PromotionItem>> getAvailablePromotions() async {
    // In production, this would fetch from Supabase
    // For now, return mock data
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockPromotions;
  }

  Future<List<String>> getPreviouslyPurchased(String userId) async {
    try {
      // For now, use automation_tasks to get previously purchased items
      // In a real implementation, you'd have a separate purchases table
      final response = await Supabase.instance.client
          .from('automation_tasks')
          .select('task_type')
          .eq('user_id', userId)
          .inFilter('status', ['completed']);
      
      return List<String>.from(response.map((row) => row['task_type']));
    } catch (e) {
      print('Error fetching purchased promotions: $e');
      return [];
    }
  }

  Future<List<String>> getActiveInQueue(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('automation_tasks')
          .select('task_type')
          .eq('user_id', userId)
          .inFilter('status', ['queued', 'running']);
      
      return List<String>.from(response.map((row) => row['task_type']));
    } catch (e) {
      print('Error fetching queue items: $e');
      return [];
    }
  }

  Future<List<PromotionItem>> getRecommendations(String userId, {int limit = 6}) async {
    final availableItems = await getAvailablePromotions();
    final previouslyPurchased = await getPreviouslyPurchased(userId);
    final activeInQueue = await getActiveInQueue(userId);

    final logic = RecommendationLogic(
      availableItems: availableItems,
      previouslyPurchased: previouslyPurchased,
      activeInQueue: activeInQueue,
    );

    return logic.getRecommendations(limit: limit);
  }

  Future<QueueItem?> purchasePromotion({
    required String userId,
    required String promotionId,
    required String promotionTitle,
    required int tokenCost,
    String? propertyId,
    List<String>? imageUrls,
  }) async {
    try {
      // Check wallet balance
      final wallet = await WalletDashboardService.getOrCreateWallet();
      if (wallet == null) {
        throw Exception('Wallet not found');
      }

      final balance = await WalletDashboardService.getWalletBalance(wallet['id']);
      if (balance == null || balance < tokenCost) {
        return null; // Insufficient balance
      }

      // Deduct tokens
      print('Attempting to deduct $tokenCost tokens from wallet ${wallet['id']}');
      final deductSuccess = await WalletDashboardService.debitTokens(
        walletId: wallet['id'],
        tokenAmount: tokenCost,
        description: 'Purchase: $promotionTitle',
      );
      
      print('Token deduction result: $deductSuccess');
      
      if (!deductSuccess) {
        throw Exception('Failed to deduct tokens');
      }

      // Prefer caller-provided image URLs (dashboard upload flow). If none were
      // provided, fall back to selecting random images from the user's gallery.
      List<String> selectedImages = (imageUrls != null && imageUrls.isNotEmpty)
          ? List<String>.from(imageUrls)
          : const [];

      if (selectedImages.isEmpty) {
        try {
          final userRow = await Supabase.instance.client
              .from('users')
              .select('gallery_urls')
              .eq('id', userId)
              .maybeSingle();
          final gallery =
              (userRow != null && userRow['gallery_urls'] is List)
                  ? List<String>.from(userRow['gallery_urls'] as List)
                  : <String>[];

          if (gallery.isNotEmpty) {
            gallery.shuffle();
            selectedImages =
                gallery.take(gallery.length >= 3 ? 3 : gallery.length).toList();
          }
        } catch (e) {
          print('Error selecting images for task: $e');
        }
      }

      // Add to automation queue using RPC function
      try {
        print('DEBUG: Creating automation task with userId: $userId, promotionId: $promotionId, status: pending');
        final result = await Supabase.instance.client.rpc(
          'create_automation_task',
          params: {
            'p_user_id': userId,
            'p_task_type': promotionId,
            'p_status': 'pending', // approval workflow
          },
        );

        print('Automation task created successfully: $result');

        // Persist selectedImages onto the task row (works even if the RPC signature
        // doesn't support p_image_urls).
        try {
          String? taskId;
          if (result is List && result.isNotEmpty) {
            final row = result.first;
            if (row is Map) {
              taskId = (row['task_id'] ?? row['id'])?.toString();
            }
          } else if (result is Map) {
            taskId = (result['task_id'] ?? result['id'])?.toString();
          }

          if (taskId != null &&
              taskId.isNotEmpty &&
              selectedImages.isNotEmpty) {
            await Supabase.instance.client
                .from('automation_tasks')
                .update({'image_urls': selectedImages})
                .eq('id', taskId);
            print('Saved image_urls on automation_tasks.$taskId');
          }
        } catch (e) {
          // If the column doesn't exist yet, ignore (DB patch not applied).
          final msg = e.toString();
          if (!msg.contains('image_urls') || !msg.contains('does not exist')) {
            print('Failed to persist image_urls on task: $e');
          }
        }
      } catch (e) {
        print('Error creating automation task via RPC: $e');
        throw Exception('Failed to create automation task: $e');
      }

      final queueItem = QueueItem(
        id: const Uuid().v4(), // Generate for local use only
        promotionId: promotionId,
        promotionTitle: promotionTitle,
        tokensDeducted: tokenCost,
        queuedAt: DateTime.now(),
        status: 'queued',
        propertyId: propertyId,
      );

      // Record purchase (optional - can be added later if needed)
      // await Supabase.instance.client.from('promotion_purchases').insert({
      //   'user_id': userId,
      //   'promotion_id': promotionId,
      //   'tokens_spent': tokenCost,
      //   'purchased_at': DateTime.now().toIso8601String(),
      // });

      return queueItem;
    } catch (e) {
      print('Error purchasing promotion: $e');
      return null;
    }
  }

  Future<List<QueueItem>> getAutomationQueue(String userId) async {
    try {
      // First try to get tasks with wallet_commitments
      final response = await Supabase.instance.client
          .from('automation_tasks')
          .select('*, wallet_commitments(reserved_amount)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      print('Fetched automation tasks: $response');

      return response.map((row) {
        // Get token cost from wallet_commitments first, then from promotion lookup
        int tokenCost = 0;
        if (row['wallet_commitments'] != null && row['wallet_commitments']['reserved_amount'] != null) {
          tokenCost = row['wallet_commitments']['reserved_amount'] as int;
        } else {
          // Use the promotion token cost as primary source
          tokenCost = _getPromotionTokenCost(row['task_type']);
        }

        print('DEBUG DB: task_type="${row['task_type']}" (type: ${row['task_type'].runtimeType})');
        print('Processing task: ${row['id']}, type: ${row['task_type']}, status: ${row['status']}, cost: $tokenCost');

        return QueueItem(
          id: row['id'],
          promotionId: row['task_type'],
          promotionTitle: _getPromotionTitle(row['task_type']),
          tokensDeducted: tokenCost,
          queuedAt: DateTime.parse(row['created_at']),
          status: _mapStatus(row['status']),
          propertyId: null,
          rejectionReason: row['rejection_reason'] as String?,
        );
      }).toList();
    } catch (e) {
      print('Error fetching automation queue: $e');
      return [];
    }
  }

  Stream<List<QueueItem>> getAutomationQueueStream(String userId) {
    return Supabase.instance.client
        .from('automation_tasks')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((data) {
          return data.map((row) {
            return QueueItem(
              id: row['id'],
              promotionId: row['task_type'],
              promotionTitle: _getPromotionTitle(row['task_type']),
              tokensDeducted: _getPromotionTokenCost(row['task_type']),
              queuedAt: DateTime.parse(row['created_at']),
              status: _mapStatus(row['status']),
              propertyId: null,
              rejectionReason: row['rejection_reason'] as String?,
            );
          }).toList();
        });
  }

  int _getPromotionTokenCost(String promotionId) {
    // First check mock promotions
    final promotion = _mockPromotions.where((p) => p.id == promotionId).firstOrNull;
    if (promotion != null) return promotion.tokenCost;
    
    // Handle string task types with default costs
    switch (promotionId) {
      case 'basic_promotion':
        return 10;
      case 'standard_promotion':
        return 15;
      case 'premium_promotion':
        return 20;
      case 'linkedin_post':
        return 5;  // Updated to match design
      case 'tiktok_video':
        return 5;  // Updated to match "TikTok Listing Walkthrough" (5 tokens)
      case 'featured_listing':
        return 20;
      case 'social_blast':
        return 12;
      case 'premium_visibility':
        return 25;
      case 'instagram_story':
        return 3;  // Updated to match "Instagram Market Insight" (3 tokens)
      case 'facebook_boost':
        return 18;
      case 'youtube_tour':
        return 30;
      case 'email_blast':
        return 14;
      case 'google_ads':
        return 35;
      case 'buyer_tip_walkthrough':
        return 4;  // New task type from image
      case 'ai_calling_campaign':
        return 2;  // AI Calling Campaign (2 tokens - LinkedIn version)
      // LinkedIn Services from Document
      case 'linkedin_carousel':
        return 5;  // LinkedIn Authority Carousel (5 tokens)
      case 'linkedin_video':
        return 6;  // LinkedIn Video Insight (6 tokens)
      case 'linkedin_static':
        return 3;  // LinkedIn Static Post (3 tokens)
      case 'linkedin_profile':
        return 8;  // LinkedIn Profile Authority Optimization (8 tokens)
      case 'linkedin_weekly':
        return 5;  // LinkedIn Weekly Posting System (5 tokens)
      // Original numeric IDs
      case '1': // TikTok Listing Walkthrough
        return 5;  // TikTok (5 tokens)
      case '2': // Instagram Market Insight
        return 3;  // Instagram (3 tokens)
      case '3': // Buyer Tip Walkthrough (YouTube Shorts)
        return 4;  // YouTube Shorts (4 tokens)
      case '4': // AI Calling Campaign ID from dashboard (8 tokens)
        return 8;  // AI Calling (8 tokens - LinkedIn version)
      case '5': // AI Calling Campaign ID from dashboard (8 tokens)
        return 8;  // AI Calling (8 tokens - AI Calling version)
      default:
        return 10; // Default cost for unknown tasks
    }
  }

  String _getPromotionTitle(String promotionId) {
    // Map promotion IDs to titles
    final titles = {
      'basic_promotion': 'Basic Promotion',
      'standard_promotion': 'Standard Promotion', 
      'premium_promotion': 'Premium Promotion',
      // LinkedIn Services from Document
      'linkedin_carousel': 'LinkedIn Authority Carousel',
      'linkedin_video': 'LinkedIn Video Insight',
      'linkedin_static': 'LinkedIn Static Post',
      'linkedin_profile': 'LinkedIn Profile Authority',
      'linkedin_weekly': 'LinkedIn Weekly Posting',
      // Original mappings
      '1': 'TikTok',  // TikTok Listing Walkthrough
      '2': 'Instagram',  // Instagram Market Insight
      '3': 'YouTube Shorts',  // Buyer Tip Walkthrough
      '4': 'AI Calling',  // AI Calling Campaign (LinkedIn version)
      '5': 'AI Calling',  // AI Calling version (8 tokens)
      'linkedin_post': 'LinkedIn',  // Show just "LinkedIn"
      'tiktok_video': 'TikTok',  // Show just "TikTok"
      'featured_listing': 'Featured Listing',
      'social_blast': 'Social Blast',
      'premium_visibility': 'Premium Visibility',
      'instagram_story': 'Instagram',  // Show just "Instagram"
      'facebook_boost': 'Facebook',
      'youtube_tour': 'YouTube',
      'email_blast': 'Email Blast',
      'google_ads': 'Google Ads',
      'buyer_tip_walkthrough': 'Buyer Tip',
      'ai_calling_campaign': 'AI Calling',
    };
    
    final title = titles[promotionId] ?? 'Promotion Task $promotionId';
    print('DEBUG: promotionId="$promotionId" -> title="$title"');
    return title;
  }

  String _mapStatus(String status) {
    // Map automation_tasks status to QueueItem status
    switch (status) {
      case 'pending':
        return 'pending';
      case 'queued':
        return 'approved';  // queued means approved by admin, ready for processing
      case 'running':
        return 'pending';  // processing tasks show as pending in simplified view
      case 'completed':
        return 'approved';  // completed tasks show as approved
      case 'failed':
        return 'pending';  // failed tasks show as pending in simplified view
      case 'rejected':
        return 'rejected';
      default:
        return 'pending';
    }
  }

  Future<int> getMissingTokens(String userId, int requiredTokens) async {
    try {
      final wallet = await WalletDashboardService.getOrCreateWallet();
      if (wallet == null) return requiredTokens;

      final balance = await WalletDashboardService.getWalletBalance(wallet['id']);
      final currentBalance = balance?.toInt() ?? 0;
      
      if (currentBalance >= requiredTokens) return 0;
      
      return requiredTokens - currentBalance;
    } catch (e) {
      print('Error calculating missing tokens: $e');
      return requiredTokens;
    }
  }

}
