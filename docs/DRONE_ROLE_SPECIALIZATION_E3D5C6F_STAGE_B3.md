# E3d5c6f Stage B3 — Distinct Physical Construction Worker and Original 18-Second Press

**Implementation committed 2026-11-24 on `feature/e3d5c6f-stage-a-role-contracts`. Godot local F6 UNRUN. Stage B3 NOT YET ACCEPTED.** B2 fully targeted accepted: its new F6 and five compatibility reruns were reported passed locally. Historical E3d5c6e 63 suites/880 manifest-expected checks are previously accepted, **not rerun** for E3d5c6f.

## One physical mission, one job clock and one power/worker authority

Existing E3d5c6f exact opt-in scene `res://scenes/core/playable_specialized_drones_e3d5c6f.tscn` now includes two **default-OFF** additions: `PowerNetwork` (original `ConstructionPowerCoverageNetwork`) and `B3BuilderController` (new `SpecializedDroneBuilderE3d5c6fB3`). Stage A/B1/B2 fixtures remain compatible and unchanged. B3 F6 first executes the **previously accepted real B2 logistics mission** in the same scene: Storage starts with 15 ingots; logistics drone makes claimed pickup of 5, flies to the original Press receiver, unloads into the original escrow and returns physically; original Press remains QUEUED with zero work.

B3 then instantiates one original completed **power pole at (8,0,0)**, registers and links its original `ConstructionPowerNetworkNode` with the real Hub, configures the original `PrototypeConstructionPowerAllocator`, `BlueprintConstructionReadinessCoordinator` and **single** `BlueprintConstructionSlotScheduler` for **7 units** of Press demand with original site-owned registry/escrow/stock. No fabricated power flags or synthetic escrow. The B2 controller transfers the **single existing scene tick-owner weakref**, exactly once, to the new B3 controller; no parallel dispatcher, `_process`, timer, or worker controller is introduced.

Only after a valid original B2 escrow/receipt may the **different, empty ConstructionDrone** claim builder role and physically launch with real metered battery/route preflight. Original `PrototypeConstructionWorkerDrone.assign_to_site` and `advance_flight` move the builder. The original scheduler's newly **additive and exact-scoped** `bind_specialized_builder` requires original Stage A receipt and distinct builder claim, **physical arrival** (`is_at_site`), exact B3 scene/drone/coordinator/escrow identity and authentic coordinator material/power readiness. It delegates to the already accepted `bind_site_drone`; only ordinary `coordinator.reconcile()` can grant power/material/worker readiness, and **only original `ConstructionJob.advance(delta)`** clocks the 18 seconds once per explicit B3 step. Original site's building activation commits original escrow, marks job complete, and queues the old site for deletion; B3 keeps a retained original-job identity and never dereferences the freed site while the builder physically returns home. Logistics drone remains docked, builder energy is consumed, original Storage remains 10 ingots, completed Press is genuine. A blackout before worker admission prevents work, and a blackout during work pauses the original job with escrow retained until real power returns.

**Limitations:** Only one explicitly stepped single mission; no automatic gameplay simulation/UI, multi-site scheduling, full fleet reuse, nonterminal independent logistics rearm/charging policy, two-role cancelled-site physical recovery, shared charging fairness, save/load, or Stage D player validation. Main and all prior accepted E3d5c6b/c/d/e scenes/tests remain untouched. Original B2/Stage A logic not broadened.

## NEW F6 acceptance first — exact path

`res://tests/specialized_drone_builder_e3d5c6f_b3_test.tscn`

**12 labeled PASS sections (source, not assertion count):**
A unauthorized early builder refused; B exact Press/site/receiver setup; C real B2 delivery and escrow return; D real power and one finite slot; E distinct builder lease and transferred single tick; F battery-metered arrival under outage cannot grant worker; G restored power allows physical admission exactly once; H original construction clock at 6/18 and loss-of-power pause without escrow loss; I remaining 12 seconds yield genuine Press and once-only escrow commit; J builder metered return, zero active slots; K no replay or duplicate goods; L Main opt-out. **Godot unrun**. Open scene and press **F6**, not F5. Stop on FIRST parse or assertion failure; screenshot/line number for correction.

## Targeted compatibility after B3 new fixture passes

1. `res://tests/specialized_drone_logistics_e3d5c6f_b2_test.tscn` — 9 labeled sections (previously accepted B2)
2. `res://tests/specialized_drone_single_owner_e3d5c6f_b1_test.tscn` — 9 (B1)
3. `res://tests/specialized_drone_role_guards_e3d5c6f_stage_a_test.tscn` — 6 (Stage A)
4. `res://tests/specialized_drone_handoff_e3d5c6f_stage_a_test.tscn` — 7 (Stage A)
5. `res://tests/drone_physical_pickup_e3d5c5x5a_test.tscn` — 12 (historic cargo)
6. `res://tests/drone_physical_delivery_e3d5c5x5b_test.tscn` — 13 (historic cargo)
7. `res://tests/drone_post_delivery_cancellation_e3d5c5x7c2_test.tscn` — 13 (historic cancellation)

These are **seven reruns, not newly added unique suites or new checks**. Verify local outcomes separately. Only then consider Stage B3 isolated/targeted acceptance; B4 fresh combined regression and Stage C custody remain further gates. Developer's uncommitted `.tres/.tscn` files must not be reset or overwritten. Draft PR #1 remains unmerged; `main` remains unchanged.
