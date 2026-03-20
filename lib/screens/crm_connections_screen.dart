import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../new_flow/screens/crm_connection_dashboard_screen.dart';
import '../widgets/crm_connection_card.dart';
import '../screens/crm_lead_sync_screen.dart';
import '../screens/tasks_queue_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/content_approval_queue_screen.dart';
import '../screens/embedded_checkout_screen.dart';
import '../screens/integrations_screen.dart';
import '../screens/payments_infrastructure_integrations_screen.dart';
import '../screens/secure_trusted_checkout_screen.dart';
import '../screens/task_audit_log_screen.dart';
import '../screens/tiktok_listing_walkthrough_screen.dart';
import '../screens/user_agent_management_screen.dart';
import '../screens/agent_security_screen.dart';
import '../screens/agent_tasks_queue_screen.dart';
import '../screens/checkout_confirmation_ready_screen.dart';
import '../screens/connect_your_tools_screen.dart';
import '../screens/google_integrations_screen.dart';
import '../screens/order_management_screen.dart';
import '../screens/purchase_tokens_screen.dart';
import '../screens/sla_time_control_panel_screen.dart';
import '../screens/task_queue_screen.dart';
import '../screens/upload_for_client_review_screen.dart';
import '../screens/agent_detail_profile_screen.dart';
import '../screens/agent_spend_summary_compact_screen.dart';
import '../screens/automation_queue_screen.dart';
import '../screens/complete_purchase_screen.dart';
import '../services/crm_connection_service.dart';
import '../services/followupboss_auth_service.dart';
import '../services/followupboss_contact_service.dart';
import '../services/ghl_connection_service.dart';
import '../services/supabase_service.dart';

class CrmConnectionsScreen extends StatefulWidget {
  const CrmConnectionsScreen({Key? key}) : super(key: key);

  @override
  State<CrmConnectionsScreen> createState() => _CrmConnectionsScreenState();
}

