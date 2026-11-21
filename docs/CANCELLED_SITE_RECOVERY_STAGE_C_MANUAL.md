# E3d5c6c — Stage C manual playable automatic cancelled-site recovery

Status **PENDING 0/10 manual checks**. Updated **2026-11-21**. Godot 4.6.2 Stable.

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
