# Industrial Warfare — Current Development Handoff

Updated 2026-11-20. Repository: ChrisGiggleman/industrial-warfare, main. Godot 4.6.2, GDScript, Forward+.
Read this first when resuming a new conversation. GitHub history and actual source take precedence over chat recollection; verify main HEAD and any local changes before making edits.

## Current checkpoint

**E3d5c6c Stage A read-only cancelled-site custody audit STAGED; local F6 13/13 pending. Recovery flights NOT implemented. Original 58/810 accepted baseline intact, E3d5c6b Stage C manual still pending.**

### 2026-11-20 — E3d5c6c Stage A READ-ONLY CANCELLED CUSTODY AUDIT STAGED (13 isolated checks pending)

Implemented one **default-OFF**, read-only `PrototypeCancelledSiteCustodyAudit` component for the **exact** opt-in Direct Build scene when explicitly added by an isolated test. The existing playable scene **does not instantiate it**, and all prior scenes / Main, adapters, escrow, drone lifecycle, tests and manifests remain unchanged. The component has no `_process`, cargo pickup, inventory debit, escrow transaction, power/worker/job authorization, receiver unlock, or resource refund. `configure()` verifies original same-scope owned Registry and Escrow services. `capture_site()` is called before cancellation/freed-site deletion and validates an original QUEUED/CONSTRUCTING/PAUSED job, canonical Storage 3-ingot or Press 5-ingot material bill, original registry locked pair, exact staging/port/buffer, site identity and hover coordinate; rejects foreign, reused or duplicate tickets. A job-cancelled signal freezes terminal status and the original escrow record ID where present; `observe()` remains read-only and after terminal escrow refund reports `ready_read_only` with exact quantity, `empty_no_pickup`, or conservatively `quarantined`/`escrow_unsettled`. Completed jobs explicitly return `complete_not_recoverable`. Source inventory/port objects are never handed to callers by the observation API; original pinned lock survives site free. Disabling the opt-in fails closed.

New F6 scene: **`res://tests/cancelled_site_custody_e3d5c6c_stage_a_test.tscn`**, expected **13/13 checks A–M**, final banner `ALL 13 CANCELLED SITE CUSTODY E3D5C6C STAGE A TESTS PASSED`. The script uses the accepted real Direct WorldInteraction click/camera ground ray and the original one-drone physical automatic adapter. Checks: A strict gate and defaults; B distinct original claims and impostor pairs refused; C duplicate tickets no authorization/debit; D physical 3-unit pickup/delivery; E delivered cancellation 3 protected; F freed-site retained provenance; G moved receiver quarantine; H independent 5-unit Press; I escrow refund on during-work cancellation; J exact **7 source + 3 locked Storage + 5 locked Press = 15** and two rearmed trips; K pre-pickup cancellation zero recoverable stock; L toggled OFF fails closed; M completed Storage consumes 3 and cannot be recovered. No new test results are **claimed**; compile and local F6 runtime verification are **pending**. After 13/13 developer verification, perform a small targeted compatibility rerun of existing registry/escrow/delivered-cancel/Direct Build suites. Reruns are not cumulative unique tests.

E3d5c6b Stage C manual 10/10 remains **pending**; two completed buildings 15→7 and generator OFF pause at 10% observed, cancellation after delivery left stock 4 until future recovery. This Stage A is **only provenance audit** and does **not return three ingots to Storage yet**. Stage B physical pickup/transport, capacity reservations and finite charge remains for subsequent separate acceptance; do not claim ability to recover materials. The prior unique accepted baseline remains **58 suites / 810 checks**, and no combined 58/810 rerun is claimed.

**Stage C partial: powered construction pause at 10% verified with generator OFF; cancellation after delivery left Starter Storage at 4 ingots and empty drone DOCK WAIT. Original staging refund is protected, but physical staged recovery remains unimplemented; separate E3d5c6c design staged. No Stage C 10/10 acceptance.** See [CANCELLED_SITE_PHYSICAL_RECOVERY.md](CANCELLED_SITE_PHYSICAL_RECOVERY.md).

### 2026-11-20 — Stage C generator-OFF pause verified; cancelled delivered Storage material recovery gap reproduced

Developer supplied two local playable screenshots and reports: `power off work but if you cancel the building the ingots do not get returned`. During powered-site third Test Storage construction, the live HUD shows **job progress 10% / PAUSED 1**, **Hub output 0 / Spare 0**, **Worker slots 0/1**, drone **AT SITE / Cargo 0**, Starter Storage **4 ingots**. Generator button says **Turn generator ON (test)**. After pressing X, Output shows **BLUEPRINT CANCELLED**; queue and pause count drop to 0, drone returns empty and is **DOCKED / DOCK WAIT** with **Battery 28.4/40**, no return reservation, **Rearms 2** unchanged, still **4** ingots and generator still OFF. Thus **power OFF pausing is observed and the cancellation/refund-to-Starter-Storage gap is confirmed in gameplay**. Power-ON resume of this particular job has NOT been demonstrated; generator OFF means charging is unavailable and explains DOCK WAIT, but would not automatically recover the empty drone's former delivery.

Source-backed distinction: if the third Storage had actually completed, its 3-ingot bill would be consumed; here the job was cancelled while 10% complete. The accepted escrow/cancellation code returns the uncommitted bill to the **pinned protected original site staging buffer**, not Starter Storage. The screenshot does not display or independently prove the staged buffer amount; staged custody is supported by original source behavior and accepted automated cancellation checks. Existing physical return logic only handles material still aboard the drone. Returning physically delivered and then cancelled materials is a **deliberately unimplemented gameplay capability** and needs strict provenance, token-bound pickup, destination capacity, finite flight/charge and conservative ownership. No claim that stock was irretrievably destroyed.

New proposed design [CANCELLED_SITE_PHYSICAL_RECOVERY.md](CANCELLED_SITE_PHYSICAL_RECOVERY.md) labels this next separate **E3d5c6c** gate (design only): A terminal provenance/escrow audit, B physical single-load pickup and return, C opt-in playable automatic recovery, D compatibility/closeout. No gameplay/test code changed, no implementation/test result claimed. Do not alter Main/ordinary scenes, remove protected registry locks, teleport refund or weaken power coverage. E3d5c6b Stage C original manual 10-check gate still open; its *loaded-cargo* C1 recovery remains distinct from the new *post-delivery* gap. Unique automated accepted **58/810**, Stage A/B accepted, final fresh 58/810 not run.

**Stage C partial evidence: two actual building completions (Storage + Press), 15→7 ingots, 2 drone rearms. Power pause/resume, unsupported/duplicate rejection, Blueprint authorization and loaded cancel remain unverified; 10/10 is NOT accepted.**

### 2026-11-20 — E3d5c6b Stage C: Test Storage and Ammunition Press visibly complete, exact 15→7 material accounting

Developer supplied a new playable Godot screenshot of `res://scenes/core/playable_direct_build_authorization_e3d5c6b.tscn`: visible completed Test Storage adjacent to Starter Storage and a dark operational-looking Ammunition Press structure to the right of the Hub. Left live automatic construction HUD: Starter Storage **7 ingots (0 reserved)**, drone **IDLE / Cargo 0/5**, **battery 40/40**, **Rearms 2**, **Queue H/N/L 0/0/0**, generator output/spare **12**, worker slots **0/1**. These match the expected two separate successful physical construction cycles and original bills: starting 15 − Storage 3 − Press 5 = **7 ingots**. The user provided screenshot rather than a separate narrated checklist; screenshot supports visual completion/material accounting and return/recharge, but does not independently demonstrate generator OFF pause and ON resume during active work, unsupported building rejection, same-footprint duplicate click rejection, three planned-only blueprint placements, explicit selection/batch authorization, or loaded Press cancellation. Therefore do **not** record full Stage C 10/10 acceptance or final combined 58/810 rerun. Stage A and Stage B remain fully accepted, unique automated baseline **58 suites / 810 checks**.

Next user manual gates: **Fresh F6** for generator OFF/ON *while* Storage or Press is constructing (verify worker 1/1, progress stops then resumes); confirm unsupported/duplicate click rejection. After that, **fresh F6** Session B blueprint planning with P/Q/H/E/Ctrl+E and exact 15→4 conservation, followed by **fresh F6** Session C cancelled *loaded cargo* (Press Cargo 5/5, X before unloading; physical return restores Starter Storage to 15). Distinguish this from already-confirmed cancelled-after-delivery protected staged materials (not automatically recovered yet; separately gated feature). No gameplay or test modifications in this documentation checkpoint.

**New Stage C partial manual evidence: covered Storage completed (15→12 ingots, drone rearmed once). Press + power pause/resume + remaining Stage C checks pending; no 10/10 acceptance.**

### 2026-11-20 — E3d5c6b Stage C manual: powered-site Test Storage completed (partial gate evidence)

Developer supplied a live Godot screenshot and explicitly said “it built the storage” after repositioning the direct Storage placement near the labeled `STORAGE SITE` within the completed Hub's full-footprint 4.5-unit power coverage. Screenshot shows a new Storage mesh/port next to Starter Storage and Hub, Starter Storage **12 ingots** (from 15; canonical Storage bill 3), drone **IDLE** with **cargo 0/5**, **battery 40/40**, **Rearms 1**, zero planned/queued/active jobs, and generator output/spare **12**. This supports manual Storage direct-placement/completion and same-drone return/recharge at an appropriately powered location, and explains why no 3-ingot return occurs for successful building completion. It does **not** independently verify progress pausing with generator OFF, Press build, or the complete Stage C A1–A6 set; do not claim 10/10 manual acceptance. The earlier cancelled-after-delivery staging case remains separate and physical staged-item recovery remains a future gated feature.

Next manual action **in the same live fresh session**: use Ammunition Press hotbar (check actual assignment via M if needed), click marked `AMMO PRESS SITE`, observe real five-ingot pickup and delivery, wait for actual `CONSTRUCTION` with worker 1/1, turn generator OFF to verify pause and ON to verify resume, then complete Press with starter stock expected **7** (15−3−5). Do not turn power OFF before worker admission. If the Press is blocked or a diagnostic error occurs, capture the live HUD and first Output/Debugger error rather than altering rules. Stage B fully accepted; unique automated baseline **58/810** unchanged; Stage C manual gate pending.

**Stage C: developer confirmed original Storage job was cancelled without completion. Source stock stayed 12/15 and drone returned empty, consistent with protected delivered staging; physical post-delivery staged recovery is NOT implemented and requires a separately gated milestone. Manual 10/10 remains pending.**

### 2026-11-20 — Stage C user confirms incomplete/cancelled site, stock remains 12/15; post-delivery recovery not yet implemented

Developer supplied three consecutive live Godot screenshots: starting sandbox **15 Test Ingots**, one idle drone and no jobs; during play **12 ingots**, **Planned: 3 / Queued: 0** with drone empty/IDLE and **Rearms: 1**; after cancellation **Planned: 0 / Queued: 0**, Starter Storage still **12**, drone empty/IDLE, fully charged. Developer explicitly confirms **construction did not complete**. Correct prior mistaken suggestion that 12 might represent successful Storage material consumption: that possibility is ruled out for this sequence. The three visible PLANNED blueprint sites alone could not debit material; some already-authorized dispatched site consumed the three from source before cancellation. Screenshots alone do not show escrow/staging inventory or pinpoint which site had them; the accepted code and Stage B isolated tests predict uncommitted **3 ingots remain in the cancelled original site's protected staging buffer**, not teleported/refunded to Starter Storage. Do **not** claim independently verified staging contents from these screenshots or mark a material conservation regression without a readout.

Existing source/protocol: `WorldInteraction._cancel_blueprint_site` calls `job.cancel()`; `ConstructionSite._cancel_job_site` queues the site for deletion; `BlueprintConstructionMaterialEscrow._on_cancelled` calls `recover_to`, preserving/refunding into the *pinned staging inventory* if escrowed; `BlueprintConstructionSiteStagingRegistry` retains original claimed staging/port, no release; `PrototypeDroneAutomaticDispatch` returns its **empty** delivered drone to Hub to recharge/rearm. `docs/DRONE_CONSTRUCTION_LOGISTICS.md` explicitly keeps **future physical recovery flights from cancelled delivered site staging** separately gated; presently no accepted service performs staged-material pickup and return. By contrast **cancelled loaded drone cargo** is physically returned to reserved eligible dock, and an actually **completed building commits** its material bill (stock 12 is then expected). Therefore this is a **real gap between the intended player recovery experience and currently implemented experimental scope**, not proof of deleted inventory. Do not silently refund or unlock a claimed buffer to satisfy manual testing.

Stage C manual 10-check gate still **pending**. Test A covered-building completion at labeled Storage position and check worker 1/1, 15→12 only after actual completion. Test C1 in separate fresh F6, cancel Press **while drone CARGO 5/5 before unload** and verify physical return restores 15. Add optional non-counted observation for cancellation **after** unload: donor Storage remains debited, drone empty, materials expected in protected staging, no playable physical recovery available yet. For full player-expected cancellation recovery, design/implement a separately opt-in `E3d5c6c` or subsequent subgate with exact original site identity, physical staged pickup, destination capacity reservation, finite drone battery and movement, cancel-safe atomic transfer, conservative retry when blocked, and no release/duplicate claims without provenance. Consider explicit HUD for staged quantities and power coverage, but do not merge experimental features into Main. Baseline remains **58 unique suites / 810 automated checks**, Stage A/B fully accepted; no new Godot verification, Stage C acceptance, compatibility or final regression claimed.

**Stage C inventory interpretation pending: 12 ingots and idle/rearmed drone can indicate a completed 3-ingot Storage cost OR cancelled delivered materials retained in protected staging. No material-loss conclusion or manual acceptance yet.**

### 2026-11-20 — Stage C screenshot: 12 ingots, drone idle/rearmed, no cargo; distinguish spend from retained staging

Developer reports "drone did not bring back the 3 ingots" after a new live F6 screenshot. Observable left HUD: **Storage 12 ingots (0 reserved); drone IDLE; Battery 40/40; Cargo 0/5; Rearms 1; H/N/L queue 0/0/0; worker 0/1; no eligible site; generator ON, output/spare 12**. This proves the drone ended its assignment and empty inventory was not replenished, **not by itself whether the site completed or was cancelled** (no construction-site state or action history shown; right panel has no selection).

