# E3d5c6f — Specialized Logistics vs Construction Drones: Read-Only Architecture Audit

**Audit date:** 2026-11-24  
**Audited GitHub HEAD:** `8cb5ddd466d95d750b2d9ac9161cdfea31f109a2` (`ChrisGiggleman/industrial-warfare`, `main`)  
**Status:** **SOURCE AUDIT COMPLETE; PROPOSED ARCHITECTURE ONLY.** Developer requested review and proposal, **not authorization for gameplay implementation**. No Godot code, scenes, tests, Main, or accepted baseline were edited in this audit. Document-only GitHub checkpoint may be committed separately. The provisional next ID **E3d5c6f** has not been previously used in the inspected tracked repository paths.

## 1. Accepted baseline and nonnegotiable invariants

Read [current handoff](HANDOFF.md), [roadmap](ROADMAP.md), [E3d5c6e closeout](DRONE_POWER_INTERRUPTION_E3D5C6E_CLOSEOUT.md) and [earlier specialization proposal](DRONE_POWER_INTERRUPTION_DESIGN.md). E3d5c6e is fully accepted *inside its exact opt-in playable scene*, NOT promoted into `scenes/core/main.tscn`. Evidence: Stage A 14/14 developer-local isolated; Stage B 42/42 existing F6 compatibility reruns (584 manifest-expected checks); Stage C 10/10 manual playable; final **63/63 unique suites passed locally with 880 manifest-expected checks**. User supplied suite-level results, not combined per-assertion logs; assistant did not run Godot.

The future two-role architecture must preserve:
- **One authoritative simulation frame/update owner**, with each individual physical drone and job advanced **at most once per bounded tick**. This does not mean only one physical drone can ever exist; it means no competing `_process` / dispatchers / recovery loops may advance the same entities.
- Actual item provenance through Starter Storage / dock → drone cargo → immutable owned site buffer → original escrow → completed building, or exact physical site buffer → authorized drone → reserved-capacity Storage on cancellation. No synthetic goods, virtual refunds, double delivery, duplicate escrow reservations, or lost claims.
- Priority/FIFO waiting queue and **explicit** authorization: PLANNED blueprints remain PLANNED; priority alone is not permission; current Direct Build authorization remains a separate gate.
- Worker permission is tied to original **construction drone physical presence**, real power and complete original material escrow; a transport drone **must never grant worker readiness or advance a construction clock**.
- Finite route energy and shared real Hub charging budget. Hub OFF gives no charge. Construction worker may use the accepted sustained blackout parking/resume model, preserving its exact job, progress and worker binding.
- Existing `main.tscn`, all prior E3d5c6b/c/d/e experimental scenes, and all accepted `tests/*.tscn` files unchanged until a separately approved phase requires exact-scoped additive source changes. New work defaults OFF outside its new experimental scene.
- Preserve [one-test-at-a-time Copy scene path / Previous / Next F6 navigation](GODOT_F6_COPY_NAVIGATOR.md) in every future chat.

## 2. Source inspected and actual constraints

