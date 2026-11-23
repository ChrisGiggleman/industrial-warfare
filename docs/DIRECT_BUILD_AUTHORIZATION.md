# E3d5c6b — Direct Build Authorization (Stages A/B and Stage C manual fully accepted)

**Status clarification (2026-11-22):** Historical sections below retain their original pending descriptions. The newer HANDOFF records original E3d5c6b Stage C manual 10/10, and the fresh 61/61 baseline (850 expected manifest checks). E3d5c6d Stage A is a separate newly staged, not-yet-F6-tested opt-in scene; see [Stage A guide](UNIFIED_CONSTRUCTION_E3D5C6D_STAGE_A.md).

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


### 2026-11-20 — E3d5c6b Stage B local F6 failed at WAIT_POS; test-only fixture correction staged

Developer supplied a Godot 4.6.2 screenshot from F6 `res://tests/playable_direct_build_authorization_e3d5c6b_stage_b_test.tscn`: debugger shows `Assertion failed: Placement failed at (2.5, 0, -0.5)` in `_place`, at the fourth insufficient-stock Direct Ammunition Press placement, with subsequent error cascade. This is **not** Stage B acceptance or evidence of previous PASS groups (Output banners not supplied). No other cause verified by screenshot. Inspection of source: completed Normal Direct Storage at (4, 0, -1), footprint 1x3, and attempted Press at (2.5, 0, -0.5), footprint 2x2, touch at x=3.5. The Direct Build path refreshes a full-size physics collision preview before the inset blueprint footprint preflight; exact edge contact can legitimately refuse placement. Diagnostic inference: fixture position likely conflicts with physical placement validation, not a reason to weaken normal collision handling or claim a drone-lifecycle failure.

