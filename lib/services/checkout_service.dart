import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase_config.dart';

class CheckoutService {
  static final SupabaseClient _client = SupabaseConfig.client;

  /// Create a Stripe checkout session using Edge Function
  static Future<Map<String, dynamic>?> createCheckoutSession({
    String? priceId,
    int? tokenAmount,
    String? successUrl,
    String? cancelUrl,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response = await _client.functions.invoke(
        'create-checkout-session',
        body: {
          'priceId': priceId,
          'tokenAmount': tokenAmount,
          'successUrl': successUrl ?? 'https://yourapp.com/success',
          'cancelUrl': cancelUrl ?? 'https://yourapp.com/cancel',
        },
      );

      return response.data;
    } catch (e) {
      print('Error creating checkout session: $e');
      return null;
    }
  }

  /// Create a direct Stripe checkout session (alternative method)
  static Future<String?> createStripeCheckoutSessionDirect({
    required String priceId,
    required String stripeSecretKey,
    String? successUrl,
    String? cancelUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/checkout/sessions'),
        headers: {
          'Authorization': 'Bearer $stripeSecretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'payment_method_types[]': 'card',
          'line_items[0][price]': priceId,
          'line_items[0][quantity]': '1',
          'mode': 'payment',
          'success_url': successUrl ?? 'https://yourapp.com/success',
          'cancel_url': cancelUrl ?? 'https://yourapp.com/cancel',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['id'];
      } else {
        print('Stripe API error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error creating Stripe checkout session: $e');
      return null;
    }
  }

  /// Get user's checkout sessions
  static Future<List<Map<String, dynamic>>> getCheckoutSessions() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response = await _client
          .from('checkout_sessions')
          .select('*')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching checkout sessions: $e');
      return [];
    }
  }

  /// Update checkout session status
  static Future<bool> updateCheckoutSessionStatus(
      String sessionId, String status) async {
    try {
      await _client
          .from('checkout_sessions')
          .update({'status': status, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', sessionId);

      return true;
    } catch (e) {
      print('Error updating checkout session: $e');
      return false;
    }
  }

  /// Delete checkout session
  static Future<bool> deleteCheckoutSession(String sessionId) async {
    try {
      await _client.from('checkout_sessions').delete().eq('id', sessionId);
      return true;
    } catch (e) {
      print('Error deleting checkout session: $e');
      return false;
    }
  }
}
