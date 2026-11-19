# E3d5c6 — Automatic construction building expansion

2026-11-18. Stage A fully accepted (8/8 isolated + 29/29 compatibility); Stage B fully accepted (12/12 isolated + 198/198 compatibility); Stage C isolated accepted (11/11); manual playable expansion accepted (9/9); final combined automated gate fully accepted (56/56 suites, 785/785 checks). Historical 53 suites / 754 checks and 9/9 manual checks at 560789595cf1c7711121be7ae0e8d3dfb1ff78f2; fresh final combined 56 suites / 785 checks accepted.

## E3d5c6a Stage A
Explicit new scene `res://scenes/core/playable_construction_building_expansion_e3d5c6a.tscn` plus default-off expansion switch. Canonical Test Storage (3 ingots) and Prototype Ammunition Press (5 ingots) only. Exact validated bill, per-site empty staging capacity, original job/definition/receiver ownership; existing coordinator and site timer handoff. Existing Stage A/B/C remain unchanged in behavior, including Storage-only eligibility even if the new switch is set in them. Seven construction power units are an isolated fixture choice, not a production balance change. No resource bills, Main, ordinary scenes, dispatcher, worker, power, conveyor, escrow or recovery code modified.

F6 `res://tests/playable_construction_building_expansion_e3d5c6a_test.tscn`: expected 8 groups A–H, default-off and old-scene refusal, canonical allowlist, unauthorized planning, queue and owned clocks, exact buffers, physical-only guards, exact dispatch reservation, cancellation protection. Final line `ALL 8 PLAYABLE CONSTRUCTION BUILDING EXPANSION E3D5C6A TESTS PASSED`. Developer confirmed all 8 checks passed locally against db08153. No independent assistant execution claimed. Stage A does not establish full Press completion/recharge/cancellation-recovery acceptance. Next: targeted Stage A/B/C reruns, then Stage B full physical Press construction and operational activation with empty production inventories and separate physical ingredients; Stage C mixed queue and manual/playable acceptance plus 754-check compatibility gate. Do not double-count reruns.

## Direct Build Authorization — separately gated follow-on
Developer identified legacy Build mode places completed buildings directly and asked for drone construction without E. Agreed direction: a valid direct Build click should be the explicit authorization event, creating a Normal-priority queued site through the existing authorization handler, with no second E. Blueprint mode remains PLANNED until E/Ctrl+E and priority metadata alone never authorizes. Both modes share one queue, staging, escrow, worker, finite power and lifecycle driver. No instant construction, free materials, fallback to legacy placement, or duplicate drivers in the future opt-in direct-build scene. First support Storage/Press; unsupported definitions should be blocked in that experimental mode, not silently completed. Test failed/blocked clicks, missing stock/energy/power, cancellation, priority/FIFO and normal-scene opt-out; later separately support direct conveyor snap/corner paths. For this Stage A commit regular Build mode is unchanged (legacy). Use Blueprint mode in expansion sandbox until direct-build gate is implemented.

Later: belt segments/routes/corners, splitter/merger, separately gated power pole registration/linking, and multi-item/multi-trip jobs. No Main/general activation, fleet concurrency, persistence, extra destruction integration, specialized Ammo Silos or staged-cargo unlocking.

### 2026-11-18 — E3d5c6a Stage A isolated accepted (8/8); compatibility pending