**Narrow test-only fix:** Move `WAIT_POS` to `(-5, 0, 0)`, an open position previously used for Storage by accepted expansion Stage C; it is away from the three completed buildings. Assert actual Hub coverage to keep insufficient materials as the relevant wait condition. Make `_place` report a clear error and return null if no site was created, and safely stop the fixture at the eight call sites rather than cascading through null references. The test still invokes `WorldInteraction._try_place_object` with a fresh camera ray, uses canonical bills, exact queue/services, no inventory injection, no material bypass, original finite power/worker, same scene and lifecycle. No gameplay, other tests, scene, manifest or accepted code changes. Correction commit [ce429537](https://github.com/ChrisGiggleman/industrial-warfare/commit/ce429537992a2ae5064d5ae94ef4c25b7dfe918b).

**Local rerun pending:** Pull updated main and F6 the same Stage B test scene, expected 14 groups A–N and `ALL 14 PLAYABLE DIRECT BUILD AUTHORIZATION E3D5C6B STAGE B TESTS PASSED`. No Godot runtime/parse execution by assistant; if failures recur capture first actual error and Output PASS lines, stop and fix before compatibility. Stage A remains fully accepted (11 isolated + 374 targeted compatibility reruns, 29 suites/385 gate evidence); unique milestone baseline remains 57 suites/796 checks. Stage B adds no accepted checks yet. No Stage B compatibility/manual/final regression claims.


### 2026-11-20 — E3d5c6b Stage B isolated physical lifecycle ACCEPTED (14/14); targeted compatibility pending

Developer explicitly reports **14/14 Stage B isolated checks A–N passed in local Godot 4.6.2**, after the test-only fourth-Press position correction at [11f2595](https://github.com/ChrisGiggleman/industrial-warfare/commit/11f2595c5be139faedc6208ddb443e359843bd40). The prior screenshot established a placement assertion at former WAIT_POS, not a gameplay failure; the new successful F6 result supersedes that pending state. The test uses the real Direct placement click handler and accepted lifecycle services: Direct Press and Storage Normal FIFO; High explicitly authorized Blueprint inserted without preemption; physical five-/three-ingot pickup/delivery, exact per-site custody/escrow, finite power and battery, one worker/one authoritative clock, real 18-second Press and 10-second Storage completions and operational building activation; same drone return/recharge; 15 -> 4 ingot conservation and unaffordable waiting Press. Fresh separate fixture checks cancellation before pickup, loaded with temporarily unavailable return dock, after delivery, and during work: exact reservation release, physical return, protected original staging, escrow refund and four rearms; zero canceled completed buildings and no fabricated stock. This is developer aggregate confirmation, **not assistant-executed Godot testing**, and no new screenshot/output logs were provided for this successful run.

**Accepted unique automated baseline now 58 suites / 810 checks**: E3d5c6a accepted 56/785 + Direct Build Stage A isolated 11 + Stage B isolated 14. Stage A compatibility 28/374 remains separately accepted (reruns, 125 historical supplemental checks outside the 56-suite baseline). Prior manual expansion 9/9 accepted separately. No fresh combined 58-suite regression claimed. Stage B is **isolated accepted**, not fully closed.

**Next Stage B targeted compatibility gate: 29/29 suites, 395/395 checks pending local F6**, selected exclusively from the accepted 56-suite expansion manifest; see [DIRECT_BUILD_AUTHORIZATION.md](DIRECT_BUILD_AUTHORIZATION.md), section “Stage B targeted compatibility gate”. Covers material flow, production, owned staging/escrow, dispatch, charging, cancellation, worker/finite power and prior playable scenes. Reruns **do not add** to 810 cumulative unique checks. Do not claim 395 passed until developer reports. After confirmation, record full Stage B acceptance, then stage Stage C real physical mouse/keyboard manual verification and final targeted combined regression. No gameplay, ordinary/Main scenes, other tests, existing regression runner or manifest changed in this documentation-only acceptance commit. Automatic conveyor, splitter/merger, new pole construction, multi-item/trip, multi-drone, persistence, destruction expansion and locked-staging unlock remain separately gated.


## Stage B targeted compatibility gate — ACCEPTED 29/29, 395/395

These 29 existing test scenes total **395 checks**, as matched against `tools/building_expansion_final_regression.csv` at 11f2595c. Each belongs to the previously accepted E3d5c6a 56-suite baseline. Open `res://tests/<scene>`, press F6 for each and check every PASS group/banner (the inventory-transfer fixture prints four PASS groups). Preserve exact spelling of `inventory_trasnfer_test.tscn`. This is a focused rerun, not a new unique-check contribution.

| Existing test scene | Expected checks |
|---|---:|
| `inventory_trasnfer_test.tscn` | 4 |
| `item_port_transfer_test.tscn` | 7 |
| `manufacturing_transaction_test.tscn` | 9 |
| `recipe_output_capacity_test.tscn` | 11 |
| `blueprint_construction_material_escrow_e3d5c2a_test.tscn` | 16 |
| `unified_receiver_consolidation_e3d5c5v_test.tscn` | 56 |
| `playable_construction_logistics_e3d5c5w_test.tscn` | 13 |
| `playable_construction_power_e3d5c5x1_test.tscn` | 9 |
| `playable_construction_drone_e3d5c5x2_test.tscn` | 11 |
| `drone_storage_discovery_e3d5c5x3_test.tscn` | 12 |
| `drone_supplier_reservations_e3d5c5x4a_test.tscn` | 12 |
| `drone_return_reservations_e3d5c5x4b_test.tscn` | 14 |
| `drone_physical_pickup_e3d5c5x5a_test.tscn` | 12 |
| `drone_physical_delivery_e3d5c5x5b_test.tscn` | 13 |
| `drone_delivered_worker_e3d5c5x5c_test.tscn` | 16 |
| `drone_cancelled_cargo_recovery_e3d5c5x6_test.tscn` | 13 |
| `finite_construction_power_e3d5c3b2_test.tscn` | 18 |
| `drone_finite_hub_charging_e3d5c5x7a_test.tscn` | 13 |
| `drone_cargo_worker_reuse_e3d5c5x7b_test.tscn` | 16 |
| `drone_pre_pickup_cancellation_e3d5c5x7c1_test.tscn` | 12 |
| `drone_post_delivery_cancellation_e3d5c5x7c2_test.tscn` | 13 |
| `drone_lost_site_recovery_e3d5c5x7c3_test.tscn` | 14 |
| `drone_automatic_dispatch_e3d5c5x8a_test.tscn` | 14 |
| `drone_automatic_lifecycle_e3d5c5x8b_test.tscn` | 15 |
| `playable_automatic_construction_drone_stage_b_test.tscn` | 8 |
| `playable_automatic_construction_drone_stage_c_test.tscn` | 13 |
| `playable_construction_building_expansion_e3d5c6a_test.tscn` | 8 |
| `playable_construction_building_expansion_e3d5c6a_stage_b_test.tscn` | 12 |
| `playable_construction_building_expansion_e3d5c6a_stage_c_test.tscn` | 11 |
| **Total (29 suites)** | **395** |

Report 29/29 and 395/395 only if all actually pass locally; for any error stop and share the first failure and preceding PASS groups. The Stage A compatibility 28/374 evidence remains accepted and is not double-counted. Stage B isolated 14/14 is accepted. Stage C manual and final combined 58/810 automated gate are not yet performed.


### 2026-11-20 — E3d5c6b Stage B FULLY ACCEPTED; Stage C manual verification staged (10 pending)

Developer explicitly confirmed **29/29 targeted Stage B compatibility suites and 395/395 checks passed in local Godot** and provided per-suite counts, each matching `tools/building_expansion_final_regression.csv` and the committed Stage B gate (29 unique names, 395 total). These are reruns of accepted expansion suites, not additive. Combined with developer-confirmed **14/14 isolated Stage B physical Direct Build checks**, full Stage B acceptance gate evidence is **30 suite executions / 409 checks** (14 isolated new + 395 overlap reruns), without inventing a fresh full combined regression. Stage A previously fully accepted (11/11 isolated + 28/28, 374/374 compatibility reruns). **Unique milestone baseline remains 58 suites / 810 checks**: 56/785 original expansion, 11 new Stage A, 14 new Stage B. Prior manual expansion 9/9 remains separately accepted. All confirmations are developer-reported local Godot results, not assistant runtime executions.

**Stage C next — manual playable verification:** see [DIRECT_BUILD_STAGE_C_MANUAL.md](DIRECT_BUILD_STAGE_C_MANUAL.md). Run only `res://scenes/core/playable_direct_build_authorization_e3d5c6b.tscn` with **F6**, three independent fresh-play sessions, **10 proposed manual checks A1–A6, B1–B3, C1**. Session A covers Direct Build mode click auto-N Storage/Press, unsupported/duplicate refusal, physical drone transport, generator power pause/resume, actual operational buildings, 15→7 material conservation and recharge. Session B covers Blueprint P planning, Q+drag H priority with no auto-authorization, E selected/single and Ctrl+E batch, mixed priority shared queue, physical completion and 15→4 conservation. Session C verifies a physical loaded cancellation by hovering site and pressing X after collecting five ingots, return storage restores 15 and no Press activates. Manual checks **not run or accepted yet**; no automatic/manual counts added. These sessions use the existing opt-in scene without changing gameplay scripts or prior scenes. **After developer-confirmed Stage C 10/10**, stage fresh final combined regression **58 unique suites / 810 checks** with actual F6 evidence; not yet run. Keep separately gated features untouched: automatic conveyor routing/builds, splitter/merger, poles, multi-trip/fleet, persistence and destruction expansion. No milestone closeout yet.



### 2026-11-20 — Stage C user confirms incomplete/cancelled site, stock remains 12/15; post-delivery recovery not yet implemented

Developer supplied three consecutive live Godot screenshots: starting sandbox **15 Test Ingots**, one idle drone and no jobs; during play **12 ingots**, **Planned: 3 / Queued: 0** with drone empty/IDLE and **Rearms: 1**; after cancellation **Planned: 0 / Queued: 0**, Starter Storage still **12**, drone empty/IDLE, fully charged. Developer explicitly confirms **construction did not complete**. Correct prior mistaken suggestion that 12 might represent successful Storage material consumption: that possibility is ruled out for this sequence. The three visible PLANNED blueprint sites alone could not debit material; some already-authorized dispatched site consumed the three from source before cancellation. Screenshots alone do not show escrow/staging inventory or pinpoint which site had them; the accepted code and Stage B isolated tests predict uncommitted **3 ingots remain in the cancelled original site's protected staging buffer**, not teleported/refunded to Starter Storage. Do **not** claim independently verified staging contents from these screenshots or mark a material conservation regression without a readout.

Existing source/protocol: `WorldInteraction._cancel_blueprint_site` calls `job.cancel()`; `ConstructionSite._cancel_job_site` queues the site for deletion; `BlueprintConstructionMaterialEscrow._on_cancelled` calls `recover_to`, preserving/refunding into the *pinned staging inventory* if escrowed; `BlueprintConstructionSiteStagingRegistry` retains original claimed staging/port, no release; `PrototypeDroneAutomaticDispatch` returns its **empty** delivered drone to Hub to recharge/rearm. `docs/DRONE_CONSTRUCTION_LOGISTICS.md` explicitly keeps **future physical recovery flights from cancelled delivered site staging** separately gated; presently no accepted service performs staged-material pickup and return. By contrast **cancelled loaded drone cargo** is physically returned to reserved eligible dock, and an actually **completed building commits** its material bill (stock 12 is then expected). Therefore this is a **real gap between the intended player recovery experience and currently implemented experimental scope**, not proof of deleted inventory. Do not silently refund or unlock a claimed buffer to satisfy manual testing.

Stage C manual 10-check gate still **pending**. Test A covered-building completion at labeled Storage position and check worker 1/1, 15→12 only after actual completion. Test C1 in separate fresh F6, cancel Press **while drone CARGO 5/5 before unload** and verify physical return restores 15. Add optional non-counted observation for cancellation **after** unload: donor Storage remains debited, drone empty, materials expected in protected staging, no playable physical recovery available yet. For full player-expected cancellation recovery, design/implement a separately opt-in `E3d5c6c` or subsequent subgate with exact original site identity, physical staged pickup, destination capacity reservation, finite drone battery and movement, cancel-safe atomic transfer, conservative retry when blocked, and no release/duplicate claims without provenance. Consider explicit HUD for staged quantities and power coverage, but do not merge experimental features into Main. Baseline remains **58 unique suites / 810 automated checks**, Stage A/B fully accepted; no new Godot verification, Stage C acceptance, compatibility or final regression claimed.
