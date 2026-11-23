# E3d5c6d — Stage C Unified Construction Manual Playable Verification

**2026-11-22 — STAGED, 0/10 manual gameplay checks reported so far.** E3d5c6d Stage A isolated **16/16** and Stage B targeted compatibility **39/39 scenes, 536 expected rerun checks** are developer-local accepted. Manual scene interaction is **not** verified by those automated checks. Run in Godot **4.6.2 Stable**, GDScript, repository `ChrisGiggleman/industrial-warfare` `main`.

## Use this exact NEW scene

`res://scenes/core/playable_unified_construction_e3d5c6d.tscn`

**F6 (Run Current Scene), not F5.** This scene inherits Factory Testing Sandbox and uses the accepted Stage C recovery adapter with one actual drone, one dispatch and recovery update authority, original same queue/staging/escrow/power systems; Main and accepted older scenes remain unchanged. Use **real mouse/keyboard input**, not manually advancing ticks or editing inventories/Inspector properties. Restart F6 for each independent session below to reset stock/drone/plots.

### Grounded controls

- **B** enters Build mode. **3** default quickbar Test Storage (bill **3 Test Ingots**, **10 seconds**). **8** default quickbar Prototype Ammunition Press (bill **5 Test Ingots**, **18 seconds**). **M** opens Building Catalog if assignments differ. **Right-click** exits Build mode.
- **P** toggles Blueprint mode (while Build is active). Direct Build with P OFF authorizes on a valid click at **Normal priority**. Blueprint with P ON creates a **PLANNED** job only — no dispatch/material movement until separately authorized.
- **Q** toggles blueprint area-select; drag around a planned site and **H/N/L** change priority only. With Q selection active **E** authorizes selected sites; without Q, hover and **E** authorizes one planned site. **Ctrl+E** authorizes all remaining plans. Press **X** while hovering an unfinished managed site to cancel it. Priority is never permission, and an active job is not preempted.
- Place unrotated Storage at the labeled **STORAGE SITE** near world position `(0,0,-3)` and Press at **AMMO PRESS SITE** near `(4.5,0,-3.5)`. Third distinct planned Storage near `(4,0,-1)` is an accepted test reference; check valid non-overlap/power coverage. If blocked/red, use an equally valid powered unoccupied position, not a ghost collision. The named guides are near the Hub and Starter Storage.
- Real generator control is the in-scene **Turn generator OFF (test)** / **ON (test)** button. Hub power is **12**, each active job requires **7**. Construction cannot advance without allocated electricity. The original single drone starts with battery **40/40**, cargo capacity **5**, and Starter Storage starts with **15 ingots**.
- **Cancel *after physical unloading but before construction completes*** for original-site inventory recovery tests. Cancellation does not teleport site materials. The SAME drone must finish/rearm previous job, fly to locked site staging, pick up, fly to eligible Storage, unload, return Hub, and recharge. A ticket count is not a completed return: watch **recovered** count and actual Storage stock. If the job finishes before X, restart that F6 session; do not count it as a cancellation pass.

## Session A — Direct builds and finite power (fresh F6; four checks)

| ID | Player action | Pass observation |
|---|---|---|
| **A1** | F6 new *Unified Construction* scene, press **B**, inspect HUD. | Original single drone **IDLE**, 40/40 battery, cargo 0/5; Starter Storage **15 ingots**; no free completed build or runtime error. |
| **A2** | P **OFF**; select **3**, click valid powered STORAGE SITE; never press E. | Direct click immediately queues original **Normal** Storage; same drone physically loads and delivers **3**; original stock becomes **12**, no instant finished building; job builds in **10 simulated seconds**. |
| **A3** | Select **8** and click valid AMMO PRESS SITE. Watch the one drone deliver five ingots and let the Press **enter active construction**, then immediately carry out A4 **before the Press completes**. | Press joins shared **Normal/FIFO** queue without a second worker; same drone physically delivers **5**, and Starter Storage is **7** after both physical pickups (15−3−5). Press is still an unfinished construction site until its original **18-second** timer completes; no instant finished Press or free production inputs. |
| **A4** | **Before Press completion**, while it is actively constructing after delivery (not while waiting), turn generator OFF and observe unchanged progress across several seconds; turn back ON, then **allow Press to finish**. Later observe the partly discharged drone at Hub, finite recharge and rearm. | Progress freezes OFF and resumes ON without a second worker or reset. After both buildings finish, Starter Storage stays **7**, one real Storage and one functional Press are complete, Press production inventory starts empty; battery does not charge with generator OFF but charges finitely when ON to 40/40. If dock charging window is missed, rerun F6 for that observation. |