| Component | Verified existing behavior / location | Consequence for specialization |
|---|---|---|
| [`prototype_drone_automatic_dispatch.gd`](../scripts/components/prototype_drone_automatic_dispatch.gd) | `_scope_reason` (around lines 162–196) enforces **exactly one** `PrototypeConstructionWorkerDrone` and `scheduler.capacity == 1`; `tick` (367+) sequences original pickup, delivery, worker promotion, construction, parking and rearm | Cannot insert a second drone into the currently accepted dispatcher scene or run two copies of it. New E3d5c6f coordinator must own two-role scheduling under an isolated scope |
| [`prototype_construction_worker_drone.gd`](../scripts/components/prototype_construction_worker_drone.gd) | One class combines cargo loading/delivery with physical work. `unload_delivery` (884+) sets DELIVERED; `_delivered_worker_valid` / `_promote_delivered_worker` (911+) explicitly require the **same cargo-delivering drone** and exact cargo/source provenance | Requires a new, guarded **separate-builder admission path** backed by immutable delivered-site proof, not a type-name swap or bypassing worker checks |
| [`prototype_construction_worker_drone.gd`](../scripts/components/prototype_construction_worker_drone.gd) | `release_docked_cargo_assignment` (1105+) requires terminal job / cleared escrow / no scheduler tracking and full authentic charge | Logistics drone needs a **new nonterminal transport-only release/rearm contract** after VERIFIED delivery (or a new role-specific transport state machine), while original material escrow remains held for builder |
| [`blueprint_construction_slot_scheduler.gd`](../scripts/components/blueprint_construction_slot_scheduler.gd) | `_is_eligible` (301+) requires real bound worker `drone.is_bound_to_site(site)` AND `drone.is_at_site()`; `bind_delivered_site_drone` (388+) calls cargo-linked worker promotion | **Only builder** may consume a construction worker slot. Retain physical-presence and power/material checks; Stage A builder handoff requires a new exact-scoped provenance-checked binding route |
| [`blueprint_construction_readiness_coordinator.gd`](../scripts/components/blueprint_construction_readiness_coordinator.gd) | `reconcile` (138+) validates complete original escrow/power then worker slot; `admit_delivered_worker` (314+) uses exact owned-source registry and same delivered drone | Reuse coordinator's materials/power authority and exact staging records; add no second independent requirement or timer authority |
| [`blueprint_construction_priority_queue.gd`](../scripts/components/blueprint_construction_priority_queue.gd) | `get_waiting_sites` (33+) orders authorized QUEUED sites by priority then registration order, without authorizing or moving anything | One canonical site priority/FIFO queue for both role dispatch phases; new handoff state may be an *adjacent role ledger*, never an alternative job or duplicate queue admission |
| [`blueprint_construction_site_staging_registry.gd`](../scripts/components/blueprint_construction_site_staging_registry.gd) and [`blueprint_construction_material_escrow.gd`](../scripts/components/blueprint_construction_material_escrow.gd) | Site registry validates pinned receiver and exact bill; escrow reserves once from original staging, commits on actual completion, recovers to original staging on cancellation | A material-delivery receipt can attest site/job/definition/buffer/escrow/bill but **must not move or mint items** |
| [`prototype_drone_supplier_reservations.gd`](../scripts/components/prototype_drone_supplier_reservations.gd) | `reserve` (44+) rejects duplicate claims for either same drone OR site and reserves actual source stock with owner token | Potential reusable logistics claim authority for one site/one material drone; confirm future multi-drone interactions and cancellation through new isolated tests |
| [`prototype_drone_return_reservations.gd`](../scripts/components/prototype_drone_return_reservations.gd) and [`prototype_cancelled_site_recovery_transport.gd`](../scripts/components/prototype_cancelled_site_recovery_transport.gd) | Return capacity reserved before inventory debit; recovery's `begin` (146+) explicitly waits for original **single** dispatch lifecycle to end, then uses the **same single** drone and ticket | Cannot simply point recovery at another drone. Need one exclusive recovery-owner lease chosen deterministically (logistics drone preferred), exact original site ticket, return capacity and safe builder abort/release |
| [`prototype_drone_hub_charging.gd`](../scripts/components/prototype_drone_hub_charging.gd) | Can register an array of drones and `advance_charging` (80+) distributes one real surplus-generation budget in fixed enrollment order | Existing budget is useful, but two drone IDs/registration and starvation/fairness must be proven; two role adapters must NOT separately call `advance_charging` in one frame |
| [`prototype_construction_drone_fleet.gd`](../scripts/components/prototype_construction_drone_fleet.gd) and [`prototype_construction_drone_tick_controller.gd`](../scripts/components/prototype_construction_drone_tick_controller.gd) | Historical E3d5c4w/z isolated one-shot **worker** fleet; separate explicit-tick controller advances flight, coordinator and jobs, with caller-supplied dock-power boolean | Valuable reference for physical occupancy/registration, **not drop-in** to accepted newer cargo/recovery/power lifecycle; do NOT run alongside current adapter as a parallel controller |
| [`playable_automatic_construction_drone_sandbox.gd`](../scripts/ui/playable_automatic_construction_drone_sandbox.gd) and [Stage C recovery adapter](../scripts/ui/playable_cancelled_site_recovery_e3d5c6c_stage_c.gd) | One `_process` owns dispatch or cancelled-site recovery per frame; current adapter has **one** `drone`, one `dispatch`, one `recovery`, and start-up identity guards | New scene/adapter must be exact opt-in, with **one orchestration tick** coordinating two drones/roles and real power/charging/recovery, never inheriting an active competing tick loop |
| [`playable_drone_power_interruption_e3d5c6e.gd`](../scripts/ui/playable_drone_power_interruption_e3d5c6e.gd) | New blackout-parking behavior is guarded to exact E3d5c6e scene; original worker retains job while temporarily at Hub | Builder role should eventually inherit the *semantics* of saved job/escrow/finite return, not assume existing code works unchanged for two physical drone instances |

