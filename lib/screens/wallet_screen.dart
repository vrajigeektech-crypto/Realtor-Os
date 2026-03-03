import 'package:flutter/material.dart';
import '../services/wallet_dashboard_service.dart';
import '../services/balance_service.dart';
import '../widgets/wallet_balance_card.dart';
import 'purchase_tokens_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  Map<String, dynamic>? _wallet;
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  final BalanceService _balanceService = BalanceService();

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  @override
  void dispose() {
    WalletDashboardService.stopRealtimeUpdates();
    super.dispose();
  }

  Future<void> _loadWalletData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get or create wallet 
      final wallet = await WalletDashboardService.getOrCreateWallet();
      if (wallet != null) {
        // Get wallet balance separately
        final balance = await WalletDashboardService.getWalletBalance(wallet['id']);
        
        setState(() {
          _wallet = {
            ...wallet,
            'balance': balance ?? 0.0,
          };
        });

        // Load transaction history
        await _loadTransactions();

        // Start real-time updates
        _startRealtimeUpdates();
      }
    } catch (e) {
      print('Error loading wallet data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTransactions() async {
    if (_wallet == null) return;

    try {
      final transactions = await WalletDashboardService.getTransactionHistory(
        walletId: _wallet!['id'],
        limit: 20,
      );
      
      setState(() {
        _transactions = transactions;
      });
    } catch (e) {
      print('Error loading transactions: $e');
    }
  }

  void _startRealtimeUpdates() {
    if (_wallet == null) return;

    WalletDashboardService.watchWallet(_wallet!['id']).listen((walletData) async {
      if (mounted) {
        // Get updated balance when wallet data changes
        final balance = await WalletDashboardService.getWalletBalance(walletData['id']);
        setState(() {
          _wallet = {
            ...walletData,
            'balance': balance ?? 0.0,
          };
        });
      }
    });

    WalletDashboardService.watchTransactions(_wallet!['id']).listen((transactions) {
      if (mounted) {
        setState(() {
          _transactions = transactions;
        });
        // Refresh balance when transactions change
        _refreshBalance();
      }
    });
  }

  Future<void> _refreshBalance() async {
    if (_wallet == null) return;
    
    try {
      final balance = await WalletDashboardService.getWalletBalance(_wallet!['id']);
      if (mounted && balance != null) {
        setState(() {
          _wallet = {
            ..._wallet!,
            'balance': balance,
          };
        });
      }
    } catch (e) {
      print('Error refreshing balance: $e');
    }
  }

  Future<void> _refreshWallet() async {
    setState(() {
      _isRefreshing = true;
    });
    
    await _loadWalletData();
    
    setState(() {
      _isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final walletBalance = (_wallet?['balance'] as num?)?.toDouble() ?? 8524.0;
    final reservedTokens = 0.0; // TODO: Calculate from transactions
    final spentToday = 0.0; // TODO: Calculate from transactions

    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(color: Color(0xFFCE9799)),
          )
        : Container(
            color: const Color(0xFF0A0A0A),
            child: Column(
              children: [
                // OST Balance Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  child: StreamBuilder<double>(
                    stream: _balanceService.balanceStream,
                    initialData: _balanceService.currentBalance,
                    builder: (context, snapshot) {
                      final balance = snapshot.data ?? 0.0;
                      return Text(
                        'OST Balance: ${_balanceService.formatBalance(balance)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Wallet Balance Card
                        WalletBalanceCard(
                          balance: walletBalance,
                          reservedTokens: reservedTokens,
                          spentToday: spentToday,
                          onBuyTokens: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PurchaseTokensScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),

                        // Transaction History
                        const Text(
                          'Transaction History',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _transactions.isEmpty
                            ? Container(
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E1E1E),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFF3E3144)),
                                ),
                                child: const Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.receipt_long_outlined,
                                        size: 48,
                                        color: Color(0xFF9EA3AE),
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'No transactions yet',
                                        style: TextStyle(
                                          color: Color(0xFF9EA3AE),
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Buy tokens to see your transaction history',
                                        style: TextStyle(
                                          color: Color(0xFF9EA3AE),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Column(
                                children: _transactions.map((tx) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E1E1E),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFF3E3144)),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: tx['type'] == 'credit' 
                                                ? Colors.green.withOpacity(0.2)
                                                : Colors.red.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Icon(
                                            tx['type'] == 'credit' 
                                                ? Icons.arrow_downward
                                                : Icons.arrow_upward,
                                            color: tx['type'] == 'credit' 
                                                ? Colors.green
                                                : Colors.red,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                tx['description'] ?? 'Transaction',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                DateTime.parse(tx['created_at']).toString().substring(0, 19),
                                                style: const TextStyle(
                                                  color: Color(0xFF9EA3AE),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '${tx['type'] == 'credit' ? '+' : '-'}${(tx['amount'] as num?)?.toStringAsFixed(0) ?? '0'}',
                                          style: TextStyle(
                                            color: tx['type'] == 'credit' 
                                                ? Colors.green
                                                : Colors.red,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
