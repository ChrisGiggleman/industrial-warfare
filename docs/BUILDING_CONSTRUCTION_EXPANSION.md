# E3d5c6 — Automatic construction building expansion

2026-11-18. Stage A isolated accepted (8/8); targeted compatibility pending. Historical 53 suites / 754 checks and 9/9 manual checks at 560789595cf1c7711121be7ae0e8d3dfb1ff78f2; cumulative 54 suites / 762 checks, not a fresh combined regression.

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
