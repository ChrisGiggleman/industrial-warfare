# Industrial Warfare — Development Log

### 2026-11-25 — C2 FULLY ACCEPTED; C3 proposal

Developer confirmed C2 compatibility 27/27 F6 scenes passed locally against 356 manifest-expected sections on 2026-11-25, following isolated 16/16. C2 FULLY ACCEPTED: 28 gate scene runs / 372 associated sections, 27/356 overlapping accepted coverage. Unique accepted coverage 70 suites / 951 expected sections; last fresh full B4 68/923 remains distinct. Assistant did not run Godot or inspect assertion logs. C3 plan awaits explicit implementation approval. [C3 implementation plan](DRONE_ROLE_SPECIALIZATION_E3D5C6F_STAGE_C3_PLAN.md). Documentation-only checkpoint; Main, prior scenes/tests, local edits and unmerged draft PR #1 preserved. No C3 gameplay or F6 fixture yet.


### 2026-11-25 — C2 isolated ACCEPTED; compatibility PENDING

Developer confirmed C2 isolated F6 16/16 labeled sections passed locally in Godot against implementation commit bb666235f575bad4c83cdde90a7d378c9c25e4ba on 2026-11-25. Cumulative unique accepted coverage 70 suites / 951 expected sections (B4 68/923 + C1 1/12 + C2 1/16); last fresh full regression remains B4 68/923. C2 targeted compatibility 27 existing suites / 356 manifest-expected sections PENDING; reruns overlap accepted coverage. Assistant did not run Godot or inspect assertion logs. C3 gated on local compatibility acceptance; Main, prior scenes/tests, local edits and unmerged draft PR #1 preserved. [Compatibility guide](DRONE_ROLE_SPECIALIZATION_E3D5C6F_STAGE_C2_COMPATIBILITY.md).


### 2026-11-25 — E3d5c6f C2 implementation staged; F6 PENDING

Developer approved C2. Default-off C2 extension of existing C1/B2 single owner, explicit physical collection and delivery without unload, original job cancellation and exact revoked lease, original return reservation/discovery service, registered return-only alternate docks, metered home return and finite charging/rearm. New isolated F6 res://tests/specialized_drone_loaded_cancel_e3d5c6f_c2_test.tscn with 16 labeled sections A–P is **PENDING local execution**. C2 tests cover capacity shrink, disabled and moved docks (actual deletion not included in this new fixture; historical x6 covers deletion and should be rerun). No gameplay activation in Main or old scene/test changes. Cumulative accepted baseline remains 69/935; fresh B4 68/923 unchanged. No assistant Godot runtime. C2 targeted compatibility after local acceptance.


### 2026-11-25 — E3d5c6f C1 FULLY ACCEPTED; C2 proposal

Developer confirmed C1 targeted compatibility 22/22 F6 scenes passed locally against 295 manifest-expected sections on 2026-11-25, following isolated 12/12 acceptance. C1 FULLY ACCEPTED: 23 gate scene runs / 307 associated expected sections, of which 22/295 overlap B4. Unique accepted coverage 69 suites / 935 expected sections; last fresh full B4 68/923 remains distinct. Assistant did not run Godot or inspect individual assertion logs. Next C2 scoped plan awaits explicit implementation approval. [C2 implementation plan](DRONE_ROLE_SPECIALIZATION_E3D5C6F_STAGE_C2_PLAN.md). Documentation-only checkpoint; Main, all previously accepted scenes/tests, local edits and draft PR #1 preserved. No C2 gameplay code or new F6 fixture yet.


### 2026-11-25 — C1 isolated ACCEPTED; compatibility PENDING

Developer confirmed all 12/12 labeled C1 sections passed locally in Godot against implementation commit acec11e64df4d9987a8156e63bc68f7ff59ad56f. Assistant did not execute Godot. Cumulative unique accepted coverage 69 suites / 935 expected sections (68/923 historical fresh B4 + 1/12 C1); no fresh full 69-suite regression claimed. Targeted compatibility 22 existing scenes / 295 manifest-expected sections PENDING; these overlap B4 and must not inflate unique coverage. C2 remains gated on developer-local compatibility acceptance. Main, accepted scenes/tests, local edits and unmerged draft PR #1 preserved. [Compatibility guide](DRONE_ROLE_SPECIALIZATION_E3D5C6F_STAGE_C1_COMPATIBILITY.md).


### 2026-11-25 — E3d5c6f C0 reviewed / C1 isolated implementation staged; F6 PENDING

Developer approved C1 only. [C0 audit and C1 gate](DRONE_ROLE_SPECIALIZATION_E3D5C6F_STAGE_C0_C1.md). Default-off same-B2-owner pre-pickup cancellation, exact supplier release, physical empty return, finite hub recharge and terminal rearm; no collection in C1 isolated mode. New F6 `res://tests/specialized_drone_pre_pickup_cancel_e3d5c6f_c1_test.tscn` (12 labeled sections) **not yet run**. Accepted B4 remains 68 unique suites / 923 manifest-expected sections. Main, old scenes/tests and local edits untouched; draft PR #1 unmerged. C2–C5 remain pending.


### 2026-11-25 — E3d5c6f Stage B4 FINAL ACCEPTED: 68/68 fresh local F6 unique suites

Developer explicitly reported **Wave 4 all 8/8 F6 scenes passed locally**, completing a fresh distinct four-wave regression: **Wave 1 20/20 (245 manifest-expected groups), Wave 2 20/20 (333), Wave 3 20/20 (258), Wave 4 8/8 (87)**. Combined **68/68 unique Godot F6 scenes accepted against 923 manifest-expected check sections**. The manifest count/sum and unique scene names are audited; the assistant did **not** run Godot or independently inspect 923 individual assertion logs. Previously accepted A/B1/B2/B3 targeted reruns do not add to the unique count.

**E3d5c6f isolated Stage B (B1–B4) CLOSED.** [Final B4 closeout](DRONE_ROLE_SPECIALIZATION_E3D5C6F_STAGE_B4_CLOSEOUT.md); [authoritative B4 regression guide](DRONE_ROLE_SPECIALIZATION_E3D5C6F_STAGE_B4_REGRESSION.md); [deduplicated manifest](../tools/specialized_drones_e3d5c6f_stage_b4_68_suite_regression.csv). **Recommended next milestone:** [E3d5c6f Stage C specialized-drone cancellation and physical material custody recovery proposal](DRONE_ROLE_SPECIALIZATION_E3D5C6F_STAGE_C_PROPOSAL.md). Begin with **C0 read-only architecture audit** to specify exact custody owner and canceled-site material recovery at pickup, in-flight cargo, delivered staging, escrow, and active builder phases; no gameplay coding in C0. Main and accepted scenes/tests remain unchanged; preserve local resource edits. Draft PR #1 stays open/unmerged on `feature/e3d5c6f-stage-a-role-contracts`.


### 2026-11-25 — E3d5c6f B4 Wave 3 ACCEPTED: 20/20 developer-local F6 scenes

Developer explicitly confirmed **all 20/20 Wave 3 F6 scenes passed locally** in Godot, matching the committed unique manifest rows 41–60 from `construction_power_coverage_e3d5c3a_test.tscn` through `cancelled_site_physical_recovery_e3d5c6c_stage_b_test.tscn`. These scenes account for **258 manifest-expected sections**, not independently counted source-level assertions. Accepted waves: **Wave 1 20/20 (245 expected), Wave 2 20/20 (333), Wave 3 20/20 (258)**. Fresh cumulative B4 acceptance is **60/68 unique F6 scenes with 836/923 associated manifest-expected sections**. This is developer-local testimony; assistant has not run Godot.

**NEXT: Wave 4, 8 F6 scenes / 87 expected sections, PENDING** in `tools/specialized_drones_e3d5c6f_stage_b4_68_suite_regression.csv`, rows 61–68: historical playable cancelled-site recovery E3d5c6c, unified construction E3d5c6d, power interruption E3d5c6e, then E3d5c6f Stage A role guards, Stage A handoff, B1 single owner, B2 logistics and B3 builder. Prior targeted passes do NOT count as fresh Wave 4 runs. **Do not close out B4 or claim 68/68 until all eight fresh F6 scenes are confirmed.** Preserve accepted source/tests, `main`, local uncommitted `.tres/.tscn` files, feature branch `feature/e3d5c6f-stage-a-role-contracts` and draft PR #1 unmerged. [B4 authoritative guide](DRONE_ROLE_SPECIALIZATION_E3D5C6F_STAGE_B4_REGRESSION.md).


### 2026-11-24 — E3d5c6f B4 Wave 2 ACCEPTED: 20/20 developer-local F6 scenes

Developer explicitly confirmed **all 20/20 Wave 2 F6 scenes passed locally**, corresponding to the exact scene paths in manifest rows **21–40** of `tools/specialized_drones_e3d5c6f_stage_b4_68_suite_regression.csv`, from `drone_return_reservations_e3d5c5x4b_test.tscn` through `drone_cancelled_cargo_recovery_e3d5c5x6_test.tscn`. These scenes carry **333 manifest-expected printed check sections**; this is not an independently audited per-assertion transcript. Local developer confirmation supersedes any unsubmitted UI checkbox progress.

**Fresh B4 cumulative acceptance: 40/68 unique scenes, 578/923 associated manifest-expected sections** (Wave 1 20/20 / 245, Wave 2 20/20 / 333). **NEXT Wave 3 PENDING:** 20 F6 scenes / 258 expected sections, manifest rows 41–60 (power, finite hub charging, drone dispatch/lifecycle, construction expansion, direct-build, canceled-site custody). **Wave 4 PENDING:** 8 scenes / 87. Do not claim all 68 passed yet or treat old targeted reruns as fresh. Historical E3d5c6e 63/63/880 accepted remains distinct. Preserve Main, old accepted scenes/tests and local .tres/.tscn modifications; use branch `feature/e3d5c6f-stage-a-role-contracts`, leave draft PR #1 unmerged. [B4 manifest and protocol](DRONE_ROLE_SPECIALIZATION_E3D5C6F_STAGE_B4_REGRESSION.md).


### 2026-11-24 — E3d5c6f B4 Wave 1 ACCEPTED: 20/20 local F6 scenes

Developer confirmed **ALL 20/20 Wave 1 F6 scenes PASSED** against the freshly committed four-wave [68-unique-suite manifest](../tools/specialized_drones_e3d5c6f_stage_b4_68_suite_regression.csv) `tools/specialized_drones_e3d5c6f_stage_b4_68_suite_regression.csv`. Wave 1 = manifest rows 1–20 (from `inventory_trasnfer_test.tscn` through `destruction_cargo_recovery_test.tscn`), **245 manifest-expected test/check sections**, not an independently verified assertion-by-assertion tally. Local developer report; Godot not run by assistant. **B4 progress: 20/68 unique scenes reported freshly passed, 245/923 manifest-expected sections associated with passed scenes.** **Wave 2 NEXT/PENDING: 20 scenes / 333 expected sections**, manifest rows 21–40. Waves 3 (20/258) and 4 (8/87) PENDING. Do not claim full B4 68/68 or reuse prior targeted reruns as this fresh regression. Preserve Main, previously accepted fixtures, developer local resource edits, feature branch `feature/e3d5c6f-stage-a-role-contracts` and unmerged PR #1. [B4 guide](DRONE_ROLE_SPECIALIZATION_E3D5C6F_STAGE_B4_REGRESSION.md).


### 2026-11-24 — E3d5c6f Stage B4 regression manifest AUDITED; fresh run PENDING

Developer requested B4 after **Stage B3 targeted 8/8 local F6** acceptance. Audited existing authoritative `tools/drone_power_interruption_e3d5c6e_final_63_suite_regression.csv` (63 unique scene names, historical manifest total 880); verified every original `tests/*.tscn` path exists on feature branch. Appended all five committed E3d5c6f A/B1/B2/B3 fixture scenes exactly once (6+7+9+9+12 = 43 source-derived labeled printed PASS sections) to new **`tools/specialized_drones_e3d5c6f_stage_b4_68_suite_regression.csv`**: **68 unique F6 scenes, 923 manifest-expected check groups**, no duplicates, all scene paths verified. Historical expected groups + new printed sections are manifest bookkeeping, **not** independently audited 923 assertions. Four ordered waves: **Wave 1 20 scenes/245 expected, Wave 2 20/333, Wave 3 20/258, Wave 4 8/87**. **NO fresh B4 Godot suite has yet been reported run**; next is **Wave 1** one-at-a-time interactive Copy scene path F6 navigator. [B4 regression guide](DRONE_ROLE_SPECIALIZATION_E3D5C6F_STAGE_B4_REGRESSION.md). Stop on first failing suite; count completed waves only on developer confirmation, not prior B3 targeted reruns.

No changes to gameplay sources or accepted legacy scenes/tests in this B4 manifest checkpoint. Keep `feature/e3d5c6f-stage-a-role-contracts`, draft PR #1 unmerged, `main` untouched, and preserve developer's uncommitted local `.tres/.tscn` modifications. Historical accepted E3d5c6e 63/63/880 remains distinct from current pending fresh 68/923.


### 2026-11-24 — E3d5c6f Stage B3 TARGETED ACCEPTED: 8/8 F6 scenes developer-local PASSED

Developer reports **all eight requested Godot F6 scenes passed**, including NEW `res://tests/specialized_drone_builder_e3d5c6f_b3_test.tscn` (12 labeled PASS sections) and seven targeted compatibility reruns:
- `res://tests/specialized_drone_logistics_e3d5c6f_b2_test.tscn` (9 labeled sections)
- `res://tests/specialized_drone_single_owner_e3d5c6f_b1_test.tscn` (9)
- `res://tests/specialized_drone_role_guards_e3d5c6f_stage_a_test.tscn` (6)
- `res://tests/specialized_drone_handoff_e3d5c6f_stage_a_test.tscn` (7)
- `res://tests/drone_physical_pickup_e3d5c5x5a_test.tscn` (12)
- `res://tests/drone_physical_delivery_e3d5c5x5b_test.tscn` (13)
- `res://tests/drone_post_delivery_cancellation_e3d5c5x7c2_test.tscn` (13)

**Counting:** 8/8 F6 scene runs at this gate = **1 new B3 fixture and 7 already accepted regression reruns**, with 81 labeled PASS sections across source, **not 81 independent assertion/check counts or 81 new unique checks**. Developer-local verification; assistant did not execute Godot. The scoped end-to-end two-role vertical slice is accepted: original logistics physical collection of five ingots and handoff/return, separate construction drone battery-metered arrival and one worker-slot admission through original coordinator, real power outage/pause/restart, original 18-second Ammunition Press build completion and escrow commitment, metered construction drone return. **B4 combined unique-suite regression is NOT yet run.** Historical E3d5c6e baseline **63 unique suites / 880 manifest-expected checks** remains accepted from earlier stage but has **NOT** been freshly rerun against B3; do not invent new combined counts.

Keep `main` and previously accepted scenes/tests unchanged; preserve developer's uncommitted local `.tres/.tscn` files. Work is on `feature/e3d5c6f-stage-a-role-contracts`, draft PR #1 remains unmerged. Next gate **E3d5c6f Stage B4** — generate an audited unique regression manifest and run developer-local comprehensive compatibility, before deciding merge or future gameplay integration. Stage C cancellations, custody recovery and fleet scheduling remain future gates. [B3 checkpoint](DRONE_ROLE_SPECIALIZATION_E3D5C6F_STAGE_B3.md).


### 2026-11-24 — E3d5c6f Stage B3 separate physical builder IMPLEMENTED; F6 PENDING

User requested B3 after accepted B2 targeted **6/6 local F6 scene runs**. Code now adds a **default-off** `B3BuilderController` and original `PowerNetwork` in the one E3d5c6f opt-in scene, an **exact B2→B3 single-tick-owner handoff**, and an **additive receipt-backed distinct physically-arrived builder binding** on the existing slot scheduler. The original PowerAllocator, ReadinessCoordinator, site escrow and single scheduler retain all real power/material/worker permission; original ConstructionJob is the **sole** 18-second timer. The new `res://tests/specialized_drone_builder_e3d5c6f_b3_test.tscn` (12 labeled sections) exercises actual B2 material movement, physically separate builder, no permission before physical arrival, real power outage waiting and construction pause/resume, escrow commitment upon real Press activation, and metered return. **UNRUN in Godot**; do not claim passage, acceptance or fresh aggregate regression. After new scene passes, seven targeted accepted suite reruns remain. [B3 scope and one-at-a-time F6 guide](DRONE_ROLE_SPECIALIZATION_E3D5C6F_STAGE_B3.md).

Preserve Main and every previously accepted test scene; avoid modifying developer local `.tres/.tscn` changes, keep feature `feature/e3d5c6f-stage-a-role-contracts`, PR #1 draft/unmerged. Older accepted historical baseline E3d5c6e **63 suites / 880 manifest-expected checks** has NOT been freshly rerun. Stage B4 combined regression and Stage C custody are NOT started.


### 2026-11-24 — E3d5c6f Stage B2 TARGETED ACCEPTANCE COMPLETE: 6/6 F6 SCENES PASSED LOCALLY

Developer confirmed **all five requested targeted compatibility F6 scenes passed**, following the separately confirmed new B2 isolated logistics fixture passing after its setup fix. Thus **six scene runs passed at the B2 gate**: (1) new `res://tests/specialized_drone_logistics_e3d5c6f_b2_test.tscn` (9 labeled sections); (2) B1 `res://tests/specialized_drone_single_owner_e3d5c6f_b1_test.tscn` (9); (3) Stage A role guards `res://tests/specialized_drone_role_guards_e3d5c6f_stage_a_test.tscn` (6); (4) Stage A material handoff `res://tests/specialized_drone_handoff_e3d5c6f_stage_a_test.tscn` (7); (5) earlier E3d5c5x5a physical pickup `res://tests/drone_physical_pickup_e3d5c5x5a_test.tscn` (12); (6) earlier E3d5c5x5b physical delivery `res://tests/drone_physical_delivery_e3d5c5x5b_test.tscn` (13). These comprise **one new B2 fixture plus five preexisting reruns**, with 56 labeled printed sections across source fixtures, **not an audited individual-assertion/check count or 56 new checks**. Results are **developer-reported local Godot F6**, not independently assistant-run.

**B2 accepted within its scoped physical logistics-only and original-material-provenance boundaries:** original Storage 15→10 Test Ingots, original site escrow 5, physically empty logistics drone returns on battery, construction drone remains idle, original Press stays QUEUED with zero progress and no worker readiness. The historical fully accepted E3d5c6e **63/63 unique suites / 880 manifest-expected checks has NOT been freshly rerun** for E3d5c6f. A combined full regression and Stage B3 physical *distinct-builder* arrival/worker admission remain pending; do not claim complete Stage B or integrated gameplay. Preserve Main, previous scenes/tests, local uncommitted .tres/.tscn changes, feature branch `feature/e3d5c6f-stage-a-role-contracts`, and unmerged draft PR #1. [B2 acceptance record](DRONE_ROLE_SPECIALIZATION_E3D5C6F_STAGE_B2.md). **Next gate: Stage B3**, which requires a separate guarded physical builder implementation and F6 validation.


### 2026-11-24 — E3d5c6f B2 NEW ISOLATED F6 PASSED; TARGETED COMPATIBILITY PENDING

Developer confirmed the fixed `res://tests/specialized_drone_logistics_e3d5c6f_b2_test.tscn` passed locally after an earlier `configure_b2` setup assertion at line 62 was corrected. The B2 fixture has **9 labeled printed PASS sections** in source, not a measured independent assertion count. This is **1 new isolated scene passed**, not yet complete Stage B2 acceptance. Required targeted reruns **PENDING**: B1 single-owner; Stage A role guards and material handoff; E3d5c5x5a physical pickup; E3d5c5x5b physical delivery. Developer-local report only; assistant did not execute Godot. Do not add rerun counts to unique checks. Historical E3d5c6e 63/63 suites / 880 manifest-expected checks remain previously accepted, not rerun. Keep PR #1 draft and Main untouched. Stage B3 not started.


### 2026-11-24 — B2 first local F6 failed at setup; scoped fix committed, RETEST PENDING

Developer screenshot shows `res://tests/specialized_drone_logistics_e3d5c6f_b2_test.gd:62` failed: `assert(b2.configure_b2(site, storage, staging, port, dock))`. The fixture reached this assertion; no successful B2 run or pickup confirmed. Source review identified one definite setup blocker: `PrototypeDroneStorageDiscovery.enable_isolated_discovery` and `PrototypeDroneSupplierReservations.enable_isolated_reservations` both default OFF in the E3d5c6f B1 scene, but the new B2 configurator mistakenly required them ON without enabling them. Updated `configure_b2` to enable both **only after** exact scene, original queued site, real 15-ingot Storage and pinned receiver preflights, then configure/register original services; pre-enabled or replacement authorities fail closed. No older scene/test edits. **B2 F6 must be rerun**; do not claim this fix passes Godot until user verifies. B1 3/3 accepted remains separate; historic 63/880 baseline not rerun.


### 2026-11-24 — E3d5c6f Stage B2 physical logistics IMPLEMENTED, F6 PENDING

User authorized next gated milestone after developer-local B1 **3/3 F6** acceptance. Stage B2 adds a **default-off, exact-scoped** `B2LogisticsController`, genuine existing source discovery + supplier stock claim, physically metered one-load logistics pickup, exact original staging/escrow handoff, and a narrowly guarded nonterminal **empty physical return** using the original drone's return flight. Additive opt-in scene resources and additive methods in existing drone script only; **Main and all previously accepted tests/scenes untouched**. The construction drone stays idle with no worker grant or job timer. Expected material conservation: original Storage 15→10 + five ingots original escrow, zero cargo/queued progress, logistics physically DOCKED. The nonterminal return does NOT fully rearm or charge and retains original provenance; complete multi-role custody/recovery remains future-gated.

**NEW UNRUN F6:** `res://tests/specialized_drone_logistics_e3d5c6f_b2_test.tscn` (9 printed sections, not assertion count). Targeted reruns after it passes: B1, both Stage A scenes, original physical pickup x5a and delivery x5b. See [B2 acceptance/test guide](DRONE_ROLE_SPECIALIZATION_E3D5C6F_STAGE_B2.md). No local Godot run by assistant; report first parse/assertion failure. Old **63/63 suites, 880 manifest-expected checks** remains historical accepted, not rerun here. Stage B3 **NOT** started. Work stays on feature `feature/e3d5c6f-stage-a-role-contracts`, PR #1 draft/unmerged, preserve developer local .tres/.tscn modifications.


### 2026-11-24 — E3d5c6f B1 ACCEPTED: 3/3 F6 scenes developer-local PASS

User confirmed **all three** B1 verification F6 scenes ran locally and passed without issues:
- NEW `res://tests/specialized_drone_single_owner_e3d5c6f_b1_test.tscn` — passed, 9 labeled PASS sections in source.
- Targeted Stage A regression `res://tests/specialized_drone_role_guards_e3d5c6f_stage_a_test.tscn` — passed, 6 labeled PASS sections.
- Targeted Stage A regression `res://tests/specialized_drone_handoff_e3d5c6f_stage_a_test.tscn` — passed, 7 labeled PASS sections.

**Counting:** 3/3 scenes tested at this acceptance gate, **1 new B1 fixture** and **2 already-accepted Stage A reruns**. Twenty-two labeled print sections across the three source fixtures, NOT an independently verified per-assertion count or 22 new unique checks. Developer-local pass report, not assistant-run Godot. Previously accepted E3d5c6e baseline stays **63/63 unique suites / 880 manifest-expected checks** (NOT freshly rerun for E3d5c6f). Do not represent this gate as a 66-suite combined regression.

**Scope:** guarded single-owner inert coordinator, real Hub and two distinct identity-only drone nodes; NO physical flight, material pickup/delivery, job progression, charging or Main integration. Stage B1 accepted; **NEXT is Stage B2 logistics pickup/delivery**, which has not been implemented or tested. Preserve all previous scenes/tests and developer local modified .tres/.tscn files. Continue on feature branch `feature/e3d5c6f-stage-a-role-contracts` (PR #1 draft/unmerged) until deliberate integration decision. See [B1 acceptance guide](DRONE_ROLE_SPECIALIZATION_E3D5C6F_STAGE_B1.md) and [Stage B plan](DRONE_ROLE_SPECIALIZATION_E3D5C6F_STAGE_B_PLAN.md).


### 2026-11-24 — E3d5c6f Stage B1 committed; F6 PENDING

Developer authorized B1 only: exact-opt-in single-owner, **identity-only** two-drone scene. Added guarded inert `PlayableSpecializedDronesE3d5c6f` controller, one authentic Hub, separate LogisticsDrone and ConstructionDrone nodes, and one original-resource service set. No movement, cargo, charging, job admission, escrow changes, Main wiring or old gameplay-source edits. The new F6 scene is `res://tests/specialized_drone_single_owner_e3d5c6f_b1_test.tscn` (9 labeled sections, **UNRUN**, not an assertion count). See [B1 implementation/test guide](DRONE_ROLE_SPECIALIZATION_E3D5C6F_STAGE_B1.md). Both Stage A F6 scenes remain developer-local accepted; fresh B1 and Stage A compatibility rerun are pending. Historical baseline E3d5c6e 63 suites / 880 manifest-expected checks remains previously accepted, **not rerun**. Feature branch `feature/e3d5c6f-stage-a-role-contracts`, draft PR #1 unmerged; Stage B2 not begun. Preserve local uncommitted resource files and the [F6 Copy navigator](GODOT_F6_COPY_NAVIGATOR.md).


### 2026-11-24 — E3d5c6f Stage A: BOTH ISOLATED F6 SCENES ACCEPTED LOCALLY

Developer confirmed **both newly added Godot F6 scenes passed without issues** on the `feature/e3d5c6f-stage-a-role-contracts` branch:
- `res://tests/specialized_drone_role_guards_e3d5c6f_stage_a_test.tscn` — passed (fixture contains six labeled sections).
- `res://tests/specialized_drone_handoff_e3d5c6f_stage_a_test.tscn` — passed (fixture contains seven labeled sections).

**Evidence boundary:** developer-reported successful local runs; no individual assertion transcript and no independent assistant Godot execution. Two newly accepted isolated fixtures; 13 labeled sections in source, **not** a claimed check/assertion count. Do not silently add 13 to the prior 880 manifest-expected check count or claim that 65-suite combined regression has run. Existing E3d5c6e **63/63 suites and 880 manifest-expected checks** remain the previously accepted historical baseline, **not rerun for E3d5c6f**.

The new stage only introduces exact opt-in bookkeeping and internally stored provenance receipts. **No physical two-drone motion, builder worker admission, shared charging, or Main wiring.** Seven additive files only, no accepted scene/test/source edits. Developer has uncommitted local changes to resource and scene `.tres/.tscn` files; never reset or overwrite them. Stage B **requires new explicit approval**. Keep PR #1 draft/unmerged until user requests merge. [Stage A test manifest and checkpoint](DRONE_ROLE_SPECIALIZATION_E3D5C6F_STAGE_A.md).


### 2026-11-24 — E3d5c6f proposed drone-role specialization: READ-ONLY SOURCE AUDIT COMPLETE

User requested a source-grounded GitHub review of **separate material-handling vs construction drones** after accepted E3d5c6e. Audited GitHub `main` commit **`8cb5ddd466d95d750b2d9ac9161cdfea31f109a2`**. [Detailed audit and scoped, approval-gated proposal](DRONE_ROLE_SPECIALIZATION_E3D5C6F_ARCHITECTURE_AUDIT.md) documents the blockers: accepted `PrototypeDroneAutomaticDispatch._scope_reason()` requires exactly one drone; current `_promote_delivered_worker()` requires worker to be the original cargo-delivering drone; terminal cargo rearm and cancelled-site recovery assume single owned drone/job; old E3d5c4w/z fleet tick controller is not a drop-in for later accepted physical cargo/custody system. The safe proposed approach is a **new E3d5c6f exact opt-in** role lease/immutable site-escrow handoff with **one authoritative tick owner**, one logistics drone and one physically admitted construction worker, original single job queue, real shared charging, provenance and recovery. Proposed **Stage A contracts/tests only**, Stage B physical two-drone path, Stage C custody/blackout/charging, Stage D manual playable, final fresh regression; all require separately approved implementation. No gameplay code, Main, accepted scenes or tests changed in this audit.

**Accepted baseline UNCHANGED:** E3d5c6e fully accepted Stage A 14/14, Stage B 42/42 targeted reruns (584 manifest-expected), Stage C 10/10 manual, fresh all **63/63 unique suites** reported passed locally with **880 manifest-expected checks** (no check-by-check logs). **No E3d5c6f implementation, test fixture or Godot run yet.** Preserve the one-scene-at-a-time [Copy/Previous/Next F6 navigator](GODOT_F6_COPY_NAVIGATOR.md). Future research unlocks, ore diversity, silos, coal/solar/wind, defense systems, Main promotion remain out of scope.

### 2026-11-24 — E3d5c6e FULL MILESTONE ACCEPTED: fresh combined 63/63 suites PASSED locally

Developer explicitly reports **"all 63 tests passed"** after running the [final 63-scene F6 navigator](DRONE_POWER_INTERRUPTION_E3D5C6E_FINAL_63_SUITE_REGRESSION.md) in local Godot 4.6.2. **All 63/63 unique automated suites passed in a fresh combined regression** according to developer report. The [validated manifest](../tools/drone_power_interruption_e3d5c6e_final_63_suite_regression.csv) has **880 expected checks** (prior accepted 62 suites/866 plus one new 14-check E3d5c6e isolated Stage A suite). **Individual per-assertion Output logs not furnished**; this is developer-local suite-level pass evidence and 880 manifest-expected checks, **not** independently audited assistant execution of every check.

**E3d5c6e worker-drone blackout parking/resumption FULLY ACCEPTED in the exact opt-in scene** `res://scenes/core/playable_drone_power_interruption_e3d5c6e.tscn`: Stage A isolated **14/14**, Stage B compatibility **42/42 previously existing suites** (**584 manifest-expected rerun checks**), Stage C hands-on **10/10**, and fresh final combined automated **63/63** (**880 expected checks**). Previously accepted scenes/tests and Main are preserved. System has **one original drone/dispatcher and adapter tick**, authenticated site-owned material escrow/custody, brief power flicker hold, sustained 2-second outage returning the drone to Hub on finite battery, no Hub charging while generator OFF, and return to original unfinished site with preserved construction progress/escrow. Cancellation while returning, parked, or resuming uses physically bounded original site-to-Storage recovery rather than teleporting refunds. No second logistics/construction drone classes, fleet or other power/ore systems implemented.

**No outstanding E3d5c6e verification gates remain.** This is a **documentation-only milestone closeout**, not new gameplay changes and not approval to promote the opt-in scene into Main.

**NEXT: separately scope the next playable factory/defense milestone.** Recommended first a read-only **material-handling vs construction drone role specialization architecture review** before deciding whether to implement a second drone type, or alternatively prioritize basic resources and power diversity (additional ore, coal/solar/wind). These are **future design options, not approved implementations**. Re-check actual main HEAD, [source-of-truth handoff](HANDOFF.md), [roadmap](ROADMAP.md), [drone specialization design](DRONE_POWER_INTERRUPTION_DESIGN.md), and [full closeout record](DRONE_POWER_INTERRUPTION_E3D5C6E_CLOSEOUT.md) before changes. **User preference across every chat:** one-at-a-time Godot F6 navigator with working Copy scene path and Previous/Next, [persistent convention](GODOT_F6_COPY_NAVIGATOR.md).

### 2026-11-24 — E3d5c6e Stage C 10/10 hands-on manual checks ACCEPTED locally; final 63-suite regression NEXT

Developer explicitly reports **"all 10 tests passed successfully"** while showing an in-game screenshot of the new `E3d5c6e` opt-in playable scene. **All Stage C manual checks A1–A5, B1–B3 and C1–C2 accepted as developer-local 10/10**. These cover real player Direct Build of Ammunition Press (five-ingot physical delivery), a brief power flicker (drone stays at site), sustained outage (job paused, drone returns to Hub on battery), no charge while Hub is OFF, real charging and same-worker return/resumption after power restored, one building completing from preserved progress, and cancellation while parked followed by original physical site→Storage five-ingot recovery without duplicate refund. Evidence: **developer's explicit all-ten report** plus **one partial in-game screenshot** showing an actively building Press at 30% progress, original single drone physically AT_SITE with 29.5/40 battery and 0/5 cargo, Storage 10 ingots (zero reserved), generator output 12/spare 5, and construction worker slots 1/1. Screenshot alone is **not** separate proof of later blackout/return/recovery stages, so rely on developer's manual result for those. No assistant-run Godot, extra inventory or test log provided. [Stage C 10-check manual guide](DRONE_POWER_INTERRUPTION_E3D5C6E_STAGE_C_MANUAL.md).

**Milestone status:** E3d5c6e Stage A **14/14 isolated** PASSED locally; Stage B compatibility **Wave 1 15/15 / 203 expected rerun checks**, **Wave 2 27/27 / 381**, combined **42/42 / 584 expected rerun checks** PASSED locally; Stage C **10/10 manual** PASSED locally. These are separately reported developer-local gates, not a fresh combined regression. Unique accepted automated test inventory remains **63 distinct suites / 880 manifest-expected checks** (prior fresh 62/866 + one new Stage A 14). **NEXT is fresh full combined 63-suite / 880-expected-check F6 regression**, [new verified manifest](../tools/drone_power_interruption_e3d5c6e_final_63_suite_regression.csv), [one-by-one F6 guide](DRONE_POWER_INTERRUPTION_E3D5C6E_FINAL_63_SUITE_REGRESSION.md), **NOT RUN YET**. Completion is needed before closing E3d5c6e. Do not promote Main or change accepted scenes. The original staging escrow, one dispatcher/drone update ownership and original physical custody must remain unchanged. For user-friendly tests always provide the [interactive Copy scene path / Previous / Next navigator](GODOT_F6_COPY_NAVIGATOR.md), including for future chats.

### 2026-11-24 — E3d5c6e Stage B FULL 42/42 compatibility suites ACCEPTED; Stage C manual next

Developer explicitly confirms **all tests passed** immediately after the **27-scene Wave 2 Godot F6 test navigator**. Accept **Wave 2 = 27/27 suites passed locally**, **381 manifest-expected rerun checks**. Combined with previously accepted **Wave 1 = 15/15 suites / 203 manifest-expected rerun checks**, the entire **E3d5c6e Stage B = 42/42 distinct compatibility suites passed / 584 manifest-expected checks**. This evidence is **developer-reported local suite-level passing**, not assistant-executed Godot checks or independently furnished check-by-check Output transcripts. Stage B suites are **reruns**, and add **zero** new unique tests; the accepted unique automated inventory remains **63 suites / 880 expected checks** (historical fresh 62/866 plus the new Stage A 14), while **no fresh combined 63-suite regression has yet been run**.

**NEXT: E3d5c6e Stage C hands-on playable manual verification**, [10-check guide](DRONE_POWER_INTERRUPTION_E3D5C6E_STAGE_C_MANUAL.md), exact opt-in `res://scenes/core/playable_drone_power_interruption_e3d5c6e.tscn` using Godot **F6**, real mouse/keyboard and original in-scene generator button. **Stage C is PENDING, 0/10 developer-reported** at this checkpoint. Sessions: A direct real Press placement, flicker, sustained power outage, meter-driven return/Hub OFF wait; B restored-power reflight, physical worker readmission, original progress and actual building completion; C new F6 cancel while parked and original five-ingot physical site→Storage recovery, no duplicate return. [Godot Copy/Previous/Next navigator convention](GODOT_F6_COPY_NAVIGATOR.md) remains mandatory. After Stage C 10/10, stage **final fresh combined 63 suites / 880 manifest-expected checks**, then close milestone. **No gameplay code, previously accepted scenes or Main changed in this acceptance/documentation checkpoint.**

### 2026-11-23 — E3d5c6e Stage B Wave 1 15/15 suites ACCEPTED locally; Wave 2 NEXT

Developer reports **"All tests passed"** immediately following the **15-scene E3d5c6e Stage B Wave 1** one-scene-at-a-time F6 navigator. Interpret as **Wave 1 15/15 F6 suites passed** locally, **203 manifest-expected checks** (the developer did not supply individual Output transcripts or per-check log). Wave 1 covered new E3d5c6e Stage A repeat (14), existing scene/authorization/priority tests (155 minus duplicate? actual 12 scenes/155, including old unified 16), and two dedicated construction-power fixtures (16+18), as recorded in the [42-scene E3d5c6e Stage B manifest](../tools/drone_power_interruption_e3d5c6e_stage_b_compatibility.csv). These are **reruns**, zero additional unique automated checks. The accepted unique inventory remains **63 distinct suites / 880 expected checks** (historical final 62/866 plus new accepted Stage A 14); **a fresh combined 63-suite run has NOT occurred**.

**NEXT: E3d5c6e Stage B Wave 2** — **27 existing F6 scenes / 381 manifest-expected checks**, covering original physical drone, battery, charging, supplier/return reservations, pickup/delivery, staging/escrow, cancelled-site custody, recovery and Direct Build. [Stage B guide](DRONE_POWER_INTERRUPTION_E3D5C6E_STAGE_B_COMPATIBILITY.md). **Wave 2 has NOT yet been reported run**, so full Stage B 42/42 must not be claimed. Retain the mandatory [interactive Copy scene path / Previous / Next test navigator](GODOT_F6_COPY_NAVIGATOR.md). After Wave 2 local acceptance, separate Stage C real playable manual F6 and eventual fresh 63/880 combined regression. Do not change accepted Main/old scenes/tests or add a competing drone tick/dispatcher.

### 2026-11-23 — E3d5c6e Stage A 14/14 ACCEPTED locally; Stage B 42-suite compatibility STAGED

Developer explicitly confirmed **all 14/14 E3d5c6e Stage A F6 checks A–N passed locally in Godot 4.6.2**, following implementation `e0d63fc` and final test-guide adjustments `4020b6e`. These are **developer-reported local checks**, not assistant-executed; individual Output log was not supplied. E3d5c6e original one-drone construction-power blackout parking now has an accepted isolated fixture for generator flicker, 2-second outage, finite same-drone Hub return and zero OFF-power charge, original escrow/progress-preserving resume, and physical custody-safe cancellations while returning, parked or resuming. No legacy scenes/test fixtures or Main were edited. **Cumulative distinct accepted automated inventory is now 63 suites / 880 manifest-expected checks (previous fresh 62 suites / 866 plus new one 14)**; there is **NO fresh full 63-suite combined run yet**.

**NEXT: E3d5c6e Stage B compatibility** in two separated F6 rerun waves, [guide](DRONE_POWER_INTERRUPTION_E3D5C6E_STAGE_B_COMPATIBILITY.md), [manifest](../tools/drone_power_interruption_e3d5c6e_stage_b_compatibility.csv): **Wave 1 = 15 distinct suites / 203 manifest-expected checks**, includes current Stage A 14, prior 12 scene/scope/authorization tests (155), and two dedicated power tests (16+18). **Wave 2 = 27 suites / 381 checks**, exactly the accepted earlier E3d5c6d Stage B Wave 2 for physical drone/cargo/staging/charging/cancellation compatibility. **Combined target 42 suites / 584 expected checks, all are reruns; not executed under new E3d5c6e code at this checkpoint**. Never double count these as new unique automated suites. Stop at first Godot red failure and repair narrowly. Later Stage C real playable manual verification and fresh full **63/880** regression before milestone closeout. Preserve [one-at-a-time Godot F6 Copy/Previous/Next navigator](GODOT_F6_COPY_NAVIGATOR.md), exact new playable scene, and original Main isolation.

### 2026-11-23 — E3d5c6e Stage A single-worker blackout parking CODE STAGED (F6 NOT RUN)

Developer **explicitly approved** the source-grounded [E3d5c6e architecture](DRONE_POWER_INTERRUPTION_ARCHITECTURE_AUDIT.md). Implementation is staged as a **NEW exact-scoped** F6 scene `res://scenes/core/playable_drone_power_interruption_e3d5c6e.tscn`, subclassing the already accepted Stage C recovery adapter with its **single existing `_process`**. The original drone and original `PrototypeDroneAutomaticDispatch.tick()` are extended via two **default-OFF plus exact scene-name checked flags**: only an admitted original worker on a physically delivered, escrowed, POWER-paused site may leave after **2.0 seconds** continuous outage; the original battery-metered RETURNING/DOCKED/OUTBOUND states park at the Hub and return after legitimate power/route eligibility. Original site, authorization, priority, immutable owned staging, escrow and elapsed progress are preserved; no second material pickup or fake charging; generator-OFF Hub charge 0. Cancellation on the return/park/reflight routes uses original terminal rearm and physical locked-site-to-Storage recovery. New scene-specific WorldInteraction, custody audit, and recovery adapter-identity allowlist branches are additive. No new drone, dispatcher, queue, worker, timer or Main activation. **Previously accepted E3d5c6b/E3d5c6c/E3d5c6d scenes and their tests were not modified.**

**NEW ISOLATED local F6 acceptance required:** `res://tests/playable_drone_power_interruption_e3d5c6e_stage_a_test.tscn`, **14 A–N proposed grouped checks, NOT YET EXECUTED**. [Stage A F6 instructions and full checks](DRONE_POWER_INTERRUPTION_E3D5C6E_STAGE_A.md). Expected end banner: `ALL 14 E3D5C6E STAGE A POWER INTERRUPTION TESTS PASSED`. Fixture creates sequential playable exact-scene instances, ticks **ONLY adapter `_process(0.1)`**, tests original material and power, flicker/delay, finite return, OFF Hub waiting, power restoration, original resumed worker/time, successful completion, cancellation while returning/parked, interrupted outbound resume and insufficient-energy conservative hold. **Only developer local F6 results may establish acceptance; no assistant Godot test executed**. The previous accepted full baseline stays **62/62 suites PASSED / 866 manifest-expected checks**; new 14 is not yet accepted and should NOT be counted as 63/880 until user verifies. On first parse/assert error stop and provide exact first red error and preceding PASS messages. Then do independent targeted legacy compatibility and separate real F6 manual gameplay before final fresh combined rerun. Preserve user's [one-scene Copy, Previous, Next navigator](GODOT_F6_COPY_NAVIGATOR.md) in this and future chats.

### 2026-11-23 — E3d5c6e Power-Outage Worker Parking ARCHITECTURE AUDIT COMPLETE (implementation pending)

After full developer-confirmed E3d5c6d 62/62 acceptance, source-audited the current **one tick owner**, drone `AT_SITE`/RETURNING/DOCKED/OUTBOUND movement and finite battery, construction scheduler worker-presence validation, real power allocator, original material escrow and cancellation recovery. Full grounded audit and proposed exact opt-in implementation: [DRONE_POWER_INTERRUPTION_ARCHITECTURE_AUDIT.md](DRONE_POWER_INTERRUPTION_ARCHITECTURE_AUDIT.md). **Critical:** do not call worker `_on_site_ended` for a healthy PAUSED job, or terminal docked rearm while still assigned; preserving exact `is_at_site()` worker eligibility and original escrow/site custody permits safe Hub parking and later resume without duplicate delivery. Proposed future `E3d5c6e` scene is not yet created; **no gameplay source, accepted scenes or tests changed**. Suggested 2-second sustained outage debounce, bounded return, actual Hub charging, original worker re-admission on physical return, cancellation in every flight/park phase. Separate specialized logistics and construction drone roles deferred. F6 test navigator requirement remains persistent. This is a **documentation-only audit checkpoint**, not an approved/accepted Stage A implementation.

### 2026-11-23 — E3d5c6d FULL MILESTONE ACCEPTED: fresh combined 62/62 automated suites PASSED locally

Developer explicitly confirmed **"all 62 tests passed"** after executing the final [62-scene combined F6 guide](UNIFIED_CONSTRUCTION_E3D5C6D_FINAL_62_SUITE_REGRESSION.md) with Godot 4.6.2 Stable. **All 62/62 unique automated suites passed in one fresh local regression**; the validated [62-suite manifest](../tools/unified_construction_e3d5c6d_final_62_suite_regression.csv) specifies **866 expected checks (850 historical plus 16 E3d5c6d Stage A)**. Individual suite-by-suite Output logs/check-by-check transcripts were **not provided**, so **866 is the expected assertion inventory for the 62 reported passed suites**, not independently reviewed 866/866 log evidence. This is **developer-reported local testing, not assistant-executed**. No double counting of earlier Stage B 39/536 targeted compatibility reruns, historical supplementary suites, or manual checks.

**E3d5c6d Unified Construction Gameplay Integration FULLY ACCEPTED in exact opt-in experimental scene** `res://scenes/core/playable_unified_construction_e3d5c6d.tscn`: Stage A isolated **16/16**; Stage B **39/39 compatibility suites, 536 manifest-expected rerun checks**; Stage C **10/10 hands-on checks**; now fresh full **62/62** regression (866 manifest-expected checks). Accepted behavior: Direct Storage and Press build, Blueprint PLANNED until E/Ctrl+E, original priority/FIFO and no worker preemption, one physical drone/sole adapter tick, real site-owned staging and immutable cancellation custody, no free material/refund, original power/finite battery/charging and same-drone physical recovery. **Main and previously accepted E3d5c6b/E3d5c6c scenes/tests remain unchanged.** No code edits occurred in this closeout (documentation-only checkpoint). There is no pending acceptance test for E3d5c6d.

**NEXT decision: separate NEW milestone for worker-drone Hub parking during sustained construction-power outage.** See [Design proposal](DRONE_POWER_INTERRUPTION_DESIGN.md); preserve delivered materials and original job/escrow/site custody while the battery-powered drone flies home, pauses, and later returns/resumes when safe. **Design proposed only, not yet gameplay-implementation approval.** A later second-role system (logistics drones vs construction drones) is also future design, not part of E3d5c6d. Do not add multibot, research, ore, coal/solar/wind, new silo or unscoped Main changes while proposing this next milestone. Read authoritative main source and verify new HEAD before new coding. **Developer-required cross-chat F6 test UI:** one-at-a-time navigator with working Copy scene path, Previous/Next, progress and correct test scene path, documented in [GODOT_F6_COPY_NAVIGATOR.md](GODOT_F6_COPY_NAVIGATOR.md).

### 2026-11-23 — E3d5c6d Stage C manual 10/10 ACCEPTED; design idea for future drone blackout parking

Developer explicitly reports **all ten unified Stage C hands-on gameplay checks A1–A4, B1–B3 and C1–C3 passed** in local Godot 4.6.2 after Stage B targeted compatibility **39/39 suites** (536 manifest-expected checks) and Stage A isolated **16/16** accepted. The new playable `res://scenes/core/playable_unified_construction_e3d5c6d.tscn` has thus passed **manual Direct Storage/Press authorization, actual build/power pause-resume, Blueprint planned/E/Ctrl+E permission, High priority, physical cancelled-site return of 3/5 ingots, finite charging and no duplicate return**, by **developer report**, not assistant-run tests. No new screenshots or individual manual checkpoint transcript supplied at this acceptance turn; preserve this evidence distinction. **Stage C manual gate is closed 10/10.** Accepted unique automated baseline **62 distinct suites / 866 manifest-expected checks**, including one new 16-check E3d5c6d suite, but **fresh all-62 suite regression NOT YET RUN**. Do not conflate 39/536 compatibility reruns or ten manual actions with new unique automated checks.

**New player-reported future design question:** when generator power fails after construction material has been physically unloaded, should the builder drone return to Hub and later resume, and should material transport and construction be split into different drone classes? **Recommendation for separate milestone ONLY; not approved gameplay modification:** With a sustained construction power loss, preserve physical site escrow/inventory and PAUSED job/progress; the **same construction worker drone safely returns to Hub using reserved finite flight energy** and remains assigned/blocked from duplicate work, does not make a second delivery, and only flies back to resume when original power/worker conditions and route battery are restored. Never start progress while remote. If the drone is still physically carrying stock, preserve real custody and safe return/recovery separately (no teleport). Reuse ONE original update owner, queues, immutable staging locks, and cancellation/return reservations. Long-term, player can unlock **separate material-handling/logistics drones** and **construction/assembler drones**, sharing the same registry/queues but with distinct explicit jobs; **do not add fleet or second driver now**. See [Drone power-interruption design proposal](DRONE_POWER_INTERRUPTION_DESIGN.md). **NEXT: Stage D final fresh combined 62/866 F6 regression**, not yet run; do not promote Main until it passes and milestone documented. Preserve [Godot F6 Copy navigator](GODOT_F6_COPY_NAVIGATOR.md) in future chats.

### 2026-11-22 — E3d5c6d Stage B FULL targeted compatibility 39/39 ACCEPTED; Stage C manual next

Developer explicitly reported **all 27/27 Wave 2 test scenes passed locally** in Godot after previously confirming **Wave 1 12/12**. From the [checked Stage B manifest](../tools/unified_construction_e3d5c6d_stage_b_compatibility.csv): Wave 1 **12 existing/accepted suites / 155 expected checks**, Wave 2 **27 existing/accepted suites / 381 expected checks**, combined **39/39 distinct suites passed locally / 536 manifest-expected checks**. User confirmed suite-level success; assistant did not run Godot or inspect check-by-check Output. These compatibility reruns are **not** additional unique test suites or new checks. Unique accepted automated baseline remains **62 suites / 866 expected checks**, with **no fresh complete 62-suite combined regression performed**. No gameplay source, Main, accepted scenes/tests, tick owners or material custody mechanisms changed for this gate.

**NEXT — E3d5c6d Stage C manual unified gameplay (new opt-in scene):** [10-check hands-on guide](UNIFIED_CONSTRUCTION_E3D5C6D_STAGE_C_MANUAL.md), `res://scenes/core/playable_unified_construction_e3d5c6d.tscn`, local F6 mouse/keyboard **PENDING**. Test Direct Storage and Press construction 15→7, generator pause/resume, strictly PLANNED Blueprints until E/Ctrl+E, priority/H queue without auto-authorization, actual delivered Storage/Press cancellation 12→15 and 10→15 only through original same-drone physical site→Storage return, finite recharge/no double return, and no new Main behavior. Use the [persistent Godot F6 Copy navigator convention](GODOT_F6_COPY_NAVIGATOR.md) in every new chat. After manual acceptance, prepare fresh full **62-suite / 866-expected-check** combined regression separately; don't mark it accepted until locally run.

### 2026-11-22 — E3d5c6d Stage B Wave 1 12/12 ACCEPTED locally; Wave 2 next

Developer explicitly reports **all twelve Stage B Wave 1 F6 scenes passed locally** in Godot 4.6.2. The twelve distinct scenes include unified Stage A (16), accepted original recovery Stage C (14), and ten older scope/placement/blueprint authorization/priority/receiver compatibility suites (125): **12/12 suites accepted, 155 expected checks** per reviewed [Stage B manifest](../tools/unified_construction_e3d5c6d_stage_b_compatibility.csv). Screenshot shows the final **Test 12 of 12 / Blueprint Click Inspection / 16 expected checks** in the copy-button navigator; independent scene-by-scene Output transcripts were not supplied. This is **developer-reported local F6 verification**, not assistant runtime testing. **Wave 2 (27 suites / 381 expected checks) remains unrun under E3d5c6d**, and Stage B combined 39/39 is NOT yet accepted. All reruns overlap existing/supplemental tests; unique milestone baseline stays **62 suites / 866 expected checks**, not a fresh combined 62-suite run.

**Critical user-requested cross-chat testing workflow preference:** In *every future Industrial Warfare development chat*, present Godot scene/test paths using the same **interactive one-at-a-time Copy scene path navigator** (test number N of total, short friendly title, exact `res://tests/*.tscn` or `res://scenes/core/*.tscn` path, expected checks, obvious **Copy scene path** control using direct copy action, **Previous** and **Next test** buttons, progress bar, and remembered position within the current chat). Include manual playable scenes with a copy control too; avoid replacing this with a hard-to-copy giant raw list. The request is from the developer, who confirmed this exact format **works great**. Rebuild controls in each new chat from the current checked manifest; don't claim UI state persists across chats. **Source of truth:** [Godot F6 copy navigator preference](GODOT_F6_COPY_NAVIGATOR.md). This preference is part of the handoff, not a gameplay-code change.

### 2026-11-22 — E3d5c6d Stage B compatibility gate STAGED (not yet executed)

Following developer-confirmed **Stage A 16/16 isolated F6 acceptance**, stage **two sequential existing-test waves** with no gameplay/test-source changes. [Stage B guide](UNIFIED_CONSTRUCTION_E3D5C6D_STAGE_B_COMPATIBILITY.md) and [CSV manifest](../tools/unified_construction_e3d5c6d_stage_b_compatibility.csv) cover **39 distinct accepted scene files / 536 expected checks**. **Wave 1: 12 suites / 155 checks**, comprising new E3d5c6d Stage A 16, accepted old E3d5c6c Stage C 14, and ten old supplemental scope/placement/authorization/priority scene checks 125. **Wave 2: 27 suites / 381 checks**, exactly the accepted E3d5c6c Stage C targeted compatibility set (physical drone, staging, power, custody, escrow, reservation and recovery). Source paths/counts were validated against current repository tree and original CSV; no F6 checks executed by assistant and no developer Stage B results yet. **These are reruns, zero new unique automated checks**, so the accepted unique inventory remains 62 suites/866 expected checks, with no fresh full combined 62-suite rerun yet. Keep Main, accepted old scenes/tests, one authoritative adapter tick and exact original material custody unchanged. On first Godot red error halt and report failure. When BOTH waves pass, proceed to separate Stage C manual playable scene and eventually final combined regression.

### 2026-11-22 — E3d5c6d Stage A isolated F6 16/16 ACCEPTED (developer-local)

Developer explicitly confirmed **all 16/16 new E3d5c6d Stage A automated F6 checks A–P passed** in Godot locally after the staged commit `deb619d`. This validates the new exact-scoped unified scene's observed automated test assertions for original Direct Build/Blueprint authorization, shared queue and one tick owner, physical material transfer, power/charging, and pre-pickup, loaded, delivered, working and return-capacity cancellation. This is **developer-reported local execution, not assistant-run testing**; no individual Output transcript supplied. Preserve all accepted legacy Main and E3d5c6b/E3d5c6c scenes and fixtures. The unique accepted automated inventory is now **62 suites / 866 planned checks**, consisting of the previously accepted 61-suite/850-expected-check baseline plus this **one new 16-check suite**; this is **not a fresh full 62-suite regression**. Stage B targeted compatibility and Stage C manual playable confirmation remain **pending**, not passed. For hands-on F6, open `res://scenes/core/playable_unified_construction_e3d5c6d.tscn`; the 16-check automated fixture is `res://tests/playable_unified_construction_e3d5c6d_stage_a_test.tscn`. See [Stage A guide](UNIFIED_CONSTRUCTION_E3D5C6D_STAGE_A.md).

### 2026-11-22 — E3d5c6d Stage A IMPLEMENTATION STAGED (local F6 PENDING)

Developer approved **E3d5c6d Unified Construction Gameplay Integration** after actual main source audit. A **new exact-scope playable scene** `res://scenes/core/playable_unified_construction_e3d5c6d.tscn` reuses the **existing Stage C adapter script and its ONE authoritative `_process`**. It adds no new dispatcher, drone, tick controller, scheduler, worker or inventory transport. Four narrow allowlist changes are restricted to `scripts/world_interaction.gd`, the existing Stage C adapter, `prototype_cancelled_site_custody_audit.gd`, and `prototype_cancelled_site_recovery_transport.gd`. Main, original E3d5c6b/E3d5c6c playable scenes and all previously accepted test fixtures are untouched.

**NEW Stage A local F6 gate:** `res://tests/playable_unified_construction_e3d5c6d_stage_a_test.tscn`, **16 proposed automated groups A–P; NOT yet run/accepted**. Expected final banner `ALL 16 E3D5C6D STAGE A UNIFIED CONSTRUCTION TESTS PASSED`. Covers scene isolation, original queue/sole tick, Direct Press/Storage and planned High Blueprint, explicit authorization without preemption, actual physical 5/3-ingot logistics, finite power pause/resume, 18/10-second construction, Hub charging, cancellation at pre-pickup / loaded / delivered / working states, exact original staging/escrow recovery, full Storage wait/retry, and no duplicate recovery. Fixture manually drives **only original playable adapter `_process(0.1)`**, never child dispatch/recovery ticks. See [Stage A F6 guide](UNIFIED_CONSTRUCTION_E3D5C6D_STAGE_A.md). **Assistant has not executed Godot. Do not mark Stage A accepted until developer confirms all 16 local checks.** If Godot stops early, capture first red error and preceding PASS lines; fix narrowly. Historical **61/61 locally accepted suites / 850 manifest-expected checks** remain the last verified full regression. Stage B targeted compatibility and Stage C manual playable checks follow after Stage A acceptance. No new ore/power generation, multi-drone, research, silos or new docking features in scope.

### 2026-11-22 — FRESH COMBINED 61/61 automated regression ACCEPTED (850 expected checks; full baseline verified)

Developer explicitly reported **"All 61 tests passed successfully"** after running the complete [combined F6 guide](INDUSTRIAL_WARFARE_COMBINED_61_SUITE_REGRESSION.md) in local Godot 4.6.2 Stable. All **61/61 suites passed locally** in a fresh combined sequence after E3d5c6b original manual 10/10 and E3d5c6c recovery manual 10/10. The manifest `tools/industrial_warfare_combined_61_suite_regression.csv` is independently verified to contain **61 distinct test scenes, 850 expected checks**, calculated from 56 prior suites /785 checks plus E3d5c6b 11+14 and E3d5c6c 13+13+14. The developer reported **suite-level success** rather than supplying each suite's Output log or separately restating 850/850; **850 is the expected total for the passed suite inventory**, not an independently reviewed check-by-check transcript. This is **developer-reported local execution, not assistant-run testing**. The accepted unique automated baseline remains **61 suites / 850 checks** (not additive to overlapping compatibility reruns). The *fresh combined regression gate is now accepted*, instead of merely a cumulative set of earlier individual acceptances.

**NEXT — E3d5c6d candidate: opt-in unified construction gameplay integration, DESIGN/IMPLEMENTATION NOT YET STARTED.** Consolidate the accepted Direct Build Authorization and automatically cancelled-site physical recovery into a separate experimental playable scene before any Main gameplay promotion. Preserve existing Main, original E3d5c6b and E3d5c6c accepted scenes/tests and single original drone/sole tick owner, explicit Blueprint E/Ctrl+E authorization, Direct Build Normal authorization, material provenance/staging escrow, original protected cancellation ticket, Storage destination capacity reservations, finite drone movement/energy/docking and conservative waits. Gate design review, new isolated F6 checks, targeted old regression and actual manual playable tests separately. Do **not** assume research silos, multiple drones, storage docking stations, multi-trip loading, auto conveyor changes or new combat behaviors are already implemented. No gameplay source changed at this checkpoint.


### 2026-11-22 — E3d5c6b original Direct Build Stage C manual 10/10 ACCEPTED; fresh combined 61/850 next

Developer explicitly confirmed **all ten original E3d5c6b Stage C manual tests passed locally in Godot 4.6.2** after running the old dedicated `res://scenes/core/playable_direct_build_authorization_e3d5c6b.tscn` verification guide. Acceptance covers **A1–A6** (powered Direct Storage/Press placement, invalid/overlap rejection, generator-OFF construction pause and ON resume, actual finished structures and 15→7 inventory), **B1–B3** (unapproved Blueprint plans, Q selection H priority not authorizing, E/Ctrl+E permissions, one worker/shared queue and 15→4 after three planned jobs), and **C1** (cancel Press **while the drone still carries five ingots before site unloading**, physical return 15/15 and rearm). This is **developer-reported manual execution**, not an assistant-run test or a separately supplied screenshot set. Do not confuse old E3d5c6b **loaded-cargo** cancellation with later E3d5c6c **post-delivery staged-material** recovery; both isolated milestones are now manually accepted. Previously accepted E3d5c6c recovery manual 10/10 remains unchanged.

**NEXT — fresh combined regression 61 suites / 850 checks PENDING** on current `main`, documented in [combined F6 guide](INDUSTRIAL_WARFARE_COMBINED_61_SUITE_REGRESSION.md) and `tools/industrial_warfare_combined_61_suite_regression.csv`. Constructed from the verified original 56 suites /785 checks plus five distinct later isolated suites (Direct Build 11 + 14 and Cancelled-Site 13 + 13 + 14 = 65); all 61 scene paths exist and are distinct. **Unique accepted milestone baseline is already 61/850**, but there is no confirmation of a new complete 61-suite pass after the latest code. Historical targeted compatibility reruns are overlapping and not additive; manual tests are separate. Do NOT mark fresh combined regression passed until user specifically reports 61/61 and 850/850 local outcomes. After that, plan a new opt-in construction integration milestone, preserving single-drone real flights, power/escrow/custody, and original scenes/Main untouched.


### 2026-11-21 — E3d5c6c Stage C B3 ACCEPTED — FULL MILESTONE CLOSEOUT (14/14 isolated, 27/381 compatibility, 10/10 manual)

Developer provided a four-screenshot **real playable** Press recovery sequence concluding with `AUTOMATIC CONSTRUCTION — WAITING`, drone **IDLE**, battery **40.0/40.0**, cargo **0/5**, `Rearms: 3`, `Recovery: WAITING / IDLE | tickets 2 | recovered 1`, Starter Storage **12 ingots**, generator ON (Hub output 12) and all queue/building counts zero. Intermediate screenshots show a Press under construction **15% paused** with generator OFF (`Hub output 0`, `Waiting: power, workers`), later **DOCK WAIT** with partially charged drone **30.9/40** while generator OFF, then a fully returned unloaded `Recovery: ACTIVE ... staged 5` at battery **34.5/40** with Storage **12** and generator OFF, and finally the completed charged/rearmed single drone. Earlier developer confirmation explicitly established **battery charging remains stopped while generator OFF**, which, together with the current terminal full recharge/rearm evidence, satisfies manual **B3**. **Do not infer an uninterrupted generator-OFF battery-hold interval from these distinct intermediate screenshots alone:** different intermediate battery readings could include generator toggles between captures; the hold finding is grounded in the earlier explicit local confirmation, not a continuous video.

**Material conservation across two jobs:** Starter Storage begins **15** ingots; previously completed Storage spends **3** (no refund); attempted Ammunition Press delivery spends **5** and its post-delivery cancellation physically returns **5** via the original one drone, yielding **15−3−5+5=12**. Two custody tickets (`tickets 2`) are therefore expected; only the Press cancellation is a successful recovery (`recovered 1`), so `recovered 1` is **one mission**, not one ingot. The extra rearm count 3 likewise represents construction/recovery lifecycle completion, not duplicate inventory return.

**E3d5c6c Stage C manual 10/10 ACCEPTED**, all A1–A5, B1–B3, C1–C2. Stage C isolated **14/14 new checks** and targeted compatibility **27/27 prior suites / 381/381 rerun checks** were previously confirmed locally; **E3d5c6c Stage C FULLY ACCEPTED** within the **opt-in experimental playable scene** `res://scenes/core/playable_cancelled_site_recovery_e3d5c6c_stage_c.tscn`. Developer-reported live tests and screenshots, not tests run by assistant. **Unique accepted automated milestone baseline remains 61 suites / 850 checks** (manual and overlapping reruns not counted); no claim of fresh full combined 61/850 run. The *older* E3d5c6b Direct Build manual 10-check gate remains independently pending; Main and original Direct Build scene are not modified to use Stage C recovery. No new code changes in this documentation acceptance update.

**Next recommended development gate:** consolidate and harden opt-in playable recovery after documenting outstanding separate Direct Build E3d5c6b manual verification; do not silently replace Main, add multi-drone/storage dock/silo behaviors, release immutable custody locks, or bypass inventory/power.


### 2026-11-21 — E3d5c6c Stage C manual C2 FULLY ACCEPTED; manual total 9/10

Developer explicitly **confirmed** that *before pressing E* the newly placed Storage blueprint remained **PLANNED**, Starter Storage stayed at **15 Test Ingots**, and the drone remained **IDLE** without dispatch/material debit. The later developer-provided playable screenshot after explicit E showed **one Storage BUILDING/CONSTRUCTION job at 9%**, the drone **AT SITE**, worker slots **1/1**, and Starter Storage **12 ingots** after the authorized three-ingot delivery. Both halves of manual **C2 passed**: no auto-authorization of a planned blueprint, and player E triggers the existing physical construction workflow. This is a developer-reported local manual pre-E observation plus post-E screenshot evidence; not an assistant-run test.

**Stage C manual acceptance advances to 9/10**: A1–A5 (Storage physical recovery/settlement), B1–B2 (Press five-ingot return), C1 (completed Storage spends 3, no return), C2 (Blueprint requires E). **Only B3 remains pending**: in a fresh Press cancellation recovery, demonstrate generator-OFF halts charging while the drone is partly discharged at the Hub, then ON resumes finite charging, reaching **40/40**, **IDLE**, `Rearms 2`, `Recovery WAITING / IDLE | tickets 1 | recovered 1`, Storage 15, cargo 0 and no duplicate recovery. Prior Press screenshot at 39.3/40 showed Storage already 15 but `Recovery ACTIVE`; do not count B3 until the terminal state is confirmed. Stage C isolated tests **14/14** and targeted compatibility **27/27 suites, 381/381 rerun checks** accepted. Unique cumulative automated baseline remains **61 suites / 850 checks**; manual checks are separate and the fresh full 61/850 combined run has not been claimed.


### 2026-11-21 — E3d5c6c Stage C manual C2: post-authorization Blueprint construction observed; pre-E gate still unconfirmed

Developer supplied a live Stage C playable screenshot while testing **C2 (Blueprint permission)**. HUD shows **Factory Blueprints Building 1, Planned/Queued 0; Automatic Construction — CONSTRUCTION; drone AT SITE, Job progress 9%; Starter Storage 12 ingots / 0 reserved; Worker slots 1/1; drone battery 34.0/40.0, cargo 0/5; Recovery WAITING/IDLE, tickets 1, recovered 0**. The construction site and drone are visible at the Storage guide. This **confirms the authorized construction half** of C2: one Storage construction is active and three ingots have been physically debited from the initial 15 stock. The screenshot alone **does not show whether the site stayed merely PLANNED and stock 15/drone idle before pressing E**, so authorization gating is **not yet independently verified** from this image; do not mark full C2 accepted.

**Manual gate remains 8/10 accepted** (A1–A5, B1–B2, C1). **C2 pre-authorization observation pending**, plus **B3 Press-specific terminal recharge/rearm**. Next ask only whether, before E, the blueprint remained PLANNED and Starter Storage stayed 15 with drone idle; if confirmed, mark C2 accepted and advance to 9/10. Automated baseline **61 suites/850 checks**, targeted compatibility **27/27 suites and 381/381 rerun checks**, unchanged. No gameplay code modified.


### 2026-11-21 — E3d5c6c Stage C manual C1 ACCEPTED: completed Storage consumes 3 ingots, no recovery

Developer supplied live playable-scene screenshot of a **finished additional Storage building** (circled), alongside the original Starter Storage and one idle construction drone. HUD shows **Starter Storage 12 ingots / 0 reserved**, `IDLE`, battery **40/40**, cargo **0/5**, `Rearms: 1`, planned/queued/building/paused all zero, and `Recovery: WAITING / IDLE | tickets 1 | recovered 0`. This matches the intended **15−3=12 ingot** committed build cost and confirms **no cancelled-site recovery was launched** for a completed site. A retained custody ticket count of 1 is not itself a recovery mission. Screenshot is developer-provided local manual evidence, not an assistant-run Godot test. **Manual C1 accepted.**

**Stage C manual checkpoint advances from 7/10 to 8/10:** A1–A5, B1–B2 and C1 accepted. **B3 pending** (Press-specific return completes Hub recharge/rearm with recovered 1 and no duplicate); **C2 pending** (unapproved Blueprint does not dispatch/debit, explicit E authorization does). Other local automated acceptance remains 14/14 isolated plus 27/27 targeted compatibility (381/381 reruns), with **61 unique suites / 850 checks**. No new code or automated test change.


### 2026-11-21 — E3d5c6c Stage C manual: Storage recovery and generator-OFF hold explicitly confirmed by developer

Developer's follow-up, **"this is confirmed working,"** confirms the immediately requested checks: the observed **three-ingot physical return** completes after the STAGED TO STORAGE flight, restoring Starter Storage from **12 → 15 ingots** with the recovery mission settled (**recovered 1**, drone returned **IDLE**, battery **40/40**), and a partly charged drone's battery does **not** increase while the generator remains OFF over the observed interval. Earlier live screenshots showed the in-flight **cargo 3/5** (Storage still 12), Hub **output 0** with generator OFF and a partially charged docked drone, and completed Direct Storage/Blueprint Storage recovery end states. This explicit developer report supplies the final outcomes that the prior screenshots alone did not show. It is **developer-reported local manual verification, not an assistant-executed test or new screenshot of the final moment**.

**Manual checkpoint:** Stage C Session A (A1–A5) is accepted from cumulative live evidence and the developer's confirmation. The earlier developer-confirmed five-ingot Direct Ammunition Press cancellation with actual returned Starter Storage stock **15** supports Session B B1/B2; B3's Press-specific complete recharge/rearm and no-duplicate observation remains pending (last Press screenshot was `DOCKED`, battery **39.3/40**, `Recovery ACTIVE`, `recovered 0`). **Seven of ten manual checks are now recorded accepted (A1–A5, B1–B2); B3, C1, C2 remain open.** The generator-OFF battery-hold behavior is independently confirmed, but does not by itself complete the separate Press B3 rearm requirement. Do not claim full 10/10 manual milestone acceptance yet.

**NEXT:** (1) Confirm Press's terminal `Recovery WAITING / IDLE | recovered 1` with battery 40/40 and original stock 15 (B3); (2) fresh F6, allow a Direct Storage building to actually complete, verify it spends three ingots (15→12) and **does not recover** committed building materials (C1); (3) fresh F6, place an unapproved Blueprint Storage and prove no pickup until E authorizes it (C2). No gameplay source changed. Existing automated Stage C 14/14 + compatibility 27 suites/381 rerun checks remain accepted; unique suite baseline **61/850** unchanged.


### 2026-11-21 — E3d5c6c Stage C live power-off and 3-ingot return in flight (partial manual evidence)

Developer supplied two additional real playable-scene screenshots, showing **distinct mid-cycle states**:

- **Power-off dock state:** `AUTOMATIC CONSTRUCTION — DOCK WAIT`, drone `DOCKED`, **battery 33.6/40.0**, cargo **0/5**, `Hub output 0 | Spare 0`, generator button `Turn generator ON (test)`, Starter Storage **12 ingots**, `Job progress: 32%`, `Recovery: WAITING / IDLE | tickets 1 | recovered 0`, Rearms 0. This visually confirms generator OFF means zero Hub output, with a partially charged drone docked; a single frame **does not prove battery stayed fixed over time** or confirm construction progress did not advance over an interval.
- **Active original-site physical recovery:** `AUTOMATIC CONSTRUCTION — STORAGE FLIGHT`, drone `STAGED TO STORAGE`, **cargo 3/5**, battery **36.1/40.0**, Starter Storage still **12 ingots**, `Recovery: ACTIVE | tickets 1 | recovered 0 | staged 3`, Rearms 1, Hub output 12. This directly shows a three-ingot cargo trip before Storage unload—**not** the five-ingot Press test—and no instant Storage credit in that captured frame.

These screenshots strengthen earlier Direct Storage/Blueprint Storage observations by showing **in-flight cargo and finite battery** rather than only a settled end HUD. They do **not** show recovered 1 / idle / restored 15 for this particular displayed 3-ingot flight, nor two elapsed generator-off observations, and cannot alone complete the formal manual A1–A5/B1–B3/C1–C2 gate. Keep those missing observations open. The previously shown Press 5-ingot unload at Storage 15 but `Recovery ACTIVE` also still awaits final IDLE/recovered 1 evidence. All 14/14 new automated checks and Stage C 27/381 targeted compatibility remain accepted; cumulative unique **61 suites / 850 checks** unchanged. No gameplay scripts changed as part of this documentation update.


### 2026-11-21 — E3d5c6c Stage C live Direct Build Ammunition Press (5 ingots): dock unload confirmed; final rearm still in progress

Developer supplied two Godot 4.6.2 live playable screenshots and reports the Press cancellation completed successfully. Godot Output shows `Selected building: Prototype Ammunition Press`, `BLUEPRINT AUTHORIZED: Prototype Ammunition Press`, `DIRECT BUILD AUTHORIZED: Prototype Ammunition Press | Normal priority`, `BLUEPRINT CANCELLED`. **Direct Build**, not merely Blueprint mode, is confirmed.

At the exact captured moment the HUD shows `AUTOMATIC CONSTRUCTION — CHARGED`, drone **DOCKED**, battery **39.3/40.0**, cargo **0/5**, **Starter Storage 15 ingots / 0 reserved**, Returns 0, worker slots 0/1, queue 0, **Rearms 1**, `Recovery: ACTIVE | tickets 1 | recovered 0 | staged 5`. The original 15 ingots are restored and no cargo remains on the drone, consistent with a successful **five-ingot physical return/unload at Storage**. The mission has **not yet reached the final rearm/complete state** in this screenshot; `ACTIVE` / `recovered 0` are not equivalent to a failed recovery, because the drone is still recharging. The HUD's `staged 5` is the recovery ticket's expected amount, not proof five ingots remain stranded in site staging after unload. No Debugger error is visible in the supplied Output.

**Exact next observation:** leave this same F6 session running with generator ON until battery **40.0/40.0**, drone **IDLE**, rearm count **2**, and `Recovery: WAITING / IDLE | tickets 1 | recovered 1`; verify Storage remains at 15 with cargo 0. Do not mark the entire B1–B3 or the total 10-check manual acceptance solely from this interim end-state screenshot: 15→10 original supplier debit, original hover pickup, and generator-off recharge test are not all independently pictured. Previous Direct Storage and Blueprint Storage final recovered 1 observations remain recorded. Stage C automation **14/14 accepted**, Stage C compatibility **27/381 accepted**, unique automated **61 suites / 850 checks** unchanged. No source/runner change required.


### 2026-11-21 — E3d5c6c Stage C live Direct Build cancellation: recovery end state confirmed (partial manual evidence)

Developer supplied a **second pair of screenshots from the real Stage C playable scene**, reporting the same successful outcome after a **Direct Build** Storage cancellation. Godot Output explicitly includes `DIRECT BUILD AUTHORIZED: Test Storage | Normal priority`, in addition to the shared `BLUEPRINT AUTHORIZED: Test Storage` and `BLUEPRINT CANCELLED` messages. The `BLUEPRINT AUTHORIZED` line here is part of the Direct Build authorization path; the explicit `DIRECT BUILD AUTHORIZED` message distinguishes this run from the earlier Blueprint-mode recovery observation. The scene reports the E3d5c6c opt-in single-adapter tick.

Final HUD shows **Storage 15 ingots, 0 reserved; drone IDLE / cargo 0/5 / battery 40.0/40.0; Rearms 2; Recovery WAITING / IDLE, tickets 1, recovered 1; planned/queued/building 0; generator ON**. This provides manual evidence of Direct Build authorization followed by cancellation and **one settled recovery with original stock restored**. The screenshots do not show the intermediate **15→12** supplier debit, exact original-site pickup flight, Storage dock unload moment, or generator-OFF recharge test. Preserve those as **unverified manual observations**, not a claim of full A1–A5 or 10/10 acceptance. No gameplay regression or debugger error is shown.

**NEXT**: fresh playable F6 for **Ammunition Press direct-build (5 Test Ingots)**. Place at powered Press marker using its hotbar selection (previous guide: slot **8**), cancel after physical delivery and before 18-second job completion; check 15→10 source debit, later physical original staging return **10→15**, same drone rearm. Separately inspect completion/no-refund, generator-off, and Blueprint authorization permissions before final manual 10/10. Stage C automated 14/14 and compatibility 27/381 remain accepted; unique baseline **61/850** unchanged.


### 2026-11-21 — E3d5c6c Stage C live Blueprint cancellation: successful settled recovery state (partial manual evidence)

Developer supplied **two live playable-scene screenshots** immediately after cancelling a construction site during building. Godot Output shows `BLUEPRINT MODE: PLAN`, `BLUEPRINT PLANNED: Test Storage`, `BLUEPRINT AUTHORIZED: Test Storage`, `BLUEPRINT CANCELLED`, and `Blueprint mode disabled`. Thus this observed path was **Blueprint placement + explicit authorization + cancellation**, **not Direct Build**. The opt-in Stage C adapter printed `E3d5c6c Stage C opt-in playable recovery enabled (single adapter tick)`.

Final in-game HUD confirms **Starter Storage: 15 ingots / 0 reserved; drone IDLE, cargo 0/5, battery 40.0/40.0; Rearms: 2; Recovery: WAITING / IDLE, tickets 1, recovered 1; queued/building/planned 0; Worker slots 0/1; generator ON.** This is consistent with **one fully settled material-recovery mission** and restored initial inventory after an interrupted authorized Storage construction. `recovered 1` denotes one recovery **mission**, not 1 ingot. No visible Debugger error was supplied. The screenshots do not independently show the drone's transit/pickup or mid-flight inventory totals; those are covered by previous local automated acceptance and still require separate full manual observations.

**Manual status: supplemental Blueprint-mode recovery outcome OBSERVED; the formal Stage C manual 10-check gate A1–A5/B1–B3/C1–C2 remains PENDING**, because those checks require separately documented Direct Build click, physical flight observations, Press, complete-building behavior and generator-off validation. No new code change or automated test rerun is required by this screenshot evidence. Next: fresh F6 of `res://scenes/core/playable_cancelled_site_recovery_e3d5c6c_stage_c.tscn`, ensure `P` is OFF for Direct Build; click Storage hotbar 3 without pressing E, observe original 15→12 delivery, X cancel after delivery, recovery 12→15 only at real Storage dock, finite Hub rearm; then Press hotbar 8 in another fresh session. Unique accepted automated baseline **61 suites / 850 checks**, Stage C targeted compatibility 27/381 accepted.


### 2026-11-21 — E3d5c6c Stage C compatibility FULLY ACCEPTED (27/27, 381/381); manual gameplay next

Developer explicitly confirmed **all 27/27 Stage C targeted compatibility regression suites and 381/381 previously accepted checks passed locally in Godot 4.6.2**. This is **developer-reported local execution, not assistant-run tests**. The gate includes all 26 Stage B compatibility reruns (368 checks) and the isolated Stage B physical return suite (13 checks), as documented in [Stage C compatibility guide](CANCELLED_SITE_RECOVERY_STAGE_C_COMPATIBILITY.md) and `tools/cancelled_site_recovery_stage_c_compatibility.csv`. The 14/14 new Stage C playable integration F6 checks were already developer-confirmed. **Both Stage C automated gates are accepted**. Unique cumulative automated baseline stays **61 suites / 850 checks**; these 381 checks are regressions and are not added again; no fresh combined 61/850 pass is claimed.

**NEXT — Stage C manual playable verification: 10/10 player-control observations PENDING**, see [new manual guide](CANCELLED_SITE_RECOVERY_STAGE_C_MANUAL.md). Run `res://scenes/core/playable_cancelled_site_recovery_e3d5c6c_stage_c.tscn` as a real scene with F6 (NOT the automated test). Observe original Direct Storage 3-ingot and Press 5-ingot deliveries, post-delivery X cancel, original single drone rearming then physically recovering staged material to eligible Storage, finite Hub battery charging and generator-off block, completed building never refunded, and Blueprint authorization requiring E. Restart each scenario to reset 15 initial ingots; manually verify **A1–A5, B1–B3, C1–C2** before marking full Stage C manual acceptance. No gameplay/test scripts changed in this compatibility-acceptance documentation gate. Original E3d5c6b separate 10-check manual gate remains independently pending.


### 2026-11-21 — E3d5c6c Stage C isolated playable recovery ACCEPTED: local 14/14; compatibility pending 27/381

Developer reports **ALL 14/14 new Stage C playable integration F6 checks A–N passed locally in Godot 4.6.2** for `res://tests/playable_cancelled_site_recovery_e3d5c6c_stage_c_test.tscn`. This is developer-reported local execution, **not assistant-executed**. Covers exact opt-in playable Direct Build path, original Storage/Press custody capture on authorization, cancellation with 3/5 protected ingots, old construction mission rearm, same drone automatic original-hover pickup, physical return with capacity reservation, blocked dock/full Storage waits, 12+3/10+5 stock conservation, finite battery charging/generator-OFF wait and one-time recovery. The new Stage C automated suite is **isolated ACCEPTED, not yet fully regression- or manually accepted**.

**Unique accepted automated baseline is now 61 suites / 850 checks**, from prior 60/836 + one new 14-check Stage C suite. This is a cumulative *unique accepted suite milestone count*, **not a fresh full 61-suite combined test execution**. No user-confirmed Stage C gameplay manual test exists yet. The original E3d5c6b 10-check manual gate is separately pending.

**NEXT: E3d5c6c Stage C compatibility PENDING — 27 existing suites / 381 rerun checks.** Exact verified list: [Stage C compatibility guide](CANCELLED_SITE_RECOVERY_STAGE_C_COMPATIBILITY.md), `tools/cancelled_site_recovery_stage_c_compatibility.csv`. This is 26 accepted Stage B compatibility suites / 368 checks plus the existing isolated Stage B physical recovery suite / 13 checks; all checks overlap existing unique 61/850. Run each existing scene with F6 in Godot, record full banners, and only then accept 27/381. After compatibility, manually run `res://scenes/core/playable_cancelled_site_recovery_e3d5c6c_stage_c.tscn` for actual player controls and visible physical returns. Preserve single-drone sole process ownership, original scene/Main isolation, immutable custody and finite charging. No gameplay or test scripts changed in this documentation checkpoint.


### 2026-11-21 — E3d5c6c Stage C opt-in playable automatic recovery STAGED (historical; superseded by later 14/14 acceptance)

After developer-confirmed Stage B acceptance (isolated 13/13 + targeted 26/26 suites / 368/368 existing checks), committed a **separate new experimental playable scene** `res://scenes/core/playable_cancelled_site_recovery_e3d5c6c_stage_c.tscn` and a new `PlayableCancelledSiteRecoveryE3d5c6cStageC` adapter subclass. The original Direct Build playable scene, Main and accepted base adapter remain unchanged. The subclass captures each originally authorized real Storage/Press site's locked custody before X cancellation, waits until the original normal construction lifecycle has released/rearmed the one drone, then calls the accepted Stage B physical recovery mission through its **sole adapter process driver**. It does NOT tick original dispatch concurrently, unlock staging, or instant-refund cargo. Capacity/dock/energy refusal leaves materials in original custody and retries; return and finite Hub charging are physical.

The accepted custody/transport modules received only strict extra Stage C scene allowlisting; playable processing is allowed only for the exact named Stage C subclass adapter. Both remain default-off in all other scenes. New F6 integration scene `res://tests/playable_cancelled_site_recovery_e3d5c6c_stage_c_test.tscn` proposes **14 checks A–N**, covering original Direct Storage and Press delivery/cancellation, automatic return without manually starting the transport, dock blocking, full-capacity waiting, conservation, generator-off charging block and single-drone reuse. See [full F6/manual guide](CANCELLED_SITE_RECOVERY_STAGE_C_PLAYABLE.md).

**STAGED ONLY, GODOT F6 AND MANUAL PLAYABLE VERIFICATION NOT RUN.** Cumulative unique ACCEPTED baseline remains **60/836**. Provisional AFTER local Stage C isolated 14/14 would become 61/850 unique. Then rerun 26 existing compatibility suites/368 checks plus Stage B isolated 13-check scene and complete manual playable verification. E3d5c6b separately pending manual 10-check gate stays pending. No fresh combined regression claimed.


### 2026-11-21 — E3d5c6c Stage B FULLY ACCEPTED (26/26 targeted compatibility; 368/368 rerun checks)

Developer confirmed **all 26/26 targeted Stage B compatibility suites and 368/368 existing checks passed locally in Godot 4.6.2** using `tools/cancelled_site_physical_recovery_stage_b_compatibility.csv`. This is **developer-reported local execution, not an assistant-run test**. Previously accepted Stage B isolated physical recovery **13/13** and Stage A isolated custody **13/13** plus its 15/218 targeted compatibility are preserved. Stage B is now **fully accepted**, isolated plus targeted compatibility. The 368 rerun checks overlap previously counted accepted suites; **unique accepted automated milestone baseline remains 60 suites / 836 checks**, not 1,204 checks. No claim of a fresh combined full 60/836 regression.

**NEXT — E3d5c6c Stage C: opt-in playable automatic cancelled-site recovery**, separate experimental scene. Same single original drone, original immutable Stage A ticket, original hover pickup of 3 Storage / 5 Press ingots, exact Storage space claim, real transport + finite recharge, safe waits and no duplicate drivers. Do **not** assert playable Stage C works until separately implemented and Godot-tested. Existing playable Direct Build scene and Main remain unchanged. E3d5c6b separate manual Stage C 10/10 gate is still pending.


---

## 2026-11-09 — E3c2a Sandbox Storage Connections Passed (16/16); E3c2b Snap Preview Staged

**Developer Godot 4.6.2 evidence:** Two screenshots show the mixed planned/finished factory and `ALL 16 CONNECTED STORAGE BLUEPRINT E3C2A TESTS PASSED` (A–P), with normal debugger shutdown. Sandbox shared claims, Storage-first/belt-first port connections, rotation, upstream route activation, ore conservation, backpressure, cancellation, corner preview and Main opt-out were validated.

**E3c2b Stage 1 — new preview change, NOT YET VALIDATED:**

- Added `BlueprintStoragePortSnapPreview.find_nearest()`, a read-only helper that proposes a future belt transform from unfinished job-driven **Test Storage** input or output markers. It respects both E3b and legacy port claims, player-selected R direction, the established 0.65-tile snap radius, and conveyor grid alignment.
- The opt-in `WorldInteraction._get_storage_blueprint_snap_preview()` rejects candidates whose real placement footprint is blocked. The straight conveyor blueprint preview resolves the snap using the **raw world mouse hit**, before normal grid rounding, and displays exactly the transform that will be committed. The old free-grid fallback still applies when no valid snap exists.
- The factory sandbox already enables `enable_connected_storage_blueprints`; Main's default remains **false**, so ordinary conveyors, corner/bridge placement, existing cargo transport and production combat are unchanged.
- New `res://tests/storage_blueprint_preview_snap_e3c2b_test.tscn` has **14 pending F6 checks** for input/output, matching orientation, exact and fractional cursor positioning, forbidden/occupied claims, cancellation return, rotated Storage, enabled/disabled flags and Main opt-out.
- This stage **does not** change actual construction, reservation ownership, reciprocal port activation, worker/material/power readiness, or save/load. Physical links remain owned by the separately validated E3c2a service.

**Next:** Execute the E3c2b 14-check F6 scene in Godot. If it passes, manually test B/5/P/R/LMB/E/X around planned Storage input/output ports, confirm visual hard-snapping and prior normal conveyor placement, then rerun legacy logistics regression.

---

## 2026-11-09 — E3c1 Storage Activation Accepted (18/18); Sandbox E3c2a Staged

**Godot 4.6.2 evidence:** Developer Output screenshot confirms `ALL 18 PLANNED STORAGE PORT ACTIVATION E3C1 TESTS PASSED` (A–R). Storage-first and belt-first construction, real input/output port reciprocity, mixed upstream route ownership, rotation, stale/moved or occupied endpoints, cancellation, demolition, cargo backpressure and conservation were validated.

**E3c2a opt-in sandbox integration — new, awaiting Godot validation:**

- `BlueprintConveyorRouteCoordinator` can now optionally create one E3c0 `PlannedEndpointClaimBroker` and attach both its existing E2b conveyor-route registry and the E3b Storage-port registry to this same broker, with an E3c1 `PlannedBuildingPortActivator`. The feature must be enabled before the coordinator enters the scene tree.
- The controller’s `enable_connected_storage_blueprints` flag defaults **false**. It is enabled in `factory_testing_sandbox.tscn` alongside existing blueprint flags. The original Main scene remains unchanged.
- Upon placing either an unfinished `test_storage` or a straight conveyor blueprint, the controller notifies the coordinator. Newly placed belts first inspect existing unfinished Storage input/output markers for exclusive claims, then seek neighboring belt links. Newly placed Storage can also discover previously placed belts; both construction orders are supported.
- The existing operational conveyor and Storage port-connection methods are used only after both constructions have completed and the activators revalidate their corresponding reservations. Unfinished blueprints remain nonoperational.
- New `res://tests/connected_storage_blueprint_e3c2a_test.tscn` has **16 pending F6 checks**: sandbox-only flags and service ownership; Storage-first input/output, mixed upstream conveyor, broker claim release; deferred real activation; ore-through-Storage conservation and blocked output; Storage cancellation; belt-first planning; rotated Storage; wrong-facing rejection; existing right-corner cancellation; and Main opt-out.
- **Not implemented in this gate:** automatic preview snapping to future Storage ports, UI visual connection lines, player mouse/keyboard acceptance, production power/material/worker availability, and universal save/load. Existing grid snapping remains; players must correctly align belt rotations and tile positions to match the future ports.

**Next:** Run the E3c2a F6 scene. If it passes, implement and separately test future-port preview snapping and manual player E/X/R/LMB controls before expanding from Storage to other production buildings.

---

## 2026-11-09 — E3c0 Shared Claims Passed (18/18); E3c1 Physical Port Activation Staged

**Godot 4.6.2 evidence:** The developer's latest Output screenshot shows `ALL 18 SHARED BLUEPRINT ENDPOINT OWNERSHIP E3C0 TESTS PASSED` (A–R). Opposing claim orders, independent belt input/output, Storage input/output, cancellation, freed sites, completed-belt destruction and final claim cleanup all passed. E3c0 is accepted as an isolated system.

**E3c1 isolated implementation — NOT YET VALIDATED IN GODOT:**

- Added `scripts/components/planned_building_port_activator.gd`, an isolated listener to the validated E3b registry's `reservation_ready` signal. It revalidates the completed Storage `ItemPortComponent`, completed `ConveyorSegment`, expected port direction, original junction and endpoint vacancy before committing.
- Actual activation calls the existing operational `ConveyorSegment.try_connect_building_port()` method rather than manually assigning connection references. Successful commits require reciprocal `port.connected_conveyor` and belt `input_building_port` / `output_building_port`, release the exact reservation (and E3c0 broker keys), then emit `connection_committed`.
- Failed connections leave the reservation pending; the separate `try_commit(id)` path can retry after a moved endpoint, occupied port or invalid direction is corrected. Cargo is never moved during connection activation itself.
- New `res://tests/planned_storage_port_activation_e3c1_test.tscn` contains **18 pending F6 checks**, including mixed E2b belt-to-belt and E3b belt-to-Storage links with one shared broker; Storage-first and belt-first completion; rotated ports; buffered ore transfer through Storage input and output; blocked-output conservation; moved or occupied connections; cancellation, destroyed endpoints and reciprocal cleanup.
- No `WorldInteraction`, Factory Testing Sandbox, Main scene, worker/power/material services or save/load code was changed. **E3c1 is NOT yet a manual player-facing feature** and the new tests are not claimed to have passed.

**Next:** Run the E3c1 18-check F6 scene, inspect any assertions before proceeding. Once accepted, integrate shared claims and Storage-port reservation/activation into sandbox-only blueprint planning with independent scripted and manual regression gates.

---

## 2026-11-09 — E3b Storage Port Reservations Accepted (18/18); Shared Claims E3c0 Staged

**Evidence:** Developer Godot 4.6.2 Output screenshot shows `ALL 18 PLANNED BUILDING PORT RESERVATION E3B TESTS PASSED` (A–R), with normal debugger shutdown. Independent input/output claims, both build orders, released/cancelled endpoints, moved geometry, completed-object removal and non-operational status were all verified.

**E3c0 implementation — awaiting first local Godot execution:**

- Added `scripts/components/planned_endpoint_claim_broker.gd`, a shared endpoint authority using stable `ConstructionSite` identity plus directional side. Both E2b belt routes and E3b Storage-port routes now claim the exact same `belt in/out` keys when connected to one broker.
- Each claim transaction reserves both keys atomically. Owner strings include the registry instance ID and local reservation ID, ensuring one system cannot accidentally release the other registry's claim.
- `PlannedConveyorRouteReservations.set_claim_broker()` and `PlannedBuildingPortReservations.set_claim_broker()` are **optional** so earlier isolated suites still work. A broker cannot be attached after pending reservations exist, or rebound later. When a registry's reservation ends, its broker keys are released even if its construction sites were freed.
- Added `res://tests/shared_blueprint_endpoint_ownership_e3c0_test.tscn` with **18 planned checks**: belt-first and Storage-first competition, separate in/out claims on one conveyor and one Storage, cancelled construction, unexpected removal, freed sites, completed-belt destruction, and final cleanup. **F6 validation is pending.**
- This is deliberately a shared-ownership *prerequisite*, not a physical connection. Existing `WorldInteraction`, sandbox scene, cargo transport and Main remain unchanged; E3b is **not yet enabled alongside E2b in the player sandbox**.
- **Next after E3c0 passes:** E3c1 read-only real port readiness and one-time physical activation with cargo conservation, then isolated sandbox wiring and manual acceptance. Do not interpret E3c0 as end-to-end factory operation.

---

## 2026-11-09 — E3a Planned Storage Port Geometry Passed (15/15); E3b Reservations Staged

**Godot 4.6.2 evidence:** Developer-provided Output screenshot confirms `ALL 15 PLANNED BUILDING PORT GEOMETRY E3A TESTS PASSED` (PASS A–O): directed future Storage input/output port matching, separate rotated junctions, invalid-facing and offset rejection, queued/paused acceptance, cancellation/completion rejection and no premature inventory activation.

**E3b source checkpoint — local Godot validation pending:**

- Added `scripts/components/planned_building_port_reservations.gd`. Each directed reservation exclusively claims one unfinished building input or output and the matching conveyor blueprint output or input **within this isolated registry**.
- Per-reservation completion, cancellation and exit observers retain immutable claim keys and completed real-object references across deletion of the temporary sites. Distinct callbacks allow one Storage plan to reserve both its input and output without missing construction events.
- `get_ready_candidate()` is read-only and requires both completed instances, correct real `ItemPortComponent` direction, an unoccupied conveyor endpoint, unchanged original junction and matching endpoint geometry. It does **not** connect or transfer cargo.
- Cancelling, unexpectedly removing or destroying a site/finished object releases both claims. Existing live-belt-to-planned-Storage `ConstructionSite.reserve_conveyor()` claims are respected.
- Added `res://tests/planned_building_port_reservations_e3b_test.tscn` with **18 pending F6 checks** for independent input/output claims, duplicate rejection, Storage-first and belt-first completion, rotated sites, stale alignment, freed-site cleanup, cancellation, unexpected deletion, completed-object destruction and legacy-reservation priority.
- Important boundary: E3b does **not yet share a single claim broker with E2b conveyor-to-conveyor reservations**. Exclusive ownership *across both registries* is an explicit prerequisite before wiring E3b into `BlueprintConveyorRouteCoordinator`. No gameplay scene, cargo transfer code or independent save system changed.

**Next:** Run E3b's 18-check scene. Only after it passes, design shared claim ownership and a separately validated reciprocal physical port-activation transaction (E3c) before sandbox UI integration.

---

## 2026-11-09 — Post-E2c2 Compatibility Passed (45/45), E3a Geometry Staged

**Godot 4.6.2 evidence:** The developer supplied four Output screenshots verifying the full post-E2c2 regression set: E2b planned route reservations **16/16**, E2c1 physical activation **15/15**, planned Storage Build Mode **6/6**, and conveyor corner cargo **8/8**. Total **45/45**. No failed checks were shown.

**Next gated implementation (not yet Godot validated):**

- Added `scripts/components/planned_building_port_geometry.gd`: read-only inspection of an unfinished job-driven building's planned `InputPort` or `OutputPort` marker against a still-planned straight conveyor site's directed `OutputEndpoint` or `InputEndpoint`, respectively.
- Uses the proven `LogisticsConnectionGeometry.are_endpoints_aligned()` with the operational belt's connection-gap tolerance. The Storage input and output are separate; a reverse-facing belt, wrong port, lateral offset, or excessive gap is rejected.
- Supports correctly rotated planned Storage and job states PLANNED/QUEUED/CONSTRUCTING/PAUSED. Cancelled or completed placeholders are no longer valid connection targets; operational building ports must be handled by a later activation transaction.
- New `res://tests/planned_building_port_geometry_e3a_test.tscn` has **15 scripted checks**; developer F6 **pending**. It does not create any reservation, power, material delivery, worker, cargo inventory or physical logistics link.
- `WorldInteraction`, `BlueprintConveyorRouteCoordinator`, Main, operational factory systems, combat and save/load remain unchanged in this checkpoint.

**Later, separately tested:** E3b exclusive Storage future-input/future-output ownership with cancellation and build-order survival; E3c reciprocal real port activation and cargo conservation. The existing delayed-connection Storage code remains intact.

---

## 2026-11-09 — Blueprint E Authorization Independent of Preview Rotation

**Manual Godot evidence:** Developer provided four screenshots and confirmed an already-placed planned corner successfully authorizes and builds with **E** no matter which direction the currently selected conveyor placement preview faces.

- The earlier reported extra-rotation restriction was not reproduced for E authorization; no change to blueprint cursor targeting is warranted.
- The receiving belt still needs to face the correct direction **when placing the route** to form a valid directed connection. Optional automatic orientation of the next placement preview can be considered separately after broader logistics regressions.
- Automated E2c2 **17/17** and all six prior manual checks remain accepted. This additional check closes the outstanding direction-vs-authorization question.
- **Next gate remains pending:** post-E2c2 E2b (16), E2c1 (15), planned Storage Build Mode (6), and conveyor corner cargo (8), totaling **45 checks**, before extending blueprint routes to unfinished Storage ports.

---

## 2026-11-09 — Manual Connected Conveyor Corner Acceptance

**Manual Godot evidence:** Developer confirmed all six player-control steps in the Factory Testing Sandbox passed and supplied three game screenshots showing translucent connected corner blueprints and completed working 90-degree conveyor layouts.

- Player-facing right/left corner planning, blueprinted direction cues, E authorization and timed construction, X cancellation/return to straight, and regular P-off conveyor placement were all reported successful.
- This complements the separately verified automated **17/17 E2c2** suite; the Main scene remains opted out.
- **UX observation (not yet diagnosed):** The developer reports needing to rotate the selected conveyor so it faces the intended direction before a corner blueprint can be built. Direction-correct placement of the receiving belt is an intentional port requirement; however, authorization of an *already placed* site via E should not depend on current ghost rotation. The current `_blueprint_site_under_mouse()` selection-ray path and `_authorize_blueprint_site()` do not inspect ghost yaw. A focused manual confirmation is needed before changing the UI or ray selection.
- No gameplay fix is claimed by this documentation checkpoint. Explore optional automatic receiver preview orientation after distinguishing route placement from E authorization.
- **Next compatibility gate:** rerun E2b reservations (16), E2c1 activation (15), planned Storage Build Mode (6), and conveyor corner cargo (8) — **45 checks** — after accepting the player-facing integration. Then proceed toward planned-building port links with end-to-end inventory conservation.

---

## 2026-11-09 — E2c2 Connected Conveyor Blueprint Automation Passed (17/17)

**Godot 4.6.2 evidence:** Developer supplied the game view and Output screenshots for `res://tests/connected_conveyor_blueprint_e2c2_test.tscn`, showing PASS A–Q and `ALL 17 CONNECTED CONVEYOR BLUEPRINT E2C2 TESTS PASSED`. The rendered factory sandbox contains a mix of planned translucent conveyor segments and completed directional belts.

- New player-sandbox route coordinator creates exclusive pending straight/left/right neighbor reservations without creating live transport on unfinished sites.
- Both mirrored planned-corner shapes and real physical completion were validated; cancellation restores an unfinished source to a straight blueprint.
- Source-first/receiver-first build activation and a three-belt, two-hop cargo conservation scenario passed.
- Compact blueprint labels and Main's opt-out defaults were also covered.
- Output includes routine `Extractor has no resource node` and `Hit nothing` diagnostics after the passing summary; no failing E2c2 checks are shown.
- **This was an automated F6 scene**, not a manual player-input acceptance of B/5/P/LMB/R/E/X. Manual right/left blueprint placement, cancellation/replanning and normal P-off belt construction remain the next gate.
- Continue to protect existing Main, combat, cargo, and the eventual integrated save/load design. Production power, physical material delivery and worker drones are not yet implemented.

**Next:** Complete manual E2c2 input tests, then rerun E2b (16), E2c1 (15), planned Storage Build Mode (6), and corner cargo (8) regressions before planning belt connections to unfinished Storage.

---

## 2026-11-09 — E2c2 Sandbox Connected Blueprint Corners Staged (17 Checks Pending)

**Status:** New opt-in code committed to `main`, **not yet Godot validated**. E2c1 physical activation passed all 15 checks in the developer's previous F6 screenshot.

- Added `BlueprintConveyorRouteCoordinator` as a sandbox-only Node. It owns a `PlannedConveyorRouteReservations` registry and `PlannedConveyorRouteActivator` instance, scans nearby unfinished straight-belt sites on placement, and reserves up to one directed incoming and one outgoing link.
- The existing `WorldInteraction._create_straight_conveyor_blueprint()` now notifies the coordinator only when `enable_connected_conveyor_blueprints` is enabled; the flag is true in `factory_testing_sandbox.tscn` and **false by default** for Main and all other scenes.
- `ConstructionSite.set_planned_conveyor_turn()` replaces a non-operational straight placeholder mesh with the existing `ConveyorCornerVisualMesh` left/right shape, copies the appropriate corner output marker transform, changes the directional arrow, and retains an original marker for safe rollback. `clear_planned_conveyor_turn()` restores straight geometry on reservation cancellation.
- The E2b registry now emits `reservation_released` after removing a claim. The coordinator uses `WeakRef` for planned source sites and only clears still-unfinished source visuals; it cannot resurrect deleted sites or change completed conveyors.
- Compact `PLANNED` labels reduce overlap on adjacent one-tile conveyor blueprints. No visual plan contains live `CargoInventory`, transport timers, or active links before construction.
- `res://tests/connected_conveyor_blueprint_e2c2_test.tscn` contains **17 scripted checks** for standalone/straight and mirrored corners, output marker transforms, cancellation rollback, source-/receiver-first completion, three-segment chains, ore conservation and Main opt-out. **Developer F6 execution remains pending.**
- No standalone save/load feature, real Power Station, drones, or new enemy factions were introduced. Building-port blueprint connections, manual full-route editing and short-gap bridges are not included in this initial E2c2 gate.

**Next:** Run the 17-check scene. If it passes, manually use B/5/P/LMB to lay a straight-to-right or straight-to-left plan and confirm the corner visually updates before E authorization. Then rerun E2b, E2c1 and legacy cargo/Build Mode regressions before broadening planning to unfinished Storage ports.

---

## 2026-11-09 — E2c1 Deferred Physical Connections Accepted (15/15)

**Godot 4.6.2 evidence:** Developer Output screenshot reports `ALL 15 PLANNED CONVEYOR ACTIVATION E2C1 TESTS PASSED` (A–O), with normal debugger shutdown.

- Direct, right-turn and left-turn routes activate only after both real conveyors complete, regardless of which finished first.
- Reciprocal links and multi-segment chains transfer physical cargo with no duplication; waiting ore is retained before activation.
- Stale geometry, occupied ports, cancelled construction and demolished endpoints do not create unsafe connections.
- The existing operational connection helper remained unchanged. Player-facing Blueprint Mode had not yet been integrated in E2c1.

**Next gate:** E2c2 sandbox-only connection discovery and planned-corner visual indicators; revalidate the completed activation flow and legacy Build Mode separately. The Main scene and power infrastructure remain unchanged.

---

## 2026-11-09 — E2c1 Deferred Conveyor Activation Staged (15 Checks Pending)

**Source checkpoint, not yet tested in Godot:** Added `scripts/components/planned_conveyor_route_activator.gd` and `res://tests/planned_conveyor_activation_e2c1_test.tscn`.

- The isolated `PlannedConveyorRouteActivator` listens to the validated E2b registry's `reservation_ready` signal. It attempts a physical connection only after `get_ready_candidate()` confirms both completed real belts, compatible endpoints, matching planned turn and unchanged junction.
- `ConveyorExistingConnection.try_connect_candidate()` performs the already-tested direct/left/right transaction and independently revalidates the final geometry. Reciprocal belt references must exist before the adapter releases reservation claims and emits `connection_committed`.
- A missed or rejected connection leaves the reservation pending, including moved geometry or occupied ports. `try_commit(id)` supports explicit retry after those conditions are corrected; no premature cargo transfer occurs.
- The new **15-check E2c1 F6 scene** covers receiver/source-first direct links, right/left corner conversion, held and delivered ore, two-link route conservation, stale geometry rejection/retry, occupied input/output protection, cancellation and completed-belt deletion. **Pending developer execution; not yet 15/15.**
- No changes to live `WorldInteraction`, building HUD, Main, factory construction sites, existing operational conveyor modules, AI/combat, or save/load. The physical activation adapter is not yet connected to player-created blueprints.
- **After passing:** create a separate sandbox-only E2c2 gate to register placed blueprint neighbors, render the planned turn and authorize actual connection activation. Test all manual controls and cargo/demolition regressions.

---

## 2026-11-09 — E2b Exclusive Route Reservations Accepted (16/16)

**Godot 4.6.2 evidence:** The developer's latest Output screenshot shows `ALL 16 PLANNED CONVEYOR RESERVATION E2B TESTS PASSED`, all PASS A–P, and normal debugger shutdown.

- Exclusive directed input/output claims remain safe through three-belt completion, including the shared middle segment receiving both reservation callbacks.
- Plans survive arbitrary job completion order and construction-site retirement without generating premature physical links.
- Right/left corner candidates, stale physical endpoint rejection, cancellation, completed-belt removal, orphaned site cleanup and claim release all passed.
- Earlier failures due to incomplete shared-site callbacks and unsafe casts of freed construction sites are now covered by successful tests.
- No changes to operational conveyor, live Build Mode or Main scene were required to accept this result.

**Next gated implementation:** E2c isolated activation should reuse `ConveyorExistingConnection.try_connect_candidate()` only after `get_ready_candidate()` verifies that both endpoints are completed, oriented, vacant and unchanged. Save UI and planned L-shaped visuals for a later independently tested checkpoint.

---

## 2026-11-09 — E2b Freed-Site Reservation Cleanup Fixed (Retest Pending)

**Godot 4.6.2 evidence:** After the first callback fix, the developer's next F6 screenshot stopped in `PlannedConveyorRouteReservations.release()` at the old line 120, invoked from test I (the explicit A→B release). The Debugger message was `Trying to cast a freed object.` The run had reached test I, so the earlier two-route completion failure no longer appears to be the current blocker.

**Root cause and corrective patch:**

- When a construction job completes, its placeholder `ConstructionSite` is retired. The registry intentionally retains the route reservation and completed `ConveyorSegment` references across that retirement.
- `release()` nonetheless cast `record["source"]` and `record["receiver"]` directly to `ConstructionSite`, which throws in Godot if either stored Variant refers to an already-freed Object.
- Cleanup now checks `is_instance_valid()` on raw saved site and belt Variants **before casting**, disconnecting observers only for existing objects. Exclusive claims are always released using the immutable source/receiver endpoint keys instead of touching freed sites.
- Applied the same validity-before-cast guard to `has_completed_endpoint()`, `get_ready_candidate()`, and the site-exit observer, to avoid related stale-object cast errors during future teardown.
- Test G now explicitly confirms A, B and C sites have been freed before continuing to test readiness. Test I directly exercises releasing A→B after those sites are gone while preserving B→C.
- No operational conveyor, cargo, or player Build Mode scripts were modified.

**Status:** Fix committed to `main`, **16/16 Godot validation still pending**. Next run: `res://tests/planned_conveyor_reservations_e2b_test.tscn` with F6.

---

## 2026-11-09 — E2b First Local Run Failed; Shared-Site Callbacks Revised

**Developer Godot 4.6.2 evidence:** `planned_conveyor_reservations_e2b_test.tscn` stopped at line 99 in test F, with `ready_ids` containing only one ID where `[ab, bc]` was expected. The initial screenshot shows Debugger Errors (4); their detailed messages were not visible. **Do not mark E2b passed.**

**Isolation and fix candidate:**

- The A→B→C test reuses the middle blueprint B as receiver of one reserved route and source of another. Both claims must receive the same `building_completed` event, and neither may steal the other's endpoint.
- Replaced bound shared-method site observers with **distinct per-reservation Callable closures** for completion, cancellation, and tree exit. Saved the exact handles in each reservation record and disconnects them on release; connection failures now roll back their claim. Completed-belt removal observers also use distinct stored closures.
- Added read-only `has_completed_endpoint()` introspection and expanded test E to assert both route records receive the middle belt's completion. Test F now prints candidate and emitted-signal diagnostics if the two-ready assertion fails again.
- No physical conveyor activation, corner conversion, user placement routing, Main scene, or cargo transport code was changed.

**Status:** Fix committed for another local Godot F6 run; **16/16 not yet validated**. If it fails, inspect the detailed Debugger errors and the new diagnostic line before further changes.

---

## 2026-11-09 — E2a Route Geometry Accepted (12/12), E2b Reservations Staged

**Godot evidence:** Developer-supplied Output screenshot confirms all twelve `planned_conveyor_route_geometry_e2a_test.tscn` checks passed in Godot 4.6.2: straight links, right/left turns, rotations, invalid gaps/facing, cancellation, paused/queued eligibility, and finished-site rejection.

**E2b isolated implementation, not yet Godot validated:**

- New `scripts/components/planned_conveyor_route_reservations.gd` tracks exclusive output-to-input blueprint endpoint claims. Each directed reservation records source/receiver site references, anticipated `mode`, `turn`, `junction`, and immutable endpoint keys.
- Every reserved site can be independently authorized and built. The registry listens for `building_completed`, retaining finished real conveyor references even after the site leaves the tree; only after both real belts exist and geometry is revalidated can it emit `reservation_ready`. The signal is not a command to connect until a later activation transaction explicitly validates/commits the route.
- Cancelling either unfinished site, unexpectedly removing one, destroying a completed belt, or explicitly releasing a route clears both endpoint claims. Shared middle blueprint sites may own one input and one output without conflict.
- `get_ready_candidate()` uses the original real-conveyor endpoint finder on the completed instances and rejects moved, occupied, incompatible or stale endpoints. This avoids physical cargo transfers or false connector links while waiting.
- New `res://tests/planned_conveyor_reservations_e2b_test.tscn` has **16 F6 checks**, including a three-belt route, duplicate blocking, completion in either order, right and left turns, release after site retirement, stale geometry rejection, cancellation and demolition. **Developer execution pending.**
- Existing `WorldInteraction`, `ConstructionSite`, operational conveyor components, Main scene, production and save/load architecture were **not modified** for E2b. Player-facing right-angle blueprint visuals and physical connection activation remain E2c.

**Next:** Run the E2b F6 scene. Do not enable automatic blueprint connections until E2b passes and the E2c activation/cargo tests are designed.

---

## 2026-11-09 — E1 Manual Acceptance and E2a Planned Corner Discovery Staged

**Manual acceptance:** The developer confirmed all seven E1 Factory Testing Sandbox steps completed. Screenshots show a set of transparent `PLANNED 0%` directional conveyor sites and the equivalent constructed real belts. Mouse placement, visible direction, E authorization and two-second build completion, X cancellation and released-space reuse, and normal P-off Build Mode are reported working.

**Observed limitation:** Perpendicular blueprint straights currently remain separate pieces and do not create a real 90-degree planned corner. This is **expected E1 scope**, because P-mode intentionally avoids the live `ConveyorCornerConversion` and endpoint-connection paths. The goal is to restore automatic turning for blueprints after they can reserve a graph edge safely.

**E2a source checkpoint (not yet Godot validated):**

- Added `scripts/components/planned_conveyor_route_geometry.gd` to inspect two unfinished straight-conveyor sites and return a direct, right-turn, or left-turn candidate. It uses the exact output transform from the corresponding existing real corner PackedScene and the established physical endpoint gap/direction thresholds, without creating or modifying an active conveyor.
- Eligibility excludes cancelled and completed jobs, unrelated definitions, invalid orientation and misplaced receivers. Queued and paused sites still carry valid geometry.
- Added `res://tests/planned_conveyor_route_geometry_e2a_test.tscn` with **12 scripted checks**, covering direct adjacency, unmodified blueprint state, right/left templates, rotated layouts, incorrect facing/distance, invalid/self targets, pause, cancellation and completion. **Run in Godot F6 before continuing.**
- This is intentionally discovery-only. It does **not** change the on-screen corner shape, store an exclusive route reservation, activate a link, or modify cargo. E2b will own pending route claims and release them during cancellation; E2c will commit the correct corner shape and connect only fully built endpoints after revalidation.
- Existing Main gameplay, functional conveyor geometry/cargo, zombie systems and save architecture remain unchanged.

---

## 2026-11-09 — Straight Conveyor Blueprint E1 Automated Regression Passed (14/14)

**Evidence:** Developer-provided Godot 4.6.2 Output screenshot of `res://tests/conveyor_blueprint_e1_test.tscn`, showing all PASS A–N and `ALL 14 STRAIGHT CONVEYOR BLUEPRINT E1 TESTS PASSED`.

- Scripted regression verifies that cardinal straight conveyor plans reserve a one-tile footprint, preserve planned endpoint geometry and direction, and lack operational cargo/transport before construction completes.
- Authorization fails closed without power/material/worker availability, pauses without lost progress, and creates one real `ConveyorSegment` with inventory and transport on the two-second job's completion.
- Invalid rotations and overlapping plans are rejected, cancelling a plan prevents activation, and its tile can be reused; completed belts do not create phantom links or duplicate instances.
- The sandbox test-only requirements override remains separate from actual future power, materials and construction workers. Main Build Mode is still opted out.
- The screenshot contains `Hit nothing` after the successful test summary. No test assertion failed; this is a separate interaction diagnostic, not a construction regression.
- **Pending:** Manual keyboard/mouse test for B/P/5/LMB/E, direction arrows, completion and X cancellation in the Factory Testing Sandbox. Scripted assertions cannot prove the real cursor controls or belt visuals.
- **After manual acceptance:** Recheck normal live conveyor Build Mode before enabling the E2 connection-graph work. No gameplay code changed for this documentation checkpoint.

---

## 2026-11-09 — Conveyor Compatibility Passed and Straight Blueprint E1 Staged

**Validated in Godot 4.6.2:** Developer-provided Output screenshots show the post-Blueprint-Mode `planned_storage_build_mode_test.tscn` passed **6/6** and `conveyor_corner_cargo_test.tscn` passed **8/8**, a combined **14/14** on the prior E0 controller revision.

**Phase E1 implementation — pending local validation:**

- Added `scripts/components/conveyor_blueprint_placement.gd` to check one straight conveyor's cardinal orientation and integer-grid tile against other unfinished footprints, same-frame completed conveyor tiles and physical placement blockers.
- The sandbox's existing P Blueprint Mode can now place **stand-alone straight belt sites only** using the definition's two-second duration. Selected conveyor ghosts in P mode use a dedicated no-snap preview instead of the existing live conveyor corner/bridge/port discovery. The normal non-P conveyor placement route is untouched.
- Planned belt sites are non-operational: only reserved collision, future endpoint markers, `PLANNED` progress and a visible direction arrow exist. No `CargoInventory`, `ConveyorTransportTimer`, completed port links or transport is created before job completion.
- E authorization and X cancellation reuse the previously validated blueprint job controls; the explicit sandbox debug override supplies synthetic readiness for testing only.
- The new `res://tests/conveyor_blueprint_e1_test.tscn` contains **14 scripted checks**, including geometry, reservation exclusivity, queued requirements, pause/resume, 2-second activation, direction, no phantom physical connections, duplicate rejection and cancellation/reuse. **Not yet run in Godot.**
- **Deliberately out of scope:** planned belt-to-belt linking, planned Storage input/output snaps, corner chains, build-order-independent physical connection and construction materials/power/drones. All require dedicated E2/E3 architecture and regression tests.
- Main scene remains opted out. No standalone save system or new enemy factions were introduced.

**Next acceptance:** Run E1 F6 14-check test; then manual belt-plan P/LMB/E and cancellation X in the zombie-free Factory Testing Sandbox before adding any live conveyor graph behavior.

---

## 2026-11-09 — Blueprint Cancellation and Footprint Reuse Manually Accepted

**Evidence:** Developer screenshot of a translucent `PLANNED 0%` Storage site in Godot 4.6.2 and explicit confirmation that all six manual steps passed in the Factory Testing Sandbox.

- Successfully placed an unauthorised blueprint while Blueprint Mode was active.
- Attempted another Storage blueprint on the same footprint and confirmed that the duplicate was rejected.
- Hovered the original site and pressed **X** to cancel; the unfinished reservation disappeared.
- Successfully placed a new plan on the previously reserved footprint.
- Combined with the preceding seven-step cursor/E authorization test and the scripted Blueprint Mode suite **12/12**, the non-conveyor building Blueprint Planning interactions are now accepted in the sandbox.
- This acceptance confirms player-reported overlap/cancellation outcomes; the screenshot independently shows the blueprint placeholder and `PLANNED 0%` label. No new power generation, worker drones, physical material delivery, conveyor-blueprint topology, or main-game save system was introduced.
- **Next compatibility gate:** Re-run `res://tests/planned_storage_build_mode_test.tscn` (**6 checks**) and `res://tests/conveyor_corner_cargo_test.tscn` (**8 checks**) on the current branch. Earlier results predate the Blueprint Mode controller edits.
- **Future gate:** Design directional planned-conveyor graph reservation, activation/corner semantics and cancellation before enabling conveyor Blueprint Mode. Keep the normal Build Mode and Main scene unchanged until this is validated.

---

## 2026-11-09 — Manual Blueprint Storage Authorization Accepted

**Manual Godot F6 evidence:** Developer explicitly confirmed all seven Factory Testing Sandbox instructions completed successfully.

- Entered Build Mode with **B**, selected Storage with **3**, and toggled the distinct **BLUEPRINT MODE (TEST)** interface with **P**.
- Left-clicked an open area to create a translucent Storage plan displaying `PLANNED 0%`.
- Hovered the planned site and pressed **E**; construction began and progressed to a completed real Storage after the definition-defined duration.
- This verifies actual cursor/keyboard interaction for blueprint placement and authorization beyond the earlier **12/12** scripted test.
- **Not yet manually accepted:** Hover + **X** to cancel a new unbuilt blueprint; duplicate/overlapping placement rejection and safe replacement after cancellation. These are the next targeted tests.
- No gameplay changes were made during this acceptance checkpoint; Main remains opt-out, and the sandbox debug requirements bypass is still a testing aid rather than actual grid/material/worker implementation.

---

## 2026-11-08 — Sandbox Blueprint Planning Scripted Regression Passed (12/12)

**Godot evidence:** Player-provided screenshot of `res://tests/blueprint_sandbox_mode_test.tscn` showing `ALL 12 SANDBOX BLUEPRINT PLANNING TESTS PASSED` in Godot 4.6.2 (PASS A-L).

- Sandbox-only Blueprint Mode and explicit readiness override remain opt-in. Main scene defaults are unchanged.
- The script verified P toggle and HUD, rotated Storage plan geometry, footprint/off-grid rejection, unsupported belt fail-closed behavior, queued work with missing resources, progress pausing, completed real Storage activation, defensive-plan cancellation and test-only authorization override.
- The screenshot also shows `Extractor has no resource node` after the passing checks. This is an existing placement validation diagnostic, not a failed check; investigate only if manual blueprint interaction is affected.
- These scripted checks directly invoke the controller methods rather than exercising mouse ray targeting or real E/X keyboard input. Manual cursor-driven plan, authorize and cancel testing is now the next acceptance gate.
- **No code change was necessary to record this pass.** Before directional conveyor blueprints, confirm manual interaction and rerun key legacy Build Mode/cargo checks. Keep all new features sandbox-only until independently validated.

---

## 2026-11-08 — Sandbox Blueprint Planning Mode (Building Phase) Staged

**Status:** New opt-in implementation and `res://tests/blueprint_sandbox_mode_test.tscn` committed, **12 checks pending local Godot F6**. No Main scene activation.

- Added `WorldInteraction.enable_blueprint_planning` (false by default) and `blueprint_sandbox_debug_requirements` (false by default). Both are explicitly enabled only in `factory_testing_sandbox.tscn`. This test override is not a real power supply, material-delivery system or construction-drone service.
- In the sandbox's Build Mode, **P** toggles building Blueprint Planning Mode, **LMB** plans a non-operational building footprint, **E** authorizes the blueprint under the cursor, and **X** cancels it. Existing **B**, **R**, **Delete**, configurable 1–9 hotbar and normal Build Mode remain in place.
- Planned structures use the validated opt-in `ConstructionSite.setup_with_definition_job()` and the new `BuildingDefinition.construction_seconds` data. Spatial rules reject overlapping plans and off-grid origins, with physics queries protecting existing built obstacles.
- A blueprint does not produce resources or fire weapons; completion alone creates the real operational scene. The HUD distinguishes BLUEPRINT MODE (TEST), planned/queued/constructing/paused labels, and displays the user controls.
- This first interactive phase intentionally rejects placing blueprint conveyor segments and does not permit a planned building ghost to snap to a live conveyor without a deferred-port reservation. Those functions need further topology and safe connection regressions, not premature activation.
- Test suite **A–L** checks opt-in isolation, UI toggle, rotated footprint, occupancy, fail-closed invalid objects, no-service queuing, pause/resume, delayed real Storage activation, cancellation protection and sandbox-only explicit readiness override.
- Before expanding to blueprint conveyors or making this the default build path, the developer must run the 12-check F6 scene, manually verify the actual cursor interaction, and recheck old placement and cargo paths.

---

## 2026-11-08 — Per-Definition Construction Durations Validated (12/12)

**Godot evidence:** User Output screenshot for `res://tests/building_construction_duration_test.tscn` showing all twelve assertions passed in Godot 4.6.2.

- All nine buildable definitions carry positive, independently editable duration metadata.
- Storage blueprint stays inactive until authorized and requirements are available; loss of power pauses its ten-second timer without losing progress.
- A conveyor blueprint is only endpoint geometry until its two-second build ends, when actual cargo and transport components are instantiated.
- Merger and splitter metadata remain distinct from machines; ammunition press waits for workers.
- The original manual-duration Storage path was explicitly verified unchanged.

**Next gate:** Introduce sandbox-only, opt-in Blueprint Planning controls using the existing construction-site and job abstractions. Begin with non-conveyor building placement, authorization and cancellation. Physical planned-belt topology is separately gated. Do not enable power/material/worker debug overrides in Main.

---

## 2026-11-08 — Legacy Construction Compatibility Complete (23/23)

**Godot 4.6.2 evidence:** Two new developer screenshots show `planned_conveyor_port_finder_test.tscn` passed **7/7** and `planned_storage_build_mode_test.tscn` passed **6/6** after universal-site integration.

- Finder still handles rotated unfinished Storage ports, range/direction filtering, fractional cursor placement and reserved/exhausted ports.
- Factory Testing Sandbox alone enables planned snapping; the Build Mode controller still reserves belts without precompletion cargo flow, receives cargo after activation without duplication, and leaves Main scene defaults unchanged.
- Together with Round 1 (Construction Site 4/4 and Planned Storage Conveyor 6/6), all **23/23 legacy compatibility checks passed** on the opt-in construction-site branch.

### Gate D1 — Per-Definition Construction Durations (staged for validation)

- `BuildingDefinition` now includes editable `construction_seconds` for universal jobs, with positive values assigned to all nine existing buildable resources. These are provisional balance values, not final pacing.
- Timings: straight belt 2s; merger/splitter 5s; Storage 10s; extractor 12s; turret 15s; smelter 16s; ammunition press 18s; large prototype 20s.
- New `ConstructionSite.setup_with_definition_job()` reads the resource duration and rejects zero/negative/nonfinite durations. Existing `setup()` and sandbox Storage's configurable duration are untouched.
- `res://tests/building_construction_duration_test.tscn` adds **12 focused F6 checks**, including resource data, planned inactivity, queued power requirements, pause/resume, live Storage completion, delayed conveyor activation, logistics blueprints and legacy behavior.
- **Not yet validated in Godot.** Do not enable this new path in `WorldInteraction` or Main until the developer confirms 12/12.
- Blueprint Planning Mode, materials, power network, drones and full main save/load remain later independent checkpoints.

---

## 2026-11-08 — Legacy Construction Compatibility Round 1 Passed (10/10)

**Godot 4.6.2 evidence:** The developer provided Output screenshots for the two original regression scenes after opt-in universal-site changes.

- `res://tests/construction_site_test.tscn`: **4/4 PASS**, confirming site footprint reservation, no premature Storage activation, completed Storage identity/rotation/inventory and real ports, and retirement of the placeholder.
- `res://tests/planned_storage_conveyor_test.tscn`: **6/6 PASS**, confirming rotated planned marker geometry, exclusive belt reservation, blocked cargo before completion, later physical connection, cargo conservation, and safe rejection of moved belts.
- **Total: 10/10 checks passed after universal site integration.** No live gameplay code was changed following these results.

**Round 2 remains pending:** `res://tests/planned_conveyor_port_finder_test.tscn` (**7 checks**) and `res://tests/planned_storage_build_mode_test.tscn` (**6 checks**). These must pass on the current branch before moving to universal construction in Build Mode.

---

## 2026-11-08 — Universal Construction Site Integration Validated (15/15)

**Godot evidence:** The developer supplied an Output panel screenshot for `res://tests/universal_construction_site_test.tscn` showing **PASS A–O** and `ALL 15 UNIVERSAL CONSTRUCTION SITE TESTS PASSED` in Godot 4.6.2.

- Optional `ConstructionSite.setup_with_job()` began as a blueprint with an occupied footprint and without an operational inventory.
- Planned Storage reserved a physical belt without connecting or consuming its cargo. Unpowered queued jobs made no progress; authorized work could pause/resume while retaining progress and cargo.
- Finishing the job activated one real Storage building and its reserved port; waiting Test Ore entered the completed inventory without duplication or loss.
- Conveyor blueprints exposed directional markers without cargo or transport components; completing the short job created an actual working conveyor.
- Multiport merger blueprints preserved input/output markers; cancelling planned, queued and paused work prevented live entity activation.
- The test validates **isolated opt-in sites**, not live WorldInteraction/Blueprint Mode or a physical power grid.

**Compatibility gate (still pending):** rerun the legacy `construction_site_test.tscn` (4 checks), `planned_storage_conveyor_test.tscn` (6), `planned_conveyor_port_finder_test.tscn` (7), and `planned_storage_build_mode_test.tscn` (6), in that order. No new gameplay code was committed in response to this test result.

---

## 2026-11-08 — Construction Job Validated; Universal Site Opt-In Staged

**Godot validation:** Developer screenshot confirms `res://tests/construction_job_test.tscn` passed **14/14** in Godot 4.6.2, covering planned authorization, queued blockers, power loss, worker gating, pause/resume, work multiplier, cancellation, and exactly-once completion.

### Gate C implementation (pending developer F6 validation)

- Added `ConstructionSite.setup_with_job()` as an opt-in path, keeping the original `setup()` + auto-starting `ConstructionLifecycle` unchanged.
- The new job-driven path reserves the world footprint and exposes only non-operational blueprint markers until authorized work finishes. It pauses and resumes progress according to the `ConstructionJob` supplied requirement flags, and cancellation queues the empty site for retirement.
- Planned geometry now copies all direct `ItemPortComponent` children, supporting multiport mergers and splitters; directional conveyor `InputEndpoint` and `OutputEndpoint` markers are also copied without instantiating a live conveyor cargo buffer or timer.
- `PlannedConveyorPortFinder` now checks `ConstructionSite.accepts_planned_connections()`, which preserves legacy Storage behavior while allowing future planned/queued job-site reservations.
- Successful job completion creates the actual building or conveyor once, retaining final world transform, existing runtime components, and strict physical port link validation for any reserved completed belts.
- New `res://tests/universal_construction_site_test.tscn` contains **15 focused assertions** for Storage, conveyor, merger, planned-port reservations, inactive cargo, queue/power pause, completion, conservation, and cancellation. **Not yet run in Godot.**
- No `WorldInteraction` or Main scene construction path was enabled. The job's power/material/worker inputs are test-provided availability values; no grid, drones, material delivery or standalone save system was introduced.

**Test order:** New universal site F6 scene, then legacy construction site and planned conveyor finder/Build Mode regression scenes. Manual end-to-end corner-to-Storage inventory accounting remains separate acceptance work.

---

## 2026-11-08 — Salvage Regression Accepted and Construction Job Gate B Staged

**Validated in Godot 4.6.2:** Player screenshot reports `ALL 12 WRECKAGE SELECTION AND CLEANUP TESTS PASSED` for `res://tests/wreckage_selection_cleanup_test.tscn`.

- Wreckage is selectable through its intended Layer-2 hitbox and reports content through the shared HUD.
- Empty wreckage cleanup preserves unrelated world objects. Stocked wreckage remains protected until its materials are recovered safely.
- Ten recovered resources remained conserved when the cache became clearable.
- This completes the focused corner cargo **8/8**, conveyor demolition **6/6**, and wreckage cleanup **12/12** regression sequence: **26/26 checks**, each run separately in local Godot.

**Next implementation checkpoint — isolated, not yet Godot validated:**

- New `scripts/components/construction_job.gd` wraps the existing `ConstructionLifecycle` and adds blueprint authorization, queueing, requirement blockers, pauses, resumes, cancellations, and one-time completion.
- New `res://tests/construction_job_test.tscn` contains **14 targeted assertions**, covering all job states, gate loss/recovery, work multiplier, idempotence, cancellation and an explicit instant prototype exception.
- No changes to existing live construction sites, WorldInteraction, conveyor logistics, demolition services, zombie gameplay or the save architecture. Power/material/worker flags are **read-only external availability snapshots supplied by future services**, not implemented networks or resource deliveries.
- **Pending:** Developer runs the 14-check F6 scene before any scene/world integration. A manual item-counted corner-to-completed-Storage receipt test also remains separate acceptance work.

---

## 2026-11-08 — Conveyor Demolition Safety Regression Accepted (6/6)

**Local Godot evidence:** Player-provided Output screenshot for `res://tests/conveyor_cargo_demolition_test.tscn` on Godot 4.6.2, showing `ALL 6 DEMOLITION SAFETY TESTS PASSED` and all original resources conserved.

- Empty belts allow guarded player demolition; occupied belts refuse it while retaining their cargo.
- Successfully unloaded belts become eligible again; invalid cargo configuration is rejected.
- Generic item types receive the same protection as ore.
- These scripted checks do not prove live click interaction with stocked world salvage; that separate test remains pending.
- No runtime gameplay code changed at this checkpoint.

**Next test gate:** `res://tests/wreckage_selection_cleanup_test.tscn` (12 expected assertions), before isolated universal construction job implementation.

---

## 2026-11-08 — Corner Cargo Regression Accepted (8/8)

**Local Godot 4.6.2 evidence:** Player-provided Output panel screenshot for `res://tests/conveyor_corner_cargo_test.tscn`, reporting `ALL 8 CORNER CARGO TESTS PASSED`.

- Real conveyor components retained cargo and travel progress through in-place right-turn conversion.
- Right-turn cargo delivery, occupied-output backpressure, post-blockage resumption and rotated left-turn transfer passed.
- Three distinct item types remained conserved within the scripted test; no reported errors.
- This suite does not replace a manual, item-counted end-to-end delivery into a completed Storage building.
- No gameplay/runtime code changes were made for this checkpoint.

**Next test gate:** `res://tests/conveyor_cargo_demolition_test.tscn` (six guarded-demolition checks), then `res://tests/wreckage_selection_cleanup_test.tscn` (12 salvage/selection checks) before isolated universal construction job implementation.

---

## 2026-11-08 — Manual Opposite-Direction Corner and Buffered Ammunition

**Evidence:** Player screenshot and explicit confirmation that the opposite 90-degree conveyor layout works in the Godot 4.6.2 Factory Testing Sandbox.

- The completed Storage and neighboring belts remain visually aligned with arrows following the turns.
- The selected conveyor's Production Debug HUD shows `Input: Previous conveyor`, `Output: Building port`, and `Cargo: Prototype Rounds x1`. This confirms it has received a buffered ammunition item and remains physically linked to a building port.
- This image does not yet prove the item emptied into Storage or establish end-to-end inventory conservation; those remain a focused follow-up.
- Both manual right-turn and opposite-turn physical connection checks are accepted. The known automated bidirectional Storage regression remains **8/8 PASS**.
- No gameplay code modified. Before universal construction rollout, finish corner cargo/conservation and demolition/salvage safety regressions.

**Next local regression:** `res://tests/conveyor_corner_cargo_test.tscn` (8 scripted assertions), followed by cargo demolition and salvage safety scenes.

---

## 2026-11-08 — Manual Outgoing Conveyor Right-Turn Preservation

**Evidence:** Player screenshot from the Godot 4.6.2 Factory Testing Sandbox after Storage completion.

- The Storage construction placeholder is replaced by the real building, with a visibly continuous outgoing conveyor route that turns 90 degrees.
- The selected conveyor directly next to the completed Storage shows `Input: Building port` and `Output: Next conveyor` in Production Debug, confirming its existing building connection and first downstream physical link survived construction.
- The selected belt reports HP 50/50 and empty cargo; this screenshot is not proof that cargo has traversed the corner or that every downstream link is connected.
- No gameplay source changes were necessary. The reverse/left-turn, corner transport, and player demolition/salvage checks remain open.

**Next gate:** Build the opposite-direction turn from a new Storage output route and verify the same two HUD fields after completion, then continue cargo conservation and destruction testing.

---

## 2026-11-08 — Manual Planned Storage Input/Output Acceptance

**Evidence:** Three player-provided Factory Testing Sandbox screenshots from Godot 4.6.2.

- At 6% construction, Storage remains a translucent reserved footprint with conveyor segments placed at both planned ends and their yellow direction arrows visually aligned.
- After Storage completed, the output-side conveyor Production Debug HUD displayed `Input: Building port` and `Output: Disconnected`, confirming its input is physically linked to Storage output.
- The input-side conveyor Production Debug HUD displayed `Input: Disconnected` and `Output: Building port`, confirming its output is physically linked to Storage input.
- Combined with the preceding automated bidirectional regression **8/8**, this accepts visible planned-port bidirectional reservation and postconstruction physical connection.
- These screenshots do **not** establish a new manual ore/ammunition transport-conservation result. Left/right corner paths, cargo, demolition and salvage interactions remain to validate before universal construction rollout.
- The Factory Testing Sandbox and Main gameplay scripts remain unchanged.

**Next gate:** Manual left/right corner paths near the completed Storage, then focused existing Godot corner regression scenes.

---

## 2026-11-08 — Bidirectional Planned Storage Conveyor Regression Accepted

**Local test:** `res://tests/planned_storage_bidirectional_conveyor_test.tscn`  
**Outcome:** **8/8 PASS** in Godot 4.6.2, confirmed by player-provided Output panel screenshot.

- Rotated unfinished Storage exposes planned input/output markers without active ports or inventories.
- Independent planned input and output conveyor reservations remain exclusive and inactive until Storage construction completes.
- Completion establishes reciprocal physical port connections; subsequent inbound delivery and outbound loading conserve all three seeded item units.
- Unrouted cargo remains buffered and protected from player demolition; detaching the outbound port preserves the remaining input link and cargo.
- These are scripted, code-driven test assertions; the actual in-game cursor snapping, 90-degree turns, and demolition interactions around unfinished Storage still require manual F6 acceptance.
- A separate design proposal for universal construction jobs, blueprint planning and connected power infrastructure is in `docs/CONSTRUCTION_AND_POWER_ARCHITECTURE.md`.
- No gameplay runtime implementation changed during this regression acceptance; main game remains unaffected.

**Next gate:** Manual input/output hard-snap and corner checks in the zombie-free Factory Testing Sandbox, followed by broader logistics and salvage regressions before universal construction implementation.

---


## 2026-11-08 — Next-Phase Design Checkpoint and Handoff

**Status:** Design documentation only. No new runtime gameplay implementation in this checkpoint.

### Accepted construction progress

- Timed Storage, unfinished footprint collisions, port activation, physical cargo delivery, and inventory conservation passed dedicated Godot regressions and manual sandbox testing in prior checkpoints.
- Planned Storage conveyor discovery **7/7** and sandbox Build Mode integration **6/6** passed in Godot 4.6.2. User confirmed the conveyor placement ghost now hard-snaps to unfinished Storage.
- Reserved conveyors activate their physical building connection when construction completes. Both planned input/output, corners, demolition, and full conveyor regression acceptance remain follow-up work, rather than assumed complete.
- Factory Testing Sandbox retains the green zombie disabled for uninterrupted construction checks; Main gameplay behavior remains a separate baseline.

### New design decisions

- All placed structures, **including every conveyor segment**, should eventually be time-built, with lightweight belts significantly faster than machines or defensive works. Current live implementation remains staged and not universal.
- Add **Blueprint Planning Mode** so players can preplan layouts and port alignments, then authorize construction separately. Holograms reserve plans but cannot operate or claim territory.
- Introduce a Main Hub with initial emergency power, Power Stations to generate electricity, and linked Power Poles/Relays to extend electrical and construction coverage.
- Power, defended territory, and drone-service reach are different concepts. A powered location is not automatically safe.
- Plan three upgrade tiers of poles with increasing coverage and **different drone charging rates** (slow, medium, fast); final numerical balance and power constraints require later design.
- The player-operated AI drone can eventually scout beyond grid support using limited battery and return for recharging; later worker drones from the hub construct authorized structures with speed/capacity research upgrades.
- Keep shared industrial materials as real physical logistics competing between ammunition, expansion construction, and eventually research.
- Preserve one zombie-planet playable demo as the near-term objective. Planetary conquest and multiple hostile factions are long-term campaign/replayability goals, not a roguelike reset mechanic.

### Next engineering sequence

1. Close remaining construction/conveyor regression cases (both planned ports, turns, selection, removal and resource conservation).
2. Review current scripts/scenes and design universal blueprint/construction jobs together with power-coverage rules.
3. Implement small opt-in checkpoints for universal construction, preplanning, grid coverage, and later drones/material costs, with local Godot validation between milestones.
4. Continue using GitHub `main` as the reviewed checkpoint branch and avoid independent save/load architecture.

---

This document tracks meaningful development milestones, design decisions, technical changes, testing, troubleshooting, and showcase-ready progress.

The development log intentionally summarizes completed milestones rather than recording every individual edit.

---

## 2026-11-07 — Planned Conveyor Hard-Snap Follow-up

- Player confirmed construction-site reservations connect automatically at 100%, but the yellow conveyor ghost does not hard-snap to the unfinished Storage site.
- Reviewed the live `WorldInteraction` preview and identified that `PlannedConveyorPortFinder` was called with a grid-rounded cursor world position. Storage port geometry may be fractional, which can push the rounded search position outside the strict snap radius.
- Updated planned-port preview discovery to receive the original `hit_position` from the ground raycast; the finder retains its direction and radius checks and the actual snap transform is unchanged.
- Extended the planned finder regression to seven checks, including a fractional raw cursor hit near a planned port.
- **Automated validation passed:** updated finder **7/7** and WorldInteraction test **6/6** in Godot 4.6.2 (player-confirmed screenshots, 2026-11-07). **Manual F6 yellow-ghost hard-snap verification passed** (player confirmed snapping works, 2026-11-07). Input/output variants and full conveyor regressions remain follow-up acceptance checks.

---


## 2026-11-07 — Planned Conveyor Ghost Snap Follow-up

- Manual sandbox testing confirmed the conveyor can reserve a planned connection and connect at construction completion, but the preview ghost did not snap when positioned over the blueprint.
- Root cause investigated: finder compared mouse-to-belt-origin only, even though players aim at the planned Storage port itself. Updated finder to accept proximity to **either** planned port or intended belt origin, preserving the strict heading/radius checks.
- Added a specific port-cursor scenario to `tests/planned_conveyor_port_finder_test.tscn`, now six checks.
- **Pending local F6 validation:** planned-port finder and sandbox Build Mode integration regression, followed by in-game ghost snapping, adjacent-lane, and rotation checks.

---


## 2026-11-07 — Sandbox Planned Conveyor Build Mode Integration

- Confirmed **5/5** `PlannedConveyorPortFinder` discovery checks passed in Godot 4.6.2.
- Added `WorldInteraction.enable_planned_storage_conveyor_snap` (default **false**), a separate planned Storage preview target and safe collision handling for the intended reserved-footprint body.
- Implemented opt-in straight-belt placement that reserves the aligned construction-site port. It does not form an operational connection until the real Storage becomes available.
- Enabled the feature only in `factory_testing_sandbox.tscn`; `main.tscn` remains unchanged.
- Added `tests/planned_storage_build_mode_test.tscn` with six isolated world-integration checks. **Local Godot verification passed: 6/6 checks** (2026-11-07); manual player placement and corner/selection regressions follow.
- No changes made to the existing conveyor transport algorithms, zombie combat, or main game save architecture.

---


## 2026-11-07 — Planned Conveyor Preview Discovery

- Six planned-reservation regression checks passed in local Godot 4.6.2, including cargo conservation, deferred port connection, and rejection of a moved belt.
- Added `PlannedConveyorPortFinder`, a preview-only candidate finder that applies search radius, player-selected conveyor heading, reserved-port restrictions, and construction-state validation.
- Added `tests/planned_conveyor_port_finder_test.tscn` with five focused discovery checks. **Pending local Godot verification.**
- Existing `WorldInteraction` placement remains unchanged. The next stage will integrate preview and click routing after the finder test passes.

---


## 2026-11-07 — Planned Port Reservation Foundation

- Added marker-only planned Storage port geometry, matching completed building port transforms while keeping unfinished sites free of operational `ItemPortComponent` instances or inventories.
- Added optional `ConstructionSite.reserve_conveyor()` plus `get_planned_belt_transform()`; reservations do not move or transfer cargo. Upon completion, each reserved belt is connected only if the existing strict `ConveyorSegment.try_connect_building_port()` validation still passes.
- Added six focused checks in `res://tests/planned_storage_conveyor_test.tscn` for early isolation, one-item holding, delayed connection, conserved delivery, and moved-belt refusal.
- **Local Godot verification: 6/6 planned-reservation tests passed on 2026-11-07.** Player-facing Build Mode snapping around blueprints is deferred pending the next isolated discovery regression; existing production, hotbar, combat, and Main scene scripts are unchanged.

---


## 2026-11-07 — Timed Storage Physical Belt Delivery Regression

- User confirmed all **4/4 construction footprint and port** checks passed in Godot 4.6.2.
- Reviewed existing `ConveyorBuildingSnap`, `ConveyorTransportTimer`, `ConveyorTransportComponent`, and `ItemPortComponent`; retained the existing physical movement mechanisms.
- Added `tests/timed_storage_conveyor_delivery_test.tscn`: completed Storage accepts an aligned conveyor input, transports one Test Ore into Storage, preserves total source/belt/destination inventory, and cleans up connections on disconnect.
- Live gameplay logic remains unchanged. **All 6/6 checks passed locally in Godot 4.6.2 on 2026-11-07**, including physical connection, item delivery, conservation and disconnection. **F6 factory sandbox acceptance:** screenshot shows completed Storage with 11 Prototype Rounds / 200 capacity and 100/100 HP beside the connected ammunition conveyor network. The full live connection-and-delivery loop is accepted; automatic connection reservation during construction remains separate.

---


## 2026-11-07 — Construction Footprint and Port Readiness

- Accepted testing sandbox: 3/3 Godot checks and player confirmation of a nonattacking zombie in F6 sandbox play.
- Reviewed `ConstructionSite`, `ItemPortComponent`, and the existing 3D placement blocker mask.
- Added `tests/construction_footprint_ports_test.tscn` to verify the unfinished site's physical overlap, absence of inventory/ports during construction, and real Storage inventory/ports on completion.
- No game-system modifications: this test establishes the prerequisite for safe delayed conveyor connection. The next checkpoint will validate connecting physical belts and moving actual items.
- **Validation pending:** Four new Godot checks, then subsequent logistics tests.

---


## 2026-11-07 — Safe Factory Testing Sandbox

- Added `scenes/core/factory_testing_sandbox.tscn` for interruption-free factory testing. The green moving zombie remains visible but its processing is disabled, so it does not walk or melee attack in this scene.
- Enabled timed Test Storage construction in the sandbox. Normal `scenes/core/main.tscn` is unchanged and retains active zombie behavior and its existing construction settings.
- Added `tests/factory_testing_sandbox_test.tscn` with three tests checking disabled sandbox zombie, normal Main behavior, and retained build HUD/catalog. **3/3 passed** locally in Godot 4.6.2 (2026-11-07). Player additionally confirmed the sandbox runs as intended with the green zombie inactive.
- Run the sandbox scene directly with **F6**; run the normal Main scene using **F5**. Since this is a separate scene copy, synchronize it if Main receives future gameplay or scene changes.

---


### Timed Storage Controller Integration — Local Validation (2026-11-06)

- Godot confirmed **4/4** world-controller integration checks passed (default instant placement, nonoperational site, activation at 100%, invalid-definition rejection).
- Next validation is a controlled F5 session with `WorldInteraction.enable_timed_storage_construction` enabled temporarily in the Main scene Inspector. Keep the default false until regular placement and downstream conveyor cases are regression-tested.
- Only standalone Test Storage placement is supported; snapped-to-belt Storage still takes the original immediate-connection route.
- Manual F5 evidence (2026-11-06): blue construction site shown at 47%, then completed Storage building with IN/OUT port markers. Timed standalone build activation accepted visually; automated checks 14/14 passed across three scenes. Actual port cargo transfer after construction and site/conveyor collision compatibility remain future checks.


## 2026-11-06 — Construction Site and World Integration Follow-up

- Local Godot **4/4 ConstructionSite** checks passed, confirming footprint, pending state, delayed real Storage, preserved transform and ports.
- Added opt-in `WorldInteraction.enable_timed_storage_construction` (default false) and `storage_construction_seconds` to stage the first standalone Storage construction in the live controller. Existing Main and conveyor snap placement remain unchanged by default.
- Added `tests/timed_storage_placement_test.tscn` for world-controller integration checks; these have **not** been run locally yet.
- Next: pass the test, validate automatic placement and safe activation, then enable timed construction in F5.

---


## 2026-11-06 — Zombie-Planet Demo Focus and Construction Lifecycle Foundation

- Confirmed the immediate vertical slice: one zombie world with persistent factory growth, ammunition-fed defenses, and turret/wall-led territorial expansion. Planet-hopping and alternate enemy factions remain long-term campaign goals.
- Added `scripts/components/construction_lifecycle.gd`: isolated planned/constructing/complete state transitions, required duration, progress, remaining work, optional worker multiplier, and one-time completion signal.
- Added `tests/construction_lifecycle_test.gd` and `tests/construction_lifecycle_test.tscn` covering six construction-state and timing regression groups.
- The lifecycle model passed **all 6/6** local Godot regression checks (user-confirmed screenshot).
- Added `ConstructionSite` prototype and `tests/construction_site_test.tscn` to demonstrate a timed, reserved Storage footprint and delayed creation of an operational Storage building. This is isolated test-only integration pending Godot verification; main Build Mode is unchanged.
- The model is intentionally **not yet wired into live placement**: current buildings remain instantly constructed until isolated tests pass and gameplay-system shutdown/activation rules are implemented and validated.
- No main-scene, conveyor, hotbar, production, combat, or salvage behavior was changed. The construction test requires execution in Godot 4.6.2.

---


## 2026-11-05 — Phase 1G6: Building Catalog Expansion, Checkpoint 1

- Reviewed existing `BuildingDefinition.category` values, hotbar stable-ID assignment model, and implemented 1×1 Splitter/Merger routing components.
- Organized each Building Catalog slot dropdown by existing unlocked building categories, with nonselectable category separators. Empty option, assignment metadata, swapping, and Restore Defaults retain their original behavior.
- Added `res://tests/build_catalog_category_test.tscn` to validate grouping, selecting a grouped building, hotbar redraw, and restoring defaults.
- This is a **catalog presentation improvement only**. No new manufacturing recipes, logistics functionality, save files, or progression systems are introduced.
- **Validation complete (2026-11-06):** Godot 4.6.2 category regression passed all **3/3** checks. Player confirmed that the in-game M menu works and dropdown entries are grouped by building category. Checkpoint 1 accepted.

---


## 2026-11-04 — Phase 1G5: Visual Hotbar UI, Checkpoint 1

### Architecture
- Reused the existing nine-slot `BuildHotbarConfiguration` stable-ID model, WorldInteraction shortcut routing, and Building Catalog.
- Added `scripts/ui/build_hotbar_visual.gd` as a presentation-only view attached to `VisualHotbar` in the existing `build_hud.tscn`.
- Moved the visible build shortcuts into nine bottom-centered horizontal tiles. The previous text slot labels remain hidden but continue to update for existing regression compatibility.
- Each tile includes shortcut number, generated placeholder graphic, compact name, selection border, and tooltip.
- Icon textures are cached by building ID. Catalog swaps, empty assignments, locked buildings, selection changes, and Restore Defaults redraw the view via existing HUD synchronization.
- Build Mode visibility follows the original BuildPanel. No changes to placement, conveyors, combat, or save/load architecture.

### Testing
- New runnable scene: `res://tests/build_hotbar_visual_test.tscn` (six regression groups).
- Re-run `res://tests/build_hotbar_keyboard_integration_test.tscn` and `res://tests/build_hotbar_configuration_test.tscn` to check existing behavior.
- Manual checklist: enter Build Mode, inspect all nine icons, press 1–9, open M catalog and swap a selection, clear a slot, restore defaults, exit Build Mode, verify placement and conveyor corner behavior.
- **Verification status:** Code committed to GitHub. Godot runtime/regression tests await execution on the local Godot 4.6.2 installation.


### Manual Validation and Layout Follow-up (2026-11-05)
- Godot 4.6.2 visual hotbar regression: all six checks passed on the local machine.
- In-game screenshot confirmed the nine centered tiles, selected highlight, and customized assignment order.
- Manual conveyor/corner placement confirmed working by the player.
- Corrected BuildPanel's anchor preset to bottom-left (with explicit horizontal anchors) to address controls clipping at the left edge.
- **Pending:** verify left-side control panel positioning after pulling this final layout correction. No gameplay systems or save/load behavior changed.

### Deferred
- Production artwork and locked-tile research presentation.
- Per-saved-game assignments, which must be integrated with the main save/load design.

---


## 2026-10-11 — Project Foundation

### Engine and Project

Created the Industrial Warfare project with:

- Godot Engine 4.6.2 Stable Official
- Forward+ renderer
- Windows desktop as the initial platform
- Single-player as the initial development target

Project path:

```text
E:\GameDev\industrial-warfare
```

### Initial Structure

Created the initial project organization:

```text
assets/
data/
docs/
docs/screenshots/
scenes/
scripts/
tests/
```

Created the core documentation files:

- `DEVLOG.md`
- `ROADMAP.md`
- `GAME_DESIGN.md`
- `ARCHITECTURE.md`
- `TROUBLESHOOTING.md`
- `FUTURE_FEATURES.md`

### Source Control

Initialized Git using the `main` branch.

Created the public GitHub repository:

```text
ChrisGiggleman/industrial-warfare
```

Connected the local repository to `origin` and pushed the project to GitHub.

### Godot Configuration

Configured:

- 1920 × 1080 base resolution
- `canvas_items` stretch mode
- `keep` stretch aspect
- resizable window
- initial Input Map actions

Initial input actions included camera movement, interaction, mouse actions, and zoom.

### Main Scene Foundation

Created:

```text
res://scenes/core/main.tscn
```

Initial world setup included:

- ground
- DirectionalLight3D
- WorldEnvironment
- Camera3D
- ReferenceCube

### Troubleshooting

Resolved an early PowerShell relative-path mistake while creating documentation files.

### Visual Milestone

The project opened successfully in Godot and entered source control with a clean baseline.

### Status

**Project Foundation: Complete**

---

## 2026-10-12 — Chat 02: Camera & Player Interaction Foundation

### Camera

Created a `CameraRig` architecture and added:

- WASD camera movement
- mouse-wheel zoom
- movement/zoom tuning
- frame-rate independent motion

### Mouse and World Interaction

Created:

```text
res://scripts/world_interaction.gd
```

Added mouse-to-world raycasting and separated player interaction from the camera controller.

### Selectable Objects

Created a reusable selection system using the `selectable` group.

Implemented:

- collider-to-logical-object parent traversal
- persistent selection state
- gold material highlight
- deselection on ground/empty-space clicks

Selection presentation was moved into:

```text
res://scripts/selectable_object.gd
```

### Physics Layer Conventions

Established:

- Layer 1 — Ground / placement surfaces
- Layer 2 — Selectable-object collision
- Layer 3 — Placement blockers

This allows ground placement raycasts and occupancy checks to remain independent.

### Build Mode

Added Build Mode with `B`.

Implemented:

- 1-meter grid snapping
- placement validity checking
- green/red placement feedback
- LMB placement
- RMB cancellation/exit

### Runtime Building Placement

Created prototype building scenes:

- `test_building.tscn`
- `test_building_large.tscn`

Added runtime instantiation and placement blocking.

### Placement Ghost

Replaced the temporary flat marker with a full translucent building ghost.

The ghost:

- follows snapped placement
- uses the actual building footprint
- turns green/red based on validity
- is safely removed when Build Mode ends

### Rotation

Added `R` rotation in 90-degree increments.

Placement validity uses the actual rotated collision shape, allowing rectangular footprints to validate correctly.

### Multiple Building Types

Added prototype building selection:

- `1` — small test building
- `2` — large test building

Switching buildings recreates the ghost and preserves footprint-aware validation.

### Build HUD

Created a temporary Build HUD showing:

- current build mode
- building slots
- selected building
- control hints

### Demolition Tool

Moved demolition into Build Mode.

Implemented:

- `Delete` tool toggle
- red demolition HUD state
- red demolition-hover targeting
- LMB demolition
- `player_built` protection rules
- safe return to placement mode

`ReferenceCube` remains selectable but cannot be demolished.

### Refactor and Regression Test

Cleaned the interaction code by:

- removing obsolete HoverMarker logic
- using named constants for masks/rotation/ghost alpha
- improving method names
- improving demolition cleanup
- organizing scripts with section headers

Regression-tested:

- camera movement
- zoom
- selection/deselection
- Build Mode
- building switching
- grid snapping
- placement ghost
- valid/invalid coloring
- collision blocking
- rotation
- rotated footprints
- placement
- demolition
- protected objects

No gameplay regressions were found.

### Status

**Chat 02 — Camera & Player Interaction Foundation: Complete**

---

## 2026-10-14 — Chat 03: Factory Building & Production Foundation

Chat 03 moved Industrial Warfare from a construction prototype into the first reusable factory-production architecture.

### Data-Driven Building Definitions

Created:

```text
res://scripts/data/building_definition.gd
```

`BuildingDefinition` currently stores:

- building ID
- display name
- description
- category
- building scene

Created:

- `res://data/buildings/test_building.tres`
- `res://data/buildings/test_building_large.tres`

The `.tres` file now describes what a building is, while the `.tscn` file describes how it physically exists.

### Build-System Refactor

Refactored `WorldInteraction` from a direct `Array[PackedScene]` to:

```gdscript
Array[BuildingDefinition]
```

The selected definition now supplies the scene used for:

- placement preview
- placement validation
- runtime construction

Removed the legacy `buildable_scenes` collection after regression testing.

### Building Runtime Component

Created:

```text
res://scripts/components/building_runtime.gd
```

Placed buildings receive the `BuildingDefinition` that created them.

Current flow:

```text
BuildingDefinition
        ↓
building_scene
        ↓
placed building
        ↓
BuildingRuntime.initialize(definition)
```

This gives each placed building access to its own data identity without hard-coding building-specific behavior into `WorldInteraction`.

### Item Definition

Created:

```text
res://scripts/data/item_definition.gd
```

Created the first item asset:

```text
res://data/items/test_ore.tres
```

`Test Ore` is the prototype raw material used to validate inventory and production behavior.

### Item Amount

Created:

```text
res://scripts/data/item_amount.gd
```

`ItemAmount` represents an `ItemDefinition` plus an integer amount.

This is used by recipe input/output arrays.

### Inventory Component

Created:

```text
res://scripts/components/inventory_component.gd
```

Current inventory operations:

- add item
- remove item
- get quantity
- check quantity

Verified with temporary runtime tests:

```text
Inventory added - Test Ore: 5
Has 5 Test Ore: true
Removed 2 Test Ore: true
Inventory remaining - Test Ore: 3
```

Temporary test code was removed after verification.

Multiple placed buildings were confirmed to maintain independent inventory instances.

### Production Recipe Data

Created:

```text
res://scripts/data/production_recipe.gd
```

Created:

```text
res://data/recipes/prototype_extraction.tres
```

Prototype recipe:

```text
Prototype Extraction
Production Time: 2 seconds
Inputs: none
Outputs: 1 Test Ore
```

The recipe format supports input arrays for future processing recipes, but input consumption is not implemented yet.

### Producer Component

Created:

```text
res://scripts/components/producer_component.gd
```

Added `ProducerComponent` only to the small `TestBuilding`.

The large prototype intentionally remains a non-producer for comparison.

Production flow:

```text
ProducerComponent
        ↓
Prototype Extraction
        ↓
wait 2 seconds
        ↓
1 Test Ore
        ↓
InventoryComponent
```

Verified autonomous production and independent inventory counts across multiple placed producers.

### Placement Ghost Gameplay Safety

Because placement ghosts instantiate the same building scene as real buildings, producer components would otherwise exist inside the preview.

The ghost root now uses disabled process mode so gameplay scripts do not run on temporary placement previews.

Verified that placement ghosts do not produce resources.

### Production Debug HUD

Created:

```text
res://scenes/ui/production_debug_hud.tscn
res://scripts/production_debug_hud.gd
```

The temporary debug HUD displays live selected-building information.

Producer example:

```text
PRODUCTION DEBUG

Building: Test Building
Recipe: Prototype Extraction
Stored Test Ore: 7
```

Non-producer example:

```text
Building: Test Building Large
Recipe: None
```

Non-building selection:

```text
Selected object has no building data.
```

No selection:

```text
No building selected.
```

The stored resource count updates live while production continues.

Temporary production console spam was removed after the HUD became the primary production-debug view.

### Troubleshooting and Lessons

Notable issues encountered:

- a `Resource` script was accidentally attached to `Main` Node3D
- GDScript indentation errors occurred while inserting nested test blocks
- the fixes reinforced the distinction between data resources, node scripts, and indentation-based GDScript structure

See `TROUBLESHOOTING.md` for reusable fixes.

### Regression Coverage

Throughout Chat 03, changes were regression-tested against the established interaction foundation.

Verified systems include:

- camera movement
- camera zoom
- normal selection
- selection clearing
- Build Mode
- building switching
- grid snapping
- placement ghost
- valid/invalid placement
- rotation
- rotated footprints
- runtime placement
- Demolition Tool
- protected non-player-built objects
- data-driven building selection
- BuildingRuntime initialization
- independent building inventories
- autonomous production
- non-producing control building
- placement-ghost production safety
- Production Debug HUD selection states

No persistent gameplay regressions remained at the end of the milestone.

### Architecture Milestone

The first factory gameplay foundation is now:

```text
BuildingDefinition
        ↓
Building Scene
        ↓
BuildingRuntime
        │
        ├── InventoryComponent
        └── ProducerComponent
                ↓
        ProductionRecipe
                ↓
            ItemAmount
                ↓
          ItemDefinition
```

### Current Limitations

Intentionally deferred:

- world resource nodes
- recipe input consumption
- storage capacity
- conveyors/logistics
- power networks
- build costs
- research/unlocks
- machine upgrades
- save/load
- polished factory UI

### Status

**Chat 03 — Factory Building & Production Foundation: Complete**

The project now has its first autonomous, data-driven production building.

---

## 2026-10-18 — Chat 04: Resource Nodes & Extraction Foundation

Chat 04 replaced the small building's temporary free-output recipe with real, location-dependent resource extraction. Earlier Chat 03 producer tests remain recorded above as history; the current Test Extractor uses an `ExtractorComponent`, not the original autonomous extraction recipe.

### Resource-Node Data and World Scene

Created:

- `res://scripts/data/resource_node_definition.gd` — `ResourceNodeDefinition` data schema.
- `res://data/resource_nodes/test_ore_deposit.tres` — Test Ore Deposit definition, linked to `Test Ore`.
- `res://scripts/components/resource_node_runtime.gd` — `ResourceNodeRuntime` instance state and extraction API.
- `res://scenes/resource_nodes/TestOreDeposit.tscn` — selectable test deposit with mesh, collision, and runtime component.

Definitions contain an ID, display name, description, `ItemDefinition`, `infinite_resource` flag, and `starting_amount`. Runtime nodes track `remaining_amount` and provide `extract(amount) -> int` so callers receive only the quantity actually available.

Tested **infinite deposits** (no depletion) and **finite deposits** (supply decreases and production stops at zero). The prototype Test Ore Deposit is configured for infinite supply by default; the starting amount is retained for finite-mode testing.

### Extractor Component and Inventory

Created `res://scripts/components/extractor_component.gd`.

The small test building now has:

- `BuildingRuntime` and its own `InventoryComponent`.
- `ExtractorComponent` with configurable extraction amount and interval (prototype defaults: 1 unit / 1 second).
- `ExtractionArea` (`Area3D`) using a 2.5-unit-radius detection shape and Layer 2 collision mask.

The component identifies nearby deposits through their `ResourceNodeRuntime`, requests resources from `extract()`, and adds the returned amount to the building's inventory. Without an in-range deposit, the extractor does not produce resources. Different placed extractors continue to hold independent inventories.

### Extractor-Specific Placement Rule

Updated `res://scripts/world_interaction.gd` so physical occupancy and resource access are separate checks:

- Physical building collision shapes are tested against placement blockers (Layer 3).
- A placement ghost with `ExtractorComponent` additionally queries its extraction shape against resource-node colliders (Layer 2).
- Extractor placement is red/invalid without a reachable resource deposit and green/valid when one is in range.
- Buildings without `ExtractorComponent`, including Test Building Large, remain placeable without ore.

The placement ghost still has gameplay processing disabled so previews do not run extraction.

### Debug HUD and Selection

Extended `res://scripts/production_debug_hud.gd`:

- Selected deposits show resource name and infinite supply or finite remaining/starting supply.
- Selected extractors show building name, extractor type, status, resource name, and live inventory quantity.
- Status differentiates **No Resource In Range**, **Extracting**, and **Resource Depleted** where applicable.
- Existing non-extractor building and empty-selection behavior remains available.

The resource deposit retains normal selectable-object highlighting.

### Prototype Naming and Asset Cleanup

Renamed the small prototype into a named extractor:

- `scenes/buildings/test_building.tscn` → `scenes/buildings/test_extractor.tscn`
- `data/buildings/test_building.tres` → `data/buildings/test_extractor.tres`
- Scene root `TestBuilding` → `TestExtractor`
- Building ID `test_extractor`, display name **Test Extractor**, category **Extraction**

Removed the obsolete `res://data/recipes/prototype_extraction.tres` asset after reference checks and a successful gameplay test. Kept the reusable `ProducerComponent`, `ProductionRecipe`, and `ItemAmount` framework for future manufacturing machines.

### Troubleshooting and Fixes

- **Unexpectedly large no-build area:** The placement ghost originally treated the extractor's spherical `ExtractionArea` collision as a physical building footprint. Changed footprint tracking to include only `CollisionShape3D` nodes belonging directly to `PhysicsBody3D`; detection-area shapes are not placement blockers.
- **Missing placement validator during editing:** Restored `_is_placement_clear()` after an intermediate script edit removed it.
- **GDScript indentation errors:** Corrected mixed/incorrect indentation around the extractor rule and ghost-color branches; retained tabs throughout the script.

Detailed fixes belong in `TROUBLESHOOTING.md`.

### Final Regression Test — Passed

Verified together:

- WASD panning and mouse-wheel zoom.
- Normal selection, highlight, and HUD updates.
- Build Mode, building-slot switching, rotation, valid/invalid ghost feedback, and placement.
- Extractor blocked away from ore and placeable near a deposit.
- Extraction transfers real resources to the placed extractor inventory.
- Infinite supply information and finite-depletion behavior.
- Large Test Building remains usable without nearby deposits.
- Demolition and protection of non-player-built objects.
- No new Godot debugger errors in the final gameplay check.

### Milestone Status

**Chat 04 — Resource Nodes & Extraction Foundation: Complete.**

Next planned work: basic inventory storage and simple item transfer/logistics, followed by recipe inputs, further factory systems, and the first zombie/defense prototype.

---

## 2026-10-20 — Chat 05: Storage & Basic Factory Logistics

**Milestone status: Complete.** Gameplay implementation and final manual regression tests passed in Godot 4.6.2 Stable.

### Inventory Capacity & Safe Item Accounting

- Extended `InventoryComponent` with a shared item-count `max_capacity` (0 = unlimited), `get_total_amount()`, `get_available_space()`, and `is_full()`.
- `add_item(item, amount) -> int` accepts only the quantity that fits and returns the actual amount stored.
- Made `ExtractorComponent` check free inventory capacity *before* extracting from finite deposits; full inventories no longer consume ore.
- Implemented `InventoryComponent.transfer_to(destination, item, amount) -> int` with source availability checks, destination capacity limits, partial transfers, self-transfer rejection, and rejected-item restoration.

### Dedicated Storage Building

- Added `scenes/buildings/test_storage.tscn` and `data/buildings/test_storage.tres`.
- Reused `BuildingRuntime`, `InventoryComponent`, selectable-object highlighting, placement collision, rotation, and demolition.
- The storage prototype has a rectangular 1.0 × 1.0 × 2.8 mesh/collision footprint and default capacity **200**.
- Added `logistics_storage` to the actual storage building root; retained `selectable` and `player_built`.
- Registered storage in `WorldInteraction.buildable_definitions`; key **3** selects storage, alongside key **1** Test Extractor and key **2** Large Building.
- Updated the Build HUD to show and highlight all three options.

### Automatic Logistics

- Added `scripts/components/logistics_transfer_component.gd` to Test Extractor as a sibling of its inventory/extractor components.
- Configured `transfer_item` (Test Ore), `transfer_amount = 5` per cycle, `transfer_interval = 1.0` second, and `transfer_range = 5.0` world units.
- The component selects the nearest eligible `logistics_storage` group member by **building-origin distance**, ignoring full destinations, missing inventories, queued-for-deletion nodes, and disabled placement ghosts.
- Nearby inventories receive up to the configured amount each cycle using `transfer_to()`; actual throughput depends on ore availability.
- Status tracking reports `Initializing`, `Transferring`, `Waiting for Resources`, or `No Eligible Storage`, with last attempt and last successful transfer quantities. `No Eligible Storage` currently covers both out-of-range and full storage.

### Production Debug HUD

- Added storage totals, capacity used, and an `INVENTORY CONTENTS` listing by `ItemDefinition`.
- Added extractor inventory capacity/full status and a `LOGISTICS STATUS` section with configured maximum transfer rate, latest attempt amount, and last successful amount.
- Preserved resource-node remaining/starting amounts and existing selection behavior.
- The `Status: Extracting` line currently indicates a valid ore source, not necessarily active mining when inventory is full; this wording is a future refinement.

### Tests and Observed Results

- An isolated Godot inventory test passed partial transfer, full destination, empty source, and invalid/self/zero-quantity transfer cases.
- Gameplay checks passed extraction, proximity-limited storage discovery, timed transfers, HUD updates, blocked transfers at storage capacity, extractor accumulation when storage is full, and existing placement/rotation/selection/demolition behavior.
- **Final finite-resource conservation test:** starting deposit **500**, remaining deposit **250**, extractor inventory **50/50**, storage inventory **200/200**. Total: **250 + 50 + 200 = 500**.
- The committed `data/resource_nodes/test_ore_deposit.tres` is currently set to a **finite 500-unit** test deposit; this is a testing configuration, not a finalized economy choice.
- Storage capacity was restored to **200** after short capacity-limit tests.

### Scope and Follow-Ups

This is a proximity-based, direct inventory transfer prototype—not a visible conveyor network. Conveyor belts, routing/ports, multi-machine flow, power, production input consumption, and refined logistics statuses remain future work.

The tested source/scenes were committed and pushed to `main` before this documentation update.

---

## 2026-10-20–21 — Chat 06: Production Inputs & First Manufacturing Chain

**Milestone status: Complete.** First automated ore-to-ingot manufacturing chain implemented and tested in Godot 4.6.2 Stable. Gameplay changes were committed and pushed to `main` before this documentation entry.

### Architecture Review and Decisions

- Preserved the existing data-driven `BuildingDefinition`, `BuildingRuntime`, `ItemDefinition`, `ItemAmount`, `ProductionRecipe`, and `InventoryComponent` architecture rather than introducing a parallel manufacturing system.
- Chose **separate input and output inventories** for manufacturing machines before implementation, preventing raw materials and finished products from competing for the same capacity.
- Configured the Test Smelter with `InputInventory` capacity **50** and `OutputInventory` capacity **100**, both using independent instances of the existing `InventoryComponent`.
- Agreed that all machines that extract or manufacture items should expose understandable operating statuses and a reusable, live activity progress indicator. Pure storage buildings have no processing progress bar.

### Safe Recipe-Based Manufacturing

Extended `scripts/components/producer_component.gd` with:

- `input_inventory` and `output_inventory` references for independent material buffers.
- `has_required_inputs()` to validate nonempty recipes, required quantities, and duplicate ingredient entries without consuming items.
- `can_store_recipe_outputs()` to reject missing/invalid outputs and ensure **all** output units fit within output inventory capacity.
- `try_complete_recipe_cycle()` to check inputs and output space, consume recipe ingredients, create finished products, and report success only for a complete cycle.
- `_rollback_recipe_cycle()` to attempt recovery if a synchronous removal or output addition unexpectedly fails; normal and blocked paths passed tests. Exceptional rollback-failure scenarios remain a future hardening area.
- A guarded timed production loop that advances only when inputs and output space are available; otherwise it resets progress and exposes statuses such as `Waiting for Inputs` or `Output Blocked`.
- Removal of the obsolete output-only production method that could generate items without consuming inputs.

For the first recipe, `data/recipes/test_smelting.tres` transforms **2 Test Ore → 1 Test Ingot** in a **2-second** production cycle. The new permanent output item is `data/items/test_ingot.tres`.

### Test Smelter Building

Added:

- `scenes/buildings/test_smelter.tscn`
- `data/buildings/test_smelter.tres`

The Test Smelter uses reusable selection, collision, rotation, placement, and demolition behavior, plus these child components:

- `BuildingRuntime`
- `InputInventory` (50)
- `OutputInventory` (100)
- `ProducerComponent`, with references to the smelting recipe and both inventories
- `LogisticsInputComponent`

Registered the smelter as construction option **4** by adding `select_building_4` to `project.godot`, adding the definition to `WorldInteraction.buildable_definitions`, and extending the Build HUD to render and highlight `[4] Test Smelter`. Existing slots 1–3 continue to work.

### Storage-to-Smelter Input Logistics

Implemented `scripts/components/logistics_input_component.gd` as a separate reusable component so the existing extractor-to-storage transfer logic remains intact.

- Searches the `logistics_storage` group for the nearest eligible stocked storage building using building-origin distance.
- Ignores out-of-range candidates, invalid inventories, deletion-queued objects, and disabled placement ghosts.
- Requests the configured `ItemDefinition` from nearby storage via the established `InventoryComponent.transfer_to()` method; it does not create items.
- Uses default configuration: Test Ore, **up to 5 units per attempt**, **1-second interval**, **5-world-unit range**, and a **10-ore input buffer target** (independent of the physical 50-unit input capacity).
- Reports transfer status and recent quantity for debugging.

**Working automated flow:** finite Test Ore Deposit → Test Extractor → Test Storage → Test Smelter input → timed smelting → Test Smelter output (Test Ingots). This is proximity-based, direct inventory movement, not a visual conveyor system.

### Production and Extraction HUD

Enhanced `scripts/production_debug_hud.gd` and `scenes/ui/production_debug_hud.tscn`:

- Selected smelters show recipe, live `production_status`, input ingredient quantities and requirements, input capacity, output item quantities, and output capacity.
- Corrected the original producer HUD assumption that all buildings store items in a child named `InventoryComponent`; smelter results now come from `OutputInventory`.
- Added `InfoContent` and one shared `ActivityProgressBar` under the HUD panel.
- Manufacturing progress reads `ProducerComponent.production_progress / recipe.production_time`.
- Extraction progress reads `ExtractorComponent.extraction_timer / extraction_interval`.
- The indicator resets to 0% when blocked and is hidden for storage, resource deposits, and no selection.

Updated `scripts/components/extractor_component.gd` with an explicit `extraction_status` and timer gating for no deposit, depletion, full inventory, missing data, and invalid intervals. The extractor HUD now displays the component's true status instead of claiming `Extracting` while its inventory is full.

### Tests and Verified Results

Added standalone Godot regression suites:

| Test scene | Result |
| --- | --- |
| `tests/recipe_input_availability_test.tscn` | **8/8 passed** |
| `tests/recipe_output_capacity_test.tscn` | **11/11 passed** |
| `tests/manufacturing_transaction_test.tscn` | **9/9 passed** |
| `tests/timed_manufacturing_test.tscn` | **8/8 passed** |

**Total: 36/36 Chat 06 assertions passed.** Existing Chat 05 inventory-transfer tests (four test groups) also passed during final regression testing.

Gameplay verification also covered key 4 selection, placement, rotation, overlap blocking, selection highlight, demolition highlight/removal, automatic resource transfers, ingot accumulation, and the shared activity progress bar for both extractor and smelter.

**Output-full safeguard:** temporarily set the smelter output capacity to **2**. The HUD showed `Output Blocked`, **2/2** ingots, **10/50** input ore, and **0%** progress. Inputs and outputs remained unchanged while blocked. The output capacity was subsequently restored to **100** and saved.

**Resource conservation:** in a verified single-deposit, finite-500-ore test, **236 remaining in deposit + 50 in extractor + 200 in storage + 10 in smelter input + 2 ingots × 2 ore each = 500 ore equivalents**. A later final end-to-end test was reported successful, though its exact terminal inventory counts were not recorded in chat. No loss or duplication was observed in these tests.

### Troubleshooting and Lessons

- **Placed smelter selected but did not turn gold/red:** `selectable_object.gd` was attached, but the exported `Selection Mesh` reference was unset. Assigning the `BuildingMesh` child resolved normal selection and demolition-hover highlighting.
- **HUD continually reported 0 ingots despite active smelting:** its original lookup used `InventoryComponent`, whereas the smelter stores finished products in `OutputInventory`. Updating the HUD inventory lookup exposed the real count.
- **Build HUD lacked option 4 / did not highlight selection:** registering the input action alone was insufficient; the Main scene definition array and `Building4Label` selection handling also needed updates.
- **Extractor displayed `Extracting` at 50/50:** replaced duplicated, inferred HUD status strings with the component-owned `extraction_status`.
- **Commit hygiene:** removed trailing whitespace before staging and excluded an accidentally created untracked file containing a Git diff summary. The tested gameplay commit was pushed successfully; local Git status was then confirmed clean.

### Scope and Follow-Ups

**Implemented:** first real automated manufacturing recipe, independent machine input/output buffers, buffer-limited input logistics, reusable manufacturing/extraction progress, and end-to-end conservation testing.

**Not implemented yet:** finished-product export from the smelter, dedicated conveyors/inserters/ports, advanced multi-input routing, energy and fuel costs, production upgrades, a finalized player-facing machine panel, or defense/horde mechanics. These remain subsequent development milestones.

---

## 2026-10-22 — Chat 07: Recipe Selection & Recipe-Aware Input Logistics (First Checkpoint)

### Architectural Direction and Scope

After Chat 06, confirmed the intended gameplay is **physical conveyor-based** factory automation feeding ammunition manufacture and colony defense, rather than proximity-based “magic transfers.” The long-term design in [GAME_VISION.md](GAME_VISION.md) calls for selectable manufacturing recipes that determine allowed inputs; universal small, medium, and large storage with slots/stacks; one automatic-turn conveyor placement tool; and **dedicated placeable splitter and merger buildings**. The first zombie-colony world includes structures and settlements associated with enemy spawning; larger logistics systems and additional planets remain later design work.

This Chat 07 checkpoint deliberately implements **recipe rules first**, preserving the short-range logistics chain until belt transport has tested replacements.

### Gameplay Implementation (Steps 07.2A–07.2D)

- `ProducerComponent.available_recipes`: Inspector-configurable list of recipes supported by a machine; the existing `recipe` field continues to represent the active recipe. The Test Smelter registers `test_smelting.tres` in its available list.
- `ProducerComponent.select_recipe(new_recipe)`: validates allowlist, non-null selection, positive production time, and nonempty ingredient/output collections; avoids changing an already-selected recipe. A real change is allowed only with an existing **empty** input inventory. It preserves stored finished goods, resets production progress, and records `Recipe Changed`.
- `ProducerComponent.accepts_input_item(item)`: non-mutating check for a valid, positive-quantity ingredient in the active recipe. Eligibility automatically changes when the recipe changes; this method does not move items or check available space.
- `LogisticsInputComponent.producer_component`: optional-on-disk but **required for working transfers**; linked in the Test Smelter scene. Delivery stops safely with `Producer Missing` or `Item Not Required by Recipe` when the reference/ingredient is incompatible. The original Test Ore transfer rate, buffer and manufacturing logic were retained.
- Changes were edited and tested locally in Godot 4.6.2 and pushed successfully by the developer to GitHub `main`.

### Tests and Verification

| Scene / check | Reported result |
| --- | --- |
| `tests/recipe_selection_test.tscn` | **10/10 passed** |
| `tests/recipe_input_acceptance_test.tscn` | **6/6 passed** |
| `tests/recipe_logistics_acceptance_test.tscn` | **5/5 passed** |
| Chat 06 recipe input, output capacity, manufacturing transaction, and timing tests | **36/36 passed** |
| Chat 05 inventory transfer regression | **Passed** (existing groups) |
| Main game: extraction, storage-to-smelter supply, smelting, HUD, placement and demolition | **Passed** |

**Total of 21 new Chat 07 assertions/groups and 36 earlier manufacturing assertions reported passing.** This checkpoint added no resource-conservation failure or game regression in the user-run tests. Tests were performed in the Godot editor, not in GitHub CI.

### Troubleshooting and Cleanup

- An isolated recipe-aware logistics test initially printed automatic transfer messages *after* its PASS banner. Resolved by disabling both the logistics and producer nodes' frame processing after scene insertion, manually invoking transfer attempts, and queueing temporary buildings for deletion before final results.
- A subsequent GDScript parser error (`Used space character for indentation instead of tab`, including around line 83) came from space indentation inserted into a tab-indented test script. Replacing affected leading whitespace with one tab inside `_ready()` resolved it; the test reran successfully with **5/5** passes and no trailing transfer messages.

### Current Boundaries / Next Work

- The Test Smelter still has **one configured permanent smelting recipe**; no production selection UI or additional persistent ore/ammunition recipes have been added.
- Ingredient eligibility is separate from physical insertion. Dynamic or multi-ingredient conveyor admission, stack/slot capacity, and input/output port behavior are still to be designed and tested.
- Short-range transfers are temporary scaffolding, not final gameplay logistics. Finished ingots remain in the smelter output inventory until belt transport and destinations are implemented.
- Next focus: review and incrementally design machine input/output ports and admission/hand-off contracts for later conveyors, while retaining current regressions and the First Night ammunition-and-defense objective.

---

## 2026-10-22 — Chat 07: Physical Port Foundation & Logical Handoffs (Second Checkpoint)

### Implementation (Steps 07.3A–07.3E)

- Created reusable `scripts/components/item_port_component.gd` (`ItemPortComponent extends Marker3D`) with `INPUT`/`OUTPUT` directions, recipe-specific vs universal item acceptance, and explicit inventory and optional producer references.
- Implemented **read-only** `can_accept_item()` (recipe eligibility, full-request available capacity, input role and correct inventory) and `can_provide_item()` (output role, item availability and output-inventory identity).
- Attached sibling `InputPort` and `OutputPort` `Marker3D` nodes to `scenes/buildings/test_smelter.tscn`, positioned on opposite X faces at local `(-0.85, 0.5, 0)` and `(0.85, 0.5, 0)`; oriented Y `+90°` and `-90°`. Bound InputPort to `InputInventory` and OutputPort to `OutputInventory`, each referencing `ProducerComponent`.
- Added `try_transfer_to_port()` to guard destination role, self-transfer, ingredient acceptance, source availability, requested capacity, then delegate accounting to `InventoryComponent.transfer_to()`. Failed prechecks return zero without changing inventories.
- Proved the complete *manual* workflow on a real Test Smelter: initial six ore in source, two ore supplied per cycle, two smelting cycles produce two ingots; one goes to capacity-1 storage and a second remains in the output buffer when storage is full; source retains two ore. Total **6 ore equivalents** conserved.

### Validation and Regression Checkpoint

| Test scene or coverage | Developer-reported result |
| --- | --- |
| `item_port_foundation_test.tscn` | **7/7 passed** |
| `item_port_integration_test.tscn` | **8/8 passed** |
| `item_port_transfer_test.tscn` | **7/7 passed** |
| `item_port_real_smelter_test.tscn` | **7/7 passed** |
| Earlier Chat 07 recipe selection / acceptance / logistics | **21/21 passed** |
| Earlier Chat 06 manufacturing suite | **36/36 passed** |
| Inventory transfer regression | **Passed** |
| Main extractor → storage → smelter production, interactions and HUD | **Passed** |

**29/29 new port tests**, **21/21 earlier Chat 07 recipe tests**, and **36/36 previous manufacturing checks**: **86 checks** across those named groups, in addition to inventory-transfer and gameplay regressions. These are reported local Godot 4.6.2 test runs, not GitHub Actions results. The developer confirmed the port milestone gameplay/test files were pushed successfully to GitHub `main`.

### Architecture Decision and Boundaries

The port component currently exposes a safe **logical transfer**, not a physically connected network. There are no placed conveyors, connection/adjacency validation, route selection, belt throughput timing, storage slot/stack layout, or automatic ingot export from the smelter. Existing proximity transfers were intentionally retained in the playable prototype.

The next incremental development priority is **connection validation between oriented ports and future directional belt segments**, followed by test-first belt placement/connection and item movement. Dedicated splitters and mergers remain distinct planned placeable buildings. Ammunition manufacture feeding defensive structures and a zombie colony First Night remains the primary game loop objective.

---

## 2026-10-24 — Chat 07: Straight Conveyor Geometry, Snapping and Placement (Third Checkpoint)

### Implemented Features

- Built LogisticsConnectionGeometry for independent world-space distance, facing and forward alignment tests.
- Added ConveyorStraight scene with BeltMesh and input/output Marker3D endpoints; item flow will be local +Z → -Z, but item movement is NOT implemented.
- Added ConveyorSegment previous/next links, strict 0.05-unit connect tolerance, and safe disconnect/scene exit cleanup.
- Implemented automatic snap-after and snap-before calculations, including nonmutating ghost preview transforms and occupied-endpoint guards.
- Added Conveyor Belt building definition, key 5 and HUD slot while preserving the original four buildings.
- Integrated nearest-compatible-endpoint search in WorldInteraction and permanent snapped placement that creates exactly one belt before returning to regular building logic.
- Added steel-gray placeholder material, selection and demolition visual methods, and separate Layer 2 Area3D input hitbox and Layer 3 placement-blocking body.

### Testing

| Scene | Developer-reported checks |
| --- | --- |
| logistics_connection_geometry_test.tscn | **8/8** |
| conveyor_alignment_test.tscn | **9/9** |
| conveyor_connection_state_test.tscn | **8/8** |
| conveyor_snapping_test.tscn | **5/5** |
| conveyor_snap_preview_test.tscn | **5/5** |
| conveyor_snap_before_test.tscn | **5/5** |

**40/40 conveyor checks passed.** The developer also confirmed successful real-game snap-before and snap-after placement, rotation, selection, demolition and unchanged factory manufacturing. The local milestone was pushed to GitHub main. These are Godot 4.6.2 editor tests, not a CI run.

### Bugs Resolved and Lessons

- An early failed ConveyorSegment cast assertion was caused by attaching the wrong script to the conveyor scene root. Attaching conveyor_segment.gd to ConveyorStraight resolved it.
- The conveyor mesh initially appeared dark; an explicit material fixed the appearance.
- Mouse selection/demolition was initially inaccurate due to collision shapes offset from the visible mesh. Values meant for Shape Size had been entered as node Transform Position. Correcting parent/child positions and using a separate interaction Area3D produced correct gold and red highlights and reliable deletion.
- A temporary placement guard intentionally printed "Conveyor snap preview only — placement not enabled yet" until connecting on click was implemented. The permanent snapped-placement branch must execute **before** the normal building instantiation to avoid duplicate objects. Final logs showed success for Before: false and Before: true.
- Perpendicular belts can look like a corner but do not yet provide a functional turn; visual touch is not a connection.

### Remaining Work

True corner scenes/automatic turn geometry, direct machine-port connections, item motion/throughput/backpressure, universal slot-based storage, and ammunition/defense remain planned. Proximity logistics is still the active resource-delivery mechanism.

**Nonblocking code-review cleanup:** The committed InteractionHitbox BoxShape3D lacks an explicit size override (so Godot uses its default cube), and its CollisionShape3D has slight Y rotation. The gameplay test passed, but normalize these when designing exact corners. A redundant conveyor_snap_source reset near the end of world_interaction.gd can also be removed during a later cleanup.

---

## 2026-10-27 — Chat 07.5: Automatic Conveyor Turns, L-Shaped Visuals and Direction Indicators (Fourth Checkpoint)

### Construction and Connection Changes

- Added `scenes/logistics/conveyor_corner.tscn` and `conveyor_corner_left.tscn` with oriented endpoints; developed safe right/left corner chains and rotation/connection tests.
- Added `ConveyorTurnIntent` and `ConveyorPieceSelector` as helpers for turn classification and shape references. The settled build interaction is **not** a mouse-selected corner ghost: it uses a normal straight preview through the single Conveyor Belt tool (key 5).
- Added `ConveyorCornerConversion.try_convert_and_connect()`: when a new perpendicular straight belt is correctly oriented next to an eligible straight belt's free output, the **existing belt** changes into a corner in place. Its identity and incoming connection remain intact; occupied outputs, invalid turns and misaligned endpoints fail without consuming an existing link.
- `WorldInteraction` integrates the perpendicular neighbor detector with normal placement, alongside the existing straight snap-before/after route. Successful turns report `AUTO CORNER SUCCESS | Turn: RIGHT/LEFT`.
- Added `ConveyorCornerVisualMesh` to provide gray L-shaped placeholder geometry. The version committed at this checkpoint merges **two rectangular arms** with SurfaceTool and uses width 0.8, height 0.2, arm length 0.6 and offset 0.2. Screenshots show usable filled-looking bends; a truly unified polygonal top and exact seam/collider matching remain refinements.
- Added `DirectionArrow` beneath `ConveyorStraight/OutputEndpoint`. Its unshaded yellow arrow follows each segment's actual output marker: straight belts, green construction ghosts, and corners converted in place show flow direction even before item motion is implemented.

### Validation Evidence (Local Godot Editor)

| Test or manual check | Reported/observed outcome |
| --- | --- |
| Right-corner scene connection and demolition | 8/8 |
| Left-corner scene connection and demolition | 8/8 |
| Corner snap-preview geometry | 6/6 |
| Conveyor turn intent | 8/8 |
| Conveyor piece selector | 8/8 |
| In-place corner conversion | 8/8 |
| Connected conveyor full-chain regression | 8/8 |
| L-shaped corner visual mesh regression | 8/8 |
| Main game: right/left auto-corners, extended straight chains, rotated layouts | Successful screenshots/output |
| Green preview direction arrow, selection, demolition, collision overlay | Successful user inspection |

The individual test outcomes were shared over several steps; **no claim is made that every old and new test was rerun together**. No GitHub CI run is claimed. The developer subsequently showed `main` synchronized to `origin/main` with a clean working tree; the new source files and tests were verified in the remote repository.

### Problems, Decisions and Remaining Scope

- Multiple apparently incorrect 90° placements were caused primarily by **ambiguous visual direction**: a plain rectangular belt looks identical at 90° and 270°, even though their outputs face opposite world directions. Visible arrows clarified valid orientation. Positive Y rotations in Godot do not necessarily match a player's intuitive notion of rotating right; retain endpoint-facing checks rather than accepting opposite-facing connections.
- Snapping after a converted corner must use its **OutputEndpoint world basis**, not only the segment root basis, because a corner's output is rotated relative to its root.
- A visual ring of belts is not proof of a closed directed graph. The final already-existing endpoint-to-endpoint loop connection needs separate gameplay integration and validation.
- The initial corner had narrow or missing-looking bend regions. The revised arm widths improve continuity, but the committed mesh still uses two joined boxes; exact continuous visual surfaces, collision/hitbox shape cleanup, and edge seams can be refined without changing established logistics links.
- **Not implemented:** item movement along conveyors, throughput, backpressure, belt-to-machine/storage port hookup, autonomous finished-product export, or dedicated splitter/merger buildings. The extractor → storage → smelter still runs on temporary proximity-based logistics.

**Next milestone:** validate final construction/connection regressions, improve precise hitboxes and corner surfaces, implement safe existing-belt loop closure, then introduce machine/storage port-to-belt links and conservation-tested conveyor item flow.

---

## 2026-10-27 — Chat 08: Generic Belt-to-Belt Transport Foundation (First Milestone)

### Implemented

- Created `ConveyorTransportComponent` with a strict one-unit `CargoInventory` buffer. All item operations use `ItemDefinition` and existing `InventoryComponent.transfer_to()`; no resource-specific belt behavior is hardcoded.
- Created `ConveyorTransportLink.try_transfer_forward()` to require reciprocal directed belt links and current endpoint alignment before handing off cargo.
- Created `ConveyorTransportTimer` with a configurable 1.0-second prototype travel interval and frame-driven update. A full/disconnected downstream belt blocks the current item without duplication or loss; movement resumes once there is space.
- Added `CargoInventory`, `ConveyorTransportComponent`, and `ConveyorTransportTimer` as direct children of the live `ConveyorStraight` scene, leaving existing snapping, arrows and corner-conversion geometry untouched.
- Verified that converting a straight belt into either automatic corner preserves the node, the held item, and the timer's partial progress.
- Added `ConveyorSegment.can_demolish_safely()` and a guard in `WorldInteraction` so **player demolition** rejects occupied or invalidly configured conveyor cargo buffers.

### Reported Local Godot Results

| Test | Checks |
| --- | --- |
| Cargo buffer | 7/7 |
| Connected directed transfer | 7/7 |
| Timed generic transport | 8/8 |
| Corner cargo preservation | 8/8 |
| Six-segment full chain | 8/8 |
| Player demolition safety policy | 6/6 |
| **Total across six separate suites** | **44/44** |

The updated connected (7/7), timed (8/8) and original full-chain construction (8/8) regressions were rerun after scene integration. The developer also confirmed normal game placement, rotation, yellow arrows, right/left corners, empty-belt demolition, and the original extractor → storage → smelter chain still worked. These are developer-run editor validations, **not a single combined CI report**.

### Important Design Decisions and Remaining Work

- **Universal cargo:** belts accept any valid `ItemDefinition`; receiving manufacturing ports will filter using the active recipe, while general storage accepts ordinary items subject to capacity.
- **Strict physical links:** automatic belt handoffs must use directed, geometry-valid next/previous connections; the low-level inventory helper alone is not an authorization to transfer.
- **Prototype throughput:** each segment currently carries one item unit and uses a 1-second interval; final belt occupancy, speed, visible travel interpolation and throughput balance remain open.
- **Safety scope:** only demolition through `WorldInteraction` is cargo-blocked. Direct `queue_free()`, scene teardown and eventual enemy destruction need a cargo recovery/dropping policy.
- **Not yet a physical factory:** no building-to-belt snap/load/unload path, visible cargo models, separate splitter/merger, intentional closed-loop closure or automated ingot export. Temporary proximity logistics remains active.

The user committed and pushed the tested gameplay milestone to GitHub `main` before this documentation update. **Next milestone:** visible generic cargo on belts, then machine/storage port connections and full ore-to-ingot physical routing, with regression checks at each step.

---

## 2026-10-27 — Chat 08: Visible Cargo, Building Connections and Physical Factory Test (Second Milestone)

### Implemented & Tested

- Created `ConveyorCargoVisual` as a read-only `MeshInstance3D` placeholder. The real ConveyorStraight scene now has a `CargoVisual` child, hidden when empty and interpolating from input to output along straight belts or an L-shaped local path on converted left/right corners. The carried `ItemDefinition` is generic; distinct item-specific artwork is not implemented yet.
- Added `OutputPort` to `test_extractor.tscn`, referencing the extractor's existing 50-unit inventory. Existing Test Smelter input/output ports continue to use the producer's selected recipe and separate inventories.
- Added `ConveyorBuildingSnap` to calculate read-only building-port snap transforms for either port direction and rotated buildings; extended it to reject occupied building and belt endpoints.
- Added reciprocal `connected_conveyor` / `input_building_port` / `output_building_port` references with alignment checks, exclusive connection ownership and cleanup on endpoint removal. Geometric alignment alone does not authorize transferring items.
- Added `ConveyorBuildingTransfer` for generic one-item output loading and guarded input unloading. Active-recipe filtering rejects irrelevant materials, full destinations retain cargo, and all transactions use conservation-aware InventoryComponent methods.
- Updated `ConveyorTransportTimer` to automatically load empty belts from connected output ports and to unload after the travel interval into connected input ports; forward belt-to-belt transfers, congestion retention and recovery remain available.
- Verified a real Extractor and Smelter with a three-belt route: **2 Test Ore seeded in the extractor → physically carried to Smelter → 1 Test Ingot manufactured**, with manual deterministic timer and producer updates and proximity/extraction processing disabled.

### Local Godot 4.6.2 Test Record

| Test scene | Result |
| --- | --- |
| `conveyor_cargo_visual_test.tscn` | 6/6 |
| `conveyor_corner_cargo_visual_test.tscn` | 8/8 |
| `extractor_output_port_test.tscn` | 7/7 |
| `conveyor_building_snap_test.tscn` | 10/10 (after occupancy expansion) |
| `conveyor_building_connection_test.tscn` | 8/8 |
| `conveyor_building_loading_test.tscn` | 9/9 |
| `conveyor_building_unloading_test.tscn` | 10/10 |
| `conveyor_automatic_unloading_test.tscn` | 9/9 |
| `conveyor_automatic_loading_test.tscn` | 10/10 |
| `conveyor_physical_factory_test.tscn` | 9/9 |
| **Second milestone subtotal** | **86/86** |

With the first milestone **44/44**, Chat 08 now has **130/130 reported checks over individually run suites**. Connected/timed/full transport and automatic unloading regressions were rerun successfully during development. The final physical factory integration test passed 9/9, and the developer pushed the changes to `main`. No single consolidated CI run is claimed.

### Problems Resolved

- `CargoVisual` initially had the **test script** (`conveyor_cargo_visual_test.gd`) attached instead of `conveyor_cargo_visual.gd`, producing a stack overflow during scene initialization. Assigning the correct component script restored passing straight/corner visual tests.
- An explanatory pseudo-code example was accidentally pasted at the bottom of `conveyor_building_transfer.gd`, duplicating `extends RefCounted` and `class_name` declarations. Removing that sample and appending only the complete top-level `try_unload_from_belt()` function corrected the file.
- The `conveyor_building_unloading_test` script/scene were initially missing; they were created separately and the new unloading test passed 10/10. `Extractor has no resource node` appeared in isolated tests because no deposit was instantiated; it was not a port/transport failure.

### Boundaries and Next Work

- The normal player factory does **not yet snap belts to building ports through Build Mode**. The completed physical route exists in an isolated test which positions and connects its actors in code, seeds ore instead of mining, and manually drives timers.
- The temporary Extractor → Storage → Smelter proximity logistics remains enabled in normal gameplay. It must be gated or replaced only after safe physical routes and regression coverage exist, to prevent overlapping transfer systems.
- Test Storage still needs dedicated universal input/output ports and a validated complete physical route via storage. Further tests should cover multiple simultaneous items, throughput and transfer order under frame-driven updates.
- The generic orange placeholder is common to all item definitions; distinct item visual models, splitter/merger buildings, explicit loop closure, improved corner colliders and cargo recovery for non-player destruction remain open.

**Next milestone:** integrate building-port preview/connection into `WorldInteraction` carefully, test player-created Extractor → Belt → Smelter networks, and add Storage port support before switching off proximity logistics.

---

## 2026-10-27–30 — Chat 08.3F–08.3G: Player-Built Physical Logistics, Grid Alignment and 1×1 Routing Buildings

### Goals and design decisions

The user identified recurring final-junction failures while building a real Extractor → Storage → Smelter route and returning belts to previously placed factories. Core decisions:

- **Construction order should not matter** when the endpoints and turn direction are actually compatible.
- **Conveyors remain physical:** no magical item movement or forced joining of visually touching but incompatible arrows.
- Use a **shared 1-unit factory grid**, taking rotated footprint parity into account, instead of independently rounding buildings and conveyors.
- Support correct final connections with new missing corners, in-place source or receiver corner conversion, exact bridges, fractional straight spans and offset L-shaped connectors.
- Dedicated **Merger**/**Splitter** are not ordinary belt turns. Final prototypes are each **1×1** with a port on every side: **3 IN → 1 OUT** and **1 IN → 3 OUT** respectively.
- Keep inventories bounded, preserve cargo and existing building links, and reject invalid occupancy rather than overwriting old connections.

### Major construction features committed

1. **Smelter dual-port and building port foundation:** Independent input/output ports, directed build previews, building-to-existing-belt snapping and reciprocal links. In-game logs showed successful building hookups and ore/ingot movement.
2. **Conveyor bridge and corner discovery:** Read-only previews, collision/endpoint revalidation on click, separate missing-corner and existing-receiver/source conversion paths, and safe two-ended bridge commits. The user reproduced prior impossible loop-closure cases and verified automatic corners connecting successfully.
3. **`FactoryGrid` consistency:** Footprint-aware odd/even building origins, rotated grid lanes and shared coordinate tests. All current building types use grid-aware placement; placement snap-to-belt rejects transforms that would put a new building off-grid.
4. **Fractional/offset geometry:** `conveyor_fractional_bridge.gd` and `conveyor_offset_corner_bridge.gd` construct actual cargo-carrying variable-length straight and L-shaped segments, with properly adjusted endpoints, physics and selection hitboxes. These resolve half-tile Extractor spacing and small perpendicular gaps when free endpoints are directionally compatible.
5. **Constant physical item speed:** `conveyor_path_motion.gd` scales connector travel time according to path length and allocates corner interpolation proportionally to each leg. A developer live check confirmed that ore moved at the same apparent speed over short and regular belts after the change.
6. **1×1 routing buildings:** `conveyor_merger.tscn` with `ConveyorMergerComponent` has three separate input buffers and a single output; `conveyor_splitter.tscn` with `ConveyorSplitterComponent` has one input and three independent bounded output buffers. Both route fairly under backpressure and require physical connections. Build Mode uses **6** for Merger and **7** for Splitter.
7. **Diagnostics and safe demolition:** Production Debug HUD shows port connections, input/output buffer quantities and per-lane completed transfer counters. Full Merger/Splitter buffers block unsafe player demolition; standard cargo-bearing conveyors retain their cargo-protection rules.

### Reported validation (Godot 4.6.2 Stable, local)

| Checkpoint | Reported outcome |
|---|---|
| Original Smelter dual-port snap | 8/8 |
| Dual-ended conveyor bridge | 11/11 |
| Bridge discovery | 10/10 |
| Factory-grid alignment (progressively expanded) | 9/9 early; latest suite covers five building types and 52 rotated lanes |
| Existing endpoint/connection and receiver-corner work | Individual suites passed; regression runs also reported |
| Existing receiver auto-snap | 11/11 |
| Building-safe source corner auto-snap | 10/10 |
| Fractional straight connector | Initial 10/10; additional later assertions passed after Build Mode and speed changes |
| Offset L-shaped connector | Initial 10/10; additional later assertions passed after constant-speed correction |
| 1×1 Merger: 3 inputs, 1 output | 10/10 |
| 1×1 Splitter: 1 input, 3 outputs | 10/10 |
| Live Splitter production | **13 completed splits**, `To A: 5`, `B: 4`, `C: 4`; three physically connected output ports |

These are **reported individual test runs**, not a single scripted or CI-based full regression. Exact test-scene names and a reproducible acceptance sequence are in [CHAT_08_FINAL_REGRESSION.md](CHAT_08_FINAL_REGRESSION.md).

### Important troubleshooting and lessons

- A translucent conveyor ghost can be visually correct but still fail to commit; always distinguish *snap discovery* from validated permanent connection.
- Opposite-facing/free endpoints are essential. A corner may redirect a single flow but cannot safely combine two occupied incoming branches.
- The first Merger design used a 2×2 body whose output center could sit between grid lanes; it was replaced by the final 1×1, four-port layout.
- Short conveyor segments taking the same interval as regular 1-unit belts looked slower; constant distance-based timing fixed the visual inconsistency without changing inventories.
- A busy Merger may stall because **three supplies share one bounded output**, not because a building-input port was disconnected. Per-lane counts and output occupancy must be inspected together.
- Before editing a long controller script, locate changes by major section headers, inspect parser errors at their first occurrence, and use discrete test scenes as regression gates.
- GitHub file edits can trigger Godot's “newer on disk” prompt; preserve unsaved edits and reload the pulled scene resources.

### Current acceptance status and remaining work (2026-10-30)

**Completed and observed:** Physical conveyor connections, short-gap placement, constant cargo speed, 1×1 Merger construction with three connected incoming lanes, and three-way Splitter cargo distribution in the main game. The developer reported the latest grid/Merger/Splitter isolated tests all passing.

**Not yet fully observed:** The 1×1 Merger's live **`From A`, `From B`, `From C`** counters all progressing during a sustained three-input/one-output production run. In particular, a paused input must be distinguished from a full output buffer; do not claim final full Merger acceptance solely from construction screenshots.

**Remaining release gate:** Run the critical scenes as a single final manual regression pass, verify Merger backpressure/recovery, confirm full deposit-driven physical mining→smelting→destination delivery without double counting retained proximity scaffolding, and inspect collision/selection/demolition behavior. Then create the final accepted GitHub checkpoint.

**Future product goals:** Gradually retire prototype proximity logistics with conservation checks, cargo recovery for destructive events, universal tiered slot/stack storage, polished visual cues, ammunition manufacture, defense and zombie First Night gameplay.

---

## 2026-10-30 — Chat 08 Final Logistics Acceptance Checkpoint (Core Systems)

### Final manual regression

The developer ran **all 20** enumerated Godot `F6` test scenes over **four rounds of five tests**, confirming every round passed. Covered grid alignment and rotated ports; three-input Merger and three-output Splitter; existing and missing corner conversion; endpoint discovery; two-ended and fractional/offset bridges; cargo path visuals; automatic machine loading/unloading; and isolated physical ore-to-ingot transport.

**Evidence status:** These are developer-reported local editor results, not one automated GitHub CI run. See [CHAT_08_FINAL_REGRESSION.md](CHAT_08_FINAL_REGRESSION.md) for the exact scene list.

### Live gameplay completion

- **Merger (1×1, 3 IN / 1 OUT):** Three connected source routes showed physical item transport; developer subsequently confirmed Merger operation in the live factory. Detailed `From A/B/C` HUD values were not separately captured.
- **Splitter (1×1, 1 IN / 3 OUT):** Live Production Debug HUD captured **13 successful splits**, distributed A=5, B=4, C=4; all three output ports connected.
- **Backpressure:** Developer explicitly confirmed that the Merger retained cargo under blocked-output conditions and resumed after space became available.
- **Ore-to-ingot production:** Developer explicitly confirmed a fully working ore-to-ingot factory chain in gameplay, beyond the earlier seeded isolated physical factory test. No numerical end-to-end resource-conservation snapshot was supplied for this new run.

### Milestone decision

**Core Chat 08 physical factory-logistics milestone: ACCEPTED (2026-10-30).** Both the manual regression and the principal player-visible production/routing behavior have passed.

This acceptance **does not** mean everything in the long-term logistics roadmap is finished. We have not separately verified that legacy proximity-based scripts were disabled for the latest live run; a confirmed functioning belt chain does not, by itself, prove there are no parallel automatic proximity transfers. Do not remove that legacy logic without a controlled physical-only conservation regression.

### Carry-forward work (later milestone)

1. Confirm physical-only resource accounting and carefully retire/gate redundant short-range proximity transfer scripts.
2. Improve diagnostic snapshots/throughput benchmarking (Merger lane counts; Splitter blocked-output sustained-traffic behavior).
3. Confirm demolition, collision refusal and cargo-recovery behavior in complex live builds; establish persistence and player-friendly build visuals.
4. Continue the original gameplay vision toward ammunition production, defensive supply and the zombie First Night vertical slice.

**Documentation checkpoint:** `GAME_DESIGN.md`, `ARCHITECTURE.md`, `TROUBLESHOOTING.md`, `ROADMAP.md` and this log capture implementation and engineering lessons. This entry supersedes earlier *historical* statements that Merger/backpressure and full factory live verification were still pending.


---

## 2026-10-31 — Physical-Only Production, Ammunition Acceptance and First Turret Foundation

### Verified by local Godot tests

- `tests/conveyor_physical_only_conservation_test.tscn`: **9/9 passed**. A 500-unit finite ore deposit supplied a physical-only Extractor → Storage → Smelter → Storage route. Legacy proximity scripts were disabled during the test. After two ore were converted into one ingot, 498 ore + (1 ingot × 2 ore) equaled the initial 500 ore equivalents.
- `tests/prototype_ammunition_press_test.tscn`: **9/9 passed**. The data-defined ammunition recipe accepts only Test Ingots, creates four Prototype Rounds per ingot, and protects finished rounds during output blockage and recovery. Conveyor export to warehouse and eight-round conservation were tested.
- `tests/ammunition_press_build_mode_test.tscn`: **9/9 passed**. Slot 8, keyboard selection, highlighting, rotation, grid-aligned ports, connection cleanup and demolition safety all passed.
- **Live main-game observation:** User supplied a screenshot with a physically connected manufacturing line and the selected final Test Storage HUD showing **6 Prototype Rounds / 200 capacity**. This verifies that manufactured ammunition arrived in normal storage during gameplay. Rounds are moved one at a time, so an intermediate storage count need not be divisible by the four-round recipe batch.

### Safeguards and deferred scope

- The older proximity transfer components still exist in the repository for compatibility, but their scene nodes are configured disabled. They were explicitly disabled during the physical-only conservation run. Do not remove their scripts merely because the new route works.
- The Prototype Ammunition Press is production-ready as a **prototype**, not balanced or visually final. The current recipe is **1 Test Ingot → 4 Prototype Rounds over 2 seconds**; actual military recipes and resource economy remain design decisions.
- New **isolated** 1×1 defensive turret foundation: `DefensiveTurretComponent`, ammunition-only `TurretAmmunitionPort`, `prototype_defensive_turret.tscn`, and `prototype_defensive_turret_test.tscn`. The first checkpoint verifies physical ammo receipt, one-round firing, cooldown, blocked/full magazines, resource conservation and protected demolition. **This newly committed turret test has not yet been run locally**, so it is not accepted as passed.
- The turret is **not** in Build Mode yet and will not auto-shoot enemies. Targeting, projectiles, damage, zombie behavior and defense balance are follow-on features.

### Next acceptance gate

Run `res://tests/prototype_defensive_turret_test.tscn` with **F6** in Godot 4.6.2. Record the result and fix any isolated test issues before registering the turret in the main Build HUD. Preserve the existing conveyor, recipe and warehouse test suites.


---

## 2026-10-31 — Turret Ammunition Foundation Accepted; Build Mode Slot 9 Prepared

### Local test results

The developer ran `res://tests/prototype_defensive_turret_test.tscn` in Godot 4.6.2 and supplied console output confirming **all 10/10 tests passed**. Verified: ammunition-only port acceptance, rejection of ore and ingots, one-way physical belt connection, backpressure, correct one-round firing transactions, cooldown, conservation, magazine capacity recovery, safe demolition, and physical connection cleanup.

### Next integration checkpoint (committed, pending local test)

- Registered **Prototype Defensive Turret** as construction **slot 9** (`9` key), preserving existing slots 1–8.
- Updated `BuildHUD` scene and script with the ninth selection label; adjusted its vertical layout.
- Added `ProductionDebugHUD` turret-specific display showing ammunition quantity/capacity, input-port connection status, cooldown, firing readiness, shot count and an explicit note that **targeting is not implemented**.
- Added `tests/defensive_turret_build_mode_test.tscn` with 12 checks against the real Main scene, building rotation/grid, incoming conveyor, ammo handling, HUD and cleanup.
- Updated the older ammunition press Build Mode regression to continue checking its original eight slots within the new nine-slot roster.

**Acceptance gate:** Run the new 12-case turret Build Mode test in local Godot before claiming the slot 9 integration is validated. Then confirm live delivery of factory-produced Prototype Rounds into the turret magazine. Automatic targeting, firing, damage, zombies and combat balancing remain unimplemented.


### Follow-up acceptance: turret Build Mode slot 9

The developer ran `res://tests/defensive_turret_build_mode_test.tscn` in Godot 4.6.2 and supplied the Output screenshot confirming **all 12/12 checks passed**. Verified existing eight build slots and new slot 9, preview and 90-degree rotation, grid-aligned turret input, ammunition-only acceptance, physical conveyor delivery, loaded-turret demolition protection, Production Debug HUD (connected state/1 of 40 rounds/readiness), a single simulated shot updating the counter, port cleanup, and switching between slots 8 and 9. This completes the local automated acceptance of turret Build Mode integration.

**Next live-game checkpoint:** Use the already-working ammunition factory to feed a placed turret through real conveyors. Existing Storage provides a universal output port; a Storage → Conveyor → Turret connection avoids disrupting the Ammunition Press's single occupied output port. Expect the turret HUD's magazine count to increase while `Fired Shots` stays at zero because no automatic targeting or in-game firing action is implemented yet. Visual targeting, enemy behavior and damage remain pending.


---

## 2026-11-01 — Live Ammunition-Fed Turret Accepted; Isolated Targeting Checkpoint

### Accepted live-game evidence

A screenshot of the player-built factory and selected Defensive Turret HUD confirms physical ammunition supply into the turret: **Ammo Conveyor Connected; Ammunition 9 / 40; Status Ready; Cooldown 0.00 seconds; Fired Shots 0**. This is the first accepted complete physical chain from extraction, smelting and ammunition manufacturing through storage/conveyors into a turret magazine during normal gameplay.

The zero-shot count is correct: no automatic combat behavior was attached to the live turret at the time of acceptance.

### New combat foundation (not yet locally tested)

- `CombatHealthComponent`: generic positive health, guarded damage transaction and death signal.
- `prototype_zombie_target.tscn`: stationary hostile placeholder with visible body and 30 health (not yet a moving zombie).
- `TurretTargetingComponent`: optional child component that scans the `hostile_targets` group, selects the nearest living target within a horizontal range (default 7 world units), and uses the existing `DefensiveTurretComponent.try_fire()` transaction before applying a temporary 10 damage instant hit. Every shot consumes one Prototype Round, obeys cooldown and skips out-of-range, friendly and already-dead targets.
- `tests/defensive_turret_targeting_test.tscn`: isolated 12-case Godot regression covering range, nearest selection, no-target/no-ammo behavior, cooldown, exact damage, target defeat and retargeting, and conservation.

**Important:** This targeting behavior is **not yet attached to the Build Mode turret**. There is no projectile simulation, line-of-sight check, target movement, zombie spawning, building damage or enemy attack behavior. Run the new isolated test first, then integrate into live gameplay only after local verification.

### Next check

Run the targeting regression with F6 in Godot 4.6.2. Preserve the previously passing turret ammo/Build Mode suites, conveyor factory, and ammunition production tests.


### Follow-up acceptance: isolated targeting/damage regression

The developer supplied Godot 4.6.2 output confirming **12/12** tests passed in `res://tests/defensive_turret_targeting_test.tscn`: no-target and out-of-range ammo preservation, ignoring non-hostiles, nearest-hostile targeting, real one-round consumption, cooldown, 10 damage per hit to a 30-HP dummy, skipping defeated targets, retargeting, empty-magazine protection and ammo/shot conservation.

### Player-world combat integration (committed; local validation pending)

- Attached the validated `TurretTargetingComponent` to `prototype_defensive_turret.tscn`. Its range is 7 units and damage 10 per authorized shot; it consumes rounds exclusively through `DefensiveTurretComponent.try_fire()`.
- Placed a stationary `PrototypeZombieTarget` instance at **(-6, 0, -6)** inside the main world's ground area, farther than 7 units from origin to avoid disrupting older slot-9 regression tests. This is a static test dummy, not a zombie with AI or movement.
- Added a visible target health/defeated Label3D and read-only combat statistics to the turret Production Debug HUD (current target, hits, defeated count). Preserved the existing magazine/cooldown/counter display.
- Updated the older turret Build Mode regression's combat label assertion to reflect automatic targeting now being attached.
- Added `res://tests/live_turret_combat_integration_test.tscn`, an **11-case** integration test against the real Main scene, connected physical belt, ammunition inventory, range detection, automatic fire, target health, visible defeat state, HUD and disconnect cleanup.

**Not yet validated locally:** The full scene integration, player-built turret automatic fire and on-screen damage. Do not claim live combat acceptance until the new F6 test and a manual in-game demonstration pass. Instant damage is a temporary placeholder; projectiles, LOS checks, zombie movement/spawning, death animations and combat balancing are future work.


### Follow-up acceptance: real Main-scene combat integration

On **2026-11-01**, the developer ran `res://tests/live_turret_combat_integration_test.tscn` in Godot 4.6.2 and supplied the full Output screenshot confirming **all 11/11 tests passed**.

Verified in the main scene: the stationary 30-HP target exists, slot 9 builds a turret containing automatic targeting, target distance gates firing, no-ammunition preserves health, a real conveyor attaches to the magazine port, each delivered round authorizes one 10-damage shot, cooldown prevents phantom hits, three rounds defeat the dummy without loss, defeated targets stop receiving hits, the target displays `TARGET DEFEATED`, combat counters update in the Production Debug HUD, and empty-turret removal does not break the existing conveyor.

**Next checkpoint (not yet accepted):** Manual, player-controlled gameplay with an ammunition-fed turret near the static target at (-6, 0, -6). Verify that the target health label and turret HUD update while rounds are physically delivered and the dummy is defeated in the running main world. Do not count this as proof of moving zombies, projectile simulation, enemy attack AI or line-of-sight.


### Follow-up acceptance: manual factory-powered combat

On **2026-11-01**, the developer supplied a screenshot from regular gameplay showing the ammunition-fed turret and its physical conveyor chain beside the stationary target whose health label reads **TARGET DEFEATED**. This confirms the first visual combat victory in the playable main world. The screenshot does not display the turret's shot counters; those 3-hit/30-HP values were separately confirmed by the **11/11** live-world integration regression.

**Next step:** Add an isolated moving-enemy prototype. Keep the original stationary target and production systems unchanged. The first movement prototype may approach a selected player-built structure directly on the X/Z plane, but collision avoidance, pathfinding, building attacks, enemy spawning and wave logic remain separate unimplemented features.


### New isolated milestone: moving-zombie foundation (not yet tested locally)

The first moving enemy is deliberately **separate** from `prototype_zombie_target.tscn`, which remains the accepted stationary reference in the main playable scene.

- `ZombieApproachComponent` finds the nearest real `player_built` structure with a `BuildingRuntime`, excluding construction previews and conveyors.
- Walks in the X/Z plane at a temporary **2 units/second** and stops **1.5 units** from the structure center; large time steps are clamped to prevent overshoot.
- Reacquires a valid target after the previous structure is removed. Stops permanently when its `CombatHealthComponent` reaches zero.
- `scenes/enemies/prototype_moving_zombie.tscn` is a separate green placeholder with the existing combat health and label implementation.
- `tests/prototype_moving_zombie_test.tscn` contains nine isolated checks for idle behavior, excluding ghosts and conveyors, nearest structure selection, displacement and stopping distance, reacquisition after deletion, existing ammo-fed turret hits/cooldown, and immobility when defeated.

**Not integrated in Main yet.** The movement code uses straight-line motion only; no NavigationAgent3D, collision avoidance, body-to-body collisions, enemy attacks, structure health, spawners or waves have been implemented. Run the nine-case F6 regression in Godot 4.6.2 before adding enemy motion to the live factory.


### Moving-zombie foundation accepted; live-world integration pending

The developer ran `res://tests/prototype_moving_zombie_test.tscn` in Godot 4.6.2 and supplied Output confirming **all 9/9 tests passed**. This verifies no-target idle behavior, excluding ghosts and conveyors, approaching and stopping 1.5 units from the nearest actual building, reacquisition when a structure is deleted, compatible ammo-fed turret damage/cooldown, and no motion after death.

**Next implementation checkpoint:** The separate `PrototypeMovingZombie` is now instanced in `scenes/core/main.tscn` at **(8, 0, -7)**. The previously validated stationary `PrototypeZombieTarget` remains at **(-6, 0, -6)**. The new `res://tests/live_moving_zombie_integration_test.tscn` uses the actual Main scene and tests the absence of target/ignored ghosts, player-built storage approach, stopping distance, switching to an actual turret after storage removal, physical ammo delivery, three real hits, target death, HUD statistics, and conveyor cleanup.

**Status:** This main-world change has been committed and repository-reviewed, but its 12-case integration regression has **not** yet run in local Godot. Do not claim it passes until the user's F6 confirmation. Live gameplay movement also still requires manual observation. This remains direct X/Z motion, with no obstacle avoidance, NavigationAgent3D, structure damage, automatic spawning, or wave systems.


### Main-scene moving-zombie integration accepted — 12/12 checks

On **2026-11-01**, the developer ran `res://tests/live_moving_zombie_integration_test.tscn` in Godot 4.6.2 and supplied Output confirming **ALL 12 LIVE MOVING ZOMBIE INTEGRATION TESTS PASSED**.

The test exercised the real Main scene: one moving zombie coexists with the original stationary target; with no player structures it remains still; construction preview ghosts and loose conveyors are ignored; the enemy travels 2 world units per second toward player-built Storage and stops 1.5 units from it; after Storage removal it acquires a placed turret; without ammunition the turret cannot fire; after physical conveyor connection three delivered Prototype Rounds produce three guarded hits, defeat the moving zombie, and preserve the static target. Dead enemies cease motion, and the turret's combat HUD and conveyor cleanup remain correct.

**Next acceptance gate:** Manually launch the actual main game with F5, place a structure near the moving enemy at (8, 0, -7), and verify it visually approaches and stops. A later manual pass should supply a turret and observe the moving enemy's defeated state. This is still straight-line X/Z motion without navigation, obstacle avoidance, structure attacks, automatic waves, or projectiles.


### Manual movement accepted — zombie approaches player-built Storage

On **2026-11-01**, the developer supplied a gameplay screenshot showing the green **PrototypeMovingZombie** beside a placed Test Storage building, with its label **TARGET HP: 30 / 30**. The previously validated red stationary target is visible separately. The developer confirmed the zombie approached and stopped at Storage during live gameplay.

This establishes manual visual acceptance of the moving-enemy approach and stop behavior. The exact 1.5-unit stopping distance is supported by earlier isolated and main-scene automated tests, rather than being measured from this screenshot. The moving zombie has not yet been visibly defeated in a live, player-controlled run.

**Next validation:** In a fresh gameplay run or with the existing factory, place an ammunition-fed turret within 7 world units of the moving zombie and verify three hits, 30-to-0 HP, the **TARGET DEFEATED** label and no more firing at the defeated zombie. Keep the static target separate from that engagement. Do not infer navigation, zombie attacks, projectile simulation or building damage.


---

## 2026-11-01 — Moving-Zombie Combat Accepted; Isolated Structure-Damage Foundation

### Accepted normal gameplay

The developer supplied a normal-gameplay screenshot showing both the previously validated stationary target and the moving zombie with separate **TARGET DEFEATED** labels. The developer confirmed that the green moving zombie immediately approached a newly placed turret, which then defeated it using factory-supplied ammunition. This accepts the first moving-hostile victory in regular gameplay. The image does not show live shot counts; existing deterministic regressions separately verified three real 10-damage hits per 30-HP target.

### Building health and melee implementation (not yet locally validated)

- `BuildingHealthComponent` introduces 100 default HP, actual-damage accounting, a single zero-HP signal, and guarded damage application. **At zero HP, the building is kept in the scene**: no inventory, resources, or conveyor connections are silently deleted.
- `ZombieMeleeComponent` allows one attack per configured interval (temporary 10 damage/1 second) only when a living zombie is within physical melee range and `ZombieApproachComponent` reports `At Structure`. It requires an explicit health-enabled building, ignores previews, conveyors, invalid targets and cooldown violations, and stops attacking when the zombie is defeated.
- `ZombieApproachComponent` now ignores a health-enabled building whose health has reached zero and reacquires another valid structure. Buildings without the health component retain their existing movement-target behavior for backward compatibility, but are not damageable by the new melee component.
- `tests/zombie_building_melee_test.tscn` has **12 isolated checks** covering no-target behavior, undamageable buildings, previews and conveyor filtering, valid structure detection, approaching/range rules, damage, cooldown, exact zero-HP clamping, stored-ammunition preservation, retargeting and dead-zombie attack prevention.

**Safety/integration boundary:** Neither `scenes/enemies/prototype_moving_zombie.tscn` nor any player-buildable factory scene has had melee or BuildingHealth attached. Existing main-game behavior should remain non-destructive while the 12-case regression awaits local F6 validation. Player-facing building HP, combat destruction, salvage/recovery, obstacle navigation, zombie spawning and waves are still future increments.


### Building-health foundation accepted — 12/12 local Godot checks

The developer ran `res://tests/zombie_building_melee_test.tscn` in Godot 4.6.2 and provided output confirming **ALL 12 ISOLATED BUILDING HEALTH AND MELEE TESTS PASSED**. Tested exact melee distance and cooldown, one hit per interval, invalid targets, 25-HP overkill clamping, three saved ammunition units remaining inside a zero-HP storage unit, retargeting a healthy structure and zombie attack/movement stopping after death.

### Step 09.16 — Factory-wide durability and shared HUD (committed, unverified)

- Added `BuildingHealthComponent` directly to the eight player-buildable **structure** scenes: Extractor, Test Large, Storage, Smelter, Merger, Splitter, Ammunition Press and Defensive Turret. Each starts at 100 HP. Ordinary conveyor **segments** are not building-health targets and retain their current cargo logic.
- Production Debug HUD now appends a standardized **BUILDING DURABILITY** block with current/max HP and Intact/Disabled status after the existing building-specific display. This preserves all production, inventory, magazine and recipe information.
- Adapted `tests/zombie_building_melee_test.gd` so its special legacy **no-health** fixture explicitly removes the new default component, preserving that test's safety invariant, while its damageable fixtures edit the existing component rather than creating duplicate children.
- Added `tests/building_health_integration_test.tscn`, an **11-case** acceptance test against all nine construction slots. It verifies one health component per structure, no health on belts, shared HUD output, stored cargo and connected-port survival at zero HP, zombies ignoring disabled Storage, and turret magazine/demolition safety.

**Important:** Zero-HP status currently marks a structure as disabled for enemy targeting but does **not** yet automatically halt processing or transport. No building is destroyed, salvaged or removed, and no stored resources disappear. The live moving zombie still has no `ZombieMeleeComponent` attached. This integration must pass local Godot validation before real zombie attacks are enabled.


### Step 09.16A — Factory-wide durability integration accepted

On **2026-11-01**, the developer ran `res://tests/building_health_integration_test.tscn` locally in Godot 4.6.2 and supplied output confirming **ALL 11 BUILDING HEALTH INTEGRATION TESTS PASSED**.

Verified all nine build slots remain registered; exactly eight non-belt structures each have one initialized 100-HP component; ordinary conveyors do not gain building HP; all eight building Debug HUD views show durability; Storage inventory and physical output port references persist through damage and zero HP; zombies skip disabled Storage; a loaded turret keeps its ammunition, HUD and demolition safety; construction ghosts are not targeted.

The teardown message `Extractor has no resource node` occurs after the tests and does not indicate an assertion failure.

**Next regression gate:** Re-run `res://tests/zombie_building_melee_test.tscn` (12 checks) with its modified no-health fixture now that the regular Storage scene includes health. This new re-run is pending; do not enable `ZombieMeleeComponent` on the live moving zombie until confirmed. Zero HP currently preserves inventory and links but does not automatically halt production or implement destruction, repair, or salvage.


### Step 09.16B — Adjusted isolated melee re-test accepted (12/12)

The developer ran the updated `res://tests/zombie_building_melee_test.tscn` after all eight non-belt structures gained their 100-HP component. The Godot 4.6.2 screenshot shows **ALL 12 ISOLATED BUILDING HEALTH AND MELEE TESTS PASSED**, confirming the no-health fixture, melee distance and cooldown, damage clamp, resource preservation, retargeting and prevention of further attacks from defeated zombies remain correct.

### Step 09.17 — Live structure attacks integrated (local acceptance pending)

- Attached `ZombieMeleeComponent` to `scenes/enemies/prototype_moving_zombie.tscn` with an exported NodePath to its existing MovementComponent. The live moving zombie now has **10 melee damage**, a **1.0-second** attack interval, and a **1.55-world-unit** attack range.
- The component only deals damage to the currently approached, intact `BuildingHealthComponent` target. Its attack routine never deletes the building, inventory, resource items or physical conveyors.
- Updated the historical isolated melee test to reuse the scene's built-in melee component instead of injecting a duplicate.
- Updated `prototype_moving_zombie_test.gd` and `live_moving_zombie_integration_test.gd` to disable the new melee process during their deterministic movement-only assertions, preserving their original scopes.
- Added `tests/live_zombie_melee_integration_test.tscn` with **12 Main-scene integration checks**. It tests the wired live zombie, empty/ghost targeting, stored ammo with a connected belt, range gating, first hit, cooldown, 10 exact hits taking 100-HP Storage to zero, no inventory or port loss, disabled-building retargeting, attacking a second structure, defeated-zombie immobility and health HUD updates.

**Not yet locally tested:** The new 12-case Main-scene zombie melee integration. Before accepting this gameplay milestone, run the F6 regression, then manually verify health decreasing on a placed Storage building. A zero-HP building still remains in place and may continue production/transport; production shutdown, damage visuals, destruction, repairs, salvage, obstacle pathfinding and wave spawning remain future work.


### Step 09.17A — Live zombie melee integration regression accepted (12/12)

The developer ran `res://tests/live_zombie_melee_integration_test.tscn` in Godot 4.6.2 and supplied Output confirming **ALL 12 LIVE ZOMBIE MELEE INTEGRATION TESTS PASSED**.

The real Main-scene zombie was verified to carry a wired melee component. The test confirmed no attacks without a structure, rejection of construction ghosts and conveyor belts, live Storage at 100 HP retaining seven Prototype Rounds and a connected belt, no premature hit outside range, 10 damage on reaching Storage, cooldown blocking extra hits, ten hits reaching exactly zero HP, inventory and port survival after defeat, target reassignment to a second intact building, and complete cessation of zombie movement and attacking after its own defeat.

**Acceptance boundary:** Integration regression is passed; manual player-controlled F5 gameplay validation remains pending. The next check is to build and select Storage near the green moving zombie at (8, 0, -7), confirm the Debug HUD durability decreases by 10 HP per melee hit, and observe the structure remaining present at zero HP. Do not require a turret for this defensive-loss test, and do not claim production shutdown, repair, salvage, pathfinding or wave spawning from it.


### Step 09.17B — Live player-controlled zombie attack accepted

On **2026-11-01**, the developer reported placing a Test Extractor near the moving zombie in the actual F5 main game. The zombie attacked until the Extractor reached **HP: 0 / 100**, while the building remained visibly present. The selected Extractor's Production Debug HUD showed **Status: Disabled** in the Building Durability section and **Stored Test Ore: 19 (19 / 50 capacity)**. This is visual confirmation of non-destructive health depletion for the Extractor. The prior **12/12** Main-scene melee regression specifically validated Storage inventory and physical port preservation at zero HP.

**Important observed gap:** The same screenshot still displayed `Status: Extracting` under the Extractor production section, despite durability being disabled. Operational shutdown at zero health is **not implemented yet**; the screenshot alone cannot establish whether additional ore was produced after reaching zero. The progress bar is not a health indicator.

**Next design/implementation milestone:** Introduce health-aware operation gates for extraction, recipe processing, ammunition-fed turret firing, and building conveyor transfers. A disabled structure should stop operating without destroying resources, changing physical connections, or resetting partial progress. Design repair/reactivation separately and verify disabled behavior with isolated regression scenes before changing live systems. Automatic physical destruction, cargo salvage, repair interfaces, navigation, and wave spawning remain out of scope.


### Game-design correction — Real structures and conveyors must be destructible

The developer clarified that the present `Disabled` status at zero HP is **only a testing safeguard**. It must not become the final gameplay outcome. In the playable game, zombies should be able to destroy **both factory buildings and conveyor segments**.

**Confirmed requirement:** A building at zero HP leaves normal operation and is destroyed through a controlled lifecycle; belts can be separately damaged and severed. Destroying a single building or conveyor does not erase the entire connected factory network. The game should show placeholder wreckage/debris until final art exists.

**Engineering gates before enabling physical removal:** Explicitly disconnect ports, resolve machine inventories and cargo on destroyed belts without silent duplication, define recoverable drops/salvage/loss, verify neighbor belts remain intact, and handle target reassignment and blocked logistics safely. Existing 0-HP preservation tests remain regression fixtures for the transition, not a statement of the intended final destruction rules. Optional repair of damaged structures and rebuild/salvage of destroyed ones are separate design decisions.

`GAME_DESIGN.md` and `ROADMAP.md` now document this requirement. No gameplay destruction code has been changed as part of this design clarification.


### Upcoming UI milestone — Player-configurable build hotbar

The developer requested that, after real building and conveyor destruction is implemented, the player should be able to open a menu of **unlocked** buildings and assign any of them to any number key. Example: **Defensive Turret → 1**, **Storage → 9**.

The planned Build Catalog and nine-slot customizable hotbar are documented in `GAME_DESIGN.md` and Phase **1G** of `ROADMAP.md`. Unlocked buildings can be assigned, reordered or swapped without affecting the existing factory. Preferences should persist across sessions by stable `building_id` rather than the `buildable_definitions` array index. The future refactor must specifically eliminate the `selected_building_index == 4` Conveyor Belt logic before allowing arbitrary slot mappings, preserving the current belt placement and snapping regressions.

**Status:** Design captured only. No UI, hotkey, progression, or save files have been modified. The immediate priority remains destruction of buildings and conveyor segments with safe cargo handling.


---

## Step 09.18A — Destruction Cargo Recovery Preflight (2026-11-01)

**Status: new isolated code committed, Godot validation pending.** No live factory destruction is enabled.

- Added `scripts/components/destruction_cargo_recovery.gd` (`DestructionCargoRecovery`), a reusable inventory recovery helper that collects all descendant `InventoryComponent` instances exactly once, rejecting invalid item identities, missing sources, same-tree recovery targets, and recovery caches with insufficient total space.
- Once preflight succeeds, resources move via the **existing** `InventoryComponent.transfer_to()` logic. This is item-generic (ore, ingots, ammunition and future `ItemDefinition` resources), and repeated calls on an emptied source are idempotent.
- Added `res://tests/destruction_cargo_recovery_test.tscn` (12 checks). It covers capacity refusal without partial transfer, 7 ore + 4 rounds from Storage, recovery from the 2-buffer Ammunition Press, recovery from a cargo-bearing belt, correct local port/belt disconnection through the existing `_exit_tree` path, keeping neighboring belt cargo intact, and a final accounting of **19/19** recoverable units.
- For this checkpoint, the recovery destination is an independent in-memory `InventoryComponent`, **not** yet a visible or pickable salvage crate. The test manually invokes removal only after escrow succeeds. Automatic damage, health-triggered world deletion, wreckage, belt health and enemy belt targeting remain unchanged.

**Design reminder:** The final game destroys buildings and damaged conveyor segments. The temporary zero-HP Disabled state is a test safeguard only. First establish 100% recoverable test escrow (an accounting baseline); tune salvage/loss rates later when dedicated world drops exist. Do not expose player demolition or combat deletion through this new helper until Godot has validated it.


### Step 09.18A — Destruction cargo regression accepted (12/12)

The developer ran `res://tests/destruction_cargo_recovery_test.tscn` in Godot 4.6.2 and supplied output confirming **ALL 12 DESTRUCTION CARGO RECOVERY TESTS PASSED**. After correcting the intentionally malformed inventory-key preflight in `destruction_cargo_recovery.gd`, both source and destination accounting passed, including all **19/19** ore, ingot and ammunition units recovered without duplication. The linked-belt test also confirmed surviving neighbors retain cargo and detach only the removed segment.

### Step 09.18B — Controlled destruction transaction (code committed, Godot test pending)

- Added `scripts/components/destruction_transaction.gd` (`DestructionTransaction`). It is a standalone helper **not wired into live zombie damage or Build Mode**. It accepts only real `player_built` buildings with `BuildingRuntime` or a `ConveyorSegment`; rejects preview ghosts, arbitrary nodes, queued sources and unattached recovery caches.
- Its `try_destroy()` first checks complete salvage capacity and moves all source-owned inventory into a separately live `InventoryComponent`. On success it disables source processing, explicitly severs the source's reciprocal building-port or belt links, then queues **only that source** for deletion. Failed preflight leaves the structure and physical connections untouched.
- Added `tests/controlled_destruction_transaction_test.tscn` with **12 checks** for rejection cases, insufficient recovery capacity, warehouse-output and two-belt linking, source removal, immediate port disconnection, duplicate removal refusal, neighbor cargo preservation, separately destroying cargo-bearing belts, multi-buffer manufacturer recovery, invalid key refusal and exact **19-unit** final conservation.

**Current boundary:** This is the first test-only transaction capable of genuinely queueing buildings and belts for removal. Live damage-to-destruction, enemy conveyor targeting, wreckage visuals and actual in-world salvage cache/pickups remain separate milestones. The 12-case scene requires an F6 pass before any live behavior is changed.


### Step 09.18B — Controlled destruction accepted (12/12)

The developer ran `res://tests/controlled_destruction_transaction_test.tscn` in local Godot 4.6.2, confirming **ALL 12 CONTROLLED DESTRUCTION TRANSACTION TESTS PASSED**. Validated invalid/preview rejection, insufficient salvage capacity preventing removal, immediate local port/belt disconnection, queued removal, duplicate refusal, neighboring belt cargo preservation, independent belt destruction, two-buffer Ammunition Press recovery, invalid item refusal, and **19/19** item accounting.

### Step 09.18C — Main-world salvage placeholders (committed, F6 test pending)

- Created `WorldSalvageCache` (`scripts/components/world_salvage_cache.gd`) and `scenes/logistics/world_salvage_cache.tscn`, a non-colliding placeholder wreckage mesh with a readable count and a dedicated unlimited `InventoryComponent`. Empty sites read `WRECKAGE`; salvaged sites read `SALVAGE: N`. The object is in `salvage_caches`, **not** `player_built`.
- Added `WorldDestructionService` (`scripts/components/world_destruction_service.gd`) as a Main scene child. Its `try_destroy_with_salvage(source)` creates the cache as an independent sibling at the affected site, uses the previously tested `DestructionTransaction.try_destroy()`, and retains its cargo even after the source is freed. Failed transactions remove the empty placeholder immediately rather than leaving phantom salvage.
- New `res://tests/world_salvage_destruction_test.tscn` uses the real Main scene and checks 12 cases for valid targets, junk/ghost exclusion, stocked storage with two connected belts, accurate 7-item salvage at a destroyed site, repeated deletion refusal, invalid manufacturer inventory refusal, two-buffer manufacturer salvage, individual adjacent belt destruction, empty wreckage, summed **15-item** conservation across five independent surviving world caches, and enemy/world safety.

**Validation boundary:** Repository checks pending completion; **no local F6 run has passed yet**. Main has the inactive service but live zombies do not invoke it on zero HP. Salvage is a runtime in-world holder and visual placeholder, **not yet player-pickable or persisted to disk**, and 100% recovery remains prototype balancing. Conveyor HP, zombie belt targeting, damage-triggered removal, special wreckage FX and player salvage collection will be handled in later checkpoints.


### Step 09.18C — Main-world salvage regression accepted (12/12)

The developer supplied Godot 4.6.2 output from `res://tests/world_salvage_destruction_test.tscn`: **ALL 12 MAIN-WORLD SALVAGE DESTRUCTION TESTS PASSED**. Validated five independent world-owned wreckage caches, empty wreckage and two cargo-bearing belts, rejection of duplicate/invalid deletion, uninterrupted surviving world nodes, and conservation of **15/15** initial item units after source removal.

### Step 09.18D — Health-triggered Main-world building destruction (committed, F6 test pending)

- `BuildingHealthComponent._ready()` now connects the existing `health_depleted` signal to the owning Main scene's `WorldDestructionService`, when present. Preview ghosts and independent isolated scenes remain excluded. No automatic removal is implemented for enemy targets or belts here.
- `WorldDestructionService.destroy_on_zero_hp` defaults to **true** in Main. When health reaches zero, the service invokes its already-tested inventory recovery, reciprocal port cleanup, stopped-processing state and single-source queue for deletion. A world-owned cache with recovered items remains at the original site. An unsuccessful salvage transaction **never deletes source data**; it leaves a 0-HP structure in place and increments `failed_health_destructions` for later recovery/retry.
- The service clears any `WorldInteraction` selection and `ProductionDebugHUD` selection referencing a successfully destroyed structure before frame-end freeing. Movement/target selection skips queued or dead structures and should reacquire intact targets.
- The historical `building_health_integration_test.gd` (11 checks) and `live_zombie_melee_integration_test.gd` (12 checks) explicitly switch off automatic world destruction so their original zero-health-disabled safety contracts can still be tested independently.
- New `res://tests/live_zombie_destruction_test.tscn` (**12 checks**, local Godot run pending) tests the Main scene, preview protection, real Storage with stocked adjacent belts, nine nonlethal hits, tenth-hit removal, salvage and HUD cleanup, local disconnections, surviving conveyor cargo, zombie reacquisition of another building, non-melee health depletion triggering the same path, invalid-inventory rollback and explicit recovery retry. Expected accounting: **12 recovered units across three wreckage caches + two surviving belt units**.

**Validation boundary:** The code is committed but live F5 gameplay must wait until the new F6 regression passes. The final game also requires damageable belts, zombie belt targeting, salvage pickup/persistence, and improved wreckage presentation; none is claimed complete.


### Step 09.18D — Zombie-triggered building destruction accepted (12/12)

On **2026-11-02**, the developer ran `res://tests/live_zombie_destruction_test.tscn` in Godot 4.6.2. All **12/12** integration checks passed (PASS A–L; screenshot provided). The tested Main scene automatically listened for building health depletion. A live moving zombie struck a selected, stocked Storage structure: its tenth hit took HP to zero and queued actual deletion. The world-owned salvage held seven Storage items and the selection/HUD cleared; both neighboring conveyor belts stayed intact and retained their cargo. The zombie subsequently targeted and damaged another healthy building, whose depletion through a separate damage call used the same destruction transaction. A deliberately malformed inventory failed salvage safely, leaving a 0-HP structure available for later retry; the recovery was then completed. End-of-test accounting: **12 units stored across three wreckage caches plus two units on the surviving belts**.

**Next acceptance gate:** Player-controlled **F5** test, not yet confirmed. Build a real Extractor or Storage near the prototype moving zombie (avoid placing a defensive turret nearby), observe the final 0-HP attack physically removing the structure, verify wreckage remains with the correct `WRECKAGE` or `SALVAGE: N` placeholder, and ensure the selection HUD clears cleanly.

**Still pending:** zombie damage to conveyor segments, isolated belt health/destruction tests, recoverable player pickups, save/load of salvage, production-chain hardening, final wreckage FX, and progression toward the customizable build catalog/hotbar.


### Step 09.18E — Zombie destruction verified in real gameplay

On **2026-11-02**, the developer ran regular F5 gameplay and showed a green moving zombie next to a visible **WRECKAGE** placeholder where its attacked player structure had been. The previous structure was no longer visible; the Production Debug HUD was not showing it. This is the accepted player-controlled destruction/wreckage milestone. The screenshot shows an **empty wreckage** placeholder; stored material recovery and preservation of neighboring conveyors were verified separately by the passing 12-case regressions.

### Step 09.18F1 — Conveyor durability across all belt geometries (committed; local validation pending)

- Added `scripts/components/conveyor_health_component.gd` (`ConveyorHealthComponent`). Every belt starts at **50 HP**, accepts clamped positive damage, emits a single depletion signal at zero, and ignores repeated hits after depletion. It does **not** itself remove a belt or trigger attacks yet.
- Attached the component to all three physical belt scene shapes used by `ConveyorPieceSelector`: `conveyor_straight.tscn`, `conveyor_corner.tscn` (right), and `conveyor_corner_left.tscn`. Both corner scenes now include an independent one-item `CargoInventory` for safe future salvage/recovery. These added corner buffers do **not** add transport timers or alter the established belt-transfer mechanism.
- Added `res://tests/conveyor_durability_foundation_test.tscn` (**12 checks pending local F6 validation**): Main scene compatibility, straight/right/left durability and buffer counts, ghost safety, physically attached Storage and two straight belts, invalid/partial/overkill damage, exactly-once depletion signaling, no automatic removal, malformed cargo fail-closed behavior, explicit zero-HP straight-belt destruction and neighbor preservation, cargo-bearing right-corner and empty left-corner salvage, and final accounting of two recovered units plus one live neighboring belt unit.
- **Scope boundary:** Automatic destruction on belt HP depletion and zombie targeting/melee against belts are NOT enabled in Step 09.18F1. Existing player demolition checks remain unchanged. The next checkpoint will wire belt targeting and guarded destruction only after the separate health regression passes.


### Step 09.18F1 — All three conveyor durability variants accepted (12/12)

The developer supplied local Godot 4.6.2 output for `res://tests/conveyor_durability_foundation_test.tscn` confirming **ALL 12 CONVEYOR DURABILITY FOUNDATION TESTS PASSED**. Straight and left/right corner belts each initialized at 50 HP with one cargo slot. The test verified overkill clamping, a single depletion event, construction-preview safety, no automatic deletion in its isolated fixture, existing Storage/belt connections, invalid cargo refusal, three explicit destruction transactions and conserved item counts (two units in salvage plus one on a surviving belt).

### Step 09.18F2 — Zombie-targeted conveyor destruction (code committed; F6 pending)

- `ZombieApproachComponent` now supports exported `target_conveyors` (default false for standalone historical regressions, explicitly true in `prototype_moving_zombie.tscn`). Valid conveyor targets require `player_built`, no preview/deletion, and an intact `ConveyorHealthComponent`. Healthy buildings remain eligible; the nearest valid target wins. Depleted belts are skipped when retargeting.
- `ZombieMeleeComponent` now routes existing 10-damage, one-second-cooldown melee attacks through either `BuildingHealthComponent` or `ConveyorHealthComponent`, depending on the selected target. Building-only tests retain their original safeguards.
- `ConveyorHealthComponent` connects `health_depleted` to the owning Main-world service, when present. `WorldDestructionService.destroy_conveyors_on_zero_hp` defaults true in Main and triggers the already-tested lossless salvage transaction, local port and belt disconnections, source removal, wreckage, and selection cleanup. If recovery fails, the belt is not removed and can be recovered explicitly later.
- Existing movement and building-melee regression fixtures explicitly set `movement.target_conveyors = false`; the historical F1 durability suite sets `service.destroy_conveyors_on_zero_hp = false` to preserve its original manual-deletion checks.
- New `res://tests/live_zombie_conveyor_destruction_test.tscn` (**12 assertions groups, pending local Godot F6**) exercises Main-world live zombie belt preference, preview exclusion, physical Storage→belt→belt connections, melee range and cooldown, a fifth 10-HP hit destroying an occupied straight belt, local disconnection and neighboring cargo preservation, retargeting and damaging another straight belt, invalid cargo fail-closed recovery with manual retry, and destroying both corner shapes with salvage conservation.

**Validation boundary:** Code has been committed but Godot and live player-controlled F5 gameplay have not yet validated the new belt-targeting behavior. Existing wreckage remains an uncollectable runtime placeholder. Do not regard the customizable build hotbar as implemented; it remains planned after the destruction milestone.


### Step 09.18F2 — Diagonal belt arrival regression fix (pending local re-test)

The first local F6 run of `res://tests/live_zombie_conveyor_destruction_test.tscn` stopped at the PASS I retargeting arrival assertion (line 166 in the initial revision): a moving zombie had selected the second intact conveyor after destroying its upstream neighbor, but `movement_status` had not yet become `At Structure`. This occurred **after** the test's initial destruction and salvage checks. Root cause is suspected floating-point drift at the diagonal 1.5-unit stopping boundary, not proven until local re-test.

Updated `ZombieApproachComponent` to treat movement within **0.001 world units** above stopping distance as arrived; the move distance and combat range are unchanged. Updated PASS I to allow up to four normal 0.1-second movement ticks to settle and to print zombie position, selected target and movement status if the assertion still fails. No changes were made to inventory transfer, source deletion, damage, or belt geometry. The full 12-case run and relevant historical movement regressions remain **unverified after this correction**.


### Step 09.18F2 — Live zombie conveyor destruction regression accepted (12/12)

On **2026-11-02**, the developer reran `res://tests/live_zombie_conveyor_destruction_test.tscn` in Godot 4.6.2 and provided output confirming **ALL 12 LIVE ZOMBIE CONVEYOR DESTRUCTION TESTS PASSED** (PASS A–L). The first run had stopped on the second-belt arrival assertion in PASS I; after adding a **0.001-unit arrival tolerance** and bounded diagnostic settling to the regression, the entire suite passed.

The accepted run validated: Main-world belt targeting and guarded destruction; construction-preview exclusion; connected Storage → first belt → second belt with cargo; approach/range gating and 10-HP melee; one-second attack cooldown; fifth hit destroying a 50-HP straight belt; local connection severing and preservation of Storage/neighbor belt stock; retargeting the next straight belt; invalid cargo blocking deletion until recovery retry; and zombie-triggered removal of a loaded right-corner and empty left-corner belt. Final item accounting: **one salvaged ore, one salvaged ingot, one salvaged ammunition round, plus three ore still stored in the surviving Storage**.

**Remaining acceptance:** Player-controlled F5 demonstration of conveyor destruction, wreckage, and intact adjacent conveyor pieces. After F5, rerun the relevant historical movement, melee, building destruction, and conveyor logistics regressions because enemy targeting and arrival tolerance changed. Do not treat salvage collection, save/load, or the planned customizable build catalog/hotbar as complete.


### Step 09.18F3 — Conveyor destruction observed in playable F5 world

On **2026-11-02**, the developer showed two distinct **WRECKAGE** placeholders near the moving green zombie in regular gameplay, confirming player-placed conveyor destruction now produces visible wreckage. The Production Debug HUD said **No object selected**, consistent with the selected destroyed segment being removed. Cargo preservation and intact neighboring belt behavior had previously passed the 12-case integration regression, but cannot be inferred independently from this screenshot.

**User-reported UI gap:** Clicking an intact conveyor did not reveal its health. Root cause in `ProductionDebugHUD._refresh_display()`: it only handled resource-node and BuildingRuntime branches; `ConveyorSegment` objects have neither, so their HP was not displayed. The empty-selection label after destruction is expected.

### Step 09.18F4 — Conveyor durability, cargo and connection HUD (code committed; F6 pending)

- `scripts/production_debug_hud.gd` now checks for `ConveyorSegment` before resource nodes and buildings. The shared HUD renders the selected belt's identity, **HP current / maximum**, **Intact / Destroyed**, actual `CargoInventory` count and item display names, plus physical input/output link status (building port, previous/next conveyor, disconnected).
- The change is read-only; no conveyor transport, collision, melee, durability, or damage/destruction code was modified. Existing non-conveyor HUD displays keep their original paths. The activity progress bar remains hidden for conveyors.
- Added `res://tests/conveyor_health_hud_test.tscn` (**12 checks; local Godot 4.6.2 verification pending**), covering WorldInteraction selection, all three belt shapes, dynamic HP and cargo changes, building/neighbor belt links, HUD progress visibility, automatic clearing of selection upon damage-triggered belt destruction, salvage accounting, and reselecting the intact next segment.

**Next:** Run the new HUD test scene in Godot, fix any resulting errors, then verify by F5 selecting an intact belt and watching its displayed HP change while the zombie attacks. Before closing the destruction milestone, rerun important legacy logistics/movement/combat regressions. The customizable Build Catalog/hotbar remains the next planned major UI feature.


### Step 09.18F4 — Conveyor health and cargo HUD accepted (12/12)

On **2026-11-02**, the developer ran `res://tests/conveyor_health_hud_test.tscn` in Godot 4.6.2 and supplied output confirming **ALL 12 CONVEYOR HEALTH HUD TESTS PASSED** (PASS A–L). The local run verified a clean initial HUD, selection and 50/50-HP display across straight and both corner segments, changes to displayed HP after damage, live inventory quantities and item names, connected building/downstream/previous-belt input-output labels, hidden production progress for belts, selected-belt removal clearing HUD/selection, cargo preserved in wreckage, and reselecting the surviving downstream belt.

**Next acceptance:** In regular F5 gameplay, select an intact belt with a zombie approaching and verify the Production Debug HUD changes from **HP: 50 / 50** through 10-HP decrements, then clears when that belt is destroyed. This manual check has **not yet been provided**. Afterward, run a final historical regression set for movement, melee, building destruction, conveyor logistics and cargo conservation, including the new arrival tolerance and both types of damageable targets. Preserve the planned unlocked-building catalog and customizable quickbar as the next major UI phase once the destruction milestone is accepted.


### Step 09.18F5 — Conveyor durability HUD confirmed in player-controlled F5 gameplay

On **2026-11-02**, the developer submitted a screenshot of the actual F5 game showing a **yellow-selected intact conveyor** next to the moving green zombie. The Production Debug HUD showed **Conveyor Durability: HP 40 / 50, Status: Intact**, **Cargo: Empty, Capacity: 0 / 1**, and **Input: Disconnected, Output: Disconnected**. This confirms the new selected-belt HUD displays a partially damaged live conveyor; the missing-health-display issue is resolved. The screenshot also shows multiple earlier wreckage caches from destroyed conveyors. Automatic selection/HUD clearing on final destruction is separately covered by the passing **12/12** HUD regression and prior F5 wreckage observation.

Minor future UI polish: selected belt's runtime node name currently appears as a Godot-generated label such as `@Node3D@10`; show an intuitive building/belt type or user-facing name in a later UI pass, without changing the working combat or cargo flows.

### Step 09.18 — Final historical regression gates (planned)

Before calling full building-and-conveyor destruction complete and moving into the **customizable Build Catalog/hotbar**, rerun representative Godot scenes in three manageable rounds:

1. **Movement and combat** — `prototype_moving_zombie_test.tscn`, `live_moving_zombie_integration_test.tscn`, `zombie_building_melee_test.tscn`, `live_zombie_melee_integration_test.tscn`. These must remain compatible with the new `target_conveyors` flag and 0.001-unit arrival tolerance.
2. **Factory/physical logistics** — `conveyor_physical_only_conservation_test.tscn`, `ammunition_press_build_mode_test.tscn`, and `defensive_turret_build_mode_test.tscn` (additional belt connection tests as needed), guarding item conservation and core construction.
3. **Destructive recovery** — `live_zombie_destruction_test.tscn`, `controlled_destruction_transaction_test.tscn`, `world_salvage_destruction_test.tscn`, `live_zombie_conveyor_destruction_test.tscn`. Existing focused conveyor HUD and 50-HP durability suites already passed and can be revisited if any regression fails.

**Status:** The new F5 HUD demonstration is accepted. These historical reruns have **not yet been confirmed** after the latest combat/UI changes. Do not mark regression rounds as passed until local Godot results are supplied.


### Step 09.18 — Final regression Round 1 accepted, Round 2 pending

The developer confirmed that all **four movement and combat test suites passed locally in Godot 4.6.2** on 2026-11-02. These covered the prototype moving zombie, main-world moving zombie, isolated building melee and main-world melee integration. The existing building-only test fixtures therefore remain compatible with recent enemy conveyor targeting and movement-arrival adjustments.

**Next gate — Round 2 factory and physical logistics:** Run the three existing scenes for physical-only resource conservation (**9 checks**), ammunition production building placement (**9 checks**), and defensive building placement (**12 checks**), for a total of **30 checks**. These round-two reruns are pending; do not mark them passed without local results. Round 3 will cover destruction and salvage recovery. No gameplay code was changed for this documentation checkpoint.


### Step 09.18 — Final regression Round 2 accepted (30/30)

On **2026-11-02**, the developer confirmed that all three factory/logistics regression suites passed again in local Godot 4.6.2. `conveyor_physical_only_conservation_test.tscn` passed **9/9**, `ammunition_press_build_mode_test.tscn` passed **9/9**, and `defensive_turret_build_mode_test.tscn` passed **12/12**, totaling **30/30** checks. Physical resource accounting, ammunition-press build logic and turret build/connection safeguards therefore remain compatible with the new zombie building/conveyor destruction changes.

### Step 09.18 — Final regression Round 3 (pending)

The final destruction and salvage verification uses four existing Godot F6 scenes, each containing 12 checks (**48 checks total**): `live_zombie_destruction_test.tscn`, `controlled_destruction_transaction_test.tscn`, `world_salvage_destruction_test.tscn`, and `live_zombie_conveyor_destruction_test.tscn`.

Confirm lossless building/belt destruction, nearby conveyor survival, independent world wreckage caches, guarded recovery refusal and retry, live zombie targeting and conveyor breakage. The focused conveyor health HUD has already passed 12/12 and has F5 gameplay evidence, so rerun it only if a new regression affects selection or UI.

**Status:** Rounds 1 and 2 are accepted; Round 3 is not yet rerun after the latest changes. Do not call the overall destruction milestone closed until the local results arrive. Customizable Building Catalog/1–9 hotbar is scheduled next.


### Step 09.18 — Destruction milestone accepted after final Round 3 (48/48)

On **2026-11-02**, the developer confirmed the four final destruction and salvage test suites all passed again in local Godot 4.6.2, **48/48 checks**. These covered Main-scene zombie building destruction, guarded transactions, persistent-in-scene salvage/wreckage, and zombie conveyor/corner destruction. With Round 1 (all four movement/combat suites) and Round 2 (**30/30 factory/logistics checks**) already passed, the **core building and conveyor destruction milestone is complete**.

Acceptance includes automatic zombie damage to 100-HP buildings and 50-HP belt segments, local disconnection, destroyed source removal, world wreckage placeholders and lossless inventory/cargo accounting. Manual F5 gameplay previously confirmed building and conveyor wreckage and the selected conveyor's **40/50 HP** display.

Deferred systems: player-pickable salvage, persistence between saves, destruction balancing, final debris effects, more advanced zombie navigation and waves. These do not invalidate the accepted foundation.

### Phase 1G1 — Stable building IDs and configurable hotbar model (committed; F6 pending)

- Existing `WorldInteraction` uses nine Build Mode slots indexed into `buildable_definitions`; the Build HUD hardcodes all nine labels, and numerous specialized Conveyor Belt branches compare `selected_building_index == 4`. Changing keys prematurely would break logistics, so live input/UI remains unchanged at this step.
- Added `scripts/components/build_hotbar_configuration.gd` with `BuildHotbarConfiguration`, an independent nine-slot assignment model. Catalog items are keyed by stable `BuildingDefinition.building_id`; all nine prototype buildings start unlocked until the progression system exists.
- The model supports default ordering, catalog enumeration, lookup by slot, swapping existing assignments, clearing and replacing slots, locking/unlocking with safe unequip, and JSON-compatible save/restore payloads (versioned ID strings). Restoration rejects malformed payloads and ignores missing, duplicated or currently locked IDs. No file is written on disk yet.
- Added `res://tests/build_hotbar_configuration_test.tscn` with **12 checks awaiting local Godot validation**, including Turret → key 1, Storage → key 9, moving the belt out of slot 5, restoring a JSON snapshot after catalog reordering, unlock restrictions and malformed save safety.
- **Next:** Pass the isolated F6 test. Then replace the 4-index Conveyor Belt assumptions with definition identity/type in a separate regression, connect configurable slot selection to the existing Build HUD, and add the unlocked-building menu and disk persistence. The current playable factory and combat systems remain unchanged.


### Phase 1G1 — Stable-ID hotbar model accepted (12/12)

The developer supplied local Godot 4.6.2 output confirming **ALL 12 BUILD HOTBAR CONFIGURATION FOUNDATION TESTS PASSED** on 2026-11-02. The test verified all nine unique building IDs, unchanged default slots, Turret → 1 and Storage → 9 swaps, moved/cleared Conveyor Belt assignments, unlock guards, stable-ID JSON-compatible snapshots and restores after catalog reordering, and malformed/duplicate/locked ID rejection without changing live Build Mode.

### Phase 1G2 — Conveyor tool identity migration (code committed; F6 pending)

The existing `scripts/world_interaction.gd` contained **22** comparisons of `selected_building_index == 4` or `!= 4` governing conveyor-specific snap previews, corner discovery, bridge/offset placement, debug keys H/J/K and ghost-scene overrides. They all now call the shared `_is_conveyor_selected()` helper, which tests `_get_selected_building_definition().building_id == &"conveyor_belt"`. The helper avoids relying on the definition's current array position or assigned quick-build number. No changes were made to actual conveyor transport/snapping algorithms, Build HUD labels, current numeric input routing, or physical placement geometry.

Added `res://tests/conveyor_building_identity_test.tscn` (**12 checks pending local Godot 4.6.2 validation**). This uses an isolated Main scene to verify default Conveyor Belt selection and both left/right ghost-scene overrides, rejected overrides when Turret is selected, all nine original building identities, hotbar data-model assignment independently from Main, and a simulated catalog reordering that puts Conveyor Belt at index **0** and Test Extractor at index **4**. It then proves corners still preview at index 0, the old index 4 cannot trigger conveyor previews, invalid selections remain harmless, and the original catalog/ghost cleanup still work.

**Regression boundary:** This is an identity-only refactor. Arbitrary number-key remapping and user-facing Build Catalog are **not enabled** until this F6 test and related physical conveyor placement regressions pass. Continue respecting the current 1–9 Build HUD labels and existing construction controls.


### Phase 1G2 — Stable conveyor identity regression accepted (12/12; 2026-11-04)

The developer supplied a Godot 4.6.2 screenshot confirming **ALL 12 CONVEYOR BUILDING IDENTITY TESTS PASSED**. The migration from 22 `selected_building_index == 4` / `!= 4` branches to the stable `building_id == &"conveyor_belt"` helper preserved straight, left-corner and right-corner placement ghosts. Tests also passed when Conveyor Belt occupied catalog index 0 and Extractor occupied the former index 4, including guards against using conveyor previews on non-conveyor types. The original catalog and placement cleanup remained intact.

The messages `Extractor has no resource node` appeared **after** the success sentinel and are expected for temporary Extractor instances/ghosts in an isolated test without a deposit; they do not overturn the 12 passed assertions.

Before activating hotbar remapping, rerun eight relevant historical Godot F6 scenes (no code changes in this checkpoint), arranged in two focused groups:

- **Round A (37 checks):** `conveyor_building_placement_snap_test.tscn` (8), `conveyor_receiver_auto_snap_test.tscn` (11), `conveyor_source_corner_auto_snap_test.tscn` (10), `conveyor_terminal_building_corner_test.tscn` (8). These protect building input/output snaps and in-place source, receiver and terminal corner conversions.
- **Round B (43 checks):** `conveyor_missing_corner_placement_test.tscn` (9), `conveyor_dual_ended_bridge_test.tscn` (11), `conveyor_fractional_bridge_test.tscn` (12), `conveyor_offset_corner_bridge_test.tscn` (11). These protect missing corners and short, full-length and offset connectors.

**Status:** 1G2 identity regression accepted, historical targeted rounds **pending local Godot reruns (80 checks)**. The active numeric input layout and Build HUD remain fixed. The UI/catalog work follows these passes, with persistent hotbar save/load and eventual unlock progression still unimplemented.


### Phase 1G2 — Targeted conveyor regression Round A accepted (37/37; 2026-11-04)

The developer confirmed that **all four** historical building-port snapping and conveyor-corner F6 scenes passed in Godot 4.6.2 after the 22-branch conveyor identity refactor. The results were: `conveyor_building_placement_snap_test.tscn` **8/8**, `conveyor_receiver_auto_snap_test.tscn` **11/11**, `conveyor_source_corner_auto_snap_test.tscn` **10/10**, and `conveyor_terminal_building_corner_test.tscn` **8/8**, for **37/37**. This confirms those established building-port and corner behaviors remain compatible with selecting Conveyor Belt by `building_id`.

**Next gate — Round B (43 checks; pending local F6):** `conveyor_missing_corner_placement_test.tscn` (9), `conveyor_dual_ended_bridge_test.tscn` (11), `conveyor_fractional_bridge_test.tscn` (12), and `conveyor_offset_corner_bridge_test.tscn` (11). All four scenes are verified present on GitHub main, but **have not yet been rerun** after this refactor.

No production code or hotbar input behavior was modified in this documentation checkpoint. Once Round B passes, proceed incrementally with actual configurable numeric key selection and the dynamic Build HUD, preserving the full conveyor placement/snap pipeline.


### Phase 1G2 — Conveyor gap and bridge regression Round B accepted (43/43; 2026-11-04)

The developer confirmed all four historical bridge/gap F6 suites passed locally in Godot 4.6.2 after the stable-ID conveyor-tool refactor. The reported results were `conveyor_missing_corner_placement_test.tscn` **9/9**, `conveyor_dual_ended_bridge_test.tscn` **11/11**, `conveyor_fractional_bridge_test.tscn` **12/12**, and `conveyor_offset_corner_bridge_test.tscn` **11/11**, for **43/43**. Together with Round A **37/37**, Phase 1G2's **80/80 targeted conveyor regression checks passed**. This accepts the transition from fixed index-4 Conveyor Belt gates to stable `building_id` checks.

### Phase 1G3 — Configurable number-key selection and dynamic Build HUD (committed; F6 pending)

- Updated `scripts/world_interaction.gd` to instantiate a `BuildHotbarConfiguration` at startup, register the nine existing `BuildingDefinition` assets, and apply the original default hotbar assignments. Number keys 1–9 now resolve **slot → stable building ID → active definition index** through `_select_hotbar_slot()`. This preserves the existing underlying placement/snapping implementation and the original InputMap handling for keys 1–5, with physical keys 6–9 as before.
- Added controller APIs `assign_hotbar_slot()`, `clear_hotbar_slot()`, and `set_hotbar_unlocked()` for a future unlocked-building catalog menu. A cleared/locked slot is visually empty and its key does nothing; if the currently selected building loses its assignment, the controller selects an available fallback or clears the placement ghost if no slots remain.
- Updated `scripts/build_hud.gd` to show the actual assigned building for each key and highlight the slot containing the selected building. The familiar prototype labels are retained by small player-facing name aliases. An unassigned slot displays `Empty`. `selected_building_index` continues referring to the real definition for placement.
- Added `res://tests/build_hotbar_keyboard_integration_test.tscn` (**12 cases; local Godot run pending**). It drives the real Main-world keyboard handler and Build HUD, confirming legacy keys, assigning **Turret → 1** and **Storage → 9**, moving **Conveyor Belt → 4** while preserving right/left corner ghosts, changing key 5 to Smelter, empty slot behavior, unlock restrictions, reset defaults, and Build Mode cleanup.
- **Deliberate scope boundary:** The keyboard remapping APIs are live, but **no user-facing catalog menu exists yet** and assignments **are not saved to disk**. Do not call the new UI complete until a player can open a menu and persist changes across sessions. The 1G3 Godot regression still needs a local run before normal F5 validation.


### Phase 1G3 — First keyboard/HUD F6 regression stopped at Turret preview identity (2026-11-04)

The first local `res://tests/build_hotbar_keyboard_integration_test.tscn` run stopped at the **PASS F** assertion (original line 88) after successfully establishing the Turret's mapped building definition and stable ID. The old assertion tested whether the new preview scene root's `Node.name` began with `PrototypeDefensiveTurret`. Repeated quick-build selection can queue the previous preview for deletion until frame-end, causing Godot to give the newly instanced preview an autogenerated name; this name is not a reliable gameplay identity.

Replaced both name-based assertions (default key 9 and remapped key 1) with `_is_turret_preview()`, checking the active building ID, actual packed-scene path, `TurretComponent` type, and `construction_preview` group. No production code, HUD logic, keyboard routing, inventory, or conveyor placement was changed in this correction.

**Status:** Test-only correction committed; **full 12/12 local rerun pending**. Do not mark 1G3 accepted until the Godot result is supplied.


### Phase 1G3 — Live build hotbar keyboard/HUD regression accepted (12/12)

The developer reran `res://tests/build_hotbar_keyboard_integration_test.tscn` in local Godot 4.6.2 and supplied output showing **ALL 12 BUILD HOTBAR KEYBOARD INTEGRATION TESTS PASSED**. The previously failing Turret preview assertion now checks actual scene/component identity instead of the unstable auto-generated runtime node name. All A–L checks passed: default hotbar layout and labels, keys 5 and 9, remapping Turret to key 1, Storage to key 9, Conveyor Belt to key 4 (including both corner previews), key 5 becoming Smelter, inert empty slots, unlock restrictions, default reset and Build Mode cleanup.

The `Extractor has no resource node` diagnostic was emitted after the success sentinel, as expected for temporary prototype Extractor instances without a deposit.

**Next acceptance:** Manual F5 smoke test of the default number-key layout and dynamic Build HUD. Player-created remappings cannot yet be tested through the F5 UI because the unlocked Build Catalog/editor is still pending. Phase 1G4 will provide those controls, followed by a remapped F5 acceptance test and persistent hotbar file storage. No production code was changed during this results checkpoint.


### Phase 1G3 — Default-key highlights confirmed in F5; wreckage interaction gap found

On **2026-11-04**, the developer confirmed the **1–9 shortcut highlights switch correctly** during regular F5 gameplay. The associated screenshot showed a functioning factory, enemies and surviving wreckage, including a `SALVAGE: 15` cache. The exact individual key mappings were covered separately by the accepted 12/12 keyboard integration suite. Phase 1G3 is accepted.

**Usability report:** Wreckage could not be clicked, highlighted, inspected or cleaned up. This is due to the original `WorldSalvageCache` scene having only a mesh/label/inventory, with no physics selection collider or selectable group. The debug HUD also lacked a salvage-specific display. The project requires safe cleanup without silently discarding recovered resources.

### Step 09.18G — Wreckage selection, inventory info and protected cleanup (committed; F6 pending)

- Added `selectable` group membership and a **Layer-2-only StaticBody3D collision box** to `world_salvage_cache.tscn`. It does not use the factory placement-blocker physics layer and is never added to `player_built`, so zombie structure targeting and normal conveyor placement rules are unchanged.
- `WorldSalvageCache` now implements `set_selected()` and `set_demolition_hover()` with yellow inspection highlighting, red empty-wreckage demolition hover and amber protected-stock hover. The new `can_clear_safely()` check requires the inventory dictionary to be truly empty; it refuses malformed/unknown inventory contents and does not use only the reported total.
- The `ProductionDebugHUD` now detects selected wreckage independently of building/conveyor components, displays **Total Items**, the actual stored item names and quantities and a clear `Protected: recover contents before cleanup` or `Empty: can remove in Demolition Mode` instruction. It remains read-only.
- `WorldInteraction` includes WorldSalvageCache in demolition targeting and exposes `_try_clear_salvage_cache()`: only empty wreckage can be queued for removal. If selected, its HUD and selection clear immediately; stocked wreckage is never deleted or drained by the demolition action.
- New `res://tests/wreckage_selection_cleanup_test.tscn` contains **12 isolated Main-world integration checks pending local F6 validation**. These cover salvage ownership and groups, selection-layer raycast, highlighting/HUD, progress-bar absence, empty cleanup, cargo-bearing wreckage item inspection and protection, malformed contents refusal, a simulated lossless inventory transfer into an independent test container and cleanup only afterward, with **10/10** transferred resources preserved.
- **Scope boundary:** This checkpoint does **not** implement salvage pickup, inventory transfer from the player's hand, storage access through the world, or saving salvage between sessions. A stocked salvage cache remains protected from player demolition until a dedicated collection/recovery interaction exists. The planned in-game Build Catalog resumes after this safety checkpoint passes.


### E3d5a — Blueprint construction priority metadata and sorted waiting jobs (2026-11-10; F6 pending)

Implemented in the Factory Testing Sandbox after E3d4b's successful area-selection validation. ConstructionJob now accepts High, Normal and Low priorities and signals changes without altering authorization or elapsed work. Within the Q selection tool, **H / N / L** assign priority to the selected planned structures; **E** still authorizes only the selection and **Ctrl+E** still authorizes all. The Factory Blueprints HUD shows the selected priority composition, waiting queue count and next waiting job. The queue stores weak references to authorized QUEUED sites and orders them by priority, then original authorization sequence; started, cancelled or destroyed jobs drop out of the waiting list.

**Important testing boundary:** The Factory Testing Sandbox retains its explicit power/material/worker availability bypass, so jobs normally move directly to CONSTRUCTING. This queue cannot allocate drones or make a blocked job start; it is scheduling metadata for future worker capacity. A dedicated regression temporarily disables sandbox debug readiness to verify real QUEUED order and requirement gates without weakening Main. Added `res://tests/blueprint_construction_priority_e3d5a_test.tscn` with 15 checkpoints; **all 15/15 passed** in developer-provided Godot 4.6.2 screenshot (2026-11-10). Manual Q-selection and H/N/L assignment accepted (2026-11-10): the developer supplied a Factory Testing Sandbox screenshot showing Planned 6, Selected 6, priorities H 2 / N 2 / L 2, Queued 0 and Building 0. The sandbox pre-authorization queue remains empty as expected. Automated regression covers E authorization; no manual post-E construction screenshot has been provided. Re-run existing E3d4b area selection and earlier construction regression after acceptance if necessary.



### E3d5b — Isolated finite-worker construction scheduler (2026-11-10; 15/15 F6 passed)

Added `scripts/components/blueprint_construction_slot_scheduler.gd`, a scheduler with 1–16 slots (two in the first test) and stable priority ordering. It accepts authorized queued sites registered through the existing priority queue, but **fails closed** until the caller supplies an explicit power/material readiness snapshot per site. It mirrors those external flags into the existing ConstructionJob availability gates and assigns finite worker permission. It neither fabricates resources nor advances time, starts an unauthorized blueprint, or creates physical drones.

Active jobs are non-preemptive. If power/material readiness disappears, a job pauses, retains elapsed work and frees its slot. Restoring readiness still requires a free slot. Completion and cancellation safely release capacity. Added `res://tests/blueprint_construction_slots_e3d5b_test.tscn` with 15 isolated checks. **Godot 4.6.2 F6 validation passed 15/15 checks**, confirmed by developer-provided screenshot on 2026-11-10. Normal Factory Testing Sandbox debug construction remains immediate because this service is not enabled or instantiated by WorldInteraction.

Next milestones: design and verify real power/material availability providers separately, then connect finite worker assignments to construction and physical drones. Maintain sandbox-only feature gating until regression-tested.


### E3d5c1 — Read-only stock and power inspection staged (2026-11-10; F6 pending)

Reviewed the accepted E3d5b scheduler, `ConstructionJob` state machine, `ConstructionSite`, inventory API, `BuildingDefinition`, and the sandbox's explicit test-only requirements override. `BuildingDefinition` has a duration and footprint but no construction bill of materials; the scheduler currently accepts test-controlled readiness booleans rather than real provider evidence.

Added `BlueprintConstructionReadinessProbe` as an isolated, non-mutating diagnostic. An authorized live site, explicitly typed power report, nonempty valid material bill and active stock inventory are independently checked; missing item quantities are reported. Unknown power, missing/invalid costs, detached stock and cancelled/planned sites fail closed. No materials are removed or reserved, and no job or worker is started. Because two jobs can see the same unreserved stock, **stock sufficiency is deliberately NOT passed into the scheduler**.

Staged `res://tests/blueprint_construction_readiness_e3d5c1_test.tscn` (15 PASS checkpoints A–O); **local Godot F6 verification pending**. No edits to WorldInteraction, Main, Factory Testing Sandbox, legacy construction, logistics or combat. Next: atomic material reservation/escrow with real bills of materials, real power provider, then a gated worker-scheduler adapter and physical drones.

### 2026-11-11 — E3d5c1 Passed; E3d5c2a Escrow Staged

**Verified:** User-provided Godot 4.6.2 screenshot reports PASS A–O and `ALL 15 E3D5C1 CONSTRUCTION READINESS PROBE TESTS PASSED`. No new debugger errors are visible.

**New isolated implementation:** `BlueprintConstructionMaterialEscrow` synchronously checks and removes a complete explicitly supplied positive bill from a live `InventoryComponent` into a stable per-site ledger for authorized QUEUED work. Insufficient or competing jobs cannot double-spend stock. Cancellation and premature site deletion trigger refund attempts; if original stock cannot accept the full batch, the reservation persists with `needs_recovery` for explicit `recover_to` to another live stock. Actual completed building activation commits the exact held items once. This code does not call the worker scheduler or grant availability flags, workers, power or work progress.

**Next F6 gate:** `res://tests/blueprint_construction_material_escrow_e3d5c2a_test.tscn` (16 checks A–P), Godot verification pending. Construction bills are TEST-ONLY and not saved into `BuildingDefinition` yet. No live scene or gameplay integration and no persistence support.

### 2026-11-11 — E3d5c2a Passed 16/16; E3d5c2b Construction Bills Staged

**Accepted:** Developer Godot 4.6.2 screenshot confirms PASS A–P and `ALL 16 E3D5C2A CONSTRUCTION MATERIAL ESCROW TESTS PASSED`. Verified atomic material holding, competing claims, cancellation refunds, full-storage recovery, completed-site consumption, and unchanged worker gates. No new errors are visible in the provided Output.

**Staged:** `BuildingDefinition` now exposes `construction_materials: Array[ItemAmount]`, reusing the engine's existing production-recipe data type. All nine current buildable resource definitions have nonempty provisional costs referencing existing Test Ore/Ingot resources. The new, isolated `ConstructionMaterialBill` validator builds a read-only, positive-integer `ItemDefinition → amount` escrow bill, rejecting missing, malformed or duplicate logical items. No inventory or scheduler mutation occurs in the validator.

**Acceptance gate:** `res://tests/blueprint_construction_costs_e3d5c2b_test.tscn` includes **17 A–Q checks awaiting developer F6**. It tests data validation and the already-accepted escrow with paused/completed job timing. Cost balancing, reliable starter stock, real power, worker dispatch and save/load remain separate future milestones. Main and factory sandbox behavior, including explicit debug readiness, remain unchanged.

### 2026-11-11 — E3d5c2b Accepted 17/17; E3d5c3a Isolated Power Topology Staged

**Accepted:** Developer screenshot of Godot 4.6.2 Output confirms PASS A–Q and `ALL 17 E3D5C2B DEFINITION CONSTRUCTION COST TESTS PASSED`. Construction bills, invalid data rejection, duration preservation, actual escrow deduction, refunds, pause/resume and final consumption passed. No errors visible in the output.

**Staged:** Added offline-by-default `ConstructionPowerNetworkNode` fixture and an isolated `ConstructionPowerCoverageNetwork` topology evaluator. Only an operational online source with explicit range-valid links can energize relays. Overlapping circles cannot form links, and disabled/moved/destroyed nodes or source outages remove downstream power dynamically. Full rotated footprint containment is required: a partially covered building is not considered covered.

**New F6 gate:** `res://tests/construction_power_coverage_e3d5c3a_test.tscn` stages 16 checks A–P pending developer validation. Power flags in this test are synthetic; the game still lacks real Main Hub/pole scene ownership, generation budget and consumer allocation. This service **never** sets construction availability or grants worker slots. Main/Factory Testing Sandbox and all existing logistics/combat systems remain unchanged.

### 2026-11-11 — E3d5c3a Power Coverage Passed 16/16; E3d5c3b1 Completed Structures Staged

**Validation:** Developer-provided Godot 4.6.2 screenshot shows PASS A–P and `ALL 16 E3D5C3A POWER COVERAGE NETWORK TESTS PASSED`, with no errors visible in Output. Rooted topology, explicit range-checked links, relay loss, rotation, disconnection, and no job-permission side effects are accepted.

**New isolated checkpoint:** Added `PrototypePowerStructure` as a completed-entity runtime with a child electrical node and real `BuildingHealthComponent`. Two light prototype scenes were staged: a prebuilt Hub (rated 12 generation units, service radius 4.5) and an unfinished buildable Power Pole (0 generation, coverage radius 3.5; provisional 2 Test Ingots and a 6-second timer). The pole is not registered in the player hotbar. Hub/Pole state derives from actual completed scene, health and enabled switches, not direct test writes to the electrical node. A planned Power Pole has no electrical node until actual building activation.

**Safety:** Updated `ConstructionPowerCoverageNetwork` to reject nodes whose owning parent structure is already queued for deletion; this closes a single-frame stale-power window and should retain E3d5c3a behavior. Fixed prototype output remains a nameplate rating, not allocated electricity; fuel, consumption and simultaneous demand are unimplemented. Nothing passes electricity into worker authorization or fabricates materials.

**Next F6 gate:** `res://tests/completed_power_structures_e3d5c3b1_test.tscn` (16 checks A–P, pending Godot). If accepted, rerun `res://tests/construction_power_coverage_e3d5c3a_test.tscn` (16 checks) for compatibility. Main/Factory Testing Sandbox and physical conveyor/combat flows remain unchanged.

### 2026-11-11 — E3d5c3b1 Dedicated F6 Accepted (16/16); Regression Pending

Developer's Godot 4.6.2 screenshot confirms PASS A–P and `ALL 16 E3D5C3B1 COMPLETED POWER STRUCTURE TESTS PASSED`. No errors visible in Output. Completed Hub/Pole runtime ownership, construction-gated activation, explicit links, source/service shutdown, health-depletion shutdown and deletion guard passed. This is a dedicated isolated test, **not** confirmation that the older E3d5c3a test passed after the code changes.

**Next required acceptance:** rerun `res://tests/construction_power_coverage_e3d5c3a_test.tscn` (16 checks) and review Output/Debugger. Power supply-demand allocation and sandbox integration remain blocked pending that regression.

### 2026-11-11 — E3d5c3b1 Compatibility Confirmed 16/16; E3d5c3b2 Power Budget Staged

**Developer validation:** Reran `res://tests/construction_power_coverage_e3d5c3a_test.tscn` after E3d5c3b1 and confirmed all 16/16 A–P checks passed in Godot 4.6.2 with no visible Output errors. Together with previously accepted E3d5c3b1 16/16, 32/32 power regressions are now accepted.

**New isolated E3d5c3b2 implementation:** Read-only `ConstructionPowerCoverageNetwork.get_operational_component()` traverses only explicit, currently valid operational links. `PrototypeConstructionPowerAllocator` computes per-component generation by summing enabled, intact, completed `PrototypePowerStructure.available_nameplate_generation()`, rejecting bare manually flagged nodes as generators. Each authorized construction site has a positive test-supplied energy demand, allocated in full or not at all to avoid overcommitting rated power. Active CONSTRUCTING jobs are preferred before queued priority High/Normal/Low, FIFO within ties; network changes and outages are reflected on each query. Neither worker scheduling nor job availability is touched.

**Gate staged:** `res://tests/finite_construction_power_e3d5c3b2_test.tscn` with 18 scripted checks A–R, **pending local Godot F6**. Retest existing E3d5c3a and E3d5c3b1 afterward. This prototype handles *nameplate allocations only*; it does not represent fuel burn, actual power delivered, save/load, charging energy, or resource consumption. Main and Factory Testing Sandbox are unchanged.

### 2026-11-11 — E3d5c3b2 First Godot Run: Test-Q Use-After-Free Corrected (Retest Pending)

The developer's Godot 4.6.2 debugger screenshot shows execution stopping at `tests/finite_construction_power_e3d5c3b2_test.gd:216`: `low.free()` was followed by `allocator.get_allocated_units(low)`, passing an already-freed Object into a typed `ConstructionSite` argument. This is a regression-test harness error, not an observed failure of the allocator's power calculation. The original **18/18 acceptance is NOT confirmed**.

The isolated test now keeps a `WeakRef` and an allocation-map entry count before freeing the site, verifies that the reference becomes null, confirms the allocation snapshot shrinks by exactly one entry, and confirms the still-active Normal job retains its five-unit allocation. No production allocator, power topology, factory sandbox, worker scheduler, inventory, or gameplay files were changed in this correction.

**Next required check:** rerun `res://tests/finite_construction_power_e3d5c3b2_test.tscn` with F6 and verify `ALL 18 E3D5C3B2 FINITE CONSTRUCTION POWER TESTS PASSED`, including no new debugger errors. Then run E3d5c3a and E3d5c3b1 power regressions before integrating anything.

### 2026-11-11 — E3d5c3b2 Finite Construction Power Accepted (18/18); Compatibility Pending

The developer reran `res://tests/finite_construction_power_e3d5c3b2_test.tscn` in Godot 4.6.2 following the Test-Q use-after-free fix. The supplied Output screenshot shows PASS A–R, including `PASS Q: Cancelled, untracked and freed jobs do not retain capacity`, `PASS R: Destroyed Hub removes power, never fabricates progress or workers`, and `ALL 18 E3D5C3B2 FINITE CONSTRUCTION POWER TESTS PASSED`. No errors are visible in the provided Output.

The finite allocator remains isolated and read-only with respect to worker/job availability, inventory, material escrow and build timers; its limits are provisional completed-generator nameplate ratings, not actual energy production or fuel use. **Required before advancing:** rerun earlier power topology and completed-structure F6 scenes (E3d5c3a 16 and E3d5c3b1 16) on this current code. Do not claim those post-change regressions passed until developer evidence is supplied.

### 2026-11-11 — Power Milestone Accepted 50/50; E3d5c3c1 Readiness Coordinator Staged

**Developer regression evidence:** Separate Godot 4.6.2 screenshots show E3d5c3a **16/16** and E3d5c3b1 **16/16** passing on the current branch, after E3d5c3b2 **18/18** had already passed. Combined **50/50 power tests accepted**, with no errors visible in the screenshots. The earlier E3d5c3b2 test-Q use-after-free is resolved.

**New isolated checkpoint:** Added `BlueprintConstructionReadinessCoordinator`, assembling verified material-cost metadata, per-job atomic escrow, prototype finite nameplate power allocation, and the existing worker-slot scheduler. Requirements remain separately gated: a job without an owned material escrow cannot request electrical allocation; power results are delivered to the scheduler only after material-ownership verification; that scheduler alone grants/revokes finite workers. Reservations occur in priority order (active work kept), and simultaneous power demand is bounded by the existing allocator. Generator outage pauses construction while preserving elapsed time and held materials; restored power and cancelled jobs permit reassignment. This code never advances job timers and is only exercised by an isolated fixture.

**Verification pending:** `res://tests/construction_readiness_coordinator_e3d5c3c1_test.tscn` contains **18 checks A–R** requiring local F6. The test uses a completed prototype Hub/Pole, 3-ingot Storage bills, one worker slot, and explicit `ConstructionJob.advance()` calls. No player-facing Factory Testing Sandbox/Main changes; power is still a provisional nameplate capacity, not actual energy consumption or fuel.

### 2026-11-11 — E3d5c3c1 Integrated Construction Readiness Passed 18/18

The developer's Godot 4.6.2 Output screenshot confirms all 18 A–R checks and `ALL 18 E3D5C3C1 CONSTRUCTION READINESS COORDINATOR TESTS PASSED` with no errors visible. The isolated fixture verifies that scarce materials are reserved from the inventory before jobs request finite prototype power; the scheduler grants only bounded worker slots; active work remains non-preemptive; a power outage pauses and preserves elapsed progress/material escrow; restoration selects waiting higher-priority work; cancellation refunds and real building completion commits materials exactly once.

**Compatibility gate:** Fresh F6 runs are required for E3d5b worker slots (15), E3d5c2a material escrow (16), and E3d5c3b2 finite power (18) — **49 checks total**. This commit only records acceptance evidence; no gameplay/worker/power code is modified. Factory Testing Sandbox and Main remain unintegrated; the source power budget is still provisional generator nameplate capacity. Next code checkpoint must await the regressions.

### 2026-11-11 — E3d5c3c1 Fully Accepted 67/67; E3d5c3c2 Hub Starter Stock Staged

**Fresh F6 regression proof:** Developer screenshots show the E3d5b worker-slot suite **15/15**, E3d5c2a material escrow **16/16**, and E3d5c3b2 finite power allocator **18/18** passing on the branch containing the E3d5c3c1 coordinator. All **49/49 regressions passed**, plus its previously accepted 18/18 coordinator checks = **67/67 total**. No errors are visible in the screenshots.

**Sandbox integration inspection:** The existing Factory Testing Sandbox still sets `blueprint_sandbox_debug_requirements = true`, and no real Hub starter inventory is available there yet. Do not disable the debug requirement override until a functioning material delivery and powered service are gated and tested.

**New isolated bootstrap checkpoint:** A real finite `InventoryComponent` (capacity 40, initially empty) is staged under `prototype_main_hub.tscn`. `PrototypeMainHubStarterStock` explicitly initializes exactly one new intact operational Hub with a test-only finite 20-Ingot/8-Ore starter loadout, guarded by a per-Hub seeded marker; no implicit scene enter, construction completion or game tick mints resources. Existing InventoryComponent handles material transfers; construction escrow owns reservations/refunds/spending. Invalid item bills, duplicates, full inventory, dead/detached/non-Hub targets and repeat seeding fail closed.

**F6 gate:** `res://tests/main_hub_starter_inventory_e3d5c3c2_test.tscn` has **16 scripted checks A–P awaiting developer Godot 4.6.2**. After acceptance rerun E3d5c3b1 and E3d5c3c1 because the prototype Hub scene gained an inventory. Save/load of starter marker/escrow, actual powered energy, Main Hub placement, real worker drones and live construction deliveries remain separate work.

### 2026-11-11 — E3d5c3c2 First Test Failure: Hub Inventory Lookup

Developer's screenshot shows E3d5c3c2 stopping at line 49 of `main_hub_starter_inventory_e3d5c3c2_test.gd`: the lookup did not return a live typed `InventoryComponent`. The screenshot's Debugger panel shows an assertion failure; the full error text and loaded scene child list were not visible. GitHub's `prototype_main_hub.tscn` includes the expected inventory child and capacity, so the exact mismatch (local resource version vs failed script attachment vs other runtime issue) remains unknown.

Staged a **diagnostic-only** revision of the F6 test to print the Hub's scene path, child names/types/scripts, raw inventory node and typed cast result, and to stop on failure without accessing null inventory, creating resources, or masking a bad scene. E3d5c3c2 is **NOT PASSED** and must be rerun with Output/Debugger screenshots before any production fix or sandbox integration.

### 2026-11-11 — E3d5c3c2 Missing Hub Inventory: TSCN Comment Syntax Fix Staged

Developer's subsequent screenshots show that both the on-disk local scene and Git HEAD contain the expected `InventoryComponent` declaration, but the restarted Godot editor and runtime load only four Hub child nodes. Rechecking the committed scene revealed two `#` comment lines directly before the newly introduced inventory node. Godot's documented TSCN syntax uses semicolon-prefixed comments; these unsupported hash comments are a plausible parser boundary issue. Removed the two comment lines and preserved every scene node, link, script reference, property and inventory capacity.

**Verification pending:** reopen Hub scene after pulling and confirm InventoryComponent appears as a fifth direct child; then run `res://tests/main_hub_starter_inventory_e3d5c3c2_test.tscn` for 16 A–P checks. If this still fails, inspect Godot's scene parse/import errors and the actual node list; do not manufacture fallback stock. The 67/67 previous integration checks remain accepted; E3d5c3c2 is not yet accepted.

### 2026-11-11 — E3d5c3c2 Main Hub Starter Inventory Accepted 16/16

Developer's refreshed Godot 4.6.2 screenshots show the prototype Main Hub scene tree with its `InventoryComponent` as the fifth child, and the standalone F6 test reporting `ALL 16 E3D5C3C2 MAIN HUB STARTER INVENTORY TESTS PASSED` (PASS A–P), with no errors visible in Output. The prior missing-child failure no longer occurs after correcting the nonstandard hash-comment lines in the TSCN resource.

Verified finite, one-time 20 Test Ingots and 8 Test Ore bootstrap, refusal to duplicate startup materials, nonempty-stock and damaged-Hub rejection, inventory transfer conservation, cost-based material escrow, cancellation refund, and real building-completion consumption. Existing Main and Factory Testing Sandbox remain unchanged.

**Pending post-change regressions:** E3d5c3b1 completed power structures 16/16 and E3d5c3c1 readiness coordinator 18/18 (34 checks). Future gameplay enablement still requires reliable save/load of bootstrap marker and escrow, powered network service tied to actual demand, and physical construction material delivery.

### 2026-11-11 — E3d5c3c2 Compatibility Passed 34/34; E3d5c3d1 Inspector Staged

Developer Godot 4.6.2 Output screenshots show E3d5c3b1 **16/16** and E3d5c3c1 **18/18** passing after the Main Hub's inventory fix, for **34/34 compatibility checks**; adding starter inventory's dedicated 16/16 yields **50/50 relevant new and regression checks accepted**. The updated Main Hub retains normal electrical behavior, and the construction coordinator's priority, material reservation, worker gating and pause/cancellation tests remain passing.

**Next small isolated feature:** A new `BlueprintConstructionRequirementsInspector` reads existing ConstructionSite/ConstructionJob metadata, validated per-definition costs, available inventory quantities, actual material escrow ownership, prototype allocation and worker scheduler snapshots. Unknown providers are reported as unknown and fail closed; enough warehouse stock is not a reservation. An all-prototype-gates-observed field is carefully separated from permanently false `live_construction_ready` because there is still no real delivered electricity, persistent escrow or physical construction drones. The inspector cannot authorize, debit, schedule, pause or advance work.

Staged `res://tests/construction_requirements_inspector_e3d5c3d1_test.tscn` with 18 A–R checks pending developer F6. This is the model for a future clickable read-only sandbox requirements UI; no existing UI or world scene was touched.

### 2026-11-11 — E3d5c3d1 Inspector 18/18 Accepted; E3d5c3d2a Clickable UI Staged

Developer Godot 4.6.2 Output screenshot confirms `ALL 18 E3D5C3D1 CONSTRUCTION REQUIREMENTS INSPECTOR TESTS PASSED`, PASS A–R, with no visible Output errors. The isolated read-only inspector is accepted and does not modify material reservations, workers, power, or timers.

**Next focused checkpoint:** Staged a clickable `BlueprintConstructionRequirementsPanel` in an isolated F6 test. The top-right button opens/closes a scrollable status panel showing building bill, stock shortages, escrow ownership, allocated prototype power, worker slot, priority, construction state and progress. Unknown or disconnected data is labeled UNKNOWN; the UI never claims genuine live construction readiness from the sandbox debug bypass. A selected planned blueprint can be followed using the existing `blueprint_area_selected` group, with no input/selection mutation.

`res://tests/blueprint_requirements_panel_e3d5c3d2a_test.tscn` contains **18 test assertions A–R** awaiting developer Godot F6, plus a manual click-open/click-close check in the running game window. F6 fixture simulates service events explicitly; UI component itself uses inspector snapshots only. No Factory Testing Sandbox scene or game logic was changed in this commit. If validated, the next stage is opt-in, read-only sandbox display, keeping debug requirements and keyboard controls untouched.

### 2026-11-11 — E3d5c3d2a Automated Requirements-Panel Tests Passed 18/18

Developer-supplied Godot 4.6.2 F6 Output shows all PASS A–R and `ALL 18 E3D5C3D2A READ-ONLY REQUIREMENTS PANEL TESTS PASSED` with no errors visible. Button press signal handling, closed/open states, real material shortages and escrow visibility, prototype allocation and worker snapshots, outage behavior, retained progress, cancellation/refunds and selection fallback were exercised in the isolated fixture.

**Manual UI acceptance is still outstanding.** The Output contains `MANUAL UI CHECK: Click top-right Construction Requirements button twice.` but no screenshot or confirmation of the displayed running game-window panel or actual mouse clicks has been provided yet. No claim of complete UI acceptance or live Factory Testing Sandbox integration is made.

This is a documentation-only evidence update. The next code checkpoint remains a read-only opt-in Factory Testing Sandbox panel and should begin only after the user confirms the manual visual/clickable behavior. No production scene or input behavior was modified.

### 2026-11-11 — E3d5c3d2a Visual Panel Verified; E3d5c3d2b Sandbox Opt-In Staged

Two user screenshots of the standalone Godot window demonstrate readable scrollable Construction Requirements content with a top-right Close button and explicit `Live readiness: NOT VERIFIED`. Automated tests remain 18/18 passed. Screenshots show an open panel only; manual physical button close/reopen is still awaiting confirmation (even though automated button signals passed).

For the next isolated checkpoint, added a small `SandboxConstructionRequirementsFeatureGate` script and a **disabled-by-default** instance to the actual Factory Testing Sandbox scene. The feature gate creates only the existing read-only panel when explicitly enabled; it follows blueprint area-selection group membership without editing WorldInteraction or any producer/consumer. No material inventory, power allocator, escrow or worker scheduler is provided in gameplay; UNKNOWN is the safe output.

New `res://tests/blueprint_requirements_sandbox_e3d5c3d2b_test.tscn` stages 16 A–P checks using a copy of the real sandbox scene with its UI gate enabled **only for the test instance**. It checks display/selection and that current debug construction/HUD inputs remain unchanged. Godot 4.6.2 F6 and human UI checks remain pending. The existing Factory Testing Sandbox continues with its feature gate off by default and its established debug construction mode unmodified.

### 2026-11-11 — E3d5c3d2b Sandbox UI Gate Passed Automated Tests 16/16

Developer's Godot 4.6.2 Output screenshot contains PASS A–P and `ALL 16 E3D5C3D2B SANDBOX READ-ONLY REQUIREMENTS UI TESTS PASSED`. No errors are visible. The test enabled the otherwise disabled feature gate only for the loaded sandbox instance and verified the original debug construction, blueprint priorities, route controls and HUD, while reading materials and selection state without creating resources or advancing construction.

**Remaining human acceptance:** The user has supplied only the automated Output for E3d5c3d2b so far, not a screenshot of the UI in the running Factory Testing Sandbox or confirmation of physical close/reopen mouse clicks. The printed MANUAL instructions are not evidence that the interactions occurred. Keep the gate off by default and await a screenshot/confirmation before turning it on for normal sandbox sessions.

This is a documentation-only change; WorldInteraction, Factory Testing Sandbox scene, inventory, job scheduling, power, conveyors and combat have not been altered.

### 2026-11-11 — E3d5c3d2b Sandbox Visual Conflict; E3d5c3d2c Adaptive Dock Staged

The developer supplied a screenshot from the real opt-in Factory Testing Sandbox window. The new requirements panel renders Test Storage's definition-owned bill, priority/progress and correctly reports UNKNOWN stock, escrow, power and workers. The existing Factory Blueprints HUD and 3D objects remain visible, but the top-right requirements panel obscures the original **Production Debug HUD**, which is anchored to the same area. Screenshot does not establish physical mouse close/reopen; only automated button checks have passed.

**Focused UI-only correction:** `BlueprintConstructionRequirementsPanel` gains a method to dock under the actual, currently measured Production Debug InfoPanel. The opt-in `SandboxConstructionRequirementsFeatureGate` periodically applies that geometry; the original debug panel itself is never moved or hidden. If the debug panel fills nearly the whole right side, the requirements interface moves to the left below the Factory Blueprints summary. The isolated panel (E3d5c3d2a) retains its existing default layout outside the sandbox gate.

`res://tests/blueprint_requirements_hud_dock_e3d5c3d2c_test.tscn` stages **10 A–J checks awaiting Godot 4.6.2 F6** and a manual in-game screenshot. This changes only the read-only UI and feature gate, not live construction, workers, power, materials, conveyor automation or combat. The sandbox feature gate remains OFF by default.

### 2026-11-11 — E3d5c3d2c Adaptive HUD Dock: 10/10 F6 Passed, Visual Layout Confirmed

Developer supplied two screenshots for the new E3d5c3d2c checkpoint. Godot 4.6.2 Output reports PASS A–J and `ALL 10 E3D5C3D2C SANDBOX REQUIREMENTS HUD DOCK TESTS PASSED`. The 1920×1080 running-window screenshot shows Production Debug at the top-right, the clickable Construction Requirements button and scrollable panel immediately below, and Factory Blueprints at the left, with no visually apparent overlap. The panel correctly describes a planned Test Storage costing 3 Test Ingots with Normal priority and UNKNOWN power/stock/escrow/worker services.

Automated signal checks for toggling passed, but screenshots show only the open panel state, not physical mouse closure and reopening. Accordingly, full mouse-interaction acceptance is still pending. No new source changes were made for this evidence update. Required next runs: the E3d5c3d2a standalone panel suite (18) and E3d5c3d2b sandbox opt-in suite (16), then confirm actual mouse toggling and blueprint selection before considering an opt-in-to-default-on UI setting change. The committed Factory Testing Sandbox requirements feature gate remains disabled by default.

### 2026-11-11 — E3d5c3d2b Post-Docking Regression Passed 16/16; Standalone UI Test Still Needed

Two developer Godot 4.6.2 screenshots show `ALL 16 E3D5C3D2B SANDBOX READ-ONLY REQUIREMENTS UI TESTS PASSED` after the adaptive HUD docking fix. PASS A–P are visible and no assertion errors appear. Existing Factory Testing Sandbox feature gate stays off by default, while isolated UI opt-in and original debug controls remain intact.

The same screenshots contain `Hit nothing`. Repository inspection locates this exact message in `scripts/world_interaction.gd` when a mouse-selection raycast misses a selectable object. It is routine debug feedback and not a construction error. The message alone cannot identify whether it came from a background click or UI interaction; manual click confirmation is still pending.

Required before default-on: run standalone `res://tests/blueprint_requirements_panel_e3d5c3d2a_test.tscn` (18 checks) on the latest code, and verify that actual mouse clicks close/reopen the panel in the F6 game window. No source or scene files were modified in this documentation update.

### 2026-11-11 — All 44/44 E3d5c3d2a/b/c UI Tests Passed on Current Code

Developer Godot 4.6.2 screenshot shows `ALL 18 E3D5C3D2A READ-ONLY REQUIREMENTS PANEL TESTS PASSED` with PASS A–R, after the docking correction. The associated open-panel screenshot shows Test Storage bill/stock/escrow, prototype power and worker readings, and Live readiness NOT VERIFIED. Together with previously accepted post-docking E3d5c3d2b 16/16 and E3d5c3d2c 10/10, the current implementation has **44/44 automated UI checks passed**.

The remaining manual acceptance is a direct physical mouse-click close/reopen verification in the running game window. Automated `pressed.emit()` tests prove signal handling but are not proof of human mouse interaction. Thus the regular Factory Testing Sandbox gate remains **OFF by default**. This is an evidence/documentation-only update; no source, construction, inventory, combat or scene files were modified.

After confirmation, the next small checkpoint is a read-only UI default-on switch in Factory Testing Sandbox with F6/manual smoke tests, preserving its debug construction override and all existing gameplay input.

### 2026-11-11 — E3d5c3d2d Default-On Sandbox Requirements Button Staged

The developer's new standalone screenshot displays the **closed** Construction Requirements panel and its visible button, confirming physical mouse-close behavior in addition to previously accepted 44/44 UI F6 checks. Reopening by physical mouse click is not explicitly shown and remains part of the next manual smoke test.

**Focused implementation:** Changed `scenes/core/factory_testing_sandbox.tscn` so its `ConstructionRequirementsFeatureGate` opts into the existing read-only panel **by default**. The component script's exported default is still OFF for any other host. The UI itself begins **closed** to avoid clutter until the player clicks. Main gameplay is not given this UI; no other existing game control or service was changed. Existing F6 E3d5c3d2b and E3d5c3d2c scenes were updated solely to expect intentional default-on sandbox behavior, without dropping their acceptance assertions.

Staged `res://tests/sandbox_requirements_default_on_e3d5c3d2d_test.tscn` with **12 A–L scripted checks**, pending local Godot F6. It validates a real unmodified sandbox instance, initial closed state, single button, no overlap, materials-only observation, unknown services, unchanged debug construction flags and no unintended game-side effects. Follow with E3d5c3d2b 16 and E3d5c3d2c 10 regressions plus the manual F6 sandbox mouse/blueprint/conveyor smoke test.

**No real construction readiness enabled:** materials/power/workers are not wired; the panel continues to report UNKNOWN and `Live readiness: NOT VERIFIED`, and the sandbox's existing debug-gate bypass is unchanged.

### 2026-11-11 — E3d5c3d2d Default-On Sandbox Requirements F6 12/12 Passed

Developer's F6 Output screenshot confirms PASS A–L and `ALL 12 E3D5C3D2D DEFAULT-ON SANDBOX REQUIREMENTS TESTS PASSED`, with no visible errors. In the paired running-window screenshot, the Factory Blueprints HUD shows one selected High-priority planned blueprint, the read-only Construction Requirements panel shows Test Storage, priority High, progress 0%, and Test Ingot x3, while stock, escrow, power and workers remain explicitly UNKNOWN. Production Debug and Factory Blueprints are not visually obscured.

The additional `Hit nothing` line matches the existing empty raycast selection diagnostic and is not an assertion failure. The screenshot shows the panel open, not a complete physical open/close/reopen sequence; manual sandbox UI and conveyor smoke checks remain to be confirmed.

**Next acceptance gate:** Re-run the updated E3d5c3d2b (16) and E3d5c3d2c (10) scenes after enabling the sandbox button by default. No source code changes in this documentation-only acceptance record. The normal sandbox retains debug construction, while this panel remains read-only and without real supply-provider connections.

### 2026-11-11 — E3d5c3d2d Post-Enable Sandbox UI Compatibility Passed 16/16

Four developer screenshots show the updated E3d5c3d2b Godot 4.6.2 Output reporting `ALL 16 E3D5C3D2B SANDBOX READ-ONLY REQUIREMENTS UI TESTS PASSED` (PASS A–P), with no visible assertion failures. The accompanying sandbox windows show a queued High-priority Test Storage blueprint, the Construction Requirements panel docked below Production Debug, and Factory Blueprints unobstructed. All resource, worker and power sources remain UNKNOWN, correctly indicating no live services were attached.

The screenshots duplicate the **E3d5c3d2b** test, not the required **E3d5c3d2c HUD dock 10-check regression**. With the preceding E3d5c3d2d 12/12, the current default-on checkpoint stands at **28/38** tests verified.

Remaining: run the E3d5c3d2c 10-check F6 suite and verify physical open/close/reopen plus blueprint and conveyor smoke in a normal Factory Testing Sandbox session. No code was altered for this documentation entry. The UI remains strictly observational, and `main.tscn` remains unaffected.

### 2026-11-11 — E3d5c3d2d Full Automated Suite Accepted 38/38

Developer's newest Godot 4.6.2 screenshot shows the post-enable E3d5c3d2c HUD docking suite passing all 10 A–J checks with `ALL 10 E3D5C3D2C SANDBOX REQUIREMENTS HUD DOCK TESTS PASSED`, and no visible errors. This completes the default-on requirements UI's updated automated checks: E3d5c3d2d **12/12**, E3d5c3d2b **16/16** and E3d5c3d2c **10/10**, totaling **38/38**.

The HUD docking test confirms no overlap, responsive adaptive repositioning, intact sandbox debug gates and read-only reporting. The screenshot's `MANUAL:` lines are instructions and do not prove that physical mouse toggle or conveyor/build placement were exercised in the **regular sandbox**. Complete the manual OPEN/CLOSE/REOPEN, blueprint select/deselect and short conveyor smoke before declaring the entire default-on UI milestone fully accepted.

No gameplay source changed in this documentation-only entry. `main.tscn` is unchanged. Future E3d5c3e1 will add clickable High/Normal/Low controls with existing priority logic, without granting real stock, power, worker slots or timer bypass.

### 2026-11-11 — Manual Sandbox Found Blueprint Click Gap; E3d5c3d2e Fix Staged

The developer supplied screenshots showing the actual default-on Construction Requirements button in both closed and open states and an existing blueprint in the sandbox, then reported **not being able to click the blueprint**. This blocks final manual acceptance of E3d5c3d2d, despite its successful 38/38 automated regression checks.

Reviewed WorldInteraction: Q+drag owns area selection and adds sites to `blueprint_area_selected`, whereas ordinary left-click while Blueprint Mode is active attempts new placement. The new read-only panel only follows the Q-selection group. Therefore a bare click on a preexisting blueprint did not select an inspection target. ConstructionSite already has a real reserved-footprint StaticBody3D on selection layer 2, so the fix reuses its authoritative hitbox rather than adding a new collision or bypass.

**E3d5c3d2e staged:** WorldInteraction emits a sandbox-gated `blueprint_inspection_requested(site)` for a plain primary click on a valid existing managed site in Blueprint Mode (and in neutral normal selection mode). The existing requirements gate listens and opens the informational panel on that target. Q-area selection and Shift route inputs retain their earlier priority; normal empty-space clicks keep placement behavior. The gate clears pinned inspection when Q area-selection begins, allowing multi-selection to drive the panel. It never edits ConstructionJob, escrow, power, workers or timers, and Main remains opted out.

New `res://tests/blueprint_click_inspection_e3d5c3d2e_test.tscn` contains **16 A–P F6 tests** including physical raycast and input event, staged for developer validation. After acceptance, repeat area/placement and relevant UI regressions; do not claim current gameplay fixed before Godot F6 and manual test.

### 2026-11-11 — E3d5c3d2e Click-to-Inspect F6: All 16/16 Passed

Developer supplied Godot 4.6.2 Output showing PASS A–P and `ALL 16 E3D5C3D2E DIRECT BLUEPRINT CLICK INSPECTION TESTS PASSED`, without visible failed assertions. The sequence exercised the real CollisionShape3D raycast path, primary input dispatch, read-only site inspection, Q-area selection separation, unchanged job material/power/worker wait reasons, and Main-scene opt-out. A paired game-window screenshot shows a valid planned Test Storage in the requirements panel while Factory Blueprints has Selected: 0; this is expected because single-click inspection is separate from the Q+drag authorization group.

The Output additionally shows `Footprint blocked or preview invalid` and `Hit nothing` after the automated test. These are not F6 check failures; if they occur during otherwise valid normal sandbox placement or clicking, gather a reproducible sequence before treating them as harmless.

**Acceptance limitation:** The new screenshots are from the isolated F6 test; they do not conclusively demonstrate physical click inspection in a normal Factory Testing Sandbox session. Next: manually click an existing planned blueprint in normal sandbox, verify Q+drag and conveyor placement, then rerun targeted UI and E3d4 area selection regressions. No game code changed in this documentation-only evidence update.

### 2026-11-11 — Normal Sandbox Click/Area Selection and Conveyor Smoke Accepted

Five user screenshots from normal Factory Testing Sandbox demonstrate the full manual interaction loop: direct Storage inspection (requirements show Test Storage, 3 ingots and zero progress without Q selection), separate Q+Drag selection with a green outline and Selected: 1, a conveyor blueprint's 1-ingot bill, a complete multi-corner directed conveyor route, and a 22-blueprint selection spanning High 7 / Normal 7 / Low 8. The debug HUD and Production Debug remain unobstructed, and the requirements report UNKNOWN stock/power/worker services rather than counterfeit readiness. This validates E3d5c3d2d and E3d5c3d2e manual acceptance following previously accepted dedicated automated tests (38/38 default-on UI, 16/16 click-inspection).

**Targeted regression backlog remains:** E3d4a/b Q rectangle/Shift/Alt selection and E3d5c3d2b/c/d post-click UI suites. Manual visual evidence is not a substitute for these specific regression runs.

### 2026-11-11 — E3d5c3e1a Standalone Priority Buttons Staged

Implemented an **isolated** `BlueprintConstructionPriorityButtons` HBoxContainer with mouse-clickable High/Normal/Low controls. The component is disabled until an external controller declares a qualifying selection; it emits a typed `priority_requested` signal but never writes construction jobs or queue state. The existing WorldInteraction Q-selection command already gates priority updates to eligible PLANNED sites; only a future integration checkpoint will connect the signal to that validated command. This first step cannot accidentally authorize work, consume escrow, allocate power/workers, or override timers.

Staged `res://tests/construction_priority_buttons_e3d5c3e1a_test.tscn` with **12 F6 A–L** checks and a manual button-click test. Godot F6 and mouse tests remain pending. Factory Testing Sandbox and Main scenes are unchanged. Before connecting the module to gameplay, run the queued E3d4a/b and E3d5c3d2b/c/d regressions.

### 2026-11-11 — E3d5c3e1b Compact Vertical Priority Stack Staged

User supplied an annotated screenshot of the bottom-center nine-slot build hotbar and requested **three tiny L, N, H buttons stacked vertically immediately to its left** rather than three wide horizontal labels. Intended use: choose the priority of Q+drag-selected planned blueprints without relying solely on keyboard shortcuts.

Implementation stages a 48 px wide / approximately 94 px high VBox button group in the prior priority-signal component with L/N/H labels and descriptive tooltips. New sandbox-only `SandboxConstructionPriorityDock` owns dynamic placement relative to `BuildHUD/VisualHotbar`; it appears only in Blueprint Mode and remains disabled unless Q area-selection contains at least one selected PLANNED site. A button request is forwarded through the **existing** guarded `WorldInteraction._set_selected_blueprint_priority()` command, not direct job modification. Main, standard BuildHUD scene, inventory, conveyors, power, combat, worker scheduling, and construction timers are untouched.

The earlier E3d5c3e1a standalone test fixture was updated (same 12 A–L cases) for the new compact button geometry. Added E3d5c3e1b isolated F6 fixture (16 A–P) using the actual Factory Testing Sandbox scene. These have been staged in GitHub but **have not been run in developer Godot**. Next: run the 16-check docking/priority test and 12-check standalone button test, inspect physical mouse clicks, then complete the pending selection/UI compatibility regression batch before starting construction authorization UI.

### 2026-11-11 — E3d5c3e1b F6 Test M Physical-Key Fixture Correction

Developer F6 screenshot reached Test M after the compact priority button checks, then failed at the assertion expecting the selected blueprint to become High priority following a simulated H press. Inspection of `WorldInteraction._unhandled_input()` confirmed that gameplay intentionally reads `InputEventKey.physical_keycode`, but this test created an event containing only `keycode`. Updated Test M to populate **both** properties and exercise physical H, N, L, and H again; verifies the unselected blueprint stays Normal, the selected plan remains PLANNED, and the final selected priority is High. No gameplay scripts or sandbox UI were changed. **The corrected 16-check F6 fixture and 12-check standalone priority-buttons fixture still require developer Godot execution; no pass is claimed yet.**

### 2026-11-11 — E3d5c3e1b 16/16 F6 Passed, Dock Placement Visually Confirmed

Developer supplied Godot F6 Output screenshot reporting **`ALL 16 E3D5C3E1B VERTICAL SANDBOX PRIORITY DOCK TESTS PASSED`**. This includes selection gating, L/N/H signal routing and priority changes, unaffected unselected sites, restored physical H/N/L keyboard alternatives, inspection isolation, and no construction authorization/timer advance. A separate in-game screenshot shows the compact L/N/H stack immediately left of the nine-slot hotbar in Blueprint Mode, correctly **disabled** because Factory Blueprints reports **Q Area Select** with **Selected: 0** (2 total planned blueprints). Requirements inspection remains open and read-only; stock/power/workers remain UNKNOWN and live readiness NOT VERIFIED. **Still pending:** F6 standalone `construction_priority_buttons_e3d5c3e1a_test.tscn` (12 cases), actual mouse-click L/N/H interactions on a selected Q+drag group in regular sandbox, and targeted E3d4a/b and E3d5c3d2b/c/d regressions. No gameplay or UI code changed for this evidence checkpoint.

### 2026-11-11 — Compact Priority Dock Manual Interaction Accepted

Developer reported that all requested manual checks passed and supplied an in-game Q-selection screenshot plus Godot Output. Output confirms priority changes **High → Normal → Low** applied to one selected planned job, leaving Q mode, returning to blueprint mode, and successfully selecting two planned sites. Final HUD shows **Planned 2, Selected 2, H 0 / N 1 / L 1**, with green selection outlines on both sites; Construction Requirements remains read-only and shows a PLANNED site at 0% progress, UNKNOWN materials/power/workers, and live readiness NOT VERIFIED. The earlier 16/16 vertical dock test is already accepted. Reported manual L/N/H button interaction is accepted on developer confirmation; the isolated 12-case E3d5c3e1a fixture is **not separately evidenced by these screenshots** and remains pending. Next: F6 the isolated 12-case UI fixture, then the targeted E3d4a/b and E3d5c3d2b/c/d regression suite before construction authorization UI integration. No gameplay code changes in this checkpoint.

### 2026-11-11 — Blueprint Selection and Read-only UI Regression Batch Accepted (73/73)

Developer submitted seven Godot 4.6.2 screenshots verifying all **six** previously pending F6 suites: E3d5c3e1a isolated compact L/N/H priority controls **12/12**, E3d4a area-selection **10/10**, E3d4b Shift/Alt area-selection **13/13**, E3d5c3d2b sandbox read-only Construction Requirements **16/16**, E3d5c3d2c adaptive requirements dock **10/10**, and E3d5c3d2d default-on requirements **12/12**. **Total 73/73 checks passed.** Together with the separately verified E3d5c3e1b vertical priority dock **16/16**, this checkpoint confirms **89/89 checks** across seven suites. Existing user screenshots also confirm actual sandbox L/N/H priority changes, Q+drag, no unauthorized timer advancement, and correctly separate inspection/selection. Test log warnings about the test extractor's missing resource node are nonfatal; suites completed. No production code was modified during this acceptance.

**Milestone status:** Sandbox priority dock, Q area-selection, and default-on read-only requirements UI are accepted. The testing sandbox still has an explicit debug requirements bypass; production Main does not. Material stock, delivered power and workers are **not** real connected readiness providers, and Live readiness must continue to say NOT VERIFIED. Next implementation work must be staged and isolated: define a user-facing explicit authorization workflow that respects PLANNED vs QUEUED state, no silent construction on priority change, and no real dispatch until actual materials escrow, delivered power and finite workers are integrated.

### 2026-11-11 — E3d5c4a Explicit Sandbox Blueprint Authorization UI Staged

Following the verified **89/89** selection, requirements and L/N/H priority milestone, added a separate signal-only blueprint authorization view and sandbox-specific CanvasLayer. The view appears above the bottom hotbar only during Blueprint Mode, with live **Authorize Selected (N)** and **Authorize All (N)** buttons. Selected is disabled until Q+drag has one or more managed PLANNED sites; All is disabled when none remain. The L/N/H stack retains its left-of-hotbar placement and still changes only priority.

The authorization adapter calls the existing guarded E/Ctrl+E WorldInteraction commands rather than authorizing jobs or changing readiness itself. To reduce accidental world-wide construction, the All button requires an explicit second click to **Confirm All**, and its confirmation resets when the eligible candidate identities change or the mode closes. The keyboard E and Ctrl+E paths are not changed. The sandbox's existing debug requirements override remains untouched; it is neither genuine resource delivery nor production readiness. The isolated material-escrow/power/worker coordinator is *not* connected to the playable game, Main is unchanged, and unverified services remain UNKNOWN.

Added `res://tests/sandbox_blueprint_authorization_test.tscn` with **18 A–R checks**. Its primary fail-closed proof turns OFF debug readiness, then asserts explicit authorization produces QUEUED jobs awaiting power, materials and workers with 0% progress. Also exercises count/selection validation, priority/inspection separation, two-step All confirmation and invalidation, and existing physical-key E/Ctrl+E routes. **Developer Godot 4.6.2 F6 execution and real mouse verification are pending; no new pass claimed.** The accepted 89/89 baseline is preserved. Follow with E3d5c3e1b 16-check, E3d4b 13-check and E3d1 7-check regressions before planning real readiness providers.

### 2026-11-11 — E3d5c4a Authorization Automated Checks Passed (18/18)

Developer provided Godot 4.6.2 screenshots from the new authorization acceptance scene. Output reports **PASS A–R** and **ALL 18 SANDBOX BLUEPRINT AUTHORIZATION TESTS PASSED**, including Selected-only actions, two-click All confirmation/candidate change invalidation, L/N/H priority nonauthorization, direct-click inspection independence, and physical E / Ctrl+E fallbacks. The simulated debug-bypass-OFF session ends at **six QUEUED construction jobs**, none building, and zero work progress. The right-side requirements panel still reports missing live inventory/escrow/power/worker providers as **UNKNOWN** and Live readiness as **NOT VERIFIED**. This is the intended secure distinction between permission to build and permission to dispatch.

The `Placement blocked` line was printed after the test's PASS summary; it did not fail any assertion, and its reproducibility in normal gameplay is not yet established. Automated acceptance is complete **18/18**; hands-on Authorize Selected / Authorize All clicks in regular sandbox and the targeted 16+13+7 = **36** existing regression checks remain pending. No production code was changed for this acceptance record; the previous **89/89** suites remain accepted historical evidence rather than new reruns.

### 2026-11-11 — E3d5c4a Targeted Authorization Regressions Passed (36/36)

Developer provided three additional Godot 4.6.2 Output screenshots after the new sandbox blueprint authorization controls were committed. **E3d5c3e1b** vertical L/N/H priority dock passed **16/16**, **E3d4b** Q+drag advanced selection (including Shift-add and Alt-subtract) passed **13/13**, and **E3d1** Ctrl+E batch authorization passed **7/7**. Total **36/36 post-change regression assertions passed** across three standalone F6 scenes. Together with the new E3d5c4a **18/18** acceptance scene, this provides **54/54 passing tests across four F6 runs**. All success counts are screenshot-evidenced, not independently executed by the GitHub connector.

Prior authorization/priority boundaries remain intact: L/N/H never starts jobs, E authorizes only selected PLANNED sites, Ctrl+E authorizes remaining plans, and removing the sandbox debug requirements override keeps unauthorized-readiness jobs QUEUED without skipping construction time. Historical 89/89 UI acceptance remains recorded separately and includes overlap with these regressions; it is not counted again as additional new checks.

**Outstanding:** physical mouse verification of Authorize Selected and Authorize All / Confirm All in a *regular* Factory Testing Sandbox session, plus conveyor placement/turn/delete smoke. Do not integrate prototype nameplate power, isolated escrow/worker coordinator or unknown requirements into production dispatch until genuine delivered resource/power and worker capacity and recovery/save-load requirements have been validated. No gameplay scripts were modified for this evidence update.

### 2026-11-11 — E3d5c4a Player-Facing Authorization Milestone Accepted

Developer reports the final normal-sandbox manual tests all passed, following **18/18** dedicated automated F6 acceptance and **36/36** post-change regression checks. The screenshot visibly confirms Blueprint Mode, a four-site Q+drag selection with green outlines, H1/N2/L1 priorities, the working vertical L/N/H dock, and active **Authorize Selected (4)** and **Authorize All (4)** controls above the unchanged nine-slot hotbar. User-reported testing covers selected-only authorization, two-click All confirmation, construction timers and conveyor placement/turn behavior. The screenshot itself is the pre-authorization selection state, so it does not independently show the jobs after clicking.

**Milestone accepted for Factory Testing Sandbox**, with no real construction readiness claims. Main remains opted out; normal sandbox can still intentionally debug-bypass materials, power and worker requirements. Real delivered cargo/material escrow and recovery, delivered electrical capacity, finite worker/drone assignments, and save/load persistence are unverified. The next checkpoint must be separately staged and tested with fail-closed admission before any production integration.

### 2026-11-11 — E3d5c4b Fail-Closed Authorization-to-Readiness Admission Staged

After E3d5c4a sandbox authorization acceptance, added the **separate, disabled-by-default** `scripts/components/blueprint_construction_readiness_admission.gd`. It explicitly admits only WorldInteraction-managed, authorized QUEUED sites into the already existing isolated readiness coordinator, and only when all power/material/worker requirements remain unsatisfied and the sandbox's debug bypass is OFF. PLANNED sites and priority changes are never treated as authorization. No UI changes, automatic scans, job-time advances, stock creation, power permission, worker capacity, scene wiring or Main modifications were introduced.

Staged **16 A–P isolated checks** in `res://tests/blueprint_readiness_admission_e3d5c4b_test.tscn`: feature opt-out, planned/priority isolation, selected E and All authorization paths, invalid demand and repeat admission refusal, test-only coordinator configuration, no-stock QUEUED behavior, and exactly one High-priority ingot escrow without generated power or workers. **F6 verification pending**. Real construction material delivery, delivered electricity, worker drones, cancellation/recovery and persistence remain unverified; production dispatch cannot use this test adapter.

### 2026-11-11 — E3d5c4b Readiness Admission Accepted (16/16)

Developer F6 screenshot confirms **all 16** E3d5c4b checks passed in Godot 4.6.2: test-only opt-in, prior explicit authorization required, PLANNED and priority-only sites refused, bounded positive demands, duplicate admission protection and debug override isolation. In the fixture, direct test inventory escrow backs the High-priority job but no generator/worker permits dispatch or timer advancement. The production Main and regular sandbox remain unconnected to the admission adapter; live readiness is **NOT VERIFIED**.

Next isolate a capacity-bounded construction material staging inventory and exercise inventory-to-inventory transfer plus escrow conservation/recovery without claiming a real conveyor-to-construction link. Metered power, physical worker drones, and save/load are later gates.

### 2026-11-11 — E3d5c4c Isolated Construction Material Transfer Staged

Following the screenshot-confirmed 16/16 E3d5c4b readiness admission acceptance, implemented `BlueprintConstructionMaterialStaging` as a **test-only disabled-by-default** material receiver with an owned bounded inventory. It cannot invent stock, automatically advance jobs or supply power/worker permission. It accepts construction-cost item types via `InventoryComponent.transfer_to()` from a controlled, live source inventory, and the isolated coordinator can escrow only that genuinely transferred buffered stock.

Added `res://tests/blueprint_material_staging_e3d5c4c_test.tscn` with **16 F6 assertions staged, not yet executed in developer Godot**. The test starts with five ingots, delivers them in partial batches, reserves one three-ingot bill for an authorized High job, proves a second job cannot claim insufficient remaining stock, and verifies refund-full handling and alternate recovery without loss/duplication before the second job obtains its bill. A missing generator keeps both jobs QUEUED with no construction time advanced. Main, the normal sandbox, WorldInteraction, conveyor logistics and combat remain unchanged.

**Important:** this is an inventory-conservation prototype and does not validate a physical belt delivery route, delivered electrical energy, real worker drones, or persistence. Those must remain fail-closed requirements before non-debug game integration.

### 2026-11-11 — E3d5c4c Godot Staging/Recovery 16/16 Accepted

Developer screenshot confirms `ALL 16 E3D5C4C MATERIAL STAGING AND RECOVERY TESTS PASSED`. Inventory source and staging buffer conserved all five Test Ingots through partial transfers, priority-based one-bill escrow, blocked full-buffer refund, explicit alternative recovery and subsequent next-job reservation. Missing electrical generation and workers kept construction jobs QUEUED. These are isolated test results, not playable cargo routing.

**E3d5c4c accepted** as a bounded inventory-staging foundation. Next step is an isolated physical conveyor-to-staging input-port F6 fixture with reciprocal endpoint and travel-time validation, while keeping Main/sandbox behavior unchanged and real readiness NOT VERIFIED.

### 2026-11-11 — E3d5c4d Isolated Physical Construction Staging Input Staged

After accepting E3d5c4c **16/16**, added a fail-closed, test-only physical `BlueprintConstructionStagingInputPort` extending the existing `ItemPortComponent`. It is disabled by default and binds explicitly to the exact buffer owned by `BlueprintConstructionMaterialStaging`. The input gate refuses unsupported construction materials and invalid/disabled/full buffers; all physical connection, direction, endpoint and cargo-time checks remain owned by the established conveyor system.

Staged `res://tests/blueprint_physical_staging_e3d5c4d_test.tscn` with **16 checks awaiting local Godot F6**. The fixture creates a synthetic inventory-owning output port, an actual conveyor segment with timer and reciprocal source/destination port connections, and a bill-filtered staging input. It exercises rejected ore, one-second belt travel, capacity backpressure, realignment, escrow of three physically transported ingots and conservation of all four ingots while a job remains QUEUED without power or workers. This is an isolated single-belt mechanism test, **not** a complete live factory supply route or a production readiness integration. No playable scene, WorldInteraction, UI, combat or construction timing code was edited.

### 2026-11-11 — E3d5c4d Physical Conveyor Construction Input 16/16 Accepted

The developer provided a Godot 4.6.2 Output screenshot verifying all **16** E3d5c4d assertions passed. The existing conveyor timer and reciprocal-port geometry physically transferred ingots into the isolated construction-staging input; rejected ore, full-buffer backpressure, subsequent successful transfer and escrow conservation all passed. The construction job remained QUEUED, so neither material ownership nor a priority change silently granted power or worker readiness.

Milestone accepted as a **single-connected-belt mechanism test**, not as a full manufacturing chain or player-placed buildable receiver. The next targeted isolated fixture will use real Smelter recipe production and multiple conveyors to prove end-to-end provenance; Main and playable sandbox remain untouched.

### 2026-11-11 — E3d5c4e Real Smelter-to-Construction Logistics Fixture Staged

The accepted E3d5c4d **16/16** conveyor-port tests established timed physical movement to staging from fixture-supplied ingots. Next, staged `tests/blueprint_factory_construction_chain_e3d5c4e_test.tscn` with **16 Godot checks, pending local F6**. This new test builds a real TestStorage-to-TestSmelter conveyor connection and a two-belt finished-product line from the real Smelter output port to the existing isolated construction staging input. Eight seeded units of Test Ore must be consumed by four real two-ore/one-ingot smelting cycles, producing exactly four ingots. Three are reserved into escrow for an explicitly authorized ConstructionSite; the fourth is held during full-buffer backpressure and later delivered. Construction must remain QUEUED due to no generator/workers. It also exercises misaligned endpoint rejection and cancellation refund recovery to the original Storage when staging has no room for the three-unit refund.

**The fixture has not been executed in Godot and no new pass is claimed.** This is a real Smelter recipe and multi-belt test, not a real mined-ore supply chain or player-built staging receiver. There were no edits to Main, Factory Testing Sandbox, the existing WorldInteraction, or live readiness. Actual power delivery, workers, destruction recovery, and save/load remain out of scope.

### 2026-11-11 — E3d5c4e F6 PASS M Assertion Corrected

The developer's initial Godot F6 run stopped at the `assert(site.job.get_wait_reasons().size() == 3)` immediately after material escrow. Code inspection confirmed a **test expectation error**, not an authority bypass: the existing coordinator calls the bounded scheduler to mirror true escrow ownership as `materials=true`, while `power=false` and `workers=false` keep construction QUEUED. Replaced the check with explicit two-reason assertions requiring `power` and `workers` and rejecting `materials`, while preserving zero active workers and zero job progress. No runtime scripts/scenes were edited. **Corrected fixture pending F6 rerun; no 16/16 acceptance yet.**

### 2026-11-11 — E3d5c4e Real Smelter-to-Construction Chain Accepted 16/16

The developer's rerun screenshot confirms all **16** E3d5c4e test assertions passed after a test-only PASS M correction. Actual TestSmelter recipe processing turned eight seeded Test Ore into four Test Ingots, moved them through physically connected input/output belts into the bill-filtered staging inventory, escrowed the full three-ingot material bill, paused on missing power/worker services and recovered cancellation stock. No runtime construction, inventory or conveyor code changed for the assertion fix. Live electrical delivery, workers, save/load and true extractor/resource-node provenance remain unverified; E3d5c4e is accepted as an isolated multi-belt logistics fixture.

### 2026-11-11 — E3d5c4f Finite Extractor-to-Storage F6 Fixture Staged

After the developer's screenshot-confirmed **16/16** acceptance of E3d5c4e (real Smelter recipe to construction staging), staged the next *separate* source-provenance verification scene: `tests/blueprint_extraction_storage_e3d5c4f_test.tscn`. It uses the unchanged real finite TestOreDeposit, actual TestExtractor resource-overlap scanning/mining, physically connected single belt and a real TestStorage with a three-unit inventory limit. **No ore is manually added to inventory.** The test must mine four units from 500, allow three to arrive normally, hold the fourth on the belt under backpressure, reject disconnected unloading, then recover by freeing capacity and reattaching a reciprocal port. Total ore held in the deposit and all inventories must remain 500. **12 A–L F6 checks staged; no local Godot pass yet.**

Only the isolated test script/scene and documentation were added. Main, sandbox, WorldInteraction, combat, blueprints and live construction readiness were not changed. This is a prerequisite to a future combined extractor→smelter→construction chain, and not verification of real electrical power, workers or persistence.

### 2026-11-11 — E3d5c4f Finite Extractor to Storage Passed 12/12

Developer Godot 4.6.2 screenshot confirms all **12 A–L** checks in `blueprint_extraction_storage_e3d5c4f_test.tscn`: physics discovery of finite Test Ore Deposit, actual timed mining rather than inventory injection, reciprocal Extractor→conveyor→Storage ports, cargo travel, full Storage backpressure, disconnection and recovered delivery. Four mined ore were accounted for across the deposit ledger (500→496) and real inventories with no duplication. Milestone **accepted in isolated F6**. The construction readiness coordinator remains disconnected from production; upcoming work is a separate combined mining-to-construction material chain.

### 2026-11-11 — E3d5c4g Combined Mining-to-Construction Factory Test Staged

After E3d5c4f passed **12/12** and E3d5c4e passed **16/16** in separate developer F6 runs, staged the first **combined** `blueprint_mined_ore_construction_chain_e3d5c4g_test.tscn` (18 A–R checks, local Godot F6 **pending**). The fixture adds a real TestExtractor and finite TestOreDeposit physics detection to the existing Storage → Smelter → construction-staging test, connecting an independent real mining belt to Storage's other physical port. Eight ore must be genuinely mined from a 500-unit deposit, carried to Storage, carried to real Smelter, converted through four 2-ore→1-ingot timed cycles, and shipped on two connected product conveyors to bounded construction staging. Three ingots must escrow for an explicitly authorized job, while the fourth tests capacity/misalignment backpressure. Missing power and workers must keep the job QUEUED at zero progress. Cancellation requires alternative Storage refund because the staging buffer already contains a fourth ingot. Ore-equivalent conservation must hold before and after refund (492 remaining + 4×2 ore-equivalent = 500).

Only test script/scene and project docs changed. Main, regular Factory Testing Sandbox, existing WorldInteraction, power, worker, logistics components, hotbar and combat were not modified. This staged integration test does not establish production live construction readiness or full worker/persistence integration.

### 2026-11-11 — E3d5c4g Full Mined-Ore to Construction Materials Chain 18/18 Accepted

Godot 4.6.2 screenshot shows **PASS A–R** and `ALL 18 E3D5C4G MINED-ORE FACTORY-TO-CONSTRUCTION TESTS PASSED`. The original 500 finite ore ledger produced eight genuinely extracted units, converted to four ingots by the existing real smelting recipe and passed through connected timed belts into staging and exactly one construction escrow. Backpressure, source geometry, two-belt transfer, inventory provenance, cancellation refund and conserved ore-equivalents passed. The authorized construction job never advanced because live power and workers were missing. **F6 acceptance is complete for this isolated chain only.** Player-buildable receiving ports, per-site resource ownership, actual delivered energy, worker drones, demolition/save-load recovery are still unverified.

### 2026-11-11 — E3d5c4h Per-Site Staging Ownership Staged (F6 Pending)

After developer-verified **18/18** E3d5c4g finite mining-to-construction tests, staged a test-only, disabled-by-default `BlueprintConstructionSiteStagingRegistry`. The registry checks that an explicitly authorized QUEUED ConstructionSite owns an exact material-bill staging buffer and matching bound receiver input port, and refuses duplicate claims, another site's claim, mismatched bills, disabled features and priority-only plans. `reserve_for_site()` resolves the owner's own inventory and bill and calls existing atomic material escrow, never granting readiness/power/workers or advancing timers. Claims are intentionally kept locked after cancellation until a future explicit recovery/reassignment policy is established.

Added two small **read-only** identity helpers to existing isolated staging/input port scripts and a **16 A–P** two-site F6 fixture `res://tests/blueprint_site_staging_ownership_e3d5c4h_test.tscn`. Test-supplied ingots (6 for A, 3 for B) verify independent reservations, partial-stock refusal, double-spend protection, cancelled A's full-buffer recovery to alternate stock and exact total nine-item conservation. This does not replay the physically mined route proven in E3d5c4g; it tests ownership separately. **Godot F6 pending**, no new test pass claimed. Existing Main and Factory Testing Sandbox scenes, WorldInteraction, conveyor transport, timers and construction-readiness coordinator have not been modified. Real worker drones, electrical power, destruction/cancel persistence and player-buildable construction receivers remain future gates.

### 2026-11-11 — E3d5c4i Site-Aligned Physical Construction Receiver Staged

Following developer-verified **16/16 E3d5c4h per-site ownership**, staged `BlueprintConstructionAnchoredStagingPort` as a separate test-only, default-disabled bill-filtered port aligned to the planned InputPort geometry of an actual authorized ConstructionSite. Crucially, it does **not** parent any inventory/port under the site: cancellation queues the site for deletion, so outstanding buffered items and escrow must stay recoverable. The new subclass requires the unique per-site registry claim and refuses input when the plan moves, the job is cancelled/deleted, the receiver is disabled, or its buffer identity breaks. No staging source, construction authority, power/worker provider, or timer permission is invented. Main and Factory Testing Sandbox remain untouched.

Added `res://tests/blueprint_anchored_receiver_e3d5c4i_test.tscn` with **16 checks awaiting Godot F6**: actual planned marker versus separate physical port, strict authorization/ownership, isolated source belt connection, one wrong-item rejection/recovery, correct one-second ingot movement, complete atomic three-ingot escrow, stale geometry blocking and resume, full-buffer backpressure, cancellation cutoff, seven-ingot accounting and alternate escrow recovery. This is a narrowly scoped receiver lifecycle proof, **not a player-placeable asset, real mined factory supply, delivered power, physical worker or save/load acceptance.** The full ore→factory route was already accepted separately in E3d5c4g.

### 2026-11-11 — E3d5c4i Anchored Site Receiver F6 Accepted 16/16

Developer Godot 4.6.2 screenshot shows PASS A–P and `ALL 16 E3D5C4I ANCHORED CONSTRUCTION RECEIVER TESTS PASSED`. Actual planned-port site geometry, separate physically connected staging intake, job authorization, ownership lockout, timed ingot delivery, rejected ore, staging backpressure, moved-site rejection, cancel intake cutoff, alternate escrow refund and exact seven-ingot conservation passed. The fixture did not enable power/workers or construction time. Main and normal sandbox are unchanged.

The next isolated gate is recovery/decommission readiness: buffer items, in-flight belt cargo, cancelled-job escrow and stale ownership must not be accidentally deleted or reassigned. A read-only audit can identify when cleanup *might* become safe, but may not itself release claims or bypass save/load.

### 2026-11-11 — E3d5c4j Read-Only Construction Receiver Cleanup Audit Staged

Following screenshot-verified **16/16** E3d5c4i construction receiver acceptance, staged an isolated, disabled-by-default `BlueprintConstructionReceiverRecoveryAudit` and `blueprint_receiver_recovery_audit_e3d5c4j_test.tscn` (**12 A–L**, Godot F6 **pending**). Two read-only lifecycle/claim helpers preserve the exact existing source of truth: the anchored receiver latches when its original site ends, and the registry can recognize that its port/buffer claim remains locked after the site node is freed. The audit checks whether a captured site escrow, receiver staging buffer, physically connected belt and held cargo are outstanding; an unavailable or disabled service fails closed. Even if all measured resources are drained, the audit's `safe_to_release` remains false, and no owner may be reassigned automatically.

The fixture stages cancellation with seven test ingots split across an escrowed bill, full staging and one in-flight belt unit; it then recovers escrow into the supply inventory, disconnects the belt, explicitly transfers buffered and in-flight items back, and checks the claim remains locked after site deletion. **No Godot pass is claimed yet.** Existing Main/sandbox, WorldInteraction, production, conveyor/timer, escrow business logic and worker/power systems are unchanged. Future actual cleanup needs stable site identities, atomic rollback, checked cargo ownership and save/load; this diagnostic test is not itself permission to retire a receiver.

### 2026-11-12 — E3d5c4j Receiver Recovery Audit Accepted 12/12

Developer screenshot confirms **ALL 12 E3D5C4J RECEIVER RECOVERY AUDIT TESTS PASSED**. The independent receiver's audit blocked retirement while the belt was linked, staged stock remained, in-flight cargo was present or captured escrow was outstanding. The test then explicitly recovered all seven ingots, severed the belt link and observed a drained state after construction-site deletion. Crucially, the registry kept the old claim locked, and no automatic receiver reassignment/release was authorized. This is isolated acceptance, not evidence of actual save/load, full destruction cleanup, powered construction or worker drones. Next isolate an inert versioned recovery-record shape without adding release authority.

### 2026-11-12 — E3d5c4k Fail-Closed JSON Recovery Observation Staged

After developer-verified **12/12** E3d5c4j receiver recovery audit checks, added a disabled-by-default `BlueprintConstructionRecoveryObservation` module and isolated `blueprint_recovery_observation_e3d5c4k_test.tscn` (**18 A–R checks; Godot F6 pending**). The module converts a live, ownership-checked audit into a versioned primitive-only JSON observation with an external correlation label, material/cargo/escrow and connection state, blocker names, and invariant `safe_to_release=false`. It never writes to a save file, reconstructs a site, refunds escrow, releases a claim, changes authorization or advances construction. Malformed, version-incompatible or forged release records must fail validation; inactive audit/service sources must not yield fresh records.

The 18-check fixture extends the previously passing 12-check recovery lifecycle with label validation, live JSON round-trip, disabled-audit refusal, active/cancelled/drained state checks, forged data rejection and post-deletion claim isolation. This is **descriptive format research**, not implementation of stable site identity, inventory/escrow persistence, rollback or safe claim decommissioning. Main, regular Factory Testing Sandbox, production construction power and worker services remain unchanged. **No local Godot pass has been claimed for E3d5c4k.**

### 2026-11-12 — E3d5c4k Read-Only Recovery Observation Accepted (18/18)

Godot 4.6.2 F6 screenshot confirms **ALL 18 E3D5C4K RECOVERY OBSERVATION TESTS PASSED**. JSON recovery observations correctly round-trip, refuse invalid owner labels or disabled audit services, report active and cancelled cargo/escrow blockers, and reject forged release permissions even after all seven test ingots are recovered. The ownership claim stays locked. No live save/load, persisted site identities, worker dispatch, delivered electricity or claim release is established. Next isolated test will issue session-stable per-site IDs and retain tombstones after site deletion without adding any real recovery authority.

### 2026-11-12 — E3d5c4l Session Site Identity and Tombstones Staged (F6 Pending)

After screenshot-verified **18/18** E3d5c4k recovery-observation acceptance, staged a separate disabled-by-default `BlueprintConstructionSiteIdentityLedger` and `blueprint_session_site_identity_e3d5c4l_test.tscn` (16 A–P checks awaiting developer Godot F6). The ledger creates OS-random UUIDv4-style identifiers for real live PLANNED/QUEUED ConstructionSites, preserving the same ID through rename, movement, priority and explicit authorization while refusing to reuse old IDs for replacement sites. Cancellation and tree exit leave in-memory tombstones readable after the original site is freed. The descriptive record contains no job permission, inventory authority, or release grant.

These are **session-level identities only**; the existing E3d5c4k caller-provided label is not retroactively authenticated by this disconnected service. There is no import/save implementation or persisted escrow, receiver, belt cargo or site recovery. The new fixture has been committed but **not yet run locally**, and it does not alter Main, the normal sandbox, WorldInteraction or any production dispatch code. Next after acceptance: consider a test-only owner-ID-to-observation binding that checks actual identity while maintaining strict no-release/no-restore boundaries.

### 2026-11-12 — E3d5c4l Session Site Identity Accepted 16/16

Screenshot supplied from Godot 4.6.2 shows **ALL 16 E3D5C4L SESSION SITE IDENTITY TESTS PASSED**. Test cases covered format rejection, real PLANNED issuance, identity stability, same-name/position uniqueness, no priority-based authorization, explicit authorization independence, tombstone retention after cancellation/tree exit, inability to reuse IDs, opt-out and inert JSON observation. The identity ledger is still process-local and not a save-game service. The next isolated checkpoint will bind the real site identity to a verified receiver recovery audit, preserving the no-release and no-dispatch gates.

### 2026-11-12 — E3d5c4m Same-Site Session Identity/Recovery Binding Staged

After developer-confirmed **16/16** E3d5c4l site-identity tests, introduced an isolated same-site proof for the existing E3d5c4j audit and disabled-by-default `BlueprintConstructionRecoveryIdentityBinding`. This adapter joins a real E3d5c4l ledger-issued, non-recycled UUID to the **actual same** authorized QUEUED ConstructionSite's receiver/staging audit and a new E3d5c4k JSON observation, rejecting a second site's ID or a preconfigured caller-supplied owner label. It cannot issue IDs, authorize work, change priorities, reserve/recover inventory, allocate workers/power, write save files, reassign claims or release receivers. Once bound, it continues to compare live audit and session tombstone flags after cancellation/deletion; a drained observation still has no release authority.

Staged `tests/blueprint_recovery_identity_binding_e3d5c4m_test.tscn` with **16 A–P F6 checks pending developer Godot execution**: live site/registry/belt/escrow verification, mismatched site/label refusal, UUID-linked JSON, after-cancel/delete continuity, disabled gate refusal, explicit material refund and drained-with-claim-locked outcome. All changes are confined to isolated audit helper, new binding component, test script/scene and project documentation. Main and regular Factory Testing Sandbox remain unchanged. Genuine persistence, electricity and physical worker services remain separate milestones.

**Pre-F6 fixture correction:** Updated the E3d5c4m isolated test to use six ingots (three escrowed and three filling staging), ensuring cancellation leaves the escrow outstanding rather than automatically refunding into an empty buffer. The staged test then drains and recovers both material locations explicitly, preserving all six ingots. No gameplay code or scene changed; E3d5c4m remains unverified until local Godot F6.

### 2026-11-12 — E3d5c4m Recovery Identity Binding Accepted 16/16

Godot 4.6.2 Output screenshot confirms all **16 A–P** E3d5c4m checks passed, including exact ledger-to-site/audit UUID matching, refusal of unrelated and caller-provided labels, retained cancel/delete tombstone and recovery of all six test ingots. Jobs remain without production power/worker dispatch; drained receivers stay locked. This is isolated acceptance, not save/load or release authority.

### 2026-11-12 — E3d5c4n Quarantined Material Checkpoint Staged (F6 Pending)

Staged `BlueprintConstructionRecoveryCheckpoint` with a strict E3d5c4j audit exact-source proof. It captures one genuine E3d5c4m verified UUID-bound recovery observation alongside itemized staging inventory, held belt cargo and original escrow costs, refusing unrelated sources, inconsistent audited unit counts, forged release rights, duplicate item IDs or malformed JSON. This data-only module defaults OFF and has no save/load restoration, escrow, receiver release or construction-authority operation.

Added `tests/blueprint_recovery_checkpoint_e3d5c4n_test.tscn` with **20 A–T F6 checks awaiting local Godot execution**. Its test-only source has seven ingots (three reserved, three staged, one held in a real belt's cargo buffer), then explicitly recovers each item after site cancellation/deletion. The F6 fixture alone writes the quarantined snapshot to `user://industrial_warfare_e3d5c4n_test_only.json`, rereads/validates it and deletes it, without reloading any game state. Checks also reject tampered UUID, quantities, stale schema and release flags. No production scenes, existing authorization, factory logistics, power or worker systems were changed. A successful JSON disk round-trip would only establish basic format/file I/O, **not full-game crash-safe persistence**.

### 2026-11-13 — E3d5c4n Material Ownership Checkpoint Accepted 20/20

Developer screenshot from Godot 4.6.2 shows **ALL 20 E3D5C4N MATERIAL OWNERSHIP CHECKPOINT TESTS PASSED**. A versioned diagnostic record described seven ingots in verified escrow/staging/belt positions (3/3/1), survived test-only JSON write/read validation and refused inconsistent ownership/release data. Explicit recovery preserved all seven ingots; the original claim remained locked after site deletion. This remains a single-scene, data-only checkpoint demonstration, NOT saved gameplay. Next work will isolate a two-generation, checksum-checked file publication and corruption fallback for diagnostic inspection only.

### 2026-11-13 — E3d5c4o Two-Generation Quarantined File Experiment Staged

E3d5c4n was screenshot-verified at **20/20**; its quarantined checkpoint parsed actual live escrow/staging/cargo descriptions. Next, staged the disabled-by-default `BlueprintConstructionCheckpointFileQuarantine` and `blueprint_checkpoint_file_quarantine_e3d5c4o_test.tscn` (**12 A–L F6 checks pending**). Two fixed test-only user:// file names protect the prior slot from accidental overwrite. Each new file is written as a temporary `.part`, read/validated before being renamed into a previously absent slot; a later generation must identify the same site. Digest mismatch, malformed content, or an abandoned temp file refuses publication/inspection. A valid older record can be inspected after the newer file is corrupted, but is clearly labeled STALE and cannot grant world restoration or receiver release.

The test uses synthetic schema-valid records to isolate disk behavior, not a live factory capture. SHA-256 is not an authenticated signature or evidence of crash-safe durability. Main and Factory Testing Sandbox are untouched; save/load, atomic multi-object recovery, persistent IDs, workers, delivered electricity and production construction readiness remain future work. The new scene is committed but **not yet run in Godot**.

### 2026-11-13 — E3d5c4o Quarantined Checkpoint Files Passed 12/12

Developer screenshot confirms `ALL 12 E3D5C4O CHECKPOINT FILE QUARANTINE TESTS PASSED`. Test-only two-generation snapshots refuse overwrite and cross-site publication, detect corrupted newer SHA-256, show stale older data for inspection without restoration, reject malformed dual files and abandoned pending files, and clean up test outputs. Main and Factory Testing Sandbox remain unchanged; no true save/load or claim release is enabled. Next stage stricter history continuity verification from a fresh reader with orphan/mismatched generations and interrupted pending writes.

### 2026-11-13 — E3d5c4p Cold-Reader Checkpoint Lineage Staged (F6 Pending)

Following Godot screenshot-confirmed **12/12 E3d5c4o** acceptance, staged a narrow, isolated strengthening of the two-generation diagnostic file reader. `read_for_inspection()` now refuses to present a valid newer generation without a matching valid older parent: missing parent yields no record/`unverified_history_for_inspection`, cross-site mismatch yields no record/`owner_conflict_for_inspection`, and unfinished newer `.part` causes the older valid record to be labelled **stale** rather than clean. All decisions remain descriptive (`safe_to_release=false`, `can_restore=false`) and cannot create or restore a construction site, owner claim or material escrow.

Added `tests/blueprint_checkpoint_lineage_e3d5c4p_test.tscn` with **16 A–P checks pending local Godot F6**: existing 12 quarantine checks, fresh in-process reader, valid SHA-256 recomputed for the wrong owner's checkpoint, valid newer file without an earlier parent, and interrupted newer staged file. Production scenes, transport, combat, power, workers, escrow, hotbar and construction readiness remain untouched. This is **NOT** a real Godot process restart or world save/load. Unkeyed SHA-256 still cannot authenticate edited records.

### 2026-11-12 — E3d5c4p Cold-Reader Checkpoint Lineage Accepted (16/16)

Developer screenshot confirms **ALL 16 E3D5C4P COLD-READER LINEAGE TESTS PASSED**. Same-owner lineage passed under a fresh in-process reader; a rewritten new generation with a valid new hash but unrelated owner UUID was quarantined, as was an orphan newer record. An incomplete newer temp file made an older snapshot explicitly stale. The validated two-generation files remain isolated diagnostics; no world restoration, durable identity, construction dispatch, receiver release or crash-resilience claim is supported. Next stage a separate-process two-run inspection-only experiment.

### 2026-11-12 — E3d5c4q Two-Run Process-Boundary Checkpoint Test Staged

After screenshot-confirmed E3d5c4p **16/16**, staged two independent Godot F6 scenes: `blueprint_checkpoint_restart_writer_e3d5c4q_test.tscn` (Phase 1, 8 checks) and `blueprint_checkpoint_restart_reader_e3d5c4q_test.tscn` (Phase 2, 10 checks). The writer uses the accepted E3d5c4o two-slot test file quarantine and synthetic, schema-valid E3d5c4n material records. It validates and publishes two generations without overwriting pre-existing files, intentionally leaving them behind for a **full Godot editor shutdown/reopen**. The independent reader must then validate cross-process file continuity, same-owner lineage, exact seven-ingot distribution in the earlier record, drained newer inspection, immutable file bytes and no restore/release authority, before removing only the test files.

**Pending developer acceptance:** Phase 1 and Phase 2 have not yet been run locally. This is a normal restart file-I/O experiment rather than crash or power-loss durability, game state restoration, worker/drone dispatch, item provenance persistence or live receiver release. No existing production Godot scripts, Main scene, normal sandbox or authorization/priority controls were changed.

### 2026-11-12 — E3d5c4q Cross-Process Checkpoint Inspection Accepted (18/18)

Developer screenshots confirm **ALL 8 E3D5C4Q PHASE 1 CHECKPOINT WRITER TESTS PASSED** followed by a complete Godot 4.6.2 editor exit/reopen and **ALL 10 E3D5C4Q PHASE 2 RESTART INSPECTION TESTS PASSED** (**18/18 total**). The isolated writer published two immutable test-only checkpoint generations; the independent reader in a later Godot process found both intact, validated their checksums and common owner, verified the earlier 3 escrow + 3 staged + 1 belt ingot record, confirmed the newer drained description, and selected the newer record strictly for inspection. Reading/toggling inspection did not change file digests or grant any restore/release authority; Phase 2 deleted the two exact namespaced test files only after successful checks.

**Boundary of evidence:** Normal cross-process file continuity was verified, not abrupt termination/power-loss durability, authenticated checkpoint provenance, live game save/load, actual material restoration, construction readiness/worker dispatch, or release of inventory claims. All checkpoint file opt-ins remain disabled by default; Main and Factory Testing Sandbox remain unmodified. E3d5c4q is accepted and closed; any live-world persistence or construction automation requires separate guarded implementation and regression tests.

### 2026-11-13 — E3d5c4r Site-Owned Construction Readiness Bridge Staged (F6 Pending)

Following E3d5c4q screenshot-confirmed **18/18**, staged a fixture-only opt-in bridge from **exclusive per-site construction staging** to the existing finite material/power/worker coordinator. The default shared-inventory mode remains unchanged. Owned mode pins the originally claimed per-site buffer, debits materials only through BlueprintConstructionSiteStagingRegistry.reserve_for_site(), validates the locked claim in QUEUED/CONSTRUCTING/PAUSED, and fails closed if either ownership opt-in is switched off or the registry becomes unavailable. A disconnected warehouse must never supply an unrelated site. Added read-only registry.matches_owned_inventory(), and `tests/blueprint_owned_readiness_e3d5c4r_test.tscn` with **18 A–R F6 checks pending** for authorization, two exclusive buffers, partial supply, no cross-site material borrowing, non-preemption, ownership outage/restore, manually timed completion, cancellation refund and item conservation.

This fixture uses explicit inventory-to-buffer transfers; E3d5c4i separately established physical belt delivery. Prototype generator nameplate is not metered delivered power, worker slots are not drones, and no production scene installs this coordinator. No Main, Factory Testing Sandbox, hotbar, authorization, route, combat or production code was changed. Real worker delivery, power consumption, persistent recovery and save/load remain future work.

### 2026-11-13 — E3d5c4r Site-Owned Construction Readiness Accepted (18/18)

Developer Godot 4.6.2 screenshot confirms **ALL 18 E3D5C4R SITE-OWNED READINESS TESTS PASSED**, A–R. The fixture verified per-site exclusive staging inventory, no cross-site/shared warehouse debit, complete bills before atomic escrow, independent prototype-power and finite-worker gating, non-preemptive priority, safe pause on ownership-registry/feature-gate loss, restart with retained escrow and construction progress, successful completion debit, cancellation refunds and remaining locked claims. Existing Main and Factory Testing Sandbox were untouched. This is test-only and not evidence of real drones, delivered/metered electricity, game-world save/load or automatic construction readiness in playable scenes.

### 2026-11-13 — E3d5c4s Conveyor Delivery to Owned Readiness Staged (F6 Pending)

Added an isolated integration fixture `tests/blueprint_conveyor_owned_readiness_e3d5c4s_test.tscn` with **16 A–P pending Godot F6 checks**. It combines the already-verified site-aligned construction input, actual connected ConveyorSegment + travel timer and cargo inventory, per-site staging registry, E3d5c4r owned escrow/coordinator, finite prototype power and one synthetic worker slot. Four ingots are explicitly seeded in a test supplier; three must travel on the actual belt before the owned escrow can start a timed construction. A fourth held belt ingot must remain blocked after the site starts. A generator outage must pause work with escrow retained, recovery must resume progress, and completion must consume exactly three while allowing explicit recovery of the fourth. A disconnected nine-ingot warehouse remains untouched. No live factory scripts or playable scene nodes changed; no automatic transport-based construction readiness is enabled in-game. **Pending developer acceptance:** 16/16 not yet run. Prototype nameplate power is not metered delivery and worker slots are not physical drones; real save/load and durable recovery remain future work.

### 2026-11-13 — E3d5c4s Physical Conveyor to Owned Readiness Accepted (16/16)

Developer Godot 4.6.2 screenshot confirms **ALL 16 E3D5C4S CONVEYOR-TO-OWNED-READINESS TESTS PASSED**. Three real timed conveyor transfers delivered explicit test ingots to the exclusive staging buffer of an authorized site; its complete bill then entered atomic escrow and qualified for prototype power plus one synthetic worker slot. A fourth item stayed in cargo after the site left QUEUED; an outage paused construction without losing escrow/progress; restoration resumed the timer; completion committed three units and explicit cargo recovery conserved the fourth. Disconnected warehouse stock was never debited. Main/Factory Testing Sandbox unchanged. This is NOT proof of actual miners/smelters as source, real worker drones, metered electricity, normal-scene dispatch or game save/load.

### 2026-11-13 — E3d5c4t Mined Ore to Site-Owned Construction Staged (F6 Pending)

Added only `tests/blueprint_mined_owned_construction_e3d5c4t_test.gd` and `.tscn` (21 A–U checks **pending local Godot F6**). Extends the accepted E3d5c4g real finite mining, Extractor -> Storage -> Smelter chain with an actual authorized ConstructionSite, independent aligned input receiver, exclusive staging ownership, and the accepted E3d5c4r/s owned-material escrow/coordinator. Eight deposit ore become four recipe-made ingots; three travel across connected belts, enter site-owned escrow, and qualify a manually advanced construction job under fixture-only prototype power and a single synthetic worker slot. The fourth ingot must stay safely in belt cargo until explicit recovery. An outage pauses and restarts verified progress. No ore/ingot is seeded into factory inventories; the deposit must account for all consumed and recovered resources. Normal playable scenes remain unmodified and have no autonomous coordinator.

This is another strictly isolated functional integration experiment: prototype generator nameplate power is not physically metered delivery, synthetic worker slots are not drones, and there is no real save/load or durable recovery. No world restoration or claim release is enabled.

### 2026-11-13 — E3d5c4t Mined Ore to Site-Owned Construction Accepted (21/21)

Developer screenshot from Godot 4.6.2 confirms **ALL 21 E3D5C4T MINED-ORE-TO-OWNED-CONSTRUCTION TESTS PASSED**. The F6 fixture mined eight finite ore from TestOreDeposit, transported ore through actual Extractor/Storage/Smelter connections, smelted four genuine ingots, moved three across the conveyor chain to an explicitly authorized and uniquely claimed construction site, escrowed exactly its bill, then completed the timed building using fixture-only prototype power and one synthetic worker slot. Outage and restoration preserved progress; the fourth manufactured ingot stayed in cargo and was explicitly recovered. No inventory creation/duplication, worker authority bypass, or source-site ownership leakage was observed. This remains an isolated experiment; normal playable scenes, physical drones, true power consumption and durable world save/load remain unimplemented.

### 2026-11-13 — E3d5c4u Isolated Visible Construction Drone Flight Staged (F6 Pending)

Introduced `PrototypeConstructionWorkerDrone` as an opt-in standalone Node3D with a simple 3D placeholder body, strictly single-site binding, bounded straight-line travel from home to an explicitly authorized blueprint, observable arrival, moving-site re-approach, and return-to-home on cancellation or site destruction. It intentionally **never calls authorize(), set_availability(), job.advance(), coordinator.reconcile(), scheduler methods, power allocators or inventory operations**. Flight does NOT count as worker-slot dispatch and does NOT unlock the blueprint's worker wait gate. A completed/cancelled site cannot silently transfer its claimed drone to a second site.

Added `tests/prototype_construction_worker_drone_e3d5c4u_test.tscn` with **16 A–P Godot F6 checks pending** for defaults-off, authorization, invalid flight parameters, speed limits, mid-flight feature disable, arrival, site relocation, single binding, cancellation return and no playable-scene integration. This is explicitly NOT real collision/pathfinding, autonomous charging, drone fleet dispatch, work contribution or save/load. Main and Factory Testing Sandbox remain unchanged.

### 2026-11-13 — E3d5c4u Physical Drone Flight Accepted (16/16)

Developer Godot 4.6.2 screenshot confirms **ALL 16 E3D5C4U ISOLATED CONSTRUCTION DRONE FLIGHT TESTS PASSED** (A–P). A simple visible 3D placeholder drone refused plans and invalid flight parameters, obeyed speed bounds and opt-in flight, reached and reacquired an authorized site, refused assignment to another blueprint, then returned home and remained non-reassignable after cancellation. Arrival granted **no** construction worker readiness or resource/power authority. Test-only movement did not modify Main, Factory Testing Sandbox, controller, scheduler or factory logistics.

### 2026-11-13 — E3d5c4v Drone Presence to Worker-Slot Readiness Staged (F6 Pending)

Extended the existing BlueprintConstructionSlotScheduler with a **default-OFF, test-only physical drone presence gate**. An explicit `bind_site_drone()` verifies a drone assigned to the **same authorized site**, preventing duplicate or cross-site binding. When enabled, a worker slot is not eligible without a live, bound, **arrived** drone, verified power and materials. Once binding begins, turning off the scheduler's feature gate does **not** restore simulated worker eligibility; it pauses until explicitly re-enabled. Added observation-only `PrototypeConstructionWorkerDrone.is_bound_to_site()`; the drone still never authorizes, changes ConstructionJob availability or advances construction itself.

Added `tests/prototype_drone_worker_readiness_e3d5c4v_test.tscn` with **21 A–U checks pending local Godot F6** for planned/priority denial, per-site staging/escrow, full material and power readiness while a drone is in flight, correct binding, worker admission strictly upon arrival, pause/resume on scheduler/drone/power opt-out, one-time timed completion and drone return. The fixture explicitly calls coordinator.reconcile() before work advancement. It does not establish automatic real-time worker revocation, pathfinding/obstacle avoidance, fleet dispatch, recharge/power simulation, persistent worker identity or scene integration. Main and Factory Testing Sandbox remain unchanged.

### 2026-11-13 — E3d5c4v Physical Drone Arrival / Worker Readiness Accepted (21/21)

Developer Godot 4.6.2 screenshot confirms **ALL 21 E3D5C4V PHYSICAL DRONE WORKER READINESS TESTS PASSED**, A–U. An explicitly authorized, uniquely owned site could receive worker readiness **only** after the assigned physical drone arrived and finite power/material escrow both checked; in-flight drones never granted a slot. Owner mismatch and duplicate binding failed. Disabled worker gate, disabled drone, or power loss paused the job while preserving reserved material and completed work; restoration resumed verified progress. Completed work consumed its escrow once and the drone returned home while its receiver claim remained locked. Test was isolated; no autonomous game-scene dispatch, charging, pathfinding or durable recovery was claimed.

### 2026-11-13 — E3d5c4w Two-Drone Construction Fleet Dispatcher Staged (F6 Pending)

New `PrototypeConstructionDroneFleet` is an opt-in, fixture-only, **caller-triggered** dispatch manager for at most the scheduler's finite worker-slot capacity. It takes only already-registered/authorized QUEUED jobs from the shared High → Normal → Low priority queue, attaches at most one pre-registered IDLE drone to each, and binds its actual physical presence to the existing default-off scheduler gate. It has no authorization, material debit, energy allocation, construction timer, save/load or worker release authority of its own. Launched drones remain one-shot/pinned even after returning to the home point; eventual reuse must get its own transactional release and charging design. Read-only scheduler query helpers are isolated and do not change default behavior.

Staged `res://tests/prototype_construction_drone_fleet_e3d5c4w_test.tscn` with **21 A–U checks pending Godot F6**. The fixture deliberately tracks Low, Normal, High in reverse order; verifies High and Normal receive the only two physical drones, three exact site-owned material bills are escrowed, only two sites fit the finite prototype power budget, and no work starts while the drones are flying. Arrival opens each worker slot separately. Displacing a drone pauses only its own job, and generator outage pauses both. Completion/cancellation returns two retired drones; a third site is never handed a drone without an explicit future fleet-reuse protocol. No existing gameplay scenes, normal conveyor transport, construction authorization controls, or power production behavior changed. No autonomous fleet, pathfinding, battery charging or persistence is implemented.

### 2026-11-13 — E3d5c4w Finite Drone Fleet Accepted (21/21)

Developer Godot 4.6.2 screenshot confirms **ALL 21 E3D5C4W PHYSICAL CONSTRUCTION FLEET TESTS PASSED**, A–U. Two unique physical drones were explicitly dispatched to three authorized jobs in High → Normal → Low order. Their site-owned escrow and finite prototype power were enforced separately from worker presence. No in-flight drone triggered work; arriving drones independently unlocked actual scheduler slots. Site displacement and power outage caused safe pause and recovery; cancellation and completion docked the two permanently pinned workers. A third authorized job remained queued rather than stealing or silently recycling a drone. Material balances and non-live-scene boundaries were retained. No charging, reusable workers, autonomous fleet runtime, obstacle-aware navigation or persistent world state was demonstrated.

### 2026-11-13 — E3d5c4x Drone Battery, Docking, and Return Reserve Staged (F6 Pending)

Added **default-OFF battery accounting** to the isolated `PrototypeConstructionWorkerDrone` with a one-time `configure_battery()` latch. An energy-equipped drone refuses assignment unless it can cover a straight-line outward flight and return-home energy reserve; actual outbound and return distances debit charge. A moved destination too far away triggers an early physical return without spending the return reserve. Disabling the configured battery flag freezes outward flight rather than silently reverting to unlimited energy. The explicit `charge_at_home(delta, powered)` method requires the drone physically IDLE or DOCKED at its registered home and a caller-supplied powered flag, caps charge, and has no job authorization or worker-slot side effects.

New `tests/prototype_drone_battery_dock_e3d5c4x_test.tscn` has **20 A–T pending F6 checks**, including invalid charge settings, low-energy dispatch refusal, powered/unpowered charging, metered flights, feature opt-out, moved-site return, dock energy totals, no double-assignment after charging, and compatibility with default-unmetered drones. This is test-only straight flight with power represented by an explicit boolean, **not metered grid draw** or true low-battery drone recovery. Battery charging **never releases** a one-shot worker or construction receiver claim; durable worker reuse requires a separate guarded protocol. No Main, Factory Testing Sandbox, fleet defaults, conveyor or real power production files were changed.

### 2026-11-13 — E3d5c4x Drone Battery and Docking Accepted (20/20)

Developer Godot 4.6.2 screenshot confirms **ALL 20 E3D5C4X DRONE BATTERY AND DOCKING TESTS PASSED**, A–T. Default-off battery accounting rejected invalid settings, refused insufficient-charge flight, required a powered home dock for charging, debited movement against straight-line distance, preserved a return-flight margin, stopped a drone from chasing a moved site beyond its energy reserve, and capped the physically docked recharge. Disabling a configured battery did not allow unmetered outbound travel. A recharged drone still could not be re-assigned to another blueprint or release its existing job/receiver claim. The fixture also verified unchanged default-unmetered behavior.

**Important scope:** the charging power signal was manually supplied by the test, not measured grid delivery; flight uses straight-line movement without obstacle avoidance; workers are still one-shot and do not support safe post-job reuse. No normal-world autonomous fleet, save/load, or durable release protocol is present. Before staging reusable-worker changes, rerun E3d5c4u, E3d5c4v, and E3d5c4w in Godot against this new battery-equipped implementation as compatibility regression tests.

### 2026-11-13 — E3d5c4x Post-Battery Drone Regression Accepted (58/58)

Developer supplied two complete sets of Godot 4.6.2 screenshots proving compatibility after E3d5c4x: E3d5c4u **16/16**, E3d5c4v **21/21**, and E3d5c4w **21/21** (58/58 per run, all three suites passing twice). No regression failures were reported. E3d5c4x battery/docking remains accepted separately at 20/20.

### 2026-11-13 — E3d5c4y Explicit Docked Worker Recycling Staged (20 F6 Pending)

Added a separate default-OFF `enable_isolated_reuse` option to the test-only physical drone and fleet. An old worker can only be rearmed through explicit `recycle_docked_worker(drone, escrow)` after its original job is COMPLETE/CANCELLED, the drone is physically DOCKED at home with its metered battery fully recharged, the global test escrow ledger is empty (conservative until per-site durable claims exist), the scheduler has no active workers or stale binding, and the old site is no longer tracked. Releasing a worker never removes/reassigns a construction receiver claim or manipulates escrow. Original job callbacks are disconnected before new work to prevent late old-site exit from interrupting the successor. One-use default behavior remains unchanged.

Added `res://tests/prototype_construction_drone_reuse_e3d5c4y_test.tscn` with 20 A–T checks PENDING local Godot F6. The isolated fixture tests two consecutive authorized building jobs on one physical drone, with initial progress, cancellation and deliberately blocked escrow refund, safe alternate-inventory recovery, required recharge, explicit reuse, second ownership and one-time construction completion. No Main/Factory Testing Sandbox installation, automation, persistent worker ledger, real power-metered charging, navigation, or safe concurrent per-site escrow release is introduced. Do not claim this is production-ready drone reuse.

### 2026-11-13 — E3d5c4y Safe Docked Drone Reuse Accepted (20/20)

Developer Godot 4.6.2 screenshot confirms **ALL 20 E3D5C4Y SAFE CONSTRUCTION DRONE REUSE TESTS PASSED**, A–T. One explicitly assigned battery-equipped drone reached an authorized, escrow-backed construction site; cancellation with a full buffer forced an unresolved refund while the worker physically returned home. Default-off release, stale scheduler worker bindings, unresolved escrow and depleted battery independently prevented reassignment. Separate material recovery and verified powered recharge cleared those blockers; explicit recycling released only the worker assignment, leaving protected input/receiver claims intact. The same drone then flew to a different authorized site, required a new escrow, power and actual presence, completed construction and returned without automatic reuse. Main/Factory Testing Sandbox remained unchanged.

### 2026-11-13 — E3d5c4z Controlled Drone Lifecycle Tick Staged (F6 Pending)

Added a **default-OFF test-only** `PrototypeConstructionDroneTickController` which has no `_process` and runs only when the caller explicitly invokes `tick(delta, dock_power_verified)`. It verifies service identity, full exclusive material escrow and prototype power before dispatching any drone, then moves registered physical drones, reconciles worker presence, advances only fully ready construction jobs and reconciles completion. At the home dock it charges battery only when supplied a caller-verified charging power flag, and attempts the separately gated E3d5c4y safe reuse protocol only after terminal assignment, scheduler cleanup, an empty global escrow ledger and full battery. Missing requirements, invalid delta, disabled feature gates and unrelated warehouse stock never grant worker or construction authority.

The new `tests/prototype_construction_drone_tick_e3d5c4z_test.tscn` contains **20 A–T checks PENDING local Godot F6**. It drives two consecutive authorized sites with one charging drone; material shortfall, in-flight delay, power outage pause/resume, blocked cancellation refund, dock recovery, charge, safe rearm and second completion are covered. Existing standalone fleet `dispatch_waiting()` remains unchanged by default; the controlled driver calls its new optional resource-ready mode. Neither Main nor Factory Testing Sandbox was edited. This is NOT a production loop, real-time source-verified grid charging, obstacle-safe navigation, physics collision, durable worker ownership or save/load.

### 2026-11-13 — E3d5c4z Controlled Construction Drone Lifecycle Accepted (20/20)

Developer Godot 4.6.2 screenshot confirms **ALL 20 E3D5C4Z CONTROLLED DRONE LIFECYCLE TICK TESTS PASSED**, A–T. A default-off caller-driven controller dispatched only after independent prototype-power and site-owned material escrow readiness, observed real drone travel before granting the worker slot, advanced job progress through explicit ticks, paused/resumed during a generator outage and conserved escrow across cancellation. After material recovery and full dock recharge, it explicitly recycled the old drone worker assignment and dispatched the same drone to a second authorized site with its own escrow. The second building completed with no unauthorized blueprints or inventory duplication. Charge power was an input flag in a fixture, not metered physical grid electricity. No playable-scene automatic drone dispatch or true save/load was established.

### 2026-11-13 — E3d5c5a Factory Testing Sandbox Drone Bridge Staged (F6 Pending)

Added `SandboxConstructionDroneLifecycleGate` to **Factory Testing Sandbox only**, with `enable_isolated_bridge = false` saved in the scene. The Main scene, `WorldInteraction` script, construction authorization/priority docks, route/logistics and combat were untouched. The gate is NEVER auto-processed or supplied with fake material/power/worker services. To opt in during a sandbox test, it requires the exact scene instance, blueprint planning enabled, the older `blueprint_sandbox_debug_requirements` bypass explicitly switched OFF, and a same-scene child `PrototypeConstructionDroneTickController` already configured with matching owned escrow, scheduler and fleet. It then supports **caller-triggered** `tick_once(delta)` only. Dock charging is hard-disabled because no verified charger power provider exists in normal gameplay.

Added `res://tests/sandbox_construction_drone_bridge_e3d5c5a_test.tscn` with 20 A–T checks **pending local Godot F6**, loading Main and the actual sandbox scene, checking disabled-by-default host and UI preservation, debug-bypass interlock, proper authorization without fake readiness, own staging escrow, bounded worker/power, drone flight and construction, outage pause, completion, and immediate tick denial when the debug bypass or bridge flag switches on/off. This is a test-driven mounting step, NOT enabling automated construction in ordinary sandbox gameplay. A future guarded source-wiring milestone must connect actual placed blueprints, real belt input, power/dock verification and per-frame scheduling. No new background loops or unconditional gameplay hooks were introduced.

### 2026-11-13 — E3d5c5a Factory Testing Sandbox Drone Bridge Accepted (20/20)

Developer screenshot from Godot 4.6.2 confirms **ALL 20 E3D5C5A SANDBOX DRONE BRIDGE TESTS PASSED**, A–T. The real Factory Testing Sandbox mounts the default-OFF lifecycle gate without changing Main. An opt-in sandbox scene instance disabled its legacy debug requirements override, attached an independently verified test-only drone controller and a site-owned escrow/receiver, and demonstrated actual drone flight, construction readiness, power pause/resume and completed Storage. Toggling the legacy bypass or disabling the bridge stopped controlled ticks without changing UI, ownership claims or unrelated stock. No live per-frame scheduling or permanent gameplay power/material providers were enabled.

### 2026-11-13 — E3d5c5b Player-Placed Sandbox Blueprint / Conveyor Receiver Staged (F6 Pending)

Added a default-OFF `SandboxConstructionDroneLifecycleGate.attach_player_site_receiver()` admission API. It only accepts a real sandbox-parented ConstructionSite registered via `WorldInteraction._create_blueprint_site()`, already intentionally QUEUED by the existing authorization mechanism, along with valid same-sandbox owned staging and registry services. Its independent Node3D receiver attaches via the existing E3d5c4i site-aligned port and immutable owner claim; no automatically created stock, power, work slots or ready flags. Foreign sites, PLANNED sites, duplicate claims and wrong material types fail closed. Normal Factory Testing Sandbox continues to have its bridge OFF and debug bypass ON.

Added `res://tests/sandbox_player_blueprint_delivery_e3d5c5b_test.tscn` with **20 A–T pending F6 checks**. It exercises the actual WorldInteraction player blueprint placement path at a grid-snapped rotated Storage position, existing explicit E-style authorization without debug bypass, site-owned physical receiver alignment, real reciprocal ConveyorSegment transport of three fixture-seeded ingots, finite prototype power, an actual physical battery drone through the sandbox bridge, generator outage/recovery, Storage completion and recovery of a fourth ingot held in belt cargo. Stock in a disconnected warehouse remains untouched and Main has no lifecycle gate. This is test-seeded supplier inventory, **not** automatic placement-time provisioning, automatically mined materials, real power-metered charging, production per-frame dispatch, obstacle navigation or durable save/load. No WorldInteraction, hotbar, Main, combat, or production logistics source code was modified.

### 2026-11-13 — E3d5c5b F6 Check R Assertion Order Corrected (Re-test Pending)

Developer Godot 4.6.2 screenshot paused at `tests/sandbox_player_blueprint_delivery_e3d5c5b_test.gd:244`: `assert(not timer.advance_transport(1.0))`. This expected rejection of a fourth ingot too early. After exactly three ingots are escrowed, the bounded staging inventory has space again, and the authorized site is still **QUEUED** while its drone travels; `BlueprintConstructionAnchoredStagingPort.can_accept_item()` currently permits delivery while QUEUED. The rejected-transfer condition becomes valid only once the worker has arrived and the job transitions to CONSTRUCTING.

Moved the fourth-ingot transfer attempt until **after** the explicit drone arrival/construction tick. The test now checks both `not port.can_accept_item(ingot)` and rejected transfer, with the fourth ingot retained in conveyor cargo for explicit recovery. No runtime port, escrow, construction coordinator, drone or gameplay scene files changed. **The previous attempt did not pass 20/20; a fresh E3d5c5b F6 run remains pending.**

**Known production gap:** A material-backed QUEUED site may accept excess physical deliveries after its bill has been escrowed but before drone arrival. Future work must introduce a separately tested, ownership-aware **escrow intake lock** without altering the older E3d5c4i test's intentional queued-buffer refund/recovery scenario or direct staging tests. Until then, the E3d5c5b scenario deliberately keeps the fourth ingot in the moving belt until construction starts and does not claim safe automatic excess-intake prevention during transit.

### 2026-11-13 — E3d5c5b Player Blueprint / Physical Belt Delivery Accepted (20/20)

Developer Godot 4.6.2 screenshot confirms **ALL 20 E3D5C5B PLAYER BLUEPRINT BELT DELIVERY TESTS PASSED**, A–T, after the fourth-ingot assertion was corrected. The sandbox WorldInteraction placement path created a rotated Storage plan, which was explicitly authorized without debug readiness; three physical timed belt deliveries entered a site-owned buffer and were escrowed. Actual drone flight and finite prototype power enabled timed construction and safe outage pause/recovery. A fourth ingot was kept in conveyor cargo until the site transitioned from QUEUED to CONSTRUCTING, then rejected and explicitly recovered. A disconnected warehouse remained untouched, Main opted out, and material claims remained locked. **Known gap from this successful test:** the existing queued receiver could admit extra stock while escrow was held, prior to drone arrival.

### 2026-11-13 — E3d5c5c Escrow-Aware Receiver Intake Lock Staged (F6 Pending)

Added a default-OFF, explicitly bound **escrow-intake lock** to the isolated `BlueprintConstructionAnchoredStagingPort` only. An opt-in receiver refuses cargo until its original site-owned, aligned QUEUED staging buffer is bound to a live escrow ledger. It then permits normal real-belt delivery before reservation and refuses additional items **as soon as escrow holds the site bill**, even while construction remains QUEUED and its worker is still in flight. Losing the bound escrow, turning the feature flag off, site movement/end or invalid original ownership fails closed; the method does not reserve/debit/release escrow or create construction authority. Default-OFF ports preserve E3d5c4i's intentional post-escrow queued-buffer cancellation/recovery path.

Staged `res://tests/sandbox_escrow_intake_lock_e3d5c5c_test.tscn` with **24 A–X checks pending F6**, extending the accepted E3d5c5b real sandbox placement/belt/drone test. The fourth seeded ingot must remain in the actual belt cargo immediately after reservation and before drone arrival, including while the guard is toggled off/on; completion must still consume exactly three and explicit recovery must account for the fourth. No Main/Factory Testing Sandbox scene, WorldInteraction, conveyor runtime, inventory debit, fleet, power or authorization controls were changed. This is a test-only guard, **not automatic per-site escrow installation**, real grid metering or durable claim recovery. E3d5c4i/E3d5c5b compatibility reruns are recommended after acceptance.
### 2026-11-13 — E3d5c5c Escrow-Aware Receiver Intake Lock Accepted (24/24)

Developer-provided Godot 4.6.2 output screenshot confirms **ALL 24 E3D5C5C ESCROW-AWARE RECEIVER INTAKE TESTS PASSED** (A–X). A real WorldInteraction-created, explicitly authorized Storage blueprint received three ingots through a reciprocal physical conveyor connection. In the experimental default-OFF receiver mode, binding the exact site-owned escrow ledger allowed normal pre-reservation delivery but **blocked the fourth ingot immediately upon reservation while the drone was still in flight and the job remained QUEUED**. The rejected fourth ingot stayed in belt cargo through flight, construction, generator-off pause and restored-power completion, then was explicitly recovered. Switching the bound intake-lock flag OFF did not reopen deliveries or release ownership; unrelated warehouse stock remained untouched. No playable scene or WorldInteraction source changed.

**Acceptance scope:** This verifies the optional escrow-aware physical receiver guard in the isolated F6 fixture, not automatic per-blueprint integration in normal gameplay. The previous E3d5c4i test intentionally relies on default-OFF delivery after escrow to test cancellation refunds; that and E3d5c5b still require fresh Godot regression runs after this change. **Next verification:** E3d5c4i expected 16/16 and E3d5c5b expected 20/20 (36 total). Before production integration, test fail-closed behavior for deleted/replaced escrow sources, moved construction sites, concurrent queued sites, and cancellation recovery, and establish durable claim/save-load handling.

### 2026-11-13 — E3d5c5c Post-Intake-Lock Regression Accepted (36/36)

Developer Godot 4.6.2 screenshots confirm fresh regressions **E3d5c4i 16/16** (original anchored receiver, queued post-escrow stock and cancellation refund/recovery), followed by **E3d5c5b 20/20** (real WorldInteraction-placed Storage, physical belt transport, owned escrow, powered drone construction and fourth-cargo recovery). Both suites passed after the default-off E3d5c5c intake-lock change, for **36/36**. The lock's new default-off behavior preserves historical tests.

### 2026-11-13 — E3d5c5d Authorization-Event Receiver Autowire Staged (F6 Pending)

Added an observation-only `WorldInteraction.blueprint_site_authorized(site)` signal emitted **only after a real explicit authorization**. The Main controller has no listener. Extended the default-OFF sandbox `SandboxConstructionDroneLifecycleGate` with a separately opt-in, single-configured, same-scene **authorized-blueprint receiver autowire**. A caller must supply an existing site-owned registry, escrow ledger, and preconfigured compatible material staging buffer for a PLANNED managed blueprint. When WorldInteraction authorizes that specific registered site, the hook synchronously creates the independent owned receiver and enables + binds its escrow-aware intake lock **before** any belt connection is possible. Unregistered or foreign sites, duplicate staging, wrong parent/service ownership, disabled bridge or active debug bypass do not gain receivers, inventory or permission.

Added `res://tests/sandbox_authorization_receiver_autowire_e3d5c5d_test.tscn` with **19 A–S F6 checks pending**. It uses two real player-created sites, explicit E-style authorization, one registered site staging, a physically connected conveyor, exact three-ingot escrow lock, a blocked fourth item, a disabled autowire flag, and cancellation refund/material conservation. No autoplay, worker dispatch, automatic raw material source, generated inventory, live grid charging, Main/Factory Testing Sandbox scene edit or save/load is introduced. Event-driven intake installation does not by itself mark power/material/worker readiness. Future milestones must safely discover construction-material sources and provision verified registry/escrow services in actual sandbox gameplay.

### 2026-11-13 — E3d5c5d Authorization-Event Receiver Autowire Accepted (19/19)

Developer Godot 4.6.2 screenshot confirms **ALL 19 E3D5C5D AUTHORIZATION-TO-RECEIVER AUTOWIRE TESTS PASSED**, A–S. Existing player blueprint placement and explicit authorization emitted a new read-only event; the default-off sandbox gate accepted only a pre-registered, same-sandbox construction site/buffer pair and attached a separately anchored receiver with an escrow intake lock. Actual physical conveyor transport of three test-supplied ingots, owner-only escrow, fourth-item denial, site cancellation refund, belt recovery and permanent input ownership were validated. A second unregistered site remained receiver-less. No Main, scene defaults, generated construction materials or live autonomous workers were enabled.

### 2026-11-13 — E3d5c5e Existing Physical Output Enrollment Staged (18 F6 Pending)

Added an **independent default-OFF** `SandboxConstructionDroneLifecycleGate.enable_isolated_output_enrollment` experiment. The caller explicitly supplies an existing same-sandbox `ItemPortComponent` with OUTPUT direction and an InventoryComponent owned by the same supplier node; wrong-parent, INPUT, foreign and invalid output sources fail closed. A still-PLANNED managed blueprint receives only a freshly allocated **empty** BlueprintConstructionMaterialStaging with capacity equal to its validated ConstructionMaterialBill. It is pre-registered with E3d5c5d authorization-event autowiring, and the original output port is pinned against duplicate enrollment in this fixture. The authorization callback revalidates the original enrolled output **and its pinned inventory identity** (as well as the independent feature flag) before creating the escrow-protected receiver. ConstructionSite nodes cannot impersonate source buildings. No inventory is copied or credited; ingots must still travel through a real connected belt before construction can escrow them.

New `res://tests/sandbox_output_source_enrollment_e3d5c5e_test.tscn` contains **18 A–R checks pending local Godot F6** covering default-off gates, sandbox debug override, invalid source identity, one-output/one-blueprint enrollment, deliberate authorization, physical belt delivery, site-only escrow lock and cancellation/recovery inventory conservation. Existing E3d5c5d `prepare_player_site_intake()` remains unchanged; no WorldInteraction or scene edits, no background dispatch, fabricated stock, auto-discovery of completed building outputs, metered dock power or save/load. This is still only fixture-driven source enrollment, not production player UX.
### 2026-11-13 — E3d5c5e Sandbox Output Enrollment Accepted (18/18)

Developer's Godot 4.6.2 F6 screenshot confirms **ALL 18 E3D5C5E SANDBOX OUTPUT ENROLLMENT TESTS PASSED**, A–R. The opt-in sandbox gate enrolled one pre-existing valid OUTPUT port/inventory as the material supplier for an explicitly PLANNED and subsequently authorized player-created Storage blueprint, created only an EMPTY three-unit staging buffer, and rejected foreign, wrong-direction, wrong-owner and competing output registrations. Authorization attached an exclusive, escrow-locked receiver without generating resources. Three of the four test-seeded ingots traversed a physically connected timed conveyor; the exact owned bill was escrowed, blocking the fourth ingot in belt cargo while the site remained QUEUED. Cancellation refunded the three units to the owned buffer, and explicit belt cargo recovery accounted for the fourth. Main and committed Factory Testing Sandbox defaults remained unchanged. The test used a deliberately seeded supplier, not automatic discovery of natural factory production.

**Next required compatibility checks:** re-run **E3d5c5d 19/19** (direct pre-registered authorization/receiver autowiring) and **E3d5c5c 24/24** (escrow-aware physical intake), for **43/43 pending regression tests**, before more normal-sandbox integration. The pinned output inventory identity added in commit `9420fbd` was inspected in code but **not directly mutation-tested by E3d5c5e**; follow-on tests should cover port inventory substitution or deletion between enrollment and authorization, source failure after authorization, and multi-site source sharing. No automatic worker/dock power orchestration, collision/pathfinding or world save/load is enabled.

### 2026-11-13 — E3d5c5e Source Enrollment Regressions Accepted (43/43)

Developer Godot 4.6.2 screenshots confirm **E3d5c5d 19/19** and **E3d5c5c 24/24**, total **43/43** fresh regression checks after the E3d5c5e output enrollment feature. Existing authorization-event autowiring, escrow-aware physical intake, full bill delivery, material recoveries and default-off gates remained compatible.

### 2026-11-13 — E3d5c5f Factory Output Source Integrity Staged (20 F6 Pending)

Added a separately opt-in, default-OFF source-identity guard on `BlueprintConstructionAnchoredStagingPort`, alongside a read-only `BlueprintConstructionMaterialStaging.matches_source_inventory()`. For output-enrolled receivers only, the E3d5c5d authorization callback now checks the exact originally enrolled output/inventory and the unchanged staging source, then synchronously binds both the escrow lock and original producer source identity **before any belt can attach**. The added receiver guard rejects physical input if the original source port is deleted, its direction changes, its source inventory is replaced, its original producer output diverges, its staging source changes or its own feature is disabled. An observed mismatch latches that receiver closed permanently; a simple pointer change or feature toggle cannot silently reopen it. Existing manually staged E3d5c5d and default-off receivers are unaffected.

Added `res://tests/sandbox_factory_source_validation_e3d5c5f_test.tscn` with **20 A–T Godot F6 checks pending**: four actual WorldInteraction-planned sites, preauthorization source-swap and source-deletion denial, an authorized original-source receiver with real timed physical belt delivery, postauthorization inventory replacement blocking the next in-flight ingot, latched denial after pointer restoration/feature toggling, postauthorization source-deletion denial on a second receiver, cancellation, recoverable belt cargo and four-ingot conservation. Untrusted output replacement does not give new material authority. Main, the committed Factory Testing Sandbox gates, construction authorization controls and drone/runtime loops remain unmodified. There is still **no** automatic supplier selection, producer-to-conveyor route identity verification, real power/worker dispatch integration, persistent claim-release protocol or save/load. Source faults must eventually have a separate explicit recovery/reset design; no silent rearm is included.

### 2026-11-13 — E3d5c5f Factory Source Identity Accepted (20/20)

Developer Godot 4.6.2 screenshot confirms **ALL 20 E3D5C5F FACTORY SOURCE IDENTITY TESTS PASSED**, A–T. Four real sandbox-created planned blueprints exercised default-off guards, required blueprint authorization, original output/inventory pinning, and failure of enrollment when an output inventory was changed or its port removed before authorization. A valid authorized blueprint accepted an ingot through the physically connected timed conveyor into its exclusive construction buffer. Replacing the source inventory after authorization prevented the next in-flight ingot from entering the receiver; restoring the original pointer and toggling the source guard did not reopen the compromised port. Deleting a second authorized source also disabled further intake. Cancellation left construction ownership claims locked; the held belt cargo was recovered, and the original four-ingot source/accounting example remained conserved. No change to playable scene defaults or live drone/worker scheduling is implied.

**Acceptance scope:** This validates the isolated F6 test only. It does not establish automatic output discovery, real conveyor route verification beyond the fixture, persistent material recovery, valid electrical charging, navigation, or saved worker/claim identity. The new source guard is default-OFF for older receivers and is explicitly bound for source-enrolled sandbox ports.

**Next regressions pending after E3d5c5f:** Run **E3d5c5e 18/18** (physical-output enrollment) and **E3d5c5d 19/19** (direct authorization/receiver autowiring), **37/37 total**, to confirm backwards compatibility. If either fails, do not proceed to the proposed E3d5c5g supplier-discovery milestone until corrected. An optional deeper E3d5c5c 24/24 run can validate the independent escrow-only port path. The supplier-discovery design must prefer explicit, validated existing output ports without manufacturing stock, bypassing E/Ctrl+E authorization, or stealing already-enrolled sources.

### 2026-11-13 — E3d5c5f Source Integrity Regressions Accepted (37/37)

Developer Godot 4.6.2 screenshots confirm **E3d5c5e 18/18** and **E3d5c5d 19/19**, total **37/37** fresh compatibility checks following E3d5c5f. Real enrolled output, empty construction staging, source pinning, authorization-event receiver autowiring, escrow intake gating and physical belt/cancellation recovery remained compatible with the new default-OFF integrity guard.

### 2026-11-13 — E3d5c5g Read-Only Factory Supplier Discovery Staged (20 F6 Pending)

Added **default-OFF** `enable_isolated_supplier_discovery` to the existing Factory Testing Sandbox lifecycle gate without changing the committed sandbox or Main scenes. `discover_available_factory_outputs(site)` scans actual same-sandbox Node3D factory buildings for valid OUTPUT ItemPortComponents with legitimate same-owner source inventories, and accepts only ports currently holding a **complete bill of the exact construction items** for one still-PLANNED, managed blueprint. It excludes already connected ports (no implicit conveyor re-routing), partially stocked or wrong-item sources, and previously enrolled ports or any sibling port sharing that already-enrolled source inventory. Eligible outputs are ranked by direct squared 3D distance to the proposed site, a provisional heuristic **not** a path, transport route, power source or delivery guarantee. The scan is strictly read-only. `prepare_player_site_from_discovery(site)` is an explicit caller-triggered step that delegates to the accepted E3d5c5e enrollment API, allocating only an EMPTY bill-sized staging buffer; E/Ctrl+E authorization and actual physical belt connection remain independently necessary.

The new isolated `res://tests/sandbox_factory_supplier_discovery_e3d5c5g_test.tscn` contains **20 A–T local Godot F6 checks PENDING**, with real TestStorage and TestSmelter output scenes, insufficient and wrong-cargo decoys, multiple player-created PLANNED sites, nearest-first and exclusive selection, source identity-bound authorization, a reciprocal real conveyor from a TestStorage output, three timed ingot deliveries and a blocked fourth, cancellation/refund and cargo conservation. There is no automatic placement/authorization, material creation, route laying, supplier assignment over time, production forecasting, metered drone charging or save/load. Read-only discovery must not be mistaken for fully autonomous supplier routing.

### 2026-11-13 — E3d5c5g Factory Supplier Discovery Accepted (20/20)

Developer Godot 4.6.2 F6 screenshot confirms **ALL 20 E3D5C5G FACTORY SUPPLIER DISCOVERY TESTS PASSED**, A–T. Actual TestStorage and TestSmelter output inventories held explicitly seeded stock. Default-off discovery rejected partial bills, wrong cargo and input ports, ranked eligible stocked outputs by proximity, and enrolled distinct output sources for two still-PLANNED player blueprints without creating stock or authorization. Explicit authorization attached two protected receivers; three timed physical conveyor deliveries supplied one site's bill while the other received nothing. The exact owned escrow blocked a fourth ingot while QUEUED. Cancellation and explicit cargo recovery conserved materials; Main and normal sandbox defaults remained unchanged.

**Next regression gate:** rerun E3d5c5e (18/18) and E3d5c5f (20/20), total 38 checks, because E3d5c5g extended source enrollment to reject shared inventory identity as well as repeated output identity. The accepted E3d5c5g fixture does not independently mutation-test sibling output aliases or already-connected candidate exclusion; these should be covered by targeted follow-up tests.

**Proposed E3d5c5h:** verify actual conveyor route identity from the pinned factory output to its authorized receiver, rather than treating nearest distance or a live source pointer as proof of transport provenance. Begin with isolated straight-belt paths and negative cases (wrong source, disconnected or nonreciprocal link, and cargo retained on failed delivery); preserve legacy opt-out, explicit authorization and escrow. Do not implement automatic conveyor placement or routing until the route integrity design is validated. No continuous live supplier discovery, real production forecasting, automatic route placement, multi-source sharing, dock grid charging or save/load is established.

### 2026-11-13 — E3d5c5g Supplier Discovery Regression Accepted (38/38)

Developer Godot 4.6.2 screenshots confirm **E3d5c5e 18/18** and **E3d5c5f 20/20** following supplier discovery: all **38/38** compatibility checks passed.

### 2026-11-13 — E3d5c5h Direct Single-Belt Route Verification Staged (26 F6 Pending)

A separate default-OFF receiver flag and explicit `bind_single_belt_route()` pin a physically empty straight belt to its exact source-enrolled, escrow-guarded receiver. Requires same sandbox, original output and receiver, reciprocal port links, current endpoint alignment and no upstream/downstream segment. No direct port transfer is admitted while opted in or bound. Physical unload now calls a context-aware input hook (default delegates to the previous acceptance policy). The existing physical building load records an ephemeral source-port/inventory and cargo identity/revision stamp. Inventory successful add/remove API calls increment a monotonic in-process mutation revision so replacement with the same item via the inventory API invalidates the original stamp. A wrong-source load does not become valid merely by reconnecting the correct source. With the original stamped cargo present, a repaired reciprocal/aligned route can deliver; ordinary escrow and source identity gates still apply.

Added `res://tests/sandbox_single_belt_route_verification_e3d5c5h_test.tscn` with **26 A–Z F6 checks pending**. Extends the accepted supplier-discovery fixture with opt-in, nonempty bind refusal, wrong supplier, source reconnection with foreign cargo, broken reciprocity, misalignment, feature toggle, same-item cargo replacement, valid timed deliveries, exact escrow and recovery. Seeded fixture stocks are explicitly conserved. No scene defaults, actual conveyor placement, automatic supplier selection or construction authorization changes. Shared inventory and transfer primitives are touched, so conveyor and ordinary input regressions are required after local acceptance. This is only normal in-process API provenance for one straight segment, not cryptographic identity or protection against arbitrary direct mutation of public dictionaries/fields, direct low-level inventory transfers, multi-hop freight, splitters, production route planning, grid metering or save/load.

### 2026-11-14 — E3d5c5h Single-Belt Route Verification Accepted (26/26)

Developer-provided Godot 4.6.2 output confirms **ALL 26 E3D5C5H SINGLE BELT ROUTE VERIFICATION TESTS PASSED**, with C–Z visible in the screenshot and the final aggregate success message (A/B above the visible viewport). The real source-enrolled receiver rejected unbound and nonempty route admission, wrong-supplier delivery and foreign cargo after reconnection, nonreciprocal and misaligned source links, disabled guard and same-item cargo replacement via inventory API. Valid timed single-belt deliveries reached only the intended owned buffer; escrow rejected extra cargo while QUEUED, cancellation refunded the bill, and explicit recovery conserved inventory. The trailing "Hit nothing" is not a failed assertion. The test-only scope remains one pinned straight belt and ephemeral in-memory cargo stamping; no multi-belt provenance, automatic layout, live sandbox enablement or save/load is established.

**Required compatibility gate (nine existing F6 scenes, 99 printed PASS outcomes total, pending):**
- `res://tests/inventory_trasnfer_test.tscn` — four unnumbered PASS summaries (filename spelling as committed).
- `res://tests/item_port_transfer_test.tscn` — 7/7.
- `res://tests/conveyor_automatic_loading_test.tscn` — 10/10.
- `res://tests/conveyor_automatic_unloading_test.tscn` — 9/9.
- `res://tests/conveyor_full_chain_test.tscn` — 8/8.
- `res://tests/conveyor_splitter_test.tscn` — 10/10.
- `res://tests/conveyor_merger_test.tscn` — 10/10.
- `res://tests/sandbox_factory_supplier_discovery_e3d5c5g_test.tscn` — 20/20.
- `res://tests/blueprint_mined_owned_construction_e3d5c4t_test.tscn` — 21/21.

These are targeted regressions, not the entire project suite. Inventory tests print four unnumbered PASS summaries rather than a numbered aggregate. E3d5c5h altered shared inventory/port/conveyor helper code, so retain the unchanged opt-out behavior before proceeding. Proposed E3d5c5i: multi-segment linear route verification with provenance propagation on successful reciprocal physical belt-to-belt transfers, rejection of broken/cyclic or foreign paths and unverified cargo, and conservation. Continue with straight segments before corners and branching networks. The current stamp is not durable identity, and arbitrary direct dictionary/field mutation lies outside its guarantees.

### 2026-11-14 — E3d5c5h Logistics Regressions Accepted (99/99)

Developer provided all nine Godot 4.6.2 F6 screenshots. Inventory transfer printed all four PASS summaries; safe port transfer 7/7, automatic loading 10/10, automatic unloading 9/9, full conveyor chain 8/8, splitter 10/10, merger 10/10, supplier discovery E3d5c5g 20/20, and mined-ore-to-owned-construction E3d5c4t 21/21. All 99 targeted compatibility outcomes passed. Together with E3d5c5h 26/26 this is 125 reported successes, not a full-project test count.

### 2026-11-14 — E3d5c5i Multi-Segment Straight Route Verification Staged (27 F6 Pending)

Added independent default-OFF multi-belt receiver guard with explicit one-time empty-path binding (2–64 straight segments). Both endpoints and every consecutive physical link must be reciprocal and aligned, same sandbox, no repeats, conflicting building ends, reversed links or cycles. Existing single-belt guard and legacy opt-out remain separate. Shared ConveyorTransportLink now snapshots valid origin before an ordinary conserved move and propagates the ordered weak-reference segment history only after successful physical forward transfer. A low-level buffer move does not carry history. A cargo mutation invalidates its stamp, and the protected receiver checks exact source and full pinned path at final delivery. This is in-process observation, not tamperproof or persistent item identity. No normal routing, inventory creation, auto-build or playable scene defaults changed.

Added `res://tests/sandbox_multi_belt_route_verification_e3d5c5i_test.tscn` with 27 A–AA checks pending F6. Three real straight segments carry test-seeded stock from an actual Storage output to a source-enrolled receiver; wrong source, repaired connections with wrong history, missing physical hop, misalignment, cyclic/nonreciprocal current chain, unbound/nonempty path and same-item cargo replacement are denied. Valid multi-hop delivery, escrow blocking and cancellation recovery are tested. Branching, corner route binding, persistent origin, live sandbox integration and automatic route placement remain outside scope. Require fresh single-belt, connected/timed transport and legacy logistics checks before accepting further shared changes.

### 2026-11-14 — E3d5c5i Multi-Segment Straight Route Verification Accepted (27/27)

Developer Godot 4.6.2 screenshot confirms **ALL 27 E3D5C5I MULTI BELT ROUTE VERIFICATION TESTS PASSED** (C–AA and aggregate visible; A/B above viewport). The isolated three-straight-segment path preserved original supplier and ordered physical hop history through successful timed transfers. Unbound/nonempty admission, duplicate/reversed/nonreciprocal paths, foreign cargo after reconnection, direct low-level buffer transfers, misalignment, cyclic or broken upstream chains, disabled bound guard and same-item replacement were rejected. Three verified ingots reached only their owned staging; escrow blocked the fourth and cancellation/recovery conserved stock. Main and committed normal sandbox behavior remain outside the opt-in receiver experiment. This does not validate every path length, corners, branching, persistent identity or gameplay automation.

**Required targeted compatibility gate (108 checks across nine F6 scenes, pending):**
- `res://tests/sandbox_single_belt_route_verification_e3d5c5h_test.tscn` — 26/26.
- `res://tests/conveyor_connected_transport_test.tscn` — 7/7.
- `res://tests/conveyor_timed_transport_test.tscn` — 8/8.
- `res://tests/conveyor_transport_buffer_test.tscn` — 7/7.
- `res://tests/conveyor_automatic_loading_test.tscn` — 10/10.
- `res://tests/conveyor_automatic_unloading_test.tscn` — 9/9.
- `res://tests/conveyor_splitter_test.tscn` — 10/10.
- `res://tests/conveyor_merger_test.tscn` — 10/10.
- `res://tests/blueprint_mined_owned_construction_e3d5c4t_test.tscn` — 21/21.

This gate targets shared transport/link behavior and legacy ports; it is not a full-project suite. Next proposed E3d5c5j: mixed straight/left/right corner route verification with actual endpoint geometry, exact segment identity and cargo history. No corner routing implementation is staged yet. Maintain the existing authorization, source ownership, escrow, default-off and resource conservation safeguards. Before live integration, still address cargo timer identity under externally manipulated buffers, source enrollment lifecycle, authenticated branching paths and save/load.

### 2026-11-14 — E3d5c5i Transport Regression Accepted (108/108)

Developer Godot screenshots confirm nine successful F6 suites: E3d5c5h 26/26, connected transport 7/7, timed transport 8/8, cargo buffer 7/7, automatic loading 10/10, automatic unloading 9/9, splitter 10/10, merger 10/10, and E3d5c4t mined-to-owned construction 21/21. All 108 targeted regressions passed; together with E3d5c5i 27/27, this records 135 successful outcomes, not a full project test total.

### 2026-11-14 — E3d5c5j Mixed Converted Corner Route Staged (29 F6 Pending)

Added a separate default-OFF corner route flag to the protected receiver, using the existing multi-belt path verifier and provenance propagation. Actual in-place corner conversion keeps the straight scene path; the validator now checks local marker position, opposite/orthogonal directions, and the runtime turn tag in addition to reciprocal world alignment. Bound paths also pin local marker transforms and the corner opt-in mode. A converted corner is refused by straight-only multi-belt mode; the single-belt path also refuses a tagged converted corner. No changes to shared conveyor transfers, placement, inventory, Main or sandbox scene defaults.

Added `res://tests/sandbox_corner_route_verification_e3d5c5j_test.tscn` with **29 pending F6 checks**. The fixture uses two actual in-place conversions (right and left) followed by a straight belt, preserving their original transport nodes. It checks default-off and wrong turn tag rejection, nonempty/invalid binding, marker change and repair, disabled corner flag, wrong supplier, low-level unstamped cargo, multi-hop timed delivery, broken/cyclic paths, escrow and cancellation conservation. The fixture positions predecessors using the actual corner template marker before calling the existing conversion; it does not change or prove automatic player route placement. The guard covers supported in-process geometry/identity observations, not arbitrary script tampering, all visual/collision geometry, splitters/mergers or durable save/load. Godot execution remains pending; rerun single/straight and existing corner conversion/full-chain suites after acceptance.

### 2026-11-14 — E3d5c5j Mixed Corner Route Verification Accepted (29/29)

Developer Godot 4.6.2 F6 screenshot confirms **ALL 29 E3D5C5J MIXED CORNER ROUTE VERIFICATION TESTS PASSED** (C–AC and aggregate visible; A/B above viewport). Actual in-place right and left corner conversions preserved segment identity and transport components. Straight-only mode rejected converted pieces; separate corner opt-in rejected mismatched turn tags, invalid or nonempty paths, changed marker geometry and disabled corner mode. Foreign cargo and low-level unstamped transfers could not enter protected staging. Valid timed cargo traversed both corners after alignment repair; broken/cyclic paths and replacement cargo were rejected. Three verified ingots reached only the intended site, escrow blocked the fourth, and cancellation/recovery conserved stock. Acceptance is confined to the isolated mixed-route fixture; playable defaults remain unchanged.

**Required focused regression gate (69 checks across four existing F6 scenes, pending):**
- `res://tests/sandbox_single_belt_route_verification_e3d5c5h_test.tscn` — 26/26.
- `res://tests/sandbox_multi_belt_route_verification_e3d5c5i_test.tscn` — 27/27.
- `res://tests/conveyor_corner_conversion_test.tscn` — 8/8.
- `res://tests/conveyor_full_chain_test.tscn` — 8/8.

The narrower gate is appropriate because E3d5c5j modified only the protected receiver and added its isolated test, without changing shared inventory, transport, or placement helpers. Next proposed E3d5c5k: isolated splitter provenance across actual input queue, round-robin distribution, and outgoing inventory, with exact source accounting, backpressure, and no bypass of protected receiver/escrow rules. Merger provenance remains a subsequent separate experiment. No branching changes are staged by this acceptance. Automatic route placement, live sandbox orchestration, durable cargo/claim identity, and save/load remain unimplemented.

### 2026-11-14 — E3d5c5j Corner Route Regression Accepted (69/69)

Developer screenshots confirm E3d5c5h 26/26, E3d5c5i 27/27, corner conversion 8/8 and full chain 8/8. All 69 targeted compatibility checks passed; combined with the 29 new mixed-route tests, 98 successful outcomes.

### 2026-11-14 — E3d5c5k Splitter Cargo Provenance Staged (16 F6 Pending)

Added default-OFF tracking on actual ConveyorSplitterComponent, requiring explicit configuration with empty original buffers. Real physical unload captures the incoming linear origin snapshot, per-item FIFO observations accompany successful round-robin inventory transfers, and the physical outgoing load records a separate splitter-crossing proof (source, upstream belt, exact splitter and output lane). External inventory API mutations invalidate observations for the affected buffer, leaving unknown items movable but unverified. Opting out during observed distribution clears ledger evidence and does not turn tracked outputs into fresh independent source stamps. No new item creation or scheduling. Ordinary default-OFF splitter behavior retains existing transfer policy.

The isolated `res://tests/splitter_cargo_provenance_e3d5c5k_test.tscn` has 16 A–P checks pending local F6: real Storage supplier and four splitter-connected belts, empty bind, three-lane round-robin, backpressure, distinct branch proof, denial of linear proof, unknown same-type FIFO, output and outgoing cargo mutation, two material types, toggle behavior and conservation. Scope is ONE splitter crossing to its first outgoing belts, not proof across subsequent belt hops, a full branch receiver path, merger provenance, route planning or persistent identity. Existing protected receiver verification is unchanged and does not admit the new splitter proof. Shared building transfer and splitter code changed, so a fresh ordinary splitter and logistics regression is required after acceptance. No playable scene defaults changed.

### 2026-11-14 — E3d5c5k Splitter Cargo Provenance Accepted (16/16)

Developer Godot 4.6.2 F6 screenshot confirms **ALL 16 E3D5C5K SPLITTER CARGO PROVENANCE TESTS PASSED**, A–P. A real Storage output fed the actual splitter input queue, with original source and lane identity preserved across three output buffers and onto their physically connected first outgoing belts. Round-robin distribution, full-buffer backpressure, independent material types, unknown same-type queue entries, inventory API replacement, outgoing cargo replacement and observed opt-out during distribution were exercised. Splitter proof remained distinct from direct/linear route proof. All seven ingots and two ore were conserved and the empty splitter was safe to remove. This accepts the isolated one-crossing fixture; it does not establish downstream splitter-proof propagation, protected branch receiver admission, multi-splitter or merger provenance, durable identity, or normal sandbox activation.

**Required targeted compatibility gate (115 checks across seven existing F6 scenes, pending):**
- `res://tests/conveyor_splitter_test.tscn` — 10/10.
- `res://tests/conveyor_merger_test.tscn` — 10/10.
- `res://tests/conveyor_automatic_loading_test.tscn` — 10/10.
- `res://tests/conveyor_automatic_unloading_test.tscn` — 9/9.
- `res://tests/sandbox_single_belt_route_verification_e3d5c5h_test.tscn` — 26/26.
- `res://tests/sandbox_corner_route_verification_e3d5c5j_test.tscn` — 29/29.
- `res://tests/blueprint_mined_owned_construction_e3d5c4t_test.tscn` — 21/21.

The gate addresses the shared physical building-transfer and transport stamp code and default-off splitter behavior. Proposed E3d5c5l: propagate the distinct splitter proof through subsequent reciprocal belt hops, bind an explicitly authorized receiver to an exact source-to-splitter-to-receiver branch, and test wrong lane, reconnection, unstamped cargo, broken links, escrow backpressure, and conservation. Do not reinterpret a splitter output as an independent original supplier for that branch. Merger provenance is a separate later experiment. No branch-admission implementation is staged by this documentation commit. Before enabling any normal gameplay, address feature disable/re-enable without intervening observed operations, multi-crossing proof, source lifecycle and durable recovery; the current tests only establish in-process observations under the exercised API operations.

### 2026-11-14 — E3d5c5k Splitter Compatibility Accepted (115/115)

All seven developer Godot F6 screenshots report passing aggregate results: splitter 10/10, merger 10/10, automatic loading 10/10, automatic unloading 9/9, single-belt E3d5c5h 26/26, mixed corners E3d5c5j 29/29, mined-to-owned construction E3d5c4t 21/21. All 115 targeted regressions passed; with 16 new splitter checks, 131 successful outcomes.

### 2026-11-14 — E3d5c5l Protected Splitter Branch Route Staged (26 F6 Pending)

Added distinct splitter proof propagation through the existing reciprocal/aligned belt transfer helper, retaining exact downstream segment history without promoting it to linear origin proof. The new default-OFF receiver branch guard binds once to one original factory output, one upstream straight belt, one explicitly configured splitter input/output pair and an empty ordered straight downstream path (1–64 segments). The receiver requires both current physical geometry and matching origin/lane/segment history, with ordinary ownership and escrow protections. It refuses competing route modes; no direct port transfer bypass. The splitter's ordinary distribution remains unchanged.

New `res://tests/sandbox_splitter_branch_route_e3d5c5l_test.tscn` has 26 A–Z pending checks using actual sandbox-created authorized Storage, existing Storage supplier, one splitter and two downstream straight belts. Tests cover exact binding, wrong source and reconnection, wrong-lane observation, low-level hop, broken reciprocity, cargo replacement, three legitimate deliveries, fourth-item escrow blocking and cancellation recovery. No scenes enabled, automatic routing, multi-crossing/merger proof, supplier sharing, charging, live construction or durable identity/save. Wrong-lane test uses a separate connected output, not a full lane-reconnection adversarial fixture. Provenance remains in-process and relies on exercised APIs, not protection against direct script mutation. Existing splitter proof, shared transport and protected route suites require regression after acceptance.

### 2026-11-14 — E3d5c5l Protected Splitter Branch Route Accepted (26/26)

Developer Godot 4.6.2 screenshot confirms **ALL 26 E3D5C5L SPLITTER BRANCH ROUTE TESTS PASSED** (B–Z and aggregate visible; A above viewport). The isolated real sandbox fixture exercised one incoming straight belt, one configured splitter, and two downstream straight belts leading to an explicitly authorized, source-enrolled Storage blueprint. Separate guard opt-ins, empty exact route binding, wrong-lane and reversed-path rejection, original foreign supplier history after reconnection, unstamped low-level buffer transfer, broken reciprocal links, feature toggle and same-type cargo replacement were exercised. Three verified ingots reached only the intended owned staging; escrow blocked the fourth and cancellation/refund/recovery conserved stock. The second independent site and ownership claims remained intact.

**Next required targeted compatibility gate (125 checks across seven existing F6 scenes, pending):**
- `res://tests/splitter_cargo_provenance_e3d5c5k_test.tscn` — 16/16.
- `res://tests/sandbox_single_belt_route_verification_e3d5c5h_test.tscn` — 26/26.
- `res://tests/sandbox_multi_belt_route_verification_e3d5c5i_test.tscn` — 27/27.
- `res://tests/sandbox_corner_route_verification_e3d5c5j_test.tscn` — 29/29.
- `res://tests/conveyor_connected_transport_test.tscn` — 7/7.
- `res://tests/conveyor_splitter_test.tscn` — 10/10.
- `res://tests/conveyor_merger_test.tscn` — 10/10.

This gate targets the shared physical belt transfer changes and competing receiver route modes, preserving ordinary splitter/merger operation. It is not a full project regression. Proposed E3d5c5m: isolated three-input merger cargo provenance, preserving exact original supplier, input lane and output identity through existing independent input buffers and the shared output queue. Exercise round-robin fairness, congestion, mixed and same-type cargo from distinct suppliers, API mutation invalidation, and conservation. Keep merger proof distinct from direct, linear and splitter proof; no protected merger-to-blueprint route admission until a separate experiment passes. No merger implementation is staged by this documentation commit.

Acceptance remains limited to one splitter crossing with a straight path and in-process observations. The wrong-lane test uses a separate connected output rather than a lane-reconnection adversarial case. Multi-splitter networks, mixed corner/branch paths, shared supplier reservations, automatic placement, live sandbox integration and persistent identity/save/load remain unverified or unimplemented.

### 2026-11-14 — E3d5c5l Splitter Branch Compatibility Accepted (125/125)

All seven developer Godot screenshots confirm E3d5c5k 16/16, E3d5c5h 26/26, E3d5c5i 27/27, E3d5c5j 29/29, connected transport 7/7, splitter 10/10 and merger 10/10. All 125 targeted regression checks passed, plus 26 new splitter branch checks (151 outcomes, not the full project suite).

### 2026-11-14 — E3d5c5m Merger Cargo Provenance Staged (18 F6 Pending)

Added independent default-OFF merger provenance to the real three-input merger, requiring explicit one-time configuration of empty pinned ports and inventories. Physical arrival snapshots preserve original linear source and exact incoming lane; per-item FIFO observations follow successful existing round-robin transfers to the one-unit shared output. The building-transfer helper records a distinct merger observation on the first outgoing belt, never promotes tracked unknown cargo to a new linear origin, and preserves normal opt-out transfer behavior. API mutations invalidate affected buffer observations. Feature opt-out changes a generation immediately, clearing ledgers and invalidating already-issued outgoing proof even during an off/on toggle without movement; fresh physical arrivals after re-enable can establish new observations. Ordinary physical distribution remains independent of proof.

Added `res://tests/merger_cargo_provenance_e3d5c5m_test.tscn` with 18 A–R checks pending Godot F6: three real Storage suppliers, identical ingots with distinct sources and lanes, congestion and fairness, unknown FIFO item, output and outgoing belt replacement, mixed material types, disable/re-enable with no movement, fresh proof, exact conservation of eight ingots and one ore, safe empty demolition. Scope is one merger crossing to its first outgoing belt, not downstream propagation, branch receiver admission, combined junction chains, production routing, live sandbox activation or save/load. No playable scene changes. Separate proof is an in-process observation under normal APIs, not tamperproof identity, and arbitrary field mutations remain outside its guarantees. Shared building-transfer code and legacy merger/splitter behavior require targeted regression after local acceptance.

### 2026-11-14 — E3d5c5m Merger Cargo Provenance Accepted (18/18)

Developer Godot 4.6.2 screenshot confirms **ALL 18 E3D5C5M MERGER CARGO PROVENANCE TESTS PASSED**, A–R. Three real independent suppliers fed identical ingots into independent merger input queues. Exact origin and lane remained distinguishable through round-robin distribution and shared-output backpressure. Unknown same-type cargo, external output-buffer and outgoing-belt replacement, mixed material types, and immediate off/on invalidation of both issued and queued evidence were exercised. Fresh physical arrivals after re-enable acquired fresh observations. Eight ingots and one ore were conserved exactly, and safe empty merger demolition disconnected all four links. The merger proof remained separate from direct, linear and splitter proof.

**Required targeted compatibility gate (128 checks across eight existing F6 scenes, pending):**
- `res://tests/conveyor_merger_test.tscn` — 10/10.
- `res://tests/conveyor_splitter_test.tscn` — 10/10.
- `res://tests/splitter_cargo_provenance_e3d5c5k_test.tscn` — 16/16.
- `res://tests/sandbox_splitter_branch_route_e3d5c5l_test.tscn` — 26/26.
- `res://tests/conveyor_automatic_loading_test.tscn` — 10/10.
- `res://tests/conveyor_automatic_unloading_test.tscn` — 9/9.
- `res://tests/sandbox_single_belt_route_verification_e3d5c5h_test.tscn` — 26/26.
- `res://tests/blueprint_mined_owned_construction_e3d5c4t_test.tscn` — 21/21.

These regressions target the changed shared building-transfer and cargo observation code, ordinary junction behavior and protected receiver compatibility. They are not a full project suite.

**Proposed E3d5c5n:** propagate merger-specific proof through subsequent physical belt hops and independently bind an authorized construction receiver to a verified original supplier, merger input lane, output and downstream path. Verify rejection of otherwise identical cargo from foreign suppliers, including after reconnection, and preserve such cargo for explicit recovery rather than destroying or silently redirecting it. A single-source protected receiver on a mixed-origin merger output may stall behind foreign cargo; this first route experiment should test that conservative backpressure behavior rather than assume automatic sorting or shared source allocation. Preserve existing priority, authorization, escrow, source ownership and default-off boundaries. No merger route implementation is staged by this documentation commit.

Acceptance remains limited to one merger crossing to its first outgoing belt and in-process API observations. Combined junction chains, automatic routing, live sandbox orchestration, metered charging and persistent save/load remain outside scope.

### 2026-11-14 — E3d5c5m Merger Compatibility Accepted (128/128)

Developer reported all eight local Godot F6 regression suites passed: merger 10/10, splitter 10/10, splitter provenance E3d5c5k 16/16, protected splitter branch E3d5c5l 26/26, automatic loading 10/10, automatic unloading 9/9, single-belt E3d5c5h 26/26, mined-to-owned construction E3d5c4t 21/21. All 128 targeted regression checks passed; with 18 new merger-provenance checks, 146 successful outcomes, not a full project test total. Acceptance is based on developer confirmation in the continuation chat, not independent execution or new screenshots. Next: isolated E3d5c5n protected merger route experiment; preserve default-off boundaries.

### 2026-11-14 — E3d5c5n Protected Merger Route Staged (28 F6 Pending)

Added distinct merger proof propagation over the existing reciprocal, aligned belt-transfer helper, carrying original supplier, selected input lane, merger epoch, output and ordered downstream history without treating junction stock as a fresh linear/splitter observation. Receiver binds once to one original supplier, one upstream straight belt, a configured merger lane/output and an empty straight downstream route (1–64 belts). The separate default-OFF guard rejects competing modes, retains original ownership and escrow checks and blocks direct port bypass even after a bound guard is disabled. No playable scene defaults changed.

New `res://tests/sandbox_merger_route_e3d5c5n_test.tscn` has 28 A–AB checks pending local Godot F6, including existing sandbox source discovery/authorization setup, exact empty binding, mixed-origin congestion, explicit inventory recovery, foreign source reconnection on the pinned lane, low-level unstamped transfer, broken reciprocity, guard toggle and merger epoch invalidation, same-type replacement, three accepted ingots, fourth-item escrow blocking, cancellation/refund and conservation. It uses real physical transfer helpers, not an autonomous timed gameplay run; automatic sorting, combined multi-crossing networks, general recovery UI and durable identity/save remain out of scope. No Godot runtime execution by assistant; acceptance and regressions remain pending.

### 2026-11-14 — E3d5c5n Protected Merger Route Accepted (28/28)

Developer Godot F6 screenshot confirms **ALL 28 E3D5C5N MERGER ROUTE VERIFICATION TESTS PASSED** (C–AB and aggregate visible; A/B above viewport), followed by debugger shutdown. The actual sandbox fixture demonstrated separate opt-in and empty route binding, rejection of wrong lane/reversed route/competing modes, foreign same-type cargo congestion with explicit conserved recovery, supplier reconnection on the same lane, rejection of unstamped low-level transfers, broken reciprocity, disabled guard and merger epoch invalidation, same-item replacement, three legitimate deliveries, fourth-item escrow backpressure, cancellation refund, conservation of nine ingots and nine ore, independent site protection and safe empty merger demolition. Acceptance is limited to one merger crossing and one pinned original source with a straight downstream path; direct physical helper tests do not establish autonomous timed gameplay, general recovery UI, automatic sorting or persistent identity.

**Required targeted compatibility gate (153 checks across eight existing F6 scenes, pending):**
- `res://tests/merger_cargo_provenance_e3d5c5m_test.tscn` — 18/18.
- `res://tests/sandbox_splitter_branch_route_e3d5c5l_test.tscn` — 26/26.
- `res://tests/sandbox_single_belt_route_verification_e3d5c5h_test.tscn` — 26/26.
- `res://tests/sandbox_multi_belt_route_verification_e3d5c5i_test.tscn` — 27/27.
- `res://tests/sandbox_corner_route_verification_e3d5c5j_test.tscn` — 29/29.
- `res://tests/conveyor_connected_transport_test.tscn` — 7/7.
- `res://tests/conveyor_merger_test.tscn` — 10/10.
- `res://tests/conveyor_splitter_test.tscn` — 10/10.

Gate targets modified shared belt forwarding, merger proof readiness, mutually exclusive receiver route guards and unchanged ordinary junction transport; not a full project regression. Proposed E3d5c5o: isolated splitter-to-merger composite cargo provenance, preserving an ordered two-junction history, original origin and both lane identities without minting a new source. Start with one straight inter-junction path and exact stock conservation; defer protected composite receiver admission, reverse junction order, automatic sorting, arbitrary graphs and gameplay integration until separate validation. No composite implementation staged by this acceptance commit.

### 2026-11-14 — E3d5c5n Merger Route Compatibility Accepted (153/153)

Developer confirmed all eight local Godot F6 regression suites passed: merger provenance 18/18, splitter branch 26/26, single-belt 26/26, multi-belt 27/27, mixed corners 29/29, connected transport 7/7, ordinary merger 10/10 and ordinary splitter 10/10. Together with the new 28-check route fixture, 181 successful targeted outcomes (not a full project suite). This regression acceptance is based on developer confirmation, not independent execution. Proceed to isolated E3d5c5o splitter-to-merger composite provenance.

### 2026-11-14 — E3d5c5o Splitter-to-Merger Composite Provenance Staged (18 F6 Pending)

Added separate default-OFF composite admission on the verified merger. One physically observed splitter crossing (one upstream straight-belt path in the fixture and one straight inter-junction belt) is nested in the merger observation without overwriting the original supplier, splitter input/output and belt history. Exact splitter and merger identities and merger input/output remain independently observable on the first merger output belt. Composite evidence cannot satisfy existing direct, linear, splitter or single-merger receivers; no composite forwarding beyond the first merger output belt is provided. Ordinary physical transfer/distribution remains independent of proof, and no playable scene defaults changed. Splitter tracking now advances an epoch immediately and invalidates old queued or issued proof on off/on, matching prior merger behavior. Changing the composite flag invalidates the merger's current observation generation. Composite-enabled merger rejects direct origin stamps minted at a junction rather than treating them as new original suppliers.

New `res://tests/splitter_merger_composite_provenance_e3d5c5o_test.tscn` has 18 A–R local F6 checks pending: separate defaults and empty binding, opt-out, direct supplier alongside composite supplier, round-robin/backpressure, both junction histories, refusal of existing proof modes, unstamped inter-junction cargo, splitter/merger/composite epoch toggles, same-type replacement, fresh observations, a second material type, exact six-ingot plus one-ore conservation and safe demolition. Explicit physical helper operations, not autonomous timed gameplay. The fixture uses one connected splitter output and two merger inputs; not a broad routing or adversarial geometry suite. No protected composite receiver, reverse order, general multi-crossing graph, automatic sorting, live gameplay or save/load. Requires Godot F6 acceptance and regression of both junction proof and existing protected route suites.

### 2026-11-14 — E3d5c5o Splitter-to-Merger Composite Provenance Accepted (18/18)

Developer confirmed all 18 local Godot F6 checks passed. Screenshot was unavailable due to the attachment upload limit; acceptance is based on developer-reported results, not independent execution or screenshot review. The isolated fixture covers distinct original supplier and nested junction history, separation from previous proof modes, mixed-origin congestion, unstamped cargo, epoch invalidation, same-type replacement, renewed observations, conservation and empty demolition. Scope remains one splitter, one merger, one connecting belt and first merger output belt only.

**Required targeted compatibility gate (141 checks across eight existing F6 scenes, pending):**
- `res://tests/splitter_cargo_provenance_e3d5c5k_test.tscn` — 16/16.
- `res://tests/merger_cargo_provenance_e3d5c5m_test.tscn` — 18/18.
- `res://tests/sandbox_splitter_branch_route_e3d5c5l_test.tscn` — 26/26.
- `res://tests/sandbox_merger_route_e3d5c5n_test.tscn` — 28/28.
- `res://tests/sandbox_single_belt_route_verification_e3d5c5h_test.tscn` — 26/26.
- `res://tests/conveyor_connected_transport_test.tscn` — 7/7.
- `res://tests/conveyor_splitter_test.tscn` — 10/10.
- `res://tests/conveyor_merger_test.tscn` — 10/10.

The gate targets changes to splitter epoch invalidation, merger admission and shared transport proof queries; it is not a full project regression. Proposed E3d5c5p: explicitly opt-in composite proof forwarding across downstream straight belts and independently bind a protected construction receiver to the exact source, splitter crossing, inter-junction belt, merger crossing and downstream path; preserve ownership, escrow and cancellation protections, fail closed on competing modes, and retain foreign cargo for explicit recovery. Reverse-order junctions, automatic sorting, live gameplay and persistent identity remain later work. No composite receiver implementation staged by this acceptance commit.

### 2026-11-14 — E3d5c5o Composite Provenance Compatibility Accepted (141/141)

Developer confirmed all eight local Godot F6 regressions passed: splitter provenance 16/16, merger provenance 18/18, protected splitter branch 26/26, protected merger route 28/28, single-belt route 26/26, connected transport 7/7, ordinary splitter 10/10 and ordinary merger 10/10. Combined with 18 new composite provenance checks, 159 targeted successful outcomes, not the full project suite. Acceptance is based on developer-reported results. Proceed to isolated E3d5c5p protected composite receiver and downstream forwarding.

### 2026-11-14 — E3d5c5p Protected Composite Route Staged (29 F6 Pending)

Added composite-specific proof propagation via the existing reciprocal, aligned physical belt helper. Preserves nested splitter history, merger epoch and ordered downstream straight-belt identities (1–64), rejecting repeated segments and raw buffer transfers. A new independent default-OFF receiver guard binds once to the enrolled factory origin, exact splitter input/output, single inter-junction belt, merger input/output and empty downstream route. Checks current reciprocal geometry, same sandbox, both junction readiness flags, exact historic cargo observations, existing site ownership, escrow and cancellation. Other route modes cannot replace a bound composite guard; direct intake remains closed if disabled. No playable scene default changes.

New `res://tests/sandbox_composite_route_e3d5c5p_test.tscn` has 29 A–AC local F6 checks pending. Uses real sandbox blueprint discovery, explicit authorization, one splitter, one merger, one connecting belt, two downstream straight belts and an independent foreign supplier. Covers wrong lane/reversed/nonempty binding, competing modes, foreign single-merger backpressure and explicit recovery, foreign composite origin after reconnection, raw buffer transfer, broken downstream and inter-junction geometry, guard opt-out, splitter/merger/composite epoch changes, same-type replacement, three legitimate ingots, fourth-item escrow blocking, cancellation refund, stock conservation and independent site protection. Uses explicit physical transfer helpers, not autonomous timing. Reverse merger-to-splitter order, arbitrary graphs, automatic sorting, player-facing recovery, gameplay orchestration and persistence remain outside scope. Godot execution and compatibility regression pending developer validation.

### 2026-11-14 — E3d5c5p Protected Composite Route Accepted (29/29)

Developer confirmed all 29 local Godot F6 checks passed. Acceptance is based on the developer's written confirmation, not independent execution or screenshot review. The isolated fixture covers separately enabled and exact empty route binding, wrong lanes, competing modes, foreign direct and composite cargo, recovery under congestion, original supplier reconnection, raw buffer movement, broken downstream and inter-junction connections, epoch invalidation, same-type replacement, three successful owned deliveries, fourth-item escrow protection, cancellation/refund, stock conservation and independent site protection. Scope remains one splitter followed by one merger with one inter-junction straight belt and a straight downstream path; no autonomous gameplay, automatic sorting or persistent identity.

**Required targeted compatibility gate (181 checks across nine existing F6 scenes, pending):**
- `res://tests/splitter_merger_composite_provenance_e3d5c5o_test.tscn` — 18/18.
- `res://tests/sandbox_splitter_branch_route_e3d5c5l_test.tscn` — 26/26.
- `res://tests/sandbox_merger_route_e3d5c5n_test.tscn` — 28/28.
- `res://tests/sandbox_single_belt_route_verification_e3d5c5h_test.tscn` — 26/26.
- `res://tests/sandbox_multi_belt_route_verification_e3d5c5i_test.tscn` — 27/27.
- `res://tests/sandbox_corner_route_verification_e3d5c5j_test.tscn` — 29/29.
- `res://tests/conveyor_connected_transport_test.tscn` — 7/7.
- `res://tests/conveyor_splitter_test.tscn` — 10/10.
- `res://tests/conveyor_merger_test.tscn` — 10/10.

Gate targets shared transport forwarding and mutually exclusive protected receiver modes, including ordinary junction behavior. This is not a full project regression. Proposed E3d5c5q: isolated reverse-order merger-to-splitter composite provenance, preserving original supplier, merger input/output, inter-junction belt and splitter output lane with distinct proof, epoch invalidation, mixed-origin fairness and conservation. Keep protected reverse-route receiver admission separate until provenance passes; no automatic sorting, arbitrary graphs, gameplay integration or save/load. No reverse-order implementation staged by this acceptance commit.

### 2026-11-14 — E3d5c5p Protected Composite Route Compatibility Accepted (181/181)

Developer confirmed all nine local Godot F6 regressions passed: composite provenance 18/18, protected splitter 26/26, protected merger 28/28, single-belt 26/26, multi-belt 27/27, mixed corners 29/29, connected transport 7/7, ordinary splitter 10/10 and ordinary merger 10/10. Together with 29 new composite route checks, 210 successful targeted outcomes, not a full project suite. Acceptance is based on developer-reported results. Proceed to isolated E3d5c5q reverse merger-to-splitter composite provenance.

### 2026-11-14 — E3d5c5q Reverse Merger-to-Splitter Composite Provenance Staged (18 F6 Pending)

Added independent default-OFF reverse composite admission on the tracked splitter. A verified single-merger crossing with one straight upstream belt and one straight inter-junction belt is nested in the splitter observation, preserving the original supplier, merger input/output, inter-junction belt and exact splitter input/output. Both junction epochs and the reverse feature flag must remain valid. Reverse proof is excluded from existing linear, splitter, merger and forward-composite proof queries, and is not forwarded beyond the first splitter output belt. Unknown cargo remains physically movable; ordinary distribution and playable scene defaults are unchanged.

New `res://tests/merger_splitter_reverse_composite_e3d5c5q_test.tscn` has 18 A–R local F6 checks pending with three real suppliers, one merger, one splitter and seven actual straight belts. Checks independent opt-ins, mixed-origin round-robin through both junctions, all three exact output identities, incorrect source/lane attribution, separation from existing proof, output congestion and recovery, unstamped inter-junction cargo, each epoch toggle, same-type replacement, fresh observations, second material type, seven ingots and one ore conservation and empty demolition. This uses explicit physical transfer helpers, not autonomous timing. Protected reverse receiver admission, downstream reverse proof forwarding, arbitrary junction graphs, automatic sorting, live gameplay and persistence remain outside scope. Godot execution and focused compatibility regression remain pending developer validation.

### 2026-11-14 — E3d5c5q Reverse Merger-to-Splitter Composite Provenance Accepted (18/18)

Developer confirmed all 18 local Godot F6 checks passed. Acceptance is based on written developer confirmation, not independent execution or screenshot review. Three original suppliers, mixed-origin round-robin distribution through both junctions, all three splitter output identities, distinct proof modes, backpressure and recovery, unknown cargo, epoch toggles, same-type replacement, fresh observations, exact material conservation and empty demolition passed in the isolated fixture. Scope is one merger then one splitter and first output belts only.

**Required targeted compatibility gate (162 checks across nine existing F6 scenes, pending):**
- `res://tests/splitter_cargo_provenance_e3d5c5k_test.tscn` — 16/16.
- `res://tests/merger_cargo_provenance_e3d5c5m_test.tscn` — 18/18.
- `res://tests/splitter_merger_composite_provenance_e3d5c5o_test.tscn` — 18/18.
- `res://tests/sandbox_splitter_branch_route_e3d5c5l_test.tscn` — 26/26.
- `res://tests/sandbox_merger_route_e3d5c5n_test.tscn` — 28/28.
- `res://tests/sandbox_composite_route_e3d5c5p_test.tscn` — 29/29.
- `res://tests/conveyor_splitter_test.tscn` — 10/10.
- `res://tests/conveyor_merger_test.tscn` — 10/10.
- `res://tests/conveyor_connected_transport_test.tscn` — 7/7.

Gate targets the modified splitter admission and shared cargo proof queries, both earlier junction orders, existing protected receiver behavior and ordinary physical transport. This is not a full project regression. Proposed E3d5c5r: separate default-OFF reverse composite downstream forwarding and exact protected receiver binding to one enrolled origin, merger input/output, inter-junction belt, splitter output and downstream path, retaining ownership, escrow, cancellation and competing-mode protections. Foreign materials remain physical and recoverable; no automatic sorting or arbitrary graphs. No new reverse receiver implementation staged by this acceptance commit. After reverse route validation, evaluate consolidation into one bounded general route model and integrated gameplay rather than proliferating specialized guards for every topology.

### 2026-11-14 — E3d5c5q Reverse Composite Compatibility Accepted (162/162)

Developer confirmed all nine local Godot F6 regression suites passed: splitter provenance 16/16, merger provenance 18/18, forward composite provenance 18/18, protected splitter 26/26, protected merger 28/28, protected forward composite 29/29, ordinary splitter 10/10, ordinary merger 10/10 and connected transport 7/7. With 18 new reverse provenance checks, 180 targeted successful outcomes, not a full project suite. Acceptance is developer-reported. Proceed to E3d5c5r protected reverse composite route.

### 2026-11-14 — E3d5c5r Protected Reverse Composite Route Staged (29 F6 Pending)

Added reverse-specific downstream straight-belt proof forwarding (1–64 distinct segments) via the same reciprocal, aligned physical transfer helper. Separate default-OFF receiver guard binds once to the enrolled original source, merger input/output, one connecting straight belt, splitter input/output and exact empty downstream path. Current geometry, sandbox ownership, both tracking epochs, reverse flag, existing staging ownership and escrow are checked. All previous protected modes and the new reverse guard exclude competing modes; disabling a bound guard cannot fall back to direct intake. No playable scene changes.

New `res://tests/sandbox_reverse_composite_route_e3d5c5r_test.tscn` has 29 A–AC local F6 checks pending, using the previously accepted sandbox setup, two suppliers, one merger, one splitter with one connected output branch, and two downstream belts. Includes wrong lane/reversed/nonempty binding, forward-composite and merger guard conflicts, foreign reverse cargo congestion/recovery, foreign origin after source reconnection, unstamped raw movement, broken geometry, both junction and reverse feature toggles, same-type substitution, three legitimate deliveries, fourth-item escrow refusal, cancellation/refund, exact conservation and independent site protection. Explicit physical transfers, not autonomous gameplay. No automatic sorting, arbitrary graphs, persistent identity, or live gameplay. Runtime acceptance and compatibility gate remain pending. Following acceptance, evaluate a bounded unified route model before further junction combinations.

### 2026-11-14 — E3d5c5r Protected Reverse Composite Route Accepted (29/29)

Developer confirmed all 29 local Godot F6 checks passed. Acceptance is based on written developer confirmation, not independent execution or screenshot review. The fixture exercised exact empty route binding, incompatible guard modes, wrong source and lane rejection, foreign reverse cargo congestion/recovery, source reconnection, raw movement without proof, broken geometry, both junction and reverse feature epochs, same-type replacement, three legitimate ingot deliveries, fourth-item escrow refusal, cancellation/refund, exact conservation and independent site protection. Scope remains one merger followed by one splitter with one connecting straight belt and straight downstream path, not autonomous timed gameplay.

**Required targeted compatibility gate (210 checks across ten existing F6 scenes, pending):**
- `res://tests/merger_splitter_reverse_composite_e3d5c5q_test.tscn` — 18/18.
- `res://tests/sandbox_composite_route_e3d5c5p_test.tscn` — 29/29.
- `res://tests/sandbox_splitter_branch_route_e3d5c5l_test.tscn` — 26/26.
- `res://tests/sandbox_merger_route_e3d5c5n_test.tscn` — 28/28.
- `res://tests/sandbox_single_belt_route_verification_e3d5c5h_test.tscn` — 26/26.
- `res://tests/sandbox_multi_belt_route_verification_e3d5c5i_test.tscn` — 27/27.
- `res://tests/sandbox_corner_route_verification_e3d5c5j_test.tscn` — 29/29.
- `res://tests/conveyor_connected_transport_test.tscn` — 7/7.
- `res://tests/conveyor_splitter_test.tscn` — 10/10.
- `res://tests/conveyor_merger_test.tscn` — 10/10.

Gate targets shared forwarding and all prior protected receiver modes plus basic junction distribution; not a full project regression. Proposed E3d5c5s: unified bounded route descriptor and read-only validation in an isolated test harness. Represent original source, ordered belts and junction crossings with exact ports; validate reciprocal alignment, repeated-node rejection, finite length and known route shapes. Start with parity against already accepted routes; do not replace live proof mechanisms, mint cargo stamps, mutate inventories, modify escrow, or enable gameplay. Use the accepted legacy tests as a reference baseline. Follow with compatibility adapter and incremental migration only after parity. Avoid creating new specialized guard variants for every topology. No unified implementation staged by this acceptance commit.

### 2026-11-14 — E3d5c5r Protected Reverse Route Compatibility Accepted (210/210)

Developer confirmed all ten local Godot F6 regression suites passed: reverse provenance 18/18, forward composite route 29/29, protected splitter 26/26, protected merger 28/28, single-belt 26/26, multi-belt 27/27, mixed corners 29/29, connected transport 7/7, ordinary splitter 10/10 and ordinary merger 10/10. Together with 29 new reverse route checks, 239 targeted successful outcomes, not a full project suite. Acceptance is developer-reported. Proceed to E3d5c5s isolated read-only unified route descriptor and structural validator.

### 2026-11-14 — E3d5c5s Unified Factory Route Descriptor Staged (28 F6 Checks Pending)

Added isolated `scripts/components/unified_factory_route_descriptor.gd`: one read-only RefCounted descriptor with weak references to exact original supplier, receiver, inventories, sandbox scope, ordered actual conveyor nodes and junction input/output ports. Validates reciprocal, aligned physical links, straight or legitimately converted corner marker geometry, exact local marker poses, same-scope ownership, real junction lane inventory identity and finite nonrepeating path. Initial envelope deliberately matches accepted shapes: up to 64 belts in the final run, one entry belt before a junction, one intermediate belt between at most two different junction types, 66 belts total, corners only in non-junction routes. No automatic path discovery, new cargo proof, authorization, reservation, inventory mutation, persistent identity, receiver replacement or gameplay integration. A structure-valid route alone does not prove that cargo is eligible. The descriptor does not call junction provenance readiness methods, which can mutate observation ledgers; existing guarded receiver methods remain the authority.

New `res://tests/unified_factory_route_verification_e3d5c5s_test.tscn` builds seven separate real sandbox fixtures using accepted legacy test setup: single belt, multi-belt, mixed left/right corners, splitter, merger, forward composite and reverse composite. Four labeled groups per fixture (28 total) compare valid structural paths with bound legacy verification; reject empty, wrong-source, repeated, oversized, reversed and malformed paths where applicable; compare broken connection/misalignment and recovery; check read-only inventory revisions, existing site state and invalidation after deletion. Each fixture must return true before aggregate success prints. This is structural parity for selected positive/negative cases, not full proof or authorization parity. No existing production scripts or scenes changed. Godot import/parse and F6 execution remain pending developer validation. After acceptance, evaluate a read-only adapter to existing cargo proof queries and then carefully migrate guarded receiver behavior with differential tests.

### 2026-11-15 — E3d5c5s Unified Structural Route Verification Accepted (28/28)

Developer confirmed all 28 local Godot F6 labeled check groups passed across seven real sandbox route fixtures. Acceptance is based on written developer confirmation, not independent execution. Selected structural parity, invalid path rejection, broken links and misalignment, state preservation and weak-reference invalidation passed. Existing guards remain authoritative. Because this stage added only isolated files and changed no production code, proceed to E3d5c5t read-only legacy cargo provenance adapter; defer broad regression until production integration. No authorization or stock movement is granted by the descriptor.

### 2026-11-15 — E3d5c5t Unified Legacy Cargo Provenance Adapter Staged (42 F6 Groups Pending)

Extends the isolated descriptor with matches_legacy_cargo(belt, item). Requires currently valid captured structural path, exact final belt and held item, then derives entry, ordered downstream belt run and exact crossed junction ports from the descriptor and dispatches to the existing direct, linear, splitter, merger, forward-composite or reverse-composite proof query. No new provenance stamp, cargo transfer, receiver admission, automatic authority, inventory mutation, escrow or gameplay integration. The adapter is observational with respect to physical stock and construction state; existing junction readiness/proof queries may clear invalid observation ledgers as before. It deliberately does not claim receiver eligibility: valid provenance can coexist with a disabled receiver guard, locked escrow or canceled job. Production receiver logic remains the authority.

New `res://tests/unified_cargo_provenance_adapter_e3d5c5t_test.tscn` builds the seven accepted sandbox route fixtures, with six labeled test groups per route (42 total). Covers empty and injected cargo, genuine physical full-route proof and unchanged inventory revisions, wrong item/final belt, foreign original source after restored geometry, broken geometry and same-item replacement, guard-off independence and each crossed junction epoch, three real deliveries, escrow refusal of a fourth, cancellation/refund and exact conservation with independent site intact. Real helper transfers, not autonomous timing. Each fixture must return success before aggregate pass. No existing production transfer or receiver scripts changed; only the isolated descriptor and new harness. Godot parse/runtime acceptance pending. Next evaluate an explicitly gated receiver adapter integration with differential results and existing route modes preserved; broad regressions before integration acceptance.

### 2026-11-15 — E3d5c5t Unified Legacy Cargo Provenance Adapter Accepted (42/42)

Developer confirmed all 42 local Godot F6 labeled check groups passed across seven real sandbox route fixtures. Acceptance is based on written developer confirmation, not independent execution. Valid full-route proof, invalid/foreign cargo refusal, unchanged stock revisions, geometry, same-type replacement, epoch invalidation, receiver guard independence, escrow/refund and conservation passed. Only isolated components and tests changed; proceed to E3d5c5u default-off receiver integration with existing authorization, source pinning and escrow remaining authoritative. Broad compatibility checks required before integration acceptance.

### 2026-11-15 — E3d5c5u Unified Receiver Integration Staged (49 F6 Groups Pending)

Adds default-OFF enable_isolated_unified_route_adapter and explicit one-time bind on the existing anchored construction receiver. Binding derives the descriptor exclusively from the already pinned and currently verified legacy route and enrolled source: no caller-supplied replacement identities. Requires authorized owned site, existing escrow/source guards, no competing route selection, empty single-capacity conveyor buffers and empty crossed junction buffers. With the adapter enabled and bound, physical intake requires both the unchanged legacy admission decision and the captured descriptor's cargo proof. Enabled but unbound and bound but disabled states fail closed; conflicting modes and direct port intake are refused. Default-off never-bound behavior remains on the legacy path. No automatic route creation, new stamps, authority, reservations, transfers, live gameplay activation or playable scene changes. Existing legacy query cleanup behavior remains. This is deliberately a dual-verification migration step, not removal of the legacy route modes.

New `res://tests/unified_receiver_integration_e3d5c5u_test.tscn` has seven labeled check groups per seven real route arrangements (49 groups). Reuses the accepted E3d5c5t fixtures with explicit integration checks for default-off compatibility, no independently created route, unbound and nonempty binding refusal, competing modes, exact one-time binding, genuine cargo accepted by both, bound opt-out denial, foreign and stale proof refusal, geometry failure, same-type substitution, epoch invalidation, ownership, escrow blocking, actual deliveries and cancellation/refund with exact resource conservation. Each case must return true before aggregate success. Godot parse/runtime and broad regression validation pending. This stage changes the production receiver script, so after 49/49 local acceptance require targeted legacy and unified regression suites before considering further migration or gameplay integration.

### 2026-11-15 — E3d5c5u Unified Receiver Integration Local Acceptance (49/49)

Developer confirmed all 49 Godot F6 labeled check groups passed across seven layouts. Acceptance is based on written developer confirmation, not independent execution. Explicit binding, default-off compatibility, no unbound intake, competing modes, bound opt-out denial, genuine and foreign cargo, geometry, epochs, substitution, actual authorized delivery, escrow/cancellation and stock conservation passed in the integration fixture. Full milestone compatibility remains pending.

**Required targeted compatibility gate: 401 labeled checks across 16 existing scenes (pending).** Scene paths verified against the main repository tree and expected totals verified against each test script's final success message.

**Unified verification — 70 checks**
- `res://tests/unified_factory_route_verification_e3d5c5s_test.tscn` — 28/28.
- `res://tests/unified_cargo_provenance_adapter_e3d5c5t_test.tscn` — 42/42.

**Specialized protected routes — 194 checks**
- `res://tests/sandbox_single_belt_route_verification_e3d5c5h_test.tscn` — 26/26.
- `res://tests/sandbox_multi_belt_route_verification_e3d5c5i_test.tscn` — 27/27.
- `res://tests/sandbox_corner_route_verification_e3d5c5j_test.tscn` — 29/29.
- `res://tests/sandbox_splitter_branch_route_e3d5c5l_test.tscn` — 26/26.
- `res://tests/sandbox_merger_route_e3d5c5n_test.tscn` — 28/28.
- `res://tests/sandbox_composite_route_e3d5c5p_test.tscn` — 29/29.
- `res://tests/sandbox_reverse_composite_route_e3d5c5r_test.tscn` — 29/29.

**Receiver lifecycle and authority — 137 checks**
- `res://tests/blueprint_anchored_receiver_e3d5c4i_test.tscn` — 16/16.
- `res://tests/sandbox_player_blueprint_delivery_e3d5c5b_test.tscn` — 20/20.
- `res://tests/sandbox_escrow_intake_lock_e3d5c5c_test.tscn` — 24/24.
- `res://tests/sandbox_authorization_receiver_autowire_e3d5c5d_test.tscn` — 19/19.
- `res://tests/sandbox_output_source_enrollment_e3d5c5e_test.tscn` — 18/18.
- `res://tests/sandbox_factory_source_validation_e3d5c5f_test.tscn` — 20/20.
- `res://tests/sandbox_factory_supplier_discovery_e3d5c5g_test.tscn` — 20/20.

This gate targets both unified descriptor/adapter behavior and existing default-off receiver admission, source ownership, discovery, escrow and authorization lifecycle. It is not a full project regression; standalone transport/provenance scripts were unchanged this stage. On reported compatibility success, record acceptance and proceed to E3d5c5v: consolidate the opt-in receiver admission path to share common descriptor-driven verification while preserving authoritative ownership, escrow, one-time exact route binding, route-mode conflicts, default-off behavior and fail-closed rollback. Retain baseline legacy path for differential tests; do not expand supported graphs or activate normal gameplay in that step. No E3d5c5v code staged by this acceptance commit.

### 2026-11-15 — E3d5c5u Unified Receiver Compatibility Accepted (401/401)

Developer confirmed all 16 local Godot F6 regression suites passed: unified structural verification 28/28, cargo adapter 42/42, seven specialized protected route suites 194/194, and seven receiver lifecycle/authority suites 137/137. Combined with 49 integration check groups, 450 targeted successful outcomes, not a full project suite. Acceptance is based on developer-reported results. Proceed to E3d5c5v opt-in unified receiver consolidation with the legacy comparison path preserved.

### 2026-11-15 — E3d5c5v Unified Receiver Consolidation Staged (56 F6 Groups Pending)

Adds independent default-OFF enable_isolated_unified_receiver_consolidation on the anchored receiver. The strategy is selected at the existing explicit one-time empty-route adapter binding and pinned for its lifetime. When consolidated intake is selected, retain authoritative legacy route readiness (including exact mode, geometry and junction readiness), source/ownership/site checks and escrow/capacity protections, but perform the cargo proof dispatch only through the bound unified descriptor. The earlier dual-verification and default-off legacy paths remain available for receivers bound to those strategies or never bound, respectively. Changing the strategy flag after binding fails closed instead of falling back; restoring the originally selected flag restores eligibility only if all other checks still pass. No direct intake, implicit authority, new cargo stamps, new route shapes, gameplay activation or playable scene changes. This consolidates duplicate cargo-query execution, not the legacy route bindings/readiness functions or topology-specific provenance implementation.

New `res://tests/unified_receiver_consolidation_e3d5c5v_test.tscn` has eight labeled check groups per seven real layouts (56). Reuses accepted integration fixtures and adds consolidated default-off behavior, consolidation-only refusal on otherwise owned second receiver, pinned strategy selection, fail-closed strategy toggle with actual unload refusal, genuine cargo admission after restoring selected strategy, legacy comparison for applicable accepted and denied cargo cases, source/geometry/epoch/substitution checks, authorized delivery, escrow, cancellation and conservation. Each fixture must return true before aggregate success. Runtime validation pending developer execution; production receiver script changed, so targeted compatibility verification is required after local acceptance. No further route expansion or gameplay changes staged.

### 2026-11-15 — E3d5c5v Unified Receiver Consolidation Local Acceptance (56/56)

Developer confirmed all 56 local Godot F6 labeled check groups passed across seven real sandbox route arrangements. Acceptance is based on written developer confirmation, not independent execution. Consolidated cargo-query dispatch, retained legacy route readiness and ownership checks, pinned strategy and fail-closed flag changes, foreign/stale cargo, geometry, epoch invalidation, escrow, cancellation and conservation passed in the fixture. Compatibility acceptance remains pending.

**Required targeted compatibility gate: 450 checks across 17 existing F6 scenes (pending).** Paths verified against main's repository tree and totals verified against each test script's aggregate success message.

**Unified structural, cargo and dual receiver — 119 checks**
- `res://tests/unified_receiver_integration_e3d5c5u_test.tscn` — 49/49.
- `res://tests/unified_factory_route_verification_e3d5c5s_test.tscn` — 28/28.
- `res://tests/unified_cargo_provenance_adapter_e3d5c5t_test.tscn` — 42/42.

**Specialized protected routes — 194 checks**
- `res://tests/sandbox_single_belt_route_verification_e3d5c5h_test.tscn` — 26/26.
- `res://tests/sandbox_multi_belt_route_verification_e3d5c5i_test.tscn` — 27/27.
- `res://tests/sandbox_corner_route_verification_e3d5c5j_test.tscn` — 29/29.
- `res://tests/sandbox_splitter_branch_route_e3d5c5l_test.tscn` — 26/26.
- `res://tests/sandbox_merger_route_e3d5c5n_test.tscn` — 28/28.
- `res://tests/sandbox_composite_route_e3d5c5p_test.tscn` — 29/29.
- `res://tests/sandbox_reverse_composite_route_e3d5c5r_test.tscn` — 29/29.

**Receiver lifecycle and authority — 137 checks**
- `res://tests/blueprint_anchored_receiver_e3d5c4i_test.tscn` — 16/16.
- `res://tests/sandbox_player_blueprint_delivery_e3d5c5b_test.tscn` — 20/20.
- `res://tests/sandbox_escrow_intake_lock_e3d5c5c_test.tscn` — 24/24.
- `res://tests/sandbox_authorization_receiver_autowire_e3d5c5d_test.tscn` — 19/19.
- `res://tests/sandbox_output_source_enrollment_e3d5c5e_test.tscn` — 18/18.
- `res://tests/sandbox_factory_source_validation_e3d5c5f_test.tscn` — 20/20.
- `res://tests/sandbox_factory_supplier_discovery_e3d5c5g_test.tscn` — 20/20.

This gate repeats the receiver-facing suites because the receiver script changed; includes the previously accepted dual-verification integration to ensure its strategy remains available. No standalone transport/provenance scripts changed. This is not a full project regression. On success record compatibility acceptance and proceed to E3d5c5w playable sandbox construction logistics bridge: explicitly gated, bounded player-placed route enrollment into the consolidated receiver, using existing supported layouts and real conveyor movement. Begin with one simple known route and actual player blueprint authorization; retain legacy modes and all ownership, escrow, worker/power readiness and cancellation protections. Do not expand arbitrary junction graphs or activate main gameplay yet. Inspect existing sandbox APIs and choose a minimal playable slice before coding. No E3d5c5w implementation staged by this commit.

### 2026-11-15 — E3d5c5v Consolidated Receiver Compatibility Accepted (450/450)

Developer confirmed all 17 local Godot F6 regression suites passed: unified structural 28/28, cargo adapter 42/42, dual receiver 49/49, seven specialized protected routes 194/194, seven receiver lifecycle/authority suites 137/137. Combined with 56 consolidation groups, 506 targeted successful outcomes, not a full project suite. Acceptance is developer-reported. Proceed to E3d5c5w bounded playable sandbox construction logistics.

### 2026-11-15 — E3d5c5w Playable Sandbox Construction Logistics Staged (12 F6 Checks + Manual Demo Pending)

Adds separate launcher scene `res://scenes/core/playable_construction_logistics_demo.tscn` which explicitly starts the existing Factory Testing Sandbox as the actual current scene and attaches a new isolated tutorial controller. Neither the normal sandbox nor Main scene is changed. In this one instance, disable the debug requirements bypass and planned-port snapping/reservations so a real receiver and live belt can be used. Create an explicitly labeled Test Storage starter fixture at (-5,0,4) with four seeded test ingots; its demo-specific output refuses release before the exact route is enrolled. No manufactured supply beyond the declared starter stock, automatic authority, worker, power or readiness. Cyan footprint marks (-5,0,0); green tile marks (-5,0,2). Default rotation: Storage input faces starter, belt moves toward negative Z. Player enters B, selects Storage (default slot 3), P plan mode, places blueprint at cyan center, clicks Prepare (or F7 while hovering), hovers plan and presses existing E authorization, turns P off and selects Conveyor (default slot 5), places one straight belt snapped to starter OUT facing toward plan, clicks Bind (or F8 in standalone play). Existing player placement creates the belt; binding only connects its aligned free terminal endpoint and enrolls the authorized receiver's empty straight route into the consolidated adapter. Real process-driven conveyor timer then delivers three ingots, one extra remains on blocked belt. HUD counts supply/belt/staging. Site stays QUEUED waiting for actual readiness. X cancels via existing controls; no automatic recovery or completion. Non-colliding guides and panel only in this separate scene.

Dedicated `res://tests/playable_construction_logistics_e3d5c5w_test.tscn` exercises 12 labeled groups: untouched entry scenes, explicit startup, counted locked supply, real world-created plan and authorization, wrong placement refusal, empty live belt, one-time route binding, actual frame-driven automatic transport, fourth-item backpressure, escrow, cancellation/refund, conservation and independent site. Test uses existing world methods and physical snap helpers, not GUI event simulation; manual launcher interaction also required. Godot import/parse/runtime and manual usability not independently verified. Fixed single route and demonstration stock are deliberate scope constraints. No broader network, automatic supplier selection, persistent save, drone or power integration yet.

### 2026-11-15 — E3d5c5w Automated Acceptance (12/12); Manual Clarification Pending

Developer reported all 12 automated Godot checks passed. Manual interaction reportedly worked except E did not build the blueprint. This could be expected: E authorizes PLANNED to QUEUED; the demo deliberately disables debug readiness and provides no power or worker, so even fully delivered materials cannot complete construction. Manual acceptance remains pending confirmation that E actually queued the plan, Bind succeeded, and final HUD counts were starter 0, belt 1, staging 3/3. If E failed to authorize at all, investigate input/hover and focus separately. No code change or automatic readiness bypass at this stage. Developer-reported validation only.

### 2026-11-15 — E3d5c5w Manual Binding Diagnostic Patch (Retest Pending)

Developer screenshot confirms QUEUED blueprint but Bind refused; HUD starter 4, belt 0, staging 0/3. Exact failing precondition was not captured by the old generic message. Tutorial panel moved below the blueprint summary; shows preparation/authorization/binding phase and distinct refusal reasons echoed in Output. Marked footprint check tolerates tiny ground-ray position error (25 mm), retains exact definition/default rotation and never moves a site. Explicit Bind can connect exactly one existing committed, empty, isolated straight belt with both endpoints aligned if normal source snapping did not connect it. No new belt, movement, authorization, geometry relaxation, cargo stamp, or readiness bypass. Existing receiver checks, source lock, and consolidation still required. Automated fixture now exercises actual button callbacks including aligned unsnapped recovery. Previous 12/12 result pertains to pre-patch code; rerun all 12 and manual demo before acceptance. Root cause remains unconfirmed until diagnostic retest.

### 2026-11-15 — E3d5c5w Post-Cancellation HUD Lifetime Fix (13 Checks Pending)

Developer screenshot shows automated run stopping in demo _process at _live(site), with a previously freed object rejected at the typed Node parameter boundary. Screenshot locals show starter 0 and delivered 3; not full test acceptance. Changed tutorial-only _live argument to Variant and check validity before Node methods. Explicit one-time preparation and binding latches prohibit reenrollment even after node deletion. Ended-site HUD retains inventory counters and reports restart required. Added group M: wait for two frames following cancellation, verify actual site deletion, safe HUD refresh and retained 0/1/3 counts, no further enrollment. Aggregate expected total is now 13. No production component, normal scene, cargo geometry or resource rules changed. Runtime and manual binding retest still pending.

### 2026-11-15 — E3d5c5w Manual Physical Delivery Verified

Developer screenshots confirm the marked Storage blueprint was successfully prepared while PLANNED, authorized via E to QUEUED, followed by player placement of a straight conveyor and explicit Bind. Final screenshot shows Route bound; Starter 0 | Belt 1 | Staged 3/3; one queued blueprint at 0% progress. Developer observed three cargo visuals traveling into the construction receiver and one remaining on the belt. This confirms the intended manual construction logistics delivery workflow and conservation of four starter ingots. Power and worker remain deliberately absent; construction does not begin. Earlier manual bind refusal occurred before successful preparation; final correctly sequenced run succeeded. Full post-patch acceptance still requires explicit 13/13 automated rerun confirmation and manual cancellation/HUD retention verification. No new implementation in this entry.

### 2026-11-15 — E3d5c5w Manual Cancellation Verified

Developer screenshots show BLUEPRINT CANCELLED in Output, no remaining planned/queued/building/paused jobs, removed orange blueprint and responsive Site ended HUD. Counts remain Starter 0 | Belt 1 | Staged 3/3: all four starter ingots accounted for, with no further construction intake. No errors are visible in the supplied Output excerpt; this is not an independent check of the full debugger log. Manual delivery and cancellation objectives accepted. Latest 13/13 automated suite confirmation following the HUD lifetime fix remains pending; the earlier 12/12 result predates that fix. Next planned milestone after confirmation: isolated playable power and construction worker integration using the existing verified readiness services, without debug bypass or main gameplay activation.

### 2026-11-15 — E3d5c5x1 Playable Construction Power Staged (9 Check Groups + Manual Test Pending)

Developer requested proceeding with power testing. E3d5c5w manual delivery and cancellation accepted; explicit latest 13/13 automated rerun still pending and not assumed. Added separate `res://scenes/core/playable_construction_power_demo.tscn` launcher and controller extending the existing isolated logistics tutorial, with completed prototype Hub at (2,0,-3), Pole at (-3,0,0), existing graph and finite allocator. Initial generator OFF, link OPEN; explicit controls toggle generation, link, and demonstration rating 12/5. Site demand 7 prototype units, whole footprint outside Hub coverage but inside relay coverage. The actual finite allocator determines power availability for the one authorized owned site only; material/worker availability remain false until coordinated escrow/worker integration. No construction completion, power charging, worker, escrow reservation or debug override. Existing tutorial, normal sandbox, Main and production components unchanged. New test `res://tests/playable_construction_power_e3d5c5x1_test.tscn` covers 9 groups: explicit startup, planned authorization protection, disconnected Hub, full connected grant, undercapacity, generator/link outage, real cargo and queued job with worker/escrow unavailable, relay failure, cancellation with allocation released and inventory conserved. Runtime and manual checks pending. This is prototype nameplate allocation, not fuel or metered electrical simulation. Next integrate verified coordinator and worker only after power verification.

### 2026-11-15 — E3d5c5x1 Automated Power Acceptance (9/9)

Developer confirmed all nine local Godot F6 power test groups passed. Automated startup, planned/authorized distinction, disconnected Hub, 7-unit allocation, undercapacity, generator/link outages, physical material delivery, relay failure and cancellation passed by developer report. Manual power demo verification remains pending. Proceed with manual preparation and authorization, generator on with link open, connected allocation, capacity reduction/restoration, outage and recovery; no worker or escrow readiness grant. Previous E3d5c5w 13-check rerun remains unconfirmed. No new production changes in this entry.

### 2026-11-16 — E3d5c5x1 Playable Construction Power Manual Acceptance

Developer confirmed 9/9 automated local Godot checks previously. Manual screenshots show prepared authorized queued Storage with generator off and open link, online 12-unit Hub without relay allocation, physical Hub/Pole link, reduced 5-unit generation with energized relay but 0/7 site grant, restored 12-unit generation with 7/7 grant, generator off/on with connected link and 0/7 then 7/7 grant. Developer confirmed disconnect/reconnect test verbally. Combined live logistics screenshot confirms bound route, starter 0, belt 1, staged 3/3, output 12, relay energized, allocation 7/7, queued site. Final cancellation screenshot confirms no remaining planned/queued/building/paused jobs, site ended HUD, output 12, relay energized, connected link, allocation 0/7, and unchanged inventory 0/1/3. All manual power objectives accepted; no independent Godot execution or full debugger review. No worker or escrow readiness was granted. Earlier E3d5c5w latest 13-check rerun remains explicitly unconfirmed; do not infer from later manual tests. Next proposed E3d5c5x2: isolated playable construction drone dispatch and coordinated readiness/escrow; inspect existing worker and lifecycle APIs before implementation, retain power interruption, material conservation, explicit authorization, and normal gameplay defaults. No new implementation staged in this entry.

### 2026-11-16 — E3d5c5x2 Playable Construction Drone Staged (11 Check Groups + Manual Test Pending)

Separate launcher `res://scenes/core/playable_construction_drone_demo.tscn` extends the accepted power/logistics tutorial with one visible prototype drone at the Hub, 40 initial battery units, 2 units/s flight, 2-unit hover and one finite worker slot. Uses existing site-owned staging registry, escrow, finite allocator, readiness coordinator, scheduler, fleet and sandbox tick gate. Enrollment occurs only for the explicitly prepared, E-authorized, consolidated-route-bound tutorial site; all original readiness gates must be missing when admitted. The power-only tutorial now delegates its unchanged direct observation code to an overridable hook; drone tutorial instead delegates all job readiness to coordinator. Site self-processing disabled only on enrolled site; driver ticks bounded to 0.1 seconds per frame and refreshes progress visuals separately. No second construction clock. Real conveyor delivery fills actual bill, coordinator reserves 3 ingots, finite 7-unit allocation plus escrow permits physical dispatch, arrival grants worker readiness, job advances using existing 10-second definition. Generator outage pauses progress, restores resume, completion activates real Storage and commits bill; cancel refunds same owned staging. Extra ingot remains in source or belt depending on frame order; no automatic final belt handoff, recovery UI, charge provider or drone reuse. Hub stock stays empty. Drone returns home on completion/cancel; existing gate passes false for charging. No Main or normal sandbox scene edits, no production component changes.

New `res://tests/playable_construction_drone_e3d5c5x2_test.tscn` has 11 groups: gated startup, planned/empty refusal, one clock, real timed material delivery with no power, escrow and dispatch, metered travel and arrival, outage pause, exact progress resume, completed building/escrow/power and surplus conservation, post-deletion return with no charge, separate in-flight cancellation/refund. Test drives same frame callback with deterministic 0.1-second steps; conveyor uses actual frame timing. Godot parse/runtime and manual usability remain pending. Rerun E3d5c5x1 9 checks after shared tutorial hook change; earlier E3d5c5w 13-check rerun still not explicitly confirmed, request it as part of compatibility gate. Fixed single-site/straight-line flight demonstration, not general routing, battery charging or live main-game integration.

### 2026-11-16 — E3d5c5x2 Playable Drone Automated Acceptance (33/33)

Developer explicitly confirmed all three local Godot F6 suites passed: E3d5c5x2 playable construction drone 11/11, E3d5c5x1 playable construction power 9/9, E3d5c5w playable construction logistics 13/13. Combined 33/33 targeted checks; not full project regression. This closes the outstanding E3d5c5w post-cancellation HUD rerun. Automated acceptance is developer-reported, not independently executed. Earlier manual logistics and power acceptance remain valid. E3d5c5x2 manual verification pending: launch separate drone tutorial, prepare then E-authorize marked Storage, establish power and real straight-belt route, verify owned escrow and dispatch, physical arrival before progress, interrupt/restore power during construction, verify completed real Storage and committed bill, released power and conserved surplus, drone return and no fabricated charging; separate cancellation run to verify refund and return. No code changes or main gameplay activation in this entry.

### 2026-11-16 — E3d5c5x2 Manual End-to-End Construction Verified

Developer reported successful manual construction. Sequential screenshots confirm prepared and authorized Storage with drone idle at 40/40 battery, connected 12-unit Hub and energized relay without allocation before reservation, physical drone at the green constructing blueprint, and final COMPLETE / building activated / 100% with actual completed Storage visible. Final HUD shows DOCKED at Hub, battery 24.8/40, escrow 0/3, starter 1, belt 0, staged 0/3, all construction queue counts zero, generation 12, relay energized, connected link and released allocation 0/7. Three ingots consumed by construction and one surplus accounted for in source; no invented charging. Exact intermediate launch/escrow timing not separately captured in manual screenshots. 33/33 automated acceptance remains recorded. Manual power interruption/resume and separate cancellation/refund/return tests remain pending; full manual milestone acceptance not yet claimed. No code changes in this entry.

### 2026-11-17 — Agreed Drone Construction Logistics Direction

Developer confirmed preference for permanent conveyors supplying production/storage and drones physically collecting and delivering construction materials; agreed standard Storage and bulk silos, research-unlocked retrofit docking attachments on ordinary Storage to allow closer collection, plus construction supply depots and drone service infrastructure. On cancellation with cargo, return to nearest available compatible storage via physical flight, then eligible next job if safe or Hub. Documented safeguards, proposed research progression and staged implementation in `docs/DRONE_CONSTRUCTION_LOGISTICS.md`; cross-linked from design, architecture and active roadmap. Power-loss pause reported with red blueprint and drone present in screenshot; no manual resume or cancellation verification yet. Finish E3d5c5x2 manual gate before new implementation. No code changes; numerical research stats and specific route policy details remain proposals, not final balance. Existing protected conveyor implementation retained.

### 2026-11-17 — E3d5c5x2 Manual Construction Acceptance

Developer screenshots and report confirm power-loss pause, subsequent restoration and building completion with 100% progress and drone return. Separate cancellation at 31%: site removed, all queue counts zero, drone DOCKED at Hub, battery 24.8/40, escrow 0/3, power allocation 0/7, generation 12 and relay still energized. Starter 1 + belt 0 + staging 3 = all four ingots retained. Output shows BLUEPRINT CANCELLED and a later duplicate Bind refusal (expected one-shot tutorial behavior); full debugger issues not independently reviewed (15 debugger entries visible). Manual objectives accepted together with previously accepted 33/33 targeted automated checks, not a full project regression. Existing conveyor-fed baseline retained. Proceed to E3d5c5x3 read-only supplier discovery and docking eligibility under agreed drone logistics architecture.

### 2026-11-17 — E3d5c5x3 Drone Storage Dock Discovery Staged (12 Checks Pending)

Added default-off PrototypeDroneStorageDock (Marker3D) and PrototypeDroneStorageDiscovery with explicit same-world completed Test Storage enrollment, pinned exact dock/building/inventory identity, live health/preview/deletion checks, independent pickup and return permissions, dock availability and per-request retained-stock floor. Pickup queries require QUEUED authorized site, missing materials, idle drone, definition bill item/amount and caller-provided cargo capacity; rank by actual drone straight-line round-trip energy (current -> dock -> site hover -> registered home plus battery margin), then site distance, then stable enrollment order. Return query ranks nearest eligible whole-load destination from current drone position and requires enough battery for onward home return; caller-supplied cargo amount is only a forecast, not proof of drone-held stock. Existing drone gains read-only estimate_route_energy; no movement, battery debit, claims, material transfer, stock/capacity reservation, readiness, docking contention scheduler, research or production scene wiring. Existing Storage and conveyor paths unchanged. New test res://tests/drone_storage_discovery_e3d5c5x3_test.tscn covers 12 groups A–L: default-off, eligibility/identity, authorization/bill/capacity, route ranking, stock/availability/permissions, ties, battery/home margin, return capacity, health/disable, stale inventory/deletion, no side effects, scene opt-out. Runtime verification pending; next isolate source claims and return capacity before physical transport. No full pathfinding or obstacle safety claims.

### 2026-11-17 — E3d5c5x3 Storage Discovery Acceptance (12/12)

Developer Godot 4.6.2 Output screenshot confirms PASS A–L and ALL 12 E3D5C5X3 DRONE STORAGE DISCOVERY TESTS PASSED. Default-off completed Storage identity, authorization, route rank, stock and dock eligibility, deterministic ties, battery forecast, nearest available return, damaged/deleted/replaced sources, read-only behavior and scene opt-out accepted. No physical cargo or claims implied. Next E3d5c5x4: isolated source claims and competing consumer protection, before physical pickup; return-capacity claims may be staged separately. Preserve prior 33/33 playable baseline.

### 2026-11-17 — E3d5c5x4a Source Stock Reservations Staged (12 Checks Pending)

Isolate source-side claims before destination capacity claims or physical pickup. InventoryComponent now has default-off opt-in runtime token claims; get_amount/total/space and mutation revision continue to represent physical stock, while has_amount, remove_item and transfer_to respect unreserved quantity. Existing claims remain protective when the flag is disabled. Discovery subtracts existing claims plus the requested material's dock retention floor, and can require an opt-in claimable inventory. New PrototypeDroneSupplierReservations is explicitly configured once per fixture scope; re-queries discovery before claiming, binds exact drone/site/job/storage/dock/inventory/item/count, allows one outstanding claim per drone and site, uses monotonically issued service-local IDs and private token identities, releases unpicked claims on cancellation/tree exit or exact-owner cancellation, and explicitly reconciles stale eligibility. No cargo debit, flight, staging, escrow grant, charging, power or job readiness. Source claims do not represent new inventory; production scene defaults remain unchanged. Retention floor protects stock from drone reservations, not ordinary factory consumption. Test res://tests/drone_supplier_reservations_e3d5c5x4a_test.tscn stages 12 A–L groups: opt-in/exclusive service, authorization and bill bounds, exact count/revision, competition, ordinary output port and transfer protection, toggle/owner release, cancellation, stale dock, freed claimant, damage, teardown/conservation and default compatibility. Godot validation pending. No timed belt attempt independently asserted by this test; run targeted inventory/conveyor and existing drone regressions after isolated acceptance. Raw dictionary mutation/destruction recovery and persistence are not covered by this runtime claim API. Next E3d5c5x4b: return capacity and then guarded arrival/pickup.

### 2026-11-17 — E3d5c5x4a Supplier Reservation Acceptance and Compatibility Gate

Developer explicitly confirmed all 12/12 supplier reservation checks passed locally in Godot. Isolated source claims accepted by developer report; not independently executed. Because shared InventoryComponent.has_amount/remove_item/transfer_to and discovery availability changed, require the following 16 existing F6 suites (207 check groups) before advancing to x4b return capacity. Counts verified from repository test scripts; inventory scene's historical filename typo is intentional and its four PASS groups do not print an ALL banner. Manufacturing prints an unnumbered ALL banner after nine PASS groups. This is targeted compatibility, not a full project regression. No additional code changes or runtime claims in this entry. Existing tests do not prove timed conveyor contention with active claims, raw inventory dictionary mutation or active-claim destruction recovery; these require separate integration checks before live activation.

- `res://tests/inventory_trasnfer_test.tscn` — 4
- `res://tests/item_port_transfer_test.tscn` — 7
- `res://tests/conveyor_automatic_loading_test.tscn` — 10
- `res://tests/conveyor_connected_transport_test.tscn` — 7
- `res://tests/conveyor_splitter_test.tscn` — 10
- `res://tests/conveyor_merger_test.tscn` — 10
- `res://tests/conveyor_physical_only_conservation_test.tscn` — 9
- `res://tests/manufacturing_transaction_test.tscn` — 9
- `res://tests/blueprint_construction_material_escrow_e3d5c2a_test.tscn` — 16
- `res://tests/unified_receiver_consolidation_e3d5c5v_test.tscn` — 56
- `res://tests/playable_construction_logistics_e3d5c5w_test.tscn` — 13
- `res://tests/playable_construction_power_e3d5c5x1_test.tscn` — 9
- `res://tests/playable_construction_drone_e3d5c5x2_test.tscn` — 11
- `res://tests/drone_storage_discovery_e3d5c5x3_test.tscn` — 12
- `res://tests/world_salvage_destruction_test.tscn` — 12
- `res://tests/destruction_cargo_recovery_test.tscn` — 12

### 2026-11-17 — E3d5c5x4a Targeted Compatibility Acceptance (207/207)

Developer explicitly confirmed all 16 previously enumerated F6 compatibility suites passed, 207/207 check groups. Combined with the accepted 12/12 source reservation test, 219/219 targeted checks accepted by developer report, not independently executed or full-project regression. Proceed to x4b isolated return-capacity claims. Timed conveyor contention with active claims and active-claim destruction recovery remain separate integration work before live activation.

### 2026-11-17 — E3d5c5x4b Return Capacity Reservations Staged (14 Checks Pending)

Added separate default-off incoming space claims to InventoryComponent. Physical item count/revision remain unchanged by claims; get_physical_available_space reports physical room, get_available_space and is_full now reflect ordinary unreserved intake capacity, and existing add_item/transfer_to/port/timed belt APIs respect that capacity. Outgoing source claims remain independent. Unlimited inventories still report -1 ordinary space but track token counts. Disabling new claims does not itself release existing claims. PrototypeDroneReturnReservations (one configured service per scope, separate from source claims) performs fresh nearest eligible return discovery, requires an explicitly claimable inventory, binds exact drone/dock/storage/inventory/item/count with private token, refuses duplicate drone claims, releases on exact-owner request or relevant tree exit, and supports explicit revalidation for permissions, health, capacity, route energy and identities; when capacity shrinks, reconcile newest-first to retain older valid claims where possible. No site binding because returns must survive cancellation. This is caller-supplied single-item whole-load forecast, not evidence of actual cargo or permission to unload. No drone movement, battery expenditure, deposit, pickup, persistence, research unlock or Main wiring. New res://tests/drone_return_reservations_e3d5c5x4b_test.tscn covers 14 groups A–N including default-off, invalid requests and energy, physical/claim separation, competing returns across item types, source/return coexistence, real connected straight conveyor timer intake/backpressure/recovery, owner release, permission invalidation, capacity reduction/newest-first, claimant deletion/damage, replacement identity, unlimited storage and teardown/conservation, and normal scene opt-out. Godot parse/runtime pending. Existing 219/219 x4a acceptance retained. After isolated acceptance rerun targeted shared inventory/transport/construction tests including automatic unloading, then proceed to guarded physical drone cargo custody. Active-claim destruction recovery and actual return routing/unloading still require dedicated integration.

### 2026-11-17 — E3d5c5x4b Isolated Return Capacity Acceptance (14/14); Compatibility Gate Pending

Developer explicitly confirmed all 14 local Godot checks passed; no independent runtime execution. Accept isolated return capacity reservation suite only. Previous x4a 219/219 remains historical acceptance. The next targeted gate is 20 suites / 245 groups, comprising all 16 prior compatibility suites (207), x4a supplier reservation suite (12), automatic unloading (9), timed Storage conveyor delivery (6), and recipe output capacity (11). Full list and pending statuses in [HANDOFF.md](HANDOFF.md). After explicit confirmation, record x4b 259/259 (14 + 245); do not advance to x5 before the gate passes. No production or gameplay code changes. Remaining cargo custody, actual return unloading, active-claim destruction recovery and persistence limitations unchanged.


### 2026-11-17 — E3d5c5x4b Full Targeted Acceptance (259/259)

Developer explicitly confirmed all 20 compatibility suites in HANDOFF passed locally in Godot, 245/245 check groups, plus previously confirmed 14/14 isolated return capacity groups: 259/259. Category totals: inventory/manufacturing 31, conveyor 61, construction 94, drones 35, destruction/recovery 24. Evidence is developer report, not independent execution or full project regression. Tested implementation d6d1ed9; gate documentation at 0d987bb. Proceed to E3d5c5x5 in isolated stages: exact-token pickup transaction, physical flight and authorized-site staging, then integration. No Main activation; active-claim destruction/persistence and actual canceled cargo unloading remain separate gates.


### 2026-11-17 — E3d5c5x5a Physical Pickup Staged (12 Checks Pending)

Split x5 into pickup and delivery gates because legacy worker dispatch expects an already authorized site and worker wait state. Add explicit default-off cargo pickup mode and append flight states without renumbering legacy states. Exact private source claim admits physical battery-metered dock travel; source service revalidates original owner/job/dock/inventory, stock and route forecast on every advance and collection. At verified arrival, consume exact claimed amount once and hold finite single-item cargo on worker, with no site readiness, unloading or automatic reassignment. Pre-pickup cancellation releases unpicked claim and returns empty worker; after pickup cancellation retains cargo in CARGO_HELD state. No cargo transfer to site, actual return deposit, loaded-drone destruction/persistence or normal scene activation yet. Isolated res://tests/drone_physical_pickup_e3d5c5x5a_test.tscn stages 12 A–L checks. Godot parse/runtime pending; no independent Godot execution. After acceptance rerun source/return reservation, shared inventory, battery and existing drone regressions before x5b delivery. No full project regression claimed.


### 2026-11-17 — E3d5c5x5a Isolated Physical Pickup Acceptance (12/12); Compatibility Gate Pending

Developer explicitly confirmed all 12 x5a physical drone pickup checks passed locally in Godot on implementation 6ed2e2b. Accepted isolated movement, battery, exact-claim collection, cargo custody and cancellation behavior; not independently executed or full-project regression. The following 28 F6 suites (397 check groups) are required before x5b. Reuse all 20 prior compatibility suites (245), x4b isolated return claims (14), plus seven direct worker flight/readiness/fleet/battery/reuse/tick/sandbox bridge suites (138). Counts of added suites checked against source PASS groups. Prior x4b 259/259 remains historical; new gate tests must be rerun on x5a. After all pass, record 409/409 targeted including 12 accepted isolated checks. See [HANDOFF](HANDOFF.md) for progress. No gameplay code changes. Loaded drone stays at source; delivery/staging, return unloading, loaded-drone destruction and persistence remain separate gates.

- `res://tests/inventory_trasnfer_test.tscn` — 4
- `res://tests/item_port_transfer_test.tscn` — 7
- `res://tests/manufacturing_transaction_test.tscn` — 9
- `res://tests/recipe_output_capacity_test.tscn` — 11
- `res://tests/conveyor_automatic_loading_test.tscn` — 10
- `res://tests/conveyor_automatic_unloading_test.tscn` — 9
- `res://tests/conveyor_connected_transport_test.tscn` — 7
- `res://tests/conveyor_splitter_test.tscn` — 10
- `res://tests/conveyor_merger_test.tscn` — 10
- `res://tests/conveyor_physical_only_conservation_test.tscn` — 9
- `res://tests/timed_storage_conveyor_delivery_test.tscn` — 6
- `res://tests/blueprint_construction_material_escrow_e3d5c2a_test.tscn` — 16
- `res://tests/unified_receiver_consolidation_e3d5c5v_test.tscn` — 56
- `res://tests/playable_construction_logistics_e3d5c5w_test.tscn` — 13
- `res://tests/playable_construction_power_e3d5c5x1_test.tscn` — 9
- `res://tests/playable_construction_drone_e3d5c5x2_test.tscn` — 11
- `res://tests/drone_storage_discovery_e3d5c5x3_test.tscn` — 12
- `res://tests/drone_supplier_reservations_e3d5c5x4a_test.tscn` — 12
- `res://tests/world_salvage_destruction_test.tscn` — 12
- `res://tests/destruction_cargo_recovery_test.tscn` — 12
- `res://tests/drone_return_reservations_e3d5c5x4b_test.tscn` — 14
- `res://tests/prototype_construction_worker_drone_e3d5c4u_test.tscn` — 16
- `res://tests/prototype_drone_worker_readiness_e3d5c4v_test.tscn` — 21
- `res://tests/prototype_construction_drone_fleet_e3d5c4w_test.tscn` — 21
- `res://tests/prototype_drone_battery_dock_e3d5c4x_test.tscn` — 20
- `res://tests/prototype_construction_drone_reuse_e3d5c4y_test.tscn` — 20
- `res://tests/prototype_construction_drone_tick_e3d5c4z_test.tscn` — 20
- `res://tests/sandbox_construction_drone_bridge_e3d5c5a_test.tscn` — 20


### 2026-11-17 — E3d5c5x5a Full Targeted Acceptance (409/409)

Developer explicitly confirmed all 28 compatibility suites and 397 check groups passed in local Godot, in addition to 12/12 isolated physical pickup checks. Tested implementation 6ed2e2b; gate record 19da901. All listed suites in HANDOFF accepted, not independently executed or full-project regression. Proceed to x5b guarded delivery; retain exact original site/job identity, finite cargo custody, physical arrival, site-owned staging and escrow/power/worker safeguards. Recovery and persistence remain separate gates.


### 2026-11-17 — E3d5c5x5b Physical Delivery Staged (13 Checks Pending)

Pin original site/job/definition at successful x5a pickup. Separate default-off delivery states and explicit metered movement do not grant legacy worker authority. Require exact original queued site with missing materials, one scope-local registry and escrow, pinned receiver identity, remaining bill, ordinary capacity, port acceptance, no held escrow and safe straight-line battery route; recheck before movement and unload. On verified arrival transfer actual whole-load cargo into owned staging, reduce custody by accepted amount, refuse duplicates; legacy escrow is separately invoked, with no automatic readiness/timer. Interrupted delivery retains cargo; successful delivery leaves worker in DELIVERED pending worker/build integration. No in-flight site demand reservation, autonomous dispatch, return unloading, destruction recovery, persistence or Main activation. Isolated scene res://tests/drone_physical_delivery_e3d5c5x5b_test.tscn stages 13 checks A–M including exact site, actual flight, moved arrival, staging, escrow/refund, cancellation, competing intake, held bill and conservation. Godot parse/runtime pending; assistant did not independently execute. After isolated acceptance targeted compatibility, then integrate delivery with worker/readiness through separate gate before x6 recovery.


### 2026-11-17 — E3d5c5x5b Isolated Physical Delivery Acceptance (13/13); Compatibility Gate Pending

Developer explicitly confirmed all 13 isolated physical delivery checks passed in local Godot on implementation 5e2fbbc. Accept delivery flight, actual battery use, original site and receiver validation, exact-once unloading, escrow/refund and cancellation custody in tested scenarios; not independently executed or full project regression. Rerun all 28 x5a compatibility suites (397), x5a physical pickup (12), and six targeted staging/port/registry/readiness/recovery suites (94), for 35 suites and 503 groups. Added counts verified from source PASS groups and scene paths. Upon explicit confirmation record x5b 516/516 including isolated checks. No gameplay changes. Successful unload remains separate DELIVERED state with no worker authority; subsequent x5c integration must use existing readiness, escrow and finite power/worker rules. Return routing/unloading, in-flight demand reservations, drone destruction recovery, persistence and Main activation remain pending. See HANDOFF for gate tracking.

- `res://tests/inventory_trasnfer_test.tscn` — 4
- `res://tests/item_port_transfer_test.tscn` — 7
- `res://tests/manufacturing_transaction_test.tscn` — 9
- `res://tests/recipe_output_capacity_test.tscn` — 11
- `res://tests/conveyor_automatic_loading_test.tscn` — 10
- `res://tests/conveyor_automatic_unloading_test.tscn` — 9
- `res://tests/conveyor_connected_transport_test.tscn` — 7
- `res://tests/conveyor_splitter_test.tscn` — 10
- `res://tests/conveyor_merger_test.tscn` — 10
- `res://tests/conveyor_physical_only_conservation_test.tscn` — 9
- `res://tests/timed_storage_conveyor_delivery_test.tscn` — 6
- `res://tests/blueprint_construction_material_escrow_e3d5c2a_test.tscn` — 16
- `res://tests/unified_receiver_consolidation_e3d5c5v_test.tscn` — 56
- `res://tests/playable_construction_logistics_e3d5c5w_test.tscn` — 13
- `res://tests/playable_construction_power_e3d5c5x1_test.tscn` — 9
- `res://tests/playable_construction_drone_e3d5c5x2_test.tscn` — 11
- `res://tests/drone_storage_discovery_e3d5c5x3_test.tscn` — 12
- `res://tests/drone_supplier_reservations_e3d5c5x4a_test.tscn` — 12
- `res://tests/world_salvage_destruction_test.tscn` — 12
- `res://tests/destruction_cargo_recovery_test.tscn` — 12
- `res://tests/drone_return_reservations_e3d5c5x4b_test.tscn` — 14
- `res://tests/prototype_construction_worker_drone_e3d5c4u_test.tscn` — 16
- `res://tests/prototype_drone_worker_readiness_e3d5c4v_test.tscn` — 21
- `res://tests/prototype_construction_drone_fleet_e3d5c4w_test.tscn` — 21
- `res://tests/prototype_drone_battery_dock_e3d5c4x_test.tscn` — 20
- `res://tests/prototype_construction_drone_reuse_e3d5c4y_test.tscn` — 20
- `res://tests/prototype_construction_drone_tick_e3d5c4z_test.tscn` — 20
- `res://tests/sandbox_construction_drone_bridge_e3d5c5a_test.tscn` — 20
- `res://tests/drone_physical_pickup_e3d5c5x5a_test.tscn` — 12
- `res://tests/blueprint_material_staging_e3d5c4c_test.tscn` — 16
- `res://tests/blueprint_physical_staging_e3d5c4d_test.tscn` — 16
- `res://tests/blueprint_site_staging_ownership_e3d5c4h_test.tscn` — 16
- `res://tests/blueprint_anchored_receiver_e3d5c4i_test.tscn` — 16
- `res://tests/blueprint_owned_readiness_e3d5c4r_test.tscn` — 18
- `res://tests/blueprint_receiver_recovery_audit_e3d5c4j_test.tscn` — 12


### 2026-11-17 — E3d5c5x5b Full Targeted Acceptance (516/516)

Developer explicitly confirmed all 35 compatibility suites and 503 check groups passed in local Godot, in addition to 13 isolated delivery checks. Tested implementation 5e2fbbc; gate record f23e494. All enumerated suites in HANDOFF accepted by developer report, not independently executed or full-project regression. Proceed to x5c delivered-drone construction worker integration, preserving exact site/job, owned escrow, finite power and scheduler presence gates. Return unloading, destruction and persistence remain separate gates.


### 2026-11-17 — E3d5c5x5c Delivered Drone Worker Integration Staged (16 Checks Pending)

Default-off explicit coordinator handoff from DELIVERED to existing AT_SITE worker state. Require original live queued site/job/definition, empty cargo, current physical arrival, return energy, pinned registry/buffer/escrow and complete held bill from exact owned inventory; coordinator must track original site, scheduler preflights exclusive binding. No movement, extra charge, authorization, slot grant or timer advancement by handoff. Existing coordinator and scheduler reconcile finite power, escrow and worker presence; disabling delivered-worker mode or ownership fails closed on reconciliation; legacy lifecycle returns empty worker after completion/cancellation. Delivered workers cannot use legacy rearm until x7. Isolated res://tests/drone_delivered_worker_e3d5c5x5c_test.tscn stages 16 A–P checks including no remote/loaded admission, provenance, stale arrival, outage, ownership, competing workers, real construction completion, cancellation refund and battery-metered return. No independent Godot execution; runtime pending. No autonomous dispatch, loaded recovery, persistence or Main activation. After isolated acceptance rerun targeted compatibility before x6.


### 2026-11-17 — E3d5c5x5c Isolated Acceptance (16/16); Compatibility Gate Pending

Developer's Godot 4.6.2 Output screenshot confirms PASS A–P and ALL 16 E3D5C5X5C DELIVERED DRONE WORKER INTEGRATION TESTS PASSED on staged implementation 6652bd0. Isolated acceptance includes no loaded/remote bypass, original site and complete held escrow, explicit scheduler binding, physical arrival, finite worker/power, feature and ownership loss, progress preservation, exact-once completion, battery-metered return, cancellation refund and conservation, reuse quarantine and normal-scene opt-out. No independent Godot execution. Rerun all 35 x5b compatibility suites (503 groups), plus physical delivery x5b (13), direct construction readiness coordinator E3d5c3c1 (18), and construction readiness probe E3d5c1 (15); 38 suites / 549 groups pending, 565 total targeted groups if accepted. Exact list and pending status in [HANDOFF](HANDOFF.md). No gameplay code changed. Do not implement x6 until compatibility completes; loaded cancellation return, persistence, destruction, reuse and normal scene activation remain separate gates.


### 2026-11-17 — E3d5c5x5c Full Targeted Acceptance (565/565)

Developer explicitly confirmed all 38 compatibility suites and 549 check groups passed locally in Godot, in addition to the 16 isolated checks; tested implementation 6652bd0, documentation checkpoint 955eab6. Exact enumerated results in HANDOFF. Not independently executed or a full-project regression. Proceed to E3d5c5x6 automatic loaded canceled-job recovery, retaining all prior safeguards; no normal scene activation, persistence or automatic next-job reuse.


### 2026-11-17 — E3d5c5x6 Isolated Canceled Cargo Recovery Staged (13 Checks Pending)

Default-off flags on drone and existing return-reservation service; explicit isolated `advance_cancelled_recovery(drone, delta)` tick derives whole-load claim from actual held cargo after original job cancellation or original-site identity loss, never from forecast-only claims. Existing discovery chooses nearest eligible whole-load Storage with battery-to-home margin; exact claim protects ordinary intake. Each tick revalidates original cargo, scope, destination, capacity and route, meters physical flight, refuses stale arrival, atomically consumes exact incoming claim into physical stock once, clears cargo and flies empty to home. Stale claims release without discarding cargo; no receiver enters protected RECOVERY_WAIT and retries on later ticks. No loaded home fallback or automatic reassignment, no normal scene wiring, no charging changes, no destruction/persistence integration. Implementation and isolated scene 6675009. Run `res://tests/drone_cancelled_cargo_recovery_e3d5c5x6_test.tscn` (A–M). No independent Godot parse/runtime execution; developer acceptance pending. Prior x5c 565/565 remains historical, not a regression result on x6. After isolated acceptance, target relevant legacy suites before x7.


### 2026-11-17 — E3d5c5x6 Isolated Acceptance (13/13); Compatibility Gate Pending

Developer supplied Godot 4.6.2 Output screenshot showing all PASS A–M and ALL 13 E3D5C5X6 CANCELED CARGO RECOVERY TESTS PASSED. Tested implementation and scene 6675009, documentation checkpoint 20cabd2. Exact-once actual cargo deposit, physical metered recovery and empty home return, nearest eligible claim, capacity and route invalidation, conservation and default-off boundaries accepted in isolated fixture. No independent execution. Rerun x5c 38 compatibility suites (549) plus isolated delivered-worker integration x5c (16; source PASS count verified), 39 suites / 565 groups pending; 578/578 overall if passed. Exact checklist in HANDOFF. No gameplay code changes; do not proceed to x7 until compatibility accepted. Recovery remains explicit tick and default-off; loaded fallback, normal scene scheduling, persistence and destruction integration not accepted.


### 2026-11-17 — E3d5c5x6 Full Targeted Acceptance (578/578)

Developer explicitly confirmed all 39 compatibility suites / 565 check groups passed locally in Godot in addition to 13 isolated recovery checks. Implementation and scene 6675009, gate documentation f1215dc. Enumerated results in HANDOFF; no independent execution or full-project regression. Proceed to x7 charging and repeated assignments through isolated gates, preserving all prior behavior. No production activation or persistence/destruction integration.


### 2026-11-17 — E3d5c5x7a Finite Hub Charging Staged (13 Checks Pending)

Default-off exclusive same-scope Hub charging service, pinned completed prototype Hub and power node, exactly one live allocator, exact physical registered home (Hub + 2m), per-worker private token and latched legacy boolean-charge denial. Read-only spare nameplate rate in the Hub's existing operational component deducts existing construction allocations using the allocator's exact covering-node selection; one explicit fleet tick spends at most spare rate times delta in fixed enrollment order, bounded by each drone's charge rate and remaining battery capacity. No cargo/claim mutations, no charging airborne or away from exact home, no power allocation changes, no automatic rearm, no live scene wiring. This is provisional nameplate-to-battery simulation, not actual fuel/electrical energy metering. Fixed enrollment order and single Hub scope deliberate for isolated gate; authority loss remains fail-closed. Implementation and test scene 61c3d7e; `res://tests/drone_finite_hub_charging_e3d5c5x7a_test.tscn` A–M pending developer F6. No independent Godot execution. x6 578/578 is historical, not x7a regression. After isolated and targeted compatibility acceptance proceed to x7b cargo-worker rearm and repeated assignments; no change to legacy default-off test paths or normal scenes.


### 2026-11-17 — E3d5c5x7a Isolated Acceptance (13/13); Compatibility Gate Pending

Developer supplied Godot Output screenshot showing PASS A–M and ALL 13 E3D5C5X7A FINITE HUB CHARGING TESTS PASSED. Implementation and scene 61c3d7e, documentation checkpoint a97db8f. Shared surplus generation with construction precedence, exclusive physical home charging, rate/capacity, outage, feature loss, duplicate allocator and service removal safeguards accepted in isolated fixture. No independent execution. Rerun x6 39 compatibility suites (565), plus x6 isolated recovery (13), power coverage (16), completed power structures (16), finite construction power (18); 43 suites / 628 groups pending; 641/641 overall if passed. Source counts verified. Exact checklist in HANDOFF. No gameplay code changes. x7b blocked until compatibility accepted; simulated nameplate-to-battery budget, fixed order and single Hub remain isolated limitations.


### 2026-11-17 — E3d5c5x7a Full Targeted Acceptance (641/641)

Developer explicitly confirmed all 43 compatibility suites / 628 checks passed in local Godot, plus 13 isolated charging checks. Implementation and scene 61c3d7e, gate record f62e8de. Exact suite results in HANDOFF. No independent execution or full-project regression. Proceed to x7b guarded cargo-worker rearm and repeated assignments; preserve existing charging, escrow, custody, authorization and worker gates. No normal scene activation.


### 2026-11-17 — E3d5c5x7b Guarded Cargo Worker Rearm Staged (16 Checks Pending)

Default-off explicit cargo-worker rearm separated from the legacy build-only method. Require terminal delivered assignment or successfully deposited canceled cargo, exact physical Hub registration and full battery under the still-live x7a charging authority, empty cargo and no pickup/return tokens, authoritative same-scope supplier/return ledgers, matching live owned-mode coordinator/escrow/scheduler, exact pinned delivered-worker scheduler and escrow where applicable, no reservation/escrow records or active worker slots, no old worker binding. Rearm disconnects old job/site callbacks and clears assignment provenance only, leaves receiver ownership/material quantities untouched; subsequent pickup uses new authorization/claim and live finite-charge gate. One drone runs complete, canceled in-flight recovery, complete, canceled during construction, with two committed bills and conserved remaining stock. Explicit calls only; an entire scope must be quiescent, full charge required, fixed Hub, no pre-pickup cancellation rearm, nonterminal lost-site recovery rearm, empty delivered-before-worker cancellation rearm, automatic dispatch, multi-trip, persistence/destruction integration or normal scene activation. Those are separate future gates.  Implementation and test scene d0fa281; `res://tests/drone_cargo_worker_reuse_e3d5c5x7b_test.tscn` A–P pending developer F6. No independent Godot execution. x7a 641/641 remains historical, not an x7b regression result. After isolated and compatibility acceptance, assess remaining cancellation paths and automatic assignment integration through separate gates.


### 2026-11-17 — E3d5c5x7b Pre-Test Original Home Guard Refinement

Latest implementation/test refinement acdcdf7. Enforce finite exact original battery home as well as live current Hub registration on rearm and subsequent pickup; simultaneous relocation of Hub and drone cannot bypass the original-home requirement. Test F now checks combined relocation. All 16 isolated checks still pending local Godot; no independent execution.


### 2026-11-17 — E3d5c5x7b Isolated Acceptance (16/16); Compatibility Gate Pending

Developer explicitly reported all 16 isolated Godot checks passed (no screenshot supplied for this checkpoint; no independent execution). Latest staged implementation/test refinement acdcdf7, documentation checkpoint 779fd41. Fixture demonstrates same drone through two completed builds, one canceled loaded recovery and one cancellation during construction; four rearms and 15/15 original ingots accounted for. Exact original home and finite charge, terminal job, authoritative ledger/scheduler and escrow cleanup, old callbacks, fresh claim/authorization, feature loss and default-off safeguards accepted in fixture. Rerun x7a 43 compatibility suites (628) plus x7a finite Hub charging (13; source count/scene verified): 44 suites / 641 checks pending, 657/657 total if passed. Exact list in HANDOFF. No gameplay code changes. Whole-scope quiescence/full charge/explicit calls remain restrictions; remaining cancellation lifecycle cases before automatic dispatch, multi-trip or fleet scheduling; no normal scene activation, persistence/destruction integration.


### 2026-11-18 — E3d5c5x7b Full Targeted Acceptance (657/657)

Developer explicitly confirmed all 44 compatibility suites / 641 checks passed locally in Godot, in addition to 16 isolated checks. Implementation refinement acdcdf7, gate documentation ca5dd3f. Exact suite results in HANDOFF. No independent execution or full-project regression. Next x7c1 pre-pickup cancellation, x7c2 post-delivery before worker admission, x7c3 nonterminal site loss; automatic dispatch only after separate acceptance gates. Preserve full finite charge, exact home, authoritative ledger and worker cleanup, material ownership and normal scene opt-out.


### 2026-11-18 — E3d5c5x7c1 Pre-Pickup Cancellation Staged (12 Checks Pending)

Default-off x7c1 pre-pickup rearm opt-in latched at active pickup launch, requires cargo-reuse opt-in. Forecast-only reservation cancellation releases stock and leaves drone idle without rearm. Exact active pickup token release with original canceled job, original site weak reference and authoritative same-scope supplier identity records empty terminal provenance; token and dock claim cleared by existing release, no source debit or cargo creation. Already-launched empty drone returns with metered flight and exact home threshold; immediate at-home cancellation docks without travel. Existing x7b explicit rearm still requires full finite charge, exact original home, same live supplier and return ledgers, matched coordinator/escrow/scheduler, no outstanding claims or active/old worker binding, and current opt-in. Disabling opt-in after launch preserves terminal provenance but blocks release until restored. Nonterminal source/claim failure or site loss does not establish rearm provenance; enabling after cancellation cannot fabricate it. No receiver ownership mutation, automatic dispatch, live scene wiring, multi-drone scheduling, or persistence/destruction changes. Implementation and test scene e19cd8a; `res://tests/drone_pre_pickup_cancellation_e3d5c5x7c1_test.tscn` A–L pending developer F6. No independent Godot execution. Prior x7b 657/657 is historical, not regression on x7c1. After isolated and targeted compatibility acceptance move to x7c2 post-delivery cancellation, x7c3 nonterminal site loss, and only then automatic dispatch.


### 2026-11-18 — E3d5c5x7c1 Isolated Acceptance (12/12); Compatibility Gate Pending

Developer explicitly reported all 12 isolated Godot checks passed; no screenshot supplied for this checkpoint, no independent execution. Implementation and scene e19cd8a, documentation checkpoint fd3a7f8. Fixture verifies reservation-only cancellation, canceled launches and physical return before debit, finite recharge and exact-once reuse, late opt-in/nonterminal release denial, new authorized build and conservation of 15 ingots. Rerun x7b 44 compatibility suites (641) plus x7b cargo-worker reuse (16; source count/scene verified), 45 suites / 657 checks pending, 669/669 overall if passed. Exact checklist in HANDOFF. No gameplay code changes. Proceed to x7c2 only after compatibility, then x7c3 and x8; conservative full-charge, whole-scope cleanup and default-off boundaries retained.


### 2026-11-18 — E3d5c5x7c1 Full Targeted Acceptance (669/669)

Developer explicitly confirmed all 45 compatibility suites / 657 checks passed locally in Godot plus 12 isolated checks. Implementation e19cd8a, gate documentation 9c6248b. Exact suite results in HANDOFF. No independent execution or full-project regression. Proceed to x7c2 terminal post-unload cancellation before worker admission; preserve staging custody, escrow, metered flight and existing rearm gates. Nonterminal site loss and automatic dispatch remain separate gates.


### 2026-11-18 — E3d5c5x7c2 Post-Delivery Cancellation Staged (13 Checks Pending)

Default-off x7c2 opt-in latched only at successful full physical unload with cargo reuse enabled. Explicit begin_cancelled_delivery_return() accepts only empty DELIVERED drone with exact original CANCELLED job and pinned delivery registry/escrow/buffer; rejects active, loaded, admitted worker, nonterminal site loss, late opt-in and repeated transition. No material, reservation, worker or staging ownership mutation; existing escrow cancellation signal refunds its own source or retains unresolved bill for explicit recovery. Empty return uses existing battery-metered flight with exact home threshold, even after opt-in loss; rearm still requires current opt-in, full finite charge, exact original home, authoritative same-scope ledgers, cleared escrow and worker bindings plus original live registry/buffer lock and matching owned-mode coordinator. Terminal/stale lock observation is read-only, including a freed terminal site if the original buffer remains live and locked; no claim deletion or retarget. A blocked refund does not prevent empty flight but prevents reuse. Fixture exercises three supported canceled deliveries and one successful build on same opted-in drone plus a separate default-off canceled delivery, accounts for 15 original ingots (12 in four owned canceled buffers, 3 committed). Explicit ticks/rearm only. No automatic recovery of material from staging, nonterminal site loss, automatic dispatch, multi-drone scheduling, persistence/destruction integration or normal-scene activation. Implementation and test scene c53519e; `res://tests/drone_post_delivery_cancellation_e3d5c5x7c2_test.tscn` A–M pending developer F6. No independent Godot compilation or execution. Prior x7c1 669/669 is historical, not regression on x7c2. After isolated and targeted compatibility acceptance move to x7c3 nonterminal original-site loss and then x8 automatic dispatch.


### 2026-11-18 — E3d5c5x7c2 Isolated Acceptance (13/13); Compatibility Gate Pending

Developer explicitly reported all 13 isolated Godot checks passed; no screenshot supplied for this checkpoint, no independent execution. Implementation and scene c53519e, documentation checkpoint 282deea. Fixture verifies post-unload terminal cancellation, empty metered return, original staging and escrow preservation, blocked refund and rearm denial, finite recharge and exact-once reuse, fresh authorized build and conservation of 15 ingots. Rerun x7c1 45 compatibility suites (657) plus x7c1 pre-pickup cancellation (12; source count/scene verified), 46 suites / 669 checks pending, 682/682 overall if passed. Exact checklist in HANDOFF. No gameplay code changes. Proceed to x7c3 only after compatibility, then x8 after separate acceptance; conservative full-charge, whole-scope cleanup, original receiver lock and default-off boundaries retained.


### 2026-11-18 — E3d5c5x7c2 Full Targeted Acceptance (682/682)

Developer explicitly confirmed all 46 compatibility suites / 669 checks passed locally in Godot plus 13 isolated checks. Implementation c53519e, gate documentation d70818a. Exact suite results in HANDOFF. No independent execution or full-project regression. Proceed to x7c3 nonterminal original-site loss; preserve actual cargo, locked staging and escrow, metered flight and full-charge cleanup gates. Automatic dispatch remains separate.


### 2026-11-18 — E3d5c5x7c3 Nonterminal Original-Site Loss Staged (14 Checks Pending)

Default-off x7c3 opt-in latched at actual pickup launch with cargo reuse enabled. Nonterminal reuse requires exact original site WeakRef to resolve null (object freed), never merely detached, queued for deletion, reparented, moved, changed job identity or temporary service failure. Exact supplier site-exit callback distinguishes lost pre-pickup claim from source failure; reservation-only loss stays idle, launched empty return is metered, no source debit. Opted-in loaded drone may use existing x6 reserved physical recovery only after original nonterminal site is freed (terminal cancellations retain existing path); no eligible Storage means protected wait. Unloaded and unadmitted drone uses explicit begin_lost_delivery_return only after actual loss; original staging lock/refund preserved. Admitted worker revokes old job readiness on site end, returns empty, and must clear scheduler binding; orphan job is paused rather than falsely marked terminal. Existing full finite charge, exact home, authoritative ledger/coordinator/scheduler, unresolved escrow/slot/claim and current opt-in checks remain. Pinned delivery registry, buffer lock and escrow identity required where a delivery was started; prior to delivery only exact source-release or actual returned cargo provenance qualifies. No receiver unlock/retarget, automatic recovery of staged materials, automatic dispatch, fleet scheduling, live scene wiring, persistence or full destruction integration. Fixture exercises five lost assignments on one drone and a fresh successful build, six rearms, all 15 original ingots accounted for (3 stock, 9 locked staging, 3 committed). Implementation and scene 31e2e7c; `res://tests/drone_lost_site_recovery_e3d5c5x7c3_test.tscn` A–N pending developer F6. No independent Godot compilation/runtime execution. Prior x7c2 682/682 is historical, not x7c3 regression. After isolated and targeted compatibility acceptance proceed to x8 automatic dispatch through separate tests.


### 2026-11-18 — E3d5c5x7c3 Isolated Acceptance (14/14); Compatibility Gate Pending

Developer explicitly reported all 14 isolated Godot checks passed; no screenshot supplied for this checkpoint, no independent execution. Implementation and scene 31e2e7c, code refinement 89696e1, documentation checkpoint 51f8da5. Fixture verifies original freed site recovery, pre-pickup no debit, loaded reserved physical recovery, post-unload empty return, original staging and escrow preservation including blocked refunds, stale worker readiness revocation, finite recharge/guarded reuse, fresh authorized build after five lost assignments, six rearms and conservation of all 15 ingots. Rerun x7c2 46 compatibility suites (669) plus x7c2 post-delivery cancellation (13; source count/scene verified), 47 suites / 682 checks pending, 696/696 overall if passed. Exact checklist in HANDOFF. No gameplay code changes. Proceed to x8 only after compatibility; recommend fresh development chat at accepted gate. Automatic dispatch, simultaneous fleet scheduling, normal-scene activation, canceled staging recovery, destruction/salvage and persistence remain separate gates.


### 2026-11-18 — E3d5c5x7c3 Full Targeted Acceptance (696/696) and x8 Handoff

Developer explicitly confirmed all 47 compatibility suites / 682 checks passed locally in Godot in addition to 14 isolated checks. All 47 reported names/counts match the pending gate exactly. Implementation and scene 31e2e7c / refinement 89696e1, gate documentation a90cf9c. Exact suite results in HANDOFF. No independent execution or full-project regression. x7 charging, reuse and planned cancellation/lost-site handling phase accepted. Next x8 automatic priority-based dispatch in a fresh conversation: proposed x8a single-drone serialized selection/claim/launch, x8b supervised explicit lifecycle tick, x8c targeted acceptance and separately gated playable sandbox demonstration. Preserve existing player authorization, priority ordering, original identity, material custody, escrow/readiness/worker/power gates, finite charging and conservative full-charge/whole-scope cleanup. No auto-authorization, active preemption, normal scene activation, multi-trip or concurrent fleet scheduling, persistent state or real destruction/salvage integration in initial gate. x8 not implemented; docs-only checkpoint.

### 2026-11-18 — E3d5c5x8a Isolated Automatic Priority Dispatch Staged (14 Checks Pending)

**E3d5c5x8a staged for isolated F6; NOT accepted.** Implementation commits 03f475d (read-only coordinator eligibility), 31a8f99 (dispatcher), 1cc112f (pre-launch revalidation); test script eb2963f, scene b9f0178, test refinement 0ebdc85. New `PrototypeDroneAutomaticDispatch` is default-off, explicit inspect/dispatch only, with no _process or ordinary scene wiring. It reads the existing authorized queue (High/Normal/Low, FIFO), checks the exact tracked and pinned owned receiver, supports a whole outstanding single-item deficit only, and uses existing discovery, exact supplier reserve/observe/begin_pickup. No material, power or worker availability is fabricated; missing construction power/escrow before pickup is expected, not a worker-admission bypass. Source or route/energy, receiver availability/capacity, unsupported bill and tracking failures skip candidates with observable reasons. Conservative one-drone/one-slot scope, full finite registered home charge, all recovery/reuse flags, no active workers or outstanding source/return/escrow claims; no automatic cleanup or preemption. Revalidate exact live services, job, definition, buffer, item, amount and supplier claim before launch; release only the newly acquired claim on failure, no second attempt in that call. No flight advancement, material movement, auto-authorization, charging, rearm or construction progression. x8b lifecycle driver and x8c compatibility/playable sandbox remain separate.

F6 scene: `res://tests/drone_automatic_dispatch_e3d5c5x8a_test.tscn`. Expected A–N (14/14): default-off and invalid/foreign/duplicate configure; planned High not authorized; Normal beats Low; unreachable/full/untracked High skipped with ordered reasons; High/FIFO and reprioritization; unavailable dock/retained stock; duplicate dispatcher/multiple drones; existing claim protected; current feature/service denial; receiver invalidation and refused launch roll back; exact claim and guarded launch without movement or source debit; non-preemption and no readiness/timer bypass; cancellation release without auto-rearm; ordinary scene opt-out. Expected final line: `ALL 14 E3D5C5X8A AUTOMATIC DISPATCH TESTS PASSED`. Developer local Godot compilation and execution pending; no independent runtime execution. Previous 696/696 remains historical. After isolated acceptance, document result and proceed to x8b separate implementation; retain x7c3 and earlier targeted compatibility baseline for x8c (48 prior suites / 696 groups including x7c3 isolated, plus new x8 suites as applicable).

### 2026-11-18 — x8a isolated acceptance

Developer explicitly confirmed 14/14 x8a isolated checks passed in local Godot on 2026-11-18 after indentation correction b1bba4a. No independent execution; compatibility deferred to x8c per plan. Prior 696/696 historical, not post-x8 regression.

## Future combat logistics — specialized Ammo Silos (agreed 2026-11-18)

Keep high-action defense readable: conveyors feed dedicated munitions silos, which automatically resupply compatible turret magazines inside a visible supply radius. Different silos stock different ammunition types for different weapon classes. Finite stock, magazine capacity, refill throughput, compatible ammo and deterministic overlapping coverage; no free ammunition or duplicate transfer. Empty, unpowered or destroyed silos stop resupply; turrets retain remaining magazine rounds. Exact radius, power, transfer mechanism, throughput and research tiers deferred to separate combat-logistics design/test gates after construction drones. No implementation or changes to existing turret/conveyor behavior now.

### 2026-11-18 — E3d5c5x8b Automatic Lifecycle Staged (15 Checks Pending)

**E3d5c5x8b staged; isolated acceptance pending.** Lifecycle implementation [eadaf27](https://github.com/ChrisGiggleman/industrial-warfare/commit/eadaf279282853f3f8034da7efe5f07bc31fd502); test b651f48, scene 477b3fb. Separately default-off `enable_isolated_lifecycle` configured only from clean, fully charged registered home with exact charging authority. Explicit tick only; no _process or scene activation. One bounded action per tick (no leftover delta replay): x8a launch, exact claim pickup flight/collect, pinned receiver delivery/physical unload, coordinator escrow/admission, existing scheduler slot and power reconciliation, single explicit job time advance only for non-processing sites, cancellation/lost-site physical recovery, metered return, finite registered charging, guarded rearm and later new dispatch. Weak original site and retained exact job/definition/buffer/claim identity; no adoption of manual assignment. Reject external automatic site timers before launch and do not advance their job time. Existing conservative whole-scope gates remain; unresolved escrow, failed source or uncertain custody can quarantine rather than fabricate recovery. No automatic authorization, preemption, multi-drone, multi-trip, persistence, normal-scene wiring or combat changes.

F6: `res://tests/drone_automatic_lifecycle_e3d5c5x8b_test.tscn`. Expected 15/15 A–O: separate opt-in/charging identity/delta; High FIFO and external timer exclusion; metered pickup; physical collection/delivery; escrow/admission without power bypass and exact construction time; pause/resume; completion/return; finite charge/rearm; second build; pre-pickup cancellation; temporary detachment then freed loaded-site recovery; post-delivery cancellation; working-job cancellation/refund; 15 ingots conserved (3 source, 6 locked staging, 6 committed across two builds), six rearms, no unauthorized work; normal-scene opt-out. Final line `ALL 15 E3D5C5X8B AUTOMATIC LIFECYCLE TESTS PASSED`. No independent Godot compilation/runtime; developer F6 required. After acceptance rerun x8a plus x7c3 and its 47 compatibility suites: 49 suites / 710 checks expected, plus x8b 15 isolated = 725 overall before separately gated x8c playable demo. Historical counts are not post-x8b evidence.

### 2026-11-18 — E3d5c5x8b Isolated Acceptance (15/15); x8c Compatibility Pending

Developer explicitly confirmed all 15/15 E3d5c5x8b isolated automatic lifecycle checks passed in local Godot on 2026-11-18. Tested implementation eadaf27, test b651f48, scene 477b3fb, verified staging HEAD 7ae57ef. Six assignments, two completed builds, six rearms, all 15 ingots accounted for (3 source, 6 locked staging, 6 committed). No independent assistant runtime execution. x8c targeted compatibility pending: rerun the 47 previously accepted x7c3 compatibility suites (682 checks), x7c3 isolated (14), and x8a isolated (14) for 49 suites / 710 checks; 725 overall including 15 accepted x8b checks. The two added scenes and counts were verified against their scripts. Prior acceptance is historical, not post-x8b regression evidence. No gameplay code changes. After explicit developer confirmation of compatibility, record full acceptance and proceed to separately gated playable automatic drone sandbox; keep Main and ordinary scenes opt-out. Preserve single-drone, whole-scope cleanup and full-charge guards, E/Ctrl+E and priority ordering, conveyor and combat systems.

### 2026-11-18 — E3d5c5x8 Full Targeted Acceptance (725/725)

Developer explicitly confirmed all 49/49 compatibility suites and 710/710 checks passed in local Godot on 2026-11-18. Every reported suite name and count was compared against the pending checklist and matches exactly. Combined with x8b isolated 15/15, E3d5c5x8 targeted automatic dispatch/lifecycle acceptance is 725/725 (50 suites including isolated). Tested lifecycle implementation eadaf27, test b651f48, scene 477b3fb; compatibility gate documentation 3f2e5aa. No independent assistant runtime execution; targeted acceptance, not a full-project regression or playable integration. Ordinary scenes remain opt-out.

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

### 2026-11-18 — Playable automatic construction drone sandbox FULLY ACCEPTED

Developer explicitly reported all 52/52 final compatibility suites and 741/741 checks passed locally in Godot; every supplied suite name and count was compared with `tools/playable_drone_final_regression.csv` at [fee58a9](https://github.com/ChrisGiggleman/industrial-warfare/commit/fee58a9b7b9baf7d55b099bf54585234af7906a7), exact ordered match, 52 unique entries, no missing/extra/mismatched counts. Combined with previously developer-confirmed Stage C isolated 13/13 at [78c8d87](https://github.com/ChrisGiggleman/industrial-warfare/commit/78c8d872b04eb525d66416a84ef0b4ad7951f71b), **53/53 targeted automated suites and 754/754 checks accepted**. Stage C manual gameplay 9/9 accepted separately. This is targeted milestone acceptance, not a full-project regression. See `docs/PLAYABLE_DRONE_FINAL_REGRESSION.md` for all 52 accepted results. No independent assistant execution, no claim that the optional PowerShell runner was used or validated. No screenshot-based visual assessment or optional extra manual cancellation run claimed.

Accepted playable scene: `res://scenes/core/playable_automatic_construction_drone_stage_c.tscn`. One Hub with finite power, one drone with finite battery, one completed docked Starter Storage, real player authorization and priority queue, exact owned staging/escrow, one active assignment and single bounded construction/movement/charging driver. Manual checks establish planning, priority and explicit authorization, physical collection/delivery, actual power pause/resume, building completion, return/recharge and automatic next assignment; automated checks cover non-preemption, equal-priority FIFO, cancellation before pickup/loaded/after delivery/during work, detachment versus freed original, protected canceled-site staging and exact conservation. Main/ordinary sandbox/legacy scenes remain opted out; only Test Storage with its 3-ingot whole-load bill is enrolled. Accepted fixture choices are not production balance. No gameplay, test, or runner code changed in this acceptance commit.

**Recommended next gated milestone (design first, not implemented or authorized by this closeout):** expand automatic construction eligibility beyond Test Storage. Inspect actual BuildingDefinition bills, completed scene/runtime initialization, existing dispatch candidate/receiver/escrow/worker constraints, power coverage, and planned conveyor activation before choosing the first additional building. Prefer explicit opt-in tests for a supported whole single-item bill first where available; if all candidates require multi-item/multi-trip, design an exact staged-delivery and ownership contract before making any change. Preserve the full 754-check accepted baseline and 9 manual checks, original Q+drag, L/N/H FIFO and explicit E/Ctrl+E, no auto-authorization/preemption, real transport, exact reservations, finite power/charge, and conservative recovery on uncertainty. Never change actual resource bills to make tests pass. Keep wider power coverage, canceled staged-resource recovery, multi-drone concurrency and per-assignment cleanup, general gameplay activation, destruction/save/load integration and specialized Ammo Silos separate until explicitly planned and gated. Start a new development chat with the current main HEAD and these documents as source of truth. No next-milestone implementation in this closeout.


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


### 2026-11-18 — E3d5c6b Direct Build Authorization Stage A staged; local F6 pending

Preserved accepted starting checkpoint [217ef366](https://github.com/ChrisGiggleman/industrial-warfare/commit/217ef366cc65b57ab00e0dc36d558231f1790b7c): **56/56 targeted suites / 785/785 checks**, expansion manual 9/9 separate. Stage A adds one exact-scope scene `res://scenes/core/playable_direct_build_authorization_e3d5c6b.tscn` with default-off adapter switch. WorldInteraction intercepts clicks before legacy placement even when the new adapter fails or is disabled; supported canonical Storage and Press only. Unsupported Blueprint placement also refused in this new scene, route tools/connected plan registration disabled here only; no changes to Main, prior scene files, accepted tests or regression manifest. A click refreshes the existing ground/ghost validation, rejects stale/blocked/port-linked placement, then creates an ordinary reserved-footprint site and invokes the original authorization handler (Normal job). The Blueprint click remains PLANNED; Q/L/N/H does not authorize; E and Ctrl+E use the same handler. The exact original queue and adapter services are reused; successful synchronous enrollment owns staging and transfers site timer to the existing lifecycle. A failed synchronous enrollment cancels the original job, preserving any quarantined claims; no legacy fallback, debug readiness, new driver or inventory transfer. The unsupported/unavailable ghost is red in the new scope. No changes to canonical bills (3/5 ingots, 10/18 seconds).
 
**Pending isolated F6:** `res://tests/playable_direct_build_authorization_e3d5c6b_test.tscn` — expected **11/11 A–K**. Actual WorldInteraction placement handler with narrow orthographic camera fixture aimed at known grid coordinates (not OS cursor injection); verified service composition and original queue; default-off and accepted-scene opt-out even if new switch is set; disabled exact scene cannot fall back; immutable canonical allowlist; unsupported, off-ground stale and occupied clicks refuse; direct Storage Normal once and duplicate rejection; Press Normal FIFO, exact bills and distinct empty staging; explicit selected and batch Blueprint authorization; forced enrollment listener failure cancels original job and prunes queue; post-start disabled admission blocks; shared dispatcher reserves exactly 3 ingots without pickup, escrow or time advancement. Expected banner: `ALL 11 PLAYABLE DIRECT BUILD AUTHORIZATION E3D5C6B STAGE A TESTS PASSED`. Implementation/fixture staged at [f6f2bc9](https://github.com/ChrisGiggleman/industrial-warfare/commit/f6f2bc9ca14e4eab1d5f5298db507b941b6566dc). No independent Godot execution or parse verification; camera/physics behavior is pending local F6. Report red errors and all PASS groups; acceptance stays pending until developer confirms. After isolated acceptance, document targeted compatibility gate before Stage B (full physical Direct lifecycle); Stage C manual and final combined 56 baseline + unique added suites. No added counts yet. No automatic belts/corners, splitter/merger, new pole integration, multi-load/fleet, persistence, destruction expansion or staged lock release.



### 2026-11-18 — E3d5c6b Stage A isolated accepted (11/11); targeted compatibility pending

Developer explicitly confirmed all 11/11 isolated Direct Build Authorization groups A–K passed locally in Godot against the staged checkpoint [673f249](https://github.com/ChrisGiggleman/industrial-warfare/commit/673f24952834cdeb676690b6ac2bed41b993b1ff). Aggregate developer confirmation, not independent assistant execution or screenshot review. Accepted: exact scene gating/default-off, original queue and canonical Storage/Press, actual refreshed placement path including unsupported/off-ground/blocked/duplicate rejection, Normal FIFO, distinct empty owned staging and original bill/time, explicit selected and batch Blueprint authorization, cancellation on forced synchronous enrollment failure, disabled admission and exact reservation without stock/time bypass. The prior final combined 56 suites / 785 checks remain accepted; cumulative unique milestone baseline is **57 suites / 796 checks** (not a fresh combined rerun). Manual expansion 9/9 remains separate.

Next gate: F6 the **28 targeted compatibility suites / 374 checks** listed in [DIRECT_BUILD_AUTHORIZATION.md](DIRECT_BUILD_AUTHORIZATION.md). They include 10 historical placement/authorization suites (125 checks, outside the 56-suite baseline) and 18 baseline overlap suites (249 checks). These are reruns, not new milestone tests; do not add 374 to the 796 unique milestone checks. No compatibility execution or result claimed yet. No gameplay, tests, accepted scene, or existing regression manifest changed. After developer confirms compatibility, record Stage A full acceptance and proceed to Stage B real physical Direct Build lifecycle; retain full 56-suite baseline for final combined regression. Stage C manual gameplay remains pending. Main/ordinary scenes and separately gated systems remain unchanged.


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


### 2026-11-20 — E3d5c6b Stage B FULLY ACCEPTED; Stage C manual verification staged (10 pending)

Developer explicitly confirmed **29/29 targeted Stage B compatibility suites and 395/395 checks passed in local Godot** and provided per-suite counts, each matching `tools/building_expansion_final_regression.csv` and the committed Stage B gate (29 unique names, 395 total). These are reruns of accepted expansion suites, not additive. Combined with developer-confirmed **14/14 isolated Stage B physical Direct Build checks**, full Stage B acceptance gate evidence is **30 suite executions / 409 checks** (14 isolated new + 395 overlap reruns), without inventing a fresh full combined regression. Stage A previously fully accepted (11/11 isolated + 28/28, 374/374 compatibility reruns). **Unique milestone baseline remains 58 suites / 810 checks**: 56/785 original expansion, 11 new Stage A, 14 new Stage B. Prior manual expansion 9/9 remains separately accepted. All confirmations are developer-reported local Godot results, not assistant runtime executions.

**Stage C next — manual playable verification:** see [DIRECT_BUILD_STAGE_C_MANUAL.md](DIRECT_BUILD_STAGE_C_MANUAL.md). Run only `res://scenes/core/playable_direct_build_authorization_e3d5c6b.tscn` with **F6**, three independent fresh-play sessions, **10 proposed manual checks A1–A6, B1–B3, C1**. Session A covers Direct Build mode click auto-N Storage/Press, unsupported/duplicate refusal, physical drone transport, generator power pause/resume, actual operational buildings, 15→7 material conservation and recharge. Session B covers Blueprint P planning, Q+drag H priority with no auto-authorization, E selected/single and Ctrl+E batch, mixed priority shared queue, physical completion and 15→4 conservation. Session C verifies a physical loaded cancellation by hovering site and pressing X after collecting five ingots, return storage restores 15 and no Press activates. Manual checks **not run or accepted yet**; no automatic/manual counts added. These sessions use the existing opt-in scene without changing gameplay scripts or prior scenes. **After developer-confirmed Stage C 10/10**, stage fresh final combined regression **58 unique suites / 810 checks** with actual F6 evidence; not yet run. Keep separately gated features untouched: automatic conveyor routing/builds, splitter/merger, poles, multi-trip/fleet, persistence and destruction expansion. No milestone closeout yet.



### 2026-11-20 — E3d5c6b Stage C manual placement blocker (power coverage, not accepted)

Developer screenshot from live `res://scenes/core/playable_direct_build_authorization_e3d5c6b.tscn` shows two Normal queued sites, drone **AT SITE / CARGO 0**, assigned job 0% **Waiting: power, workers**, Starter Storage **12** (down three from 15), generator ON **Hub output 12 / Spare 12**, worker 0/1, battery 28.4/40. This shows physical delivery happened but the worker was not admitted. The right-hand **CONSTRUCTION REQUIREMENTS** read-only panel says stock/power/worker **UNKNOWN (service not connected)** by design; do not interpret that detached panel as an authoritative service error. Screenshot does not establish exact site world coordinates, so do **not** claim a confirmed root cause.

Source inspection: the completed Hub is at **(2,0,-3)** with a **4.5 world-unit coverage radius** (`prototype_main_hub.tscn`); `ConstructionPowerCoverageNetwork.covers_site` and `PrototypeConstructionPowerAllocator._find_covering_node` require **all rotated footprint corners** to be covered, not just a powered generator or site center. The screenshot's drone is visibly at a far-left site instead of either labeled near-Hub plot; **most likely a valid Direct placement was authorized outside full coverage**. Delivery is currently allowed to such queued sites, but power allocation remains zero and the drone may wait there; **do not** loosen the gate, mint resources, or bypass power to make the manual check pass. The approved near-Hub test positions are Test Storage at **(0,0,-3)** and Prototype Ammunition Press at **(4.5,0,-3.5)**, each full footprint within 4.5 of the Hub (with unrotated orientation). The generator ON button reads **Turn generator OFF (test)**.

**Next diagnostic/retest:** Stop F6; restart a fresh scene (15 ingots). Press B then 3, click precisely on the labeled **STORAGE SITE** marker near Hub; 8 and labeled **AMMO PRESS SITE** for second placement. Allow physical delivery and actual escrow admission; confirm `CONSTRUCTION` action, allocated worker 1/1 and nonzero progress before testing generator toggle. Do not count Stage C A5/A6 or 10/10 yet. If waiting persists even at the labeled plot, capture both the scene and Godot Output/Debugger (including the site's exact coordinates/selection) to distinguish coverage from coordinator/admission failure. Record this as evidence, not acceptance. Unique automated baseline remains **58/810**, Stage B fully accepted, Stage C manual pending.


### 2026-11-20 — Stage C screenshot: 12 ingots, drone idle/rearmed, no cargo; distinguish spend from retained staging

Developer reports "drone did not bring back the 3 ingots" after a new live F6 screenshot. Observable left HUD: **Storage 12 ingots (0 reserved); drone IDLE; Battery 40/40; Cargo 0/5; Rearms 1; H/N/L queue 0/0/0; worker 0/1; no eligible site; generator ON, output/spare 12**. This proves the drone ended its assignment and empty inventory was not replenished, **not by itself whether the site completed or was cancelled** (no construction-site state or action history shown; right panel has no selection).

Expected conservation is state-dependent: (1) **Successful canonical Test Storage completion consumes 3 ingots**, leaving starter stock 12 from 15, with completed Storage replacing the site and drone returning empty, fully charged. **No return is expected** after completed construction. (2) **Cancellation while cargo is aboard the drone before unloading** must invoke physically metered return to starter inventory; after return/recharge the 3 ingots should be restored to 15, provided the dock can accept them. (3) **Cancellation after delivery / during construction** occurs with cargo already zero; the already-delivered 3 ingots are protected by the original staging receiver/escrow recovery, not automatically transported back to Starter Storage. Thus 12 starter ingots can be expected even without a completed building, with 3 remaining in locked staging; no automatic staging pickup/unlock exists in this gate. Repository: `BlueprintConstructionMaterialEscrow.commit_built` consumes bill only after `ConstructionJob.State.COMPLETE` and actual building activation; `recover_to` refunds an interrupted escrow to its pinned staging source; accepted Stage B cancellation checks preserve original locked buffers. UI currently does not make retained staging contents or actual "completed vs cancelled" history obvious.

**Next user verification:** Ask whether they pressed X after drone unloading or saw the new Storage become fully operational; inspect the actual built site or any first Output errors before accepting Stage C checks. Do **not** treat screenshot alone as a loss or completed pass. Use separate fresh F6 sessions: complete a single covered Storage (15→12 expected); separately cancel a Press **while Cargo 5/5** (15 restored after physical return). Stage C **10/10 still pending**, unique automated **58/810 remains accepted**, Stage B remains fully accepted. Do not change gameplay or release protected staging for this observation.


### 2026-11-20 — Stage C user confirms incomplete/cancelled site, stock remains 12/15; post-delivery recovery not yet implemented

Developer supplied three consecutive live Godot screenshots: starting sandbox **15 Test Ingots**, one idle drone and no jobs; during play **12 ingots**, **Planned: 3 / Queued: 0** with drone empty/IDLE and **Rearms: 1**; after cancellation **Planned: 0 / Queued: 0**, Starter Storage still **12**, drone empty/IDLE, fully charged. Developer explicitly confirms **construction did not complete**. Correct prior mistaken suggestion that 12 might represent successful Storage material consumption: that possibility is ruled out for this sequence. The three visible PLANNED blueprint sites alone could not debit material; some already-authorized dispatched site consumed the three from source before cancellation. Screenshots alone do not show escrow/staging inventory or pinpoint which site had them; the accepted code and Stage B isolated tests predict uncommitted **3 ingots remain in the cancelled original site's protected staging buffer**, not teleported/refunded to Starter Storage. Do **not** claim independently verified staging contents from these screenshots or mark a material conservation regression without a readout.

Existing source/protocol: `WorldInteraction._cancel_blueprint_site` calls `job.cancel()`; `ConstructionSite._cancel_job_site` queues the site for deletion; `BlueprintConstructionMaterialEscrow._on_cancelled` calls `recover_to`, preserving/refunding into the *pinned staging inventory* if escrowed; `BlueprintConstructionSiteStagingRegistry` retains original claimed staging/port, no release; `PrototypeDroneAutomaticDispatch` returns its **empty** delivered drone to Hub to recharge/rearm. `docs/DRONE_CONSTRUCTION_LOGISTICS.md` explicitly keeps **future physical recovery flights from cancelled delivered site staging** separately gated; presently no accepted service performs staged-material pickup and return. By contrast **cancelled loaded drone cargo** is physically returned to reserved eligible dock, and an actually **completed building commits** its material bill (stock 12 is then expected). Therefore this is a **real gap between the intended player recovery experience and currently implemented experimental scope**, not proof of deleted inventory. Do not silently refund or unlock a claimed buffer to satisfy manual testing.

Stage C manual 10-check gate still **pending**. Test A covered-building completion at labeled Storage position and check worker 1/1, 15→12 only after actual completion. Test C1 in separate fresh F6, cancel Press **while drone CARGO 5/5 before unload** and verify physical return restores 15. Add optional non-counted observation for cancellation **after** unload: donor Storage remains debited, drone empty, materials expected in protected staging, no playable physical recovery available yet. For full player-expected cancellation recovery, design/implement a separately opt-in `E3d5c6c` or subsequent subgate with exact original site identity, physical staged pickup, destination capacity reservation, finite drone battery and movement, cancel-safe atomic transfer, conservative retry when blocked, and no release/duplicate claims without provenance. Consider explicit HUD for staged quantities and power coverage, but do not merge experimental features into Main. Baseline remains **58 unique suites / 810 automated checks**, Stage A/B fully accepted; no new Godot verification, Stage C acceptance, compatibility or final regression claimed.


### 2026-11-20 — E3d5c6b Stage C manual: powered-site Test Storage completed (partial gate evidence)

Developer supplied a live Godot screenshot and explicitly said “it built the storage” after repositioning the direct Storage placement near the labeled `STORAGE SITE` within the completed Hub's full-footprint 4.5-unit power coverage. Screenshot shows a new Storage mesh/port next to Starter Storage and Hub, Starter Storage **12 ingots** (from 15; canonical Storage bill 3), drone **IDLE** with **cargo 0/5**, **battery 40/40**, **Rearms 1**, zero planned/queued/active jobs, and generator output/spare **12**. This supports manual Storage direct-placement/completion and same-drone return/recharge at an appropriately powered location, and explains why no 3-ingot return occurs for successful building completion. It does **not** independently verify progress pausing with generator OFF, Press build, or the complete Stage C A1–A6 set; do not claim 10/10 manual acceptance. The earlier cancelled-after-delivery staging case remains separate and physical staged-item recovery remains a future gated feature.

Next manual action **in the same live fresh session**: use Ammunition Press hotbar (check actual assignment via M if needed), click marked `AMMO PRESS SITE`, observe real five-ingot pickup and delivery, wait for actual `CONSTRUCTION` with worker 1/1, turn generator OFF to verify pause and ON to verify resume, then complete Press with starter stock expected **7** (15−3−5). Do not turn power OFF before worker admission. If the Press is blocked or a diagnostic error occurs, capture the live HUD and first Output/Debugger error rather than altering rules. Stage B fully accepted; unique automated baseline **58/810** unchanged; Stage C manual gate pending.


### 2026-11-20 — E3d5c6b Stage C: Test Storage and Ammunition Press visibly complete, exact 15→7 material accounting

Developer supplied a new playable Godot screenshot of `res://scenes/core/playable_direct_build_authorization_e3d5c6b.tscn`: visible completed Test Storage adjacent to Starter Storage and a dark operational-looking Ammunition Press structure to the right of the Hub. Left live automatic construction HUD: Starter Storage **7 ingots (0 reserved)**, drone **IDLE / Cargo 0/5**, **battery 40/40**, **Rearms 2**, **Queue H/N/L 0/0/0**, generator output/spare **12**, worker slots **0/1**. These match the expected two separate successful physical construction cycles and original bills: starting 15 − Storage 3 − Press 5 = **7 ingots**. The user provided screenshot rather than a separate narrated checklist; screenshot supports visual completion/material accounting and return/recharge, but does not independently demonstrate generator OFF pause and ON resume during active work, unsupported building rejection, same-footprint duplicate click rejection, three planned-only blueprint placements, explicit selection/batch authorization, or loaded Press cancellation. Therefore do **not** record full Stage C 10/10 acceptance or final combined 58/810 rerun. Stage A and Stage B remain fully accepted, unique automated baseline **58 suites / 810 checks**.

Next user manual gates: **Fresh F6** for generator OFF/ON *while* Storage or Press is constructing (verify worker 1/1, progress stops then resumes); confirm unsupported/duplicate click rejection. After that, **fresh F6** Session B blueprint planning with P/Q/H/E/Ctrl+E and exact 15→4 conservation, followed by **fresh F6** Session C cancelled *loaded cargo* (Press Cargo 5/5, X before unloading; physical return restores Starter Storage to 15). Distinguish this from already-confirmed cancelled-after-delivery protected staged materials (not automatically recovered yet; separately gated feature). No gameplay or test modifications in this documentation checkpoint.


### 2026-11-20 — Stage C generator-OFF pause verified; cancelled delivered Storage material recovery gap reproduced

Developer supplied two local playable screenshots and reports: `power off work but if you cancel the building the ingots do not get returned`. During powered-site third Test Storage construction, the live HUD shows **job progress 10% / PAUSED 1**, **Hub output 0 / Spare 0**, **Worker slots 0/1**, drone **AT SITE / Cargo 0**, Starter Storage **4 ingots**. Generator button says **Turn generator ON (test)**. After pressing X, Output shows **BLUEPRINT CANCELLED**; queue and pause count drop to 0, drone returns empty and is **DOCKED / DOCK WAIT** with **Battery 28.4/40**, no return reservation, **Rearms 2** unchanged, still **4** ingots and generator still OFF. Thus **power OFF pausing is observed and the cancellation/refund-to-Starter-Storage gap is confirmed in gameplay**. Power-ON resume of this particular job has NOT been demonstrated; generator OFF means charging is unavailable and explains DOCK WAIT, but would not automatically recover the empty drone's former delivery.

Source-backed distinction: if the third Storage had actually completed, its 3-ingot bill would be consumed; here the job was cancelled while 10% complete. The accepted escrow/cancellation code returns the uncommitted bill to the **pinned protected original site staging buffer**, not Starter Storage. The screenshot does not display or independently prove the staged buffer amount; staged custody is supported by original source behavior and accepted automated cancellation checks. Existing physical return logic only handles material still aboard the drone. Returning physically delivered and then cancelled materials is a **deliberately unimplemented gameplay capability** and needs strict provenance, token-bound pickup, destination capacity, finite flight/charge and conservative ownership. No claim that stock was irretrievably destroyed.

New proposed design [CANCELLED_SITE_PHYSICAL_RECOVERY.md](CANCELLED_SITE_PHYSICAL_RECOVERY.md) labels this next separate **E3d5c6c** gate (design only): A terminal provenance/escrow audit, B physical single-load pickup and return, C opt-in playable automatic recovery, D compatibility/closeout. No gameplay/test code changed, no implementation/test result claimed. Do not alter Main/ordinary scenes, remove protected registry locks, teleport refund or weaken power coverage. E3d5c6b Stage C original manual 10-check gate still open; its *loaded-cargo* C1 recovery remains distinct from the new *post-delivery* gap. Unique automated accepted **58/810**, Stage A/B accepted, final fresh 58/810 not run.


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


### 2026-11-20 — E3d5c6c Stage A FULLY ACCEPTED; Stage B isolated physical recovery starts

Developer confirmed the corrected final `playable_direct_build_authorization_e3d5c6b_stage_b_test.tscn` **all 14/14 A–N passed locally in Godot**, resolving the half-grid WAIT_POS silent exit. The other 14 suites in the sequential E3d5c6c Stage A compatibility gate had been completed previously; together **15/15 compatibility suites / 218/218 checks are accepted** with manifest `tools/cancelled_site_custody_stage_a_compatibility.csv`. The **13/13 isolated cancelled-site custody audit checks** were already locally accepted. Full Stage A gate: 16 suite runs / **231/231** checks; the 218 reruns overlap previously accepted suites and must **not** inflate the unique baseline. Current cumulative unique automated milestone baseline: **59 suites / 823 checks** (E3d5c6a 56/785; E3d5c6b 11+14; E3d5c6c Stage A 13). No new fresh full 59/823 combined run claimed. E3d5c6b Stage C 10 manual checks remain pending.

**Stage B goal:** default-OFF, exact-scoped terminal-site physical recovery using the original ONE charged drone after previous assignment rearms. Source is the Stage A immutable cancelled-site ticket, original staging/port and actual inventory after escrow refund. Reserve exact destination storage capacity before any source debit. A guarded drone flight must first reach the original site hover before removing 3 or 5 actual ingots, then visibly carry them to a real registered Storage dock and unload with the reserved capacity token, respecting battery/finite recharge and never touching complete-building bills. Preserve original staging locks. No asynchronous separate process/worker/timer, no power/free inventory, no silent fallback or automatic installation in Main/accepted scenes. Stage B implementation and tests require isolated F6 and compatibility gates; **no new acceptance claimed** by this Stage A documentation checkpoint.


### 2026-11-20 — E3d5c6c Stage B physical recovery implementation STAGED (13 isolated checks pending F6)

Stage A full local acceptance **13/13 isolated + 15/15 targeted compatibility suites / 218/218 rerun checks** was recorded immediately before this stage, against last suite's corrected PASS A–N. Cumulative unique accepted milestone baseline remains **59 suites / 823 checks**. Stage B runtime is **NOT yet Godot-executed or accepted**.

A separately gated transport implementation now exists at `scripts/components/prototype_cancelled_site_recovery_transport.gd`. It has **no `_process` and no automatic registration in scenes**. It is instantiated manually only in the isolated F6 test. Default-off method additions in `PrototypeConstructionWorkerDrone` append unique `STAGED_*` flight states without renumbering existing states, and meter battery distance on home→original site hover→real Storage dock→home legs. The Stage A custody audit remains read-only in its accepted default configuration; a **second default-off** companion-only `_recovery_source_for` API exposes the original escrow-settled locked buffer only to the exact configured recovery controller.

Terminal ticket source identity, original site/job/port/buffer and hover are verified before each pre-pickup tick. The idle, fully charged, finite-battery original drone must be free of the prior construction assignment, and the original adapter must have `set_process(false)` in this isolated fixture: no simultaneous drone driving, job authorization, worker or timer. A real registered Storage dock reserves an exact incoming capacity token before pickup. Physical debit of canonical **3 Storage or 5 Press Test Ingots** happens only after the drone arrives at the original site hover. The drone carries actual cargo to a dock and deposits only on verified physical arrival via `InventoryComponent.consume_drone_return_claim(token)`. The original staging claim stays locked after recovery. A failed or full return dock leaves custody protected; mid-flight invalid destinations hold cargo until valid. The drone flies home, recharges with real finite Hub generation, then re-arms. No instant refund, staging unlock, silos or other construction types.

New isolated F6 scene `res://tests/cancelled_site_physical_recovery_e3d5c6c_stage_b_test.tscn` has **13 proposed checks A–M**: A source cancelled 3-ingot delivery and original custody; B wrong IDs/default off; C capacity reserve before debit; D real outbound battery flight; E actual site pickup and locked staging; F blocked dock wait with cargo held; G real return and blocked unload; H 12→15 exact reserved physical deposit; I return home and generator-OFF charging block; J same drone finite recharge and one-time ticket; K full escrow refund of cancelled Press 5; L full Storage capacity and moved original receiver fail closed; M true physical 5-ingot return, finite recharge, conserved 15 and duplicate refusal. Expected banner: `ALL 13 CANCELLED SITE PHYSICAL RECOVERY E3D5C6C STAGE B TESTS PASSED`.

**No local parse/F6 checks have run yet.** If the fixture fails, record first error and PASS groups and fix before targeted compatibility. After developer confirms all 13, record isolated acceptance, perform focused regression of existing custody, return, charging and Direct Build physical lifecycle suites, then separately gate Stage C playable automatic recovery. The accepted `playable_direct_build_authorization_e3d5c6b.tscn`, Main, ordinary scenes, existing tests and E3d5c6a 56/785 manifest remain unchanged. Do not claim restored cancellation materials in gameplay yet. E3d5c6b Stage C manual 10-check gate is still open; final fresh combined regression also pending.


### 2026-11-21 — E3d5c6c Stage B isolated 13/13 ACCEPTED; targeted compatibility 26/368 PENDING

Developer explicitly confirmed **all 13/13** `cancelled_site_physical_recovery_e3d5c6c_stage_b_test.tscn` checks A–M passed locally in Godot. This verifies the **isolated, default-off** physical recovery implementation: a real cancelled-site custody ticket, actual 3/5-ingot original locked staging debit only when the drone reaches the original hover, one real charged drone, exact reserved return capacity at registered Storage, finite flights and battery, safe wait on unavailable dock, actual unloading at dock, return/recharge/rearm and no duplicate material or mission. These are **developer-reported local Godot results, not assistant-executed tests**. E3d5c6c Stage A was already fully accepted (13 isolated + 15/218 compatibility reruns).

Unique automated baseline advances from **59/823** to **60 suites / 836 checks** (+ one new 13-check Stage B suite); no full fresh combined 60/836 regression has been executed. New Stage B compatibility guide: [CANCELLED_SITE_RECOVERY_STAGE_B_COMPATIBILITY.md](CANCELLED_SITE_RECOVERY_STAGE_B_COMPATIBILITY.md), manifest `tools/cancelled_site_physical_recovery_stage_b_compatibility.csv`: **26 existing suites / 368 existing checks**, all scene paths verified on main. Covers original drone flight/battery, staging/port provenance, escrow, registered Storage capacity, supplier and return claims, physical pickup/delivery, finite charging and worker reuse, all cancellation phases, automatic dispatch/lifecycle, Direct Build isolated A/B and Stage A custody audit. These checks **have not been rerun for Stage B**, so Stage B is **isolated accepted but compatibility PENDING**. Their 368 checks overlap accepted suites; do NOT add to unique 836.

No gameplay source changes in this acceptance-documentation gate. Main and old Direct Build playable scene do NOT yet auto-dispatch a staged-material recovery flight. After explicit 26/368 developer acceptance, progress to **E3d5c6c Stage C** in a separate opt-in playable recovery scene, reusing original single-drone dispatch ownership without a parallel driver. E3d5c6b Stage C manual gate 10/10 remains independently pending. Keep research silo/docking expansion, auto conveyor/merger, multi-item/trip/fleet, persistence and destruction separately gated.
