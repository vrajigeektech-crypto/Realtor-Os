# Approval Workflow Implementation

## Overview

This document describes the complete implementation of the approval workflow system that allows users to launch workflows from the Review Recommendation Screen, which then require admin approval before execution.

## Workflow Flow

1. **User launches workflow** from Review Recommendation Screen
2. **Task created** with "pending" status in automation_tasks table
3. **Task appears** in both Queue Screen (user view) and Admin Content Approval Queue (admin view)
4. **Admin reviews** task in Admin Content Approval Queue
5. **Admin action**: Approve or Reject the task
6. **Status updates** on both screens in real-time

## Files Modified/Created

### 1. Database Functions (`supabase/migrations/20260305113829_add_approval_workflow_functions.sql`)

- **Updated automation_tasks table**: Added 'pending' and 'rejected' to status check constraint
- **approve_automation_task()**: RPC function to approve tasks (changes status to 'queued')
- **reject_automation_task()**: RPC function to reject tasks (changes status to 'rejected')
- **get_pending_tasks_for_admin()**: RPC function to get all pending tasks for admin review
- **Admin RLS policies**: Added policies for admins to view and update all tasks

### 2. Services

#### Admin Approval Service (`lib/services/admin_approval_service.dart`)
- `getPendingTasks()`: Fetches all pending tasks for admin approval
- `approveTask(taskId)`: Approves a task and updates status
- `rejectTask(taskId, reason)`: Rejects a task with optional reason
- `isCurrentUserAdmin()`: Checks if current user has admin role

#### Updated Recommendation Service (`lib/services/recommendation_service.dart`)
- Modified `purchasePromotion()` to create tasks with 'pending' status instead of 'queued'
- Updated `_mapStatus()` to handle 'pending' and 'rejected' statuses

### 3. UI Screens

#### Review Recommendation Screen (`lib/screens/review_recommendation_screen.dart`)
- No changes needed - already calls `purchasePromotion()` which now creates pending tasks

#### Automation Queue Screen (`lib/screens/automation_queue_screen.dart`)
- Added support for 'pending' and 'rejected' status display
- Added real-time refresh every 10 seconds
- Updated status colors: Amber for pending, darker red for rejected

#### Admin Content Approval Queue (`lib/admin_pannel/admin_content_approval_queue.dart`)
- Complete rewrite to use real data from database
- Added loading states and error handling
- Integrated with AdminApprovalService for approval/rejection actions
- Added user information display (email, name)
- Added success/error feedback via SnackBars

## Status Mapping

| Database Status | UI Display | Color |
|----------------|------------|-------|
| pending | Pending | Amber |
| queued | Scheduled | Blue |
| running | Processing | Orange |
| completed | Completed | Green |
| failed | Failed | Red |
| rejected | Rejected | Dark Red |

## Real-time Updates

- **Queue Screen**: Auto-refreshes every 10 seconds to show status changes
- **Admin Screen**: Refreshes after each approval/rejection action
- **User Experience**: Immediate visual feedback when status changes

## Testing

### Manual Testing Steps

1. **Launch Workflow**:
   - Navigate to Review Recommendation Screen
   - Click "Launch Workflow" on any recommendation
   - Verify tokens are deducted and task is created

2. **Check Queue Screen**:
   - Navigate to Automation Queue Screen
   - Verify new task appears with "Pending" status
   - Check that status color is amber

3. **Check Admin Queue**:
   - Navigate to Admin Content Approval Queue
   - Verify task appears in the list
   - Check user information is displayed correctly

4. **Approve Task**:
   - Click "Approve" button on admin screen
   - Verify success message appears
   - Check that task disappears from admin queue
   - Verify task status changes to "Scheduled" in user queue

5. **Reject Task**:
   - Launch another workflow to create a new pending task
   - Click "Reject" button on admin screen
   - Verify success message appears
   - Check that task disappears from admin queue
   - Verify task status changes to "Rejected" in user queue

### Automated Testing

Use the test script `test_approval_workflow.dart` to verify database functions work correctly.

## Database Schema Changes

### automation_tasks table
```sql
-- Status check constraint updated to include new values
CHECK (status IN ('pending', 'queued', 'running', 'completed', 'failed', 'rejected'))
```

### New RPC Functions
- `approve_automation_task(task_id, admin_user_id)`
- `reject_automation_task(task_id, admin_user_id, rejection_reason)`
- `get_pending_tasks_for_admin()`

## Security Considerations

- **RLS Policies**: Admins can view/update all tasks, users can only view their own
- **Function Security**: All RPC functions use SECURITY DEFINER with proper checks
- **Role-based Access**: Admin functions check for admin role in user metadata

## Error Handling

- **Database Errors**: Caught and displayed as user-friendly messages
- **Network Issues**: Graceful fallback with retry mechanisms
- **Permission Errors**: Clear error messages for insufficient permissions

## Future Enhancements

1. **WebSocket Integration**: Replace polling with real-time subscriptions
2. **Bulk Actions**: Allow admins to approve/reject multiple tasks at once
3. **Audit Trail**: Add logging for all approval/rejection actions
4. **Email Notifications**: Notify users when tasks are approved/rejected
5. **Comments System**: Allow admins to add notes when approving/rejecting

## Troubleshooting

### Common Issues

1. **Tasks not appearing in admin queue**:
   - Check if user has admin role in auth.users metadata
   - Verify RLS policies are correctly applied
   - Check database connection

2. **Status not updating**:
   - Verify RPC functions are properly created
   - Check if task status is 'pending' before approval/rejection
   - Review database logs for errors

3. **Real-time updates not working**:
   - Check timer is running in AutomationQueueScreen
   - Verify network connectivity
   - Check if data is being refreshed correctly

### Debug Commands

```sql
-- Check pending tasks
SELECT * FROM get_pending_tasks_for_admin();

-- Check all tasks for a user
SELECT * FROM automation_tasks WHERE user_id = 'USER_ID' ORDER BY created_at DESC;

-- Check RLS policies
SELECT * FROM pg_policies WHERE tablename = 'automation_tasks';
```

## Conclusion

The approval workflow system is now fully implemented and ready for testing. The system provides a complete end-to-end workflow from task creation to approval/rejection with real-time status updates across all screens.
