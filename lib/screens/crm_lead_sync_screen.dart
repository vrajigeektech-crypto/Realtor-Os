import 'package:flutter/material.dart';
import '../widgets/connected_section_header.dart';
import '../widgets/crm_connection_card_connected.dart';
import '../widgets/sync_leads_button.dart';
import '../widgets/sync_progress_card.dart';
import '../widgets/sync_success_card.dart';
import '../services/supabase_service.dart';

enum SyncState { idle, syncing, success }

class CrmLeadSyncScreen extends StatefulWidget {
  const CrmLeadSyncScreen({
    super.key,
    this.initialState = SyncState.idle,
  });

  final SyncState initialState;

  @override
  State<CrmLeadSyncScreen> createState() => _CrmLeadSyncScreenState();
}

class _CrmLeadSyncScreenState extends State<CrmLeadSyncScreen> {
  late SyncState _state;

  @override
  void initState() {
    super.initState();
    _state = widget.initialState;
    if (_state == SyncState.syncing) {
      _startSync();
    }
  }

  Future<void> _startSync() async {
    setState(() => _state = SyncState.syncing);

    try {
      final supabase = SupabaseService.instance.client;
      final response = await supabase.functions.invoke('ghl_sync_leads');

      if (response.status != 200) {
        final errorData = response.data as Map<String, dynamic>?;
        final errorMessage = errorData?['error'] as String? ??
            errorData?['message'] as String? ??
            'Sync failed';
        throw Exception(errorMessage);
      }

      if (mounted) {
        setState(() => _state = SyncState.success);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _state = SyncState.idle);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SectionHeader(),
              const SizedBox(height: 24),
              const CrmConnectionCardConnected(),
              const SizedBox(height: 32),
              if (_state == SyncState.idle)
                SyncLeadsButton(onPressed: _startSync),
              if (_state == SyncState.syncing)
                const SyncProgressCard(),
              if (_state == SyncState.success)
                const SyncSuccessCard(),
            ],
          ),
        ),
      ),
    );
  }
}
