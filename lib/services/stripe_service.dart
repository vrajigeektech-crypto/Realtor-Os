import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase_config.dart';

class StripeService {
  static const String _publishableKey = 'pk_test_51T24IEQnyYQTmh38Vs9aGScDROvn64UhzmHxviGIPSrZ4Qzaq4cbzZNEJZFHhivZ4JC3wQTjl9kNZbolV6Z8BBfz009M94hT74';
  static const String _productId = 'prod_U06aN1WnzDJNRspk';
  static const String _supabaseUrl = SupabaseConfig.supabaseUrl;
  
  static Future<void> initialize() async {
    try {
      Stripe.publishableKey = _publishableKey;
      await Stripe.instance.applySettings();
      debugPrint('✅ [Stripe] Initialized successfully');
    } catch (e) {
      debugPrint('⚠️ [Stripe] Initialization skipped or failed: $e');
      debugPrint('   Note: Stripe might not be supported on this platform (e.g., macOS desktop).');
    }
  }

  /// Creates a Stripe Checkout Session via Supabase Edge Function
  Future<String?> createCheckoutSession({
    int? tokenAmount,
    String? productId,
    String? successUrl,
    String? cancelUrl,
  }) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response = await Supabase.instance.client.functions.invoke(
        'create-checkout-session',
        body: {
          if (tokenAmount != null) "tokenAmount": tokenAmount,
          if (productId != null) "productId": productId,
          "successUrl": successUrl ?? "https://yourapp.com/success",
          "cancelUrl": cancelUrl ?? "https://yourapp.com/cancel",
          "userId": user.id, // Add user ID to metadata
        },
      );

      if (response.status != 200 && response.status != 201) {
        throw Exception('Failed to create checkout session: ${response.data}');
      }

      final data = response.data;
      return data['url'] as String?;
    } catch (e) {
      debugPrint('❌ [Stripe] Error creating checkout session: $e');
      rethrow;
    }
  }

  /// Processes payment by launching Stripe Checkout
  Future<void> processPayment({int? tokenAmount, String? productId}) async {
    try {
      debugPrint('🚀 [Stripe] Starting payment process...');
      
      final checkoutUrl = await createCheckoutSession(
        tokenAmount: tokenAmount,
        productId: productId ?? _productId,
        successUrl: "demoapp://payment-success?session_id={CHECKOUT_SESSION_ID}",
        cancelUrl: "demoapp://payment-cancel",
      );
      
      if (checkoutUrl == null) {
        throw Exception('No checkout URL returned from server');
      }

      debugPrint('✅ [Stripe] Checkout URL generated: $checkoutUrl');
      
      final launched = await launchUrl(
        Uri.parse(checkoutUrl),
        mode: LaunchMode.externalApplication,
      );
      
      if (!launched) {
        throw Exception('Could not launch checkout URL');
      }

      debugPrint('💰 [Stripe] User redirected to Stripe Checkout');
      debugPrint('ℹ️ [Stripe] Status will be updated via webhook after payment completion');
      
    } catch (e) {
      debugPrint('❌ [Stripe] Payment process failed: $e');
      rethrow;
    }
  }

  // Support for Payment Sheet if needed in the future
  static Future<void> presentPaymentSheet({
    required String clientSecret,
  }) async {
    try {
      await Stripe.instance.presentPaymentSheet();
    } catch (e) {
      debugPrint('Payment sheet presentation failed: $e');
      rethrow;
    }
  }
}

