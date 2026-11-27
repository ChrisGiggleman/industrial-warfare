# Industrial Warfare — Current Development Handoff

2026-11-27: Developer confirmed all 10/10 isolated C5P-B1 F6 labeled sections passed locally after freed-object guard correction at 1b3908f7e23820cbea8d69c78742c3a30fdc1578 (local HEAD and logs not independently inspected). Isolated acceptance only. Historical 73/997 plus new isolated 1/10 = cumulative unique 74/1007, not fresh full regression. Targeted compatibility gate: 43 existing suites / 606 manifest-expected sections in 3 waves; all pending. No gameplay, existing tests, historical manifest or Main changes. B2/B3 remain blocked pending B1 compatibility acceptance and separate implementation approval.

### 2026-11-27 — C5P-B1 candidate implementation; local F6 pending

Approved isolated battery-independent worker/dock/route mode implemented as candidate; legacy default preserved, B2/B3 follow-on stages not authorized. [B1 test and implementation notes](DRONE_ROLE_SPECIALIZATION_E3D5C6F_STAGE_C5P_B1.md). New ten-section fixture UNRUN; historical accepted baseline remains 73/997. Main and prior tests preserved. No new acceptance.


### 2026-11-26 — C5P-A simplified drone power design checkpoint

C5A remains developer-confirmed 73/73 suites / 997/997 manifest-expected sections; manifest independently recounted. C5B original battery-dependent sandbox proposal is on hold. Targeted read-only source audit at 36cdef6fab1bd9815986dfe925ce434b57c11a8a identified battery coupling in worker movement, discovery/reservations/recovery, B2/B3, docking and dispatch; pre-delivery power cannot depend on escrow-gated allocation. [C5P-A audit and scoped implementation proposal](DRONE_ROLE_SPECIALIZATION_E3D5C6F_STAGE_C5P_AUDIT.md) awaits explicit implementation approval. Approved direction: automated drones use destination/site power, not individual batteries/charging/path coverage; suspend on outage, preserve original cargo/escrow/progress, physically return and resume. Power extensions need no site power, but must be within valid completed network link range; scoped bootstrap/restoration exception proposed. Future backlog: construction drones repair surviving buildings automatically, free time-limited default with optional material cost; configurable per-world demolition refund 0–100% (recommended custom default 100%), stored inventory recovered separately, unconsumed cancellation materials returned, no enemy-destruction construction refund by default; world difficulty settings and player-controlled exploration batteries later. No gameplay, Main, accepted tests or manifest changes; no new Godot runs or accepted counts. Next: approve staged C5P implementation, isolated tests, compatibility/full regression, revised C5B, then separate Main review.


### 2026-11-26 — C5A FULL FRESH REGRESSION ACCEPTED; C5B proposal ready

2026-11-26: Developer confirmed C5A Wave 4 13/13 F6 scenes passed locally in Godot against 161 manifest-expected sections. Waves 1–3 previously accepted 20/245, 20/333, 20/258. C5A FRESH FULL REGRESSION ACCEPTED: 73/73 unique suites and 997/997 manifest-expected sections (20+20+20+13; 245+333+258+161). Supersedes B4 fresh 68/923; cumulative unique accepted baseline remains 73/997. Runtime revision expected C4B implementation bed2c8dd4189d5fc1c2a9572134e5ef761a1723c plus documentation checkpoints; local HEAD and individual assertion logs not independently inspected. C5B interactive sandbox implementation proposal ready for explicit approval; smoke and manual checks PENDING. Main, existing runtime, accepted scenes/tests, manifest, local edits and draft PR #1 preserved; no merge. [C5B sandbox implementation proposal](DRONE_ROLE_SPECIALIZATION_E3D5C6F_STAGE_C5B_PLAN.md).


### 2026-11-26 — C5A Wave 3 ACCEPTED; final Wave 4 ready

2026-11-26: Developer confirmed C5A Wave 3 all 20/20 F6 scenes passed locally in Godot against 258 manifest-expected sections. Waves 1 and 2 remain accepted 20/245 and 20/333. Fresh C5A progress 60/73 suites and 836/997 expected sections; cumulative unique accepted baseline 73/997 unchanged. Runtime revision expected to remain C4B implementation bed2c8dd4189d5fc1c2a9572134e5ef761a1723c plus documentation checkpoints; actual local HEAD and assertion logs not independently inspected. Final Wave 4: 13 scenes / 161 expected sections PENDING; on acceptance fresh progress 73/73 and 997/997. C5B manual sandbox implementation/verification pending separate approval. No gameplay, manifest, existing tests or Main changes. Draft PR #1 remains unmerged.


### 2026-11-26 — C5A Wave 2 ACCEPTED; Wave 3 ready

