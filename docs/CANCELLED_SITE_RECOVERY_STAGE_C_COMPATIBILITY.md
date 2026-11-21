# E3d5c6c — Stage C playable recovery targeted compatibility gate

Updated **2026-11-21**. Repository `ChrisGiggleman/industrial-warfare`, `main`; Godot **4.6.2 Stable**.

## Stage C isolated acceptance — CONFIRMED

The developer explicitly reported that **all 14/14 A–N checks** passed locally in `res://tests/playable_cancelled_site_recovery_e3d5c6c_stage_c_test.tscn`. This is **user-confirmed local Godot execution**, not assistant-executed verification.

The accepted tests cover: original same-drone Direct Build, custody ticket capture on Storage and Press authorization, 3/5-ingot physical delivery, cancellation and immutable locked staging, automatic recovery after prior rearm, real original-hover pickup and reserved return, unavailable dock wait, full destination wait, exact returned inventory conservation (15 total), generator-off charging block, finite recharge, single completion and no duplicate reuse. Original Main and ordinary Direct Build scenes remain unchanged.

Unique automated milestone baseline **advances from 60 suites / 836 checks to 61 suites / 850 checks**, adding this one new Stage C suite and 14 new checks. This does **not** imply a fresh full 61/850 combined regression.

## Targeted compatibility gate — ACCEPTED: 27/27 existing suites, 381/381 existing checks

**2026-11-21 local acceptance:** Developer explicitly reports **all 27/27 previously accepted suites and all 381/381 regression checks passed locally in Godot**. This is user-reported local execution, **not assistant-executed**. The 27 reruns overlap existing suites, so the unique milestone baseline remains **61 suites / 850 checks**; there is **no fresh full 61/850 combined regression**. The next gate is the separate **10-check manual playable verification** in [Stage C manual guide](CANCELLED_SITE_RECOVERY_STAGE_C_MANUAL.md).

After the Stage C exact-scene allowlist and opt-in adapter integration, rerun **the same 26 Stage B compatibility suites (368 checks) plus the Stage B isolated physical recovery suite (13 checks)**. All 27 were previously accepted before Stage C. Reruns are **not unique** and do not change the 61/850 baseline. The Stage C new 14-check suite is **not** part of these 27 reruns; its separate isolated acceptance was just recorded.

Manifest (source of truth): [`tools/cancelled_site_recovery_stage_c_compatibility.csv`](../tools/cancelled_site_recovery_stage_c_compatibility.csv).

### Complete F6 checklist

