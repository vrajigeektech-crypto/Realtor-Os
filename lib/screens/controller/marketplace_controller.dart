import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../screens/review_recommendation_screen.dart';
// import '../../screens/linkedin_recommendation_screen.dart';
// import '../../services/linkedin_marketplace_service.dart';

class MarketplaceController extends GetxController {
  final isLoadingRecommendations = false.obs;
  final recommendations = <Map<String, dynamic>>[].obs;
  final insights = <Map<String, dynamic>>[].obs;
  final activationCategories = <Map<String, dynamic>>[].obs;
  final availableBalance = 0.0.obs;
  final ostBalance = 0.0.obs;
  // final LinkedInMarketplaceService _linkedinService = LinkedInMarketplaceService();

  @override
  void onInit() {
    super.onInit();
    // Initialize data if needed
    _loadMockData();
  }

  void _loadMockData() {
    // Temporarily disable LinkedIn services
    // final linkedinServices = _linkedinService.getLinkedInServices();
    
    // Debug: Check if LinkedIn services are loaded
    // print('LinkedIn services count: ${linkedinServices.length}');
    
    // Temporarily disable LinkedIn services to test compilation
    final linkedinRecommendations = <Map<String, dynamic>>[];
    
    // Debug: Print LinkedIn services
    // print('=== LINKEDIN SERVICES DEBUG ===');
    // for (var service in linkedinServices) {
    //   print('ID: ${service.id}, Title: ${service.title}, Platform: ${service.platform}');
    // }
    // print('=============================');

    // Add a simple test LinkedIn service if none exist
    if (linkedinRecommendations.isEmpty) {
      linkedinRecommendations.add({
        'id': 'test_linkedin',
        'title': 'Test LinkedIn Service',
        'description': 'Test description',
        'platform': 'LinkedIn',
        'category': 'Test',
        'token_cost': 5,
        'xp_reward': 2,
        'status': 'Ready',
      });
      print('Added test LinkedIn service');
    }

    // Mock recommendations data for testing
    recommendations.value = [
      ...linkedinRecommendations,
      {
        'id': '1',
        'title': 'TikTok Listing Walkthrough',
        'platform': 'TikTok',
        'category': 'Social Media Content',
        'token_cost': 5,
        'status': 'Ready',
        'description': 'Create engaging TikTok walkthrough of your latest listing',
      },
      {
        'id': '2',
        'title': 'Instagram Market Insight',
        'platform': 'Instagram',
        'category': 'Market Update',
        'token_cost': 3,
        'status': 'Ready',
        'description': 'Share latest market trends with your Instagram followers',
      },
      {
        'id': '3',
        'title': 'Buyer Tip Walkthrough',
        'platform': 'YouTube Shorts',
        'category': 'Educational Content',
        'token_cost': 4,
        'status': 'In Progress',
        'description': 'Help first-time buyers with essential tips',
      },
      {
        'id': '4',
        'title': 'AI Calling Campaign',
        'platform': 'LinkedIn',
        'category': 'Lead Generation',
        'token_cost': 8,
        'status': 'Ready',
        'description': 'AI-powered calling campaign for qualified leads',
      },
    ];

    insights.value = [
      {'label': '5 new listings this week', 'icon': 'list'},
      {'label': 'Buyer activity up 23%', 'icon': 'trending-up'},
      {'label': 'Market timing optimal', 'icon': 'clock'},
    ];

    activationCategories.value = [
      {
        'category_name': 'Social Media',
        'description': 'Automated posting across platforms',
        'icon': 'megaphone',
        'is_active': true,
        'status': 'active',
      },
      {
        'category_name': 'Lead Nurturing',
        'description': 'AI-powered follow-up sequences',
        'icon': 'graduation-cap',
        'is_active': true,
        'status': 'active',
      },
      {
        'category_name': 'Content Creation',
        'description': 'AI-generated property content',
        'icon': 'magnet',
        'is_active': false,
        'status': 'inactive',
      },
      {
        'category_name': 'Market Analysis',
        'description': 'Real-time market insights',
        'icon': 'refresh',
        'is_active': false,
        'status': 'reserved',
      },
    ];

    availableBalance.value = 8043.0;
    ostBalance.value = 8043.0;
  }

  Future<void> approveAndPostRecommendation(String id) async {
    try {
      // Find the recommendation by id
      final recommendation = recommendations.firstWhereOrNull((item) => item['id'].toString() == id);
      
      if (recommendation == null) {
        Get.snackbar(
          'Error',
          'Recommendation not found',
          backgroundColor: const Color(0xFFCE9799),
          colorText: Colors.black,
        );
        return;
      }

      // Temporarily disable LinkedIn navigation
      // if (recommendation['id'].toString().startsWith('linkedin_')) {
      //   // Navigate to LinkedIn Recommendation Screen
      //   await Get.to(
      //     () => LinkedInRecommendationScreen(recommendation: recommendation),
      //     transition: Transition.rightToLeft,
      //     duration: const Duration(milliseconds: 300),
      //   );
      // } else {
        // Navigate to regular Review Recommendation screen
        await Get.to(
          () => ReviewRecommendationScreen(recommendation: recommendation),
          transition: Transition.rightToLeft,
          duration: const Duration(milliseconds: 300),
        );
      // }

      // Refresh data after returning from review screen
      _loadMockData();
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to process recommendation: ${e.toString()}',
        backgroundColor: const Color(0xFFCE9799),
        colorText: Colors.black,
      );
    }
  }
}
