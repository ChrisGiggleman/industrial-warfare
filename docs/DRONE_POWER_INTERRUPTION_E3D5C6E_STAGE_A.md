# E3d5c6e — Stage A isolated F6: Construction Worker Blackout Parking and Resumption

**2026-11-23 — Stage A ACCEPTED: developer reports all 14 checks A–N PASSED locally in Godot 4.6.2.** Original STAGED / NOT RUN status below is historical and retained for traceability. Suite-level report is the evidence, not an assistant-run Godot execution or independently furnished Output transcript. Full 63-suite regression not run. **Next:** [Stage B compatibility F6 guide](DRONE_POWER_INTERRUPTION_E3D5C6E_STAGE_B_COMPATIBILITY.md), 42 suites / 584 expected rerun checks.

**2026-11-23 — CODE STAGED, LOCAL F6 NOT RUN OR ACCEPTED.** Exact new scene `res://scenes/core/playable_drone_power_interruption_e3d5c6e.tscn`, Godot **4.6.2 Stable**, `ChrisGiggleman/industrial-warfare` / `main`. Developer approved the [source-grounded Stage A architecture](DRONE_POWER_INTERRUPTION_ARCHITECTURE_AUDIT.md).

## New exact scene and implementation boundaries

- New `scripts/ui/playable_drone_power_interruption_e3d5c6e.gd` **subclasses** the original accepted Stage C recovery adapter, **does not override `_process`**, and creates no new tick owner. The original adapter controls either original construction dispatcher or original physical canceled-site recovery in a given frame.
- Original `scripts/components/prototype_drone_automatic_dispatch.gd` and `prototype_construction_worker_drone.gd` have **default-off and exact scene-guarded** power-parking flags. Power outage must be **continuous for 2.0 seconds** after authentic delivered-worker admission; a brief flicker leaves the drone at the site. Genuine original paused job/progress, original escrowing, original worker binding and protected receiver/source all remain pinned to this site. Battery-metered RETURNING/DOCKED/OUTBOUND legs park and return; when the Hub is OFF charging accepts zero.
- Three existing scripts have **additive exact-scene allowlist changes only** for Direct Build authorization, immutable cancellation custody, and protected recovery transport. No new material forwarding, imaginary energy, workers, drone classes, fleet, dispatchers, clocks or storage docks. All accepted old scenes and tests, including `scenes/core/main.tscn`, remain byte-for-byte unchanged.
- Expected original Press bill **5 Test Ingots / 18 seconds**, starting Storage **15 ingots**, one worker drone **40 battery / cargo cap 5**, original Hub output **12**, site demand **7**. On an intact power pause, Starter Storage remains **10** while five owned ingots remain escrowed at their original site; on terminal cancellation, actual physical site→Storage recovery eventually restores **15**, not immediately.
- **Code staged is NOT equivalent to test acceptance**. Prior full 62-suite / 866-expected-check acceptance remains historical; this *new* 14-check suite will be the 63rd unique suite **only if the developer reports all Stage A checks actually passed**.

## One new F6 scene — 14 test groups

`res://tests/playable_drone_power_interruption_e3d5c6e_stage_a_test.tscn`

| Group | Isolated requirement |
|---|---|
| A | New exact-scoped playable scene starts accepted recovery adapter and separately gated parking services |
| B | Main and older Direct, Recovery and Unified playable scene script identities remain unchanged |
| C | One drone, original queue, one dispatcher, no fleet/legacy tick controller; one adapter tick per step |
| D | Real five-ingot Press physically unloads to original locked staging then escrow; actual worker admitted |
| E | One-second generator flicker pauses construction without parking, stock or escrow changes |
| F | Sustained outage triggers safe return after two seconds; job remains PAUSED, worker slot released, escrow intact |
| G | Genuine battery-metered flight back to the same Hub, retaining original nonterminal assignment |
| H | Hub generator OFF holds docked battery constant; original job, custody ticket, stock and escrow unchanged |
| I | Restored real power and sufficient route energy allow same drone to start outbound trip to ORIGINAL site |
| J | Original worker only regains construction permission on physical arrival; no remote build or second debit |
| K | Original Press reaches COMPLETE once; original escrow commits once, battery and worker reuse bounded |
| L | Cancel while returning to Hub: original terminal rearm and exact five-ingot physical site recovery |
| M | Cancel while parked at unpowered Hub: original custody retained, no instant return, physical recovery later |
| N | Power restoration mid-return, second outage mid-reflight, simulated low-energy fail-closed hold, and cancellation while resuming outbound preserve original materials and physical recovery |

Test harness uses the **accepted original real placement and worker admission** and manual deterministic stepping of the **ONLY inherited adapter `_process(0.1)`**; it never advances the drone, dispatcher, charging, recovery, job clock or site process separately. Fixtures are created and freed **sequentially**. The low-battery negative test **only reduces charge** for adversarial simulation; it never adds fictional energy/items.

## Exact user F6 steps

1. In VS Code, open the existing `industrial-warfare` repository and check `git status --short`. Preserve any unfinished local work.
2. Pull safely with `git fetch origin`, `git switch main`, `git pull --ff-only origin main`. Do not discard or force-reset unrelated changes.
3. Open the project in **Godot 4.6.2 Stable** and allow scripts/scenes to finish parsing/importing.
4. Use the one-scene [interactive Copy navigator preference](GODOT_F6_COPY_NAVIGATOR.md) from the conversation, or open exactly `res://tests/playable_drone_power_interruption_e3d5c6e_stage_a_test.tscn` in Godot's **FileSystem**. Press **F6** (Run Current Scene), **NOT F5**.
5. Check Godot **Debugger for any red error** and Output for sequential `PASS A` through `PASS N`, ending with exactly `ALL 14 E3D5C6E STAGE A POWER INTERRUPTION TESTS PASSED`.
6. If the test stops at a parser/assertion error, **report the FIRST red error with the source line and last completed PASS label**. Do not claim Stage A accepted or proceed to compatibility until all checks pass. No assistant-side Godot execution is claimed.

## Next only after developer confirms 14/14

- Record developer-local Stage A isolated acceptance in HANDOFF, DEVLOG, ROADMAP and DRONE_CONSTRUCTION_LOGISTICS.
- Stage B: targeted compatibility of the already accepted systems, including existing 62/866 expected baseline without double-counting reruns.
- Stage C: actual F6 player mouse/key Direct Build, blackout pause/park/HUB wait/charging/resume and cancel/recovery.
- Fresh whole-baseline combined regression after Stage C; then close new E3d5c6e milestone. Do not promote Main, add two-role drone fleets, new ores, alternate power types, research/silos/docking until separately scoped and authorized.