Expected conservation is state-dependent: (1) **Successful canonical Test Storage completion consumes 3 ingots**, leaving starter stock 12 from 15, with completed Storage replacing the site and drone returning empty, fully charged. **No return is expected** after completed construction. (2) **Cancellation while cargo is aboard the drone before unloading** must invoke physically metered return to starter inventory; after return/recharge the 3 ingots should be restored to 15, provided the dock can accept them. (3) **Cancellation after delivery / during construction** occurs with cargo already zero; the already-delivered 3 ingots are protected by the original staging receiver/escrow recovery, not automatically transported back to Starter Storage. Thus 12 starter ingots can be expected even without a completed building, with 3 remaining in locked staging; no automatic staging pickup/unlock exists in this gate. Repository: `BlueprintConstructionMaterialEscrow.commit_built` consumes bill only after `ConstructionJob.State.COMPLETE` and actual building activation; `recover_to` refunds an interrupted escrow to its pinned staging source; accepted Stage B cancellation checks preserve original locked buffers. UI currently does not make retained staging contents or actual "completed vs cancelled" history obvious.

**Next user verification:** Ask whether they pressed X after drone unloading or saw the new Storage become fully operational; inspect the actual built site or any first Output errors before accepting Stage C checks. Do **not** treat screenshot alone as a loss or completed pass. Use separate fresh F6 sessions: complete a single covered Storage (15→12 expected); separately cancel a Press **while Cargo 5/5** (15 restored after physical return). Stage C **10/10 still pending**, unique automated **58/810 remains accepted**, Stage B remains fully accepted. Do not change gameplay or release protected staging for this observation.

**Stage C manual blocker observed: delivered drone waiting for power/worker at apparently distant site; verify full-footprint Hub coverage using the labeled plots before accepting further checks. No gameplay changes.**

### 2026-11-20 — E3d5c6b Stage C manual placement blocker (power coverage, not accepted)

Developer screenshot from live `res://scenes/core/playable_direct_build_authorization_e3d5c6b.tscn` shows two Normal queued sites, drone **AT SITE / CARGO 0**, assigned job 0% **Waiting: power, workers**, Starter Storage **12** (down three from 15), generator ON **Hub output 12 / Spare 12**, worker 0/1, battery 28.4/40. This shows physical delivery happened but the worker was not admitted. The right-hand **CONSTRUCTION REQUIREMENTS** read-only panel says stock/power/worker **UNKNOWN (service not connected)** by design; do not interpret that detached panel as an authoritative service error. Screenshot does not establish exact site world coordinates, so do **not** claim a confirmed root cause.

Source inspection: the completed Hub is at **(2,0,-3)** with a **4.5 world-unit coverage radius** (`prototype_main_hub.tscn`); `ConstructionPowerCoverageNetwork.covers_site` and `PrototypeConstructionPowerAllocator._find_covering_node` require **all rotated footprint corners** to be covered, not just a powered generator or site center. The screenshot's drone is visibly at a far-left site instead of either labeled near-Hub plot; **most likely a valid Direct placement was authorized outside full coverage**. Delivery is currently allowed to such queued sites, but power allocation remains zero and the drone may wait there; **do not** loosen the gate, mint resources, or bypass power to make the manual check pass. The approved near-Hub test positions are Test Storage at **(0,0,-3)** and Prototype Ammunition Press at **(4.5,0,-3.5)**, each full footprint within 4.5 of the Hub (with unrotated orientation). The generator ON button reads **Turn generator OFF (test)**.

