# E3d5c6a final building expansion regression

**Manual 9/9 accepted 2026-11-18; final combined automated rerun pending.** Stage A 8/8 + 29/29 targeted compatibility, Stage B 12/12 + 198/198 targeted compatibility, Stage C isolated 11/11 (developer reported pass against [d604d37](https://github.com/ChrisGiggleman/industrial-warfare/commit/d604d3710bb20572425aa65ab22a0174f7bb0d70)). Cumulative unique 56 suites / 785 checks. New manual expansion 9/9 developer-confirmed; historical Storage manual 9/9 remains separate. No independent assistant runtime execution. Run fresh combined automated gate before Direct Build Authorization. Main/ordinary scenes unchanged.

## Combined targeted regression (not whole-project)

F6 each scene under res://tests/. Original 52 suites / 741 checks preserved exactly; previous playable Drone Stage C 13 and Expansion A/B/C 8/12/11 appended = 56/785. Do not double-count previous reruns. Inventory transfer has four PASS groups instead of ALL banner. Review errors, warnings and completion groups. 

| Scene | Expected checks |
|---|---:|
| `inventory_trasnfer_test.tscn` | 4 |
| `item_port_transfer_test.tscn` | 7 |
| `manufacturing_transaction_test.tscn` | 9 |
| `recipe_output_capacity_test.tscn` | 11 |
| `conveyor_automatic_loading_test.tscn` | 10 |
| `conveyor_automatic_unloading_test.tscn` | 9 |
| `conveyor_connected_transport_test.tscn` | 7 |
| `conveyor_splitter_test.tscn` | 10 |
| `conveyor_merger_test.tscn` | 10 |
| `conveyor_physical_only_conservation_test.tscn` | 9 |
| `timed_storage_conveyor_delivery_test.tscn` | 6 |
| `blueprint_construction_material_escrow_e3d5c2a_test.tscn` | 16 |
| `unified_receiver_consolidation_e3d5c5v_test.tscn` | 56 |
| `playable_construction_logistics_e3d5c5w_test.tscn` | 13 |
| `playable_construction_power_e3d5c5x1_test.tscn` | 9 |
| `playable_construction_drone_e3d5c5x2_test.tscn` | 11 |
| `drone_storage_discovery_e3d5c5x3_test.tscn` | 12 |
| `drone_supplier_reservations_e3d5c5x4a_test.tscn` | 12 |
| `world_salvage_destruction_test.tscn` | 12 |
| `destruction_cargo_recovery_test.tscn` | 12 |
| `drone_return_reservations_e3d5c5x4b_test.tscn` | 14 |
| `prototype_construction_worker_drone_e3d5c4u_test.tscn` | 16 |
| `prototype_drone_worker_readiness_e3d5c4v_test.tscn` | 21 |
| `prototype_construction_drone_fleet_e3d5c4w_test.tscn` | 21 |
| `prototype_drone_battery_dock_e3d5c4x_test.tscn` | 20 |
| `prototype_construction_drone_reuse_e3d5c4y_test.tscn` | 20 |
| `prototype_construction_drone_tick_e3d5c4z_test.tscn` | 20 |
| `sandbox_construction_drone_bridge_e3d5c5a_test.tscn` | 20 |
| `drone_physical_pickup_e3d5c5x5a_test.tscn` | 12 |
| `blueprint_material_staging_e3d5c4c_test.tscn` | 16 |
| `blueprint_physical_staging_e3d5c4d_test.tscn` | 16 |
| `blueprint_site_staging_ownership_e3d5c4h_test.tscn` | 16 |
| `blueprint_anchored_receiver_e3d5c4i_test.tscn` | 16 |
| `blueprint_owned_readiness_e3d5c4r_test.tscn` | 18 |
| `blueprint_receiver_recovery_audit_e3d5c4j_test.tscn` | 12 |
| `drone_physical_delivery_e3d5c5x5b_test.tscn` | 13 |
| `construction_readiness_coordinator_e3d5c3c1_test.tscn` | 18 |
| `blueprint_construction_readiness_e3d5c1_test.tscn` | 15 |
| `drone_delivered_worker_e3d5c5x5c_test.tscn` | 16 |
| `drone_cancelled_cargo_recovery_e3d5c5x6_test.tscn` | 13 |
| `construction_power_coverage_e3d5c3a_test.tscn` | 16 |
| `completed_power_structures_e3d5c3b1_test.tscn` | 16 |
| `finite_construction_power_e3d5c3b2_test.tscn` | 18 |
| `drone_finite_hub_charging_e3d5c5x7a_test.tscn` | 13 |
| `drone_cargo_worker_reuse_e3d5c5x7b_test.tscn` | 16 |
| `drone_pre_pickup_cancellation_e3d5c5x7c1_test.tscn` | 12 |
| `drone_post_delivery_cancellation_e3d5c5x7c2_test.tscn` | 13 |
| `drone_lost_site_recovery_e3d5c5x7c3_test.tscn` | 14 |
| `drone_automatic_dispatch_e3d5c5x8a_test.tscn` | 14 |
| `drone_automatic_lifecycle_e3d5c5x8b_test.tscn` | 15 |
| `playable_automatic_construction_drone_stage_a_test.tscn` | 8 |
| `playable_automatic_construction_drone_stage_b_test.tscn` | 8 |
| `playable_automatic_construction_drone_stage_c_test.tscn` | 13 |
| `playable_construction_building_expansion_e3d5c6a_test.tscn` | 8 |
| `playable_construction_building_expansion_e3d5c6a_stage_b_test.tscn` | 12 |
| `playable_construction_building_expansion_e3d5c6a_stage_c_test.tscn` | 11 |
| **Total (56 suites)** | **785** |

Optional new local batch runner, from repo root with imported Godot project:
```powershell
.\tools\run_building_expansion_final_regression.ps1 -GodotExe "C:\path\to\Godot_v4.6.2-stable_win64_console.exe"
```
Use actual console executable. This preserves original runner and manifest unchanged; new runner is a copy with different manifest and expected counts. No assistant execution. Per-scene output and results.csv in temp folder; CANDIDATE is not accepted; verify logs/check groups, F6 all REVIEW or errors. Report exact suites/counts. No added logs to git.

## Manual playable expansion — 9/9 accepted (developer-confirmed)

Use F6 on `res://scenes/core/playable_construction_building_expansion_e3d5c6a.tscn` (not an automated test). Fresh scene 15 ingots, battery 40, one drone, one worker slot, 12-unit generator. Use Blueprint mode (P while placement mode is active), NOT regular Build mode; legacy direct placement is intentionally unchanged and would bypass the experimental test. Default building rotation. The Stage C F6 test proved these non-overlapping covered fixture positions: Press (4.5,0,-3.5) labeled AMMO PRESS SITE; High Storage (0,0,-3) labeled STORAGE SITE; Low Storage (4,0,-1), near Press toward central reference cube along +Z. Second waiting Press (2.5,0,-0.5). Only the first two are marked with existing guides. Do not add guide geometry or game code. If exact third/second Press positioning is unclear, inspect cursor/ghost footprint and power coverage, capture screenshots for review; avoid overlaps or changing settings to force acceptance.

First run:
1. Initial HUD shows 15 stock, 40/40 battery, 0 cargo, no reservations/worker slots/rearms.
2. Create Low Storage first, Press second, High Storage third at the above positions. Q+drag/select each or use the existing priority dock to set Low, High, High respectively. Leave a fourth Press unplanned until later. Observe plans remain ghosted, stock unchanged and drone idle without E.
3. Ctrl+E authorizes all three in one input event while Blueprint placement mode is active. Expect Press first (High FIFO before later High Storage, both before older Low); visible exact 5 reserved, then pickup at source, stock 10 and cargo 5, physical delivery cargo 0.
4. During Press construction switch generator off with HUD button, verify paused progress and no other job starts; reenable and verify original Press resumes.
5. Press completes once into the real operational machine with input/output ports; no production material from construction stock. Drone travels home, battery visibly replenishes to 40 before another dispatch.
6. High Storage then Low Storage complete, each exact cargo 3 and stock 7 then 4; third return/rearm finishes with battery 40, no reservations/cargo/active worker. Same drone, three completed buildings, 11 committed ingots. Observe HUD.
7. Place and authorize fourth Press at WAIT_POS. With 4 ingots, wait for several seconds; no pickup, no partial delivery or progress, stock 4, drone idle and queued materials requirement.

Fresh second run (stop/restart F6 resets fixture to 15); first guide Press only:
8. Authorize Press and cancel using X while drone carries 5 (stock 10, cargo 5). Observe physical return/deposit to starter Storage, then Hub and finite recharge: 15 stock, 0 cargo/claims/active worker, 1 rearm; no completed Press. If missed window restart.
9. Replan Press after first cancellation and recharge, authorize and let it begin work. Cancel with X during actual progress. Verify ghost removed, no completed building, original five delivered ingots remain protected in staging (not remotely deposited back), stock 10, cargo 0, no reservation/active worker, 2 rearms. HUD does not directly enumerate protected buffer; manual observation is no stock refund or duplication, exact buffer contents already covered by Stage B automated check L. Do not unlock staged stock or use legacy Build.

Developer confirmed all nine checks passed, with no failures or skips reported. Retain checklist for future reruns; manual checks remain separate from automated totals.

After both gates pass: record closeout, recommend separate Direct Build Authorization Stage A with explicit new scene/feature gates, direct placement Normal queue authorization, no fallback instant builds for unsupported definitions, no changes to existing playable scenes. Preserve explicit blueprint authorization, one lifecycle driver, physical custody and no Main activation.


### 2026-11-18 — E3d5c6a final manual playable expansion accepted (9/9); final combined regression pending

Developer explicitly confirmed all nine manual playable expansion checks passed locally in Godot against the expansion sandbox and checklist checkpoint [e2da66b](https://github.com/ChrisGiggleman/industrial-warfare/commit/e2da66b4378ac371eccb55721083b9391599c904): initial HUD, unauthorized mixed plans, batch authorization and physical Press dispatch, generator pause/resume, actual Press completion and recharge, High/Low Storage completion and four remaining ingots, unaffordable Press waiting, loaded cancellation physical return, and during-work cancellation with protected staged materials. Aggregate developer confirmation, no independent assistant runtime/manual execution or screenshot review. Exact retained staging contents were verified by earlier accepted automated Stage B, not directly enumerated by HUD. New manual 9/9 is separate from historic Storage manual 9/9 and automated counts. Cumulative accepted 56 suites / 785 unique checks; fresh final combined 56/785 rerun is still pending. Use [BUILDING_EXPANSION_FINAL_REGRESSION.md](BUILDING_EXPANSION_FINAL_REGRESSION.md) and `tools/building_expansion_final_regression.csv`. Do not claim full expansion closeout or begin Direct Build Authorization until developer confirms final automated results. No gameplay/test/runner changes; Main and ordinary scenes remain untouched. Build mode remains legacy.