class _CrmConnectionsScreenState extends State<CrmConnectionsScreen>
    with WidgetsBindingObserver {
  final CrmConnectionService _crmService = CrmConnectionService();
  final FollowUpBossAuthService _fubAuthService = FollowUpBossAuthService();
  final FollowUpBossContactService _fubContactService = FollowUpBossContactService();
  final GhlConnectionService _ghlService = GhlConnectionService();

  bool _loading = true;
  String? _errorMessage;
  String? _connectingProvider;
  Timer? _oauthPollingTimer;
  int _oauthPollCount = 0;
  static const int _maxOAuthPolls = 60; // 3 minutes at 3-second intervals
  
  final List<Map<String, dynamic>> crmSystems = [
    {
      'name': 'GoHighLevel',
      'provider': 'gohighlevel',
      'isConnected': false,
      'logo': 'assets/logos/gohighlevel.png',
      // Official HighLevel brand asset
      'logoUrl': 'https://images.leadconnectorhq.com/image/f_webp,q_90,w_400/remote/assets/company/gohighlevel-logo.png',
      'logoUrlFallback': 'https://www.google.com/s2/favicons?domain=gohighlevel.com&sz=128',
      'connectedAt': null,
      'metadata': null,
    },
    {
      'name': 'Follow Up Boss',
      'provider': 'followupboss',
      'isConnected': false,
      'logo': 'assets/logos/followupboss.png',
      // G2Crowd product social image (user-verified URL)
      'logoUrl': 'https://images.g2crowd.com/uploads/product/image/social_landscape/social_landscape_16426185626c57445e56e1361c0c6ae0/follow-up-boss.png',
      'logoUrlFallback': 'https://www.google.com/s2/favicons?domain=followupboss.com&sz=128',
      'connectedAt': null,
      'metadata': null,
    },
    {
      'name': 'kvCORE',
      'provider': 'kvcore',
      'isConnected': false,
      'logo': 'assets/logos/kvcore.png',
      'logoUrl': 'https://logo.clearbit.com/kvcore.com',
      'logoUrlFallback': 'https://www.google.com/s2/favicons?domain=kvcore.com&sz=128',
      'connectedAt': null,
      'metadata': null,
    },
    {
      'name': 'Chime',
      'provider': 'chime',
      'isConnected': false,
      'logo': 'assets/logos/chime.png',
      'logoUrl': 'https://logo.clearbit.com/chime.me',
      'logoUrlFallback': 'https://www.google.com/s2/favicons?domain=chime.me&sz=128',
      'connectedAt': null,
      'metadata': null,
    },
    {
      'name': 'LionDesk',
      'provider': 'liondesk',
      'isConnected': false,
      'logo': 'assets/logos/liondesk.png',
      'logoUrl': 'https://logo.clearbit.com/liondesk.com',
      'logoUrlFallback': 'https://www.google.com/s2/favicons?domain=liondesk.com&sz=128',
      'connectedAt': null,
      'metadata': null,
    },
    {
      'name': 'Salesforce',
      'provider': 'salesforce',
      'isConnected': false,
      'logo': 'assets/logos/salesforce.png',
      // Wikimedia Commons — stable, CORS-friendly PNG
      'logoUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f9/Salesforce.com_logo.svg/320px-Salesforce.com_logo.svg.png',
      'logoUrlFallback': 'https://www.google.com/s2/favicons?domain=salesforce.com&sz=128',
      'connectedAt': null,
      'metadata': null,
    },
    {
      'name': 'HubSpot',
      'provider': 'hubspot',
      'isConnected': false,
      'logo': 'assets/logos/hubspot.png',
      // Wikimedia Commons — stable, CORS-friendly PNG
      'logoUrl': 'https://upload.wikimedia.org/wikipedia/commons/7/71/HubSpot_Logo.png',
      'logoUrlFallback': 'https://www.google.com/s2/favicons?domain=hubspot.com&sz=128',
      'connectedAt': null,
      'metadata': null,
    },
    {
      'name': 'Zoho CRM',
      'provider': 'zoho',
      'isConnected': false,
      'logo': 'assets/logos/zoho.png',
      // Wikimedia Commons — stable, CORS-friendly PNG
      'logoUrl': 'https://upload.wikimedia.org/wikipedia/commons/9/96/Zoho-logo.png',
      'logoUrlFallback': 'https://www.google.com/s2/favicons?domain=zoho.com&sz=128',
      'connectedAt': null,
      'metadata': null,
    },
    {
      'name': 'Pipedrive',
      'provider': 'pipedrive',
      'isConnected': false,
      'logo': 'assets/logos/pipedrive.png',
      // Wikimedia Commons — stable CORS-friendly JPG
      'logoUrl': 'https://upload.wikimedia.org/wikipedia/commons/2/27/Pipedrive_logo.jpg',
      'logoUrlFallback': 'https://www.google.com/s2/favicons?domain=pipedrive.com&sz=128',
      'connectedAt': null,
      'metadata': null,
    },
    {
      'name': 'Freshsales',
      'provider': 'freshsales',
      'isConnected': false,
      'logo': 'assets/logos/freshsales.png',
      // Wikimedia Commons — Freshworks (Freshsales parent brand) logo
      'logoUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2f/Freshworks-vector-logo.svg/320px-Freshworks-vector-logo.svg.png',
      'logoUrlFallback': 'https://www.google.com/s2/favicons?domain=freshsales.io&sz=128',
      'connectedAt': null,
      'metadata': null,
    },
    {
      'name': 'Top Producer',
      'provider': 'topproducer',
      'isConnected': false,
      'logo': 'assets/logos/topproducer.png',
      'logoUrl': 'https://logo.clearbit.com/topproducer.com',
      'logoUrlFallback': 'https://www.google.com/s2/favicons?domain=topproducer.com&sz=128',
      'connectedAt': null,
      'metadata': null,
    },
    {
      'name': 'Real Geeks',
      'provider': 'realgeeks',
      'isConnected': false,
      'logo': 'assets/logos/realgeeks.png',
      'logoUrl': 'https://logo.clearbit.com/realgeeks.com',
      'logoUrlFallback': 'https://www.google.com/s2/favicons?domain=realgeeks.com&sz=128',
      'connectedAt': null,
      'metadata': null,
    },
    {
      'name': 'BoomTown',
      'provider': 'boomtown',
      'isConnected': false,
      'logo': 'assets/logos/boomtown.png',
      'logoUrl': 'https://logo.clearbit.com/boomtownroi.com',
      'logoUrlFallback': 'https://www.google.com/s2/favicons?domain=boomtownroi.com&sz=128',
      'connectedAt': null,
      'metadata': null,
    },
    {
      'name': 'Wise Agent',
      'provider': 'wiseagent',
      'isConnected': false,
      'logo': 'assets/logos/wiseagent.png',
      'logoUrl': 'https://logo.clearbit.com/wiseagent.com',
      'logoUrlFallback': 'https://www.google.com/s2/favicons?domain=wiseagent.com&sz=128',
      'connectedAt': null,
      'metadata': null,
    },
    {
      'name': 'Cloze',
      'provider': 'cloze',
      'isConnected': false,
      'logo': 'assets/logos/cloze.png',
      'logoUrl': 'https://logo.clearbit.com/cloze.com',
      'logoUrlFallback': 'https://www.google.com/s2/favicons?domain=cloze.com&sz=128',
      'connectedAt': null,
      'metadata': null,
    },
    {
      'name': 'Monday CRM',
      'provider': 'monday',
      'isConnected': false,
      'logo': 'assets/logos/monday.png',
      // Wikimedia Commons — stable, CORS-friendly PNG
      'logoUrl': 'https://upload.wikimedia.org/wikipedia/commons/c/ce/Monday.com_Logo.png',
      'logoUrlFallback': 'https://www.google.com/s2/favicons?domain=monday.com&sz=128',
      'connectedAt': null,
      'metadata': null,
    },
    {
      'name': 'Close',
      'provider': 'close',
      'isConnected': false,
      'logo': 'assets/logos/close.png',
      'logoUrl': 'https://logo.clearbit.com/close.com',
      'logoUrlFallback': 'https://www.google.com/s2/favicons?domain=close.com&sz=128',
      'connectedAt': null,
      'metadata': null,
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAuthAndLoadConnections();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopOAuthPolling();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // On mobile: reload when app returns to foreground after OAuth redirect
    if (state == AppLifecycleState.resumed) {
      _loadConnections();
    }
  }

  // ── OAuth polling (used on web where deep links are unavailable) ─────────────

  void _startFubOAuthPolling() {
    _stopOAuthPolling();
    _oauthPollCount = 0;
    debugPrint('🔄 [CRM] Starting OAuth polling (web)...');

    _oauthPollingTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) async {
        _oauthPollCount++;
        if (_oauthPollCount > _maxOAuthPolls) {
          debugPrint('⏰ [CRM] OAuth polling timed out');
          _stopOAuthPolling();
          return;
        }

        try {
          final conn = await _crmService.getCrmConnectionByProvider('followupboss');
          final isConnected = conn['is_connected'] as bool? ?? false;
          if (isConnected) {
            debugPrint('✅ [CRM] OAuth polling detected connection');
            _stopOAuthPolling();
            await _loadConnections();
            if (mounted) {
              _showSuccessSnackBar('Follow Up Boss connected');
            }
          }
        } catch (_) {
          // Ignore transient errors during polling
        }
      },
    );
  }

  void _stopOAuthPolling() {
    _oauthPollingTimer?.cancel();
    _oauthPollingTimer = null;
  }

  Future<void> _checkAuthAndLoadConnections() async {
    // Check authentication before making any RPC calls
    final user = SupabaseService.instance.client.auth.currentUser;
    final session = SupabaseService.instance.client.auth.currentSession;
    
    if (user == null || session == null) {
      debugPrint('⚠️ [CRM] User not authenticated - blocking RPC calls');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = 'Please log in first';
      });
      return;
    }

    debugPrint('✅ [CRM] User authenticated: ${user.email}');
    _loadConnections();
  }

  Future<void> _loadConnections() async {
    try {
      if (!mounted) return;
      setState(() {
        _loading = true;
        _errorMessage = null;
      });

      // Double-check auth before RPC call
      final user = SupabaseService.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated. Please log in first.');
      }

      debugPrint('📡 [CRM] Loading CRM connections');
      final connections = await _crmService.getCrmConnections();
      
      debugPrint('✅ [CRM] Loaded ${connections.length} connections');
      
      if (!mounted) return;
      setState(() {
        for (var crm in crmSystems) {
          final provider = crm['provider'] as String;
          try {
            final connection = connections.firstWhere(
              (conn) => (conn['provider'] as String?)?.toLowerCase() == provider.toLowerCase(),
              orElse: () => {},
            );
            // RPC returns access_token/refresh_token but no is_connected field;
            // derive connection status from token presence.
            final isConnected = (connection['is_connected'] as bool?) ??
                ((connection['access_token'] as String?)?.isNotEmpty == true ||
                    (connection['refresh_token'] as String?)?.isNotEmpty == true);
            crm['isConnected'] = isConnected;
            if (isConnected) {
              final rawDate = connection['created_at'];
              crm['connectedAt'] = rawDate != null ? DateTime.tryParse(rawDate.toString()) : null;
              crm['metadata'] = connection['metadata'] as Map<String, dynamic>?;
            } else {
              crm['connectedAt'] = null;
              crm['metadata'] = null;
            }
          } catch (e) {
            debugPrint('⚠️ [CRM] Error mapping connection for $provider: $e');
            crm['isConnected'] = false;
            crm['connectedAt'] = null;
            crm['metadata'] = null;
          }
        }
        _loading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('❌ [CRM] Failed to load connections: $e');
      debugPrint('   Stack: $stackTrace');
      
      if (!mounted) return;
      
      String errorMessage = e.toString();
      // Check for 401/authentication errors
      if (e.toString().contains('401') || 
          e.toString().contains('not authenticated') ||
          e.toString().contains('JWT')) {
        errorMessage = 'Session expired. Please log in again.';
      }
      
      setState(() {
        // Set all connections to false if RPC fails
        for (var crm in crmSystems) {
          crm['isConnected'] = false;
        }
        _loading = false;
        _errorMessage = errorMessage;
      });
    }
  }

  Future<void> _handleConnection(String crmName, String provider, bool currentStatus) async {
    if (_connectingProvider != null) {
      return;
    }

    try {
      if (!mounted) return;
      setState(() {
        _connectingProvider = provider;
      });

      if (currentStatus) {
        await _disconnectCrm(provider);
      } else {
        if (provider == 'followupboss') {
          await _connectFollowUpBoss();
        } else if (provider == 'gohighlevel') {
          await _showGhlConnectionModal();
        } else {
          _showComingSoonDialog(crmName);
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [CRM] Connection handling failed: $e');
      debugPrint('   Stack: $stackTrace');
      if (mounted) {
        _showErrorSnackBar('Failed to ${currentStatus ? "disconnect" : "connect"} $crmName: $e');
      }
    } finally {
      if (!mounted) return;
      setState(() {
        _connectingProvider = null;
      });
      await _loadConnections();
    }
  }

  Future<void> _handleManage(String crmName, String provider) async {
    // Show a brief loading indicator while fetching live CRM data
    setState(() => _connectingProvider = '__manage_$provider');

    int? totalContacts;
    Map<String, dynamic>? crmMetadata;

    try {
      if (provider == 'followupboss') {
        final result = await _fubContactService.getPeople(limit: 1);
        final meta = result['_metadata'] as Map<String, dynamic>?;
        totalContacts = meta?['total'] as int?;
      }
      final crmEntry = crmSystems.firstWhere(
        (c) => c['provider'] == provider,
        orElse: () => {},
      );
      crmMetadata = crmEntry['metadata'] as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('⚠️ [Manage] Could not fetch live CRM data: $e');
    } finally {
      if (mounted) setState(() => _connectingProvider = null);
    }

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CRMConnectionDashboardScreen(
          crmName: crmName,
          provider: provider,
          totalContacts: totalContacts,
          metadata: crmMetadata,
        ),
      ),
    );
  }

  Future<void> _showFubManageModal(String crmName) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF2a2a2a),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FubManageSheet(
        crmName: crmName,
        contactService: _fubContactService,
        onDisconnect: () async {
          Navigator.of(context).pop();
          await _disconnectCrm('followupboss');
          await _loadConnections();
        },
      ),
    );
  }

  Future<void> _connectFollowUpBoss() async {
    await _showFubConnectionModal();
  }

  Future<void> _showFubConnectionModal() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _FubConnectionModal(
        onConnect: (apiKey) async {
          await _fubAuthService.connectWithApiKey(apiKey: apiKey);

          if (!context.mounted) return;
          Navigator.of(context).pop();
          await _loadConnections();
          _showSuccessSnackBar('Follow Up Boss connected');
        },
        onOAuthConnect: () async {
          await _fubAuthService.initiateAuth();
          // On web, deep links don't work — poll the DB until the token
          // appears (set by fub-callback after the user grants access).
          // On mobile, didChangeAppLifecycleState(resumed) handles refresh.
          if (kIsWeb) {
            _startFubOAuthPolling();
          }
        },
      ),
    );
  }

  Future<void> _showGhlConnectionModal() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _GhlConnectionModal(
        onConnect: (apiKey, locationId) async {
          await _ghlService.connect(
            apiKey: apiKey,
            locationId: locationId,
          );
          
          // Try to sync contacts, but don't block on failure
          bool syncSucceeded = false;
          try {
            await _ghlService.syncContacts();
            syncSucceeded = true;
          } catch (syncError) {
            debugPrint('⚠️ [GHL] Connection succeeded but sync failed: $syncError');
            // Continue anyway - user can sync manually later
          }
          
          if (!context.mounted) return;
          Navigator.of(context).pop();
          
          if (syncSucceeded) {
            _showSuccessSnackBar('GHL Connected & Synced');
            if (!context.mounted) return;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (context) => const CrmLeadSyncScreen(
                  initialState: SyncState.syncing,
                ),
              ),
            );
          } else {
            _showSuccessSnackBar('GHL Connected (Sync failed - you can sync manually)');
            if (!context.mounted) return;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (context) => const CrmLeadSyncScreen(
                  initialState: SyncState.idle,
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _disconnectCrm(String provider) async {
    try {
      debugPrint('🔌 [CRM] Disconnecting $provider');
      await _crmService.disconnectCrm(provider);
      _showSuccessSnackBar('Successfully disconnected');
      debugPrint('✅ [CRM] Disconnected $provider');
    } catch (e) {
      debugPrint('❌ [CRM] Disconnect failed: $e');
      rethrow;
    }
  }

  void _showComingSoonDialog(String crmName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a2a),
        title: const Text(
          'Coming Soon',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '$crmName integration is coming soon!',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1a1a),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Connect Your CRM Systems',
              style: TextStyle(color: Color(0xFFd4a574), fontSize: 24),
            ),
            Text(
              'Link your CRM accounts.',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: $_errorMessage',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadConnections,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = constraints.maxWidth > 1200
                        ? 4
                        : constraints.maxWidth > 800
                            ? 3
                            : constraints.maxWidth > 500
                                ? 2
                                : 1;

                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(24),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.5,
                            ),
                            itemCount: crmSystems.length,
                            itemBuilder: (context, index) {
                              final crm = crmSystems[index];
                              final isConnecting = _connectingProvider == crm['provider'];
                              return CrmConnectionCard(
                                name: crm['name'],
                                logoPath: crm['logo'],
                                logoUrl: crm['logoUrl'] as String?,
                                logoUrlFallback: crm['logoUrlFallback'] as String?,
                                isConnected: crm['isConnected'],
                                isLoading: isConnecting,
                                connectedAt: crm['connectedAt'] as DateTime?,
                                metadata: crm['metadata'] as Map<String, dynamic>?,
                                onTap: () => _handleConnection(
                                  crm['name'],
                                  crm['provider'],
                                  crm['isConnected'],
                                ),
                                onManage: crm['isConnected'] == true
                                    ? () => _handleManage(crm['name'], crm['provider'])
                                    : null,
                              );
                            },
                          ),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: const BoxDecoration(
                            color: Color(0xFF2a2a2a),
                            border: Border(
                              top: BorderSide(color: Colors.white10, width: 1),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => const TasksQueueScreen(),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFd4a574),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                    ),
                                    child: const Text('Go to Task Queue'),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => DashboardScreen(),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFd4a574),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                    ),
                                      child: const Text('Go to Dashboard'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildDevButton(BuildContext context, String label, VoidCallback onPressed, {Color? color}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? const Color(0xFF2a2a2a),
        foregroundColor: Colors.white70,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: const Size(0, 36),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}

// ── FUB Manage Bottom Sheet ──────────────────────────────────────────────────

class _FubManageSheet extends StatefulWidget {
  const _FubManageSheet({
    required this.crmName,
    required this.contactService,
    required this.onDisconnect,
  });

  final String crmName;
  final FollowUpBossContactService contactService;
  final VoidCallback onDisconnect;

  @override
  State<_FubManageSheet> createState() => _FubManageSheetState();
}

class _FubManageSheetState extends State<_FubManageSheet> {
  int _tab = 0; // 0=People, 1=Create

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
              child: Row(
                children: [
                  const Icon(Icons.people_alt_outlined, color: Color(0xFFd4a574), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.crmName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: widget.onDisconnect,
                    icon: const Icon(Icons.link_off, size: 14, color: Colors.red),
                    label: const Text('Disconnect', style: TextStyle(color: Colors.red, fontSize: 12)),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white10),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _tab = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _tab == 0 ? const Color(0xFFd4a574) : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.group_outlined, size: 16,
                              color: _tab == 0 ? const Color(0xFFd4a574) : Colors.white54),
                          const SizedBox(width: 6),
                          Text(
                            'Get People',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _tab == 0 ? const Color(0xFFd4a574) : Colors.white54,
                              fontWeight: _tab == 0 ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _tab = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _tab == 1 ? const Color(0xFFd4a574) : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_add_outlined, size: 16,
                              color: _tab == 1 ? const Color(0xFFd4a574) : Colors.white54),
                          const SizedBox(width: 6),
                          Text(
                            'Create Person',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _tab == 1 ? const Color(0xFFd4a574) : Colors.white54,
                              fontWeight: _tab == 1 ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: _tab == 0
                  ? _FubPeopleView(contactService: widget.contactService, scrollController: scrollController)
                  : _FubCreatePersonView(contactService: widget.contactService),
            ),
          ],
        );
      },
    );
  }
}

