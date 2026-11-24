# E3d5c6f — Stage B1: Identity-Only Single-Owner Controller

**Status:** Implementation committed on feature branch; **isolated F6 UNRUN** pending developer-local Godot 4.6.2 verification (2026-11-24). Do not mark accepted merely because GitHub files exist.

## Additive B1 changes
- New `scripts/ui/playable_specialized_drones_e3d5c6f.gd`: exact-scoped, default-off (outside its scene) controller; explicitly called `step_b1(delta)` is the **sole** bounded *observational* tick authority. `_process` and physics processing stay disabled; no movement, inventory writes, charge, worker readiness, dispatch, reconciliation, escrow mutation or timer advance. It requires one authentic Hub, exactly two distinctly named physical drone nodes, original-role authority, one each of the isolated queue/registry/escrow/scheduler/coordinator/power allocator/source service classes, and refuses legacy dispatch/fleet/charging controllers and duplicate B1 owners.
- Existing Stage A-only `scenes/core/playable_specialized_drones_e3d5c6f.tscn` updated to add the two separate `PrototypeConstructionWorkerDrone` nodes (`LogisticsDrone`, `ConstructionDrone`), real Hub instance, isolated service nodes, and inert `SingleTickController`. **Both movement/cargo features remain OFF.** No flight/battery configured yet. Scene is a contract/test harness, not yet a playable delivery simulation.
- New `res://tests/specialized_drone_single_owner_e3d5c6f_b1_test.tscn` with source fixture `tests/specialized_drone_single_owner_e3d5c6f_b1_test.gd`. Nine labeled PASS sections in source (not individual assertion count).

## F6 test navigator — one new B1 scene
**Test 1/1 (UNRUN):** `res://tests/specialized_drone_single_owner_e3d5c6f_b1_test.tscn`
Expected **9 printed sections**: A exact scope/Hub/identity; B disabled flight/cargo; C bounded explicit steps; D no custody/progress/worker changes; E PLANNED refusal; F duplicate owner; G legacy dispatcher refusal; H movement/pickup flag refusal; I opt-out. Run with **F6**, not F5.

After it passes, rerun the **two already accepted Stage A** isolated scenes as targeted compatibility, and report them separately. Do not count reruns as new suites. No fresh 63/880 regression has been executed for E3d5c6f, and original accepted tests/scene files remain unchanged.

## Boundaries / next gate
Stage B1 grants **no physical travel** or construction permission. It intentionally does not configure B2 supplier reservation, real cargo, delivery release/rearm or B3 distinct builder physical worker binding. The controller currently refuses queued jobs so it cannot accidentally advance anything until a separately approved B2 extension adds guarded dispatch. **Stage B2 not implemented**. Original Main, all E3d5c6b/c/d/e scenes, existing test fixtures and original gameplay-source files not edited. Preserve developer's uncommitted local `.tres/.tscn` files.

**Do not merge draft PR #1 or start B2 until developer reports B1 F6 outcomes and requests the next gate.**
