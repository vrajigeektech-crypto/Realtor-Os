import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'shared_admin_navigation.dart';
import 'admin_user_agent_content.dart';
import 'admin_content_approval_queue.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          SharedAdminNavigation(
            selectedIndex: _selectedIndex,
            onSelect: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            workspaceName: 'Realtor OS Admin',
          ),
          Expanded(
            child: _buildSelectedScreen(),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedScreen() {
    switch (_selectedIndex) {
      case 0: // Dashboard
        return _buildDashboardScreen();
      case 1: // User Management
          return const AdminUserAgentContent();
      case 2: // Orders
        return _buildOrdersScreen();
      case 3: // Content Approval
        return const AdminContentApprovalQueueScreen();
      case 4: // Tasks
        return _buildTasksScreen();
      case 5: // Activity Log
        return _buildActivityLogScreen();
      case 6: // Automation
        return _buildAutomationScreen();
      default:
        return const AdminUserAgentContent();
    }
  }

  Widget _buildDashboardScreen() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Admin Dashboard',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w300,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: GridView.count(
              crossAxisCount: 4,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildDashboardCard(
                  'Total Users',
                  '1,234',
                  Icons.people_outline,
                  AppColors.buttonGold,
                ),
                _buildDashboardCard(
                  'Active Agents',
                  '56',
                  Icons.person_outline,
                  AppColors.roseGold,
                ),
                _buildDashboardCard(
                  'Pending Content',
                  '23',
                  Icons.pending_actions,
                  Colors.orange,
                ),
                _buildDashboardCard(
                  'Total Orders',
                  '892',
                  Icons.shopping_cart_outlined,
                  Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accentBrown),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+12%',
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersScreen() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Orders Management',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w300,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 32),
          Center(
            child: Text(
              'Orders management screen coming soon...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksScreen() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tasks Management',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w300,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 32),
          Center(
            child: Text(
              'Tasks management screen coming soon...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityLogScreen() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity Log',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w300,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 32),
          Center(
            child: Text(
              'Activity log screen coming soon...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutomationScreen() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Automation Settings',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w300,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 32),
          Center(
            child: Text(
              'Automation settings screen coming soon...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