// ── FUB People List ──────────────────────────────────────────────────────────

class _FubPeopleView extends StatefulWidget {
  const _FubPeopleView({required this.contactService, required this.scrollController});

  final FollowUpBossContactService contactService;
  final ScrollController scrollController;

  @override
  State<_FubPeopleView> createState() => _FubPeopleViewState();
}

class _FubPeopleViewState extends State<_FubPeopleView> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _people = [];
  bool _loading = true;
  String? _error;
  int _total = 0;
  int _offset = 0;
  static const int _limit = 20;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _fetchPeople();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPeople({bool reset = true}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _error = null;
        _offset = 0;
      });
    } else {
      setState(() => _loadingMore = true);
    }
    try {
      final q = _searchController.text.trim();
      final result = await widget.contactService.getPeople(
        limit: _limit,
        offset: reset ? 0 : _offset,
        query: q.isEmpty ? null : q,
      );
      final people = (result['people'] as List?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [];
      final meta = result['_metadata'] as Map<String, dynamic>?;
      final total = (meta?['total'] as num?)?.toInt() ?? people.length;
      if (!mounted) return;
      setState(() {
        if (reset) {
          _people = people;
          _offset = people.length;
        } else {
          _people.addAll(people);
          _offset += people.length;
        }
        _total = total;
        _loading = false;
        _loadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  String _personSubtitle(Map<String, dynamic> p) {
    final emails = p['emails'] as List?;
    final phones = p['phones'] as List?;
    final email = (emails?.isNotEmpty == true)
        ? (emails!.first as Map<String, dynamic>)['value']?.toString()
        : null;
    final phone = (phones?.isNotEmpty == true)
        ? (phones!.first as Map<String, dynamic>)['value']?.toString()
        : null;
    return [email, phone].where((s) => s != null && s.isNotEmpty).join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search people...',
                    hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 18),
                    filled: true,
                    fillColor: const Color(0xFF1a1a1a),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white38, size: 16),
                            onPressed: () {
                              _searchController.clear();
                              _fetchPeople();
                            },
                          )
                        : null,
                  ),
                  onSubmitted: (_) => _fetchPeople(),
                  onChanged: (v) => setState(() {}),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _fetchPeople(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFd4a574),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  minimumSize: Size.zero,
                ),
                child: const Text('Search', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ),
        if (!_loading)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  '$_total contact${_total == 1 ? '' : 's'}',
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFd4a574)))
              : _error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 40),
                          const SizedBox(height: 12),
                          Text(
                            _error!,
                            style: const TextStyle(color: Colors.red, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _fetchPeople,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : _people.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people_outline, color: Colors.white24, size: 48),
                              SizedBox(height: 12),
                              Text('No people found', style: TextStyle(color: Colors.white38)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: widget.scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          itemCount: _people.length + (_offset < _total ? 1 : 0),
                          itemBuilder: (context, i) {
                            if (i == _people.length) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: _loadingMore
                                      ? const CircularProgressIndicator(color: Color(0xFFd4a574))
                                      : TextButton(
                                          onPressed: () => _fetchPeople(reset: false),
                                          child: const Text(
                                            'Load more',
                                            style: TextStyle(color: Color(0xFFd4a574)),
                                          ),
                                        ),
                                ),
                              );
                            }
                            final person = _people[i];
                            final name = [person['firstName'], person['lastName']]
                                .where((s) => s != null && (s as String).isNotEmpty)
                                .join(' ');
                            final subtitle = _personSubtitle(person);
                            final tags = (person['tags'] as List?)
                                ?.map((t) => t.toString())
                                .toList() ??
                                [];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1a1a1a),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: const Color(0xFF2a3a2a),
                                  child: Text(
                                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  name.isNotEmpty ? name : 'Unknown',
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (subtitle.isNotEmpty)
                                      Text(
                                        subtitle,
                                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                                      ),
                                    if (tags.isNotEmpty)
                                      Wrap(
                                        spacing: 4,
                                        children: tags.map((tag) => Chip(
                                          label: Text(tag, style: const TextStyle(fontSize: 10, color: Colors.white70)),
                                          backgroundColor: const Color(0xFF3a3a1a),
                                          padding: EdgeInsets.zero,
                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          visualDensity: VisualDensity.compact,
                                        )).toList(),
                                      ),
                                  ],
                                ),
                                dense: true,
                              ),
                            );
                          },
                        ),
        ),
      ],
    );
  }
}

