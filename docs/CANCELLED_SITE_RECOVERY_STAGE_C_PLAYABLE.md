# E3d5c6c — Stage C playable automatic cancelled-site physical recovery

Updated **2026-11-21**. **STAGE C FULLY ACCEPTED: isolated 14/14, targeted compatibility 27/27 suites / 381/381 existing checks, manual playable 10/10 locally confirmed.** This gate is separate from fully accepted Stage B.

## 2026-11-21 milestone closeout

### 2026-11-21 — E3d5c6c Stage C B3 ACCEPTED — FULL MILESTONE CLOSEOUT (14/14 isolated, 27/381 compatibility, 10/10 manual)

Developer provided a four-screenshot **real playable** Press recovery sequence concluding with `AUTOMATIC CONSTRUCTION — WAITING`, drone **IDLE**, battery **40.0/40.0**, cargo **0/5**, `Rearms: 3`, `Recovery: WAITING / IDLE | tickets 2 | recovered 1`, Starter Storage **12 ingots**, generator ON (Hub output 12) and all queue/building counts zero. Intermediate screenshots show a Press under construction **15% paused** with generator OFF (`Hub output 0`, `Waiting: power, workers`), later **DOCK WAIT** with partially charged drone **30.9/40** while generator OFF, then a fully returned unloaded `Recovery: ACTIVE ... staged 5` at battery **34.5/40** with Storage **12** and generator OFF, and finally the completed charged/rearmed single drone. Earlier developer confirmation explicitly established **battery charging remains stopped while generator OFF**, which, together with the current terminal full recharge/rearm evidence, satisfies manual **B3**. **Do not infer an uninterrupted generator-OFF battery-hold interval from these distinct intermediate screenshots alone:** different intermediate battery readings could include generator toggles between captures; the hold finding is grounded in the earlier explicit local confirmation, not a continuous video.

**Material conservation across two jobs:** Starter Storage begins **15** ingots; previously completed Storage spends **3** (no refund); attempted Ammunition Press delivery spends **5** and its post-delivery cancellation physically returns **5** via the original one drone, yielding **15−3−5+5=12**. Two custody tickets (`tickets 2`) are therefore expected; only the Press cancellation is a successful recovery (`recovered 1`), so `recovered 1` is **one mission**, not one ingot. The extra rearm count 3 likewise represents construction/recovery lifecycle completion, not duplicate inventory return.

**E3d5c6c Stage C manual 10/10 ACCEPTED**, all A1–A5, B1–B3, C1–C2. Stage C isolated **14/14 new checks** and targeted compatibility **27/27 prior suites / 381/381 rerun checks** were previously confirmed locally; **E3d5c6c Stage C FULLY ACCEPTED** within the **opt-in experimental playable scene** `res://scenes/core/playable_cancelled_site_recovery_e3d5c6c_stage_c.tscn`. Developer-reported live tests and screenshots, not tests run by assistant. **Unique accepted automated milestone baseline remains 61 suites / 850 checks** (manual and overlapping reruns not counted); no claim of fresh full combined 61/850 run. The *older* E3d5c6b Direct Build manual 10-check gate remains independently pending; Main and original Direct Build scene are not modified to use Stage C recovery. No new code changes in this documentation acceptance update.

**Next recommended development gate:** consolidate and harden opt-in playable recovery after documenting outstanding separate Direct Build E3d5c6b manual verification; do not silently replace Main, add multi-drone/storage dock/silo behaviors, release immutable custody locks, or bypass inventory/power.


## Accepted prerequisites

- Stage A cancelled-site immutable custody: local isolated 13/13 + targeted compatibility 15 suites/218 checks accepted.
- Stage B physical 3/5-ingot drone transport: local isolated 13/13 + targeted compatibility **26/26 suites, 368/368 checks accepted**.
- Cumulative **unique accepted automated baseline: 61 suites / 850 checks** (Stage C adds one new 14-check suite). The 368 Stage B targeted checks are existing reruns and must not be added again.
- Original E3d5c6b Stage C manual 10-check verification is still independently pending.

## What Stage C adds (experimental opt-in only)

