# E3d5c6b — Direct Build Authorization (Stage A fully accepted; Stage B F6 pending)

2026-11-18. Prerequisite E3d5c6a fully accepted: 56/56 targeted automated suites, 785/785 checks, expansion manual 9/9; historical Storage manual 9/9 separate. Developer reported local Godot results. See BUILDING_EXPANSION_FINAL_REGRESSION.md and HANDOFF.md. The original proposed sequence is retained below. Stage A is fully accepted by developer local Godot verification; Stage B is staged.

## Player workflow agreed earlier

- Build mode: a valid placement click is itself explicit authorization. Create a non-operational construction site and submit the same original job to the same queue at Normal priority, with no second E. A queued job may wait for stock, worker, route/power/energy; click does not promise immediate dispatch.
- Blueprint mode: placement stays PLANNED; Q+drag and L/N/H only change priority, E/Ctrl+E explicitly authorize existing selected/all plans. No change to existing behavior.
- Both paths share the same ownership, inventory, receiver, queue, escrow, worker, power, timing, cancellation and lifecycle authority. No immediate completed buildings, free resources, duplicate jobs/drivers or preemption.

## Source inspection before implementation

Inspect actual main versions of `scripts/world_interaction.gd` (especially _try_place_object, _commit_blueprint_from_preview, _create_blueprint_site, _authorize_blueprint_site, current preview/footprint/snap and cancellation paths), `scripts/ui/playable_automatic_construction_drone_sandbox.gd` (scene allowlist, verified services, enrollment), existing expansion scene and A/B/C tests, construction site/queue/readiness contracts, relevant catalog and input handlers. Check whether selected transforms are fresh and how activation failures are handled. Do not treat proposed method signatures as confirmed APIs. GitHub source takes precedence.

## Proposed phased gates

A — isolated direct placement authorization. Default-off switch and exact new experimental scene; only canonical Storage/Press initially, preserve legacy behavior outside new scope including all prior accepted scenes and Main. Intercept direct placement before legacy instant/timed/conveyor routes in the new scope. Reuse current validated preview transform and site creation and original authorization. Fail closed on invalid placement, unsupported definition, missing verified services or failed enrollment; avoid orphan authorized jobs or fallback completed buildings. No requirement to change general-scene behavior. Test invalid/blocked/stale placement, duplicate clicks, successful Normal job, no materials/time bypass, no E necessary, explicit Blueprint authorization unchanged, priority/order and scope opt-out. Inspect before choosing rollback behavior; preserve evidence and existing ownership invariants.

B — real playable direct construction. New isolated test verifies physical 3/5-unit pickup/delivery, finite power/work/battery, 10/18-second construction, actual building activation, mixed Direct/Blueprint orders, missing materials/power, cancellation before pickup/loaded/delivered/working, no duplicates, return/recharge; original accepted behavior unchanged.

C — manual mouse/key workflow, final targeted regression with accepted 56/785 plus new suites, document acceptance. New scene HUD should distinguish Direct Build authorization from Blueprint planning, show queued/waiting state, and avoid misleading unsupported placement. No Main activation.

Later separately gated: automatic conveyor segments and straight/corner/waypoint route snapping; splitter/merger; pole coverage registration; multi-item/multi-trip and large bills; multi-drone; persistence; expanded destruction recovery; specialized Ammo Silos. Do not unlock protected staging in this milestone.

## Acceptance discipline

Inspect current HEAD, stage scoped changes, commit to main with non-force expected-head update, provide exact pull/F6 steps and expected banners. User runs local Godot 4.6.2, reports actual results, record isolated then compatibility and manual acceptance without double-counting. Handoff at each major gate. No independent runtime claims without execution.


### 2026-11-18 — E3d5c6b Direct Build Authorization Stage A staged; local F6 pending

