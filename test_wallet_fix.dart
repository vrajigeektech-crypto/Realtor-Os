import 'package:flutter/material.dart';
import 'lib/services/wallet_dashboard_service.dart';

// Simple test to verify wallet balance fix
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🧪 Testing wallet balance fix...');
  
  try {
    // Test 1: Get or create wallet
    final wallet = await WalletDashboardService.getOrCreateWallet();
    if (wallet != null) {
      print('✅ Wallet found: ${wallet['id']}');
      
      // Test 2: Get wallet balance
      final balance = await WalletDashboardService.getWalletBalance(wallet['id']);
      print('💰 Current balance: $balance');
      
      // Test 3: Add 1000 tokens
      print('➕ Adding 1000 tokens...');
      final success = await WalletDashboardService.creditTokens(
        walletId: wallet['id'],
        tokenAmount: 1000,
        referenceId: 'test_add_${DateTime.now().millisecondsSinceEpoch}',
      );
      
      if (success) {
        print('✅ Successfully added 1000 tokens');
        
        // Test 4: Check new balance
        await Future.delayed(Duration(seconds: 2)); // Wait for DB update
        final newBalance = await WalletDashboardService.getWalletBalance(wallet['id']);
        print('💰 New balance: $newBalance');
        
        if (newBalance! > balance) {
          print('🎉 SUCCESS: Wallet balance updated correctly!');
        } else {
          print('❌ ISSUE: Balance did not update as expected');
        }
      } else {
        print('❌ Failed to add tokens');
      }
      
      // Test 5: Get transaction history
      final transactions = await WalletDashboardService.getTransactionHistory(
        walletId: wallet['id'],
        limit: 5,
      );
      print('📜 Recent transactions (${transactions.length}):');
      for (var tx in transactions) {
        print('   ${tx['type']}: ${tx['amount']} - ${tx['description']}');
      }
      
    } else {
      print('❌ No wallet found');
    }
  } catch (e) {
    print('❌ Error during test: $e');
  }
  
  print('🏁 Test completed');
}
