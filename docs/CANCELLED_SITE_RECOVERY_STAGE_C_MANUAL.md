# E3d5c6c — Stage C manual playable automatic cancelled-site recovery

Status **PARTIAL ACCEPTANCE: 8/10 manual checks accepted (A1–A5, B1–B2, C1); B3 and C2 pending**. Updated **2026-11-21**. Godot 4.6.2 Stable.

## Manual acceptance update — completed Storage C1 accepted

### 2026-11-21 — E3d5c6c Stage C manual C1 ACCEPTED: completed Storage consumes 3 ingots, no recovery

Developer supplied live playable-scene screenshot of a **finished additional Storage building** (circled), alongside the original Starter Storage and one idle construction drone. HUD shows **Starter Storage 12 ingots / 0 reserved**, `IDLE`, battery **40/40**, cargo **0/5**, `Rearms: 1`, planned/queued/building/paused all zero, and `Recovery: WAITING / IDLE | tickets 1 | recovered 0`. This matches the intended **15−3=12 ingot** committed build cost and confirms **no cancelled-site recovery was launched** for a completed site. A retained custody ticket count of 1 is not itself a recovery mission. Screenshot is developer-provided local manual evidence, not an assistant-run Godot test. **Manual C1 accepted.**

**Stage C manual checkpoint advances from 7/10 to 8/10:** A1–A5, B1–B2 and C1 accepted. **B3 pending** (Press-specific return completes Hub recharge/rearm with recovered 1 and no duplicate); **C2 pending** (unapproved Blueprint does not dispatch/debit, explicit E authorization does). Other local automated acceptance remains 14/14 isolated plus 27/27 targeted compatibility (381/381 reruns), with **61 unique suites / 850 checks**. No new code or automated test change.


## Manual acceptance update — Storage recovery and battery hold confirmed

### 2026-11-21 — E3d5c6c Stage C manual: Storage recovery and generator-OFF hold explicitly confirmed by developer

Developer's follow-up, **"this is confirmed working,"** confirms the immediately requested checks: the observed **three-ingot physical return** completes after the STAGED TO STORAGE flight, restoring Starter Storage from **12 → 15 ingots** with the recovery mission settled (**recovered 1**, drone returned **IDLE**, battery **40/40**), and a partly charged drone's battery does **not** increase while the generator remains OFF over the observed interval. Earlier live screenshots showed the in-flight **cargo 3/5** (Storage still 12), Hub **output 0** with generator OFF and a partially charged docked drone, and completed Direct Storage/Blueprint Storage recovery end states. This explicit developer report supplies the final outcomes that the prior screenshots alone did not show. It is **developer-reported local manual verification, not an assistant-executed test or new screenshot of the final moment**.

**Manual checkpoint:** Stage C Session A (A1–A5) is accepted from cumulative live evidence and the developer's confirmation. The earlier developer-confirmed five-ingot Direct Ammunition Press cancellation with actual returned Starter Storage stock **15** supports Session B B1/B2; B3's Press-specific complete recharge/rearm and no-duplicate observation remains pending (last Press screenshot was `DOCKED`, battery **39.3/40**, `Recovery ACTIVE`, `recovered 0`). **Seven of ten manual checks are now recorded accepted (A1–A5, B1–B2); B3, C1, C2 remain open.** The generator-OFF battery-hold behavior is independently confirmed, but does not by itself complete the separate Press B3 rearm requirement. Do not claim full 10/10 manual milestone acceptance yet.

**NEXT:** (1) Confirm Press's terminal `Recovery WAITING / IDLE | recovered 1` with battery 40/40 and original stock 15 (B3); (2) fresh F6, allow a Direct Storage building to actually complete, verify it spends three ingots (15→12) and **does not recover** committed building materials (C1); (3) fresh F6, place an unapproved Blueprint Storage and prove no pickup until E authorizes it (C2). No gameplay source changed. Existing automated Stage C 14/14 + compatibility 27 suites/381 rerun checks remain accepted; unique suite baseline **61/850** unchanged.


## Live observation — Generator-off dock and 3-ingot recovery flight

### 2026-11-21 — E3d5c6c Stage C live power-off and 3-ingot return in flight (partial manual evidence)

Developer supplied two additional real playable-scene screenshots, showing **distinct mid-cycle states**:

