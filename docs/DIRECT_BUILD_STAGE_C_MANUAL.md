# E3d5c6b — Stage C manual playable verification (PENDING)

Godot **4.6.2 Stable**, GDScript, Forward+. Run only the isolated opt-in playable scene:

`res://scenes/core/playable_direct_build_authorization_e3d5c6b.tscn`

Choose the scene in FileSystem and **F6** (Run Current Scene), **not** the new automated Stage B test and not Main. Use genuine mouse placement and keyboard inputs; do not simulate placements through test scripts or Inspector calls. **Restart F6 before each session** to restore the initial 15 ingots and one idle drone. Record 10 **manual observations** A1–A6, B1–B3, C1. This gate is independent of all automated suites; no software or runner changes are required.

## Grounded controls / visual cues

- **B** enables Build mode; **right-click** exits it. **3** selects canonical Test Storage; **8** selects Prototype Ammunition Press with the default 1–9 quickbar. If assignments differ, **M** opens Building Catalog; choose the desired hotbar assignments or Restore Defaults. Press **R** for 90° rotation; use the default unrotated orientation for the named placements.
- **P** toggles Blueprint mode, but only while Build mode is active. In Build mode, a valid supported click **authorizes immediately** at Normal priority; no E needed. In Blueprint mode, a supported click **plans only**.
- While in Blueprint mode, **Q** enters/exits drag-selection mode; left-drag around a planned site. **H/N/L** change priority of selected planned sites but do **not** authorize. With Q selection active, **E** authorizes selected; outside Q, hover an unapproved site and press **E** to authorize that one; **Ctrl+E** authorizes all remaining planned sites. Hover a managed site and press **X** to cancel it (also in normal Build mode).
- The experiment displays a left status HUD, starter storage amount/reservations, drone battery/cargo, hub power, queue H/N/L and rearm count. The **Turn generator OFF/ON (test)** button operates the real Hub generator, not a debug availability override. The `AMMO PRESS SITE` and `STORAGE SITE` labels mark suggested open positions near **(4.5,0,-3.5)** and **(0,0,-3)**. Do not click on the existing Hub or Starter Storage. The ground, valid footprint, camera view and site collision checks are authoritative.
- Only **canonical Test Storage** (3 Test Ingots, 10 seconds) and **Prototype Ammunition Press** (5 Test Ingots, 18 seconds) are admitted. Unsupported Extractor, Smelter, splitter/merger, belt, turret etc. must **not** become operational buildings in this scene. Automatic belt placement/construction remains separately gated. A red/blocked ghost or refusal is correct for unsupported choices.
- The **one** automatic drone physically picks up materials at Starter Storage, flies them to each construction site's hover receiver, then construction progresses with actual Hub power, worker, escrow and timer. The player does not need temporary conveyor lines to build these two structures.

## Session A — Direct Build and physical progression (fresh F6; 15 ingots)

| Check | Physical action | Pass observation |
|---|---|---|
| A1 | Open the dedicated scene with F6; press **B**. | Build HUD and automatic-construction status appear, Starter Storage reports **15** Test Ingots and one available drone; no parse/errors or completed free building. |
| A2 | Press **3**, click valid unoccupied ground at `STORAGE SITE` (approximately **0,0,-3**), with default rotation; **do not press E**. | One unfinished Test Storage site appears, is automatically authorized at **Normal**, and waits for or enters the original drone delivery workflow. No instant completed Storage or free initial material transfer. |
| A3 | Press **8**, click valid `AMMO PRESS SITE` ground (approximately **4.5,0,-3.5**); try a second click on the same occupied footprint. | Exactly one additional nonoperational Press site is queued at Normal; repeated/overlapping click is rejected; no duplicate site or second lifecycle driver. |
| A4 | Select an unsupported hotbar building (e.g. **7** splitter), point at an otherwise open plot and click; reselect **3** or **8** afterward. | Preview is invalid/red or placement is refused; no legacy instant building, unauthorized conveyor or free material appears in this opt-in scene. |
| A5 | Watch the one drone collect and deliver ingots; **after delivery and while a job is visibly constructing**, click **Turn generator OFF (test)**; then back ON. | Pickups visibly debit Starter Storage (**3** for Storage, **5** for Press); drone carries finite cargo. With generator OFF, worker construction **pauses** (progress unchanged); ON resumes without starting a second worker or resetting progress. Do not judge pause before escrow/admission. |
| A6 | Let both jobs finish and drone return/recharge. | Exactly **one completed Storage and one completed functional Press** replace their unfinished sites after real timers. Press production inventories start empty (construction cargo is not free manufacturing stock). Starter Storage ends at **7 ingots** (15−3−5), no duplicate building and same drone can recharge/rearm. |

## Session B — Blueprint permissions and shared queues (restart fresh F6; 15 ingots)

| Check | Physical action | Pass observation |
|---|---|---|
| B1 | Press **B**, then **P**. In Blueprint mode, place unrotated **3 Storage** at `STORAGE SITE` (0,0,-3), **8 Press** at `AMMO PRESS SITE` (4.5,0,-3.5), and another **3 Storage** at an unoccupied adjacent-safe position (approximately **4,0,-1**). Do not authorize. | All three remain **PLANNED**; no queue jobs, drone departure, material debit or construction progress simply because they were clicked. |
| B2 | Press **Q**, drag-select only the first planned Storage; press **H** and inspect priority. **Do not authorize yet**, then press **E** while Q-selection is active. Press **Q** again to leave selection mode. | H changes the selected job's priority without starting it. Only **E** authorizes that selected Storage and allows physical dispatch; Press and other Storage remain planned. Priority never automatically authorizes. |
| B3 | Hover over the planned Press and press **E** (single-site authorization); then **Ctrl+E** to authorize the remaining Storage. Observe queue/drone and allow completion. | Same original queue/physical drone, distinct stages/cargo bills, one worker and no preemption. High Storage takes priority over remaining Normal jobs when dispatch is free. All three can finish with **4 ingots** left (15−3−5−3); neither E nor Ctrl+E fabricates material. |

## Session C — Manual cancellation and loaded return (restart fresh F6; 15 ingots)

| Check | Physical action | Pass observation |
|---|---|---|
| C1 | Press **B** and **8**; Direct-place a Press on the marked clear plot. Observe HUD/drone. When drone has **collected five ingots** and is carrying them toward the site (cargo **5**), hover the construction site and press **X** **before unloading**. | Job cancels; **no completed Press**, no further construction or duplicate dispatch. Drone physically returns the **five carried ingots** to Starter Storage (eventually back to **15**), then returns/recharges. If you miss the loaded window, restart F6 rather than claiming the loaded-cancellation check passed. |

## Reporting and acceptance

Provide each manual result (A1–A6, B1–B3, C1), any first error and screenshots of the HUD/site/drone when useful. Expected **10/10**; these are **manual** checks, not a new automated suite and do not increase the accepted **58-suite / 810-check** unique automated baseline. No Stage C acceptance before developer confirmation.

After **10/10 manual acceptance**, stage the final combined automated regression: E3d5c6a original **56 suites / 785 checks** plus Direct Build Stage A **11** and Stage B **14** = **58 unique suites / 810 checks** (fresh final rerun pending). Keep Stage A historical supplementary 10/125 and all Stage A/B compatibility reruns separate; do not double-count. Retain Main and previous scenes unchanged and do not activate automatic conveyors, splitter/merger construction, new pole construction, multi-trip/multi-drone delivery, persistence, expanded destruction or protected-staging unlock.
