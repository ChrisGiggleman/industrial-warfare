# E3d5c6e — Stage C playable manual checks: blackout parking, return, resume and physical recovery

**2026-11-24 — STAGE C 10/10 ACCEPTED by developer-local report,** covering A1–A5, B1–B3 and C1–C2. User also supplied a partial gameplay screenshot showing one Press actively building at 30%, one drone at site, 29.5/40 battery, empty cargo, original Storage at 10 ingots, Hub output 12 and worker slots 1/1. Screenshot does not itself demonstrate blackout parking, resumption or actual cancellation recovery; those rely on developer's stated all-ten manual checks passed. No assistant Godot execution. The earlier 0/10 and instructions below are the originally staged manual test plan. [NEXT final fresh 63-suite / 880-expected-check regression](DRONE_POWER_INTERRUPTION_E3D5C6E_FINAL_63_SUITE_REGRESSION.md), **not yet run**.

**2026-11-24 — STAGED, 0/10 checks reported.** E3d5c6e Stage A isolated 14/14 and Stage B targeted compatibility 42/42 suites (584 manifest-expected rerun checks) **have been developer-local accepted**. This manual real-player-control gate is **not** established by those automated fixtures.

## Exact new scene — one single existing drone and construction driver

`res://scenes/core/playable_drone_power_interruption_e3d5c6e.tscn`

**Press F6 (Run Current Scene), NOT F5.** Godot 4.6.2 Stable. Do not edit Inspector flags, inventories, run a separate timer, or manually tick the drone. Use **actual mouse and keyboard**, the in-scene **Turn generator OFF (test)** / **ON (test)** button, and visible status/flight labels. This new scene inherits the accepted Stage C single-driver recovery adapter and keeps Main and previously accepted scenes isolated.

### Exact controls and starting resources

- Press **B** to enter Build mode; quickbar **8** selects **Prototype Ammunition Press** (cost **5 Test Ingots**, construction **18 seconds**). The on-screen HUD's number 5 describes the **material bill**, not the quickbar number. **3** selects Storage (3 ingots). Press **M** for Building Catalog if selection differs.
- Keep **P OFF** (Direct Build, NOT Blueprint) and click a valid powered **AMMO PRESS SITE** at the guide around `(4.5,0,-3.5)` near the Hub; if invalid/red, use a similarly valid clear, covered footprint. **X** hovering an unfinished site cancels it; don't press X after completion.
- One original drone starts **40/40 battery**, cargo cap **5**. **Starter Storage starts 15 ingots** and drops to **10** when the same drone physically collects five. Material staging/escrow at the site stays owned while paused; no 5-ingot instant refill on power loss.
- Hub generates **12 units** when ON, Press construction needs **7 units**. Power OFF causes immediate PAUSED job/progress. The new feature waits for approximately **2 seconds of continuously missing construction power** before the worker flies home; no instant drone teleport.
- HUD shows `Job progress`, `Battery`, `Storage`, `Worker slots`, `Rearms`, and new `Blackout worker` status. During return/park, the drone is still assigned to its old job but not physically acting as worker. Hub charging only happens on real power.
- **Use fresh F6 for independent Session C.** For manual cancellation, stop the generator and wait until the drone has actually parked and remains at Hub, then hover its original unfinished Press site and press X. Turn generator back ON only after cancellation. The same drone must later perform original physical locked-site→Storage return; do not count tickets as items already returned.

## Session A — Normal construction and power interruption (fresh F6; five checks)

