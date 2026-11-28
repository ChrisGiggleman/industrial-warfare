# E3d5c6f Stage B2 — Physical Logistics Pickup, Delivery and Empty Return

**Status: B2 TARGETED ACCEPTED (2026-11-24): new B2 scene plus all five targeted compatibility scenes passed locally in Godot.** This is one isolated physical logistics mission, not a fully playable two-drone construction flow. B1 and Stage A were previously developer-local accepted (three F6 scenes in B1 gate). Original E3d5c6e 63 unique suites/880 manifest-expected checks is historical, not freshly rerun.

## Scope and accepted interfaces

Exact opt-in `res://scenes/core/playable_specialized_drones_e3d5c6f.tscn` is extended with **default-off** `B2LogisticsController`, `StorageDiscovery`, `SupplierReservations`. The previously accepted `SingleTickController` stays on and inert for B1 tests; B2 configuration explicitly disables it before enabling B2. One explicit B2 `step_b2(delta)` controls the whole mission, with no automatic `_process`, competing dispatcher, construction clock, scheduler worker permission, or builder flight. The builder stays idle.

B2 uses the original `PrototypeDroneStorageDiscovery` and `PrototypeDroneSupplierReservations` to reserve and physically debit **five Test Ingots** only after the authentic logistics drone arrives at an original real completed Storage dock. It uses the original battery-metered cargo pickup/delivery methods, original `BlueprintConstructionSiteStagingRegistry` and input port to deposit the complete bill into the correct authorized Ammunition Press staging buffer, then the original `BlueprintConstructionMaterialEscrow` to reserve the exact bill. The Stage A contract seals one internal provenance receipt, and only then may the empty logistics drone return physically to its original Hub/home while the site remains QUEUED. Added `PrototypeConstructionWorkerDrone.begin_specialized_logistics_return` and `finish_specialized_logistics_return` are exactly gated to this opt-in scene, original site, registry, escrow and authenticated receipt; they do **not** clear custody, grant worker readiness, charge, or transfer materials.

Source conservation at end: **Storage 15→10, cargo 0, staged buffer 0, original escrow holds 5; original Press remains QUEUED, zero progress, builder IDLE and no scheduler slot.** Return consumes real battery. Post-return original cargo assignment is intentionally still pinned; this one-job Stage B2 does not claim reusable logistics fleets or newly unlocked charging. Later Stage B3 will separate the actual worker admission; Stage C will close the full cancellation/return-to-stock path.

## Copy navigator and Godot local test order

**First F6 scene (NEW, DEVELOPER-LOCAL PASS):**
`res://tests/specialized_drone_logistics_e3d5c6f_b2_test.tscn`
Nine labeled sections A–I: planned refusal, real Storage and receiver, reserved inventory before pickup, metered cargo collection, exact original-site unload, held escrow and verified receipt, metered return, no duplicate/unearned construction, total physical material conservation. Sections are **not** authoritative individual assertion counts. Run with **F6**, not F5. If any assertion/parse error, stop and report screenshot before regression.

**Targeted compatibility (ALL FIVE PASSED LOCALLY, developer report):** 
- `res://tests/specialized_drone_single_owner_e3d5c6f_b1_test.tscn`
- `res://tests/specialized_drone_role_guards_e3d5c6f_stage_a_test.tscn`
- `res://tests/specialized_drone_handoff_e3d5c6f_stage_a_test.tscn`
- `res://tests/drone_physical_pickup_e3d5c5x5a_test.tscn`
- `res://tests/drone_physical_delivery_e3d5c5x5b_test.tscn`

These five existing accepted suites were **rerun successfully**, not five new unique suites. Source-derived expected printed sections: B1 9, Stage A guards 6, Stage A handoff 7, earlier pickup 12, earlier delivery 13. Report each individually. Do not add their totals to 880 or claim a fresh 63-suite full regression.

## Safety boundaries

No legacy source scene or test changes; only the current E3d5c6f opt-in scene and additive guarded methods in shared drone class. No mutation of Main, prior E3d5c6b/c/d/e scenes, settled fixtures or their defaults. No power production/network expansion, charging from caller booleans, worker admission, construction timer, builder launch, multi-load/multi-site work, recovery after cancel, or new ore/electricity. Preserve the developer's uncommitted local resource edits and keep draft PR #1 unmerged. Godot runtime unavailable to assistant; local F6 gate required.

**Acceptance:** 6/6 developer-local F6 scene runs passed at B2 gate: 1 new B2 and 5 accepted compatibility reruns. The source fixtures contain 56 labeled PASS sections total, not 56 individual assertions or newly added checks. The historical 63/880 baseline was not rerun. **Next gate:** separately guarded Stage B3 physical construction drone/worker-admission implementation; NOT implemented.


### 2026-11-24 — E3d5c6f B2 NEW ISOLATED F6 PASSED; TARGETED COMPATIBILITY PENDING

Developer confirmed the fixed `res://tests/specialized_drone_logistics_e3d5c6f_b2_test.tscn` passed locally after an earlier `configure_b2` setup assertion at line 62 was corrected. The B2 fixture has **9 labeled printed PASS sections** in source, not a measured independent assertion count. This is **1 new isolated scene passed**, not yet complete Stage B2 acceptance. Required targeted reruns **PENDING**: B1 single-owner; Stage A role guards and material handoff; E3d5c5x5a physical pickup; E3d5c5x5b physical delivery. Developer-local report only; assistant did not execute Godot. Do not add rerun counts to unique checks. Historical E3d5c6e 63/63 suites / 880 manifest-expected checks remain previously accepted, not rerun. Keep PR #1 draft and Main untouched. Stage B3 not started.

