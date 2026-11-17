# Industrial Warfare — Drone Construction Logistics

**Decision date:** 2026-11-17. **Status:** agreed gameplay direction; implementation pending. This supersedes temporary direct conveyor-to-blueprint delivery as the intended ordinary construction workflow, not the validated implementation or existing tests. See [construction architecture](CONSTRUCTION_AND_POWER_ARCHITECTURE.md), [roadmap](ROADMAP.md), and [development log](DEVLOG.md).

## Factory versus construction transport

Permanent physical conveyors move raw resources, manufactured items, fuel and ammo between machines, storage and consumers (e.g. turrets or fuel-consuming power plants). Electricity travels through the power network, not conveyors. Construction workers collect physical cargo from eligible storage, deliver it to authorized sites, then construct. No disposable construction belt required. Keep the existing protected conveyor receiver, provenance, snapping and planned connection systems as validated compatibility paths; planned permanent factory belts may later connect to completed buildings without being needed for construction delivery. Do not remove safeguards or activate Main as part of this decision.

## Storage and infrastructure

- Retain general-purpose inventory storage and planned small/medium/large tiers. Start the isolated pickup prototype with existing Storage and an explicit pickup interface; an initial Hub/eligible starter supply is needed before research unlocks additional storage docks.
- Research unlocks a retrofitted docking attachment on existing regular Storage: landing/pickup/drop-off without rebuilding the warehouse or its conveyor connections. Only construction-enabled stock and compatible available docks are eligible. A basic dock is not an electricity generator or charger.
- Bulk silos specialize in one resource, with higher capacity; eligibility for drone pickup and deposit comes through appropriate docking infrastructure. Dedicated construction supply depots contain built-in docking, conveyor access and construction stock. Multiple distributed locations reduce travel distance.
- Main Hub starts the construction fleet; later drone service stations provide finite budgeted charging and maintenance. Remote storage dock charging and higher-tier relay/service charging are research candidates, requiring verified power and explicit finite allocation; no free charging.
- Proposed research branches: material collection, storage docking, bulk silos, supply depots, cargo capacity, speed, battery/endurance, construction speed, docking capacity, fleet size, remote charging and advanced routing. Exact dependencies, costs and numbers remain balancing decisions. Illustrative T1/T2/T3 cargo 5/15/30, battery 40/80/160, flight speed 2/3/4, work multiplier 1/1.5/2, charging multiplier 1/2/4 are not fixed production specs.

## Physical construction assignment

1. Player plans and explicitly authorizes (E/Ctrl+E). Priority influences queue order only.
2. Discover authorized, live, same-factory suppliers with eligible construction stock, dock access, and valid energy path. Prefer nearby eligible sources by actual route cost, starting with distance-based ranking in the isolated prototype. Include worker position, site location, battery return margin, cargo availability and dock contention. Do not select the geographically nearest building if it cannot serve the trip. Stable tie-breaking.
3. Reserve item quantities at source atomically against other drones and ordinary output consumers. Reservation is a claim on existing stock, not a remote move or duplicate inventory. Preserve source/item/job identity.
4. Fly to selected pickup point; physically arrive/dock, atomically debit exact reserved stock to finite drone cargo, release fulfilled source claim. No remote pickup.
5. Fly to site; on verified arrival, unload only matching item quantities into that site's owned staging. Multiple trips and suppliers later; staging and in-flight quantities count against outstanding demand.
6. Existing escrow reserves complete staged bill; existing finite power and worker presence gates authorize construction progression. Logistics flights must be permitted before full site escrow exists, unlike the current build-only dispatcher; separate transport admission from actual construction readiness without weakening the latter.
7. Activate real building once, commit cost only on successful completion, release construction allocation. Drone may take another eligible job when cargo is empty and battery/return reserve permit; otherwise dock at Hub or future powered service station. No charging without verified allocation.

## Cancellation, rerouting, and material conservation