**Audit conclusion:** The original accepted **one-drone dispatcher cannot be widened to two role instances without invasive contract changes**. The safest next milestone is a **new exact-scoped role coordinator plus role-specific lifecycle claims**, preserving the existing priority, staging, escrow, power and worker readiness *authorities* instead of duplicating them.

## 3. Alternatives considered

**Option A — Enable the legacy fleet beside the accepted dispatcher:** **REJECT.** Its distinct tick controller and worker-only assignment contract can duplicate job advancement and does not naturally support cargo custody or original real charging/recovery.

**Option B — Widen the existing live dispatcher/worker classes to multiple drones immediately:** **DEFER.** The dispatcher strictly counts one drone; delivered-worker, terminal rearm and recovery ownership are written around the same drone. In-place generalization would expose accepted gameplay to a large regression blast radius.

**Option C — Separate E3d5c6f scope, one orchestration owner, two explicit role leases, auditable material→builder handoff:** **RECOMMENDED.** Start with one logistics drone and one builder drone in a new experimental scope, one queued Press/Storage bill, one active construction worker slot. Implement contracts and isolated proof before playable movement; feature flags remain OFF in Main and old scenes.

## 4. Proposed ownership and state model (not implemented)

```text
Player explicitly authorizes original ConstructionJob (QUEUED; priority/FIFO)
         |
         v
Canonical original site/queue + pinned site receiver/escrow services
         |
         v
[LOGISTICS LEASE ONLY] one material-handling drone reserves source stock
  → flies to actual Storage → physically collects real bill (3 or 5 ingots)
  → flies to ORIGINAL site → physically unloads to pinned staging buffer
         |
         v
[HANDOFF RECEIPT] immutable site/job/definition/bill/registry/escrow identity
  → authoritative coordinator verifies COMPLETE site escrow
  → logistics lease releases only after cargo empty and safe finite return
  → NO worker readiness and NO job construction progress granted by logistics
         |
         v
[BUILDER LEASE ONLY] different physically identifiable construction drone
  → receives original job/site claim (no supplier debit or cargo)
  → route-energy preflight → flies to ORIGINAL site
  → existing scheduler admits physically present builder + real materials/power
  → one original construction timer advances exactly once per owned tick
  → sustained power outage: builder parks at Hub / restores / resumes job
  → completion commits original escrow ONCE, returns and recharges
```

**One site can have one logistics lease and one builder lease at different phases, never two concurrent owners of the same material or worker action.** The handoff receipt is **provenance and permission**, not a replacement source of materials or worker flags. Keep original site job states as source of truth; add one **separate role-phase ledger** (e.g., `PICKUP_RESERVED`, `CARGO_IN_FLIGHT`, `STAGED_ESCROWED`, `BUILDER_ASSIGNED`, `BUILDING`, `CANCELLED_RECOVERING`) only as subordinate observations/claims. Token fields should bind original site identity, actual job object and authorization generation, owned buffer/registry, escrow reservation, item/bill, role and unique drone identity. Failed or stale checks must freeze/quarantine, never fall through to ordinary dispatch.

**First vertical-slice limit:** one original Storage/Press bill (3/5 Test Ingots, each fits present five-unit capacity), one site at a time, one logistics drone, one construction drone, one construction worker slot, a single Hub and Starter Storage. No multi-trip, partial/compound bills, multiple hubs, fleets, permanent save/load or research unlock yet. These are separate follow-on audits.

### Cancellation, outage and charging rules

1. **Before pickup:** release source reservation token; no inventory debit or worker assignment.
2. **Logistics carrying materials:** original item stays physically in logistics cargo; reserve real return-storage capacity and fly back to an actual dock before unloading. Do not fabricate a refund.
3. **After site unload / before builder arrival:** original pinned escrow and staging own materials; cancellation makes them available **at the original staging source**. A uniquely assigned recovery drone later flies site→eligible Storage, with destination reservation made before source collection.
4. **Builder dispatched, constructing, returning from power loss or parked:** revoke/finalize builder worker lease safely while retaining original cancellation ticket and staged materials. Builder does not transport the canceled bill. A material-handling drone performs the recovery, but **existing single-drone recovery transport must be replaced/adapted only within E3d5c6f** with exact role/driver identity checks.
5. **Power OFF:** builder never advances absent site/power worker grant. After accepted two-second sustained outage, builder may return to Hub with finite battery; original job/escrow/progress remain. Logistics cargo movement may finish on finite battery without live grid generation; **neither drone recharges** until authentic generation returns.
6. **Charging:** one shared Hub spare-generation allocation per tick for BOTH registered roles, not two independent charge budgets. Fixed enrollment can starve the second drone; set a documented, deterministic role/fairness policy **before** enabling concurrent full-mission cases and test no budget overdraft.
7. **Destroy site / remove dock / fill destination / lose worker drone / insufficient route battery:** fail closed with physical cargo and claims retained where they actually are; resume or manual recovery only after suitable resources/route/identity return. Never teleport, discard, or silently move a claim to another site.

