# XP Award RPC — Schema Fix & Usage

## 1. Inspect your `xp_rules` table (run in Supabase SQL)

```sql
SELECT * FROM public.xp_rules LIMIT 1;
```

If you see columns like `action`, `key`, or `event` instead of `event_key`, the migration adds `event_key` and backfills from them.

---

## 2. Apply the migration

Run the migration file:

**File:** `supabase/migrations/20250127000000_xp_rules_and_award_xp.sql`

It:

- Ensures `xp_rules` has `event_key` (adds and backfills from `action`/`key`/`event` if needed)
- Ensures `users.xp` exists
- Creates `xp_ledger` with `UNIQUE (user_id, event_ref)` for idempotency
- Creates/updates `award_xp_for_event(p_user_id, p_event_key, p_event_ref)` using `event_key`
- Seeds rules for `upload_logo`, `upload_photos`, `upload_selfies`, `upload_voice`

---

## 3. Final RPC signature (unchanged)

```sql
award_xp_for_event(p_user_id uuid, p_event_key text, p_event_ref text)
```

Returns: `{ "awarded": true|false, "xp": number, "reason"?: "already_awarded"|"no_rule_or_zero_xp"|"conflict" }`

---

## 4. Copy-paste Dart RPC calls

Use after completing onboarding steps (logo, photos, voice). Ensure you have `user.id` and a unique `eventRef` per occurrence (e.g. `upload_logo_${user.id}_${DateTime.now().millisecondsSinceEpoch}` or a stable id like step id).

### Option A — Using RpcClient (recommended)

```dart
import '../services/supabase_service.dart';

final user = SupabaseService.instance.client.auth.currentUser;
if (user != null) {
  final rpc = SupabaseService.instance.rpc;
  final result = await rpc.awardXpForEvent(
    userId: user.id,
    eventKey: 'upload_logo',
    eventRef: 'upload_logo_${user.id}_${DateTime.now().millisecondsSinceEpoch}',
  );
  if (result['awarded'] == true) {
    debugPrint('XP awarded: ${result['xp']}');
  }
}
```

### Option B — Raw RPC (copy-paste per event)

**After logo upload:**

```dart
await SupabaseService.instance.client.rpc(
  'award_xp_for_event',
  params: {
    'p_user_id': user.id,
    'p_event_key': 'upload_logo',
    'p_event_ref': 'upload_logo_${user.id}_${DateTime.now().millisecondsSinceEpoch}',
  },
);
```

**After gallery/photos save:**

```dart
await SupabaseService.instance.client.rpc(
  'award_xp_for_event',
  params: {
    'p_user_id': user.id,
    'p_event_key': 'upload_selfies',
    'p_event_ref': 'upload_selfies_${user.id}_${DateTime.now().millisecondsSinceEpoch}',
  },
);
```

**After voice upload:**

```dart
await SupabaseService.instance.client.rpc(
  'award_xp_for_event',
  params: {
    'p_user_id': user.id,
    'p_event_key': 'upload_voice',
    'p_event_ref': 'upload_voice_${user.id}_${DateTime.now().millisecondsSinceEpoch}',
  },
);
```

Use a **stable** `p_event_ref` if you want “once per user per event type” (e.g. `upload_logo_${user.id}`). Use a **unique** ref if you want “once per action” (e.g. with timestamp).

---

## 5. Idempotency

- `xp_ledger` has `UNIQUE (user_id, event_ref)`.
- The RPC checks the ledger first; if `(user_id, event_ref)` exists, it returns `{ "awarded": false, "reason": "already_awarded" }` and does not add XP again.