2026-11-26: Developer confirmed C5A Wave 2 all 20/20 F6 scenes passed locally in Godot against 333 manifest-expected sections. Wave 1 remains accepted 20/245. Fresh C5A progress 40/73 suites and 578/997 expected sections; cumulative unique accepted baseline 73/997 unchanged. Runtime revision expected to remain C4B implementation bed2c8dd4189d5fc1c2a9572134e5ef761a1723c plus documentation checkpoints; actual local HEAD and assertion logs not independently inspected. Wave 3: 20 scenes / 258 expected sections PENDING; on acceptance fresh progress 60/73 and 836/997. Wave 4 and C5B manual sandbox implementation/verification pending. No gameplay, manifest, existing tests or Main changes. Draft PR #1 remains unmerged.


### 2026-11-26 — C5A Wave 1 ACCEPTED; Wave 2 ready

2026-11-26: Developer confirmed C5A Wave 1 all 20/20 F6 scenes passed locally in Godot against 245 manifest-expected sections, using C5 manifest prepared at 5f32bd84fa9f973381f22754884649a82753352e. Fresh C5A progress 20/73 suites and 245/997 expected sections; cumulative unique accepted baseline 73/997 unchanged. Runtime revision expected to remain C4B implementation bed2c8dd4189d5fc1c2a9572134e5ef761a1723c plus documentation checkpoints; actual local HEAD and assertion logs not independently inspected. Wave 2: 20 scenes / 333 expected sections PENDING; on acceptance fresh progress 40/73 and 578/997. Waves 3–4 and C5B manual sandbox implementation/verification pending. No gameplay, manifest, existing tests or Main changes. Draft PR #1 remains unmerged.


### 2026-11-25 — C4B FULLY ACCEPTED; C5 verification prepared

Developer confirmed C4B compatibility 53/53 F6 scenes passed locally against 751 manifest-expected sections on 2026-11-25, following isolated 14/14. C4B FULLY ACCEPTED: 54 gate scene runs / 765 associated sections; compatibility overlaps prior accepted coverage. Unique accepted coverage 73 suites / 997 expected sections; last fresh full regression B4 68/923. Assistant did not run Godot or inspect assertion logs. C5A fresh full 73/997 regression PENDING. C5B manual playable verification requires a separately approved isolated harness; existing specialized scene is inert B1 by default, has no player-facing controls or camera, and B2/B3/C stages require explicit fixture setup and manual ticks. No C5 gameplay or harness implementation yet; no manual acceptance. [C5 verification plan](DRONE_ROLE_SPECIALIZATION_E3D5C6F_STAGE_C5_PLAN.md). Documentation-only checkpoint; Main, existing gameplay, accepted scenes/tests, local edits and draft PR #1 preserved.


### 2026-11-25 — C4B isolated ACCEPTED; compatibility PENDING

Developer confirmed C4B isolated F6 14/14 labeled sections passed locally in Godot against implementation commit bed2c8dd4189d5fc1c2a9572134e5ef761a1723c on 2026-11-25. Cumulative unique accepted coverage 73 suites / 997 expected sections (B4 68/923 + C1 1/12 + C2 1/16 + C3 1/18 + C4A 1/14 + C4B 1/14); last fresh full regression remains B4 68/923. C4B targeted compatibility 53 existing suites / 751 manifest-expected sections PENDING; reruns overlap accepted coverage. Assistant did not run Godot or inspect individual assertion logs. C5 gated on local compatibility acceptance; Main, prior scenes/tests, local edits and unmerged draft PR #1 preserved. [Compatibility guide](DRONE_ROLE_SPECIALIZATION_E3D5C6F_STAGE_C4B_COMPATIBILITY.md).


### 2026-11-25 — C4B implementation staged; F6 PENDING

Developer approved C4B. Implemented default-off terminal builder cancellation at C4A flight/work/parking/parked including resume, exact revoked builder-bearing receipt, coordinator cleanup, metered empty right berth retirement without recharge, one B3→B2 token hand-back, original C3 custody ticket/escrow and existing physical recovery/finite charging. New isolated F6 res://tests/specialized_drone_builder_cancel_e3d5c6f_c4b_test.tscn 14 labeled sections A–N PENDING local execution. No assistant Godot run. Explicit controller cancel only; no generalized reroute, dynamic relocation or source destruction; retired builder stays DOCKED and disabled, retains charging registration history but cannot charge. Accepted baseline 72/983; fresh B4 68/923. Main and prior scenes/tests unchanged. C5 gated.


### 2026-11-25 — C4A FULLY ACCEPTED; C4B proposal

Developer confirmed C4A compatibility 40/40 F6 scenes passed locally against 581 manifest-expected sections on 2026-11-25, following isolated 14/14. C4A FULLY ACCEPTED: 41 gate scene runs / 595 associated sections; 40/581 overlap prior accepted coverage. Unique accepted coverage 72 suites / 983 expected sections; last fresh full B4 68/923 remains distinct. Assistant did not run Godot or inspect assertion logs. C4B awaits explicit implementation approval. [C4B implementation plan](DRONE_ROLE_SPECIALIZATION_E3D5C6F_STAGE_C4B_PLAN.md). Documentation-only checkpoint; Main, prior scenes/tests, local edits and unmerged draft PR #1 preserved. No C4B gameplay or F6 fixture yet.