**Next diagnostic/retest:** Stop F6; restart a fresh scene (15 ingots). Press B then 3, click precisely on the labeled **STORAGE SITE** marker near Hub; 8 and labeled **AMMO PRESS SITE** for second placement. Allow physical delivery and actual escrow admission; confirm `CONSTRUCTION` action, allocated worker 1/1 and nonzero progress before testing generator toggle. Do not count Stage C A5/A6 or 10/10 yet. If waiting persists even at the labeled plot, capture both the scene and Godot Output/Debugger (including the site's exact coordinates/selection) to distinguish coverage from coordinator/admission failure. Record this as evidence, not acceptance. Unique automated baseline remains **58/810**, Stage B fully accepted, Stage C manual pending.

**E3d5c6b Stage B FULLY ACCEPTED (isolated 14/14 plus compatibility 29/29, 395/395); Stage C manual F6 pending 10/10.** Current unique automated baseline **58 suites / 810 checks**. Stage C guide: [DIRECT_BUILD_STAGE_C_MANUAL.md](DIRECT_BUILD_STAGE_C_MANUAL.md). Main/ordinary scenes unchanged. Verify main HEAD before editing.

### 2026-11-20 — E3d5c6b Stage B FULLY ACCEPTED; Stage C manual verification staged (10 pending)

Developer explicitly confirmed **29/29 targeted Stage B compatibility suites and 395/395 checks passed in local Godot** and provided per-suite counts, each matching `tools/building_expansion_final_regression.csv` and the committed Stage B gate (29 unique names, 395 total). These are reruns of accepted expansion suites, not additive. Combined with developer-confirmed **14/14 isolated Stage B physical Direct Build checks**, full Stage B acceptance gate evidence is **30 suite executions / 409 checks** (14 isolated new + 395 overlap reruns), without inventing a fresh full combined regression. Stage A previously fully accepted (11/11 isolated + 28/28, 374/374 compatibility reruns). **Unique milestone baseline remains 58 suites / 810 checks**: 56/785 original expansion, 11 new Stage A, 14 new Stage B. Prior manual expansion 9/9 remains separately accepted. All confirmations are developer-reported local Godot results, not assistant runtime executions.

**Stage C next — manual playable verification:** see [DIRECT_BUILD_STAGE_C_MANUAL.md](DIRECT_BUILD_STAGE_C_MANUAL.md). Run only `res://scenes/core/playable_direct_build_authorization_e3d5c6b.tscn` with **F6**, three independent fresh-play sessions, **10 proposed manual checks A1–A6, B1–B3, C1**. Session A covers Direct Build mode click auto-N Storage/Press, unsupported/duplicate refusal, physical drone transport, generator power pause/resume, actual operational buildings, 15→7 material conservation and recharge. Session B covers Blueprint P planning, Q+drag H priority with no auto-authorization, E selected/single and Ctrl+E batch, mixed priority shared queue, physical completion and 15→4 conservation. Session C verifies a physical loaded cancellation by hovering site and pressing X after collecting five ingots, return storage restores 15 and no Press activates. Manual checks **not run or accepted yet**; no automatic/manual counts added. These sessions use the existing opt-in scene without changing gameplay scripts or prior scenes. **After developer-confirmed Stage C 10/10**, stage fresh final combined regression **58 unique suites / 810 checks** with actual F6 evidence; not yet run. Keep separately gated features untouched: automatic conveyor routing/builds, splitter/merger, poles, multi-trip/fleet, persistence and destruction expansion. No milestone closeout yet.

**E3d5c6b Stage B isolated ACCEPTED (14/14); Stage B compatibility pending 29 suites / 395 checks.** Unique automated milestone baseline: **58 suites / 810 checks**; Stage A fully accepted 11/11 isolated + 28/28 compatibility suites (374/374 rerun checks). Manual expansion 9/9 separate. Main/ordinary opt-out unchanged. See [DIRECT_BUILD_AUTHORIZATION.md](DIRECT_BUILD_AUTHORIZATION.md). Verify main HEAD before any work.

### 2026-11-20 — E3d5c6b Stage B isolated physical lifecycle ACCEPTED (14/14); targeted compatibility pending

Developer explicitly reports **14/14 Stage B isolated checks A–N passed in local Godot 4.6.2**, after the test-only fourth-Press position correction at [11f2595](https://github.com/ChrisGiggleman/industrial-warfare/commit/11f2595c5be139faedc6208ddb443e359843bd40). The prior screenshot established a placement assertion at former WAIT_POS, not a gameplay failure; the new successful F6 result supersedes that pending state. The test uses the real Direct placement click handler and accepted lifecycle services: Direct Press and Storage Normal FIFO; High explicitly authorized Blueprint inserted without preemption; physical five-/three-ingot pickup/delivery, exact per-site custody/escrow, finite power and battery, one worker/one authoritative clock, real 18-second Press and 10-second Storage completions and operational building activation; same drone return/recharge; 15 -> 4 ingot conservation and unaffordable waiting Press. Fresh separate fixture checks cancellation before pickup, loaded with temporarily unavailable return dock, after delivery, and during work: exact reservation release, physical return, protected original staging, escrow refund and four rearms; zero canceled completed buildings and no fabricated stock. This is developer aggregate confirmation, **not assistant-executed Godot testing**, and no new screenshot/output logs were provided for this successful run.

**Accepted unique automated baseline now 58 suites / 810 checks**: E3d5c6a accepted 56/785 + Direct Build Stage A isolated 11 + Stage B isolated 14. Stage A compatibility 28/374 remains separately accepted (reruns, 125 historical supplemental checks outside the 56-suite baseline). Prior manual expansion 9/9 accepted separately. No fresh combined 58-suite regression claimed. Stage B is **isolated accepted**, not fully closed.

**Next Stage B targeted compatibility gate: 29/29 suites, 395/395 checks pending local F6**, selected exclusively from the accepted 56-suite expansion manifest; see [DIRECT_BUILD_AUTHORIZATION.md](DIRECT_BUILD_AUTHORIZATION.md), section “Stage B targeted compatibility gate”. Covers material flow, production, owned staging/escrow, dispatch, charging, cancellation, worker/finite power and prior playable scenes. Reruns **do not add** to 810 cumulative unique checks. Do not claim 395 passed until developer reports. After confirmation, record full Stage B acceptance, then stage Stage C real physical mouse/keyboard manual verification and final targeted combined regression. No gameplay, ordinary/Main scenes, other tests, existing regression runner or manifest changed in this documentation-only acceptance commit. Automatic conveyor, splitter/merger, new pole construction, multi-item/trip, multi-drone, persistence, destruction expansion and locked-staging unlock remain separately gated.

### 2026-11-20 — E3d5c6b Stage B local F6 failed at WAIT_POS; test-only fixture correction staged

Developer supplied a Godot 4.6.2 screenshot from F6 `res://tests/playable_direct_build_authorization_e3d5c6b_stage_b_test.tscn`: debugger shows `Assertion failed: Placement failed at (2.5, 0, -0.5)` in `_place`, at the fourth insufficient-stock Direct Ammunition Press placement, with subsequent error cascade. This is **not** Stage B acceptance or evidence of previous PASS groups (Output banners not supplied). No other cause verified by screenshot. Inspection of source: completed Normal Direct Storage at (4, 0, -1), footprint 1x3, and attempted Press at (2.5, 0, -0.5), footprint 2x2, touch at x=3.5. The Direct Build path refreshes a full-size physics collision preview before the inset blueprint footprint preflight; exact edge contact can legitimately refuse placement. Diagnostic inference: fixture position likely conflicts with physical placement validation, not a reason to weaken normal collision handling or claim a drone-lifecycle failure.

**Narrow test-only fix:** Move `WAIT_POS` to `(-5, 0, 0)`, an open position previously used for Storage by accepted expansion Stage C; it is away from the three completed buildings. Assert actual Hub coverage to keep insufficient materials as the relevant wait condition. Make `_place` report a clear error and return null if no site was created, and safely stop the fixture at the eight call sites rather than cascading through null references. The test still invokes `WorldInteraction._try_place_object` with a fresh camera ray, uses canonical bills, exact queue/services, no inventory injection, no material bypass, original finite power/worker, same scene and lifecycle. No gameplay, other tests, scene, manifest or accepted code changes. Correction commit [ce429537](https://github.com/ChrisGiggleman/industrial-warfare/commit/ce429537992a2ae5064d5ae94ef4c25b7dfe918b).

**Local rerun pending:** Pull updated main and F6 the same Stage B test scene, expected 14 groups A–N and `ALL 14 PLAYABLE DIRECT BUILD AUTHORIZATION E3D5C6B STAGE B TESTS PASSED`. No Godot runtime/parse execution by assistant; if failures recur capture first actual error and Output PASS lines, stop and fix before compatibility. Stage A remains fully accepted (11 isolated + 374 targeted compatibility reruns, 29 suites/385 gate evidence); unique milestone baseline remains 57 suites/796 checks. Stage B adds no accepted checks yet. No Stage B compatibility/manual/final regression claims.

**E3d5c6b Stage A FULLY ACCEPTED (385/385 gate checks); Stage B local F6 failed at fourth placement, test-only correction staged, 14 isolated checks pending rerun.** Read [DIRECT_BUILD_AUTHORIZATION.md](DIRECT_BUILD_AUTHORIZATION.md). Cumulative unique milestone baseline 57/796; prior manual 9/9 separate. Verify current main before changes.

### 2026-11-18 — E3d5c6b Stage A fully accepted (385/385); Stage B physical Direct Build lifecycle staged

Developer explicitly confirmed all **28/28 targeted compatibility suites and 374/374 checks** passed locally in Godot, naming every suite and count. Exact ordered match against the committed Stage A compatibility tables at [c93f2f81](https://github.com/ChrisGiggleman/industrial-warfare/commit/c93f2f81249a4fde8babad97d23c7c273a2c2873); 28 unique entries, no missing/extra/mismatched counts. Includes 10 historical supplemental suites / 125 checks and 18 existing expansion baseline suites / 249 checks. Together with previously accepted 11/11 isolated checks, Stage A full gate evidence is **29 suites / 385 checks**. Cumulative unique milestone baseline remains **57 suites / 796 checks** (56/785 + new isolated 11); historical supplemental checks are separate, reruns not additive; manual expansion 9/9 separate. No fresh full combined regression, runtime execution by assistant, or screenshot review claimed.

Stage B adds a new isolated test only, using the existing exact-scope Direct Build scene and the Stage A accepted camera/ground-ray click entry point. No gameplay, node scene, existing test, runner or manifest changes. Explicit test tick calls replace the adapter frame callback; no duplicate driver, fabricated readiness, transfer shortcut, or direct job authorization. First fresh instance: 15 counted ingots, Direct Press and Direct Storage queued Normal FIFO, High Blueprint remains planned until batch authorization during active Press work; one physical drone picks up 5, then 3, then 3; original source/hover delivery, escrow, finite power pause/resume, exclusive worker and bounded clock, exact canonical 18/10-second completion, real Press with empty production inventories/ports and real Storage, same drone returns and metered recharge, High Blueprint before waiting Normal Storage without preemption. Direct Press at WAIT_POS remains queued with four ingots, no partial loads or work. Second fresh instance: original 15 counted stock, four Direct Press cancellations before pickup, while loaded with return dock disabled/re-enabled, after delivery, and during work. No in-scenario restock or claim unlock; first two leave 15 stock, last two leave 5 each in distinct protected original buffers and 5 in starter Storage; four rearms, no completed cancelled building. New fixture is not physical mouse/manual input and does not prove new production conveyor construction.

**Pending F6:** `res://tests/playable_direct_build_authorization_e3d5c6b_stage_b_test.tscn` — expected **14/14 A–N**. Test implementation [3c4a8b6](https://github.com/ChrisGiggleman/industrial-warfare/commit/3c4a8b66938243b69400f31bf9c2fe16fa16123c). Expected banner: `ALL 14 PLAYABLE DIRECT BUILD AUTHORIZATION E3D5C6B STAGE B TESTS PASSED`. No assistant runtime or parse execution; local Godot verification pending. After isolated pass, record acceptance and stage targeted compatibility gate for physical lifecycle, then Stage C manual workflow and final regression (preserve 56/785 and unique added milestone tests; supplemental historical suite evidence separate unless deliberately included in expanded manifest). No Main or ordinary-scene activation, automatic conveyor construction, splitter/merger construction, new pole, multi-item/trip, multiple drones, persistence, expanded destruction or staged-material unlocking.


### 2026-11-18 — E3d5c6b Stage A isolated accepted (11/11); targeted compatibility pending

Developer explicitly confirmed all 11/11 isolated Direct Build Authorization groups A–K passed locally in Godot against the staged checkpoint [673f249](https://github.com/ChrisGiggleman/industrial-warfare/commit/673f24952834cdeb676690b6ac2bed41b993b1ff). Aggregate developer confirmation, not independent assistant execution or screenshot review. Accepted: exact scene gating/default-off, original queue and canonical Storage/Press, actual refreshed placement path including unsupported/off-ground/blocked/duplicate rejection, Normal FIFO, distinct empty owned staging and original bill/time, explicit selected and batch Blueprint authorization, cancellation on forced synchronous enrollment failure, disabled admission and exact reservation without stock/time bypass. The prior final combined 56 suites / 785 checks remain accepted; cumulative unique milestone baseline is **57 suites / 796 checks** (not a fresh combined rerun). Manual expansion 9/9 remains separate.

Next gate: F6 the **28 targeted compatibility suites / 374 checks** listed in [DIRECT_BUILD_AUTHORIZATION.md](DIRECT_BUILD_AUTHORIZATION.md). They include 10 historical placement/authorization suites (125 checks, outside the 56-suite baseline) and 18 baseline overlap suites (249 checks). These are reruns, not new milestone tests; do not add 374 to the 796 unique milestone checks. No compatibility execution or result claimed yet. No gameplay, tests, accepted scene, or existing regression manifest changed. After developer confirms compatibility, record Stage A full acceptance and proceed to Stage B real physical Direct Build lifecycle; retain full 56-suite baseline for final combined regression. Stage C manual gameplay remains pending. Main/ordinary scenes and separately gated systems remain unchanged.


### 2026-11-18 — E3d5c6b Direct Build Authorization Stage A staged; local F6 pending

Preserved accepted starting checkpoint [217ef366](https://github.com/ChrisGiggleman/industrial-warfare/commit/217ef366cc65b57ab00e0dc36d558231f1790b7c): **56/56 targeted suites / 785/785 checks**, expansion manual 9/9 separate. Stage A adds one exact-scope scene `res://scenes/core/playable_direct_build_authorization_e3d5c6b.tscn` with default-off adapter switch. WorldInteraction intercepts clicks before legacy placement even when the new adapter fails or is disabled; supported canonical Storage and Press only. Unsupported Blueprint placement also refused in this new scene, route tools/connected plan registration disabled here only; no changes to Main, prior scene files, accepted tests or regression manifest. A click refreshes the existing ground/ghost validation, rejects stale/blocked/port-linked placement, then creates an ordinary reserved-footprint site and invokes the original authorization handler (Normal job). The Blueprint click remains PLANNED; Q/L/N/H does not authorize; E and Ctrl+E use the same handler. The exact original queue and adapter services are reused; successful synchronous enrollment owns staging and transfers site timer to the existing lifecycle. A failed synchronous enrollment cancels the original job, preserving any quarantined claims; no legacy fallback, debug readiness, new driver or inventory transfer. The unsupported/unavailable ghost is red in the new scope. No changes to canonical bills (3/5 ingots, 10/18 seconds).
 
**Pending isolated F6:** `res://tests/playable_direct_build_authorization_e3d5c6b_test.tscn` — expected **11/11 A–K**. Actual WorldInteraction placement handler with narrow orthographic camera fixture aimed at known grid coordinates (not OS cursor injection); verified service composition and original queue; default-off and accepted-scene opt-out even if new switch is set; disabled exact scene cannot fall back; immutable canonical allowlist; unsupported, off-ground stale and occupied clicks refuse; direct Storage Normal once and duplicate rejection; Press Normal FIFO, exact bills and distinct empty staging; explicit selected and batch Blueprint authorization; forced enrollment listener failure cancels original job and prunes queue; post-start disabled admission blocks; shared dispatcher reserves exactly 3 ingots without pickup, escrow or time advancement. Expected banner: `ALL 11 PLAYABLE DIRECT BUILD AUTHORIZATION E3D5C6B STAGE A TESTS PASSED`. Implementation/fixture staged at [f6f2bc9](https://github.com/ChrisGiggleman/industrial-warfare/commit/f6f2bc9ca14e4eab1d5f5298db507b941b6566dc). No independent Godot execution or parse verification; camera/physics behavior is pending local F6. Report red errors and all PASS groups; acceptance stays pending until developer confirms. After isolated acceptance, document targeted compatibility gate before Stage B (full physical Direct lifecycle); Stage C manual and final combined 56 baseline + unique added suites. No added counts yet. No automatic belts/corners, splitter/merger, new pole integration, multi-load/fleet, persistence, destruction expansion or staged lock release.

## Prior fully accepted checkpoint

**E3d5c6a automatic construction building expansion FULLY ACCEPTED.** Developer reported fresh final 56/56 automated suites and 785/785 checks, manual expansion 9/9 previously accepted at fdb059b. See [BUILDING_EXPANSION_FINAL_REGRESSION.md](BUILDING_EXPANSION_FINAL_REGRESSION.md). Next proposed milestone: E3d5c6b Direct Build Authorization; read [DIRECT_BUILD_AUTHORIZATION.md](DIRECT_BUILD_AUTHORIZATION.md). No gameplay code changes since accepted expansion implementation. Build mode remains legacy; no Main/ordinary activation.

**Latest authoritative closeout — 2026-11-18:**

### 2026-11-18 — E3d5c6a automatic construction building expansion FULLY ACCEPTED

Developer explicitly confirmed the final combined local Godot regression: **56/56 suites, 785/785 checks passed**, after manual expansion 9/9 previously accepted at [fdb059b](https://github.com/ChrisGiggleman/industrial-warfare/commit/fdb059b83cf0bced24b02cc86541813425eb2040). The committed `tools/building_expansion_final_regression.csv` was independently checked for 56 unique entries totaling 785; developer supplied aggregate pass confirmation, not individual output logs in this turn. No independent assistant runtime execution or runner-use claim. The fresh accepted targeted combined regression supersedes the prior cumulative-only baseline. Historical 53 suites/754 checks plus expansion A/B/C 8/12/11 = 56/785; do not add targeted reruns or manual checks to automated totals. Manual expansion 9/9 and original Storage manual 9/9 are separately accepted. Not a full-project regression.

Accepted experimental capability: canonical Test Storage (3 ingots / 10 seconds) and Prototype Ammunition Press (5 ingots / 18 seconds), exact per-site staging, one shared priority/FIFO queue, explicit E/Ctrl+E authorization, physical pickup/delivery and exact escrow, exclusive worker, finite power/energy/recharge, actual completed building and operational manufacturing, mixed queues, nonpreemption, insufficient-stock skip, physical loaded cancellation recovery and locked staged/escrow refunds. One separately counted conveyor-fed production ingredient yielded four ammunition; no claim of full upstream route. Main and ordinary scenes unchanged; existing Build mode still legacy. No gameplay, test or runner code changes in closeout. Keep manifest as accepted baseline.

Next proposed milestone **E3d5c6b — Direct Build Authorization**, staged separately; no implementation yet. Read [DIRECT_BUILD_AUTHORIZATION.md](DIRECT_BUILD_AUTHORIZATION.md) before modifying code. New chat should verify main HEAD and actual source before deciding implementation. Direct click authorizes Normal-priority construction through existing lifecycle; Blueprint mode retains E/Ctrl+E. No silent legacy fallback for unsupported definitions in new opt-in scope. Automatic belts/corners, splitter/merger, pole, multi-item/trip, fleet, persistence, destruction expansion, specialized Ammo Silos and staged-material unlocking remain separately gated.


## Historical closeouts

### 2026-11-18 — Playable automatic construction drone sandbox FULLY ACCEPTED

Developer explicitly reported all 52/52 final compatibility suites and 741/741 checks passed locally in Godot; every supplied suite name and count was compared with `tools/playable_drone_final_regression.csv` at [fee58a9](https://github.com/ChrisGiggleman/industrial-warfare/commit/fee58a9b7b9baf7d55b099bf54585234af7906a7), exact ordered match, 52 unique entries, no missing/extra/mismatched counts. Combined with previously developer-confirmed Stage C isolated 13/13 at [78c8d87](https://github.com/ChrisGiggleman/industrial-warfare/commit/78c8d872b04eb525d66416a84ef0b4ad7951f71b), **53/53 targeted automated suites and 754/754 checks accepted**. Stage C manual gameplay 9/9 accepted separately. This is targeted milestone acceptance, not a full-project regression. See `docs/PLAYABLE_DRONE_FINAL_REGRESSION.md` for all 52 accepted results. No independent assistant execution, no claim that the optional PowerShell runner was used or validated. No screenshot-based visual assessment or optional extra manual cancellation run claimed.

Accepted playable scene: `res://scenes/core/playable_automatic_construction_drone_stage_c.tscn`. One Hub with finite power, one drone with finite battery, one completed docked Starter Storage, real player authorization and priority queue, exact owned staging/escrow, one active assignment and single bounded construction/movement/charging driver. Manual checks establish planning, priority and explicit authorization, physical collection/delivery, actual power pause/resume, building completion, return/recharge and automatic next assignment; automated checks cover non-preemption, equal-priority FIFO, cancellation before pickup/loaded/after delivery/during work, detachment versus freed original, protected canceled-site staging and exact conservation. Main/ordinary sandbox/legacy scenes remain opted out; only Test Storage with its 3-ingot whole-load bill is enrolled. Accepted fixture choices are not production balance. No gameplay, test, or runner code changed in this acceptance commit.

**Recommended next gated milestone (design first, not implemented or authorized by this closeout):** expand automatic construction eligibility beyond Test Storage. Inspect actual BuildingDefinition bills, completed scene/runtime initialization, existing dispatch candidate/receiver/escrow/worker constraints, power coverage, and planned conveyor activation before choosing the first additional building. Prefer explicit opt-in tests for a supported whole single-item bill first where available; if all candidates require multi-item/multi-trip, design an exact staged-delivery and ownership contract before making any change. Preserve the full 754-check accepted baseline and 9 manual checks, original Q+drag, L/N/H FIFO and explicit E/Ctrl+E, no auto-authorization/preemption, real transport, exact reservations, finite power/charge, and conservative recovery on uncertainty. Never change actual resource bills to make tests pass. Keep wider power coverage, canceled staged-resource recovery, multi-drone concurrency and per-assignment cleanup, general gameplay activation, destruction/save/load integration and specialized Ammo Silos separate until explicitly planned and gated. Start a new development chat with the current main HEAD and these documents as source of truth. No next-milestone implementation in this closeout.

## Historical accepted checkpoints

- E3d5c5x2 playable drone lifecycle accepted (33/33 targeted checks plus manual power resume, completion, cancellation and Hub return).
- E3d5c5x3 Storage supplier discovery accepted (12/12).
- E3d5c5x4a source reservations fully accepted (12/12 isolated and 207/207 across 16 targeted compatibility suites; 219/219). Acceptance commit [2987d49](https://github.com/ChrisGiggleman/industrial-warfare/commit/2987d497bfdd5bca2050ea35bd47f580b1b73245).
- E3d5c5x4b return capacity reservations isolated accepted (14/14 A–N, developer explicitly confirmed all 14 passed in Godot). Implementation [d6d1ed9](https://github.com/ChrisGiggleman/industrial-warfare/commit/d6d1ed9d74af73aaffa175ec9748e77671325d10); staging documentation [1fec87a](https://github.com/ChrisGiggleman/industrial-warfare/commit/1fec87aa4b72a37603215314b1f19ed2cd65d81e).
- **E3d5c5x4b fully accepted: 259/259 (14 isolated + 245 across 20 targeted compatibility suites).** Developer confirmed every suite on 2026-11-17. 
- **E3d5c5x5a isolated physical pickup accepted (12/12)**, developer confirmed in Godot 2026-11-17. Tested code [6ed2e2b](https://github.com/ChrisGiggleman/industrial-warfare/commit/6ed2e2bdffa40ea8bcb301bada6a7a8e96190501). Full acceptance 409/409 (12 isolated + 397 across 28 compatibility suites), developer-confirmed.
- **E3d5c5x5b isolated physical delivery accepted (13/13)**, developer confirmed all checks in Godot 2026-11-17. Implementation [5e2fbbc](https://github.com/ChrisGiggleman/industrial-warfare/commit/5e2fbbc122f2f72329d7f811504cecf0698b7616). Full targeted acceptance 516/516 (13 isolated + 503 across 35 compatibility suites), developer-confirmed.
- **E3d5c5x5c isolated accepted (16/16)**, developer screenshot 2026-11-17, implementation [6652bd0](https://github.com/ChrisGiggleman/industrial-warfare/commit/6652bd0db58594a8efd0c7d862c533abdbe782fb). **Fully accepted 565/565 (16 isolated + 549 across 38 compatibility suites)**, developer-confirmed 2026-11-17.
- **E3d5c5x6 isolated canceled cargo recovery accepted (13/13)**, developer Godot Output screenshot; **Fully accepted 578/578 (13 isolated + 565 across 39 compatibility suites)**.
- **E3d5c5x7a finite Hub charging isolated accepted (13/13)**, developer Godot Output screenshot; **Fully accepted 641/641 (13 isolated + 628 across 43 compatibility suites)**.
- **E3d5c5x7b guarded cargo-worker rearm isolated accepted (16/16)**, developer explicitly confirmed in local Godot; **Fully accepted 657/657 (16 isolated + 641 across 44 compatibility suites)**.
- **E3d5c5x7c1 pre-pickup cancellation isolated accepted (12/12)**, developer-confirmed local Godot; **Fully accepted 669/669 (12 isolated + 657 across 45 compatibility suites)**.
- **E3d5c5x7c2 post-delivery cancellation isolated accepted (13/13)**, developer-confirmed local Godot; **Fully accepted 682/682 (13 isolated + 669 across 46 compatibility suites)**.
- **E3d5c5x7c3 lost original-site recovery isolated accepted (14/14)**, developer-confirmed local Godot; **Fully accepted 696/696 (14 isolated + 682 across 47 compatibility suites)**.
- **E3d5c5x8 automatic priority dispatch and lifecycle fully accepted: 725/725 (15 isolated + 710 across 49 compatibility suites).** Developer confirmed all results on 2026-11-18; all names/counts match the pending gate.
- No independent runtime execution by assistant; accepted evidence is developer's local Godot report. Normal gameplay remains unchanged.

## Completed milestone — E3d5c5x8 playable automatic construction drone sandbox (separate gate)

**Stages A/B accepted 8/8 each (A rerun also 8/8); Stage C automated accepted 13/13 and manual accepted 9/9. Final compatibility accepted 52/52 suites and 741/741 checks; combined **754/754**.** This milestone is closed; see the new checkpoint above for the recommended follow-on. Inspect current main HEAD, the actual existing playable construction controllers/bridges and scenes, and the accepted dispatcher and lifecycle source before choosing interfaces. Prefer a separately named, explicit opt-in playable sandbox scene/adapter over modifying Main or existing accepted ordinary scenes.

Proposed sequencing (subject to actual source inspection):
- Stage A: establish one authoritative same-scope Hub, one finite-charged drone, real completed Storage supplier/dock, discovery and exact supplier/return ledgers, staging registry, escrow, power, queue, scheduler and coordinator. Pin exact service identity; verify startup and default-off/ordinary-scene opt-out. No duplicate legacy drone controller, construction driver or charging loop.
- Stage B: connect existing player blueprint placement, Q+drag selection, High/Normal/Low priority and E/Ctrl+E authorization to the real tracked sites and owned staging. Do not silently authorize or fabricate stock/power/worker readiness. Use the accepted single-item whole-load bill initially (Storage is a suitable fixture if source confirms). Explicitly transfer timer ownership only for eligible experimental sites; preserve existing timer behavior for every other site. One lifecycle tick driver; no double step or leftover delta replay.
- Stage C: automated integration F6 fixture plus manually playable demonstration: multiple planned blueprints, visible drone pickup/delivery and return, High/FIFO order, no preemption, power pause/resume, finite charging/reuse, exact stock conservation, cancellation before pickup/with cargo/after delivery/during work and lost-site protection where supported. Show observable blocked/working/recharging status using existing UI where feasible. Preserve conveyor logistics, placement/snapping, combat and normal scene opt-out. Record actual developer results before compatibility acceptance; rerun the 725-check baseline plus new affected checks as appropriate.
- Keep one drone/one outstanding assignment, full finite charge and whole-scope cleanup gates. Unresolved escrow, unsafe receiver or source failures can quarantine; no silent rescue, unlock, teleport or inventory creation. Multi-drone/multi-trip, general gameplay activation, destruction/persistence and specialized Ammo Silos remain separate future milestones. No code changes during this documentation handoff.

### 2026-11-18 — Playable automatic construction drone sandbox Stage A (staged; local F6 pending)

Stage A composes the accepted x8 services in a new explicit scene `res://scenes/core/playable_automatic_construction_drone_sandbox.tscn`, inheriting the existing factory sandbox; default-off adapter refuses other scene paths. No existing scenes or accepted component scripts modified. The adapter adopts the *exact existing WorldInteraction priority queue* by reparenting it to the sandbox scope without replacing the player's reference; no second queue. One real completed Hub at (2,0,-3), 12-unit prototype nameplate, one real initialized Storage at (-2,0,-3) with 15 counted starter ingots / capacity 20, explicit pickup/return dock, one drone at Hub + 2m with 40 initial energy, 1 energy/m, 4 units/s finite charge and 5-item whole-load capacity. Exact discovery/reservation, site registry, escrow, finite allocator, scheduler (one slot), owned coordinator, Hub charging and x8 lifecycle services; legacy bridge remains disabled, no old fleet or driver, no second charge/timer loop. One frame callback delegates at most once to accepted dispatch.tick with delta capped at 0.1 seconds; invalid delta, disabled gate or foreign direct scope authority block. Instance-only debug readiness disabled, original placement/planning/snap/priority/authorization flags otherwise preserved. Stage A intentionally does NOT enroll any sites, attach staging, transfer timer ownership or enable real construction yet. Existing authorized but untracked sites wait; no transfer/claim/auto-authorization. Scene-only prototype fixture choices, not production balancing; no relay or additional suppliers yet.

**Pending F6:** `res://tests/playable_automatic_construction_drone_stage_a_test.tscn` — expected 8/8 A–H: ordinary/default-off; separate scene flag off; actual scene startup and exact player queue/owned services; Hub power and finite registered full battery; real Storage stock/return forecast; bounded single lifecycle call and invalid delta; actual player plan/authorization without enrollment or timer takeover; disabled/legacy/duplicate authority fail closed with unchanged custody. Final line `ALL 8 PLAYABLE AUTOMATIC CONSTRUCTION DRONE STAGE A TESTS PASSED`. Developer confirmed all 8 checks locally in Godot after implementation commit 010e8f0. No independent assistant runtime execution. Previous 725/725 remains historical; 733/733 cumulative. Stage B staging and explicit timer handoff now pending F6; Stage C playable behavior and compatibility remain separate. Specialized Ammo Silos stay future combat logistics.

### 2026-11-18 — Playable Stage A accepted (8/8); Stage B staged (F6 pending)

Developer explicitly confirmed all 8 Stage A tests passed locally in Godot. Tested main [010e8f0](https://github.com/ChrisGiggleman/industrial-warfare/commit/010e8f0110df414acfdf92a9d49625504d94fc34). Historical accepted x8 baseline 725/725 plus Stage A 8/8 = cumulative 733/733; not a new regression run. No independent assistant runtime execution.

Stage B adds a separately opted-in scene `res://scenes/core/playable_automatic_construction_drone_stage_b.tscn`. Stage A scene remains enrollment-off. Shared adapter connects only Stage B's existing WorldInteraction blueprint_site_authorized signal after original player queue registration. Supports only exact Test Storage definition and whole 3-ingot bill, 7-unit construction demand, empty unique per-site staging/hover receiver and exact owned coordinator; no fabricated readiness/authorization, remote stage transfer or conveyor intake through drone-only receiver. Original planned port/snapping and ordinary conveyor systems remain unchanged. Ownership is independent of site lifetime; only successfully tracked sites transfer site process clock to accepted x8 frame driver. Unsupported sites retain original timers and missing readiness; failed claimed pairs retained disabled, no retry or unlock. Refresh visual progress separately, never call site._process. No duplicate charging or job driver, Main/ordinary sandbox and legacy scenes unchanged. No new power topology or production balance decisions.

**Pending F6:** `res://tests/playable_automatic_construction_drone_stage_b_test.tscn` — expected 8/8 A–H: plans remain unauthorized; selected priority and authorization/FIFO; batch authorization and unsupported site clock preservation; unique empty buffers with belt/remote staging denial; one exact reservation; metered physical collection/delivery; power and single capped construction step; player cancellation refunds original owned buffer. Final line `ALL 8 PLAYABLE AUTOMATIC CONSTRUCTION DRONE STAGE B TESTS PASSED`. Developer confirmed Stage B 8/8 and Stage A rerun 8/8 locally in Godot against 0b8956b. No independent assistant execution. Stage C automated/manual and full compatibility remain separately pending. Preserve specialized Ammo Silos as future combat logistics.

### 2026-11-18 — Playable Stage B accepted (8/8), Stage A rerun (8/8); Stage C staged (later automated accepted 13/13; manual pending)

Developer explicitly confirmed Stage B 8/8 and Stage A compatibility rerun 8/8 in local Godot against main [0b8956b](https://github.com/ChrisGiggleman/industrial-warfare/commit/0b8956b15749b37fa53fc82f37754110df70579f). Historical cumulative accepted 741/741 (725 + 8 + 8; Stage A rerun not double-counted). No independent assistant compile/runtime or post-B full compatibility run.

Stage C adds `res://scenes/core/playable_automatic_construction_drone_stage_c.tscn`, explicit opt-in for existing Stage B site enrollment plus presentation. Uses same original queue, x8 dispatcher and one bounded frame owner. HUD observes actual phase/action, cargo, battery, physical starter stock/reservations, finite Hub nameplate/spare budget, worker count, priority counts, progress/wait reasons and rearm count. Real Hub generator toggle exercises actual allocation and charging; never sets job readiness. Drone and starter stock labels reflect live values. Non-colliding optional guides for default-rotation Storage at (4,0,-3) and (0,0,-3), both inside existing Hub coverage; no new generator, relay, or stock. No ordinary, legacy or Stage A/B scene changes, no accepted core component change, no new clock. Only Storage supported; out-of-coverage authorized sites can receive cargo but wait for power. Q+drag and E/Ctrl+E remain original code.

**Accepted F6 (developer-confirmed 13/13 at 78c8d87):** `res://tests/playable_automatic_construction_drone_stage_c_test.tscn`; 13/13 A–M: read-only status/unplanned protection; Normal before older Low; late High no preemption and power pause/resume; real building completion/escrow commit; meter return and finite charge outage/rearm; equal High FIFO and second completion; pre-pickup cancel; loaded cancel with denied/approved return dock; detach versus freed-site recovery; post-delivery cancel; during-work escrow refund; seven rearms and 15 ingots conserved (3 source + 6 locked staged + 6 committed); ordinary scene opt-out and A/B feedback-off. Final line `ALL 13 PLAYABLE AUTOMATIC CONSTRUCTION DRONE STAGE C TESTS PASSED`. Automated test drives real WorldInteraction placement/authorization/cancellation handlers and same frame callback; no actual mouse/key injection. Local manual F6: stage C playable scene; place two guided plans, select/assign priorities, authorize, observe actual pickup/dropoff, construction, return/recharge and next job; generator off during work then on; optionally cancel another while loaded or working, verify status/stock. Stage A/B reruns needed (shared adapter). Stage C acceptance requires local automated/manual evidence; then rerun historical 50 suites/725 checks plus Stage A/B (52 suites/741 compatibility checks); plus 13 Stage C isolated = 754 checks across 53 suites, if all pass. Do not claim acceptance pre-results. Ammo Silos, wider coverage, multi-item/multi-trip/fleet and production activation remain later gates.

### 2026-11-18 — Stage C automated playable integration accepted (13/13); manual subsequently accepted (9/9)

Developer explicitly confirmed all 13/13 Stage C automated tests passed in local Godot against implementation [78c8d87](https://github.com/ChrisGiggleman/industrial-warfare/commit/78c8d872b04eb525d66416a84ef0b4ad7951f71b). Cumulative accepted automated checks: 754/754 (historical x8 725/725 + Stage A 8/8 + Stage B 8/8 + Stage C 13/13; prior Stage A rerun not double-counted). This is not a fresh combined compatibility run. No independent assistant runtime execution. Stage C manual and final targeted compatibility gates remain open.

**Next: manual F6 in `res://scenes/core/playable_automatic_construction_drone_stage_c.tscn` (not the test scene).** Fresh fixture: 15 ingots, full 40-unit battery, one Hub, one drone and zero assignments. Place default-rotation Test Storage ghost blueprints on guides A (4,0,-3) and B (0,0,-3). Confirm they stay planned; use Q+drag and L/N/H with B High and A Low, then E/Ctrl+E using actual controls. Observe first eligible High job, physical pickup (15 -> 12 stock; cargo 3), delivery (cargo 0), actual work progress, generator off during active work freezes progress, restore generator and confirm same job resumes; first building completes, drone travels to Hub, charge rises finitely to 40 before next assignment, then Low job completes (9 ingots remain, 2 rearms, zero reservations/cargo/active slots). Verify HUD and world labels match physical behavior and do not obstruct controls. Optional separate fresh run: cancel loaded or active site using existing controls; verify physical return of carried items or protected original staging refund, never duplication. No new implementation changes in this acceptance commit. Record manual evidence before closing Stage C; then run 52 compatibility suites/741 checks (prior 50 x8 suites + Stage A/B), alongside accepted Stage C 13/13 for combined 53 suites/754 checks. No normal-scene activation, wider coverage, persistence, multi-drone/multi-item or Ammo Silo work before playable gate acceptance.

### 2026-11-18 — Stage C manual playable verification accepted (9/9); final compatibility subsequently accepted

Developer explicitly confirmed all nine manual gameplay checks passed in local Godot after Stage C automated 13/13 against implementation [78c8d87](https://github.com/ChrisGiggleman/industrial-warfare/commit/78c8d872b04eb525d66416a84ef0b4ad7951f71b) and documentation checkpoint bbad4d3: initial inspection, blueprint placement, priority selection, automatic dispatch, physical delivery, power interruption/restoration, completed building and finite charging, automatic next assignment. No independent assistant manual or runtime execution; no screenshot-based visual assessment. Optional additional manual cancellation run not claimed. Manual checks are not added to automated counts.

**Final targeted gate:** 52 suites / 741 checks (exact 49 x8c suites / 710 + x8b 15 + Stage A 8 + Stage B 8). All 52 scene paths verified on main and counts checked against the accepted manifest. Subsequent developer report confirmed 52/52 and 741/741; combined with already accepted Stage C 13/13, 53 suites / 754 checks accepted. See `docs/PLAYABLE_DRONE_FINAL_REGRESSION.md` and `tools/playable_drone_final_regression.csv` for the full accepted checklist. Optional PowerShell launcher `tools/run_playable_drone_final_regression.ps1` runs independent Godot headless processes and captures per-scene logs; it is unexecuted by assistant, treats uncertain output/errors as REVIEW and does not replace developer F6 acceptance. No game or test code changed. Keep all live gameplay and future combat/logistics extensions deferred until this targeted gate closes.

## Accepted isolated lifecycle prerequisite — x8b

**E3d5c5x8b isolated accepted (15/15).** Developer explicitly confirmed all 49/49 compatibility suites and 710/710 checks passed in local Godot on 2026-11-18. Every reported suite name and count was compared against the pending checklist and matches exactly. Combined with x8b isolated 15/15, E3d5c5x8 targeted automatic dispatch/lifecycle acceptance is 725/725 (50 suites including isolated). Tested lifecycle implementation eadaf27, test b651f48, scene 477b3fb; compatibility gate documentation 3f2e5aa. No independent assistant runtime execution; targeted acceptance, not a full-project regression or playable integration. Ordinary scenes remain opt-out. Lifecycle implementation [eadaf27](https://github.com/ChrisGiggleman/industrial-warfare/commit/eadaf279282853f3f8034da7efe5f07bc31fd502); test b651f48, scene 477b3fb. Separately default-off `enable_isolated_lifecycle` configured only from clean, fully charged registered home with exact charging authority. Explicit tick only; no _process or scene activation. One bounded action per tick (no leftover delta replay): x8a launch, exact claim pickup flight/collect, pinned receiver delivery/physical unload, coordinator escrow/admission, existing scheduler slot and power reconciliation, single explicit job time advance only for non-processing sites, cancellation/lost-site physical recovery, metered return, finite registered charging, guarded rearm and later new dispatch. Weak original site and retained exact job/definition/buffer/claim identity; no adoption of manual assignment. Reject external automatic site timers before launch and do not advance their job time. Existing conservative whole-scope gates remain; unresolved escrow, failed source or uncertain custody can quarantine rather than fabricate recovery. No automatic authorization, preemption, multi-drone, multi-trip, persistence, normal-scene wiring or combat changes.

F6: `res://tests/drone_automatic_lifecycle_e3d5c5x8b_test.tscn`. Expected 15/15 A–O: separate opt-in/charging identity/delta; High FIFO and external timer exclusion; metered pickup; physical collection/delivery; escrow/admission without power bypass and exact construction time; pause/resume; completion/return; finite charge/rearm; second build; pre-pickup cancellation; temporary detachment then freed loaded-site recovery; post-delivery cancellation; working-job cancellation/refund; 15 ingots conserved (3 source, 6 locked staging, 6 committed across two builds), six rearms, no unauthorized work; normal-scene opt-out. Final line `ALL 15 E3D5C5X8B AUTOMATIC LIFECYCLE TESTS PASSED`. Developer confirmed all 15 checks passed in local Godot; no independent assistant execution. All 49 compatibility suites / 710 checks subsequently accepted; see completed x8c gate below. Playable demo remains separate.

### Accepted x8a prerequisite

**E3d5c5x8a isolated accepted (14/14).** Developer explicitly confirmed 14/14 x8a isolated checks passed in local Godot on 2026-11-18 after indentation correction b1bba4a. No independent execution; compatibility subsequently accepted at x8c. Prior 696/696 historical, not post-x8 regression. Implementation commits 03f475d (read-only coordinator eligibility), 31a8f99 (dispatcher), 1cc112f (pre-launch revalidation); test script eb2963f, scene b9f0178, test refinement 0ebdc85. New `PrototypeDroneAutomaticDispatch` is default-off, explicit inspect/dispatch only, with no _process or ordinary scene wiring. It reads the existing authorized queue (High/Normal/Low, FIFO), checks the exact tracked and pinned owned receiver, supports a whole outstanding single-item deficit only, and uses existing discovery, exact supplier reserve/observe/begin_pickup. No material, power or worker availability is fabricated; missing construction power/escrow before pickup is expected, not a worker-admission bypass. Source or route/energy, receiver availability/capacity, unsupported bill and tracking failures skip candidates with observable reasons. Conservative one-drone/one-slot scope, full finite registered home charge, all recovery/reuse flags, no active workers or outstanding source/return/escrow claims; no automatic cleanup or preemption. Revalidate exact live services, job, definition, buffer, item, amount and supplier claim before launch; release only the newly acquired claim on failure, no second attempt in that call. No flight advancement, material movement, auto-authorization, charging, rearm or construction progression. x8b lifecycle driver and x8c compatibility/playable sandbox remain separate.

F6 scene: `res://tests/drone_automatic_dispatch_e3d5c5x8a_test.tscn`. Expected A–N (14/14): default-off and invalid/foreign/duplicate configure; planned High not authorized; Normal beats Low; unreachable/full/untracked High skipped with ordered reasons; High/FIFO and reprioritization; unavailable dock/retained stock; duplicate dispatcher/multiple drones; existing claim protected; current feature/service denial; receiver invalidation and refused launch roll back; exact claim and guarded launch without movement or source debit; non-preemption and no readiness/timer bypass; cancellation release without auto-rearm; ordinary scene opt-out. Expected final line: `ALL 14 E3D5C5X8A AUTOMATIC DISPATCH TESTS PASSED`. Developer confirmed all 14 checks passed after b1bba4a; no independent runtime execution. Previous 696/696 remains historical. x8b and x8c targeted compatibility subsequently accepted; preserve as historical baseline.

### x8 stages (isolated and targeted compatibility accepted; playable demonstration pending)

- x8a: isolated deterministic selection and guarded claim/launch for one drone / one outstanding assignment. Use existing authoritative player-authorized queue and stable High/Normal/Low order, FIFO within equal priority. Select only eligible candidates; skip with observable reasons when stock, route/energy, receiver/capacity, or applicable readiness prerequisites fail. Do not conflate pre-pickup eligibility with worker admission requiring delivered materials. No automatic authorization, no hidden resource transfers, no preemption of an active job. Revalidate before reservation and launch; failed launch must release only its own claim.
- x8b: isolated explicit dispatcher tick integrating existing pickup, delivery, admission, construction, physical recovery, return, finite charging and guarded rearm. Preserve cancellation/lost-site handling, escrow and ownership. Verify sequential jobs and deterministic ordering; no direct calls that manufacture readiness or advance construction time twice. Keep full-charge, single-Hub and whole-scope cleanup constraints.
- x8c: targeted compatibility and separately gated playable sandbox demonstration; multi-drone concurrency and per-assignment cleanup refinement come later, not part of initial dispatch. Keep Main and ordinary scenes opt-out until separately approved and verified.

Use defaults-off flags, exact live service/claim/job identity and existing conservation gates. Stage new Godot F6 tests and report actual developer-confirmed isolated results before compatibility. Rerun relevant acceptance baseline (including x7c3), plus any new affected suites, with exact counts documented; do not claim independent runtime execution. Preserve player E/Ctrl+E authorization, blueprint priority UI, conveyor placement/production and timers. Multi-trip/multi-item scheduling, recovery of locked canceled staging, researchable docks, silos/depots, real destruction/salvage integration, persistence and live gameplay activation remain distinct future gates. No gameplay edits made in this handoff.

## Completed compatibility gate — x8c

Developer explicitly confirmed all 49/49 compatibility suites and 710/710 checks passed in local Godot on 2026-11-18. Every reported suite name and count was compared against the pending checklist and matches exactly. Combined with x8b isolated 15/15, E3d5c5x8 targeted automatic dispatch/lifecycle acceptance is 725/725 (50 suites including isolated). Tested lifecycle implementation eadaf27, test b651f48, scene 477b3fb; compatibility gate documentation 3f2e5aa. No independent assistant runtime execution; targeted acceptance, not a full-project regression or playable integration. Ordinary scenes remain opt-out.

| Scene under res://tests/ | Expected check groups | Result |
|---|---:|---|
| `inventory_trasnfer_test.tscn` | 4 | Passed |
| `item_port_transfer_test.tscn` | 7 | Passed |
| `manufacturing_transaction_test.tscn` | 9 | Passed |
| `recipe_output_capacity_test.tscn` | 11 | Passed |
| `conveyor_automatic_loading_test.tscn` | 10 | Passed |
| `conveyor_automatic_unloading_test.tscn` | 9 | Passed |
| `conveyor_connected_transport_test.tscn` | 7 | Passed |
| `conveyor_splitter_test.tscn` | 10 | Passed |
| `conveyor_merger_test.tscn` | 10 | Passed |
| `conveyor_physical_only_conservation_test.tscn` | 9 | Passed |
| `timed_storage_conveyor_delivery_test.tscn` | 6 | Passed |
| `blueprint_construction_material_escrow_e3d5c2a_test.tscn` | 16 | Passed |
| `unified_receiver_consolidation_e3d5c5v_test.tscn` | 56 | Passed |
| `playable_construction_logistics_e3d5c5w_test.tscn` | 13 | Passed |
| `playable_construction_power_e3d5c5x1_test.tscn` | 9 | Passed |
| `playable_construction_drone_e3d5c5x2_test.tscn` | 11 | Passed |
| `drone_storage_discovery_e3d5c5x3_test.tscn` | 12 | Passed |
| `drone_supplier_reservations_e3d5c5x4a_test.tscn` | 12 | Passed |
| `world_salvage_destruction_test.tscn` | 12 | Passed |
| `destruction_cargo_recovery_test.tscn` | 12 | Passed |
| `drone_return_reservations_e3d5c5x4b_test.tscn` | 14 | Passed |
| `prototype_construction_worker_drone_e3d5c4u_test.tscn` | 16 | Passed |
| `prototype_drone_worker_readiness_e3d5c4v_test.tscn` | 21 | Passed |
| `prototype_construction_drone_fleet_e3d5c4w_test.tscn` | 21 | Passed |
| `prototype_drone_battery_dock_e3d5c4x_test.tscn` | 20 | Passed |
| `prototype_construction_drone_reuse_e3d5c4y_test.tscn` | 20 | Passed |
| `prototype_construction_drone_tick_e3d5c4z_test.tscn` | 20 | Passed |
| `sandbox_construction_drone_bridge_e3d5c5a_test.tscn` | 20 | Passed |
| `drone_physical_pickup_e3d5c5x5a_test.tscn` | 12 | Passed |
| `blueprint_material_staging_e3d5c4c_test.tscn` | 16 | Passed |
| `blueprint_physical_staging_e3d5c4d_test.tscn` | 16 | Passed |
| `blueprint_site_staging_ownership_e3d5c4h_test.tscn` | 16 | Passed |
| `blueprint_anchored_receiver_e3d5c4i_test.tscn` | 16 | Passed |
| `blueprint_owned_readiness_e3d5c4r_test.tscn` | 18 | Passed |
| `blueprint_receiver_recovery_audit_e3d5c4j_test.tscn` | 12 | Passed |
| `drone_physical_delivery_e3d5c5x5b_test.tscn` | 13 | Passed |
| `construction_readiness_coordinator_e3d5c3c1_test.tscn` | 18 | Passed |
| `blueprint_construction_readiness_e3d5c1_test.tscn` | 15 | Passed |
| `drone_delivered_worker_e3d5c5x5c_test.tscn` | 16 | Passed |
| `drone_cancelled_cargo_recovery_e3d5c5x6_test.tscn` | 13 | Passed |
| `construction_power_coverage_e3d5c3a_test.tscn` | 16 | Passed |
| `completed_power_structures_e3d5c3b1_test.tscn` | 16 | Passed |
| `finite_construction_power_e3d5c3b2_test.tscn` | 18 | Passed |
| `drone_finite_hub_charging_e3d5c5x7a_test.tscn` | 13 | Passed |
| `drone_cargo_worker_reuse_e3d5c5x7b_test.tscn` | 16 | Passed |
| `drone_pre_pickup_cancellation_e3d5c5x7c1_test.tscn` | 12 | Passed |
| `drone_post_delivery_cancellation_e3d5c5x7c2_test.tscn` | 13 | Passed |
| `drone_lost_site_recovery_e3d5c5x7c3_test.tscn` | 14 | Passed |
| `drone_automatic_dispatch_e3d5c5x8a_test.tscn` | 14 | Passed |
| **Total (49 suites)** | **710** | Passed |

## Future combat logistics — specialized Ammo Silos (agreed 2026-11-18)

Keep high-action defense readable: conveyors feed dedicated munitions silos, which automatically resupply compatible turret magazines inside a visible supply radius. Different silos stock different ammunition types for different weapon classes. Finite stock, magazine capacity, refill throughput, compatible ammo and deterministic overlapping coverage; no free ammunition or duplicate transfer. Empty, unpowered or destroyed silos stop resupply; turrets retain remaining magazine rounds. Exact radius, power, transfer mechanism, throughput and research tiers deferred to separate combat-logistics design/test gates after construction drones. No implementation or changes to existing turret/conveyor behavior now.

## Completed compatibility gate — x7c3

**Isolated accepted: 14/14 A–N**, developer explicitly reported all 14 tests passed in local Godot. No screenshot supplied for this checkpoint; no independent execution. Implementation and scene [31e2e7c](https://github.com/ChrisGiggleman/industrial-warfare/commit/31e2e7cf7234e3e5a21519f71b2d54d7c5cd7ec7), code refinement 89696e1, documentation checkpoint 51f8da5. Fixture confirms default-off/late opt-in, forecast-only loss, detachment denial, lost pre-pickup no debit, healthy/detached loaded refusal, protected loaded recovery and return, full finite charge/original ownership gate, unloaded site loss, blocked refund and explicit refund, lost worker readiness revocation and scheduler cleanup, fresh authorized build, conservation and replay denial, normal scene opt-out. Five lost assignments followed by one successful build, six rearms, all 15 ingots accounted for (3 source stock, 9 locked staging, 3 committed).

**Accepted: all 47 compatibility suites / 682 checks**, explicitly developer-confirmed in local Godot on 2026-11-18; 696/696 including 14 isolated checks. Every reported suite name and count matches the documented pending gate. Implementation and scene 31e2e7c, code refinement 89696e1, gate documentation a90cf9c. Targeted, not full-project regression; no independent execution. x7 charging/reuse/cancellation phase accepted. Next x8 in a new development chat.

| Scene under res://tests/ | Expected check groups | Result |
|---|---:|---|
| `inventory_trasnfer_test.tscn` | 4 | Passed |
| `item_port_transfer_test.tscn` | 7 | Passed |
| `manufacturing_transaction_test.tscn` | 9 | Passed |
| `recipe_output_capacity_test.tscn` | 11 | Passed |
| `conveyor_automatic_loading_test.tscn` | 10 | Passed |
| `conveyor_automatic_unloading_test.tscn` | 9 | Passed |
| `conveyor_connected_transport_test.tscn` | 7 | Passed |
| `conveyor_splitter_test.tscn` | 10 | Passed |
| `conveyor_merger_test.tscn` | 10 | Passed |
| `conveyor_physical_only_conservation_test.tscn` | 9 | Passed |
| `timed_storage_conveyor_delivery_test.tscn` | 6 | Passed |
| `blueprint_construction_material_escrow_e3d5c2a_test.tscn` | 16 | Passed |
| `unified_receiver_consolidation_e3d5c5v_test.tscn` | 56 | Passed |
| `playable_construction_logistics_e3d5c5w_test.tscn` | 13 | Passed |
| `playable_construction_power_e3d5c5x1_test.tscn` | 9 | Passed |
| `playable_construction_drone_e3d5c5x2_test.tscn` | 11 | Passed |
| `drone_storage_discovery_e3d5c5x3_test.tscn` | 12 | Passed |
| `drone_supplier_reservations_e3d5c5x4a_test.tscn` | 12 | Passed |
| `world_salvage_destruction_test.tscn` | 12 | Passed |
| `destruction_cargo_recovery_test.tscn` | 12 | Passed |
| `drone_return_reservations_e3d5c5x4b_test.tscn` | 14 | Passed |
| `prototype_construction_worker_drone_e3d5c4u_test.tscn` | 16 | Passed |
| `prototype_drone_worker_readiness_e3d5c4v_test.tscn` | 21 | Passed |
| `prototype_construction_drone_fleet_e3d5c4w_test.tscn` | 21 | Passed |
| `prototype_drone_battery_dock_e3d5c4x_test.tscn` | 20 | Passed |
| `prototype_construction_drone_reuse_e3d5c4y_test.tscn` | 20 | Passed |
| `prototype_construction_drone_tick_e3d5c4z_test.tscn` | 20 | Passed |
| `sandbox_construction_drone_bridge_e3d5c5a_test.tscn` | 20 | Passed |
| `drone_physical_pickup_e3d5c5x5a_test.tscn` | 12 | Passed |
| `blueprint_material_staging_e3d5c4c_test.tscn` | 16 | Passed |
| `blueprint_physical_staging_e3d5c4d_test.tscn` | 16 | Passed |
| `blueprint_site_staging_ownership_e3d5c4h_test.tscn` | 16 | Passed |
| `blueprint_anchored_receiver_e3d5c4i_test.tscn` | 16 | Passed |
| `blueprint_owned_readiness_e3d5c4r_test.tscn` | 18 | Passed |
| `blueprint_receiver_recovery_audit_e3d5c4j_test.tscn` | 12 | Passed |
| `drone_physical_delivery_e3d5c5x5b_test.tscn` | 13 | Passed |
| `construction_readiness_coordinator_e3d5c3c1_test.tscn` | 18 | Passed |
| `blueprint_construction_readiness_e3d5c1_test.tscn` | 15 | Passed |
| `drone_delivered_worker_e3d5c5x5c_test.tscn` | 16 | Passed |
| `drone_cancelled_cargo_recovery_e3d5c5x6_test.tscn` | 13 | Passed |
| `construction_power_coverage_e3d5c3a_test.tscn` | 16 | Passed |
| `completed_power_structures_e3d5c3b1_test.tscn` | 16 | Passed |
| `finite_construction_power_e3d5c3b2_test.tscn` | 18 | Passed |
| `drone_finite_hub_charging_e3d5c5x7a_test.tscn` | 13 | Passed |
| `drone_cargo_worker_reuse_e3d5c5x7b_test.tscn` | 16 | Passed |
| `drone_pre_pickup_cancellation_e3d5c5x7c1_test.tscn` | 12 | Passed |
| `drone_post_delivery_cancellation_e3d5c5x7c2_test.tscn` | 13 | Passed |
| **Total (47 suites)** | **682** | Passed |

## Completed compatibility gate — x7c2

**Isolated accepted: 13/13 A–M**, developer explicitly reported all 13 tests passed in local Godot. No screenshot supplied for this checkpoint; no independent execution. Implementation and scene [c53519e](https://github.com/ChrisGiggleman/industrial-warfare/commit/c53519eb92dfae1493ca23f7b5993f590e51e32f), documentation checkpoint 282deea. Fixture confirms default-off/late opt-in denial, healthy/loaded refusal, terminal no-escrow preserved stock, metered empty return, full charge/ownership/feature gate, escrow alone not worker permission, exact refund, blocked refund protection and reuse denial, explicit recovery and ownership lock, fresh authorized construction after three canceled deliveries, conservation of all fifteen ingots, replay denial and normal-scene opt-out.

**Accepted: all 46 compatibility suites / 669 checks**, explicitly developer-confirmed in local Godot on 2026-11-18; 682/682 including 13 isolated checks. Implementation c53519e, gate documentation d70818a. Targeted, not full-project regression; no independent execution. Next x7c3.

| Scene under res://tests/ | Expected check groups | Result |
|---|---:|---|
| `inventory_trasnfer_test.tscn` | 4 | Passed |
| `item_port_transfer_test.tscn` | 7 | Passed |
| `manufacturing_transaction_test.tscn` | 9 | Passed |
| `recipe_output_capacity_test.tscn` | 11 | Passed |
| `conveyor_automatic_loading_test.tscn` | 10 | Passed |
| `conveyor_automatic_unloading_test.tscn` | 9 | Passed |
| `conveyor_connected_transport_test.tscn` | 7 | Passed |
| `conveyor_splitter_test.tscn` | 10 | Passed |
| `conveyor_merger_test.tscn` | 10 | Passed |
| `conveyor_physical_only_conservation_test.tscn` | 9 | Passed |
| `timed_storage_conveyor_delivery_test.tscn` | 6 | Passed |
| `blueprint_construction_material_escrow_e3d5c2a_test.tscn` | 16 | Passed |
| `unified_receiver_consolidation_e3d5c5v_test.tscn` | 56 | Passed |
| `playable_construction_logistics_e3d5c5w_test.tscn` | 13 | Passed |
| `playable_construction_power_e3d5c5x1_test.tscn` | 9 | Passed |
| `playable_construction_drone_e3d5c5x2_test.tscn` | 11 | Passed |
| `drone_storage_discovery_e3d5c5x3_test.tscn` | 12 | Passed |
| `drone_supplier_reservations_e3d5c5x4a_test.tscn` | 12 | Passed |
| `world_salvage_destruction_test.tscn` | 12 | Passed |
| `destruction_cargo_recovery_test.tscn` | 12 | Passed |
| `drone_return_reservations_e3d5c5x4b_test.tscn` | 14 | Passed |
| `prototype_construction_worker_drone_e3d5c4u_test.tscn` | 16 | Passed |
| `prototype_drone_worker_readiness_e3d5c4v_test.tscn` | 21 | Passed |
| `prototype_construction_drone_fleet_e3d5c4w_test.tscn` | 21 | Passed |
| `prototype_drone_battery_dock_e3d5c4x_test.tscn` | 20 | Passed |
| `prototype_construction_drone_reuse_e3d5c4y_test.tscn` | 20 | Passed |
| `prototype_construction_drone_tick_e3d5c4z_test.tscn` | 20 | Passed |
| `sandbox_construction_drone_bridge_e3d5c5a_test.tscn` | 20 | Passed |
| `drone_physical_pickup_e3d5c5x5a_test.tscn` | 12 | Passed |
| `blueprint_material_staging_e3d5c4c_test.tscn` | 16 | Passed |
| `blueprint_physical_staging_e3d5c4d_test.tscn` | 16 | Passed |
| `blueprint_site_staging_ownership_e3d5c4h_test.tscn` | 16 | Passed |
| `blueprint_anchored_receiver_e3d5c4i_test.tscn` | 16 | Passed |
| `blueprint_owned_readiness_e3d5c4r_test.tscn` | 18 | Passed |
| `blueprint_receiver_recovery_audit_e3d5c4j_test.tscn` | 12 | Passed |
| `drone_physical_delivery_e3d5c5x5b_test.tscn` | 13 | Passed |
| `construction_readiness_coordinator_e3d5c3c1_test.tscn` | 18 | Passed |
| `blueprint_construction_readiness_e3d5c1_test.tscn` | 15 | Passed |
| `drone_delivered_worker_e3d5c5x5c_test.tscn` | 16 | Passed |
| `drone_cancelled_cargo_recovery_e3d5c5x6_test.tscn` | 13 | Passed |
| `construction_power_coverage_e3d5c3a_test.tscn` | 16 | Passed |
| `completed_power_structures_e3d5c3b1_test.tscn` | 16 | Passed |
| `finite_construction_power_e3d5c3b2_test.tscn` | 18 | Passed |
| `drone_finite_hub_charging_e3d5c5x7a_test.tscn` | 13 | Passed |
| `drone_cargo_worker_reuse_e3d5c5x7b_test.tscn` | 16 | Passed |
| `drone_pre_pickup_cancellation_e3d5c5x7c1_test.tscn` | 12 | Passed |
| **Total (46 suites)** | **669** | Passed |

## Completed compatibility gate — x7c1

**Isolated accepted: 12/12 A–L**, developer explicitly reported all 12 tests passed in local Godot. No screenshot supplied for this checkpoint; no independent execution. Implementation and scene [e19cd8a](https://github.com/ChrisGiggleman/industrial-warfare/commit/e19cd8ae4850918d9d289d780611bc848b4e3c36), documentation checkpoint fd3a7f8. Fixture confirms forecast-only reservation cancellation leaves drone idle; launched cancellation at home, in flight and at pickup dock releases stock without debit; metered empty return, finite full recharge and exact-once rearm; no late opt-in or nonterminal claim release bypass; fresh authorized construction after three canceled flights; all fifteen original ingots accounted for; normal scenes opt-out.

**Accepted: all 45 compatibility suites / 657 checks**, explicitly developer-confirmed in local Godot on 2026-11-18; 669/669 including 12 isolated checks. Implementation e19cd8a, gate documentation 9c6248b. Targeted, not full-project regression; no independent execution. Next x7c2.

| Scene under res://tests/ | Expected check groups | Result |
|---|---:|---|
| `inventory_trasnfer_test.tscn` | 4 | Passed |
| `item_port_transfer_test.tscn` | 7 | Passed |
| `manufacturing_transaction_test.tscn` | 9 | Passed |
| `recipe_output_capacity_test.tscn` | 11 | Passed |
| `conveyor_automatic_loading_test.tscn` | 10 | Passed |
| `conveyor_automatic_unloading_test.tscn` | 9 | Passed |
| `conveyor_connected_transport_test.tscn` | 7 | Passed |
| `conveyor_splitter_test.tscn` | 10 | Passed |
| `conveyor_merger_test.tscn` | 10 | Passed |
| `conveyor_physical_only_conservation_test.tscn` | 9 | Passed |
| `timed_storage_conveyor_delivery_test.tscn` | 6 | Passed |
| `blueprint_construction_material_escrow_e3d5c2a_test.tscn` | 16 | Passed |
| `unified_receiver_consolidation_e3d5c5v_test.tscn` | 56 | Passed |
| `playable_construction_logistics_e3d5c5w_test.tscn` | 13 | Passed |
| `playable_construction_power_e3d5c5x1_test.tscn` | 9 | Passed |
| `playable_construction_drone_e3d5c5x2_test.tscn` | 11 | Passed |
| `drone_storage_discovery_e3d5c5x3_test.tscn` | 12 | Passed |
| `drone_supplier_reservations_e3d5c5x4a_test.tscn` | 12 | Passed |
| `world_salvage_destruction_test.tscn` | 12 | Passed |
| `destruction_cargo_recovery_test.tscn` | 12 | Passed |
| `drone_return_reservations_e3d5c5x4b_test.tscn` | 14 | Passed |
| `prototype_construction_worker_drone_e3d5c4u_test.tscn` | 16 | Passed |
| `prototype_drone_worker_readiness_e3d5c4v_test.tscn` | 21 | Passed |
| `prototype_construction_drone_fleet_e3d5c4w_test.tscn` | 21 | Passed |
| `prototype_drone_battery_dock_e3d5c4x_test.tscn` | 20 | Passed |
| `prototype_construction_drone_reuse_e3d5c4y_test.tscn` | 20 | Passed |
| `prototype_construction_drone_tick_e3d5c4z_test.tscn` | 20 | Passed |
| `sandbox_construction_drone_bridge_e3d5c5a_test.tscn` | 20 | Passed |
| `drone_physical_pickup_e3d5c5x5a_test.tscn` | 12 | Passed |
| `blueprint_material_staging_e3d5c4c_test.tscn` | 16 | Passed |
| `blueprint_physical_staging_e3d5c4d_test.tscn` | 16 | Passed |
| `blueprint_site_staging_ownership_e3d5c4h_test.tscn` | 16 | Passed |
| `blueprint_anchored_receiver_e3d5c4i_test.tscn` | 16 | Passed |
| `blueprint_owned_readiness_e3d5c4r_test.tscn` | 18 | Passed |
| `blueprint_receiver_recovery_audit_e3d5c4j_test.tscn` | 12 | Passed |
| `drone_physical_delivery_e3d5c5x5b_test.tscn` | 13 | Passed |
| `construction_readiness_coordinator_e3d5c3c1_test.tscn` | 18 | Passed |
| `blueprint_construction_readiness_e3d5c1_test.tscn` | 15 | Passed |
| `drone_delivered_worker_e3d5c5x5c_test.tscn` | 16 | Passed |
| `drone_cancelled_cargo_recovery_e3d5c5x6_test.tscn` | 13 | Passed |
| `construction_power_coverage_e3d5c3a_test.tscn` | 16 | Passed |
| `completed_power_structures_e3d5c3b1_test.tscn` | 16 | Passed |
| `finite_construction_power_e3d5c3b2_test.tscn` | 18 | Passed |
| `drone_finite_hub_charging_e3d5c5x7a_test.tscn` | 13 | Passed |
| `drone_cargo_worker_reuse_e3d5c5x7b_test.tscn` | 16 | Passed |
| **Total (45 suites)** | **657** | Passed |

## Completed compatibility gate — x7b

**Isolated accepted: 16/16 A–P**, developer explicitly reported all 16 tests passed in local Godot; no screenshot supplied for this checkpoint and no independent execution. Latest staged implementation/test refinement [acdcdf7](https://github.com/ChrisGiggleman/industrial-warfare/commit/acdcdf76861f012ed2231dd8760e23d02f928d6b), documentation checkpoint 779fd41. Same drone completes two authorized builds, recovers a canceled loaded assignment, and refunds a fourth assignment canceled during work; four successful rearms and all 15 original ingots accounted for in the fixture. Checks include terminal job, full finite charge, exact original home (including combined relocation refusal), authoritative ledgers and scheduler, unresolved claim/escrow denial, callback cleanup, fresh authorization and pickup, conservation, feature-loss interlock and normal scene opt-out.

**Accepted: all 44 compatibility suites / 641 checks**, explicitly developer-confirmed in local Godot on 2026-11-18; 657/657 including 16 isolated checks. Implementation refinement acdcdf7, gate documentation ca5dd3f. Targeted, not full-project regression; no independent execution. Next x7c1 pre-pickup cancellation.

| Scene under res://tests/ | Expected check groups | Result |
|---|---:|---|
| `inventory_trasnfer_test.tscn` | 4 | Passed |
| `item_port_transfer_test.tscn` | 7 | Passed |
| `manufacturing_transaction_test.tscn` | 9 | Passed |
| `recipe_output_capacity_test.tscn` | 11 | Passed |
| `conveyor_automatic_loading_test.tscn` | 10 | Passed |
| `conveyor_automatic_unloading_test.tscn` | 9 | Passed |
| `conveyor_connected_transport_test.tscn` | 7 | Passed |
| `conveyor_splitter_test.tscn` | 10 | Passed |
| `conveyor_merger_test.tscn` | 10 | Passed |
| `conveyor_physical_only_conservation_test.tscn` | 9 | Passed |
| `timed_storage_conveyor_delivery_test.tscn` | 6 | Passed |
| `blueprint_construction_material_escrow_e3d5c2a_test.tscn` | 16 | Passed |
| `unified_receiver_consolidation_e3d5c5v_test.tscn` | 56 | Passed |
| `playable_construction_logistics_e3d5c5w_test.tscn` | 13 | Passed |
| `playable_construction_power_e3d5c5x1_test.tscn` | 9 | Passed |
| `playable_construction_drone_e3d5c5x2_test.tscn` | 11 | Passed |
| `drone_storage_discovery_e3d5c5x3_test.tscn` | 12 | Passed |
| `drone_supplier_reservations_e3d5c5x4a_test.tscn` | 12 | Passed |
| `world_salvage_destruction_test.tscn` | 12 | Passed |
| `destruction_cargo_recovery_test.tscn` | 12 | Passed |
| `drone_return_reservations_e3d5c5x4b_test.tscn` | 14 | Passed |
| `prototype_construction_worker_drone_e3d5c4u_test.tscn` | 16 | Passed |
| `prototype_drone_worker_readiness_e3d5c4v_test.tscn` | 21 | Passed |
| `prototype_construction_drone_fleet_e3d5c4w_test.tscn` | 21 | Passed |
| `prototype_drone_battery_dock_e3d5c4x_test.tscn` | 20 | Passed |
| `prototype_construction_drone_reuse_e3d5c4y_test.tscn` | 20 | Passed |
| `prototype_construction_drone_tick_e3d5c4z_test.tscn` | 20 | Passed |
| `sandbox_construction_drone_bridge_e3d5c5a_test.tscn` | 20 | Passed |
| `drone_physical_pickup_e3d5c5x5a_test.tscn` | 12 | Passed |
| `blueprint_material_staging_e3d5c4c_test.tscn` | 16 | Passed |
| `blueprint_physical_staging_e3d5c4d_test.tscn` | 16 | Passed |
| `blueprint_site_staging_ownership_e3d5c4h_test.tscn` | 16 | Passed |
| `blueprint_anchored_receiver_e3d5c4i_test.tscn` | 16 | Passed |
| `blueprint_owned_readiness_e3d5c4r_test.tscn` | 18 | Passed |
| `blueprint_receiver_recovery_audit_e3d5c4j_test.tscn` | 12 | Passed |
| `drone_physical_delivery_e3d5c5x5b_test.tscn` | 13 | Passed |
| `construction_readiness_coordinator_e3d5c3c1_test.tscn` | 18 | Passed |
| `blueprint_construction_readiness_e3d5c1_test.tscn` | 15 | Passed |
| `drone_delivered_worker_e3d5c5x5c_test.tscn` | 16 | Passed |
| `drone_cancelled_cargo_recovery_e3d5c5x6_test.tscn` | 13 | Passed |
| `construction_power_coverage_e3d5c3a_test.tscn` | 16 | Passed |
| `completed_power_structures_e3d5c3b1_test.tscn` | 16 | Passed |
| `finite_construction_power_e3d5c3b2_test.tscn` | 18 | Passed |
| `drone_finite_hub_charging_e3d5c5x7a_test.tscn` | 13 | Passed |
| **Total (44 suites)** | **641** | Passed |

## Completed compatibility gate — x7a

**Isolated accepted: 13/13 A–M**, developer's Godot Output screenshot, 2026-11-17 local date, implementation and test scene [61c3d7e](https://github.com/ChrisGiggleman/industrial-warfare/commit/61c3d7e454e51cceb8c85edec44d1172c9ace665), documentation checkpoint a97db8f. All PASS A–M and final ALL 13 E3D5C5X7A FINITE HUB CHARGING TESTS PASSED visible. Default-off, exclusive authority, exact home, no legacy bypass, invalid delta, construction-first shared budget, rate/headroom, outage, restored allocation, physical dock checks, feature loss, duplicate allocator, metered return and recharge, authority removal and normal-scene opt-out passed. No independent execution.

**Accepted: all 43 compatibility suites / 628 checks**, developer explicitly confirmed in local Godot; 641/641 including 13 isolated checks. Implementation 61c3d7e, gate documentation f62e8de. Targeted, not full-project regression; no independent execution. Next x7b.

| Scene under res://tests/ | Expected check groups | Result |
|---|---:|---|
| `inventory_trasnfer_test.tscn` | 4 | Passed |
| `item_port_transfer_test.tscn` | 7 | Passed |
| `manufacturing_transaction_test.tscn` | 9 | Passed |
| `recipe_output_capacity_test.tscn` | 11 | Passed |
| `conveyor_automatic_loading_test.tscn` | 10 | Passed |
| `conveyor_automatic_unloading_test.tscn` | 9 | Passed |
| `conveyor_connected_transport_test.tscn` | 7 | Passed |
| `conveyor_splitter_test.tscn` | 10 | Passed |
| `conveyor_merger_test.tscn` | 10 | Passed |
| `conveyor_physical_only_conservation_test.tscn` | 9 | Passed |
| `timed_storage_conveyor_delivery_test.tscn` | 6 | Passed |
| `blueprint_construction_material_escrow_e3d5c2a_test.tscn` | 16 | Passed |
| `unified_receiver_consolidation_e3d5c5v_test.tscn` | 56 | Passed |
| `playable_construction_logistics_e3d5c5w_test.tscn` | 13 | Passed |
| `playable_construction_power_e3d5c5x1_test.tscn` | 9 | Passed |
| `playable_construction_drone_e3d5c5x2_test.tscn` | 11 | Passed |
| `drone_storage_discovery_e3d5c5x3_test.tscn` | 12 | Passed |
| `drone_supplier_reservations_e3d5c5x4a_test.tscn` | 12 | Passed |
| `world_salvage_destruction_test.tscn` | 12 | Passed |
| `destruction_cargo_recovery_test.tscn` | 12 | Passed |
| `drone_return_reservations_e3d5c5x4b_test.tscn` | 14 | Passed |
| `prototype_construction_worker_drone_e3d5c4u_test.tscn` | 16 | Passed |
| `prototype_drone_worker_readiness_e3d5c4v_test.tscn` | 21 | Passed |
| `prototype_construction_drone_fleet_e3d5c4w_test.tscn` | 21 | Passed |
| `prototype_drone_battery_dock_e3d5c4x_test.tscn` | 20 | Passed |
| `prototype_construction_drone_reuse_e3d5c4y_test.tscn` | 20 | Passed |
| `prototype_construction_drone_tick_e3d5c4z_test.tscn` | 20 | Passed |
| `sandbox_construction_drone_bridge_e3d5c5a_test.tscn` | 20 | Passed |
| `drone_physical_pickup_e3d5c5x5a_test.tscn` | 12 | Passed |
| `blueprint_material_staging_e3d5c4c_test.tscn` | 16 | Passed |
| `blueprint_physical_staging_e3d5c4d_test.tscn` | 16 | Passed |
| `blueprint_site_staging_ownership_e3d5c4h_test.tscn` | 16 | Passed |
| `blueprint_anchored_receiver_e3d5c4i_test.tscn` | 16 | Passed |
| `blueprint_owned_readiness_e3d5c4r_test.tscn` | 18 | Passed |
| `blueprint_receiver_recovery_audit_e3d5c4j_test.tscn` | 12 | Passed |
| `drone_physical_delivery_e3d5c5x5b_test.tscn` | 13 | Passed |
| `construction_readiness_coordinator_e3d5c3c1_test.tscn` | 18 | Passed |
| `blueprint_construction_readiness_e3d5c1_test.tscn` | 15 | Passed |
| `drone_delivered_worker_e3d5c5x5c_test.tscn` | 16 | Passed |
| `drone_cancelled_cargo_recovery_e3d5c5x6_test.tscn` | 13 | Passed |
| `construction_power_coverage_e3d5c3a_test.tscn` | 16 | Passed |
| `completed_power_structures_e3d5c3b1_test.tscn` | 16 | Passed |
| `finite_construction_power_e3d5c3b2_test.tscn` | 18 | Passed |
| **Total (43 suites)** | **628** | Passed |

## Completed compatibility gate — x6

**Isolated accepted: 13/13 A–M**, developer's Godot 4.6.2 Output screenshot, 2026-11-17 local date, implementation and test scene [6675009](https://github.com/ChrisGiggleman/industrial-warfare/commit/6675009fe9862d8830b2eedc3e3c33427cfb4dc1), documentation checkpoint 20cabd2. All PASS A–M and final ALL 13 E3D5C5X6 CANCELED CARGO RECOVERY TESTS PASSED visible. Default-off/active-job refusal, actual nearest reservation, ordinary intake protection, physical metered flight, moved dock, exact deposit, empty home return, invalid/full destination, flag loss/reroute, capacity shrink/deleted dock, unreachable route, conservation and normal scene opt-out passed. No independent execution.

**Accepted: all 39 compatibility suites / 565 checks**, explicitly developer-confirmed in local Godot; 578/578 including 13 isolated checks. Implementation 6675009, gate documentation f1215dc. This is targeted, not full-project regression; no independent execution. Next x7.

| Scene under res://tests/ | Expected check groups | Result |
|---|---:|---|
| `inventory_trasnfer_test.tscn` | 4 | Passed |
| `item_port_transfer_test.tscn` | 7 | Passed |
| `manufacturing_transaction_test.tscn` | 9 | Passed |
| `recipe_output_capacity_test.tscn` | 11 | Passed |
| `conveyor_automatic_loading_test.tscn` | 10 | Passed |
| `conveyor_automatic_unloading_test.tscn` | 9 | Passed |
| `conveyor_connected_transport_test.tscn` | 7 | Passed |
| `conveyor_splitter_test.tscn` | 10 | Passed |
| `conveyor_merger_test.tscn` | 10 | Passed |
| `conveyor_physical_only_conservation_test.tscn` | 9 | Passed |
| `timed_storage_conveyor_delivery_test.tscn` | 6 | Passed |
| `blueprint_construction_material_escrow_e3d5c2a_test.tscn` | 16 | Passed |
| `unified_receiver_consolidation_e3d5c5v_test.tscn` | 56 | Passed |
| `playable_construction_logistics_e3d5c5w_test.tscn` | 13 | Passed |
| `playable_construction_power_e3d5c5x1_test.tscn` | 9 | Passed |
| `playable_construction_drone_e3d5c5x2_test.tscn` | 11 | Passed |
| `drone_storage_discovery_e3d5c5x3_test.tscn` | 12 | Passed |
| `drone_supplier_reservations_e3d5c5x4a_test.tscn` | 12 | Passed |
| `world_salvage_destruction_test.tscn` | 12 | Passed |
| `destruction_cargo_recovery_test.tscn` | 12 | Passed |
| `drone_return_reservations_e3d5c5x4b_test.tscn` | 14 | Passed |
| `prototype_construction_worker_drone_e3d5c4u_test.tscn` | 16 | Passed |
| `prototype_drone_worker_readiness_e3d5c4v_test.tscn` | 21 | Passed |
| `prototype_construction_drone_fleet_e3d5c4w_test.tscn` | 21 | Passed |
| `prototype_drone_battery_dock_e3d5c4x_test.tscn` | 20 | Passed |
| `prototype_construction_drone_reuse_e3d5c4y_test.tscn` | 20 | Passed |
| `prototype_construction_drone_tick_e3d5c4z_test.tscn` | 20 | Passed |
| `sandbox_construction_drone_bridge_e3d5c5a_test.tscn` | 20 | Passed |
| `drone_physical_pickup_e3d5c5x5a_test.tscn` | 12 | Passed |
| `blueprint_material_staging_e3d5c4c_test.tscn` | 16 | Passed |
| `blueprint_physical_staging_e3d5c4d_test.tscn` | 16 | Passed |
| `blueprint_site_staging_ownership_e3d5c4h_test.tscn` | 16 | Passed |
| `blueprint_anchored_receiver_e3d5c4i_test.tscn` | 16 | Passed |
| `blueprint_owned_readiness_e3d5c4r_test.tscn` | 18 | Passed |
| `blueprint_receiver_recovery_audit_e3d5c4j_test.tscn` | 12 | Passed |
| `drone_physical_delivery_e3d5c5x5b_test.tscn` | 13 | Passed |
| `construction_readiness_coordinator_e3d5c3c1_test.tscn` | 18 | Passed |
| `blueprint_construction_readiness_e3d5c1_test.tscn` | 15 | Passed |
| `drone_delivered_worker_e3d5c5x5c_test.tscn` | 16 | Passed |
| **Total (39 suites)** | **565** | Passed |

## Completed compatibility gate — x5c

**Isolated accepted: 16/16 A–P**, local developer Godot 4.6.2 Output screenshot 2026-11-17, implementation [6652bd0](https://github.com/ChrisGiggleman/industrial-warfare/commit/6652bd0db58594a8efd0c7d862c533abdbe782fb). Explicit coordinator handoff of empty delivered drone into existing owned-material coordinator and finite worker scheduler, exact escrow provenance, physical arrival and return energy, pause/resume, empty return, cancellation conservation, reuse quarantine and normal-scene opt-out passed. No independent runtime execution by assistant.

**Accepted: all 38 compatibility suites / 549 check groups** explicitly reported passed by developer in local Godot on 2026-11-17, plus 16 isolated checks: 565/565 targeted acceptance. Tested implementation 6652bd0; documentation checkpoint 955eab6. Not independently executed or a full-project regression. Next x6 automatic canceled-job cargo recovery.

| Scene under res://tests/ | Expected check groups | Result |
|---|---:|---|
| `inventory_trasnfer_test.tscn` | 4 | Passed |
| `item_port_transfer_test.tscn` | 7 | Passed |
| `manufacturing_transaction_test.tscn` | 9 | Passed |
| `recipe_output_capacity_test.tscn` | 11 | Passed |
| `conveyor_automatic_loading_test.tscn` | 10 | Passed |
| `conveyor_automatic_unloading_test.tscn` | 9 | Passed |
| `conveyor_connected_transport_test.tscn` | 7 | Passed |
| `conveyor_splitter_test.tscn` | 10 | Passed |
| `conveyor_merger_test.tscn` | 10 | Passed |
| `conveyor_physical_only_conservation_test.tscn` | 9 | Passed |
| `timed_storage_conveyor_delivery_test.tscn` | 6 | Passed |
| `blueprint_construction_material_escrow_e3d5c2a_test.tscn` | 16 | Passed |
| `unified_receiver_consolidation_e3d5c5v_test.tscn` | 56 | Passed |
| `playable_construction_logistics_e3d5c5w_test.tscn` | 13 | Passed |
| `playable_construction_power_e3d5c5x1_test.tscn` | 9 | Passed |
| `playable_construction_drone_e3d5c5x2_test.tscn` | 11 | Passed |
| `drone_storage_discovery_e3d5c5x3_test.tscn` | 12 | Passed |
| `drone_supplier_reservations_e3d5c5x4a_test.tscn` | 12 | Passed |
| `world_salvage_destruction_test.tscn` | 12 | Passed |
| `destruction_cargo_recovery_test.tscn` | 12 | Passed |
| `drone_return_reservations_e3d5c5x4b_test.tscn` | 14 | Passed |
| `prototype_construction_worker_drone_e3d5c4u_test.tscn` | 16 | Passed |
| `prototype_drone_worker_readiness_e3d5c4v_test.tscn` | 21 | Passed |
| `prototype_construction_drone_fleet_e3d5c4w_test.tscn` | 21 | Passed |
| `prototype_drone_battery_dock_e3d5c4x_test.tscn` | 20 | Passed |
| `prototype_construction_drone_reuse_e3d5c4y_test.tscn` | 20 | Passed |
| `prototype_construction_drone_tick_e3d5c4z_test.tscn` | 20 | Passed |
| `sandbox_construction_drone_bridge_e3d5c5a_test.tscn` | 20 | Passed |
| `drone_physical_pickup_e3d5c5x5a_test.tscn` | 12 | Passed |
| `blueprint_material_staging_e3d5c4c_test.tscn` | 16 | Passed |
| `blueprint_physical_staging_e3d5c4d_test.tscn` | 16 | Passed |
| `blueprint_site_staging_ownership_e3d5c4h_test.tscn` | 16 | Passed |
| `blueprint_anchored_receiver_e3d5c4i_test.tscn` | 16 | Passed |
| `blueprint_owned_readiness_e3d5c4r_test.tscn` | 18 | Passed |
| `blueprint_receiver_recovery_audit_e3d5c4j_test.tscn` | 12 | Passed |
| `drone_physical_delivery_e3d5c5x5b_test.tscn` | 13 | Passed |
| `construction_readiness_coordinator_e3d5c3c1_test.tscn` | 18 | Passed |
| `blueprint_construction_readiness_e3d5c1_test.tscn` | 15 | Passed |
| **Total (38 suites)** | **549** | Passed |

## Completed compatibility gate — x5b

All 35 compatibility suites and 503/503 groups passed in local Godot; 516/516 including 13 isolated checks. Historical baseline for x5c compatibility.

| Scene under res://tests/ | Expected check groups | Result |
|---|---:|---|
| `inventory_trasnfer_test.tscn` | 4 | Passed |
| `item_port_transfer_test.tscn` | 7 | Passed |
| `manufacturing_transaction_test.tscn` | 9 | Passed |
| `recipe_output_capacity_test.tscn` | 11 | Passed |
| `conveyor_automatic_loading_test.tscn` | 10 | Passed |
| `conveyor_automatic_unloading_test.tscn` | 9 | Passed |
| `conveyor_connected_transport_test.tscn` | 7 | Passed |
| `conveyor_splitter_test.tscn` | 10 | Passed |
| `conveyor_merger_test.tscn` | 10 | Passed |
| `conveyor_physical_only_conservation_test.tscn` | 9 | Passed |
| `timed_storage_conveyor_delivery_test.tscn` | 6 | Passed |
| `blueprint_construction_material_escrow_e3d5c2a_test.tscn` | 16 | Passed |
| `unified_receiver_consolidation_e3d5c5v_test.tscn` | 56 | Passed |
| `playable_construction_logistics_e3d5c5w_test.tscn` | 13 | Passed |
| `playable_construction_power_e3d5c5x1_test.tscn` | 9 | Passed |
| `playable_construction_drone_e3d5c5x2_test.tscn` | 11 | Passed |
| `drone_storage_discovery_e3d5c5x3_test.tscn` | 12 | Passed |
| `drone_supplier_reservations_e3d5c5x4a_test.tscn` | 12 | Passed |
| `world_salvage_destruction_test.tscn` | 12 | Passed |
| `destruction_cargo_recovery_test.tscn` | 12 | Passed |
| `drone_return_reservations_e3d5c5x4b_test.tscn` | 14 | Passed |
| `prototype_construction_worker_drone_e3d5c4u_test.tscn` | 16 | Passed |
| `prototype_drone_worker_readiness_e3d5c4v_test.tscn` | 21 | Passed |
| `prototype_construction_drone_fleet_e3d5c4w_test.tscn` | 21 | Passed |
| `prototype_drone_battery_dock_e3d5c4x_test.tscn` | 20 | Passed |
| `prototype_construction_drone_reuse_e3d5c4y_test.tscn` | 20 | Passed |
| `prototype_construction_drone_tick_e3d5c4z_test.tscn` | 20 | Passed |
| `sandbox_construction_drone_bridge_e3d5c5a_test.tscn` | 20 | Passed |
| `drone_physical_pickup_e3d5c5x5a_test.tscn` | 12 | Passed |
| `blueprint_material_staging_e3d5c4c_test.tscn` | 16 | Passed |
| `blueprint_physical_staging_e3d5c4d_test.tscn` | 16 | Passed |
| `blueprint_site_staging_ownership_e3d5c4h_test.tscn` | 16 | Passed |
| `blueprint_anchored_receiver_e3d5c4i_test.tscn` | 16 | Passed |
| `blueprint_owned_readiness_e3d5c4r_test.tscn` | 18 | Passed |
| `blueprint_receiver_recovery_audit_e3d5c4j_test.tscn` | 12 | Passed |
| **Total (35 suites)** | **503** | Passed |

## Completed compatibility gate — x5a

All 28 suites and 397 check groups passed in local Godot, plus 12 isolated checks: 409/409 targeted acceptance. Next x5b: guarded delivery to the original authorized site's owned staging.

| Scene under res://tests/ | Expected check groups | Result |
|---|---:|---|
| `inventory_trasnfer_test.tscn` | 4 | Passed |
| `item_port_transfer_test.tscn` | 7 | Passed |
| `manufacturing_transaction_test.tscn` | 9 | Passed |
| `recipe_output_capacity_test.tscn` | 11 | Passed |
| `conveyor_automatic_loading_test.tscn` | 10 | Passed |
| `conveyor_automatic_unloading_test.tscn` | 9 | Passed |
| `conveyor_connected_transport_test.tscn` | 7 | Passed |
| `conveyor_splitter_test.tscn` | 10 | Passed |
| `conveyor_merger_test.tscn` | 10 | Passed |
| `conveyor_physical_only_conservation_test.tscn` | 9 | Passed |
| `timed_storage_conveyor_delivery_test.tscn` | 6 | Passed |
| `blueprint_construction_material_escrow_e3d5c2a_test.tscn` | 16 | Passed |
| `unified_receiver_consolidation_e3d5c5v_test.tscn` | 56 | Passed |
| `playable_construction_logistics_e3d5c5w_test.tscn` | 13 | Passed |
| `playable_construction_power_e3d5c5x1_test.tscn` | 9 | Passed |
| `playable_construction_drone_e3d5c5x2_test.tscn` | 11 | Passed |
| `drone_storage_discovery_e3d5c5x3_test.tscn` | 12 | Passed |
| `drone_supplier_reservations_e3d5c5x4a_test.tscn` | 12 | Passed |
| `world_salvage_destruction_test.tscn` | 12 | Passed |
| `destruction_cargo_recovery_test.tscn` | 12 | Passed |
| `drone_return_reservations_e3d5c5x4b_test.tscn` | 14 | Passed |
| `prototype_construction_worker_drone_e3d5c4u_test.tscn` | 16 | Passed |
| `prototype_drone_worker_readiness_e3d5c4v_test.tscn` | 21 | Passed |
| `prototype_construction_drone_fleet_e3d5c4w_test.tscn` | 21 | Passed |
| `prototype_drone_battery_dock_e3d5c4x_test.tscn` | 20 | Passed |
| `prototype_construction_drone_reuse_e3d5c4y_test.tscn` | 20 | Passed |
| `prototype_construction_drone_tick_e3d5c4z_test.tscn` | 20 | Passed |
| `sandbox_construction_drone_bridge_e3d5c5a_test.tscn` | 20 | Passed |
| **Total (28 suites)** | **397** | Passed |

x5b fully accepted; x5c delivered-worker handoff fully accepted. Successful unload remains DELIVERED until explicit coordinator handoff. Cancellation return unloading, loaded-drone destruction/persistence and Main activation remain separate gates.

## Completed compatibility gate — x4b

Completed locally in Godot (F6); retain this list as the acceptance record. The x4a 16-suite gate is reused, plus supplier reservations, automatic unloading, timed Storage conveyor delivery and recipe output capacity because ordinary intake capacity changed. This is targeted coverage, not a full project regression.

| Scene under res://tests/ | Expected check groups | Result |
|---|---:|---|
| `inventory_trasnfer_test.tscn` | 4 | Passed |
| `item_port_transfer_test.tscn` | 7 | Passed |
| `manufacturing_transaction_test.tscn` | 9 | Passed |
| `recipe_output_capacity_test.tscn` | 11 | Passed |
| `conveyor_automatic_loading_test.tscn` | 10 | Passed |
| `conveyor_automatic_unloading_test.tscn` | 9 | Passed |
| `conveyor_connected_transport_test.tscn` | 7 | Passed |
| `conveyor_splitter_test.tscn` | 10 | Passed |
| `conveyor_merger_test.tscn` | 10 | Passed |
| `conveyor_physical_only_conservation_test.tscn` | 9 | Passed |
| `timed_storage_conveyor_delivery_test.tscn` | 6 | Passed |
| `blueprint_construction_material_escrow_e3d5c2a_test.tscn` | 16 | Passed |
| `unified_receiver_consolidation_e3d5c5v_test.tscn` | 56 | Passed |
| `playable_construction_logistics_e3d5c5w_test.tscn` | 13 | Passed |
| `playable_construction_power_e3d5c5x1_test.tscn` | 9 | Passed |
| `playable_construction_drone_e3d5c5x2_test.tscn` | 11 | Passed |
| `drone_storage_discovery_e3d5c5x3_test.tscn` | 12 | Passed |
| `drone_supplier_reservations_e3d5c5x4a_test.tscn` | 12 | Passed |
| `world_salvage_destruction_test.tscn` | 12 | Passed |
| `destruction_cargo_recovery_test.tscn` | 12 | Passed |
| **Total** | **245** | Passed |

Inventory scene's historical filename typo is intentional; inventory's four groups have no ALL banner, and manufacturing and output capacity print unnumbered ALL banners. All 245 passed; 259/259 including isolated checks. Next: x5 isolated pickup transaction, then movement and site delivery.

## Design decisions and guardrails

- Permanent conveyors move factory materials; construction drones physically collect eligible Storage stock and deliver it to authorized sites. No temporary belts required for construction, no magical transfer.
- Preserve existing conveyor paths, manual construction authorization (E selected, Ctrl+E all), priority ordering (never auto-authorizes), escrow, timed construction, power/readiness, and all accepted tests.
- Preserve sandbox-only/default-off feature gates and Main opt-out. No unreviewed production activation.
- Incoming capacity and outgoing stock claims are independent; physical inventory remains unchanged by reserving or releasing. Current return claim is whole single-material load, exact owner/Storage/dock/inventory identity, and newest excess claims released first after capacity reduction.
- On cancellation, an actual loaded drone should retain its cargo and select nearest eligible Storage with reserved capacity and safe battery forecast; do not discard or duplicate material. Re-evaluate assignment only after safe unloading. Researchable docking retrofits, silos and depots remain agreed future features.
- Physical pickup/cargo custody fully accepted; site delivery and isolated return unloading fully accepted; active-claim destruction recovery and persistence remain pending. No assumption of pathfinding safety or production activation.

## Roadmap from here

1. x4b compatibility acceptance — complete.
2. E3d5c5x5a fully accepted; x5b fully accepted. x5c fully accepted 565/565; proceed to x6.
3. E3d5c5x6 fully accepted 578/578; proceed to x7.
4. E3d5c5x7a fully accepted 641/641; x7b fully accepted 657/657; x7c1 fully accepted 669/669; x7c2 fully accepted 682/682; x7c3 fully accepted 696/696. Proceed to x8 isolated automatic priority-based dispatch in a fresh chat.
5. Multiple drones/sites, researchable Storage docking attachments, bulk silos, construction depots, persistence/destruction integration and playable Main activation through separate gates.

Read [DEVLOG](DEVLOG.md), [ROADMAP](ROADMAP.md), [Drone Construction Logistics](DRONE_CONSTRUCTION_LOGISTICS.md), [Architecture](ARCHITECTURE.md), [Construction and Power](CONSTRUCTION_AND_POWER_ARCHITECTURE.md), and [Future Features](FUTURE_FEATURES.md) for detail.

## Continuity procedure

At each major milestone, before changing chats, and when stopping mid-gate: record tested commit, developer-confirmed results, pending and failed tests, changes, design decisions, limitations and next action here and in the appropriate history/roadmap docs. Keep prior history in DEVLOG and Git; do not mark pending work accepted. Provide the new-chat prompt below. A new chat should inspect this file at main and current HEAD, reconcile differences and resume from the documented gate, not restart or redesign. Exact chat capacity is not reliably observable; rotate at clean checkpoints, or checkpoint before long implementation/testing.

### Reusable new-chat prompt

Continue Industrial Warfare development from ChrisGiggleman/industrial-warfare, main, Godot 4.6.2. Read docs/HANDOFF.md, DEVLOG, ROADMAP and DRONE_CONSTRUCTION_LOGISTICS.md using GitHub; verify current main HEAD and actual source. E3d5c5x7c3 fully accepted 696/696 (14 isolated + 682 across 47 compatibility suites), user-confirmed Godot tests, 2026-11-18. Begin E3d5c5x8 automatic priority-based construction drone dispatch, initially x8a single-drone serialized selection and exact claim/launch, following the proposed stages in HANDOFF. Preserve player authorization (E/Ctrl+E), H/N/L and FIFO priority, no automatic authorization, conservation, existing finite charging, recovery, staging/escrow, power/worker, full-charge and cleanup gates. Keep default-off and normal scenes unchanged. Implement and commit isolated code and test scene, provide git pull/F6 instructions and exact pending counts, and wait for my local results before accepting tests. Do not skip gates or treat historical results as new runtime verification. Keep the four project docs current and provide a new-chat prompt at clean checkpoints.


### 2026-11-18 — E3d5c6a final manual playable expansion accepted (9/9); final combined regression pending

Developer explicitly confirmed all nine manual playable expansion checks passed locally in Godot against the expansion sandbox and checklist checkpoint [e2da66b](https://github.com/ChrisGiggleman/industrial-warfare/commit/e2da66b4378ac371eccb55721083b9391599c904): initial HUD, unauthorized mixed plans, batch authorization and physical Press dispatch, generator pause/resume, actual Press completion and recharge, High/Low Storage completion and four remaining ingots, unaffordable Press waiting, loaded cancellation physical return, and during-work cancellation with protected staged materials. Aggregate developer confirmation, no independent assistant runtime/manual execution or screenshot review. Exact retained staging contents were verified by earlier accepted automated Stage B, not directly enumerated by HUD. New manual 9/9 is separate from historic Storage manual 9/9 and automated counts. Cumulative accepted 56 suites / 785 unique checks; fresh final combined 56/785 rerun is still pending. Use [BUILDING_EXPANSION_FINAL_REGRESSION.md](BUILDING_EXPANSION_FINAL_REGRESSION.md) and `tools/building_expansion_final_regression.csv`. Do not claim full expansion closeout or begin Direct Build Authorization until developer confirms final automated results. No gameplay/test/runner changes; Main and ordinary scenes remain untouched. Build mode remains legacy.