- Cancel before pickup: release only unfulfilled source claims; drone may reroute safely.
- Cancel with cargo in flight: retain original physical cargo and identity, stop deliveries to canceled site, reserve compatible return capacity at the nearest available reachable storage from the drone's current position. Prefer shortest valid route, not necessarily original supplier. Eligible means live, owned, matching resource restrictions, enabled return docking, free capacity and safe battery reserve for return plus onward travel to a dock/Hub. Do not dump cargo onto an incompatible silo or into full storage.
- Fly to the chosen return dock; unload only upon arrival via atomic capacity-checked transfer. If destination fills, disconnects, is destroyed or loses eligibility, revalidate and select another eligible receiver; retain cargo throughout. Initial prototype may require one whole-load receiver; partial multi-stop returns are a later option. If none available, keep cargo protected and return to a safe reachable dock where possible or enter explicit recovery-needed state. Never delete, duplicate, teleport or abandon stock silently.
- Once cargo is empty and its reservation/assignment cleanup confirmed, check authorized queue for a new eligible job, subject to battery budget, then return to Hub/service station if none or insufficient charge. Do not reassign old job cargo directly in the initial prototype.
- Cancel after unloading: existing site staging and escrow must retain/refund all uncommitted resources independently of the site node; future recovery flights collect retained site stock. No automatic remote refund into unrelated storage. Cancel during work retains exact bill according to current atomic escrow policy (no partial build consumption yet). Completed consumed costs are not refunded by job cancellation.
- Account for every item in source inventory (including claimed-but-not-picked-up quantities counted once), drone cargo, site staging, held escrow, recovery stock or committed building bill. Reservation quantities and empty capacity claims are not new physical stock. Protect stock even if source/site/destination is destroyed or drone is disabled; recovery and persistence require later explicit design/testing.

## Power and verification

Maintain current build coverage, finite generation, outage pause/resume and explicit player authorization. Flight is battery powered; a safe return need not require energized site power. Existing build-only demo is retained as a regression baseline. E3d5c5x2 manual pause/resume, completion, cancellation at 31%, full refund and return accepted 2026-11-17. Automated 33/33 accepted.

## Proposed staged implementation

1. Completed: E3d5c5x2 manual resume and cancellation gate (2026-11-17).
2. E3d5c5x3 (accepted, 12/12 F6 checks, 2026-11-17): isolated supplier eligibility/discovery and one physical pickup/return dock contract on existing Storage, including deterministic nearest eligible selection and read-only actual battery forecast. No reservation or movement.
3. E3d5c5x4a isolated accepted (12/12 F6 checks); targeted compatibility accepted (16 suites, 207/207 checks): source stock claims, competing ordinary consumer protection and lifecycle release. E3d5c5x4b isolated accepted (14/14 developer-confirmed F6 checks): return-capacity claims and real timed conveyor contention; no actual cargo custody or deposit. Targeted compatibility accepted (20 suites, 245/245 groups; combined x4b 259/259, see [current handoff](HANDOFF.md)). Physical cargo custody and arrival transactions follow; no pickup in x4a.
4. E3d5c5x5a isolated pickup accepted (12/12 developer-confirmed F6 checks); targeted compatibility pending (28 suites / 397 checks, see [HANDOFF](HANDOFF.md)); x5b delivery follows acceptance: One drone: Hub -> Storage -> authorized site; finite cargo pickup, delivery, and existing escrow/power/worker construction; no direct belt-to-site required.
5. In-flight cancellation and nearest compatible storage recovery, destination invalidation, insufficient capacity/battery and no receiver tests. Empty cargo before next-job reevaluation.
6. Verified finite charging and repeated assignments; multi-trip delivery and multiple drones/sites.
7. Research-unlocked storage attachments, dedicated depots and bulk silo types, expanded power/charging and permanent conveyor handoff. Persistence, destruction recovery and playable Main activation require their own acceptance gates.

Milestones beyond the next isolated discovery step are sequencing proposals. Preserve all existing regression baselines. E3d5c5x3 is staged separately from the design decision; see DEVLOG for verification status.