### 2026-11-25 — C4A isolated ACCEPTED; compatibility PENDING

Developer confirmed C4A isolated F6 14/14 labeled sections passed locally in Godot against implementation commit 18391041722c4ae2fc4ff4f92645f7930b43f4b0 on 2026-11-25. Cumulative unique accepted coverage 72 suites / 983 expected sections (B4 68/923 + C1 1/12 + C2 1/16 + C3 1/18 + C4A 1/14); last fresh full regression remains B4 68/923. C4A targeted compatibility 40 existing suites / 581 manifest-expected sections PENDING; reruns overlap accepted coverage. Assistant did not run Godot or inspect individual assertion logs. C4B gated on local compatibility acceptance; Main, prior scenes/tests, local edits and unmerged draft PR #1 preserved. [Compatibility guide](DRONE_ROLE_SPECIALIZATION_E3D5C6F_STAGE_C4A_COMPATIBILITY.md).


### 2026-11-25 — C4A implementation staged; F6 PENDING

Developer approved C4A. Default-off specialized builder admission from C3 docked delivery, exact original custody ticket and one owner transfer, separate right berth finite registration on existing shared allocator, active receipt validation across queued/constructing/paused, physical blackout parking/resume with preserved progress/escrow and existing scheduler binding, normal completion and empty return. New isolated F6 res://tests/specialized_drone_builder_blackout_e3d5c6f_c4a_test.tscn 14 labeled sections A–N PENDING local execution. No assistant Godot run. Terminal cancellation/hand-back deferred C4B; no generalized dynamic site relocation or automatic reroute. Accepted baseline 71/969; fresh B4 68/923. Main and prior scenes/tests unchanged.


### 2026-11-25 — C3 FULLY ACCEPTED; C4 proposal

Developer confirmed C3 compatibility 44/44 F6 scenes passed locally against 623 manifest-expected sections on 2026-11-25, following isolated 18/18. C3 FULLY ACCEPTED: 45 gate scene runs / 641 associated sections; 44/623 overlap prior accepted coverage. Unique accepted coverage 71 suites / 969 expected sections; last fresh full B4 68/923 remains distinct. Assistant did not run Godot or inspect assertion logs. C4 awaits explicit implementation approval. [C4 implementation plan](DRONE_ROLE_SPECIALIZATION_E3D5C6F_STAGE_C4_PLAN.md). Documentation-only checkpoint; Main, prior scenes/tests, local edits and unmerged draft PR #1 preserved. No C4 gameplay or F6 fixtures yet.


### 2026-11-25 — C3 isolated ACCEPTED; compatibility PENDING

Developer confirmed C3 isolated F6 18/18 labeled sections passed locally in Godot against implementation commit 33ddb5288f51b8c3dd45c2d36cf999a8980cd8c1 on 2026-11-25. Cumulative unique accepted coverage 71 suites / 969 expected sections (B4 68/923 + C1 1/12 + C2 1/16 + C3 1/18); last fresh full regression remains B4 68/923. C3 targeted compatibility 44 existing suites / 623 manifest-expected sections PENDING; reruns overlap accepted coverage. Assistant did not run Godot or inspect individual assertion logs. C4 gated on local compatibility acceptance; Main, prior scenes/tests, local edits and unmerged draft PR #1 preserved. [Compatibility guide](DRONE_ROLE_SPECIALIZATION_E3D5C6F_STAGE_C3_COMPATIBILITY.md).


### 2026-11-25 — C3 implementation staged; F6 PENDING

Developer approved C3; implementation staged with default-off exact specialized controller, original custody audit, escrow refund/retry, terminal empty return, existing staged recovery transport without dispatcher, whole-route destination capacity forecast and protected physical pickup/deposit. Invalid destination during staged mission deliberately waits with existing claim and custody; automatic rerouting/deleted destination before deposit not implemented. Home after deposit independent of dock. Explicit controller cancellation captures ticket before job.cancel; external direct job.cancel without capture is not integrated. New isolated F6 res://tests/specialized_drone_staging_recovery_e3d5c6f_c3_test.tscn 18 labeled sections A–R PENDING local execution. No assistant Godot run. Accepted baseline 70/951; fresh B4 68/923. Main and prior scenes/tests unchanged. C4 remains gated.


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


Updated 2026-11-24. Repository: ChrisGiggleman/industrial-warfare, main. Godot 4.6.2, GDScript, Forward+.
Read this first when resuming a new conversation. GitHub history and actual source take precedence over chat recollection; verify main HEAD and any local changes before making edits.

