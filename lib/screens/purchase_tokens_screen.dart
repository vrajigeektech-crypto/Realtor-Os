import 'package:flutter/material.dart';
import '../layout/main_layout.dart';
import '../services/wallet_dashboard_service.dart';
import '../services/stripe_service.dart';
import 'complete_purchase_screen.dart';
import 'wallet_dashboard.dart';

class PurchaseTokensScreen extends StatefulWidget {
  const PurchaseTokensScreen({super.key});

  @override
  State<PurchaseTokensScreen> createState() => _PurchaseTokensScreenState();
}

class _PurchaseTokensScreenState extends State<PurchaseTokensScreen> {
  Map<String, dynamic>? _wallet;
  bool _isLoading = true;
  final TextEditingController _tokenController = TextEditingController(text: '100');

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Initialize wallet service to ensure transactions table exists
    WalletDashboardService.initialize();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    try {
      final wallet = await WalletDashboardService.getOrCreateWallet();
      if (wallet != null) {
        // Get wallet balance separately
        final balance = await WalletDashboardService.getWalletBalance(wallet['id']);
        if (mounted) {
          setState(() {
            _wallet = {
              ...wallet,
              'balance': balance ?? 0.0,
            };
            _isLoading = false;
          });
        }
      } else if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Purchase Tokens',
      activeIndex: 3, // Wallet/Billing
      child: _PurchaseTokensLayout(
        wallet: _wallet,
        isLoading: _isLoading,
        onRefresh: _loadWalletData,
        tokenController: _tokenController,
      ),
    );
  }
}

class _PurchaseTokensLayout extends StatefulWidget {
  final Map<String, dynamic>? wallet;
  final bool isLoading;
  final VoidCallback onRefresh;
  final TextEditingController tokenController;

  const _PurchaseTokensLayout({
    required this.wallet,
    required this.isLoading,
    required this.onRefresh,
    required this.tokenController,
  });

  @override
  State<_PurchaseTokensLayout> createState() => _PurchaseTokensLayoutState();
}

class _PurchaseTokensLayoutState extends State<_PurchaseTokensLayout> {
  @override
  void initState() {
    super.initState();
    // Listen to changes in the text controller to update title
    widget.tokenController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.tokenController.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {}); // Rebuild when text changes to update title
  }

  @override
  Widget build(BuildContext context) {
    const divider = Color(0xFF3E3144);
    const accentRose = Color(0xFFCE9799);

    return Center(
      child: SizedBox(
        width: 980,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Purchase ${widget.tokenController.text} Tokens',
                  style: const TextStyle(
                    color: accentRose,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                // _WalletBalanceCard(
                //   wallet: widget.wallet,
                //   isLoading: widget.isLoading,
                //   onRefresh: widget.onRefresh,
                  // ),letBalanceCard(
                  //   wallet: widget.wallet,
                  //   isLoading: widget.isLoading,
                  //   onRefresh: widget.onRefresh,
                  // ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: divider),
            const SizedBox(height: 24),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 800) {
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          _PaymentFormCard(tokenController: widget.tokenController),
                          const SizedBox(height: 24),
                          _TokenSummaryCard(tokenController: widget.tokenController),
                        ],
                      ),
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _PaymentFormCard(tokenController: widget.tokenController)),
                      const SizedBox(width: 24),
                      SizedBox(width: 320, child: _TokenSummaryCard(tokenController: widget.tokenController)),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            const _FooterTrustRow(),
          ],
        ),
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  final Widget child;
  const _CardShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF3E3144)),
      ),
      padding: const EdgeInsets.all(20),
      child: child,
    );
  }
}

class _PaymentFormCard extends StatefulWidget {
  final TextEditingController tokenController;
  
  const _PaymentFormCard({required this.tokenController});

  @override
  State<_PaymentFormCard> createState() => _PaymentFormCardState();
}

class _PaymentFormCardState extends State<_PaymentFormCard> {

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFCE9799);
    const muted = Color(0xFF9EA3AE);

    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Expanded(child: _PayButton(label: 'Apple Pay')),
              SizedBox(width: 12),
              Expanded(child: _PayButton(label: 'Google Pay')),
            ],
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text('or', style: TextStyle(color: muted, fontSize: 12)),
          ),
          const SizedBox(height: 12),
          // Token amount input field
          TextField(
            controller: widget.tokenController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF141414),
              prefixIcon: const Icon(Icons.token, color: Color(0xFFCE9799), size: 20),
              labelText: 'Number of Tokens',
              labelStyle: const TextStyle(color: Color(0xFF9EA3AE)),
              hintText: 'Enter token amount',
              hintStyle: const TextStyle(color: Color(0xFF9EA3AE)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF3E3144)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFCE9799)),
              ),
            ),
            onChanged: (value) {
              // Trigger rebuild to update title and summary
              setState(() {});
            },
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF141414),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFCE9799)),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.credit_card,
                  color: Color(0xFFCE9799),
                  size: 32,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Secure Stripe Payment',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Click "Purchase Tokens" to continue with secure payment',
                  style: TextStyle(
                    color: muted,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _PurchaseButton(tokenController: widget.tokenController),
          const SizedBox(height: 10),
          const Text(
            'You can cancel anytime.\nYour card details are encrypted and secure.',
            style: TextStyle(color: muted, fontSize: 11, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _PayButton extends StatelessWidget {
  final String label;
  const _PayButton({required this.label});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFCE9799);
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final IconData icon;
  const _InputField({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    const muted = Color(0xFF9EA3AE);
    const border = Color(0xFF3E3144);
    const accent = Color(0xFFCE9799);

    return TextField(
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF141414),
        prefixIcon: Icon(icon, color: muted, size: 18),
        hintText: label,
        hintStyle: const TextStyle(color: muted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: accent),
        ),
      ),
    );
  }
}

