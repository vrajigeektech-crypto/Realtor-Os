import 'package:flutter/material.dart';
import '../layout/main_layout.dart';
import '../utils/app_styles.dart';
import '../widgets/task_header_card.dart';
import '../widgets/audit_log_widgets.dart';
import '../models/task_audit_models.dart';
import '../models/agent_task_item.dart';
import '../services/task_audit_service.dart';

/// Realtor OS – Task Audit Log Screen
class TaskAuditLogScreen extends StatefulWidget {
  final String? initialTaskId;
  
  const TaskAuditLogScreen({super.key, this.initialTaskId});

  @override
  State<TaskAuditLogScreen> createState() => _TaskAuditLogScreenState();
}

class _TaskAuditLogScreenState extends State<TaskAuditLogScreen> {
  final TaskAuditService _auditService = TaskAuditService();
  
  String? _selectedTaskId;
  List<AgentTaskItem> _availableTasks = [];
  bool _loadingTasks = false;

  @override
  void initState() {
    super.initState();
    _selectedTaskId = widget.initialTaskId;
    _loadAvailableTasks();
  }

  Future<void> _loadAvailableTasks() async {
    setState(() {
      _loadingTasks = true;
    });

    try {
      final tasks = await _auditService.getAgentTasks();
      
      if (!mounted) return;
      
      setState(() {
        _availableTasks = tasks;
        if (_selectedTaskId == null && tasks.isNotEmpty) {
          _selectedTaskId = tasks.first.taskId;
        }
        _loadingTasks = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _loadingTasks = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load tasks: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Task Audit Log',
      activeIndex: 8, // Tasks
      child: _TaskAuditLogLayout(
        selectedTaskId: _selectedTaskId,
        availableTasks: _availableTasks,
        loadingTasks: _loadingTasks,
        onTaskIdChanged: (taskId) {
          setState(() {
            _selectedTaskId = taskId;
          });
        },
      ),
    );
  }
}

class _TaskAuditLogLayout extends StatelessWidget {
  final String? selectedTaskId;
  final List<AgentTaskItem> availableTasks;
  final bool loadingTasks;
  final ValueChanged<String?> onTaskIdChanged;

  const _TaskAuditLogLayout({
    required this.selectedTaskId,
    required this.availableTasks,
    required this.loadingTasks,
    required this.onTaskIdChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeaderBar(context),
                const Divider(height: 0, color: AppStyles.borderSoft),
                Expanded(
                  child: selectedTaskId == null
                      ? const Center(
                          child: Text(
                            'Please select a task',
                            style: TextStyle(color: AppStyles.mutedText),
                          ),
                        )
                      : _buildContent(isMobile),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(bool isMobile) {
    final TaskAuditService service = TaskAuditService();
    
    return FutureBuilder<Map<String, dynamic>>(
      key: ValueKey(selectedTaskId), // Force rebuild when task changes
      future: Future.wait([
        service.getTaskAuditLogHeader(selectedTaskId!),
        service.getTaskAuditLogTaskHeader(selectedTaskId!),
        service.getTaskActivityFeed(selectedTaskId!),
      ]).then((results) => {
        'header': results[0] as TaskAuditHeader,
        'taskHeader': results[1] as TaskAuditTaskHeader,
        'entries': results[2] as List<TaskAuditEntry>,
      }),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error loading audit log: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Trigger rebuild
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final data = snapshot.data;
        if (data == null) {
          return const Center(
            child: Text(
              'No data available',
              style: TextStyle(color: AppStyles.mutedText),
            ),
          );
        }

        final taskHeader = data['taskHeader'] as TaskAuditTaskHeader;
        final entries = data['entries'] as List<TaskAuditEntry>;

        final events = entries.map((e) => e.toAuditEvent()).toList();

        return Container(
          color: Colors.transparent,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                child: TaskHeaderCard(
                  isMobile: false,
                  taskId: selectedTaskId!,
                  agentName: taskHeader.agentName,
                  agentInitials: taskHeader.agentInitials,
                  brokerageName: taskHeader.brokerageName,
                  totalTasks: taskHeader.totalTasks,
                  joinedDate: taskHeader.joinedDate,
                ),
              ),
              const Divider(height: 0, color: AppStyles.borderSoft),
              Expanded(
                child: events.isEmpty
                    ? const Center(
                        child: Text(
                          'No audit entries found',
                          style: TextStyle(color: AppStyles.mutedText),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final event = events[index];
                          final isLast = index == events.length - 1;
                          return InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) =>
                                    _EventDetailsDialog(event: event),
                              );
                            },
                            child: TimelineEventTile(
                              event: event,
                              showConnector: !isLast,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Task Audit Log',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  selectedTaskId != null
                      ? _getHeaderDescription()
                      : 'Select a task to view its audit log.',
                  style: const TextStyle(color: AppStyles.mutedText, fontSize: 12.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          if (availableTasks.length > 1) _buildTaskIdSelector(context),
        ],
      ),
    );
  }

  Widget _buildTaskIdSelector(BuildContext context) {
    // Find selected task for display
    final selectedTask = availableTasks.firstWhere(
      (task) => task.taskId == selectedTaskId,
      orElse: () => availableTasks.isNotEmpty ? availableTasks.first : AgentTaskItem(
        taskId: '',
        taskNumber: 0,
        title: 'No Task',
        status: 'open',
        createdAt: DateTime.now(),
      ),
    );

    return PopupMenuButton<String>(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppStyles.borderSoft),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loadingTasks)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else ...[
              Flexible(
                child: Text(
                  selectedTaskId != null
                      ? selectedTask.displayText
                      : 'Select Task',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: AppStyles.mutedText,
              ),
            ],
          ],
        ),
      ),
      itemBuilder: (context) {
        if (loadingTasks) {
          return [
            const PopupMenuItem(
              enabled: false,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ];
        }

        if (availableTasks.isEmpty) {
          return [
            const PopupMenuItem(
              enabled: false,
              child: Text(
                'No tasks available',
                style: TextStyle(color: AppStyles.mutedText),
              ),
            ),
          ];
        }

        // Show up to 10 recent tasks
        final tasksToShow = availableTasks.take(10).toList();
        
        return tasksToShow.map((task) {
          final isSelected = selectedTaskId == task.taskId;
          return PopupMenuItem<String>(
            value: task.taskId,
            child: Row(
              children: [
                if (isSelected)
                  Icon(
                    Icons.check,
                    size: 16,
                    color: AppStyles.accentRose,
                  )
                else
                  const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    task.displayText,
                    style: TextStyle(
                      color: isSelected
                          ? AppStyles.accentRose
                          : Colors.white,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
      onSelected: (taskId) {
        onTaskIdChanged(taskId);
      },
    );
  }

  String _getHeaderDescription() {
    if (selectedTaskId == null) {
      return 'Select a task to view its audit log.';
    }
    
    final selectedTask = availableTasks.firstWhere(
      (task) => task.taskId == selectedTaskId,
      orElse: () {
        // Try to parse last 4 chars as int, otherwise null
        int? taskNumber;
        if (selectedTaskId!.length > 4) {
          final lastFour = selectedTaskId!.substring(selectedTaskId!.length - 4);
          taskNumber = int.tryParse(lastFour);
        }
        return AgentTaskItem(
          taskId: selectedTaskId!,
          taskNumber: taskNumber,
          title: 'Task',
          status: 'open',
          createdAt: DateTime.now(),
        );
      },
    );
    
    return 'Internal event log for ${selectedTask.displayText}. Immutable history of all task actions.';
  }
}

class _EventDetailsDialog extends StatelessWidget {
  final AuditEvent event;
  const _EventDetailsDialog({required this.event});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF3E3144)),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF9EA3AE)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _detailRow('Actor', event.actor),
            _detailRow('Time', event.timeAgo),
            _detailRow('Description', event.description),
            if (event.details.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Additional Details:',
                style: TextStyle(
                  color: Color(0xFF9EA3AE),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...event.details.map(
                (d) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.circle,
                        size: 6,
                        color: Color(0xFFCE9799),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        d,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF9EA3AE), fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