| Check | Actual player interaction | Passing observation |
|---|---|---|
| **A1** | F6 the exact new scene, press **B**, inspect HUD, drone and generator before placing anything. | One IDLE drone (40/40 battery, cargo 0/5); Starter Storage 15; Hub ON, no build completed or script error; new status field visible. |
| **A2** | With **P OFF**, choose **8 Press** and click valid AMMO PRESS SITE. Wait for original drone to physically pick up/unload five and **actively construct**, before its 18-second completion. | Direct click admits one Normal job, Storage **15→10** after pickup; same drone first carries 5, then cargo 0 and becomes on-site worker; progress rises from zero. No free second drone/delivery. |
| **A3** | While Press is actively constructing, click generator **OFF for about 1 second**, then ON before 2 seconds continuously elapse. | Progress pauses immediately and resumes from same percentage; drone **stays on site** during short flicker. Starter Storage stays 10 and no custody recovery/refund. |
| **A4** | While same Press is still under construction, turn generator **OFF for longer than 2 seconds**. Observe through the job pause until drone departs and reaches Hub. | Progress freezes and never advances remotely; original drone physically travels back at decreasing battery, reaches Hub, `Blackout worker` becomes **PARKED / AT HUB**, one original job remains unfinished, Storage still 10. |
| **A5** | Keep generator OFF with worker at Hub for several seconds; watch battery, recovery and stock. | Docked battery stays fixed (no free energy); original site/progress remain untouched, no automatic refund/second drone or new job. |

## Session B — Power restoration and real worker resumption (continue Session A; three checks)

| Check | Actual player interaction | Passing observation |
|---|---|---|
| **B1** | While worker is parked, turn generator **ON** and observe HUD battery and drone state. | Electricity becomes available; drone only returns to the original Press when existing route/battery safety allows. Charging, if needed, is gradual and only with Hub ON; Storage remains 10. |
| **B2** | Watch the drone fly from Hub back to the original unfinished Press and regain on-site work. | No new material pickup/unload, no second worker/dispatcher; **no progress while drone is away**, then the original job resumes at its saved percentage on physical arrival. |
| **B3** | Let the resumed original Press construction reach completion and allow drone to return/recharge/rearm. | Exactly **one** Press building finishes; Starter Storage remains **10** (one 5-ingot bill), original progress commits once; same worker returns to Hub and eventually becomes IDLE/fully charged; no errors. |

## Session C — Cancellation while parked (RESTART F6; two checks)

| Check | Actual player interaction | Passing observation |
|---|---|---|
| **C1** | Fresh F6. Direct-build **8 Press** again. **After five ingots are delivered/unloaded and work starts but before completion**, turn generator OFF for 2+ seconds. Wait until drone is **PARKED / AT HUB**. Hover original unfinished site and press **X**, leaving generator OFF initially. | Job is cancelled, no completed Press, original stock stays **10**, and five original site-owned ingots are **not** instantly added back to Storage; no recovery completes while worker cannot recharge/rearm. |
| **C2** | Turn generator **ON** after C1. Follow the same drone as it rearms, physically visits the cancelled site's locked staging, collects five, flies to eligible Storage and unloads. Continue observing after recovery. | Starter Storage rises **10→15 only when actual unloading occurs**, recovered mission count becomes **1**, drone ends cargo 0/5 and returns/recharges. Extra observation does not generate duplicate returns, stock over 15 or a new construction worker. |

## What to report

- **Stage C remains 0/10, PENDING** until user explicitly reports these hands-on results from local Godot. If a behavior differs, stop at that check and provide screenshot / current HUD action, flight state, battery, Storage value and first debugger error.
- Upon developer-local **10/10 acceptance**, record in `HANDOFF.md`, `DEVLOG.md`, `ROADMAP.md` and `DRONE_CONSTRUCTION_LOGISTICS.md`, then stage **fresh full 63-suite / 880-manifest-expected-check F6 final regression** (old 62/866 baseline plus one new 14-check Stage A suite). Do not double-count the 42 Stage B compatibility reruns as new checks.
- Recreate the [working per-check Copy scene path / Previous / Next navigator](GODOT_F6_COPY_NAVIGATOR.md) in this and all future Industrial Warfare chats. All ten manual check cards share the same one new playable `res://scenes/core/playable_drone_power_interruption_e3d5c6e.tscn`.