Developer explicitly confirmed all eight isolated test groups passed in local Godot 4.6.2 against implementation [db08153](https://github.com/ChrisGiggleman/industrial-warfare/commit/db0815322930252b5388921dd159732a527cd5ae). Historical 53 suites / 754 checks plus 1 new suite / 8 checks = cumulative 54 suites / 762 checks. No independent assistant runtime execution and no fresh 762-check regression claim. Previous manual 9/9 remains historical and separate.

Next targeted compatibility gate: run each scene separately with F6:
- `res://tests/playable_automatic_construction_drone_stage_a_test.tscn` — 8 checks.
- `res://tests/playable_automatic_construction_drone_stage_b_test.tscn` — 8 checks.
- `res://tests/playable_automatic_construction_drone_stage_c_test.tscn` — 13 checks.

Expected 3 suites / 29 checks, reruns only (do not double-count). After developer confirmation, proceed to E3d5c6a Stage B: real five-ingot Press delivery, exact escrow, finite coverage/power and battery, 18-second construction, actual completed scene/runtime and empty production inventories, return/recharge, cancellation/recovery. Mixed queues and manual playable gate remain later. Direct Build Authorization remains separately gated: placement click authorizes a Normal-priority job, Blueprint mode still requires E/Ctrl+E, same lifecycle, no free build. Build mode remains legacy in this commit; Main and ordinary scenes unchanged. Documentation only.


### 2026-11-18 — E3d5c6a Stage A fully accepted (37/37); Stage B test staged

Developer explicitly confirmed all 3/3 targeted Stage A/B/C compatibility suites and 29/29 checks passed in local Godot, in addition to 8/8 isolated expansion. Stage A gate 4 suites/37 checks. Cumulative unique 54 suites/762 checks; reruns not double-counted. Historical manual 9/9 remains separate.

Stage B adds only an isolated end-to-end test, reusing existing expansion scene and all production/runtime code unchanged. F6 `res://tests/playable_construction_building_expansion_e3d5c6a_stage_b_test.tscn`, expected 12 groups A–L. Five-ingot reservation, physical pickup/delivery, exact escrow, finite power, capped 18-second job and actual Press activation, empty production inventories, separate counted one-ingot fixture loaded onto a real connected conveyor (not a full upstream source route), timed 1-to-4 ammunition production, finite recharge and four cancellation phases. Final 15 construction ingots accounted for: 5 consumed by completed Press, 5 locked in delivered-cancelled buffer, 5 refunded to working-cancelled buffer, zero stock/cargo. Separate one-ingot production fixture accounted independently. No new local execution or acceptance yet. Expected banner `ALL 12 PLAYABLE CONSTRUCTION BUILDING EXPANSION E3D5C6A STAGE B TESTS PASSED`. If passed, record then proceed to targeted compatibility and Stage C mixed queue. No Main/ordinary activation, direct Build authorization still separately planned; no automatic conveyor construction or staged-cargo unlocking.


### 2026-11-18 — E3d5c6a Stage B isolated accepted (12/12); targeted compatibility pending

Developer explicitly confirmed all 12 Stage B test groups passed locally in Godot 4.6.2 against [1f94c50](https://github.com/ChrisGiggleman/industrial-warfare/commit/1f94c503c1c20251189abb06a6363f8d3958cf9c). The real Press construction, finite power/battery, independent manufacturing inventories, connected conveyor receiving one separately counted production ingot and four ammo output, five assignments, and four cancellation phases are accepted by developer report. All 15 construction ingots accounted for. Cumulative unique 55 suites / 774 checks; historical manual 9/9 separate. No independent assistant execution or new full regression claimed. Stage B added tests only; no gameplay code changed.

Targeted compatibility gate: 16 existing suites / 198 checks, each F6 under res://tests/. Counts from accepted final regression manifest plus accepted Stage C (13) and expansion Stage A (8). Reruns only, no double-count.

| Scene | Expected checks |
|---|---:|
| `playable_construction_building_expansion_e3d5c6a_test.tscn` | 8 |
| `playable_automatic_construction_drone_stage_c_test.tscn` | 13 |
| `item_port_transfer_test.tscn` | 7 |
| `manufacturing_transaction_test.tscn` | 9 |
| `recipe_output_capacity_test.tscn` | 11 |
| `conveyor_automatic_unloading_test.tscn` | 9 |
| `blueprint_construction_material_escrow_e3d5c2a_test.tscn` | 16 |
| `drone_physical_pickup_e3d5c5x5a_test.tscn` | 12 |
| `drone_physical_delivery_e3d5c5x5b_test.tscn` | 13 |
| `drone_delivered_worker_e3d5c5x5c_test.tscn` | 16 |
| `finite_construction_power_e3d5c3b2_test.tscn` | 18 |
| `drone_finite_hub_charging_e3d5c5x7a_test.tscn` | 13 |
| `drone_pre_pickup_cancellation_e3d5c5x7c1_test.tscn` | 12 |
| `drone_cancelled_cargo_recovery_e3d5c5x6_test.tscn` | 13 |
| `drone_post_delivery_cancellation_e3d5c5x7c2_test.tscn` | 13 |
| `drone_automatic_lifecycle_e3d5c5x8b_test.tscn` | 15 |
| Total | 198 |

After confirmation, record Stage B full acceptance (12 + 198 = 210 milestone checks), then Stage C mixed Storage/Press queue and manual playable expansion checks. Direct Build Authorization remains separate after expansion; regular Build mode is still legacy. No Main/ordinary activation, automatic conveyor construction, multi-drone, persistence, or staged-cargo unlock.


### 2026-11-18 — E3d5c6a Stage B fully accepted (210/210); Stage C mixed queues staged

Developer explicitly confirmed the 16/16 targeted compatibility suites and 198/198 checks locally, naming every suite and count; exact match with prior documented gate, plus 12/12 isolated physical Press checks. Stage B milestone 17 suites / 210 checks. Cumulative unique 55 suites / 774 checks (reruns not double-counted); historical manual 9/9 remains separate. No assistant runtime execution.

Stage C adds test only, no gameplay changes. F6 `res://tests/playable_construction_building_expansion_e3d5c6a_stage_c_test.tscn` — 11 expected groups A–K. Actual selected authorization path with mixed canonical definitions, Normal/High/Low queue metadata (High FIFO over older Low), distinct exact buffers, physical Press five-ingot delivery, pause/resume and active job ownership, real Press then High Storage then Low Storage, 15 initial stock minus 5+3+3 = 4, same drone recharged after each. Later High Press with cost 5 and High Storage cost 3 enter during Low active work (no preemption); after Low completion stock 4, dispatcher skips unaffordable Press and reserves affordable Storage. Cancel before pickup, rearm and leave 4 stock with Press queued. No partial delivery or fabricated input. Final expected banner `ALL 11 PLAYABLE CONSTRUCTION BUILDING EXPANSION E3D5C6A STAGE C TESTS PASSED`. Local testing pending. After success, record isolated result, run final combined automated compatibility and manual playable expansion; Direct Build Authorization remains separately gated after expansion. No Main/ordinary scene changes, automatic conveyor construction, fleet concurrency, persistence or staged cargo unlocking.


### 2026-11-18 — E3d5c6a Stage C isolated accepted (11/11); final gates pending

Developer explicitly confirmed all 11 mixed-building test groups passed locally in Godot against [d604d37](https://github.com/ChrisGiggleman/industrial-warfare/commit/d604d3710bb20572425aa65ab22a0174f7bb0d70). Three completed mixed buildings in intended order, 15 -> 4 construction stock, same drone, nonpreemption, unaffordable Press skipped for affordable Storage, cancellation before pickup and conservation. Cumulative unique 56 suites / 785 checks, no fresh combined run claimed yet. Stage A/B fully accepted. New [BUILDING_EXPANSION_FINAL_REGRESSION.md](BUILDING_EXPANSION_FINAL_REGRESSION.md) records 56-suite/785-check complete combined rerun manifest, optional copied local runner and 9 manual checks in existing expansion playable scene. Original runner/manifest unchanged. No gameplay or test code changed. New runner not executed by assistant. Final combined and new manual gates pending; after both pass, Direct Build Authorization next. Build mode remains legacy for current gate, use Blueprint mode. No Main/ordinary activation.


### 2026-11-18 — E3d5c6a final manual playable expansion accepted (9/9); final combined regression pending

Developer explicitly confirmed all nine manual playable expansion checks passed locally in Godot against the expansion sandbox and checklist checkpoint [e2da66b](https://github.com/ChrisGiggleman/industrial-warfare/commit/e2da66b4378ac371eccb55721083b9391599c904): initial HUD, unauthorized mixed plans, batch authorization and physical Press dispatch, generator pause/resume, actual Press completion and recharge, High/Low Storage completion and four remaining ingots, unaffordable Press waiting, loaded cancellation physical return, and during-work cancellation with protected staged materials. Aggregate developer confirmation, no independent assistant runtime/manual execution or screenshot review. Exact retained staging contents were verified by earlier accepted automated Stage B, not directly enumerated by HUD. New manual 9/9 is separate from historic Storage manual 9/9 and automated counts. Cumulative accepted 56 suites / 785 unique checks; fresh final combined 56/785 rerun is still pending. Use [BUILDING_EXPANSION_FINAL_REGRESSION.md](BUILDING_EXPANSION_FINAL_REGRESSION.md) and `tools/building_expansion_final_regression.csv`. Do not claim full expansion closeout or begin Direct Build Authorization until developer confirms final automated results. No gameplay/test/runner changes; Main and ordinary scenes remain untouched. Build mode remains legacy.


### 2026-11-18 — E3d5c6a automatic construction building expansion FULLY ACCEPTED

Developer explicitly confirmed the final combined local Godot regression: **56/56 suites, 785/785 checks passed**, after manual expansion 9/9 previously accepted at [fdb059b](https://github.com/ChrisGiggleman/industrial-warfare/commit/fdb059b83cf0bced24b02cc86541813425eb2040). The committed `tools/building_expansion_final_regression.csv` was independently checked for 56 unique entries totaling 785; developer supplied aggregate pass confirmation, not individual output logs in this turn. No independent assistant runtime execution or runner-use claim. The fresh accepted targeted combined regression supersedes the prior cumulative-only baseline. Historical 53 suites/754 checks plus expansion A/B/C 8/12/11 = 56/785; do not add targeted reruns or manual checks to automated totals. Manual expansion 9/9 and original Storage manual 9/9 are separately accepted. Not a full-project regression.

Accepted experimental capability: canonical Test Storage (3 ingots / 10 seconds) and Prototype Ammunition Press (5 ingots / 18 seconds), exact per-site staging, one shared priority/FIFO queue, explicit E/Ctrl+E authorization, physical pickup/delivery and exact escrow, exclusive worker, finite power/energy/recharge, actual completed building and operational manufacturing, mixed queues, nonpreemption, insufficient-stock skip, physical loaded cancellation recovery and locked staged/escrow refunds. One separately counted conveyor-fed production ingredient yielded four ammunition; no claim of full upstream route. Main and ordinary scenes unchanged; existing Build mode still legacy. No gameplay, test or runner code changes in closeout. Keep manifest as accepted baseline.

Next proposed milestone **E3d5c6b — Direct Build Authorization**, staged separately; no implementation yet. Read [DIRECT_BUILD_AUTHORIZATION.md](DIRECT_BUILD_AUTHORIZATION.md) before modifying code. New chat should verify main HEAD and actual source before deciding implementation. Direct click authorizes Normal-priority construction through existing lifecycle; Blueprint mode retains E/Ctrl+E. No silent legacy fallback for unsupported definitions in new opt-in scope. Automatic belts/corners, splitter/merger, pole, multi-item/trip, fleet, persistence, destruction expansion, specialized Ammo Silos and staged-material unlocking remain separately gated.