- **Power-off dock state:** `AUTOMATIC CONSTRUCTION — DOCK WAIT`, drone `DOCKED`, **battery 33.6/40.0**, cargo **0/5**, `Hub output 0 | Spare 0`, generator button `Turn generator ON (test)`, Starter Storage **12 ingots**, `Job progress: 32%`, `Recovery: WAITING / IDLE | tickets 1 | recovered 0`, Rearms 0. This visually confirms generator OFF means zero Hub output, with a partially charged drone docked; a single frame **does not prove battery stayed fixed over time** or confirm construction progress did not advance over an interval.
- **Active original-site physical recovery:** `AUTOMATIC CONSTRUCTION — STORAGE FLIGHT`, drone `STAGED TO STORAGE`, **cargo 3/5**, battery **36.1/40.0**, Starter Storage still **12 ingots**, `Recovery: ACTIVE | tickets 1 | recovered 0 | staged 3`, Rearms 1, Hub output 12. This directly shows a three-ingot cargo trip before Storage unload—**not** the five-ingot Press test—and no instant Storage credit in that captured frame.

These screenshots strengthen earlier Direct Storage/Blueprint Storage observations by showing **in-flight cargo and finite battery** rather than only a settled end HUD. They do **not** show recovered 1 / idle / restored 15 for this particular displayed 3-ingot flight, nor two elapsed generator-off observations, and cannot alone complete the formal manual A1–A5/B1–B3/C1–C2 gate. Keep those missing observations open. The previously shown Press 5-ingot unload at Storage 15 but `Recovery ACTIVE` also still awaits final IDLE/recovered 1 evidence. All 14/14 new automated checks and Stage C 27/381 targeted compatibility remain accepted; cumulative unique **61 suites / 850 checks** unchanged. No gameplay scripts changed as part of this documentation update.


## Live observation — Direct Build Ammunition Press five-ingot recovery (dock unload confirmed; final rearm pending)

### 2026-11-21 — E3d5c6c Stage C live Direct Build Ammunition Press (5 ingots): dock unload confirmed; final rearm still in progress

Developer supplied two Godot 4.6.2 live playable screenshots and reports the Press cancellation completed successfully. Godot Output shows `Selected building: Prototype Ammunition Press`, `BLUEPRINT AUTHORIZED: Prototype Ammunition Press`, `DIRECT BUILD AUTHORIZED: Prototype Ammunition Press | Normal priority`, `BLUEPRINT CANCELLED`. **Direct Build**, not merely Blueprint mode, is confirmed.

At the exact captured moment the HUD shows `AUTOMATIC CONSTRUCTION — CHARGED`, drone **DOCKED**, battery **39.3/40.0**, cargo **0/5**, **Starter Storage 15 ingots / 0 reserved**, Returns 0, worker slots 0/1, queue 0, **Rearms 1**, `Recovery: ACTIVE | tickets 1 | recovered 0 | staged 5`. The original 15 ingots are restored and no cargo remains on the drone, consistent with a successful **five-ingot physical return/unload at Storage**. The mission has **not yet reached the final rearm/complete state** in this screenshot; `ACTIVE` / `recovered 0` are not equivalent to a failed recovery, because the drone is still recharging. The HUD's `staged 5` is the recovery ticket's expected amount, not proof five ingots remain stranded in site staging after unload. No Debugger error is visible in the supplied Output.

**Exact next observation:** leave this same F6 session running with generator ON until battery **40.0/40.0**, drone **IDLE**, rearm count **2**, and `Recovery: WAITING / IDLE | tickets 1 | recovered 1`; verify Storage remains at 15 with cargo 0. Do not mark the entire B1–B3 or the total 10-check manual acceptance solely from this interim end-state screenshot: 15→10 original supplier debit, original hover pickup, and generator-off recharge test are not all independently pictured. Previous Direct Storage and Blueprint Storage final recovered 1 observations remain recorded. Stage C automation **14/14 accepted**, Stage C compatibility **27/381 accepted**, unique automated **61 suites / 850 checks** unchanged. No source/runner change required.


## Live observation — Direct Build cancellation recovery (partial manual evidence)

### 2026-11-21 — E3d5c6c Stage C live Direct Build cancellation: recovery end state confirmed (partial manual evidence)

Developer supplied a **second pair of screenshots from the real Stage C playable scene**, reporting the same successful outcome after a **Direct Build** Storage cancellation. Godot Output explicitly includes `DIRECT BUILD AUTHORIZED: Test Storage | Normal priority`, in addition to the shared `BLUEPRINT AUTHORIZED: Test Storage` and `BLUEPRINT CANCELLED` messages. The `BLUEPRINT AUTHORIZED` line here is part of the Direct Build authorization path; the explicit `DIRECT BUILD AUTHORIZED` message distinguishes this run from the earlier Blueprint-mode recovery observation. The scene reports the E3d5c6c opt-in single-adapter tick.