New playable scene:
`res://scenes/core/playable_cancelled_site_recovery_e3d5c6c_stage_c.tscn`

New subclass adapter:
`res://scripts/ui/playable_cancelled_site_recovery_e3d5c6c_stage_c.gd`

**Stage C does not replace Main or the previously accepted playable Direct Build scene.** The new scene inherits the Factory Testing Sandbox setup and opts into the existing player authorization, one-drone construction runtime, and the Stage A/Stage B custody and physical recovery services. The accepted original adapter is unchanged. `WorldInteraction._direct_build_scope()` now has an **exact second allowed path** for this new Stage C scene, so placement enters the same secure Direct Build authorization path instead of falling through to the legacy build path. Every other scene remains unchanged.

On real Direct Build / authorized Blueprint site enrollment, the subclass records the original site's staging/port/job custody ticket. After **X cancellation**, it only recovers a ticket if the Stage A immutable audit verifies exact unused original 3 Storage or 5 Press ingots. Existing construction assignments finish their own returns and recharge before recovery takes the same idle drone. The subclass owns the **sole per-frame tick**; it calls either original construction dispatch **or** the Stage B physical transport, never both on a frame. A recovery ticket is prioritized over a new construction dispatch while ready; a full dock, unavailable dock or insufficient safe route energy causes conservative waiting (no source debit).

Stage B's original source/claim and finite-battery tests remain authoritative for cargo conservation. The only changes to those accepted modules are exact additional Stage C scope allowlisting and adapter processing permission when the **exact new Stage C adapter script** owns the playable tick. They are still default OFF elsewhere.

No researched drone Storage docking station, silo, multi-item, multi-trip, concurrent fleet, conveyor return, instant refund, persistence or destruction expansion is added here.

## First F6 acceptance gate — ACCEPTED: 14/14 NEW checks (A–N)

**Developer reported 14/14 checks passed locally on 2026-11-21; not assistant-executed.** For future reruns open:
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

**Now accepted:** Stage C's one new 14-check suite advances the cumulative unique baseline to **61 suites / 850 checks**. No fresh full 61/850 combined regression has been confirmed.

## Subsequent gates — targeted compatibility accepted; manual gameplay pending

**Targeted compatibility ACCEPTED locally on 2026-11-21:** Developer confirmed all 27/27 suites and 381/381 regression checks passed. The accepted checklist is in the [complete Stage C compatibility guide](CANCELLED_SITE_RECOVERY_STAGE_C_COMPATIBILITY.md) and `tools/cancelled_site_recovery_stage_c_compatibility.csv`: full Stage B manifest (26 prior suites, 368 rerun checks) plus Stage B isolated `cancelled_site_physical_recovery_e3d5c6c_stage_b_test.tscn` (13 existing checks). These are **27 existing suites / 381 overlapping checks**, not additional unique checks. Broader combined regression remains separately pending.

**Manual playable verification ACCEPTED (10/10 checks, developer-reported):** Use [the exact Stage C manual checklist](CANCELLED_SITE_RECOVERY_STAGE_C_MANUAL.md). Open the new Stage C playable scene with F6, not the F6 test fixture. Test direct Storage (3) and Press (5) separately: click to authorize within Hub power coverage, watch original physical material delivery, cancel with X after delivery, observe same drone's real original-hover pickup, real Storage unload and stock restoration, Hub return and finite charging. Confirm new builds are not authorized automatically, generator OFF pauses real charging, cancellation before delivery cannot fabricate stock, no double drone/duplicate recovery, old original Direct Build and Main remain untouched. Check UI's recovery status text and any blocked-capacity wait explanation. **Manual acceptance is independent of the 14 scripted checks.**

## Pull current source

```bash
git pull --ff-only origin main
```

Source-of-truth continuity: `docs/HANDOFF.md`, `docs/DEVLOG.md`, `docs/ROADMAP.md`, `docs/DRONE_CONSTRUCTION_LOGISTICS.md`, Stage B compatibility guide and this Stage C guide. Distinguish developer-reported local tests from staged source and unrun tests.