## Current checkpoint

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

### 2026-11-22 — Resource and power expansion sequencing RECOMMENDATION (not implementation authorization)

Before the next chat, developer asked whether to add more ore varieties and coal/solar/wind power now or later. **Recommendation: defer these additions until after E3d5c6d unified construction gameplay integration**, while ensuring the integration architecture remains extensible to additional item definitions, fuel-consuming generators and multiple power producers. This is a **sequencing recommendation**, not a final balance specification or approved code task. No gameplay source or tests changed.

**Existing, not new:** prototype **Test Ore** finite/infinite world deposits and physical extractor, `2 Test Ore → 1 Test Ingot` Smelter recipe, separate `1 Test Ingot → 4 Prototype Rounds` Press prototype, physical conveyor logistics, finite Hub power/coverage and drone charging already have documented accepted paths. The Main Hub currently provides bootstrap electricity; alternate generator types are *not* claimed implemented.

**Next proposed progression:** (1) E3d5c6d exact-scope unified Direct Build / Blueprint / drones / cancellation and power; (2) close the small ore → ingot → ammunition → defensive-supply vertical-slice loop using existing prototype resource systems, retaining finite material accounting; (3) introduce additional resource definitions/deposits/machine recipes gradually (candidate **iron ore**, **copper ore** and **coal**; do not rename the existing `Test Ore` IDs casually); (4) add functional buildable power distribution and **one fuel-fed coal generation option** with verified physical fuel use, finite output and safe blackout/restart; only afterward explore **solar** daylight variability, **wind** availability, battery storage and power management, all gated separately. Electricity travels by the power network, solid fuel by conveyors, no remote free resource or charge teleportation.

These resource/power phases should be separately proposed and tested, rather than changing Main or accepted 61-suite/850-check current source while starting E3d5c6d. First playable zombie-planet vertical-slice priority remains an **understandable physical ore-to-ammunition-to-defense chain** rather than numerous item/power types without gameplay integration. Consult `GAME_VISION.md`, `GAME_DESIGN.md`, `CONSTRUCTION_AND_POWER_ARCHITECTURE.md`, and `DRONE_CONSTRUCTION_LOGISTICS.md` before implementing any generator or new ore.

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

### 2026-11-21 — E3d5c6c Stage C opt-in playable automatic recovery STAGED (historical; superseded by 14/14 acceptance above)

After developer-confirmed Stage B acceptance (isolated 13/13 + targeted 26/26 suites / 368/368 existing checks), committed a **separate new experimental playable scene** `res://scenes/core/playable_cancelled_site_recovery_e3d5c6c_stage_c.tscn` and a new `PlayableCancelledSiteRecoveryE3d5c6cStageC` adapter subclass. The original Direct Build playable scene, Main and accepted base adapter remain unchanged. The subclass captures each originally authorized real Storage/Press site's locked custody before X cancellation, waits until the original normal construction lifecycle has released/rearmed the one drone, then calls the accepted Stage B physical recovery mission through its **sole adapter process driver**. It does NOT tick original dispatch concurrently, unlock staging, or instant-refund cargo. Capacity/dock/energy refusal leaves materials in original custody and retries; return and finite Hub charging are physical.

The accepted custody/transport modules received strict extra Stage C scene allowlisting; playable processing is allowed only for the exact named Stage C subclass adapter. `WorldInteraction._direct_build_scope` also received the exact Stage C scene path so new-scene Direct Build cannot fall through to the legacy placement path. Both remain default-off in all other scenes. New F6 integration scene `res://tests/playable_cancelled_site_recovery_e3d5c6c_stage_c_test.tscn` proposes **14 checks A–N**, covering original Direct Storage and Press delivery/cancellation, automatic return without manually starting the transport, dock blocking, full-capacity waiting, conservation, generator-off charging block and single-drone reuse. See [full F6/manual guide](CANCELLED_SITE_RECOVERY_STAGE_C_PLAYABLE.md).

**STAGED ONLY, GODOT F6 AND MANUAL PLAYABLE VERIFICATION NOT RUN.** Cumulative unique ACCEPTED baseline remains **60/836**. Provisional AFTER local Stage C isolated 14/14 would become 61/850 unique. Then rerun 26 existing compatibility suites/368 checks plus Stage B isolated 13-check scene and complete manual playable verification. E3d5c6b separately pending manual 10-check gate stays pending. No fresh combined regression claimed.

### 2026-11-21 — E3d5c6c Stage B FULLY ACCEPTED (26/26 targeted compatibility; 368/368 rerun checks)