| # | Scene under `res://tests/` | Checks | Status |
|---:|---|---:|:---:|
| 01 | [`prototype_construction_worker_drone_e3d5c4u_test.tscn`](../tests/prototype_construction_worker_drone_e3d5c4u_test.tscn) | 16 | ✓ |
| 02 | [`prototype_drone_battery_dock_e3d5c4x_test.tscn`](../tests/prototype_drone_battery_dock_e3d5c4x_test.tscn) | 20 | ✓ |
| 03 | [`blueprint_material_staging_e3d5c4c_test.tscn`](../tests/blueprint_material_staging_e3d5c4c_test.tscn) | 16 | ✓ |
| 04 | [`blueprint_physical_staging_e3d5c4d_test.tscn`](../tests/blueprint_physical_staging_e3d5c4d_test.tscn) | 16 | ✓ |
| 05 | [`blueprint_site_staging_ownership_e3d5c4h_test.tscn`](../tests/blueprint_site_staging_ownership_e3d5c4h_test.tscn) | 16 | ✓ |
| 06 | [`blueprint_anchored_receiver_e3d5c4i_test.tscn`](../tests/blueprint_anchored_receiver_e3d5c4i_test.tscn) | 16 | ✓ |
| 07 | [`blueprint_receiver_recovery_audit_e3d5c4j_test.tscn`](../tests/blueprint_receiver_recovery_audit_e3d5c4j_test.tscn) | 12 | ✓ |
| 08 | [`blueprint_construction_material_escrow_e3d5c2a_test.tscn`](../tests/blueprint_construction_material_escrow_e3d5c2a_test.tscn) | 16 | ✓ |
| 09 | [`drone_storage_discovery_e3d5c5x3_test.tscn`](../tests/drone_storage_discovery_e3d5c5x3_test.tscn) | 12 | ✓ |
| 10 | [`drone_supplier_reservations_e3d5c5x4a_test.tscn`](../tests/drone_supplier_reservations_e3d5c5x4a_test.tscn) | 12 | ✓ |
| 11 | [`drone_return_reservations_e3d5c5x4b_test.tscn`](../tests/drone_return_reservations_e3d5c5x4b_test.tscn) | 14 | ✓ |
| 12 | [`drone_physical_pickup_e3d5c5x5a_test.tscn`](../tests/drone_physical_pickup_e3d5c5x5a_test.tscn) | 12 | ✓ |
| 13 | [`drone_physical_delivery_e3d5c5x5b_test.tscn`](../tests/drone_physical_delivery_e3d5c5x5b_test.tscn) | 13 | ✓ |
| 14 | [`drone_delivered_worker_e3d5c5x5c_test.tscn`](../tests/drone_delivered_worker_e3d5c5x5c_test.tscn) | 16 | ✓ |
| 15 | [`drone_cancelled_cargo_recovery_e3d5c5x6_test.tscn`](../tests/drone_cancelled_cargo_recovery_e3d5c5x6_test.tscn) | 13 | ✓ |
| 16 | [`drone_finite_hub_charging_e3d5c5x7a_test.tscn`](../tests/drone_finite_hub_charging_e3d5c5x7a_test.tscn) | 13 | ✓ |
| 17 | [`drone_cargo_worker_reuse_e3d5c5x7b_test.tscn`](../tests/drone_cargo_worker_reuse_e3d5c5x7b_test.tscn) | 16 | ✓ |
| 18 | [`drone_pre_pickup_cancellation_e3d5c5x7c1_test.tscn`](../tests/drone_pre_pickup_cancellation_e3d5c5x7c1_test.tscn) | 12 | ✓ |
| 19 | [`drone_post_delivery_cancellation_e3d5c5x7c2_test.tscn`](../tests/drone_post_delivery_cancellation_e3d5c5x7c2_test.tscn) | 13 | ✓ |
| 20 | [`drone_lost_site_recovery_e3d5c5x7c3_test.tscn`](../tests/drone_lost_site_recovery_e3d5c5x7c3_test.tscn) | 14 | ✓ |
| 21 | [`drone_automatic_dispatch_e3d5c5x8a_test.tscn`](../tests/drone_automatic_dispatch_e3d5c5x8a_test.tscn) | 14 | ✓ |
| 22 | [`drone_automatic_lifecycle_e3d5c5x8b_test.tscn`](../tests/drone_automatic_lifecycle_e3d5c5x8b_test.tscn) | 15 | ✓ |
| 23 | [`playable_automatic_construction_drone_stage_c_test.tscn`](../tests/playable_automatic_construction_drone_stage_c_test.tscn) | 13 | ✓ |
| 24 | [`playable_direct_build_authorization_e3d5c6b_test.tscn`](../tests/playable_direct_build_authorization_e3d5c6b_test.tscn) | 11 | ✓ |
| 25 | [`playable_direct_build_authorization_e3d5c6b_stage_b_test.tscn`](../tests/playable_direct_build_authorization_e3d5c6b_stage_b_test.tscn) | 14 | ✓ |
| 26 | [`cancelled_site_custody_e3d5c6c_stage_a_test.tscn`](../tests/cancelled_site_custody_e3d5c6c_stage_a_test.tscn) | 13 | ✓ |
| 27 | [`cancelled_site_physical_recovery_e3d5c6c_stage_b_test.tscn`](../tests/cancelled_site_physical_recovery_e3d5c6c_stage_b_test.tscn) | 13 | ✓ |
| | **27 previously accepted suites** | **381** | **ACCEPTED** |

### Execute

1. In VS Code run `git pull --ff-only origin main` (only if the working tree has no conflicting uncommitted changes).
2. In Godot, open each exact `res://tests/<scene>` from the checklist above in order, press **F6**, inspect the **Output** and **Debugger** tabs for all PASS checks and each suite's final passing banner.
3. Record progress carefully. If any suite fails or stops early, capture the **first Debugger error** and the preceding PASS lines. Fix only the proven issue, then rerun the failed scene; do **not** assume remaining suites passed.
4. Developer has now reported **all 27/27 suites and 381/381 checks passed locally**; acceptance is recorded. Use the checklist for later reruns. They are repeats and remain outside the unique 61/850 count.

## After compatibility — manual playable verification pending

Run **manual Stage C gameplay verification** in `res://scenes/core/playable_cancelled_site_recovery_e3d5c6c_stage_c.tscn`, not the automated test fixture. Follow the [dedicated Stage C 10-check manual guide](CANCELLED_SITE_RECOVERY_STAGE_C_MANUAL.md): perform actual mouse/key input for Direct Storage and Ammunition Press, post-delivery X cancellation, watch drone pickup from original site/return to eligible Storage, inspect HUD, Hub recharge and generator OFF, and validate original Main/Direct Build non-regression. Automated 14/14 does **not** constitute manual acceptance.

The separate original E3d5c6b Stage C **10-check manual gate remains pending**. Keep future research silos, storage drone stations, multi-trip/multi-item, persistence, fleet, and destruction features for later milestones.

**Current status: Stage C isolated 14/14 ACCEPTED; Stage C compatibility 27/381 ACCEPTED; Stage C manual 0/10 PENDING.**
