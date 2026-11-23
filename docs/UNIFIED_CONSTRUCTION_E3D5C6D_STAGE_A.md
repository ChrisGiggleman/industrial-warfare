# E3d5c6d — Stage A: Unified Construction Gameplay Integration

**ACCEPTED on 2026-11-22: developer reports all 16 Stage A F6 tests passed locally in Godot.** The earlier pre-verification text below preserves the implementation/test plan's original pending status; it no longer describes the current acceptance result. Stage B compatibility and Stage C manual F6 have not yet been run. The 61-suite/850 expected-check legacy baseline plus one new 16-check suite gives **62 unique accepted suites / 866 manifest-expected checks**, but no fresh entire 62-suite run has been performed. This is user-reported local testing, not assistant execution.

**2026-11-22 — CODE STAGED, LOCAL F6 NOT RUN.** Developer approved the source-audited architecture. This is a new, exact-scoped, separately gated playable integration. Previously accepted 61 suites/850 manifest-expected checks are historical, unaffected by this staging.

## Architecture and exact scope

- New playable scene: `res://scenes/core/playable_unified_construction_e3d5c6d.tscn` (inherits Factory Testing Sandbox).
- Reuse the exact accepted E3d5c6c Stage C adapter script `scripts/ui/playable_cancelled_site_recovery_e3d5c6c_stage_c.gd` — the **sole `_process(delta)` owner**. On a frame it calls original construction dispatch OR original cancelled-site staged-cargo recovery, never both.
- Only existing gameplay edits: exact-scene allowlist additions in `scripts/world_interaction.gd`, Stage C adapter, `prototype_cancelled_site_custody_audit.gd`, and `prototype_cancelled_site_recovery_transport.gd`.
- No changes to `scenes/core/main.tscn`, `scenes/core/factory_testing_sandbox.tscn`, old E3d5c6b/E3d5c6c playable scenes, or their accepted tests. No new dispatcher, tick owner, drone, item, silo, docking feature, research path or power generator.
- Direct Build and E/Ctrl+E-authorized Blueprints reuse the original `WorldInteraction` authorization and EXACT priority queue; same scheduler/coordinator, site-owned staging and locked receiver, protected escrow, physical cargo, finite power and charging, and immutable cancelled-site custody tickets.
- Retain canonical Storage **3 Test Ingots/10 seconds**, Ammunition Press **5 Test Ingots/18 seconds**, one **5-item** drone, **15** starter ingots, **40** battery units, **12** Hub rated generation and **7** units per construction job.

## New Stage A F6 test — 16 proposed groups (NOT YET RUN)

`res://tests/playable_unified_construction_e3d5c6d_stage_a_test.tscn`

| Check | Required behavior |
|---|---|
| A | New exact-scoped scene starts original adapter, custody and transport |
| B | Main and original Direct/Recovery scene definitions keep their original adapter identities |
| C | One drone, one dispatcher, original queue, one adapter tick and no competing tick controller |
| D | Direct Press and Storage authorize Normal FIFO with no free stock |
| E | Planned High Blueprint remains unapproved, unchanged stock |
| F | Normal Direct Press physically collects five actual ingots |
| G | Delivery reaches pinned staging, escrow, finite power and worker, no second site timer |
| H | Explicit Blueprint authorization queues High without preempting Direct Press; generator OFF/ON pause/resume |
| I | Press builds once after 18 simulated seconds; real producer enabled and escrow committed |
| J | Same drone returns/recharges only with Hub power and rearms |
| K | High Blueprint builds before waiting Normal Direct; 3 real buildings consume 11 of 15 ingots |
| L | Pre-pickup cancel releases the original supplier claim |
| M | Loaded-cargo cancel waits at unavailable return dock, then physically restores five ingots |
| N | Post-delivery cancel uses exact original ticket and same drone to recover five staged ingots |
| O | Working cancellation settles escrow to locked staging; physical return restores three ingots |
| P | Full Storage blocks staged recovery until capacity restored; no duplicate transfer |

The F6 harness turns off normal adapter processing and drives **only its `_process(0.1)`**, including original internal dispatch/recovery/charge paths. It does not tick those services independently, fabricate inventory or advance construction jobs directly. Test scopes are sequentially created/freed.

## Exact VS Code / Godot instructions

1. In VS Code open the `industrial-warfare` repository and **Terminal → New Terminal**.
2. Check `git status --short`. Preserve any local edits; do not reset or overwrite unrelated work.
3. Use `git fetch origin`, `git switch main`, then `git pull --ff-only origin main`.
4. Open `project.godot` in **Godot 4.6.2 Stable** and allow imports/GDScript parsing to finish.
5. Open `res://tests/playable_unified_construction_e3d5c6d_stage_a_test.tscn` in the Godot FileSystem. Press **F6 (Run Current Scene)** — NOT F5.
6. In Output, verify ordered `PASS A` through `PASS P`; expected final exact line: `ALL 16 E3D5C6D STAGE A UNIFIED CONSTRUCTION TESTS PASSED`.
7. Inspect Debugger for errors. If a parser or assertion fails, stop and report the **first red error, source line and preceding PASS lines**. Fix only the issue; rerun F6 before proceeding.
8. **Do not mark Stage A accepted or start Stage B compatibility until the developer reports all 16 checks passing locally.**

Expected banner (not independently observed):
```text
PASS A: ...
...
PASS P: ...
ALL 16 E3D5C6D STAGE A UNIFIED CONSTRUCTION TESTS PASSED
```

After accepted isolated F6: separately run relevant existing compatibility gates, a manual playable F6 check on the new unified scene, then the full accepted 61-suite regression with any new isolated suites. Record developer-confirmed results in HANDOFF, DEVLOG, ROADMAP and DRONE_CONSTRUCTION_LOGISTICS without double-counting or claiming unrun tests passed.
