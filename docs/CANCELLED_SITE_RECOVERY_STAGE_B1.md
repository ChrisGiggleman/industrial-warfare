# E3d5c6c Stage B1 — Cancelled-site Storage capacity reservation

Status: **staged implementation; local Godot F6 required; not accepted** (2026-11-20).

## Accepted checkpoint

E3d5c6c Stage A custody audit accepted: developer confirmed **13/13 isolated** plus **15/15 previously accepted compatibility suites totaling 218/218** (the corrected last suite `playable_direct_build_authorization_e3d5c6b_stage_b_test.tscn` passed 14/14 on local F6). Combined Stage A gate evidence is **16 suite executions / 231 checks**, including repeated checks. The **unique accepted milestone baseline remains 59 suites / 823 checks** (58/810 + one new isolated 13); Stage A compatibility reruns do not add to the unique count. No fresh combined 59-suite run claimed. Stage C manual E3d5c6b remains open.

## Stage B1 implementation boundary

The player expects a drone to retrieve **unused** ingots after a cancelled construction site was unloaded or cancelled during work. Stage A proved those materials remain with the original pinned staging source. Stage B1 prepares the exact **Storage capacity reservation** *before* any flight and uses only original ownership proven by Stage A.

Files added:
- `scripts/components/prototype_cancelled_site_recovery_capacity.gd` — separate, default-OFF scene-only recovery capacity authority. Registers no normal scene node or clock. The only permitted scope is existing `playable_direct_build_authorization_e3d5c6b.tscn` when an isolated fixture adds it explicitly.
- `PrototypeCancelledSiteCustodyAudit.matches_original_terminal_source(...)` — read-only exact job/staging/port/buffer identity verification against the previously locked custody ticket, not a mutation endpoint.
- `tests/cancelled_site_recovery_capacity_e3d5c6c_stage_b1_test.gd` + matching `.tscn` — isolated local Godot test.

Capabilities:
1. Only an original `ready_read_only` cancelled site is eligible. Completed, active, empty, unknown, mixed or forged source records never create return claims. Stage A still owns the original provenance; the registry claim remains locked.
2. Recovery service accepts only the **original one** rearmed idle drone and true existing Storage discovery service, destination-return service and original dispatcher in the same exact scene. It reserves a real `InventoryComponent.reserve_drone_return_space` claim using a private RefCounted token, not physical inventory. One outstanding claim per drone and ticket; duplicate service ownership refused.
3. Candidate Storage must be discovered and physically eligible, have `allow_returns` enabled and enough unreserved space, and pass finite energy forecast for **current drone location → captured original cancelled-site hover → Storage dock → home**.
4. Read-only observation identifies whether the held claim remains valid or quarantined if the original receiver moved, Storage return was disabled or source/service unavailable. A claim is **not silently released** by disabling a feature. Explicit authorized release/cleanup only releases **that Storage space token**, never the cancelled-site staging lock or ingots.
5. **No actual drone flight, pickup, cargo creation, staging debit, Storage credit, construction, inventory transfer, escrow manipulation, or authority changes to existing playable scenes.** Physical pickup/unload is the separate next Stage B2; completion/loaded cargo cancellation continue through the unchanged accepted paths.

## Required Stage B1 isolated F6 acceptance gate

Pull current main, open:

`res://tests/cancelled_site_recovery_capacity_e3d5c6c_stage_b1_test.tscn`

Press **F6** in Godot 4.6.2 Stable; expect **10 checks A–J**:
- **A**: default-off, exact scene, one configured authority.
- **B**: active construction cannot claim recovery stock.
- **C**: original Storage real physical three-ingot pickup/delivery; cancelled original job; drone rearmed empty and locked staging retained.
- **D**: foreign/unknown provenance refused.
- **E**: full Storage or another inbound space claim blocks reservation.
- **F**: single valid **3-unit** incoming capacity reservation; neither inventory nor drone/energy changes.
- **G**: duplicate ticket and duplicate capacity authority refused.
- **H**: disabled destination and moved original receiver quarantine existing claim without freeing stock.
- **I**: feature toggle OFF does not drop protected claim; explicit cleanup releases only destination space.
- **J**: same-worker retry, idempotent cleanup and exact `12 Starter Storage + 3 locked staging = 15` conservation.

Expected final banner:
`ALL 10 CANCELLED SITE RECOVERY CAPACITY E3D5C6C STAGE B1 TESTS PASSED`.

**No Godot local execution or test result claimed yet.** If anything fails, capture the first Debugger assertion and preceding Output PASS groups, and do not proceed to B2 until the isolated suite and a focused compatibility gate are accepted. Existing Stage A/B Direct Build, previous 56/785, and historical compatibility results stay accepted and unmodified.

## B2 planned separately

Extend the **existing one-drone physical lifecycle**, under a separate default-off gate, to physically fly to the original hover, debit only the authentic pinned staging inventory on confirmed arrival, carry exactly 3/5 ingots, fly to the reserved eligible Storage dock, unload through the exact destination capacity token and fly home/recharge. Preserve conservative waiting when no eligible capacity/power/battery, interrupted site/receiver, stale tokens or cancellation. No teleport, fabrication, direct resource unlock or competing dispatcher. Initial scope canonical Test Storage and Prototype Ammunition Press; add multiple-item/trip, researched silo/docks and fleet concurrency only later.
