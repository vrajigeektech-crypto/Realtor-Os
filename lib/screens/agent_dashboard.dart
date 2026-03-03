import 'package:flutter/material.dart';
import '../core/app_colors.dart';
// TODO: These imports are commented out because the classes don't exist yet
// import 'package:get/get.dart';
// import 'package:realtor/models/completed_asset_model.dart';
//import 'package:realtor/modules/dashboard/controler/asset_controller.dart';
//import 'package:realtor/modules/dashboard/controler/automation_queue_controller.dart';
//import 'package:realtor/modules/dashboard/controler/bpa_controller.dart';
//import 'package:realtor/modules/dashboard/controler/xp_controller.dart';
//import 'package:realtor/modules/dashboard/ui/asset_detail_bottom_sheet.dart';
//import 'package:realtor/modules/dashboard/ui/automation_task_detail_bottom_sheet.dart';
//import 'package:realtor/modules/dashboard/ui/bpa_history_bottom_sheet.dart';

class AgentDashboardWidget extends StatefulWidget {
  const AgentDashboardWidget({super.key});

  @override
  State<AgentDashboardWidget> createState() => _AgentDashboardWidgetState();
}

class _AgentDashboardWidgetState extends State<AgentDashboardWidget> {
  // TODO: Controllers commented out - they don't exist yet
  // late XpController xpController;
  // late AssetController assetController;
  // late AutomationQueueController automationQueueController;
  // late BpaController bpaController;

  @override
  void initState() {
    super.initState();
    // TODO: Initialize controllers when they exist
    // xpController = Get.put(XpController());
    // assetController = Get.put(AssetController());
    // automationQueueController = Get.put(AutomationQueueController());
    // bpaController = Get.put(BpaController());
  }