## Session B — Blueprint authorization, priorities and material provenance (fresh F6; three checks)

| ID | Player action | Pass observation |
|---|---|---|
| **B1** | Press **B** then **P**. Place planned Storage 3 at STORAGE SITE, planned Press 8 at AMMO PRESS SITE and third planned Storage 3 at another clear powered plot. **Do not press E or Ctrl+E.** | Exactly three PLANNED sites, drone remains idle, original inventory **15**, no queue admission or automatic authorization/material debit. |
| **B2** | With Q area-select, drag-select first Storage and press **H**. Observe before E; then authorize only selection with **E**; Q exits selection. | High priority alone leaves all three PLANNED, stock 15, drone idle. E authorizes only selected Storage; other two stay PLANNED. The same original drone handles authorized job. |
| **B3** | **Ctrl+E** to authorize remaining Press and Storage, observe dispatch order/nonpreemption, wait for all three builds and rearm. | One original worker/queue, no active preemption; priority High first when free, Normal FIFO among peers, exact physical 3+5+3 spends **11 ingots**; final Starter Storage **4 ingots**, three completed structures, no extra stock/charge. |

## Session C — Delivered-site physical cancellation and custody (fresh F6 for Storage and Press; three checks)

| ID | Player action | Pass observation |
|---|---|---|
| **C1** | Restart F6; P OFF, Direct-build **3 Storage** at powered guide. Wait until delivery/unload (Storage **15→12**, drone cargo 0, site still unfinished); hover site, press **X**. | Original site cancels; no completed Storage, source stays **12** immediately after X; only when the SAME drone travels to original locked site and then physically unloads 3 at Starter Storage does **12→15**. Protected custody and no free refund. |
| **C2** | Restart F6; P OFF, Direct-build **8 Press** at powered guide. After real five-ingot unload but before 18-second completion (Storage **15→10**), hover and press **X**. | No completed Press; original staging retains five until drone actually retrieves and deposits them at Storage; **10→15** only at actual unloading; one recovered mission, no second drone. Generator OFF after delivery may pause construction if needed, but turn ON for final charging/recovery. |
| **C3** | During Press recovery and Hub recharge, observe docked drone battery below 40, briefly turn generator OFF and observe two moments; turn ON and wait for full 40/40, cargo 0, IDLE and recovery completed; wait longer. | Battery does **not** rise during OFF interval; ON restores finite charging, same drone rearms. Recovery reaches **recovered 1** (mission count), Starter Storage stays **15** after settlement; no duplicate return, no second construction or recovery owner. |

## Status and next steps

- **Manual Stage C current:** 0/10 reported, no assistant-run Godot or manual gameplay verification. Developer should report A1–A4, B1–B3 and C1–C3 explicitly, and send screenshots/error from first failure or ambiguity. Record partial passes truthfully.
- All current gameplay source and accepted E3d5c6b/E3d5c6c scenes/tests are preserved; no changes needed to run manual guide.
- When manual 10/10 is developer-confirmed, update `HANDOFF.md`, `DEVLOG.md`, `ROADMAP.md` and `DRONE_CONSTRUCTION_LOGISTICS.md`; then stage a **fresh complete 62-suite / 866-expected-check combined F6 gate** (61 historical + 1 unified Stage A suite). Do not count 39/536 targeted reruns as new checks.
- **For all future chats:** recreate the [interactive Godot F6 Copy navigator](GODOT_F6_COPY_NAVIGATOR.md), including per-check title, Previous/Next and working Copy scene path control, even when all manual checks share a single playable scene.