Developer confirmed **all 26/26 targeted Stage B compatibility suites and 368/368 existing checks passed locally in Godot 4.6.2** using `tools/cancelled_site_physical_recovery_stage_b_compatibility.csv`. This is **developer-reported local execution, not an assistant-run test**. Previously accepted Stage B isolated physical recovery **13/13** and Stage A isolated custody **13/13** plus its 15/218 targeted compatibility are preserved. Stage B is now **fully accepted**, isolated plus targeted compatibility. The 368 rerun checks overlap previously counted accepted suites; **unique accepted automated milestone baseline remains 60 suites / 836 checks**, not 1,204 checks. No claim of a fresh combined full 60/836 regression.

**NEXT — E3d5c6c Stage C: opt-in playable automatic cancelled-site recovery**, separate experimental scene. Same single original drone, original immutable Stage A ticket, original hover pickup of 3 Storage / 5 Press ingots, exact Storage space claim, real transport + finite recharge, safe waits and no duplicate drivers. Do **not** assert playable Stage C works until separately implemented and Godot-tested. Existing playable Direct Build scene and Main remain unchanged. E3d5c6b separate manual Stage C 10/10 gate is still pending.

**E3d5c6c Stage C isolated ACCEPTED 14/14 locally; Stage C compatibility 27/27 suites and 381/381 existing checks ACCEPTED; manual gameplay 10 checks PENDING. Stage B FULLY ACCEPTED (13/13 + 26/368), Stage A FULLY ACCEPTED (13/13 + 15/218). Unique automated accepted baseline 61 suites/850 checks; no fresh full combined regression. E3d5c6b manual Stage C separately open.** [Exact F6 list](CANCELLED_SITE_RECOVERY_STAGE_B_COMPATIBILITY.md)

### 2026-11-21 — E3d5c6c Stage B isolated 13/13 ACCEPTED; targeted compatibility 26/368 PENDING

Developer explicitly confirmed **all 13/13** `cancelled_site_physical_recovery_e3d5c6c_stage_b_test.tscn` checks A–M passed locally in Godot. This verifies the **isolated, default-off** physical recovery implementation: a real cancelled-site custody ticket, actual 3/5-ingot original locked staging debit only when the drone reaches the original hover, one real charged drone, exact reserved return capacity at registered Storage, finite flights and battery, safe wait on unavailable dock, actual unloading at dock, return/recharge/rearm and no duplicate material or mission. These are **developer-reported local Godot results, not assistant-executed tests**. E3d5c6c Stage A was already fully accepted (13 isolated + 15/218 compatibility reruns).

Unique automated baseline advances from **59/823** to **60 suites / 836 checks** (+ one new 13-check Stage B suite); no full fresh combined 60/836 regression has been executed. New Stage B compatibility guide: [CANCELLED_SITE_RECOVERY_STAGE_B_COMPATIBILITY.md](CANCELLED_SITE_RECOVERY_STAGE_B_COMPATIBILITY.md), manifest `tools/cancelled_site_physical_recovery_stage_b_compatibility.csv`: **26 existing suites / 368 existing checks**, all scene paths verified on main. Covers original drone flight/battery, staging/port provenance, escrow, registered Storage capacity, supplier and return claims, physical pickup/delivery, finite charging and worker reuse, all cancellation phases, automatic dispatch/lifecycle, Direct Build isolated A/B and Stage A custody audit. These checks **have not been rerun for Stage B**, so Stage B is **isolated accepted but compatibility PENDING**. Their 368 checks overlap accepted suites; do NOT add to unique 836.

No gameplay source changes in this acceptance-documentation gate. Main and old Direct Build playable scene do NOT yet auto-dispatch a staged-material recovery flight. After explicit 26/368 developer acceptance, progress to **E3d5c6c Stage C** in a separate opt-in playable recovery scene, reusing original single-drone dispatch ownership without a parallel driver. E3d5c6b Stage C manual gate 10/10 remains independently pending. Keep research silo/docking expansion, auto conveyor/merger, multi-item/trip/fleet, persistence and destruction separately gated.

**E3d5c6c Stage A FULLY ACCEPTED (13 isolated plus 15/218 compatibility reruns). Stage B isolated physical cancelled-site recovery STAGED, F6 13/13 pending. Unique accepted baseline 59/823. Original playable scene has NO new automatic recovery yet.**

### 2026-11-20 — E3d5c6c Stage B physical recovery implementation STAGED (13 isolated checks pending F6)

Stage A full local acceptance **13/13 isolated + 15/15 targeted compatibility suites / 218/218 rerun checks** was recorded immediately before this stage, against last suite's corrected PASS A–N. Cumulative unique accepted milestone baseline remains **59 suites / 823 checks**. Stage B runtime is **NOT yet Godot-executed or accepted**.

A separately gated transport implementation now exists at `scripts/components/prototype_cancelled_site_recovery_transport.gd`. It has **no `_process` and no automatic registration in scenes**. It is instantiated manually only in the isolated F6 test. Default-off method additions in `PrototypeConstructionWorkerDrone` append unique `STAGED_*` flight states without renumbering existing states, and meter battery distance on home→original site hover→real Storage dock→home legs. The Stage A custody audit remains read-only in its accepted default configuration; a **second default-off** companion-only `_recovery_source_for` API exposes the original escrow-settled locked buffer only to the exact configured recovery controller.

