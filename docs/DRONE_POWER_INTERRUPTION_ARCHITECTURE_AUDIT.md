# E3d5c6e — Power-Outage Drone Hub Parking: Source Audit and Proposed Architecture

**2026-11-23 IMPLEMENTATION UPDATE:** Developer explicitly approved Stage A, and new exact-scope implementation/test scene have been staged in GitHub. **LOCAL F6 STILL PENDING, zero new results accepted.** Source matches approved one-adapter-tick/one-drone model with default-OFF exact-scene-only driver/worker flags, a 2.0-second continuous-power-outage debounce, retained original escrow and job worker binding, battery-metered return and resume, authentic Hub charging, and terminal cancellation recovery. [Exact F6 acceptance guide](DRONE_POWER_INTERRUPTION_E3D5C6E_STAGE_A.md). All older “not yet authorized” passages below are audit-era historical status, not current approval status. Do not call the stage accepted without Godot-local A–N results.

**Status: read-only gameplay source audit completed 2026-11-23. Proposed Stage A implementation NOT YET CODED or tested.** Repository `ChrisGiggleman/industrial-warfare`, audited HEAD `b5c51ff69db2c4774221860641e75325758183fd`. Godot 4.6.2 Stable.

## Accepted starting baseline

- **E3d5c6d FULLY ACCEPTED**, experimental unified scene `res://scenes/core/playable_unified_construction_e3d5c6d.tscn`.
- Stage A isolated 16/16, Stage B targeted existing compatibility 39/39 suites (536 manifest-expected checks), Stage C manual 10/10, fresh full **62/62 unique automated suites passed locally** (866 checks expected in manifest; developer supplied suite-level acceptance, not a complete individual-assertion transcript).
- Current single drone, one authoritative playable adapter tick, original WorldInteraction/priority queue, physical material custody, pinned site staging, escrow and full battery/route constraints **must stay accepted**. Main, earlier E3d5c6b/E3d5c6c/E3d5c6d scenes and their tests are untouched in this audit.

## Actual inspected source and implications

| Source | Evidence from live main | Implication |
|---|---|---|
| `scripts/ui/playable_automatic_construction_drone_sandbox.gd`, `_process` | Calls `dispatch.tick(min(delta, 0.1))` as the ONLY simulation driver; no independent job/charge/worker process | New behavior must be driven inside the **existing adapter → dispatch** tick, never in a new parallel `_process` |
| `scripts/ui/playable_cancelled_site_recovery_e3d5c6c_stage_c.gd`, `_process` | Dispatches active construction OR gives a single cancelled-site recovery exclusive ownership of the same drone | Preserve single-driver construction/recovery exclusion; parked mission cannot be stolen by recovery or next job |
| `scripts/components/prototype_drone_automatic_dispatch.gd`, `_tick_once` | After `DELIVERED`, coordinator admits the drone, then `AT_SITE` advances `ConstructionJob.advance(delta)` only when CONSTRUCTING with active scheduler slot | Outage-specific transition belongs in an **exact opt-in extension of AT_SITE/RETURNING/DOCKED/OUTBOUND** |
| `scripts/components/blueprint_construction_readiness_coordinator.gd`, `reconcile` | Recalculates escrow ownership and real power allocation; site losing power pauses through scheduler before any next construction time step | Detect power loss via actual coordinator status/power allocator, not a fake `generator_off` state or a manual timer override |
| `scripts/components/blueprint_construction_slot_scheduler.gd`, `_is_eligible` | Worker is eligible only with original site-bound drone AND `drone.is_at_site()`; inactive/paused site retains its scheduler binding until terminal prune | **Keep original binding**, but parked/returning drone must report NOT physically at site; no remote progress or duplicate worker |
| `scripts/components/construction_job.gd`, `_refresh_readiness` | Missing power sets CONSTRUCTING → PAUSED and PAUSED → CONSTRUCTING restores existing elapsed lifecycle without `start()` reset | Keep original authorized job, time/progress and priority; do NOT invent a second construction clock |
| `scripts/components/prototype_construction_worker_drone.gd`, `advance_flight`, `is_at_site`, `is_bound_to_site` | Existing battery-metered `RETURNING` spends finite energy to Hub, `DOCKED` is true home, `OUTBOUND` meters return reserve; admitted worker retains original site/escrow associations | Add opt-in parked-mission latch and guarded begin-return/relaunch methods; reuse known flight physics rather than teleporting |
| `scripts/components/prototype_drone_hub_charging.gd`, `advance_charging` | Accepts finite charging for true docked/idle drone only, using allocator's actual spare generation; OFF yields zero | Use existing DOCKED charging (no special free recharge), while preventing normal terminal rearm of a *nonterminal parked* job |
| `scripts/components/blueprint_construction_material_escrow.gd`, `recover_to` and `commit_built` | Complete bill already debited from original pinned site source; cancellation refunds original buffer, successful site activation commits | **Power pause is NOT cancellation**: no source mutation/refund or second materials delivery on parking/resume |
| `scripts/components/prototype_cancelled_site_recovery_transport.gd`, `begin` | Original recovery waits for dispatch assignment to end and same drone to be fully idle; reserves actual return capacity before a site→Storage debit | Cancellation while parking must finish safe return/rearm, then allow existing recovery flow; never discard staged materials or bypass destination claim |

### Critical constraints / likely failure modes