Final HUD shows **Storage 15 ingots, 0 reserved; drone IDLE / cargo 0/5 / battery 40.0/40.0; Rearms 2; Recovery WAITING / IDLE, tickets 1, recovered 1; planned/queued/building 0; generator ON**. This provides manual evidence of Direct Build authorization followed by cancellation and **one settled recovery with original stock restored**. The screenshots do not show the intermediate **15→12** supplier debit, exact original-site pickup flight, Storage dock unload moment, or generator-OFF recharge test. Preserve those as **unverified manual observations**, not a claim of full A1–A5 or 10/10 acceptance. No gameplay regression or debugger error is shown.

**NEXT**: fresh playable F6 for **Ammunition Press direct-build (5 Test Ingots)**. Place at powered Press marker using its hotbar selection (previous guide: slot **8**), cancel after physical delivery and before 18-second job completion; check 15→10 source debit, later physical original staging return **10→15**, same drone rearm. Separately inspect completion/no-refund, generator-off, and Blueprint authorization permissions before final manual 10/10. Stage C automated 14/14 and compatibility 27/381 remain accepted; unique baseline **61/850** unchanged.


## Live observation — Blueprint cancellation recovery (partial manual evidence)

**2026-11-21 — E3d5c6c Stage C live Blueprint cancellation: successful settled recovery state (partial manual evidence)**

Developer supplied **two live playable-scene screenshots** immediately after cancelling a construction site during building. Godot Output shows `BLUEPRINT MODE: PLAN`, `BLUEPRINT PLANNED: Test Storage`, `BLUEPRINT AUTHORIZED: Test Storage`, `BLUEPRINT CANCELLED`, and `Blueprint mode disabled`. Thus this observed path was **Blueprint placement + explicit authorization + cancellation**, **not Direct Build**. The opt-in Stage C adapter printed `E3d5c6c Stage C opt-in playable recovery enabled (single adapter tick)`.

Final in-game HUD confirms **Starter Storage: 15 ingots / 0 reserved; drone IDLE, cargo 0/5, battery 40.0/40.0; Rearms: 2; Recovery: WAITING / IDLE, tickets 1, recovered 1; queued/building/planned 0; Worker slots 0/1; generator ON.** This is consistent with **one fully settled material-recovery mission** and restored initial inventory after an interrupted authorized Storage construction. `recovered 1` denotes one recovery **mission**, not 1 ingot. No visible Debugger error was supplied. The screenshots do not independently show the drone's transit/pickup or mid-flight inventory totals; those are covered by previous local automated acceptance and still require separate full manual observations.

**Manual status: supplemental Blueprint-mode recovery outcome OBSERVED; the formal Stage C manual 10-check gate A1–A5/B1–B3/C1–C2 remains PENDING**, because those checks require separately documented Direct Build click, physical flight observations, Press, complete-building behavior and generator-off validation. No new code change or automated test rerun is required by this screenshot evidence. Next: fresh F6 of `res://scenes/core/playable_cancelled_site_recovery_e3d5c6c_stage_c.tscn`, ensure `P` is OFF for Direct Build; click Storage hotbar 3 without pressing E, observe original 15→12 delivery, X cancel after delivery, recovery 12→15 only at real Storage dock, finite Hub rearm; then Press hotbar 8 in another fresh session. Unique accepted automated baseline **61 suites / 850 checks**, Stage C targeted compatibility 27/381 accepted.


## Prerequisites — already accepted

- Stage C integration F6 **14/14 new checks**, developer-confirmed locally.
- Stage C targeted compatibility **27/27 prior suites, 381/381 existing checks**, developer-confirmed locally.
- **61 unique accepted automated suites, 850 unique checks** (cumulative milestones, not a new fresh combined run).
- This manual gate is **distinct** from the older `E3d5c6b` Direct Build manual 10-check gate, which is still pending.

## Open the correct playable scene

`res://scenes/core/playable_cancelled_site_recovery_e3d5c6c_stage_c.tscn`

In Godot's FileSystem, open that **scene** and press **F6**. Do not run the automated `tests/playable_cancelled_site_recovery_e3d5c6c_stage_c_test.tscn`. **Restart F6 before each session** so Starter Storage has the initial **15 Test Ingots**, the drone is idle, and earlier building plots are clear.

Use actual keyboard/mouse controls, not Inspector property changes, scripting, or test fixture shortcuts:

- **B** shows the Build HUD; **3** selects Test Storage, **8** selects Prototype Ammunition Press.
- Leave **Blueprint mode OFF** for direct builds. Click the unobstructed, fully Hub-powered **STORAGE SITE** guide near **(0, 0, -3)** or **AMMO PRESS SITE** guide near **(4.5, 0, -3.5)**, with default orientation. The world X/Z coordinates are guide targets, not a guarantee about ground Y.
- Direct Build should authorize one eligible building automatically at Normal. **X** cancels the site under the cursor. Use the HUD's **Turn generator OFF (test)** and **Turn generator ON (test)** control where instructed.
- Physical material return is **not instant**. After X, the one drone must finish or rearm its original assignment, then physically travel to the original hover, collect actual locked staging inventory, deposit at eligible Storage, return to Hub, and recharge.
- **Timing:** Test Storage has a 10-second construction timer, Press 18 seconds. Cancel **after the initial drone delivery/unload, before the site finishes**. If you miss the window, stop/restart F6 rather than counting a successful build as a cancelled-site recovery. When needed, turning the generator OFF after delivery can pause active construction; turn it ON again for the drone's Hub charging cycle.
- Ignore the detached legacy "construction requirements" panel when it says UNKNOWN; use the authoritative automatic-construction HUD and the actual job/drone behavior.

## Session A — Direct Storage: physical return (fresh F6)

| Check | Player action | Pass observation |
|---|---|---|
| **A1** | F6 playable Stage C scene, press B. | Starter Storage **15**, one idle/charged drone, correct recovery HUD, no free finished building or Debugger errors. |
| **A2** | Select **3** and left-click near labeled STORAGE SITE; do **not** press E. | One **Normal** queued site appears, physical drone pickup/delivery uses **3** ingots, Starter Storage becomes **12** after pickup; no instant building. |
| **A3** | Once **cargo unloads at the original site** and the job is unfinished, hover site and press **X**. | Site/job cancels, no completed Storage; original **3** staged ingots are not credited back instantly, Storage is still **12** until real recovery unload. |
| **A4** | Let the original drone return/rearm and watch automatic recovery. | The **same drone** flies to the original site, collects **3**, delivers to actual Starter Storage; stock returns **12 → 15** only at real dock unload. |
| **A5** | Observe the drone's return to Hub, charging, and later idle state. | Finite travel/recharge, cargo returns to **0**, battery eventually **40/40**, no duplicate mission, no second drone, no extra material after waiting. |

## Session B — Direct Press: cancellation and energy (restart F6)

| Check | Player action | Pass observation |
|---|---|---|
| **B1** | Select **8**, click the labeled AMMO PRESS SITE (unrotated), wait for the real delivery of **5** ingots. | Normal queued Press, Starter Storage **15 → 10**, one physical drone, site has not yet completed. |
| **B2** | After delivery but before completion, hover Press and press **X**; if construction has started, generator OFF can pause progress, then turn ON. | No finished Press; the same drone physically recovers original **5** ingots, stock **10 → 15** at real Storage unload, not instantly on cancellation. |
| **B3** | If convenient, briefly turn generator OFF when the drone is docked but not fully charged, then back ON. | Battery does **not** charge while generator OFF; with ON it charges finitely, same drone rearms, no duplicate five-ingot return. If the recharge window was missed, restart F6 for this check. |

## Session C — Conservation and player permissions (restart F6 as needed)

| Check | Player action | Pass observation |
|---|---|---|
| **C1** | Direct-build **3 Storage** at the powered guide and **allow it to finish** without cancelling. | Exactly one real completed Storage consumes **3** construction ingots, leaving **12** starter ingots; **no recovery** from completed construction. |
| **C2** | Restart F6, press **P** to enter Blueprint mode, place a new Storage blueprint but **do not authorize it**. Observe; then select/authorize with **E** via existing blueprint controls. | Unapproved planned site does **not** dispatch the drone or debit stock. Explicit authorization alone starts the existing physical construction workflow. No automatic authorization, free materials, or second drone. |

## Manual acceptance rules

Record **A1–A5, B1–B3 and C1–C2 = 10 checks total**. Report **10/10** only after every check passes in local interactive Godot, or send a screenshot and the first Debugger error/Output lines for the first incomplete check. If a future edit requires modifying gameplay, fix narrowly and rerun the affected automated/compatibility gates. No manual result is inferred from the 14/14 F6 integration tests.

**Remaining separate gate:** `docs/DIRECT_BUILD_STAGE_C_MANUAL.md` for older `E3d5c6b` manual Direct Build verification; do not mark it accepted from this Stage C result. Main and the original E3d5c6b playable scene remain unchanged.