Terminal ticket source identity, original site/job/port/buffer and hover are verified before each pre-pickup tick. The idle, fully charged, finite-battery original drone must be free of the prior construction assignment, and the original adapter must have `set_process(false)` in this isolated fixture: no simultaneous drone driving, job authorization, worker or timer. A real registered Storage dock reserves an exact incoming capacity token before pickup. Physical debit of canonical **3 Storage or 5 Press Test Ingots** happens only after the drone arrives at the original site hover. The drone carries actual cargo to a dock and deposits only on verified physical arrival via `InventoryComponent.consume_drone_return_claim(token)`. The original staging claim stays locked after recovery. A failed or full return dock leaves custody protected; mid-flight invalid destinations hold cargo until valid. The drone flies home, recharges with real finite Hub generation, then re-arms. No instant refund, staging unlock, silos or other construction types.

New isolated F6 scene `res://tests/cancelled_site_physical_recovery_e3d5c6c_stage_b_test.tscn` has **13 proposed checks A–M**: A source cancelled 3-ingot delivery and original custody; B wrong IDs/default off; C capacity reserve before debit; D real outbound battery flight; E actual site pickup and locked staging; F blocked dock wait with cargo held; G real return and blocked unload; H 12→15 exact reserved physical deposit; I return home and generator-OFF charging block; J same drone finite recharge and one-time ticket; K full escrow refund of cancelled Press 5; L full Storage capacity and moved original receiver fail closed; M true physical 5-ingot return, finite recharge, conserved 15 and duplicate refusal. Expected banner: `ALL 13 CANCELLED SITE PHYSICAL RECOVERY E3D5C6C STAGE B TESTS PASSED`.

**No local parse/F6 checks have run yet.** If the fixture fails, record first error and PASS groups and fix before targeted compatibility. After developer confirms all 13, record isolated acceptance, perform focused regression of existing custody, return, charging and Direct Build physical lifecycle suites, then separately gate Stage C playable automatic recovery. The accepted `playable_direct_build_authorization_e3d5c6b.tscn`, Main, ordinary scenes, existing tests and E3d5c6a 56/785 manifest remain unchanged. Do not claim restored cancellation materials in gameplay yet. E3d5c6b Stage C manual 10-check gate is still open; final fresh combined regression also pending.

**E3d5c6c Stage A FULLY ACCEPTED: isolated 13/13 + targeted compatibility 15/15 suites, 218/218 checks. Stage B default-off physical recovery is the next milestone. Unique accepted baseline 59/823 unchanged.**

### 2026-11-20 — E3d5c6c Stage A FULLY ACCEPTED; Stage B isolated physical recovery starts

Developer confirmed the corrected final `playable_direct_build_authorization_e3d5c6b_stage_b_test.tscn` **all 14/14 A–N passed locally in Godot**, resolving the half-grid WAIT_POS silent exit. The other 14 suites in the sequential E3d5c6c Stage A compatibility gate had been completed previously; together **15/15 compatibility suites / 218/218 checks are accepted** with manifest `tools/cancelled_site_custody_stage_a_compatibility.csv`. The **13/13 isolated cancelled-site custody audit checks** were already locally accepted. Full Stage A gate: 16 suite runs / **231/231** checks; the 218 reruns overlap previously accepted suites and must **not** inflate the unique baseline. Current cumulative unique automated milestone baseline: **59 suites / 823 checks** (E3d5c6a 56/785; E3d5c6b 11+14; E3d5c6c Stage A 13). No new fresh full 59/823 combined run claimed. E3d5c6b Stage C 10 manual checks remain pending.

**Stage B goal:** default-OFF, exact-scoped terminal-site physical recovery using the original ONE charged drone after previous assignment rearms. Source is the Stage A immutable cancelled-site ticket, original staging/port and actual inventory after escrow refund. Reserve exact destination storage capacity before any source debit. A guarded drone flight must first reach the original site hover before removing 3 or 5 actual ingots, then visibly carry them to a real registered Storage dock and unload with the reserved capacity token, respecting battery/finite recharge and never touching complete-building bills. Preserve original staging locks. No asynchronous separate process/worker/timer, no power/free inventory, no silent fallback or automatic installation in Main/accepted scenes. Stage B implementation and tests require isolated F6 and compatibility gates; **no new acceptance claimed** by this Stage A documentation checkpoint.

**E3d5c6c Stage A isolated 13/13 ACCEPTED; compatibility final suite was silently ending after PASS I because 2×2 Press WAIT_POS used integer Storage grid and unpowered plot. Corrected half-grid powered WAIT_POS and diagnostic assert; final F6 rerun pending. 15/218 NOT yet accepted; unique baseline 59/823.**