// ── FUB Create Person ────────────────────────────────────────────────────────

class _FubCreatePersonView extends StatefulWidget {
  const _FubCreatePersonView({required this.contactService});

  final FollowUpBossContactService contactService;

  @override
  State<_FubCreatePersonView> createState() => _FubCreatePersonViewState();
}

class _FubCreatePersonViewState extends State<_FubCreatePersonView> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _tagsController = TextEditingController();
  bool _loading = false;
  String? _error;
  String? _successMessage;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
      _successMessage = null;
    });
    try {
      final emails = _emailController.text.trim().isNotEmpty
          ? [_emailController.text.trim()]
          : <String>[];
      final phones = _phoneController.text.trim().isNotEmpty
          ? [_phoneController.text.trim()]
          : <String>[];
      final tags = _tagsController.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      final result = await widget.contactService.createPerson(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim().isEmpty
            ? null
            : _lastNameController.text.trim(),
        emails: emails,
        phones: phones,
        tags: tags,
      );

      if (!mounted) return;
      final name = [result['firstName'], result['lastName']]
          .where((s) => s != null && (s as String).isNotEmpty)
          .join(' ');
      setState(() {
        _loading = false;
        _successMessage = 'Created: ${name.isNotEmpty ? name : 'Person'} (ID: ${result['id']})';
      });
      _firstNameController.clear();
      _lastNameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _tagsController.clear();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  InputDecoration _fieldDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
      prefixIcon: icon != null ? Icon(icon, color: Colors.white38, size: 18) : null,
      filled: true,
      fillColor: const Color(0xFF1a1a1a),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.white12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.white12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFd4a574)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Add a new contact to Follow Up Boss',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: _fieldDecoration('First Name *', icon: Icons.person_outline),
                    enabled: !_loading,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: _fieldDecoration('Last Name'),
                    enabled: !_loading,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: _fieldDecoration('Email', icon: Icons.email_outlined),
              keyboardType: TextInputType.emailAddress,
              enabled: !_loading,
              validator: (v) {
                if (v != null && v.trim().isNotEmpty && !v.contains('@')) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: _fieldDecoration('Phone', icon: Icons.phone_outlined),
              keyboardType: TextInputType.phone,
              enabled: !_loading,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _tagsController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: _fieldDecoration('Tags (comma-separated)', icon: Icons.label_outline),
              enabled: !_loading,
            ),
            const SizedBox(height: 20),
            if (_error != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            if (_successMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.green, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _successMessage!,
                        style: const TextStyle(color: Colors.green, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ElevatedButton.icon(
              onPressed: _loading ? null : _submit,
              icon: _loading
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.person_add, size: 18),
              label: Text(_loading ? 'Creating...' : 'Create Person'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFd4a574),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── GHL Connection Modal ─────────────────────────────────────────────────────

class _GhlConnectionModal extends StatefulWidget {
  const _GhlConnectionModal({
    required this.onConnect,
  });

  final Future<void> Function(String apiKey, String locationId) onConnect;

  @override
  State<_GhlConnectionModal> createState() => _GhlConnectionModalState();
}

class _FubConnectionModal extends StatefulWidget {
  const _FubConnectionModal({
    required this.onConnect,
    required this.onOAuthConnect,
  });

  final Future<void> Function(String apiKey) onConnect;
  final Future<void> Function() onOAuthConnect;

  @override
  State<_FubConnectionModal> createState() => _FubConnectionModalState();
}

class _FubConnectionModalState extends State<_FubConnectionModal> {
  final _formKey = GlobalKey<FormState>();
  final _apiKeyController = TextEditingController();
  bool _isLoading = false;
  bool _isOAuthLoading = false;
  String? _errorMessage;
  bool _obscureKey = true;

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await widget.onConnect(_apiKeyController.text.trim());
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceAll('Exception: ', '');
      setState(() {
        _errorMessage = msg;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleOAuth() async {
    if (!mounted) return;
    setState(() {
      _isOAuthLoading = true;
      _errorMessage = null;
    });

    try {
      await widget.onOAuthConnect();
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceAll('Exception: ', '');
      setState(() {
        _errorMessage = msg;
        _isOAuthLoading = false;
      });
    }
  }

  bool get _busy => _isLoading || _isOAuthLoading;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2a2a2a),
      title: const Text(
        'Connect Follow Up Boss',
        style: TextStyle(color: Colors.white),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // OAuth section
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _busy ? null : _handleOAuth,
                  icon: _isOAuthLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.open_in_browser, size: 18),
                  label: const Text('Connect with OAuth'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3d6b9e),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Opens Follow Up Boss in your browser to authorize access.',
                style: TextStyle(color: Colors.white54, fontSize: 11),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Expanded(child: Divider(color: Colors.white24)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'or use API key',
                      style: TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ),
                  const Expanded(child: Divider(color: Colors.white24)),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _apiKeyController,
                decoration: InputDecoration(
                  labelText: 'Follow Up Boss API Key',
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFd4a574)),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureKey ? Icons.visibility : Icons.visibility_off,
                      color: Colors.white70,
                    ),
                    onPressed: _busy
                        ? null
                        : () {
                            setState(() {
                              _obscureKey = !_obscureKey;
                            });
                          },
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                obscureText: _obscureKey,
                enabled: !_busy,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your Follow Up Boss API key';
                  }
                  return null;
                },
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.5)),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.white70),
          ),
        ),
        ElevatedButton(
          onPressed: _busy ? null : _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFd4a574),
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Connect with Key'),
        ),
      ],
    );
  }
}

class _GhlConnectionModalState extends State<_GhlConnectionModal> {
  final _formKey = GlobalKey<FormState>();
  final _apiKeyController = TextEditingController();
  final _locationIdController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _apiKeyController.dispose();
    _locationIdController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await widget.onConnect(
        _apiKeyController.text.trim(),
        _locationIdController.text.trim(),
      );
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceAll('Exception: ', '');
      setState(() {
        _errorMessage = msg;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2a2a2a),
      title: const Text(
        'Connect GoHighLevel',
        style: TextStyle(color: Colors.white),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _apiKeyController,
                decoration: const InputDecoration(
                  labelText: 'GHL API Key',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFd4a574)),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                obscureText: true,
                enabled: !_isLoading,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your GHL API Key';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _locationIdController,
                decoration: const InputDecoration(
                  labelText: 'GHL Location ID',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFd4a574)),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                enabled: !_isLoading,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your GHL Location ID';
                  }
                  return null;
                },
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.5)),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.white70),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFd4a574),
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Connect'),
        ),
      ],
    );
  }
}