class _TokenSummaryCard extends StatefulWidget {
  final TextEditingController tokenController;
  
  const _TokenSummaryCard({required this.tokenController});

  @override
  State<_TokenSummaryCard> createState() => _TokenSummaryCardState();
}

class _TokenSummaryCardState extends State<_TokenSummaryCard> {
  @override
  void initState() {
    super.initState();
    // Listen to changes in the text controller
    widget.tokenController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.tokenController.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {}); // Rebuild when text changes
  }

  @override
  Widget build(BuildContext context) {
    // Calculate price dynamically
    final tokenAmount = int.tryParse(widget.tokenController.text) ?? 0;
    final price = tokenAmount.toDouble(); // 1 token = $1
    
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Token Package',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _SummaryRow(label: '$tokenAmount Tokens', value: '\$${price.toStringAsFixed(2)}'),
          const SizedBox(height: 10),
          const Divider(color: Color(0xFF3E3144)),
          const SizedBox(height: 10),
          _SummaryRow(label: 'Total', value: '\$${price.toStringAsFixed(2)}', isTotal: true),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isTotal ? Colors.white : const Color(0xFF9EA3AE);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: isTotal ? 14 : 13,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: isTotal ? 14 : 13,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _PurchaseButton extends StatefulWidget {
  final TextEditingController tokenController;
  
  const _PurchaseButton({required this.tokenController});

  @override
  State<_PurchaseButton> createState() => _PurchaseButtonState();
}

class _PurchaseButtonState extends State<_PurchaseButton> {
  bool _isLoading = false;

  Future<void> _handlePurchase() async {
    setState(() => _isLoading = true);
    
    try {
      // Get token amount from controller
      final tokenAmount = int.tryParse(widget.tokenController.text) ?? 0;
      
      if (tokenAmount <= 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter a valid token amount'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }
      
      // Use StripeService to process payment
      await StripeService().processPayment(
        tokenAmount: tokenAmount,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Redirecting to secure payment checkout...'),
            backgroundColor: Color(0xFFCE9799),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Stripe attempt failed: $e. Falling back to manual credit...'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      
      // Fallback to manual credit for testing if Stripe fails
      try {
        // Get token amount again for fallback
        final tokenAmount = int.tryParse(widget.tokenController.text) ?? 0;
        final wallet = await WalletDashboardService.getOrCreateWallet();
        if (wallet != null) {
          final success = await WalletDashboardService.creditTokens(
            walletId: wallet['id'] as String,
            tokenAmount: tokenAmount,
            referenceId: 'token_purchase_fallback_${DateTime.now().millisecondsSinceEpoch}',
          );
          
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Success! (Manual Fallback): $tokenAmount tokens added.'),
                backgroundColor: Colors.green,
              ),
            );
            
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const WalletDashboard()),
                  (route) => false,
                );
              }
            });
          }
        }
      } catch (fallbackError) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Final failure: $fallbackError'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFCE9799);

    return SizedBox(
      height: 48,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: _isLoading ? null : _handlePurchase,
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Purchase Tokens',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}

class _WalletBalanceCard extends StatelessWidget {
  final Map<String, dynamic>? wallet;
  final bool isLoading;
  final VoidCallback onRefresh;

  const _WalletBalanceCard({
    required this.wallet,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    const cardBg = Color(0xFF1E1E1E);
    const border = Color(0xFF3E3144);
    const accent = Color(0xFFCE9799);

    if (isLoading) {
      return Container(
        width: 280,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: accent,
            strokeWidth: 2,
          ),
        ),
      );
    }

    final balance = (wallet?['balance'] as num?)?.toDouble() ?? 0.0;

    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Current Balance',
                style: TextStyle(
                  color: Color(0xFF9EA3AE),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              GestureDetector(
                onTap: onRefresh,
                child: const Icon(
                  Icons.refresh,
                  color: Color(0xFF9EA3AE),
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                balance.toStringAsFixed(0),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  'tokens',
                  style: TextStyle(
                    color: Color(0xFF9EA3AE),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FooterTrustRow extends StatelessWidget {
  const _FooterTrustRow();

  @override
  Widget build(BuildContext context) {
    const muted = Color(0xFF9EA3AE);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.lock_outline, size: 16, color: muted),
        SizedBox(width: 6),
        Text('Secure Payment', style: TextStyle(color: muted, fontSize: 11)),
        SizedBox(width: 16),
        Icon(Icons.verified_user_outlined, size: 16, color: muted),
        SizedBox(width: 6),
        Text('Trusted Service', style: TextStyle(color: muted, fontSize: 11)),
        SizedBox(width: 16),
        Text('Powered by Stripe', style: TextStyle(color: muted, fontSize: 11)),
      ],
    );
  }
}
