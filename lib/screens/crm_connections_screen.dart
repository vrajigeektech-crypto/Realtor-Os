import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
import '../services/ghl_connection_service.dart';
import '../services/supabase_service.dart';

class CrmConnectionsScreen extends StatefulWidget {
  const CrmConnectionsScreen({Key? key}) : super(key: key);

  @override
  State<CrmConnectionsScreen> createState() => _CrmConnectionsScreenState();
}

class _CrmConnectionsScreenState extends State<CrmConnectionsScreen> {
  final CrmConnectionService _crmService = CrmConnectionService();
  final FollowUpBossAuthService _fubAuthService = FollowUpBossAuthService();
  final GhlConnectionService _ghlService = GhlConnectionService();

  bool _loading = true;
  String? _errorMessage;
  String? _connectingProvider;
  
  final List<Map<String, dynamic>> crmSystems = [
    {'name': 'GoHighLevel', 'provider': 'gohighlevel', 'isConnected': false, 'logo': 'assets/logos/gohighlevel.png'},
    {'name': 'Follow Up Boss', 'provider': 'followupboss', 'isConnected': false, 'logo': 'assets/logos/followupboss.png'},
    {'name': 'kvCORE', 'provider': 'kvcore', 'isConnected': false, 'logo': 'assets/logos/kvcore.png'},
    {'name': 'Chime', 'provider': 'chime', 'isConnected': false, 'logo': 'assets/logos/chime.png'},
    {'name': 'LionDesk', 'provider': 'liondesk', 'isConnected': false, 'logo': 'assets/logos/liondesk.png'},
    {'name': 'Salesforce', 'provider': 'salesforce', 'isConnected': false, 'logo': 'assets/logos/salesforce.png'},
    {'name': 'HubSpot', 'provider': 'hubspot', 'isConnected': false, 'logo': 'assets/logos/hubspot.png'},
    {'name': 'Zoho CRM', 'provider': 'zoho', 'isConnected': false, 'logo': 'assets/logos/zoho.png'},
    {'name': 'Pipedrive', 'provider': 'pipedrive', 'isConnected': false, 'logo': 'assets/logos/pipedrive.png'},
    {'name': 'Freshsales', 'provider': 'freshsales', 'isConnected': false, 'logo': 'assets/logos/freshsales.png'},
    {'name': 'Top Producer', 'provider': 'topproducer', 'isConnected': false, 'logo': 'assets/logos/topproducer.png'},
    {'name': 'Real Geeks', 'provider': 'realgeeks', 'isConnected': false, 'logo': 'assets/logos/realgeeks.png'},
    {'name': 'BoomTown', 'provider': 'boomtown', 'isConnected': false, 'logo': 'assets/logos/boomtown.png'},
    {'name': 'Wise Agent', 'provider': 'wiseagent', 'isConnected': false, 'logo': 'assets/logos/wiseagent.png'},
    {'name': 'Cloze', 'provider': 'cloze', 'isConnected': false, 'logo': 'assets/logos/cloze.png'},
    {'name': 'Monday CRM', 'provider': 'monday', 'isConnected': false, 'logo': 'assets/logos/monday.png'},
    {'name': 'Close', 'provider': 'close', 'isConnected': false, 'logo': 'assets/logos/close.png'},
  ];

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoadConnections();
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
            crm['isConnected'] = connection['is_connected'] as bool? ?? false;
          } catch (e) {
            debugPrint('⚠️ [CRM] Error mapping connection for $provider: $e');
            crm['isConnected'] = false;
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

  Future<void> _connectFollowUpBoss() async {
    try {
      debugPrint('🔐 [FUB] Starting OAuth authentication flow');
      
      await _fubAuthService.initiateAuth();
      
      _showSuccessSnackBar('Opening Follow Up Boss authentication page...');
      debugPrint('✅ [FUB] OAuth flow initiated successfully');
    } catch (e) {
      debugPrint('❌ [FUB] OAuth initiation failed: $e');
      
      String errorMessage = 'Failed to connect Follow Up Boss';
      if (e.toString().contains('Configuration error')) {
        errorMessage = 'Server configuration error. Please contact support.';
      } else if (e.toString().contains('Could not open browser') || e.toString().contains('Could not launch')) {
        errorMessage = 'Could not open browser. Please check your system settings.';
      } else {
        errorMessage = 'Failed to connect: ${e.toString()}';
      }
      
      _showErrorSnackBar(errorMessage);
    }
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
                                isConnected: crm['isConnected'],
                                isLoading: isConnecting,
                                onTap: () => _handleConnection(
                                  crm['name'],
                                  crm['provider'],
                                  crm['isConnected'],
                                ),
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

class _GhlConnectionModal extends StatefulWidget {
  const _GhlConnectionModal({
    required this.onConnect,
  });

  final Future<void> Function(String apiKey, String locationId) onConnect;

  @override
  State<_GhlConnectionModal> createState() => _GhlConnectionModalState();
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
