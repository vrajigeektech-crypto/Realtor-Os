import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'wallet_dashboard_service.dart';

/// Global service to manage OST balance across the entire application
class BalanceService {
  static final BalanceService _instance = BalanceService._internal();
  factory BalanceService() => _instance;
  BalanceService._internal();

  final StreamController<double> _balanceController = StreamController<double>.broadcast();
  double _currentBalance = 0.0;

  Stream<double> get balanceStream => _balanceController.stream;
  double get currentBalance => _currentBalance;

  /// Initialize the balance service and start listening for balance changes
  Future<void> initialize() async {
    try {
      await _loadInitialBalance();
      _startRealtimeUpdates();
    } catch (e) {
      print('Error initializing balance service: $e');
    }
  }

  /// Load the initial balance from the wallet
  Future<void> _loadInitialBalance() async {
    try {
      final wallet = await WalletDashboardService.getOrCreateWallet();
      if (wallet != null) {
        final balance = await WalletDashboardService.getWalletBalance(wallet['id']);
        if (balance != null) {
          _currentBalance = balance;
          if (!_balanceController.isClosed) {
            _balanceController.add(_currentBalance);
          }
        }
      }
    } catch (e) {
      print('Error loading initial balance: $e');
    }
  }

  /// Start real-time updates for balance changes
  void _startRealtimeUpdates() {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // Watch wallet changes
      WalletDashboardService.watchWallet(user.id).listen((walletData) async {
        if (walletData['id'] != null) {
          final balance = await WalletDashboardService.getWalletBalance(walletData['id']);
          if (balance != null && balance != _currentBalance) {
            _currentBalance = balance;
            if (!_balanceController.isClosed) {
              _balanceController.add(_currentBalance);
            }
          }
        }
      });

      // Watch transaction changes
      WalletDashboardService.watchTransactions(user.id).listen((transactions) {
        // Refresh balance when transactions change
        _loadInitialBalance();
      });
    } catch (e) {
      print('Error starting realtime updates: $e');
    }
  }

  /// Format balance for display
  String formatBalance(double balance) {
    return balance.toStringAsFixed(2);
  }

  /// Get formatted balance string
  String get formattedBalance => formatBalance(_currentBalance);

  /// Dispose the service
  void dispose() {
    _balanceController.close();
  }
}