### 2026-11-20 — E3d5c6c Stage A compatibility last suite silently exits after PASS I; exact fixture problem corrected, rerun pending

Developer posted Output of `res://tests/playable_direct_build_authorization_e3d5c6b_stage_b_test.tscn`: **PASS A through PASS I** now print, including all three strict completed-building original site transform checks after the previous fix. The last Output line is `DIRECT BUILD AUTHORIZED: Prototype Ammunition Press | Normal priority`, immediately followed by `--- Debugging process stopped ---`, with **no PASS J** or visible assertion. They clarified this is repeatable, not a manual stop.

Confirmed test control-flow cause: in `_checks` after PASS I, `var waiting := _place(demo, PRESS, WAIT_POS)` and an `if not is_instance_valid(waiting): sandbox.free(); return` branch **silently ends** the whole isolated test. The prior `WAIT_POS=Vector3(-5,0,0)` was copied from an expansion fixture's **Storage** LATE_POS; that building has odd footprint (1×3), but the newly placed **Press** has even 2×2 footprint and must center on **half-integer X/Z**. Godot's real Direct placement can succeed after grid snapping even though the test helper `_at()` looks for the exact requested integer X/Z, causing a null lookup and early return. Moreover the previous plot is far outside the Hub's finite power radius (4.5), so it would fail the following coverage assertion. This is a test-fixture issue, not a confirmed gameplay/drone bug.

**Narrow test-only correction:** The fourth Press now requests `WAIT_POS=Vector3(1.5,0,-5.5)`, exact half-grid coordinates. Its footprint stays inside the existing Hub at `(2,0,-3)` 4.5-unit corner coverage; the open plot north of the Hub is away from the three completed building interiors and ReferenceCube. Do not modify real placement, building footprints, power coverage, physical drone movement, escrow or ownership. `_place` now prints the requested/observed actual sites and raises an explicit debugger assertion on any future null lookup, instead of returning silently. Check J now prints a start marker, and the waiting site/coverage guards fail visibly if the plot is blocked or coverage invalid. The original 14 checks A–N and expectations (including 15→4 and unaffordable fourth Press) are unchanged.

**Local follow-up:** Pull main and F6 **only** `res://tests/playable_direct_build_authorization_e3d5c6b_stage_b_test.tscn`. Expected PASS J, then K–N, then `ALL 14 PLAYABLE DIRECT BUILD AUTHORIZATION E3D5C6B STAGE B TESTS PASSED`. No Godot execution by assistant. Previous 14 compatibility suites are developer-reported as passed; full **E3d5c6c Stage A 15 suites / 218 checks** is **not yet accepted** until this final rerun passes. Unique accepted baseline remains **59 suites / 823 checks**, and E3d5c6b Stage C manual is still pending. Recovery flight implementation Stage B has not begun.

**E3d5c6c Stage A isolated 13/13 ACCEPTED; targeted compatibility final suite reported failing at completed-building position/parent compound assertion. Test-only strict original-site-transform correction staged; rerun last existing Stage B F6 suite. Full compatibility 15/218 NOT accepted yet.**

### 2026-11-20 — E3d5c6c Stage A compatibility suite 15 halted; Stage B fixture transform correction pending F6

Developer reported reaching the final suite of the **15-suite / 218-check Stage A targeted compatibility gate** and supplied a Godot 4.6.2 debugger screenshot showing `res://tests/playable_direct_build_authorization_e3d5c6b_stage_b_test.gd:182` asserting `building.get_parent() == sandbox and building.global_position.is_equal_approx(at)`. This is in `_check_built` after `_finish` has already observed a completed job and emitted one building. The compound assertion does **not** isolate which clause failed. The first 14 compatibility scenes were marked complete in the user's test tracker, but no complete Output log was supplied; therefore the **full compatibility gate remains pending**, not 15/15 accepted.

Source inspection: `ConstructionSite._finish_construction` parents the actual building to `get_parent()` and copies the original `global_transform`; `WorldInteraction._update_placement_preview` uses physics ray elevation for the construction site, not guaranteed world Y=0. **Likely test-only hardcoded Y mismatch**, not verified material loss or gameplay regression. Prior Stage A custody fixture similarly needed to compare against actual site hover position.

**Narrow test-only correction:** snapshot each actual site's full `global_transform` (Press, High Blueprint Storage, Normal Direct Storage) immediately after real placement; at completion, separately assert (1) original actual site X/Z matches expected plot, (2) completed building's parent is sandbox, (3) completed building's **full world transform** equals the original captured site transform, and (4) scene definition/runtime binding are unchanged. The assertions now include expected and actual transforms/parent in error messages, to distinguish a true ownership/placement regression if it persists. No gameplay scripts, scene, prior custody audit, material transport, escrow, power, worker, or ownership behavior changed. No compatibility result claimed from the correction.

