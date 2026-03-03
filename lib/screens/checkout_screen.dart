import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import 'package:url_launcher/url_launcher.dart';
import '../services/checkout_service.dart';
import '../services/stripe_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _sessions = [];

  @override
  void initState() {
    super.initState();
    _loadCheckoutSessions();
  }

  Future<void> _loadCheckoutSessions() async {
    final sessions = await CheckoutService.getCheckoutSessions();
    setState(() {
      _sessions = sessions;
    });
  }

  Future<void> _createCheckoutSession() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Example: Purchase 100 tokens for $100
      const tokenAmount = 100;
      
      final stripe = StripeService();
      await stripe.processPayment(tokenAmount: tokenAmount);
      
      // Refresh sessions after starting flow
      _loadCheckoutSessions();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating checkout session: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: const Color(0xFF1C1C1E),
      ),
      backgroundColor: const Color(0xFF000000),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Purchase Tokens',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '100 tokens for \$100 USD',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _createCheckoutSession,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFCE9799),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Buy Now',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _sessions.isEmpty
                  ? const Center(
                      child: Text('No checkout sessions found'),
                    )
                  : ListView.builder(
                      itemCount: _sessions.length,
                      itemBuilder: (BuildContext context, int index) {
                        final session = _sessions[index];
                        return Card(
                          child: ListTile(
                            title: Text('Session ${session['id'].toString().substring(0, 8)}...'),
                            subtitle: Text(
                              'Status: ${session['status']}\n'
                              'Created: ${DateTime.parse(session['created_at']).toString().split('.')[0]}',
                            ),
                            trailing: Icon(
                              _getStatusIcon(session['status']),
                              color: _getStatusColor(session['status']),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'expired':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'expired':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
