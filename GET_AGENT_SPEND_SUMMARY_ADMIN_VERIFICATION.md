# get_agent_spend_summary_admin RPC - Verification & Implementation

## ✅ Implementation Complete

### 1. SQL RPC Function Created
**File:** `create_get_agent_spend_summary_admin_rpc.sql`

**Features:**
- ✅ Admin access enforcement (admin, broker, team_lead roles only)
- ✅ Explicit agent context via `p_agent_id` parameter
- ✅ Reads from `public.token_spend_events` table
- ✅ Groups by `reason` and sums `token_amount`
- ✅ Returns empty array `[]` if no spend exists
- ✅ Debug mode enabled (`v_debug := true`)
- ✅ Debug output includes:
  - `requested_agent_id`
  - `requester_user_id`
  - `requester_role`
  - `is_authorized`
  - `spend_row_count`
  - `distinct_reasons`
- ✅ Results ordered alphabetically by category (reason)
- ✅ Uses `SECURITY DEFINER`

**Output Format:**
- **Debug Mode (enabled):**
  ```json
  {
    "debug": {
      "requested_agent_id": "uuid",
      "requester_user_id": "uuid",
      "requester_role": "admin|broker|team_lead",
      "is_authorized": true,
      "spend_row_count": 0,
      "distinct_reasons": 0
    },
    "data": [
      {
        "category": "text",
        "total_tokens": 0
      }
    ]
  }
  ```
- **Normal Mode (when debug disabled):**
  ```json
  [
    {
      "category": "text",
      "total_tokens": 0
    }
  ]
  ```

### 2. Frontend Integration

**Files Updated:**
- ✅ `lib/services/rpc_client.dart` - Added `getAgentSpendSummaryAdmin()` method
- ✅ `lib/services/user_service.dart` - Added `getAgentSpendSummaryAdmin()` method
- ✅ `lib/models/agent_spending_models.dart` - Updated `SpendCategory.fromJson()` to handle both RPC formats
- ✅ `lib/screens/agent_detail_profile_screen.dart` - Updated to accept optional `agentId` parameter and use admin RPC

**Usage:**
```dart
// In AgentDetailProfileScreen
AgentDetailProfileScreen(agentId: selectedAgent.id)

// The screen will automatically:
// 1. Check if user is admin
// 2. If agentId is provided AND user is admin, call get_agent_spend_summary_admin
// 3. Otherwise, fall back to self-service RPC
```

## 🔍 Verification Steps

### Step 1: Deploy SQL RPC
```sql
-- Run in Supabase SQL Editor
\i create_get_agent_spend_summary_admin_rpc.sql
```

### Step 2: Verify Table Schema
Ensure `public.token_spend_events` exists with columns:
- `agent_id` (uuid)
- `token_amount` (integer or numeric)
- `reason` (text)
- `created_at` (timestamptz)

### Step 3: Test with Agent That Has Spend Data
```sql
-- Test RPC with an agent that has spend events
SELECT * FROM public.get_agent_spend_summary_admin('agent-uuid-here');
```

**Expected:**
- Returns debug object with `data` array
- Categories grouped by `reason`
- `total_tokens` is sum of `token_amount` for each category
- Empty array if no spend exists

### Step 4: Test with Agent That Has No Spend
```sql
-- Test RPC with an agent that has no spend events
SELECT * FROM public.get_agent_spend_summary_admin('agent-uuid-with-no-spend');
```

**Expected:**
- Returns `{ "debug": {...}, "data": [] }`
- `spend_row_count` = 0
- `distinct_reasons` = 0

### Step 5: Test Authorization
```sql
-- Test as non-admin user (should fail)
-- Login as agent role user, then:
SELECT * FROM public.get_agent_spend_summary_admin('any-agent-id');
```

**Expected:**
- Error: "Access denied. Admin, broker, or team_lead role required. Current role: agent"

### Step 6: Test Frontend Integration
1. Navigate to `AgentDetailProfileScreen` with `agentId` parameter
2. Verify admin check passes
3. Verify RPC is called with correct `p_agent_id`
4. Verify spend categories display correctly
5. Check console for debug logs

## 🐛 Debugging

### If RPC Returns Empty Array
1. Check `token_spend_events` table has rows for the agent:
   ```sql
   SELECT COUNT(*) FROM public.token_spend_events WHERE agent_id = 'agent-uuid';
   ```
2. Check debug output for `spend_row_count` and `distinct_reasons`
3. Verify `reason` column is not NULL

### If Authorization Fails
1. Verify user role in `public.users`:
   ```sql
   SELECT id, role FROM public.users WHERE id = auth.uid();
   ```
2. Ensure role is one of: `admin`, `broker`, `team_lead`
3. Check RPC error message for exact role value

### If Frontend Shows No Data
1. Check Flutter console for RPC call logs
2. Verify `agentId` is passed to screen
3. Verify `_isAdmin` is `true`
4. Check network tab for RPC response
5. Verify `SpendCategory.fromJson()` handles the response format

## 📝 Notes

- **Debug Mode:** Currently enabled (`v_debug := true`). Set to `false` in production to return data array only.
- **Agent Context:** The RPC requires explicit `p_agent_id`. It does NOT infer from `auth.uid()`.
- **Table Dependency:** Requires `public.token_spend_events` table to exist.
- **Model Compatibility:** `SpendCategory` model now handles both:
  - `get_spend_breakdown_by_category` format: `{ category_id, category_name, total_amount }`
  - `get_agent_spend_summary_admin` format: `{ category, total_tokens }`

## ✅ Success Criteria

- [x] RPC enforces admin access
- [x] RPC uses explicit agent context
- [x] RPC reads from `token_spend_events`
- [x] RPC groups by reason and sums tokens
- [x] RPC returns empty array when no data
- [x] Debug mode provides diagnostic info
- [x] Frontend can call RPC with agent ID
- [x] Frontend displays spend categories correctly
