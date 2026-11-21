# E3d5c6c — Cancelled-site staged-material physical recovery (Stage A fully accepted; B1 F6 pending)

Status: **Stage A isolated audit tests ACCEPTED (13/13), targeted compatibility pending; physical recovery NOT implemented**. Proposed separate opt-in follow-on to E3d5c6b Direct Build Authorization. Date: 2026-11-20. Engine: Godot 4.6.2 Stable; repository `ChrisGiggleman/industrial-warfare`, `main`. The separate Direct Build scene remains the only intended prototype scope; Main and accepted scenes remain unchanged.

## Why this is needed / reproduced live evidence

Developer captured a real F6 session in `res://scenes/core/playable_direct_build_authorization_e3d5c6b.tscn`:

- During a third Direct **Test Storage** build, Starter Storage showed **4 ingots** (previous completed Storage+Press consumed 8, third site picked up 3), job **10%**, `PAUSED 1`, drone **AT SITE / cargo 0**, worker **0/1**, generator OFF, output/spare **0/0**. This confirms power loss paused the job after real delivery, rather than advancing the timer.
- Developer pressed **X** to cancel. Output showed `BLUEPRINT CANCELLED`; job left the queue. Drone returned empty to Hub and showed **DOCK WAIT**, battery **28.4/40**, `Rearms 2` (unchanged), generator still OFF, Starter Storage **4 ingots**. The original cancelled site was **not completed**. Because power is OFF, recharging is not currently possible; switching ON restores ordinary charging but does not recover staged stock.
- This is **not** evidence that three ingots were destroyed. Existing Stage B isolated tests and authoritative source retain or refund the unused three into original locked staging; the screenshot does not show the buffer contents, so actual live staging quantity still needs read-only verification. The user expects a physical drone to collect these remaining materials and return them to Storage.

Confirmed source contracts: `WorldInteraction._cancel_blueprint_site` calls original `ConstructionJob.cancel()`. `ConstructionSite._cancel_job_site` frees the construction footprint. `BlueprintConstructionMaterialEscrow.recover_to` refunds a paused work reservation to its pinned **staging source**, never to Starter Storage. `BlueprintConstructionSiteStagingRegistry` deliberately retains the original site/staging/port/buffer claim; `inventory_for_site` refuses terminal sites but `has_locked_pair` permits read-only locked-claim auditing. `PrototypeDroneAutomaticDispatch` sends the now-empty worker drone home after terminal delivery; `PrototypeDroneReturnReservations` currently supports **cargo already on the drone**, not pickup from terminal staging. There is no accepted terminal staging pickup lifecycle or release API. `docs/DRONE_CONSTRUCTION_LOGISTICS.md` already reserves this for later physical recovery work.

## Invariants — cannot be bypassed

1. Only the **original cancelled job's exact staging inventory** is eligible. Link an immutable terminal recovery ticket to the original job, building definition, item bill, staging port, inventory and immutable site identity (plus original hover location) while the site still exists; retain provenance after the site is freed. Never reuse another site's stock/port or accept a caller-supplied bill as physical proof.
2. Recovery starts **after terminal cancellation and escrow refund settlement**, never against a still constructing/completed site. Observe the actual source inventory; complete buildings' committed material bills are **consumed and never recovered**.
3. Source debit happens **only when the drone arrives at the real original hover pickup** and a guarded token-bound pickup succeeds. Destination receives cargo **only after a metered flight and verified physical dock arrival**. Reservations, labels and timestamps are not stock.
4. The selected destination is a real eligible Storage dock (initial scene has Starter Storage only). Reserve an exact amount of free capacity atomically before source debit; if no dock has capacity, wait with materials protected. Revalidate target, return claim, cargo, route, battery and capacity through the trip. Destination failures must not discard cargo or cause duplicate depot deposits.
5. Use the **existing one-drone physical lifecycle and finite battery/Hub recharge**. No second `_process`, worker, or construction timer; recover after current terminal assignment is safely rearmed, with clear priority and no preemption. Avoid routing a newly authorized construction job and a recovery mission from the same drone simultaneously.
6. Remain exact-bill, single-item, whole-load initially (Storage 3 Test Ingots; Press 5). Multi-trip/multi-item/fleet recovery and bulk silo/dock upgrades are later separate gates. No instant transfers, free source stock, silent legacy fallback or premature unlock.
7. Cancellation once in every phase must be idempotent. Missing site, destroyed receiver, moved/disconnected port, failed reserved return, no power, blocked route or insufficient energy must yield **recoverable quarantine/wait** and visible status—not release, auto-restock or partial duplication. Terminal staging claims stay locked until an independently verified, explicit reclaim/release policy is accepted.
8. Keep user-facing status truthful: distinguish `CANCELLED — MATERIALS HELD AT SITE`, `RECOVERY WAITING — NO STORAGE CAPACITY`, `RECOVERY IN TRANSIT`, and `RECOVERED`. Hub output 0 / dock wait is finite charging behavior, not material loss.