**Local next step:** Pull current main and rerun **only** `res://tests/playable_direct_build_authorization_e3d5c6b_stage_b_test.tscn` with F6 (existing 14/14 isolated suite). If it passes, report successful final suite plus previously completed 14 to record 15/15, 218/218 compatibility gate; do not double-count it in unique accepted **59-suite / 823-check baseline**. If it fails, capture first Debugger error and preceding PASS lines; corrected assertions should reveal whether parent or actual transform differs. E3d5c6c Stage A isolated **13/13 accepted**, full Stage A pending compatibility. No physical post-delivery return code yet; E3d5c6b manual Stage C remains pending.

**E3d5c6c Stage A isolated ACCEPTED (13/13 locally confirmed); targeted compatibility gate PENDING 15 suites / 218 rerun checks. Unique automated milestone baseline now 59 suites / 823 checks (prior 58/810 preserved). No physical staged recovery code.**

### 2026-11-20 — E3d5c6c Stage A isolated custody audit ACCEPTED 13/13; compatibility 15/218 pending

Developer explicitly confirmed **all 13/13 isolated Stage A custody test checks passed locally in Godot** after the isolated hover-Y assertion correction at commit [0ef6947d](https://github.com/ChrisGiggleman/industrial-warfare/commit/0ef6947d1b215da05a606b78ae2725d8f089c03f). This is user-reported local Godot execution, not assistant execution. Checks cover original site+job+receiver identity; canonical 3/5 bill; duplicate and foreign-ownership refusal; physical delivery; protected storage after post-delivery cancellation; survival after site free; moved receiver quarantine; during-work escrow refund into original locked Press staging; exact **7 source + 3 Storage staging + 5 Press staging = 15** conservation; zero-stock cancelled sites; strict default-off and terminal completed buildings never recoverable. The first pre-fix Check E assertion was test-only; successful rerun supersedes it.

**Unique accepted automated milestone baseline: 59 suites / 823 checks** = previously accepted E3d5c6a + E3d5c6b **58/810** plus this isolated 1/13. No fresh full 59/823 combined run claimed. E3d5c6b Stage C manual 10 checks still pending and physical post-delivery recovery **NOT implemented**.

Next acceptance gate is **15 existing suites / 218 rerun checks** with named exact F6 scenes and counts in [CANCELLED_SITE_PHYSICAL_RECOVERY.md](CANCELLED_SITE_PHYSICAL_RECOVERY.md) and new `tools/cancelled_site_custody_stage_a_compatibility.csv`. 13 are in original 56-suite manifest (193 checks); 2 Direct Build suites account for 25; **all overlap previously accepted checks**. Compatibility is **not yet executed**. No gameplay or existing accepted scenes/tests/manifests changed by this acceptance bookkeeping.

**E3d5c6c Stage A F6 first run halted in Check E at hardcoded hover Y position assertion; narrow fixture correction committed and 13-check rerun pending. No custody audit or gameplay change.**

### 2026-11-20 — E3d5c6c Stage A local F6 halted at Check E hover-position assertion (test-only correction staged)

Developer screenshot of `res://tests/cancelled_site_custody_e3d5c6c_stage_a_test.tscn` shows **assertion failed at test line 281**: `obs["hover_position"].is_equal_approx(STORAGE_POS + Vector3.UP * 2.0)`. The test has already entered Check E after the physical Storage pickup/delivery steps, and the earlier E assertions on `ready_read_only`, amount 3, original instance ID, canonical bill and definition ran without stopping. The visible image does not include numerical values for the recorded hover; likely culprit is the test's **hardcoded zero Y** for an actual Godot ray-placed site, not a verified custody loss. No 13/13 acceptance; any later checks F–M were not verified by this run.

**Narrow test-only correction:** Before cancelling the original site, store `actual_hover = storage.global_position + Vector3.UP * 2.0`, assert actual site **X/Z match the intended STORAGE_POS plot**, and assert the original registered physical receiver is at that hover. After cancellation, compare the audit's immutable `obs["hover_position"]` to that captured original hover. Include both vectors in the failure message. This tests original-site provenance and immutable receiver geometry without assuming world Y=0, modifying the audit/registry, unlocking staged stock, or changing gameplay collision/placement logic. No `_process` or material movement added. The original 58/810 baseline remains accepted; no compatibility or new tests claimed.

**Rerun after pulling current main:** F6 same `cancelled_site_custody_e3d5c6c_stage_a_test.tscn`, expected 13/13 A–M; final banner `ALL 13 CANCELLED SITE CUSTODY E3D5C6C STAGE A TESTS PASSED`. If another assertion fails, developer should provide first Debugger error and Output PASS lines; do not count Stage A as accepted until 13/13. Stage B physical recovered-material pickup/return still unimplemented. E3d5c6b manual Stage C remains open.

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
