# E3d5c6c — Stage C playable automatic cancelled-site physical recovery

Updated **2026-11-21**. **STAGED / NOT YET RUN IN GODOT.** This gate is separate from fully accepted Stage B.

## Accepted prerequisites

- Stage A cancelled-site immutable custody: local isolated 13/13 + targeted compatibility 15 suites/218 checks accepted.
- Stage B physical 3/5-ingot drone transport: local isolated 13/13 + targeted compatibility **26/26 suites, 368/368 checks accepted**.
- Cumulative **unique accepted automated baseline: 60 suites / 836 checks**. The 368 targeted checks are existing reruns and must not be added again.
- Original E3d5c6b Stage C manual 10-check verification is still independently pending.

## What Stage C adds (experimental opt-in only)

New playable scene:
`res://scenes/core/playable_cancelled_site_recovery_e3d5c6c_stage_c.tscn`

New subclass adapter:
`res://scripts/ui/playable_cancelled_site_recovery_e3d5c6c_stage_c.gd`

**Stage C does not replace Main or the previously accepted playable Direct Build scene.** The new scene inherits the Factory Testing Sandbox setup and opts into the existing player authorization, one-drone construction runtime, and the Stage A/Stage B custody and physical recovery services. The accepted original adapter is unchanged.

On real Direct Build / authorized Blueprint site enrollment, the subclass records the original site's staging/port/job custody ticket. After **X cancellation**, it only recovers a ticket if the Stage A immutable audit verifies exact unused original 3 Storage or 5 Press ingots. Existing construction assignments finish their own returns and recharge before recovery takes the same idle drone. The subclass owns the **sole per-frame tick**; it calls either original construction dispatch **or** the Stage B physical transport, never both on a frame. A recovery ticket is prioritized over a new construction dispatch while ready; a full dock, unavailable dock or insufficient safe route energy causes conservative waiting (no source debit).

Stage B's original source/claim and finite-battery tests remain authoritative for cargo conservation. The only changes to those accepted modules are exact additional Stage C scope allowlisting and adapter processing permission when the **exact new Stage C adapter script** owns the playable tick. They are still default OFF elsewhere.

No researched drone Storage docking station, silo, multi-item, multi-trip, concurrent fleet, conveyor return, instant refund, persistence or destruction expansion is added here.

## First F6 acceptance gate — 14 NEW isolated checks (A–N)

**Not executed or accepted yet.** Open:
`res://tests/playable_cancelled_site_recovery_e3d5c6c_stage_c_test.tscn`
and press **F6** in Godot 4.6.2. Inspect Output + Debugger for full success.

| Check | Acceptance |
|---|---|
| A | Separate scene, original single drone and active sole adapter |
| B | Direct Storage authorization automatically captures immutable ticket |
| C | Original construction dispatch physically delivers 3 ingots |
| D | Cancelled original site retains 3 ingots and lock |
| E | Original assignment rearms, then adapter starts physical return with capacity reserved |
| F | Real original-hover flight and 3-ingot pickup, finite battery |
| G | Unavailable Storage dock holds cargo, no remote credit |
| H | Actual Storage arrival and 12 + 3 = 15 conservation |
| I | Drone returns to Hub, generator OFF prevents free charging |
| J | Generator ON finite rearm, exactly one recovered mission |
| K | No duplicate recovery, protected original staging lock |
| L | Separate Direct Press 5-ingot original delivery and cancellation |
| M | Full Storage conservatively waits; no debit or mission |
| N | Restored capacity triggers automatic 5-ingot recovery, real unload and rearm |

Expected final Output banner:

```
ALL 14 PLAYABLE CANCELLED SITE RECOVERY E3D5C6C STAGE C TESTS PASSED
```

The F6 harness invokes the **actual playable adapter** deterministic `_process(0.1)` entry; it never explicitly calls `recovery.begin`, `recovery.tick`, fabricates inventory or teleports the drone. It briefly disables engine-driven automatic processing to prevent double ticks in the fixture. This is **automated integration verification**, not a manual mouse/keyboard gameplay claim.

If a test stops or fails, send the **first Debugger error and preceding PASS lines**. Fix narrowly and rerun that scene. Do not mark Stage C accepted from partial output or a successful GitHub commit.

**Only after 14/14 locally pass**, count Stage C's one new suite/14 checks as unique: provisional baseline would be **61 unique suites / 850 checks**; do not promote before developer confirmation.

## Subsequent gates (NOT YET PERFORMED)

**Targeted compatibility:** At minimum rerun the full Stage B manifest `tools/cancelled_site_physical_recovery_stage_b_compatibility.csv` (26 prior suites, 368 rerun checks), and Stage B isolated `cancelled_site_physical_recovery_e3d5c6c_stage_b_test.tscn` (13 existing checks) to verify the new allowlist and adapter scope cannot regress the accepted original. These are **27 existing suites / 381 overlapping checks**; never add to unique baseline. Broader combined regression remains separately pending.

**Manual playable verification:** Open the new Stage C playable scene with F6, not the F6 test fixture. Test direct Storage (3) and Press (5) separately: click to authorize within Hub power coverage, watch original physical material delivery, cancel with X after delivery, observe same drone's real original-hover pickup, real Storage unload and stock restoration, Hub return and finite charging. Confirm new builds are not authorized automatically, generator OFF pauses real charging, cancellation before delivery cannot fabricate stock, no double drone/duplicate recovery, old original Direct Build and Main remain untouched. Check UI's recovery status text and any blocked-capacity wait explanation. **Manual acceptance is independent of the 14 scripted checks.**

## Pull current source

```bash
git pull --ff-only origin main
```

Source-of-truth continuity: `docs/HANDOFF.md`, `docs/DEVLOG.md`, `docs/ROADMAP.md`, `docs/DRONE_CONSTRUCTION_LOGISTICS.md`, Stage B compatibility guide and this Stage C guide. Distinguish developer-reported local tests from staged source and unrun tests.