## Proposed gated implementation sequence

### Stage A — terminal custody ledger, read-only validation (isolated)

- Separate default-off experimental ledger/observer for the exact Direct Build scene. Freeze original cancelled-site provenance before `queue_free`; audit old receiver, escrow terminal recovery, source item counts and lock identity after the site disappears.
- Do not debit, transfer, spawn or authorize anything in Stage A. Refuse missing/ambiguous ownership, active/complete jobs, stale ports and duplicated ticket IDs. A cancelled job with zero staged stock remains a no-op, not a free pickup.
- Isolated F6 fixtures must prove existing 3- and 5-ingot delivered cancellations remain protected with no creation/loss. Compatibility gate: Stage B cancellation/escrow/registry/return tests; all earlier scene defaults remain off.

### Stage B — real pickup, return and finite movement (isolated)

- Add one token-bound recovery pickup transaction from a verified terminal staging inventory and anchored original hover point. An idle, charged drone reserves actual destination capacity then physically travels to source, debits only on arrival, carries real cargo and physically returns/unloads to a reserved eligible Storage dock; finite energy decrements.
- Double-dispatch, cancellation/restart, blocked destination, full Storage, stale source/port, energy failure, no battery charge and mid-flight receiver loss all fail closed with preserved material custody and a deterministic retry policy. Do not use current `inventory_for_site` for terminal sites; add a distinct guarded terminal-only API.
- Exactly 3/5 item conservation and distinct locked records after recovery; do not expose `release` from registry simply because buffer is empty. Stage B isolated Godot F6 + targeted compatibility must pass before playable wiring.

### Stage C — exact-scoped playable automatic recovery

- Enable the accepted recovery component only in a separately named or separately opted-in Direct Build recovery scene, never Main or current accepted `playable_direct_build_authorization_e3d5c6b.tscn` by default. Integrate terminal recovery tasks with the sole drone lifecycle after its safe rearm; no parallel authority.
- Player test: 15 → 12 for delivered cancelled Storage, then after verified physical recovery 12 → **15**; a delivered cancelled Press returns 5. Battery/headroom and storage capacity are finite; the generator OFF blocks recharge but never consumes/loses staged stock.
- Record manual screenshots of staged amount, pickup cargo, real return flight, final stock, empty staging and correct worker/queue. Retain HUD power-coverage diagnostic as a separate UI enhancement, never a bypass.

### Stage D — final compatibility and milestone closeout

- Fresh isolated and targeted compatibility suites against original **E3d5c6a 56/785**, Direct Build Stage A **11**, Direct Build Stage B **14**; preserve unique accepted baseline **58/810** until new local checks are confirmed and do not double-count reruns.
- Do not treat this design, the screenshots or unrun tests as new accepted checks. Manual E3d5c6b Stage C 10-check gate is still **pending** independently. Its loaded-cargo cancellation C1 tests existing in-flight recovery; post-delivery staged recovery is *not* its acceptance prerequisite. Do not silently redefine the 10-check Stage C gate.

## Separate later features

Power-coverage warnings and building requirements HUD live integration; additional construction types, conveyor/splitter/merger and power pole placement; multi-item/multi-trip, multiple drones, silo or researched remote depot/docking; persistence and destruction integration; locked claim release/garbage collection require separate authorization/test gates.

## Current checkpoint

- E3d5c6a: **56/785** accepted plus manual **9/9**.
- E3d5c6b Stage A: **11 isolated** and **28/374 compatibility reruns** accepted.
- E3d5c6b Stage B: **14 isolated** and **29/395 compatibility reruns** accepted.
- Unique automated combined accepted baseline: **58 suites / 810 checks** (last full combined 58/810 rerun pending).
- E3d5c6b Stage C: manual **10-check gate not yet accepted**. Visible powered Storage+Press completed (15→7; two rearms); generator-OFF paused 10%-complete third Storage, then player cancelled with only 4 Starter Storage ingots; local staged stock not directly read. Generator-ON resume and all other manual gates not fully evidenced.
- E3d5c6c: **design proposed only**, no implementation or tests.


