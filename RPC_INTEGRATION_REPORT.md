# RPC Integration Report

## 1️⃣ SLICE VALIDATION REPORT

### #DATA SLICE: agent_profile_header
**RPC:** `get_agent_profile_header`  
**Status:** VALID  
**Inputs:** none (all available)  
**Outputs:** All fields mapped  
**UI Fields Populated:**
- `User.name` ← `full_name`
- `User.title` ← `role`
- `User.company` ← `brokerage_name`
- `User.isActive` ← `status` (converted to boolean)
- `User.profileImageUrl` ← `avatar_url`

---

### #DATA SLICE: task_queue_table
**RPC:** `get_task_queue_table`  
**Status:** VALID  
**Inputs:** none (all available)  
**Outputs:** All fields mapped  
**UI Fields Populated:**
- `Task.id` ← `id`
- `Task.taskType` ← `task_type`
- `Task.status` ← `status` (mapped to enum)
- `Task.priority` ← `priority` (mapped to enum, nullable handled)
- `Task.slaCountdown` ← `sla_countdown` (nullable, defaults to "—")
- `Task.queuePosition` ← `queue_position` (nullable, defaults to 0)
- `Task.assignedAdmin` ← `assigned_admin_name`

---

### #DATA SLICE: task_overview_counts
**RPC:** `get_task_overview_counts`  
**Status:** VALID  
**Inputs:** none (all available)  
**Outputs:** All fields mapped  
**UI Fields Populated:**
- `TaskOverview.totalOpenTasks` ← `total_open_tasks`
- `TaskOverview.awaitingApproval` ← `awaiting_approval`
- `TaskOverview.slaBreachesToday` ← `sla_breaches_today`

---

### #DATA SLICE: task_detail
**RPC:** `view_task_detail`  
**Status:** VALID  
**Inputs:** `p_task_id` (uuid) - available from `Task.id`  
**Outputs:** All fields mapped  
**UI Fields Populated:**
- `TaskDetail.id` ← `id`
- `TaskDetail.title` ← `title`
- `TaskDetail.description` ← `description`
- `TaskDetail.category` ← `category`
- `TaskDetail.status` ← `status`
- `TaskDetail.tokenCost` ← `token_cost`
- `TaskDetail.xpReward` ← `xp_reward`
- `TaskDetail.createdAt` ← `created_at`
- `TaskDetail.updatedAt` ← `updated_at`

---

### #DATA SLICE: agent_nav_tabs
**RPC:** `get_agent_nav_tabs`  
**Status:** VALID  
**Inputs:** none (all available)  
**Outputs:** All fields mapped  
**UI Fields Populated:**
- `NavTab.id` ← `id`
- `NavTab.label` ← `label`

---

### #DATA SLICE: active_tab_state
**RPC:** `get_active_tab_state`  
**Status:** VALID (with limitation)  
**Inputs:** none (header x-tab not yet implemented - see notes)  
**Outputs:** String mapped  
**UI Fields Populated:**
- `_selectedTabId` ← RPC response (text)

**Note:** Custom header `x-tab` support requires Supabase client-level configuration. Currently using default behavior.

---

## 2️⃣ RPC BINDING CODE

### RPC Client Service
**File:** `lib/services/rpc_client.dart`
- All RPC methods implemented
- Error handling with null checks
- Type-safe return values

### Service Layer
**Files:**
- `lib/services/task_service.dart` - Task-related RPCs
- `lib/services/user_service.dart` - User/agent RPCs
- `lib/services/navigation_service.dart` - Navigation RPCs
- `lib/services/supabase_service.dart` - Supabase initialization

---

## 3️⃣ STATE MAPPING TABLE

### Agent Profile Header
```
RPC Output Field     →  UI State Field
------------------------------------------
id                   →  User.id
full_name            →  User.name
role                 →  User.title
brokerage_name       →  User.company
status               →  User.isActive (converted)
avatar_url           →  User.profileImageUrl
```

### Task Queue Table
```
RPC Output Field     →  UI State Field
------------------------------------------
id                   →  Task.id
task_type            →  Task.taskType
status               →  Task.status (enum mapped)
priority             →  Task.priority (enum mapped, nullable)
sla_countdown        →  Task.slaCountdown (nullable)
queue_position       →  Task.queuePosition (nullable)
assigned_admin_name  →  Task.assignedAdmin
```

### Task Overview Counts
```
RPC Output Field     →  UI State Field
------------------------------------------
total_open_tasks     →  TaskOverview.totalOpenTasks
awaiting_approval    →  TaskOverview.awaitingApproval
sla_breaches_today    →  TaskOverview.slaBreachesToday
```

### Task Detail
```
RPC Output Field     →  UI State Field
------------------------------------------
id                   →  TaskDetail.id
title                →  TaskDetail.title
description          →  TaskDetail.description
category             →  TaskDetail.category
status               →  TaskDetail.status
token_cost           →  TaskDetail.tokenCost
xp_reward            →  TaskDetail.xpReward
created_at           →  TaskDetail.createdAt
updated_at           →  TaskDetail.updatedAt
```

### Navigation Tabs
```
RPC Output Field     →  UI State Field
------------------------------------------
id                   →  NavTab.id
label                →  NavTab.label
```

---

## 4️⃣ EXECUTION ORDER

### Initial Screen Load
```
1. SupabaseService.initialize() - Must be called first in main()
2. UserService.getAgentProfileHeader()
3. TaskService.getTasks()
4. TaskService.getTaskOverview()
5. NavigationService.getAgentNavTabs()
6. NavigationService.getActiveTabState()
```

All RPCs execute in parallel using `Future.wait()` for optimal performance.

### Task Detail View
```
1. TaskService.getTaskDetail(taskId) - Called on task tap
```

---

## 5️⃣ CONFIGURATION REQUIRED

### Supabase Initialization
**File:** `lib/main.dart`

**REQUIRED:** Replace placeholder values:
```dart
await SupabaseService.instance.initialize(
  supabaseUrl: 'YOUR_SUPABASE_URL',  // ← Replace
  supabaseAnonKey: 'YOUR_SUPABASE_ANON_KEY',  // ← Replace
);
```

**Recommended:** Use environment variables:
```dart
await SupabaseService.instance.initialize(
  supabaseUrl: const String.fromEnvironment('SUPABASE_URL'),
  supabaseAnonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
);
```

---

## 6️⃣ KNOWN LIMITATIONS

1. **Custom Headers:** `get_active_tab_state` RPC expects `x-tab` header, but Supabase Flutter RPC doesn't support custom headers directly. This requires Supabase client-level configuration or PostgREST client usage.

2. **Status/Priority Mapping:** String values from RPC are mapped to enums using substring matching. Ensure RPC returns consistent string formats.

3. **Nullable Fields:** `priority`, `sla_countdown`, and `queue_position` are nullable in RPC but required in UI models. Default values are provided.

---

## 7️⃣ ERROR HANDLING

All RPC calls include:
- ✅ Loading state management
- ✅ Success state handling
- ✅ Error state with user-friendly messages
- ✅ Retry functionality on error screen

---

## 8️⃣ TESTING CHECKLIST

- [ ] Supabase URL and anon key configured
- [ ] All RPCs return expected data shapes
- [ ] Status enum mapping works correctly
- [ ] Priority enum mapping works correctly
- [ ] Nullable fields handled gracefully
- [ ] Error states display correctly
- [ ] Task detail view loads on tap
- [ ] Navigation tabs load from RPC
- [ ] Active tab state loads correctly

---

## ✅ READY FOR TESTING

All RPC bindings are complete and ready for integration testing.
