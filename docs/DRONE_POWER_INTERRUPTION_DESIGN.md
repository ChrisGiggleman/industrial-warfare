# Industrial Warfare — Construction Drone Power-Interruption and Specialized Drone Roles

**2026-11-23 source-audit update:** [E3d5c6e source-grounded architecture, exact opt-in boundary and staged tests](DRONE_POWER_INTERRUPTION_ARCHITECTURE_AUDIT.md) prepared. This remains a design proposal; no gameplay implementation or new test acceptance has occurred. Both the existing accepted scenes and 62/62 full regression are preserved.

**2026-11-23 — DESIGN PROPOSAL ONLY; no user approval to implement, no runtime/source changes.** Player suggests (1) a construction drone returning to Hub while power is out instead of hovering at a powerless site, leaving delivered construction materials there; and (2) separate material handling/logistics and construction drone types. Derived from accepted E3d5c6d Stage C manual gameplay and source read of `scripts/components/prototype_drone_automatic_dispatch.gd`, `prototype_construction_worker_drone.gd`, `prototype_drone_hub_charging.gd`.

## Actual current behavior (already accepted)

- One physical prototype drone handles supplier pickup, construction delivery, worker admission, active construction, return and Hub charging. `PrototypeDroneAutomaticDispatch.tick` calls exactly one phase per adapter-owned frame.
- After `DELIVERED`, the original coordinator admits the *same drone* as the construction worker; its state becomes `AT_SITE`. The dispatcher advances job time only if job state is `CONSTRUCTING` and original scheduler marks site active.
- On power loss the accepted job pauses, its materials remain in original protected staging/escrow according to job phase, and the single drone generally **stays at the site** in worker state rather than returning to Hub. A power pause is **not** a material-refund event.
- Recovery of cancelled, delivered materials uses original immutable custody, exact original staging/escrow, reserved return destination and a genuine same-drone site→Storage→Hub flight. Hub charging is bounded by real surplus generation.

## Recommended near-term separate milestone: suspended-worker Hub parking

**Goal:** When a construction job that has received its materials is held by a sustained generator outage, the same worker drone should leave the powerless site, return to an eligible Hub at finite battery cost, and wait until construction may resume. *Do not do this inside E3d5c6d's already accepted sources or Main.*

Proposed responsibilities and mandatory invariants:

1. **Only after delivery/unload and authentic worker admission** does a timed sustained outage trigger `PAUSED_POWER_AT_SITE` → `RETURN_TO_HUB` → `PARKED_WAITING_FOR_POWER`. A short flicker should not cause thrashing; select a tested debounce once scoped.
2. **Keep materials physically at their original assigned site.** Staging/escrow amounts, item identity, receiver claim and immutable custody ticket stay protected. No virtual movement from site to Hub, fabricated refund, freed receiver or duplicate supplier reservation.
3. **Suspend the original active worker admission safely** so no remote worker is counted toward construction and no job timer advances while the drone is at Hub. Job progress and original authorization/priority persist, and the job remains PAUSED. If resource shortage/low battery makes travel unsafe, remain in an explicitly safe wait state; do not teleport or strand cargo.
4. **Finish the return flight using the drone's existing reserved finite energy**, even if Hub electricity is off; a battery can fly without continuous generator output. Hub charging stays zero while generator OFF. The drone is parked while its *original job remains assigned* and cannot silently be dispatched to unrelated work or preempted by another queue entry.
5. **On restored power**, require original site still valid/authorized, actual electricity allocation, worker slot and full round-trip battery safety. Re-fly the same drone to the site, reacquire the original worker readiness grant and resume **from preserved progress**. If generator toggles mid-flight, handle in-flight transition deterministically. Never resume construction from a distant Hub or re-debit the already delivered material bill.
6. **If the player cancels during suspension/return/park/resume**, release worker claim safely, retain original site custody and use the existing physical site→Storage recovery path. If the original drone still holds material pre-delivery, handle through current cargo-return workflow; never abandon it at the wrong site.
7. **No second lifecycle owner.** Extend the original single adapter/dispatcher/worker state machine under an exact new opt-in scene and isolated tests; preserve old accepted E3d5c6b/E3d5c6c/E3d5c6d scenes and fixtures unless separately authorized. No automatic new job during outage, no new free stock/energy, no loss of reservations or charges.

**Test proposal (not run):** outage right after unloading, during construction at 30%, off-at-Hub zero charging, power restoration/re-approach/worker re-admission/progress preservation, repeated short power flickers, cancellation during each parking leg, recovery while return storage full, incomplete supplier pickup/material in drone custody during blackout, route energy insufficient case, no second worker/driver, no duplicate material debit, exact old 62-suite compatibility.

## Later, separately designed specialization — two drone roles

- **Material-handling drones:** move actual raw materials and construction items between Storage/silos and immutable site receiving ports; use physical pickups and deliveries, reserved stock and Storage return capacity, route charging and cancellation recovery. No worker grant or construction clock.
- **Construction drones:** physically attend authorized sites, consume only already-delivered/escrowed material bills with original coordinator/work slot and power, provide construction progress, park on blackout and resume. No direct supplier stock minting or delivery shortcuts.
- **Dispatch logic:** one canonical site/job queue; explicit independent logistics phase and build phase, each with exclusive claims, no duplicate ownership; any later multi-drone fleet requires bounded resource/energy contracts, explicit concurrency ownership and noninterfering loops.
- **Gameplay progression:** start with a single multi-purpose drone (existing) and unlock specialized logistics + assembly drones by research after a later scoped milestone. Separate research-level enhancements (Storage docking/Ammo silo/coal/solar/wind) are neither present nor approved now.
- **Design tradeoff:** specialization reduces wasted builder time moving resources and makes base logistics interesting, but adds two scheduling services, fleet contention, cancellation edge states and many more regressions. **Do not implement it merely to solve blackout parking**: implement parking first with one drone, then specialized roles in a standalone later milestone when the vertical slice benefits.

## Milestone / authority status

- **Current accepted:** E3d5c6d Stage A 16/16 isolated, Stage B 39/39 compatibility (536 expected rerun checks), Stage C manual 10/10, and **fresh combined 62/62 suites passed locally** with 866 manifest-expected checks (no individual assertion transcript). Full E3d5c6d milestone closed.
- **Next implementation candidate now that E3d5c6d is fully accepted:** a separate exact-gated drone power-interruption / worker parking milestone. **Not yet approved for source edits.** First audit current authority/job/worker contracts, then seek specific architecture approval and isolated F6/manual acceptance before any Main change.
- **Future separate candidate:** two-role drone fleet/research architecture. User suggested it for design discussion; it is **not yet an agreed implementation specification**.