### 2026-11-20 — E3d5c6c Stage A READ-ONLY CANCELLED CUSTODY AUDIT STAGED (13 isolated checks pending)

Implemented one **default-OFF**, read-only `PrototypeCancelledSiteCustodyAudit` component for the **exact** opt-in Direct Build scene when explicitly added by an isolated test. The existing playable scene **does not instantiate it**, and all prior scenes / Main, adapters, escrow, drone lifecycle, tests and manifests remain unchanged. The component has no `_process`, cargo pickup, inventory debit, escrow transaction, power/worker/job authorization, receiver unlock, or resource refund. `configure()` verifies original same-scope owned Registry and Escrow services. `capture_site()` is called before cancellation/freed-site deletion and validates an original QUEUED/CONSTRUCTING/PAUSED job, canonical Storage 3-ingot or Press 5-ingot material bill, original registry locked pair, exact staging/port/buffer, site identity and hover coordinate; rejects foreign, reused or duplicate tickets. A job-cancelled signal freezes terminal status and the original escrow record ID where present; `observe()` remains read-only and after terminal escrow refund reports `ready_read_only` with exact quantity, `empty_no_pickup`, or conservatively `quarantined`/`escrow_unsettled`. Completed jobs explicitly return `complete_not_recoverable`. Source inventory/port objects are never handed to callers by the observation API; original pinned lock survives site free. Disabling the opt-in fails closed.

New F6 scene: **`res://tests/cancelled_site_custody_e3d5c6c_stage_a_test.tscn`**, expected **13/13 checks A–M**, final banner `ALL 13 CANCELLED SITE CUSTODY E3D5C6C STAGE A TESTS PASSED`. The script uses the accepted real Direct WorldInteraction click/camera ground ray and the original one-drone physical automatic adapter. Checks: A strict gate and defaults; B distinct original claims and impostor pairs refused; C duplicate tickets no authorization/debit; D physical 3-unit pickup/delivery; E delivered cancellation 3 protected; F freed-site retained provenance; G moved receiver quarantine; H independent 5-unit Press; I escrow refund on during-work cancellation; J exact **7 source + 3 locked Storage + 5 locked Press = 15** and two rearmed trips; K pre-pickup cancellation zero recoverable stock; L toggled OFF fails closed; M completed Storage consumes 3 and cannot be recovered. No new test results are **claimed**; compile and local F6 runtime verification are **pending**. After 13/13 developer verification, perform a small targeted compatibility rerun of existing registry/escrow/delivered-cancel/Direct Build suites. Reruns are not cumulative unique tests.

E3d5c6b Stage C manual 10/10 remains **pending**; two completed buildings 15→7 and generator OFF pause at 10% observed, cancellation after delivery left stock 4 until future recovery. This Stage A is **only provenance audit** and does **not return three ingots to Storage yet**. Stage B physical pickup/transport, capacity reservations and finite charge remains for subsequent separate acceptance; do not claim ability to recover materials. The prior unique accepted baseline remains **58 suites / 810 checks**, and no combined 58/810 rerun is claimed.


### 2026-11-20 — E3d5c6c Stage A local F6 halted at Check E hover-position assertion (test-only correction staged)

Developer screenshot of `res://tests/cancelled_site_custody_e3d5c6c_stage_a_test.tscn` shows **assertion failed at test line 281**: `obs["hover_position"].is_equal_approx(STORAGE_POS + Vector3.UP * 2.0)`. The test has already entered Check E after the physical Storage pickup/delivery steps, and the earlier E assertions on `ready_read_only`, amount 3, original instance ID, canonical bill and definition ran without stopping. The visible image does not include numerical values for the recorded hover; likely culprit is the test's **hardcoded zero Y** for an actual Godot ray-placed site, not a verified custody loss. No 13/13 acceptance; any later checks F–M were not verified by this run.