## 5. Proposed new-scene boundaries and implementation phases — require separate approval

**Provisional opt-in scene** (NOT YET CREATED): `res://scenes/core/playable_specialized_drones_e3d5c6f.tscn`  
**Proposed test prefix** (NOT YET CREATED): `res://tests/specialized_drone_..._e3d5c6f_*.tscn`

- **Stage A — role contracts and immutable handoff only (recommended first approval):** New default-off `E3d5c6f` role lease/receipt authority, exact scene identity guards, one canonical job and staging source. Isolated F6 tests for logistics vs builder identity, stale receipt rejection, unauthorized/planned site refusal, incomplete escrow refusal, duplicate claim refusal, and fail-closed cancellation. **No live two-drone movement or Main wiring in this step.** Before implementation, review the exact minimum new component names and make edits only within approved opt-in scope.
- **Stage B — first physical two-drone path:** Add a new isolated single-owner adapter and visible logistics + builder drone entities, actual 5-ingot Press pickup/unload, proof-based transport-only rearm, then separate builder flight/physical worker admission; original 18-second construction clock and single worker slot. Verify Storage 15→10, job completes once, no extra worker or second material pickup. Preserve original 63/880 acceptance with targeted legacy compatibility.
- **Stage C — full custody, outage and charging:** Add role-owned cancellation/recovery for pre-pickup, in-cargo, staged, building and parked states; shared real Hub charging, blackout builder parking and original-site resume; energy exhaustion, storage-full, dock-missing, worker-lost and duplicate-token tests. Stop at first custody mismatch; no synthetic emergency refund.
- **Stage D — real playable manual acceptance:** Player places a Direct/Blueprint Storage or Press using real mouse/keyboard, watches two distinct drones perform their jobs, tests short/long power outages, cancellation at each phase and recovery to Storage, actual battery/HUD state, one job queue and no Main changes.
- **Final:** Fresh combined regression = **63 previously accepted unique suites / 880 manifest-expected checks + only newly accepted E3d5c6f isolated suites**, counted once each. The number of new checks is **TBD**, not a prematurely invented 64th suite or asserted pass. Stage B reruns never inflate unique suite counts. Close milestone after developer-local isolated, compatibility, manual and fresh combined acceptance.

### Design questions to resolve at Stage A review

- Should the player begin with one existing **multi-purpose drone** and research-unlock specialized logistics/builders later? **Recommended**, but this is player-design scope, not part of Stage A.
- Should logistics assignment and builder assignment be sequential at first or overlap on different sites? **Recommend sequential on one site** for initial isolation, with parallel multi-site fleet scheduling reserved for a later milestone.
- Which drone performs cancelled-site pickup when logistics drone is already carrying another ticket? **Require explicit exclusive lease/priority and no double booking**; Stage A may model only one available logistics drone.
- How should shared Hub power be allocated to two charging drones (fixed enrollment, alternating fair share, priority)? **Decide before Stage C**; existing implementation is fixed enrollment, not fairness-guaranteed.
- Are alternate ore types, coal/solar/wind power, silo ammunition feeding, storage docking research and zombie combat in scope? **No**; defer to separate accepted planning/implementation milestones.

## 6. Approval and test status

**Developer authorized this READ-ONLY AUDIT ONLY. The proposed E3d5c6f implementation is NOT approved, no source changes have been made, no new F6 fixtures exist, no tests have been run.** Existing `main` and test scenes preserved. This audit is based on GitHub main source reviewed at the recorded SHA, not on locally running Godot. Read actual GitHub HEAD and test diffs again before any future Stage A implementation.

**Suggested next decision:** Approve **E3d5c6f Stage A role-contract architecture** *separately* before implementing new opt-in code. Maintain [HANDOFF](HANDOFF.md), [DEVLOG](DEVLOG.md), [ROADMAP](ROADMAP.md), [DRONE_CONSTRUCTION_LOGISTICS](DRONE_CONSTRUCTION_LOGISTICS.md) and the [Copy navigator convention](GODOT_F6_COPY_NAVIGATOR.md) across chats.