  void _go(String route) {
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F0F),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF4A3436), width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFCE9799).withOpacity(0.05),
              blurRadius: 20,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            // Top Metallic Bar
            Container(
              height: 12,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF2A2A2A),
                    Color(0xFF5A4A4C),
                    Color(0xFF2A2A2A),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // ===== KPI ROW =====
                  // TODO: Uncomment when BpaController exists
                  // Obx(() {
                  //   final bpa = bpaController.bpaOverview.value;
                  //   return Row(
                  //     children: [
                  //       _kpiCard(
                  //         'Active Clients',
                  //         '${bpa?.activeClients ?? 0}',
                  //         '/clients',
                  //       ),
                  //       SizedBox(width: 8),
                  //       _kpiCard(
                  //         'Total Buying Power',
                  //         '\$${((bpa?.totalBuyingPower ?? 0) / 1000000).toStringAsFixed(1)}M',
                  //         '/bpa',
                  //       ),
                  //       SizedBox(width: 8),
                  //       _kpiCard(
                  //         'Avg Buying Power',
                  //         '\$${((bpa?.averageBuyingPower ?? 0) / 1000).toStringAsFixed(0)}K',
                  //         '/bpa',
                  //       ),
                  //       SizedBox(width: 8),
                  //       _kpiCard('Appts Booked (7D)', '6', '/appointments'),
                  //     ],
                  //   );
                  // }),
                  Row(
                    children: [
                      _kpiCard('Active Clients', '0', '/clients'),
                      SizedBox(width: 8),
                      _kpiCard('Total Buying Power', '\$0M', '/bpa'),
                      SizedBox(width: 8),
                      _kpiCard('Avg Buying Power', '\$0K', '/bpa'),
                      SizedBox(width: 8),
                      _kpiCard('Appts Booked (7D)', '0', '/appointments'),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ===== BPA ANALYSIS =====
                  _section(
                    title: 'Buying Power Analysis',
                    action: GestureDetector(
                      onTap: () {
                        // TODO: Uncomment when BpaHistoryBottomSheet exists
                        // Get.bottomSheet(
                        //   BpaHistoryBottomSheet(
                        //     history: bpaController.bpaHistory,
                        //   ),
                        //   isScrollControlled: true,
                        // );
                      },
                      child: Text(
                        'View History',
                        style: TextStyle(
                          color: AppColors.roseGold.withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () => _go('/bpa'),
                      child: Builder(
                        builder: (context) {
                          // TODO: Uncomment when BpaController exists
                          // Obx(() {
                          //   final bpa = bpaController.bpaOverview.value;
                          return _card(
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // --- Funnel ---
                                SizedBox(
                                  width: 220,
                                  child: Column(
                                    children: [
                                      _buildFunnelItem('Leads in BPA Bot', 1.4),
                                      _buildFunnelItem('Pre-Qualified', 1.2),
                                      _buildFunnelItem('Fully Approved', 1),
                                      _buildFunnelItem('Under Contract', 0.8),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 24),
                                // --- Data Grid ---
                                Expanded(
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildBpaMetric(
                                              'BPA Issued YTD',
                                              '\$0',
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: _buildBpaMetric(
                                              'BPA Last 30 Days',
                                              '\$0',
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      const Divider(color: Colors.white10),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildBpaMetric(
                                              'BPA Last 30 Days',
                                              '\$0',
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: _buildBpaMetric(
                                              'Deals in Escrow',
                                              '0 | \$0',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                          // }),
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ===== DATABASE + CALLING =====
                  _section(
                    title: 'Database & Calling Command Center',
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _go('/database'),
                            child: _card(
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Contacts: 5,284',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  Text(
                                    'Never Contacted: 1,012',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  Text(
                                    'Stale 30+ Days: 456',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  Text(
                                    'Actively Nurturing: 782',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _go('/calling'),
                            child: Builder(
                              builder: (context) {
                                // TODO: Uncomment when XpController exists
                                // Obx(() {
                                //   final summary = xpController.weeklySummary.value;
                                return _card(
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Calls (7D): 0',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                      Text(
                                        'Conversations: 0',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                      Text(
                                        'Appointments: 0',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                      const Text(
                                        'Follow-Ups: 0',
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                );
                                // });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ===== OPERATOR PROGRESSION =====
                  Builder(
                    builder: (context) {
                      // TODO: Uncomment when XpController exists
                      // Obx(() {
                      //   final progression = xpController.operatorProgression.value;
                      //   final level = progression?.level ?? 1;
                      //   final levelLabel = progression?.levelLabel ?? 'Beginner';
                      //   final progress =
                      //       (progression?.progressPercent ?? 0) / 100.0;
                      //   final progressPercent = progression?.progressPercent ?? 0;
                      //   final nextUnlockTitle =
                      //       progression?.nextUnlock.title ?? 'Next Unlock';
                      final level = 1;
                      final levelLabel = 'Beginner';
                      final progress = 0.0;
                      final progressPercent = 0;
                      final nextUnlockTitle = 'Next Unlock';

                      return _section(
                        title: 'Operator Progression',
                        child: GestureDetector(
                          onTap: () => _go('/progression'),
                          child: _card(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Level $level – $levelLabel',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.local_fire_department,
                                          color: Colors.orange,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '0',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: Colors.white10,
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    AppColors.roseGold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Next Unlock: $nextUnlockTitle ($progressPercent%)',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                      // });
                    },
                  ),

                  const SizedBox(height: 20),

                  const SizedBox(height: 20),

                  _section(
                    title: 'AI Automation Queue',
                    child: Builder(
                      builder: (context) {
                        // TODO: Uncomment when AutomationQueueController exists
                        // Obx(() {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children:
                                    ['all', 'pending', 'completed', 'failed'].map(
                                      (status) {
                                        final isSelected = false; // TODO: Use controller when available
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            right: 8.0,
                                            bottom: 8.0,
                                          ),
                                          child: FilterChip(
                                            label: Text(
                                              status[0].toUpperCase() + status.substring(1),
                                              style: TextStyle(
                                                color: isSelected
                                                    ? Colors.black
                                                    : Colors.white70,
                                                fontSize: 12,
                                              ),
                                            ),
                                            selected: isSelected,
                                            onSelected: (bool selected) {
                                              // TODO: Uncomment when controller exists
                                              // if (selected) {
                                              //   automationQueueController
                                              //       .fetchQueueItemsByStatus(
                                              //         status,
                                              //       );
                                              // }
                                            },
                                            selectedColor: AppColors.roseGold,
                                            backgroundColor: const Color(
                                              0xFF2A2A2C,
                                            ),
                                            checkmarkColor: Colors.black,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                            ),
                                          ),
                                        );
                                      },
                                    ).toList(),
                              ),
                            ),
                            _card(
                              const Center(
                                child: Text(
                                  'No automation tasks in queue',
                                  style: TextStyle(color: Colors.white24),
                                ),
                              ),
                            ),
                            // TODO: Uncomment when controller exists
                            // if (automationQueueController.isLoading.value)
                            //   _card(
                            //     const Center(child: CircularProgressIndicator()),
                            //   )
                            // else if (automationQueueController.queueItems.isEmpty)
                            //   _card(
                            //     const Center(
                            //       child: Text(
                            //         'No automation tasks in queue',
                            //         style: TextStyle(color: Colors.white24),
                            //       ),
                            //     ),
                            //   )
                            // else
                            //   _card(
                            //     Column(
                            //       children: automationQueueController.queueItems
                            //           .map((item) {
                            //             return _buildQueueRow(
                            //               item.taskName,
                            //               item.status,
                            //               item.status == 'completed',
                            //               () async {
                            //                 await automationQueueController
                            //                     .fetchTaskDetail(item.taskId);
                            //                 if (automationQueueController
                            //                         .selectedTaskDetail
                            //                         .value !=
                            //                     null) {
                            //                   Get.bottomSheet(
                            //                     AutomationTaskDetailBottomSheet(
                            //                       task: automationQueueController
                            //                           .selectedTaskDetail
                            //                           .value!,
                            //                     ),
                            //                     isScrollControlled: true,
                            //                   );
                            //                 }
                            //               },
                            //             );
                            //           })
                            //           .toList(),
                            //     ),
                            //   ),
                          ],
                        );
                        // });
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ===== TOKEN ECONOMY =====
                  _section(
                    title: 'Token Economy Overview',
                    child: Column(
                      children: [
                        _buildTokenRow(
                          Icons.check_box_outlined,
                          'Monthly Burn',
                          '1,500 OST',
                        ),
                        const SizedBox(height: 12),
                        _buildTokenRow(
                          Icons.account_balance_wallet_outlined,
                          'Pending Rewards',
                          '800 OST',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ===== TRANSACTIONS =====
                  _section(
                    title: 'Latest Transactions',
                    child: _card(
                      Column(
                        children: [
                          _buildTransactionRow(
                            'Purchase Premium Report',
                            '-30 OST',
                            'Completed',
                          ),
                          const Divider(color: Colors.white10),
                          _buildTransactionRow(
                            'Reward: Profile Complete',
                            '+20 OST',
                            'Credited',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ===== FILES & ASSETS =====
                  _section(
                    title: 'Files & Assets',
                    child: _buildFilesAssetsSection(),
                  ),

                  const SizedBox(height: 16),

                  // ===== PRIMARY CTA =====
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.roseGold,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.all(16),
                      ),
                      onPressed: () => _go('/queue/priority'),
                      child: const Text(
                        'Call the 5 clients closest to approval',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Bottom Metallic Bar
            Container(
              height: 12,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF2A2A2A),
                    Color(0xFF5A4A4C),
                    Color(0xFF2A2A2A),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilesAssetsSection() {
    // TODO: Uncomment when AssetController exists
    // return Obx(() {
    //   if (assetController.isLoading.value) {
    //     return _card(const Center(child: CircularProgressIndicator()));
    //   }
    //
    //   if (assetController.completedAssets.isEmpty) {
    //     return _card(
    //       const Center(
    //         child: Text(
    //           'No assets found',
    //           style: TextStyle(color: Colors.white24),
    //         ),
    //       ),
    //     );
    //   }
    //
    //   return SizedBox(
    //     height: 100,
    //     child: ListView.separated(
    //       scrollDirection: Axis.horizontal,
    //       itemCount: assetController.completedAssets.length,
    //       separatorBuilder: (context, index) => const SizedBox(width: 12),
    //       itemBuilder: (context, index) {
    //         final asset = assetController.completedAssets[index];
    //         return _assetTile(asset);
    //       },
    //     ),
    //   );
    // });
    return _card(
      const Center(
        child: Text(
          'No assets found',
          style: TextStyle(color: Colors.white24),
        ),
      ),
    );
  }

  Widget _kpiCard(String label, String value, String route) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _go(route),
        child: _card(
          Column(
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 10),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section({
    required String title,
    required Widget child,
    Widget? action,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (action != null) action,
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _card(Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4A3436), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCE9799).withOpacity(0.02),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _assetTile(dynamic asset) {
    // TODO: Update when CompletedAssetModel exists
    return GestureDetector(
      onTap: () async {
        // TODO: Uncomment when AssetController exists
        // await assetController.showAssetDetails(asset.id);
        // if (assetController.selectedAsset.value != null) {
        //   Get.bottomSheet(
        //     AssetDetailBottomSheet(asset: assetController.selectedAsset.value!),
        //     isScrollControlled: true,
        //   );
        // }
      },
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1C),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insert_drive_file,
              color: AppColors.roseGold.withOpacity(0.7),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              asset?.name ?? 'Asset',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueRow(
    String task,
    String status,
    bool isChecked,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              isChecked ? Icons.check_box : Icons.check_box_outline_blank,
              color: AppColors.roseGold,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                task,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
            Text(
              status,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenRow(IconData icon, String label, String value) {
    return _card(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.roseGold, size: 20),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionRow(String title, String value, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          const SizedBox(width: 12),
          Text(
            status,
            style: TextStyle(
              color: status == 'Completed' ? Colors.green : Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFunnelItem(String label, double scale) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      width: 140 * scale,
      height: 28,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white10),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(color: Colors.white70, fontSize: 10),
      ),
    );
  }

  Widget _buildBpaMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