1. Calling legacy `_on_site_ended()` to send a healthy paused drone home would **mark its site ended** and break safe resumption. Do not do so.
2. Calling the old terminal `release_docked_cargo_assignment()` for a parked, still-PAUSED job would be incorrect: it requires terminal job, clear escrow, no tracked old site and complete power charge. A parked job must remain assigned, with explicit status distinguishing it from terminal docking.
3. Worker binding is an ownership claim **not** proof that the worker is at the site. The actual `is_at_site()` check gates progress. Preserve binding while absent, and allow only the same original drone to return.
4. Existing `RETURNING` and `DOCKED` movements and charging can be reused under an explicit `parked_for_power_loss` latch, with dispatch priority for parking/resume over its generic rearm path. Short flickers need a debounced trigger to prevent unnecessary flights.
5. `is_at_site()` checks energy-to-Hub reserve. Outage return must still validate route and remaining battery, never silently disable battery metering. Unexpected insufficient energy or invalid origin should fail closed into explicit wait/quarantine.
6. Power may return **during return flight**, or fail **again during resume flight**; finish or safely redirect under deterministic rules, never process two movement phases on one tick.
7. If the player cancels or site is destroyed during return/park/resume, preserve cancellation signals, original escrow refund, staging lock and site custody; rearm original assignment before handing same drone to physical recovery. No remote material return or duplicate supplier claim.

## Proposed milestone: E3d5c6e (NEW exact opt-in only)

This is a source-grounded plan, **not yet an authorized gameplay edit**.

**Composition:** New separate `res://scenes/core/playable_drone_power_interruption_e3d5c6e.tscn`, inheriting current Factory Testing Sandbox, and a new lightweight subclass of the existing accepted playable recovery adapter at `scripts/ui/playable_drone_power_interruption_e3d5c6e.gd`. Reuse original drone/dispatcher, queue, scheduler, escrow, charging, custody and transport nodes; no additional `_process` owner. Enable new parking flags **only** in the new exact-scoped scene. Retain old scenes unchanged and feature-disabled.

**Minimal existing source patches (expected; final scope must be rechecked before write):**
- `scripts/world_interaction.gd`: additive scene allowlist only for Direct Build authorization.
- `scripts/components/prototype_cancelled_site_custody_audit.gd`: additive exact scene allowlist.
- `scripts/components/prototype_cancelled_site_recovery_transport.gd`: exact new scene+adapter-identity allowlist; no broad adapter matching.
- `scripts/components/prototype_construction_worker_drone.gd`: opt-in parked-job state/latch and guarded battery-metered return/resume; preserve all original movement/rearm and custody paths outside new flag.
- `scripts/components/prototype_drone_automatic_dispatch.gd`: opt-in pause detector and debounced parking/charge/resume transitions integrated into original `tick`; never a second tick.
- New adapter subclass inherits Stage C's existing sole `_process` and custody startup rather than independently stepping workers; verify virtual scene-scope methods. No edit to Main or accepted scene/test files.

**Exact single-drone behavior proposed:**

```text
AT_SITE + CONSTRUCTING (actual escrow and worker claim)
   └── real power lost → PAUSED (original ConstructionJob)
       ├── short outage → wait at site, no building time advances
       └── sustained outage (proposal: 2.0 s) → RETURNING to Hub
           └── DOCKED + original nonterminal job assignment retained
               ├── Hub OFF → 0 charge
               └── Hub ON → charge from real surplus generation
                   └── original power allocated AND battery route safe
                       → OUTBOUND to ORIGINAL site
                         → AT_SITE + scheduler eligibility reconciled
                           → original PAUSED job continues from saved progress
```

**Do not** re-collect/ship original building bill on return to the site. `BlueprintConstructionMaterialEscrow` stays held at site (or restored to original locked staging if cancelled); no duplicate pickup, delivery, worker, job, authority, or charge. Generic docked terminal rearm must not run while job remains merely PAUSED.

**Outage-flap policy candidate:** 2.0 continuous seconds without original construction power before parking; if electricity comes back during the outbound return leg, **finish safe return to Hub**, then recharge to the required round-trip reserve and return to site. If power fails on resume flight, use remaining return reserve and return safely, retaining original assignment. All timings should be explicit and testable.

## Tests / gates to implement separately

- **Stage A new isolated F6 fixture** in a new scene `res://tests/playable_drone_power_interruption_e3d5c6e_stage_a_test.tscn` (proposed 14 distinct assertion groups): exact scene/old opt-out, original queue/single tick, materials correctly delivered, brief flicker no parking, sustained blackout and worker revoke, metered return, docked zero charge while OFF, original escrow/progress/priority unchanged, ON finite recharge, original-site resume (no second delivery), resumed real work/commit once, cancel during return, cancel while parked/return-to-site, low battery/identity fail-closed and no double recovery. Test design may split groups if an isolated fixture becomes too complex.
- **Stage B compatibility**: explicitly rerun original 62-suite/866-expected-check baseline and selected scope/authorization supplemental scenes; **do not double-count reruns**.
- **Stage C manual F6**: actual generator button, completed-delivery pause, 2-second return, Hub OFF battery hold, restart power, original site reflight and eventual build, cancellation during parked state and real material recovery.
- **Final**: fresh combined regression with accepted new Stage A test(s), documentation and handoff. User locally executes Godot and reports pass; no assistant-run testing claim. Use [the persistent one-scene Copy/Previous/Next navigator](GODOT_F6_COPY_NAVIGATOR.md).

## Scope exclusions and approval boundary

**No gameplay files were modified by this architecture audit.** No new drone types, multi-drone fleet, extra tick owner, Storage research docking, silos, new ore or coal/solar/wind power generation in E3d5c6e. Future separate logistics-vs-construction drone roles remain a design proposal.

Implementation should follow explicit approval of this scoped plan, with new exact-scene feature gates, F6 checkpoints and fail-closed behavior.
