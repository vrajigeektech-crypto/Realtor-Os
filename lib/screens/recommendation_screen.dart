import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recommendation_models.dart';
import '../services/recommendation_service.dart';
import '../services/balance_service.dart';
import '../services/wallet_dashboard_service.dart';
import '../core/app_colors.dart';
import 'purchase_tokens_screen.dart';

class RecommendationScreen extends StatefulWidget {
  final String? propertyId;

  const RecommendationScreen({
    super.key,
    this.propertyId,
  });

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  final RecommendationService _recommendationService = RecommendationService();
  final BalanceService _balanceService = BalanceService();
  
  List<PromotionItem> _recommendations = [];
  PromotionItem? _topPick;
  bool _isLoading = true;
  String? _error;
  List<String> _selectedItems = [];
  bool _isPurchasing = false;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final recommendations = await _recommendationService.getRecommendations(userId);
      final topPick = recommendations.isNotEmpty ? recommendations.first : null;

      setState(() {
        _recommendations = recommendations;
        _topPick = topPick;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _toggleSelection(String promotionId) {
    setState(() {
      if (_selectedItems.contains(promotionId)) {
        _selectedItems.remove(promotionId);
      } else {
        _selectedItems.add(promotionId);
      }
    });
  }

  Future<void> _handlePurchase(PromotionItem item) async {
    await _purchaseItems([item]);
  }

  Future<void> _handleBulkPurchase() async {
    final selectedPromotions = _recommendations
        .where((item) => _selectedItems.contains(item.id))
        .toList();
    
    await _purchaseItems(selectedPromotions);
  }

  Future<void> _purchaseItems(List<PromotionItem> items) async {
    if (items.isEmpty) return;

    setState(() {
      _isPurchasing = true;
    });

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final totalCost = items.fold<int>(0, (sum, item) => sum + item.tokenCost);
      final currentBalance = _balanceService.currentBalance;

      if (currentBalance < totalCost) {
        // Show insufficient balance dialog
        final missingTokens = totalCost - currentBalance.toInt();
        _showInsufficientBalanceDialog(missingTokens, items);
        return;
      }

      // Process purchase for each item
      for (final item in items) {
        final queueItem = await _recommendationService.purchasePromotion(
          userId: userId,
          promotionId: item.id,
          promotionTitle: item.title,
          tokenCost: item.tokenCost,
          propertyId: widget.propertyId,
        );

        if (queueItem == null) {
          throw Exception('Failed to purchase ${item.title}');
        }
      }

      // Show success message
      _showSuccessDialog(items);

      // Clear selections and reload
      setState(() {
        _selectedItems.clear();
      });
      await _loadRecommendations();

    } catch (e) {
      _showErrorDialog('Purchase failed: ${e.toString()}');
    } finally {
      setState(() {
        _isPurchasing = false;
      });
    }
  }

  void _showInsufficientBalanceDialog(int missingTokens, List<PromotionItem> items) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Insufficient Balance',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You need $missingTokens more tokens to complete this purchase.',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            const Text(
              'Buy exactly what you need - no forced large purchases!',
              style: TextStyle(color: Color(0xFFCE9799), fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PurchaseTokensScreen(
                    requiredTokens: missingTokens,
                    onPurchaseComplete: () {
                      Navigator.pop(context);
                      _purchaseItems(items);
                    },
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCE9799),
              foregroundColor: Colors.black,
            ),
            child: Text('Buy $missingTokens Tokens'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(List<PromotionItem> items) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Purchase Successful!',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              '${items.length} promotion(s) added to your automation queue',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'They will be processed automatically',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCE9799),
              foregroundColor: Colors.black,
            ),
            child: const Text('Great!'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Error',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK', style: TextStyle(color: Color(0xFFCE9799))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        title: const Text(
          'Promotion Marketplace',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          StreamBuilder<double>(
            stream: _balanceService.balanceStream,
            initialData: _balanceService.currentBalance,
            builder: (context, snapshot) {
              final balance = snapshot.data ?? 0.0;
              return Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFCE9799)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Color(0xFFCE9799),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${balance.toInt()} tokens',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFCE9799)),
            )
          : _error != null
              ? _buildErrorState()
              : Column(
                  children: [
                    // Top Pick Section
                    if (_topPick != null) _buildTopPickSection(),
                    
                    // Recommendations Grid
                    Expanded(
                      child: _buildRecommendationsGrid(),
                    ),
                    
                    // Bottom Action Bar
                    if (_selectedItems.isNotEmpty) _buildBottomActionBar(),
                  ],
                ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Color(0xFFCE9799),
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'Something went wrong',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadRecommendations,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCE9799),
              foregroundColor: Colors.black,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildTopPickSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFCE9799).withOpacity(0.2),
            const Color(0xFFCE9799).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCE9799)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFCE9799),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'TOP PICK',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.star,
                color: const Color(0xFFCE9799),
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                _topPick!.icon,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _topPick!.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Recommended for this property',
                      style: TextStyle(
                        color: const Color(0xFFCE9799).withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${_topPick!.tokenCost} tokens',
                    style: const TextStyle(
                      color: Color(0xFFCE9799),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _handlePurchase(_topPick!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCE9799),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    ),
                    child: const Text('Get Now'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsGrid() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: _recommendations.length,
        itemBuilder: (context, index) {
          final item = _recommendations[index];
          final isSelected = _selectedItems.contains(item.id);
          
          return _buildPromotionCard(item, isSelected);
        },
      ),
    );
  }

  Widget _buildPromotionCard(PromotionItem item, bool isSelected) {
    return GestureDetector(
      onTap: () => _toggleSelection(item.id),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFCE9799).withOpacity(0.1) : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFCE9799) : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and selection
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFCE9799).withOpacity(0.2) : Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFFCE9799),
                      size: 20,
                    ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${item.tokenCost} tokens',
                          style: const TextStyle(
                            color: Color(0xFFCE9799),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFCE9799).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item.category,
                            style: const TextStyle(
                              color: Color(0xFFCE9799),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionBar() {
    final selectedPromotions = _recommendations
        .where((item) => _selectedItems.contains(item.id))
        .toList();
    final totalCost = selectedPromotions.fold<int>(0, (sum, item) => sum + item.tokenCost);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        border: Border(
          top: BorderSide(color: Color(0xFFCE9799)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_selectedItems.length} item${_selectedItems.length == 1 ? '' : 's'} selected',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Total: $totalCost tokens',
                  style: const TextStyle(
                    color: Color(0xFFCE9799),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _isPurchasing ? null : _handleBulkPurchase,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCE9799),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: _isPurchasing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                : const Text(
                    'Purchase All',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
          ),
        ],
      ),
    );
  }
}