**Narrow test-only correction:** Before cancelling the original site, store `actual_hover = storage.global_position + Vector3.UP * 2.0`, assert actual site **X/Z match the intended STORAGE_POS plot**, and assert the original registered physical receiver is at that hover. After cancellation, compare the audit's immutable `obs["hover_position"]` to that captured original hover. Include both vectors in the failure message. This tests original-site provenance and immutable receiver geometry without assuming world Y=0, modifying the audit/registry, unlocking staged stock, or changing gameplay collision/placement logic. No `_process` or material movement added. The original 58/810 baseline remains accepted; no compatibility or new tests claimed.

**Rerun after pulling current main:** F6 same `cancelled_site_custody_e3d5c6c_stage_a_test.tscn`, expected 13/13 A–M; final banner `ALL 13 CANCELLED SITE CUSTODY E3D5C6C STAGE A TESTS PASSED`. If another assertion fails, developer should provide first Debugger error and Output PASS lines; do not count Stage A as accepted until 13/13. Stage B physical recovered-material pickup/return still unimplemented. E3d5c6b manual Stage C remains open.


### 2026-11-20 — E3d5c6c Stage A isolated custody audit ACCEPTED 13/13; compatibility 15/218 pending

Developer explicitly confirmed **all 13/13 isolated Stage A custody test checks passed locally in Godot** after the isolated hover-Y assertion correction at commit [0ef6947d](https://github.com/ChrisGiggleman/industrial-warfare/commit/0ef6947d1b215da05a606b78ae2725d8f089c03f). This is user-reported local Godot execution, not assistant execution. Checks cover original site+job+receiver identity; canonical 3/5 bill; duplicate and foreign-ownership refusal; physical delivery; protected storage after post-delivery cancellation; survival after site free; moved receiver quarantine; during-work escrow refund into original locked Press staging; exact **7 source + 3 Storage staging + 5 Press staging = 15** conservation; zero-stock cancelled sites; strict default-off and terminal completed buildings never recoverable. The first pre-fix Check E assertion was test-only; successful rerun supersedes it.

**Unique accepted automated milestone baseline: 59 suites / 823 checks** = previously accepted E3d5c6a + E3d5c6b **58/810** plus this isolated 1/13. No fresh full 59/823 combined run claimed. E3d5c6b Stage C manual 10 checks still pending and physical post-delivery recovery **NOT implemented**.

Next acceptance gate is **15 existing suites / 218 rerun checks** with named exact F6 scenes and counts in [CANCELLED_SITE_PHYSICAL_RECOVERY.md](CANCELLED_SITE_PHYSICAL_RECOVERY.md) and new `tools/cancelled_site_custody_stage_a_compatibility.csv`. 13 are in original 56-suite manifest (193 checks); 2 Direct Build suites account for 25; **all overlap previously accepted checks**. Compatibility is **not yet executed**. No gameplay or existing accepted scenes/tests/manifests changed by this acceptance bookkeeping.


## E3d5c6c Stage A targeted compatibility gate — pending local F6

**15 previously accepted suites / 218 existing checks**, selecting tests that exercise staging/receiver ownership, escrow, cancellation, physical cargo delivery, return reservations and the E3d5c6b Direct Build entry points. The first **13 suites / 193 checks** belong to the E3d5c6a accepted final regression manifest `tools/building_expansion_final_regression.csv`; the last **2 suites / 25 checks** are E3d5c6b Stage A/B isolated suites previously accepted separately. All 15 scene files were verified to exist on GitHub main. Gate manifest: `tools/cancelled_site_custody_stage_a_compatibility.csv`.

| Scene (under `res://tests/`) | Expected checks |
|---|---:|
| `blueprint_material_staging_e3d5c4c_test.tscn` | 16 |
| `blueprint_physical_staging_e3d5c4d_test.tscn` | 16 |
| `blueprint_site_staging_ownership_e3d5c4h_test.tscn` | 16 |
| `blueprint_anchored_receiver_e3d5c4i_test.tscn` | 16 |
| `blueprint_receiver_recovery_audit_e3d5c4j_test.tscn` | 12 |
| `blueprint_owned_readiness_e3d5c4r_test.tscn` | 18 |
| `blueprint_construction_material_escrow_e3d5c2a_test.tscn` | 16 |
| `drone_physical_delivery_e3d5c5x5b_test.tscn` | 13 |
| `drone_delivered_worker_e3d5c5x5c_test.tscn` | 16 |
| `drone_cancelled_cargo_recovery_e3d5c5x6_test.tscn` | 13 |
| `drone_post_delivery_cancellation_e3d5c5x7c2_test.tscn` | 13 |
| `drone_lost_site_recovery_e3d5c5x7c3_test.tscn` | 14 |
| `drone_return_reservations_e3d5c5x4b_test.tscn` | 14 |
| `playable_direct_build_authorization_e3d5c6b_test.tscn` | 11 |
| `playable_direct_build_authorization_e3d5c6b_stage_b_test.tscn` | 14 |
| **15 existing suites** | **218** |

Open one scene at a time and press **F6**; check PASS banners/counts in Godot Output/Debugger. Report a failure's first assertion and preceding PASS results before continuing. **Do not add** 218 rerun checks to the 59-suite / 823 unique accepted baseline. After explicit 15/15, 218/218 developer confirmation, record Stage A fully accepted and begin E3d5c6c Stage B **separately isolated** real drone pickup/return implementation. No new recovery flight was staged yet. E3d5c6b Stage C manual 10-check gate and final combined full regression remain outstanding.


### 2026-11-20 — E3d5c6c Stage A compatibility suite 15 halted; Stage B fixture transform correction pending F6

Developer reported reaching the final suite of the **15-suite / 218-check Stage A targeted compatibility gate** and supplied a Godot 4.6.2 debugger screenshot showing `res://tests/playable_direct_build_authorization_e3d5c6b_stage_b_test.gd:182` asserting `building.get_parent() == sandbox and building.global_position.is_equal_approx(at)`. This is in `_check_built` after `_finish` has already observed a completed job and emitted one building. The compound assertion does **not** isolate which clause failed. The first 14 compatibility scenes were marked complete in the user's test tracker, but no complete Output log was supplied; therefore the **full compatibility gate remains pending**, not 15/15 accepted.

Source inspection: `ConstructionSite._finish_construction` parents the actual building to `get_parent()` and copies the original `global_transform`; `WorldInteraction._update_placement_preview` uses physics ray elevation for the construction site, not guaranteed world Y=0. **Likely test-only hardcoded Y mismatch**, not verified material loss or gameplay regression. Prior Stage A custody fixture similarly needed to compare against actual site hover position.

**Narrow test-only correction:** snapshot each actual site's full `global_transform` (Press, High Blueprint Storage, Normal Direct Storage) immediately after real placement; at completion, separately assert (1) original actual site X/Z matches expected plot, (2) completed building's parent is sandbox, (3) completed building's **full world transform** equals the original captured site transform, and (4) scene definition/runtime binding are unchanged. The assertions now include expected and actual transforms/parent in error messages, to distinguish a true ownership/placement regression if it persists. No gameplay scripts, scene, prior custody audit, material transport, escrow, power, worker, or ownership behavior changed. No compatibility result claimed from the correction.

**Local next step:** Pull current main and rerun **only** `res://tests/playable_direct_build_authorization_e3d5c6b_stage_b_test.tscn` with F6 (existing 14/14 isolated suite). If it passes, report successful final suite plus previously completed 14 to record 15/15, 218/218 compatibility gate; do not double-count it in unique accepted **59-suite / 823-check baseline**. If it fails, capture first Debugger error and preceding PASS lines; corrected assertions should reveal whether parent or actual transform differs. E3d5c6c Stage A isolated **13/13 accepted**, full Stage A pending compatibility. No physical post-delivery return code yet; E3d5c6b manual Stage C remains pending.


### 2026-11-20 — E3d5c6c Stage A compatibility last suite silently exits after PASS I; exact fixture problem corrected, rerun pending

Developer posted Output of `res://tests/playable_direct_build_authorization_e3d5c6b_stage_b_test.tscn`: **PASS A through PASS I** now print, including all three strict completed-building original site transform checks after the previous fix. The last Output line is `DIRECT BUILD AUTHORIZED: Prototype Ammunition Press | Normal priority`, immediately followed by `--- Debugging process stopped ---`, with **no PASS J** or visible assertion. They clarified this is repeatable, not a manual stop.

Confirmed test control-flow cause: in `_checks` after PASS I, `var waiting := _place(demo, PRESS, WAIT_POS)` and an `if not is_instance_valid(waiting): sandbox.free(); return` branch **silently ends** the whole isolated test. The prior `WAIT_POS=Vector3(-5,0,0)` was copied from an expansion fixture's **Storage** LATE_POS; that building has odd footprint (1×3), but the newly placed **Press** has even 2×2 footprint and must center on **half-integer X/Z**. Godot's real Direct placement can succeed after grid snapping even though the test helper `_at()` looks for the exact requested integer X/Z, causing a null lookup and early return. Moreover the previous plot is far outside the Hub's finite power radius (4.5), so it would fail the following coverage assertion. This is a test-fixture issue, not a confirmed gameplay/drone bug.

**Narrow test-only correction:** The fourth Press now requests `WAIT_POS=Vector3(1.5,0,-5.5)`, exact half-grid coordinates. Its footprint stays inside the existing Hub at `(2,0,-3)` 4.5-unit corner coverage; the open plot north of the Hub is away from the three completed building interiors and ReferenceCube. Do not modify real placement, building footprints, power coverage, physical drone movement, escrow or ownership. `_place` now prints the requested/observed actual sites and raises an explicit debugger assertion on any future null lookup, instead of returning silently. Check J now prints a start marker, and the waiting site/coverage guards fail visibly if the plot is blocked or coverage invalid. The original 14 checks A–N and expectations (including 15→4 and unaffordable fourth Press) are unchanged.

**Local follow-up:** Pull main and F6 **only** `res://tests/playable_direct_build_authorization_e3d5c6b_stage_b_test.tscn`. Expected PASS J, then K–N, then `ALL 14 PLAYABLE DIRECT BUILD AUTHORIZATION E3D5C6B STAGE B TESTS PASSED`. No Godot execution by assistant. Previous 14 compatibility suites are developer-reported as passed; full **E3d5c6c Stage A 15 suites / 218 checks** is **not yet accepted** until this final rerun passes. Unique accepted baseline remains **59 suites / 823 checks**, and E3d5c6b Stage C manual is still pending. Recovery flight implementation Stage B has not begun.


### 2026-11-20 — E3d5c6c Stage A fully accepted (15/218 compatibility) and Stage B1 destination capacity claim staged

Developer explicitly confirmed the **corrected final** `playable_direct_build_authorization_e3d5c6b_stage_b_test.tscn` passed **all 14/14** locally after the half-grid powered `WAIT_POS=(1.5,0,-5.5)` fix. Previous 14/15 targeted compatibility suites were reported as passing; together the committed 15-suite gate is **15/15 suites and 218/218 checks accepted**, with no double count of the final suite's earlier incomplete/failed executions. Stage A previously accepted isolated **13/13**. E3d5c6c Stage A FULL acceptance evidence: **16 suite executions / 231 checks** (13 new + 218 overlap). Unique accepted milestone baseline remains **59 suites / 823 checks** (prior 58/810 + 13 new). These are **developer-reported local Godot results**, not assistant-executed tests; no fresh combined 59/823 regression claimed.

Next step staged as **E3d5c6c Stage B1**: default-OFF `PrototypeCancelledSiteRecoveryCapacity` plus strictly read-only audit provenance matching. Separate isolated ten-check Godot test `res://tests/cancelled_site_recovery_capacity_e3d5c6c_stage_b1_test.tscn` verifies that only the authentic cancelled site with a terminal, full Storage or Ammunition Press bill can reserve **actual eligible destination Storage space** after the existing drone has fully rearmed. It checks exact source staging/port/buffer/job/ticket identity, finite whole-route battery forecast (idle drone→original hover→Storage→home), private inbound-space tokens, original Storage docks, destination availability/capacity, competing claims, strict one owner/ticket and claim quarantine/release. No normal scene nodes, no new _process, no cargo movement, no escrow debit, no drone flight, no staged-site unlock, no transport bypass. The accepted custody audit Stage A is only extended with a **read-only original source matching predicate**; original mutation semantics remain unchanged. See [CANCELLED_SITE_RECOVERY_STAGE_B1.md](CANCELLED_SITE_RECOVERY_STAGE_B1.md) for exact acceptance steps.

**Stage B1 implementation staged, local Godot F6 10/10 NOT YET RUN OR ACCEPTED.** Stage B2 will implement the actual physical recovery trip only after staged claim testing and targeted compatibility pass. E3d5c6b Stage C manual 10/10 remains pending; prior visible build/power pause/cancellation evidence separately recorded. No automatic belt, splitter/merger, multi-item/multi-trip, fleet, silo/researched dock, persistence, or expanded destruction is activated.