Preserved accepted starting checkpoint [217ef366](https://github.com/ChrisGiggleman/industrial-warfare/commit/217ef366cc65b57ab00e0dc36d558231f1790b7c): **56/56 targeted suites / 785/785 checks**, expansion manual 9/9 separate. Stage A adds one exact-scope scene `res://scenes/core/playable_direct_build_authorization_e3d5c6b.tscn` with default-off adapter switch. WorldInteraction intercepts clicks before legacy placement even when the new adapter fails or is disabled; supported canonical Storage and Press only. Unsupported Blueprint placement also refused in this new scene, route tools/connected plan registration disabled here only; no changes to Main, prior scene files, accepted tests or regression manifest. A click refreshes the existing ground/ghost validation, rejects stale/blocked/port-linked placement, then creates an ordinary reserved-footprint site and invokes the original authorization handler (Normal job). The Blueprint click remains PLANNED; Q/L/N/H does not authorize; E and Ctrl+E use the same handler. The exact original queue and adapter services are reused; successful synchronous enrollment owns staging and transfers site timer to the existing lifecycle. A failed synchronous enrollment cancels the original job, preserving any quarantined claims; no legacy fallback, debug readiness, new driver or inventory transfer. The unsupported/unavailable ghost is red in the new scope. No changes to canonical bills (3/5 ingots, 10/18 seconds).
 
**Pending isolated F6:** `res://tests/playable_direct_build_authorization_e3d5c6b_test.tscn` — expected **11/11 A–K**. Actual WorldInteraction placement handler with narrow orthographic camera fixture aimed at known grid coordinates (not OS cursor injection); verified service composition and original queue; default-off and accepted-scene opt-out even if new switch is set; disabled exact scene cannot fall back; immutable canonical allowlist; unsupported, off-ground stale and occupied clicks refuse; direct Storage Normal once and duplicate rejection; Press Normal FIFO, exact bills and distinct empty staging; explicit selected and batch Blueprint authorization; forced enrollment listener failure cancels original job and prunes queue; post-start disabled admission blocks; shared dispatcher reserves exactly 3 ingots without pickup, escrow or time advancement. Expected banner: `ALL 11 PLAYABLE DIRECT BUILD AUTHORIZATION E3D5C6B STAGE A TESTS PASSED`. Implementation/fixture staged at [f6f2bc9](https://github.com/ChrisGiggleman/industrial-warfare/commit/f6f2bc9ca14e4eab1d5f5298db507b941b6566dc). No independent Godot execution or parse verification; camera/physics behavior is pending local F6. Report red errors and all PASS groups; acceptance stays pending until developer confirms. After isolated acceptance, document targeted compatibility gate before Stage B (full physical Direct lifecycle); Stage C manual and final combined 56 baseline + unique added suites. No added counts yet. No automatic belts/corners, splitter/merger, new pole integration, multi-load/fleet, persistence, destruction expansion or staged lock release.


### 2026-11-18 — E3d5c6b Stage A isolated accepted (11/11); targeted compatibility pending

Developer explicitly confirmed all 11/11 isolated Direct Build Authorization groups A–K passed locally in Godot against the staged checkpoint [673f249](https://github.com/ChrisGiggleman/industrial-warfare/commit/673f24952834cdeb676690b6ac2bed41b993b1ff). Aggregate developer confirmation, not independent assistant execution or screenshot review. Accepted: exact scene gating/default-off, original queue and canonical Storage/Press, actual refreshed placement path including unsupported/off-ground/blocked/duplicate rejection, Normal FIFO, distinct empty owned staging and original bill/time, explicit selected and batch Blueprint authorization, cancellation on forced synchronous enrollment failure, disabled admission and exact reservation without stock/time bypass. The prior final combined 56 suites / 785 checks remain accepted; cumulative unique milestone baseline is **57 suites / 796 checks** (not a fresh combined rerun). Manual expansion 9/9 remains separate.

Next gate: F6 the **28 targeted compatibility suites / 374 checks** listed in [DIRECT_BUILD_AUTHORIZATION.md](DIRECT_BUILD_AUTHORIZATION.md). They include 10 historical placement/authorization suites (125 checks, outside the 56-suite baseline) and 18 baseline overlap suites (249 checks). These are reruns, not new milestone tests; do not add 374 to the 796 unique milestone checks. No compatibility execution or result claimed yet. No gameplay, tests, accepted scene, or existing regression manifest changed. After developer confirms compatibility, record Stage A full acceptance and proceed to Stage B real physical Direct Build lifecycle; retain full 56-suite baseline for final combined regression. Stage C manual gameplay remains pending. Main/ordinary scenes and separately gated systems remain unchanged.

## Stage A targeted compatibility gate — accepted 28/28, 374/374

Open each existing scene under `res://tests/` and press F6; stop before running the next. Check the expected PASS groups/banners and report all failures or skips. No new tests or runner for this gate. Counts checked against existing test banners for the historical set and accepted manifest for the overlapping set.

### Historical placement and authorization (outside final expansion manifest)

| Scene | Expected checks |
|---|---:|
| `blueprint_sandbox_mode_test.tscn` | 12 |
| `timed_storage_placement_test.tscn` | 4 |
| `planned_storage_build_mode_test.tscn` | 6 |
| `storage_blueprint_preview_snap_e3c2b_test.tscn` | 15 |
| `conveyor_building_placement_snap_test.tscn` | 8 |
| `build_hotbar_keyboard_integration_test.tscn` | 12 |
| `sandbox_blueprint_authorization_test.tscn` | 18 |
| `blueprint_construction_priority_e3d5a_test.tscn` | 15 |
| `sandbox_authorization_receiver_autowire_e3d5c5d_test.tscn` | 19 |
| `blueprint_click_inspection_e3d5c3d2e_test.tscn` | 16 |
| **10 suites** | **125** |

### Previously accepted expansion baseline subset

| Scene | Expected checks |
|---|---:|
| `conveyor_splitter_test.tscn` | 10 |
| `conveyor_merger_test.tscn` | 10 |
| `conveyor_physical_only_conservation_test.tscn` | 9 |
| `timed_storage_conveyor_delivery_test.tscn` | 6 |
| `blueprint_construction_material_escrow_e3d5c2a_test.tscn` | 16 |
| `unified_receiver_consolidation_e3d5c5v_test.tscn` | 56 |
| `playable_construction_logistics_e3d5c5w_test.tscn` | 13 |
| `playable_construction_power_e3d5c5x1_test.tscn` | 9 |
| `playable_construction_drone_e3d5c5x2_test.tscn` | 11 |
| `sandbox_construction_drone_bridge_e3d5c5a_test.tscn` | 20 |
| `drone_automatic_dispatch_e3d5c5x8a_test.tscn` | 14 |
| `drone_automatic_lifecycle_e3d5c5x8b_test.tscn` | 15 |
| `playable_automatic_construction_drone_stage_a_test.tscn` | 8 |
| `playable_automatic_construction_drone_stage_b_test.tscn` | 8 |
| `playable_automatic_construction_drone_stage_c_test.tscn` | 13 |
| `playable_construction_building_expansion_e3d5c6a_test.tscn` | 8 |
| `playable_construction_building_expansion_e3d5c6a_stage_b_test.tscn` | 12 |
| `playable_construction_building_expansion_e3d5c6a_stage_c_test.tscn` | 11 |
| **18 suites** | **249** |

**Compatibility gate: 28 suites / 374 checks.** Combined Stage A gate evidence after confirmation will be 29 suites / 385 checks (11 isolated + 374 rerun), not 385 unique new checks. Cumulative unique milestone baseline remains 57 / 796; historical supplemental checks tracked separately. The 56-suite / 785-check manifest remains unchanged and will be included at final combined regression. Do not claim runtime execution or acceptance until developer reports results.


### 2026-11-18 — E3d5c6b Stage A fully accepted (385/385); Stage B physical Direct Build lifecycle staged

Developer explicitly confirmed all **28/28 targeted compatibility suites and 374/374 checks** passed locally in Godot, naming every suite and count. Exact ordered match against the committed Stage A compatibility tables at [c93f2f81](https://github.com/ChrisGiggleman/industrial-warfare/commit/c93f2f81249a4fde8babad97d23c7c273a2c2873); 28 unique entries, no missing/extra/mismatched counts. Includes 10 historical supplemental suites / 125 checks and 18 existing expansion baseline suites / 249 checks. Together with previously accepted 11/11 isolated checks, Stage A full gate evidence is **29 suites / 385 checks**. Cumulative unique milestone baseline remains **57 suites / 796 checks** (56/785 + new isolated 11); historical supplemental checks are separate, reruns not additive; manual expansion 9/9 separate. No fresh full combined regression, runtime execution by assistant, or screenshot review claimed.

Stage B adds a new isolated test only, using the existing exact-scope Direct Build scene and the Stage A accepted camera/ground-ray click entry point. No gameplay, node scene, existing test, runner or manifest changes. Explicit test tick calls replace the adapter frame callback; no duplicate driver, fabricated readiness, transfer shortcut, or direct job authorization. First fresh instance: 15 counted ingots, Direct Press and Direct Storage queued Normal FIFO, High Blueprint remains planned until batch authorization during active Press work; one physical drone picks up 5, then 3, then 3; original source/hover delivery, escrow, finite power pause/resume, exclusive worker and bounded clock, exact canonical 18/10-second completion, real Press with empty production inventories/ports and real Storage, same drone returns and metered recharge, High Blueprint before waiting Normal Storage without preemption. Direct Press at WAIT_POS remains queued with four ingots, no partial loads or work. Second fresh instance: original 15 counted stock, four Direct Press cancellations before pickup, while loaded with return dock disabled/re-enabled, after delivery, and during work. No in-scenario restock or claim unlock; first two leave 15 stock, last two leave 5 each in distinct protected original buffers and 5 in starter Storage; four rearms, no completed cancelled building. New fixture is not physical mouse/manual input and does not prove new production conveyor construction.

**Pending F6:** `res://tests/playable_direct_build_authorization_e3d5c6b_stage_b_test.tscn` — expected **14/14 A–N**. Test implementation [3c4a8b6](https://github.com/ChrisGiggleman/industrial-warfare/commit/3c4a8b66938243b69400f31bf9c2fe16fa16123c). Expected banner: `ALL 14 PLAYABLE DIRECT BUILD AUTHORIZATION E3D5C6B STAGE B TESTS PASSED`. No assistant runtime or parse execution; local Godot verification pending. After isolated pass, record acceptance and stage targeted compatibility gate for physical lifecycle, then Stage C manual workflow and final regression (preserve 56/785 and unique added milestone tests; supplemental historical suite evidence separate unless deliberately included in expanded manifest). No Main or ordinary-scene activation, automatic conveyor construction, splitter/merger construction, new pole, multi-item/trip, multiple drones, persistence, expanded destruction or staged-material unlocking.
