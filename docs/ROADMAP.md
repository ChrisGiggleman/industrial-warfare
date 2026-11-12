# Industrial Warfare — Development Roadmap

---

## Active Next Phase — Universal Construction, Blueprint Planning, Power (2026-11-08)

**Playable target:** One persistent zombie-planet demo, advancing the supplied defensive perimeter. Other planets/factions remain future expansion content.

### Acceptance before broader implementation

- [x] Timed Storage foundation, planned conveyor reservation, and delayed physical connection validated previously.
- [x] Planned conveyor finder **7/7** and Build Mode integration **6/6** passed in Godot 4.6.2; user confirmed live ghost hard-snapping to unfinished Storage.
- [x] Planned Storage bidirectional conveyor regression **8/8 passed** in Godot 4.6.2 (user-provided Output screenshot, 2026-11-08). Confirms rotated planned markers, two exclusive reservations, inactive precompletion flow, completion activation, input/output cargo conservation, occupied-belt demolition protection, and safe output disconnection. This is programmatic geometry/transport validation, not manual Build Mode acceptance.
- [x] **Manual planned Storage input/output placement accepted** (2026-11-08): player screenshots show a timed construction site with two correctly directed conveyor placements and, after completion, reciprocal Production Debug HUD evidence of `Input: Building port` and `Output: Building port` on the respective conveyors. This verifies visible bidirectional connection, not a new manual cargo-flow assertion.
- [x] **Manual right-turn preservation accepted** (2026-11-08): screenshot shows completed Storage, a visibly aligned 90-degree outgoing conveyor path, and the selected adjacent belt's Production Debug HUD confirming `Input: Building port` plus `Output: Next conveyor`. This confirms the first outgoing connection survives site completion; does not independently prove corner cargo transport.
- [x] **Manual opposite-direction / left-turn route accepted** (2026-11-08): user confirmed the layout works; screenshot shows a completed Storage, directional conveyor corner routing, and a selected incoming belt with `Input: Previous conveyor`, `Output: Building port`, and `Cargo: Prototype Rounds x1`. This confirms a buffered ammunition item on an attached conveyor, not yet a measured end-to-end inventory delivery or conservation total.
- [x] **Automated conveyor corner cargo regression 8/8 passed** in Godot 4.6.2 (player Output screenshot, 2026-11-08): in-place right corner preserves cargo/timer, right and rotated-left corners forward items, blocked output retains cargo and later resumes, and all three item types are conserved across the scripted test. This is standalone corner logistics validation, not yet a manual complete Storage receipt/accounting check.
- [x] **Conveyor cargo demolition safety 6/6 passed** in Godot 4.6.2 (user Output screenshot, 2026-11-08): empty conveyors allow demolition; occupied conveyors are protected; blocked removal preserves cargo; unloading restores eligibility; malformed cargo buffers fail safely; item-type-independent protection and conservation confirmed.
- [x] **Wreckage selection and cleanup 12/12 passed** in Godot 4.6.2 (user Output screenshot, 2026-11-08): selectable Layer-2 wreckage, live HUD inspection, empty cleanup, protected stocked caches, guarded material transfer, and conservation of ten recovered units all passed.
- [ ] Manual corner-to-completed-Storage receipt and end-to-end item accounting remain acceptance work for the larger sandbox. Avoid interpreting isolated cargo tests as a complete live factory conservation audit.
- [ ] Confirm local Git working tree and sandbox scene changes are reconciled before broad edits.

### Shared architecture design

Design specification drafted in [CONSTRUCTION_AND_POWER_ARCHITECTURE.md](CONSTRUCTION_AND_POWER_ARCHITECTURE.md) (2026-11-08). Review/acceptance and runtime implementation remain separate checkpoints.

- [ ] Review `BuildingDefinition`, `ConstructionLifecycle`, `ConstructionSite`, `WorldInteraction`, `FactoryGrid`, logistics ports, and existing destruction.
- [ ] Specify blueprint intent vs authorized queued work vs constructing vs operational; decide material and power gating, pausing, cancellation, footprint reservation and serialization boundaries.
- [ ] Specify hub power supply, relay connectivity, electrical coverage, and separate defense and drone-support areas *before* finalizing the universal construction model.
- [ ] Specify three candidate power-pole levels, increasing coverage and slow/medium/fast charging (exact numeric balancing deferred).

### Incremental implementation (not yet complete)

- [x] **Gate B — isolated ConstructionJob foundation 14/14 passed** in Godot 4.6.2 (user screenshot, 2026-11-08). Validated blueprint authorization, queued blockers, retained work through pause/resume, safe cancellation, one-time completion, work modifiers and explicit zero-duration test exceptions. No operational power, material delivery or worker service exists yet.
- [x] **Gate C isolated universal construction-site integration 15/15 passed** in Godot 4.6.2 (user screenshot, 2026-11-08). Validated opt-in `ConstructionSite.setup_with_job()` for planned/queued/constructing/paused Storage, non-operational conveyor and multiport merger blueprints, real activation, reserved connection, waiting cargo conservation, and cancelled jobs never spawning entities.
- [x] **Legacy backward compatibility Round 1 passed 10/10** in Godot 4.6.2 (player screenshots, 2026-11-08): `construction_site_test.tscn` 4/4 and `planned_storage_conveyor_test.tscn` 6/6. Existing timed Storage activation, footprint/port behavior, delayed conveyor reservation, conservation, and moved-link rejection remain intact after the opt-in universal site integration.
- [x] **Legacy backward compatibility Round 2 passed 13/13** in Godot 4.6.2 (developer screenshots, 2026-11-08): `planned_conveyor_port_finder_test.tscn` 7/7 and `planned_storage_build_mode_test.tscn` 6/6. Confirms nearest planned input preview, fractional port cursor alignment, reserved-port exclusion, activation after completion, and Main scene opt-in isolation.
- [x] **Legacy backward compatibility gate fully passed 23/23** across construction site 4/4, planned Storage reservation 6/6, planned-port discovery 7/7, and Build Mode integration 6/6 on the opt-in universal-site branch.
- [x] **Gate D1 per-definition construction durations 12/12 passed** in Godot 4.6.2 (player Output screenshot, 2026-11-08). All nine resources have positive provisional build times; power pauses freeze work; blueprints lack live cargo; Storage and belts activate only at completion; legacy manual-timed Storage remains unchanged.
- [x] **Gate D2 sandbox Blueprint Planning Mode scripted regression 12/12 passed** in Godot 4.6.2 (player Output screenshot, 2026-11-08): `WorldInteraction` test opt-in, P mode/HUD toggle, rotated Storage footprint and ports, overlap/off-grid rejection, fail-closed unsupported belts, requirement-blocked queue/pause, deferred Storage activation, cancellation, and explicit sandbox readiness override. Main scene flags remain OFF.
- [x] **Manual Blueprint Mode placement/authorization accepted** (2026-11-09): developer confirmed all seven F6 steps worked: enter Build Mode (B), select Storage (3), toggle Blueprint Mode (P) with correct HUD, place a transparent `PLANNED 0%` Storage through mouse click, aim at site, authorize with E, and observe timed construction to an operational Storage. This is player-facing validation, distinct from scripted 12/12.
- [x] **Manual Blueprint Mode cancellation/occupancy accepted** (2026-11-09): developer confirmed all six sandbox test steps worked, including placing a `PLANNED 0%` Storage, rejecting a second plan on its occupied footprint, hovering and cancelling via X, and successfully placing another plan in the released location. The screenshot shows the translucent `PLANNED 0%` site; cancellation/overlap outcomes are supported by the developer's explicit manual confirmation.
- [x] **Gate D2 building Blueprint Planning Mode accepted (manual + scripted)**: 12/12 scripted checks, seven-step player placement/authorization check, and six-step cancellation/overlap check completed in the Factory Testing Sandbox. This is for non-conveyor building plans only; debug availability override is sandbox-only.
- [x] **Pre-conveyor compatibility gate passed 14/14** (2026-11-09, Godot 4.6.2 user Output screenshots): `res://tests/planned_storage_build_mode_test.tscn` 6/6 and `res://tests/conveyor_corner_cargo_test.tscn` 8/8 passed after Blueprint Mode integration. The original timed Storage belt reservation/cargo flow and straight/left/right corner transport/backpressure conservation remain intact.
- [x] **Conveyor Blueprint Phase E1 scripted regression 14/14 passed** (2026-11-09, developer Godot 4.6.2 Output screenshot): `res://tests/conveyor_blueprint_e1_test.tscn` passed A–N. Verified cardinal, isolated two-second belt plans, direction/endpoints, exclusive tile reservations, inactive cargo/transport before completion, power pause and resume, exact-once real conveyor activation, safe cancellation/reuse, no phantom connections, and Main defaults off.
- [x] **Phase E1 manual interaction passed** (2026-11-09): player confirmed all seven Factory Testing Sandbox F6 steps, with screenshots showing multiple transparent `PLANNED 0%` straight belt sites and completed real directional segments. Verified mouse placement, 2s authorization, cancellation and tile reuse, plus regular conveyor placement after P-mode exit.
- [x] **Blueprint corner limitation identified, not an E1 regression:** perpendicular planned straights remain independent and do not convert to L-shaped corners. The live belt system already supports right/left in-place conversion; E2 must introduce a non-operational planned-route/endpoint contract before making planned corners visible or connectable.
- [x] **E2a planned route geometry passed 12/12** in Godot 4.6.2 (2026-11-09, player Output screenshot): direct and right/left corner intent, rotation, invalid facing/gaps, cancellation and construction eligibility recognized without changing any operational conveyor.
- [x] **E2b exclusive endpoint reservation regression passed 16/16** (developer Godot 4.6.2 Output screenshot, 2026-11-09): exclusive input/output claims; shared middle-belt completion; readiness in either build order; stable references across retired/freed sites; rejected stale geometry; right/left corner intent; cancellation, demolition and explicit release without phantom connections. Two earlier bugs (shared completion observers and freed-object casting) were corrected and now covered by the passing suite.
- [x] **E2c1 physical activation passed 15/15** (user Godot 4.6.2 Output screenshot, 2026-11-09): deferred direct/right/left connections, both build orders, three-belt chain cargo conservation, occupied-port and stale-geometry refusal, cancellation, demolition safety. `PlannedConveyorRouteActivator` remains the isolated validated adapter; operational conveyor code unchanged.
- [x] **E2c2 sandbox connected-belt integration automated 17/17 PASSED** (developer Godot 4.6.2 Output screenshot): `res://tests/connected_conveyor_blueprint_e2c2_test.tscn` passed A–Q, including straight links, rendered right/left planned corner markers, restoration after cancellation, both build orders, three-belt chain and two-hop item conservation, smaller labels, and Main opt-out. The new coordinator is enabled only in Factory Testing Sandbox; no power/material/worker service or standalone save system was added.
- [x] **E2c2 manual player acceptance passed** (2026-11-09, developer confirmation and three screenshots): six manual Factory Testing Sandbox steps succeeded, showing the planned and constructed right/left conveyor corners, authorization and completed routes, cancellation behavior, and normal P-off placement. An additional targeted manual check later confirmed E authorization is independent of selected-preview rotation; correct receiver direction is still required when first placing a valid route. The scripted 17/17 and manual checks remain accepted.
- [x] **E2c2 direction-independent E authorization confirmed manually** (2026-11-09, four screenshots and developer report): authorization and construction of already placed planned conveyor corners succeed regardless of the selected placement preview's current rotation. No targeting fix needed. Receiving-segment facing remains intentional for forming the directed connection during placement. Automatically orienting the next preview is a separate optional usability enhancement, not a current blocker.
- [x] **Post-E2c2 compatibility gate PASSED 45/45** (developer Godot 4.6.2 screenshots, 2026-11-09): E2b reservations **16/16**, E2c1 deferred physical activation **15/15**, planned Storage Build Mode **6/6**, and conveyor corner cargo **8/8**. The existing planned Storage, reservation, corner and cargo conservation behavior remains validated after E2c2 manual acceptance.
- [x] **E3a planned building-port geometry PASSED 15/15 in Godot 4.6.2** (developer Output screenshot, 2026-11-09): unfinished Storage input/output matching, rotation, correct direction, invalid/far endpoints, queued/paused eligibility, cancelled/completed rejection, and no premature operations. `res://tests/planned_building_port_geometry_e3a_test.tscn`. Main and player controller unchanged.
- [x] **E3b Storage-port reservations PASSED 18/18 in Godot 4.6.2** (developer screenshot): independent Storage input/output, duplicate rejection, build-order independence, cancellation and footprint reclaim, stale-endpoint rejection, freed construction-site cleanup, destroyed endpoint release, and legacy live-belt reservation priority. No live ports or cargo were connected.
- [x] **E3c0 shared blueprint claim broker PASSED 18/18** (developer Godot 4.6.2 Output screenshot, 2026-11-09): E2b conveyor routes and E3b Storage-port plans share atomic input/output claims, reject both claimant-order conflicts and invalid partial claims, preserve independent middle-belt sides, and release claims safely on cancellation, destruction and freed construction sites. `res://tests/shared_blueprint_endpoint_ownership_e3c0_test.tscn`. The broker is **not yet installed in the player sandbox**; no physical port link or cargo was created.
- [x] **E3c1 isolated physical Storage-port activation PASSED 18/18** in Godot 4.6.2 (developer Output screenshot): both construction orders, rotated input/output, occupied/invalid/stale connections, cancellation/demolition safety, mixed E2b/E3b broker ownership, end-to-end ore through Storage and blocked-belt backpressure. `res://tests/planned_storage_port_activation_e3c1_test.tscn`. No gameplay controller or Main changes were needed to validate this component.
- [x] **E3c2a sandbox automatic Storage-port discovery PASSED 16/16** (developer Godot 4.6.2 Output and gameplay screenshots, 2026-11-09): Storage-first/belt-first planning, independent ports, single shared E3c0 broker, deferred physical activation, rotated Storage, mixed multi-step ore conservation, backpressure, cancellation, existing conveyor corners and Main opt-out. `res://tests/connected_storage_blueprint_e3c2a_test.tscn`.
- [x] **E3c2b Stage 1 — planned Storage port preview snapping STAGED (not yet Godot validated):** `BlueprintStoragePortSnapPreview` finds the nearest unclaimed planned Storage input/output using raw mouse coordinates, existing planned-port transforms, requested conveyor rotation and strict 0.65-tile attraction. Sandbox-only `WorldInteraction` uses this read-only choice for the straight conveyor ghost and still validates footprint before placement; Main stays opted out. `res://tests/storage_blueprint_preview_snap_e3c2b_test.tscn` has **14 checks, NOT YET RUN** for markers, fractional cursor, direction, radius, input/output, cancellation, rotated Storage and Main opt-out. No new operational or cargo code.
- [ ] **E3c2b Stage 2 — manual visual acceptance after F6:** open Factory Testing Sandbox, use B → conveyor 5 → P, approach the future Storage IN/OUT markers with correct R rotation; verify the green preview hard-snaps to their future belt tiles and both placed belts reserve and complete after E. Test X cancellation, wrong facing, and old P-off snapping. Rerun conveyor and Storage compatibility suites before widening to other buildings, power, or Main.
- [ ] **Next connection scope:** planned belts to unfinished Storage and other building ports, bridge/short-gap path planning, robust multi-turn route editing, and full resource-delivery validation remain separate checkpoints before enabling in Main.
- [ ] After 16/16 passes, E2c must bind reservations to player planning, show real L-shaped blueprint placeholders, and commit existing corner/direct physical connections only when both neighboring conveyor builds complete. Test right/left turns and either build order, cargo conservation, demolition, and cancellation before enabling in Main.
- [ ] **E2/E3 later:** design/test directional graph reservations, Storage port snapping, build-order independence, corner conversion, collision and cargo conservation. These are not included in E1.
- [ ] Design/test directional planned-conveyor geometry, endpoint reservations, corner handling, queued activation order, cancellation and cargo conservation without changing Main until each independent checkpoint passes.
- [ ] Extend universal job/site integration to live, opt-in Build Mode only after regressions; implement per-building construction times and non-operational planned conveyors before enabling any universal feature in Main.
- [ ] Add Blueprint Mode with safe preplanning, port markers, cancellation, authorization and queueing.
- [ ] Implement Main Hub initial power and connected pole/relay coverage, then generation/consumption and tiered drone recharge.
- [ ] Add worker drones, material-consuming construction, physical supply priorities and powered turret/wall expansion.
- [ ] Finish a small playable zombie horde defense-and-expansion demonstration; reserve other worlds, enemy factions, and interplanetary travel for after the first slice.

**Scope guard:** Keep Main scene and validated logistics/combat systems stable. Use opt-in features and Godot F6 regression suites. No disconnected save system.

---

This roadmap tracks the major development stages for Industrial Warfare.

The current goal is to build a small, playable vertical slice before expanding into larger systems.

---

## Blueprint Conveyor Ghost Hard-Snap — Cursor Coordinate Correction (2026-11-07)

- [x] Player verified delayed connection works, but yellow conveyor placement ghost does **not** visibly hard-snap to an unfinished Storage blueprint.
- [x] Trace live WorldInteraction preview: planned finder incorrectly received integer-snapped `mouse_grid_position`, despite fractional building-port placement.
- [x] Pass the raw `hit_position` instead, preserving original building-port direction and hard-snap transform validation.
- [x] Expand `planned_conveyor_port_finder_test.tscn` to **7 checks** including fractional cursor proximity.
- [x] Run updated finder regression **7/7** and Build Mode integration regression **6/6** in Godot 4.6.2 (player-confirmed screenshots, 2026-11-07).
- [x] Recheck hard-snapping in the F6 factory sandbox with a new unfinished Storage blueprint: **player confirmed snapping works** (2026-11-07).
- [ ] If still not snapping, inspect preview precedence and camera-hit targeting before adjusting collision safety or connection logic.

**No modifications to completed building connectivity, cargo transport, or Main scene construction settings.**

---


## Planned Storage — Visible Port Snapping Correction (2026-11-07)

- [x] Manual F6 testing confirmed a reserved conveyor connects once Storage is complete, but the placement ghost does **not reliably snap** when aimed at the unfinished Storage.
- [x] Extend `PlannedConveyorPortFinder` to accept the cursor near either the planned port or the proposed belt origin, retaining direction filtering and original tight search radius.
- [x] Expand `planned_conveyor_port_finder_test.tscn` to six checks, including cursor directly over planned input.
- [ ] Run 6-check finder regression and existing 6-check sandbox Build Mode integration test.
- [ ] Verify actual ghost moves/snaps to unfinished Storage port before click in F6 sandbox, without affecting parallel belts, corners, or R rotation.

**Status:** Discovery adjustment committed; local Godot validation pending.

---


## Planned Storage Conveyor Reservation — Checkpoint 1 (2026-11-07)

- [x] Add non-operational `PlannedInputPort` / `PlannedOutputPort` marker geometry copied from the future building's actual scene.
- [x] Implement optional physical-belt reservation and revalidation of endpoint geometry when construction finishes.
- [x] Add `tests/planned_storage_conveyor_test.tscn` covering six checks: geometry, reservation exclusivity, waiting cargo, completion connection, conserved unloading, and rejection of moved belts.
- [x] Run the six-check Godot regression: **6/6 passed** in Godot 4.6.2 (2026-11-07).
- [ ] Wire Build Mode preview/click handling to planned markers without bypassing existing collision and conveyor corner rules.
- [ ] Validate live blueprint-to-conveyor construction and demolition/salvage behavior.
- [ ] Only then consider enabling planned connections in the normal zombie-planet demo.

**Status:** Reservation logic passed local tests. Preview finder is now committed for separate regression; manual in-game placement around unfinished Storage is not yet available.

### Planned-port discovery checkpoint

- [x] Add `PlannedConveyorPortFinder`, a separate read-only preview finder for planned Storage input/output markers.
- [x] Add `res://tests/planned_conveyor_port_finder_test.tscn`, checking rotated geometry, snap range, requested belt direction, reserved port exclusivity, and completed-site exclusion.
- [x] Run the five-check Godot discovery test: **5/5 passed** (2026-11-07).
- [x] Integrate the finder with an **opt-in sandbox-only** Build Mode preview/click route, keeping existing corner and collision checks.\n- [x] Add `tests/planned_storage_build_mode_test.tscn` with six checks for controller reservation, cargo conservation and Main scene isolation.\n- [x] Run the six-check sandbox Build Mode integration test in Godot 4.6.2: **6/6 passed** (2026-11-07).\n- [ ] Finish manual acceptance for both planned input/output ports, belt direction, completion and cargo transfer; **visual hard-snapping confirmed** in F6 sandbox.

**No player-facing snap changes at this checkpoint.**

 No WorldInteraction placement changes in this checkpoint.

---


## Timed Storage — Conveyor Delivery Compatibility (2026-11-07)

- [x] `construction_footprint_ports_test.tscn`: **4/4 passed locally**; unfinished sites reserve the physics footprint and expose no inventory/port.
- [x] Add `tests/timed_storage_conveyor_delivery_test.tscn` covering site completion, a physically snapped conveyor, one ore delivery, item conservation, and disconnection cleanup.
- [x] Run `timed_storage_conveyor_delivery_test.tscn` in Godot 4.6.2: **6/6 passed** (2026-11-07), including actual cargo delivery and conservation.
- [x] Verify player-built conveyor connection in F6 sandbox to completed timed Storage: user screenshot shows **11 Prototype Rounds / 200** in completed Test Storage, HP **100/100**, with adjacent physical conveyor chain (2026-11-07).
- [ ] Later: design delayed building-to-existing-belt snapping, to avoid premature connections before construction completes.

**This checkpoint adds a regression scene, not new live snapping logic.**

---


## Construction and Conveyor Compatibility — Footprint Checkpoint (2026-11-07)

- [x] Confirm factory testing sandbox accepted (3/3 test checks and manual stationary-zombie verification).
- [x] Inspect ConstructionSite collision reservation and Storage port activation on completion.
- [x] Add `tests/construction_footprint_ports_test.tscn` validating placement layer, actual Godot overlap detection, absent premature inventory/ports, and final inventory/ports.
- [ ] Execute new 4-check physics-world regression in Godot 4.6.2.
- [ ] Test physical conveyor endpoint connection and cargo conservation after timed construction completes; no automatic reconnection is implemented in this checkpoint.
- [ ] Enable timed construction for conveyor-attached buildings only after those logistics checks pass.

**Checkpoint:** Regression scene committed; local execution pending. Main game and sandbox behavior unchanged.

---


## Factory Testing Sandbox — Temporary Developer Convenience

- [x] Add `res://scenes/core/factory_testing_sandbox.tscn` as a separate developer-only copy of the current Main scene, with `PrototypeMovingZombie.process_mode = DISABLED`.
- [x] Enable timed Storage construction only in this sandbox; `main.tscn` keeps the zombie active and its original construction flag unchanged.
- [x] Add `res://tests/factory_testing_sandbox_test.tscn` with three focused settings-isolation checks.
- [x] Run sandbox regression (F6): **3/3 checks passed** in Godot 4.6.2 (2026-11-07). Player confirmed in-game sandbox operates with the green zombie inactive; construction and conveyor compatibility testing can proceed without combat interruptions.
- [ ] Reconcile the temporary sandbox scene if the main prototype scene changes in future checkpoints.

**The sandbox is an isolated development aid, not a permanent combat or zombie AI change.**

---


### Timed Storage Manual F5 Acceptance — Next Step

- [x] Controller integration `tests/timed_storage_placement_test.tscn` **4/4 checks passed locally** (2026-11-06).
- [x] In Godot Main scene, temporarily enable `WorldInteraction.enable_timed_storage_construction` for F5 demonstration (default intentionally remains false for existing regression compatibility).
- [x] Place free-standing Test Storage with shortcut 3: F5 screenshot confirmed blue site at 47%, followed by screenshot of completed Storage with IN/OUT markers (2026-11-06). Actual live cargo flow still pending verification.
- [ ] Verify ordinary conveyor placement is unaffected. Storage directly snapped to an existing belt remains on the old immediate-placement path until a separate delayed port-connection integration is tested.
- [ ] Restore the Inspector flag to disabled after this focused acceptance test to retain the established baseline.


### Timed Storage World Integration — Opt-in Validation

- [x] Local Godot passed all **4/4** isolated ConstructionSite tests on 2026-11-06; combined with lifecycle **6/6**.
- [x] Added an opt-in `WorldInteraction` path for **standalone Test Storage** to place a ConstructionSite instead of an immediate building; ordinary placement defaults remain unchanged.
- [x] Added `tests/timed_storage_placement_test.tscn` with four checks for the controller integration, site footprint, timed activation and rejection of unsupported definitions.
- [x] Run the new regression in Godot 4.6.2 (**4/4 passed**). Main-world timed placement remains deliberately opt-in pending F5 inspection.
- [ ] Integrate the specialized conveyor-attached placement path and confirm no early inventory/port transfer.
- [ ] Enable construction sites in normal F5 gameplay after passing new tests, then manually test progress, location, rotation, collisions and completion.

**Status:** Opt-in world integration committed; new Godot checks pending.

---


## Zombie-Planet Playable Demo — Active Development Focus (2026-11-06)

- [x] Confirm **one zombie-planet demo** as the immediate scope; other factions, worlds, and interplanetary launches are later campaign features.
- [x] Define fortified perimeter expansion, shared ammunition/construction resource economy, RTS command view, optional player drone, and worker construction drones as design directions.
- [x] Add isolated `ConstructionLifecycle` with planned / constructing / complete states, progress, work multiplier, and safe one-time completion event.
- [x] Add `res://tests/construction_lifecycle_test.tscn` with six focused timing and transition checks.
- [x] Execute all six construction lifecycle tests in Godot 4.6.2 (**6/6 passed**, user-confirmed).
- [x] Add isolated `ConstructionSite` prototype that reserves a footprint and replaces itself with a real Test Storage building at completion.
- [x] Add `tests/construction_site_test.tscn` for four storage-activation checks (**awaiting local Godot run**).
- [ ] Integrate construction sites with a **single simple building** before generalizing to all structures and conveyor placement variants.
- [ ] Reserve build footprints while unfinished; prevent production, port transfers, and combat until completion.
- [ ] Add construction progress UI and regression checks for placement, demolition, health, logistics and selection.
- [ ] Create the central hub and worker assistance behavior; then implement material-consuming construction.
- [ ] Add expandable defensive walls, waves and a bounded victory/lose condition for the zombie demo.

**Checkpoint status:** Standalone lifecycle committed; runtime validation and live-world integration pending. No live building placement behavior changed.

---


## Phase 0 — Foundation

**Goal:** Establish a clean and maintainable technical base.

- [x] Create Godot 4.6.2 project
- [x] Establish initial project folders
- [x] Create documentation structure
- [x] Configure Git and GitHub
- [x] Review and finalize `.gitignore`
- [x] Define naming and coding conventions
- [x] Configure essential Godot project settings
- [x] Create initial input mappings
- [x] Create basic main/test scene
- [x] Make initial Git commit

**Status: Complete**

---

## Phase 1 — Core Prototype

**Goal:** Prove the basic factory-and-defense loop in a simple test environment.

Planned major systems:

- camera and world interaction
- building placement
- resource nodes
- resource collection
- inventories
- machine production
- simple storage
- basic conveyor/logistics prototype
- basic power or machine-operation constraints
- simple zombie enemy
- enemy movement toward player structures
- basic defensive structure
- basic health and damage

### 1A — Camera & Player Interaction Foundation

- [x] Create RTS-style CameraRig
- [x] Add WASD camera movement
- [x] Add mouse-wheel zoom
- [x] Add mouse-to-world raycasting
- [x] Add selectable-object system
- [x] Add material selection highlighting
- [x] Establish interaction collision layers
- [x] Add Build Mode
- [x] Add 1-meter grid snapping
- [x] Add placement validity checks
- [x] Add green/red placement ghost
- [x] Add 90-degree placement rotation
- [x] Add rotation-aware collision footprints
- [x] Support multiple prototype building types
- [x] Add prototype Build HUD
- [x] Add `player_built` classification
- [x] Add Demolition Tool
- [x] Restrict demolition to Build Mode
- [x] Add demolition HUD state
- [x] Add demolition hover targeting
- [x] Complete interaction-system refactor
- [x] Complete regression test

**Status: Complete**

### 1B — Factory & Production Foundation

- [x] Create `BuildingDefinition` resource architecture
- [x] Create data-driven prototype building assets
- [x] Refactor Build Mode to use `BuildingDefinition`
- [x] Remove legacy direct buildable-scene collection
- [x] Add `BuildingRuntime`
- [x] Inject building definitions into placed instances
- [x] Create `ItemDefinition`
- [x] Create prototype `Test Ore`
- [x] Create reusable `ItemAmount`
- [x] Create reusable `InventoryComponent`
- [x] Verify add/check/remove inventory operations
- [x] Create `ProductionRecipe`
- [x] Create `Prototype Extraction` recipe
- [x] Create reusable `ProducerComponent`
- [x] Prevent placement ghosts from running gameplay components
- [x] Produce Test Ore automatically every 2 seconds
- [x] Verify independent inventories across multiple producers
- [x] Add Production Debug HUD
- [x] Display selected building, recipe, and live stored output
- [x] Verify non-producer and non-building debug states
- [x] Remove temporary production console spam

**Status: Complete**

> Historical note: Chat 03 validated autonomous ore generation. Chat 04 replaced the small building's free-output recipe with a source-dependent Test Extractor; the reusable producer/recipe code remains for later machines.

### 1C — Resource Nodes & Extraction Foundation (Chat 04)

- [x] Define reusable `ResourceNodeDefinition` data
- [x] Create Test Ore Deposit definition and selectable world scene
- [x] Add `ResourceNodeRuntime` and `extract(amount)`
- [x] Support and test infinite versus finite resource availability
- [x] Add reusable `ExtractorComponent` with nearby-deposit detection
- [x] Transfer extracted resources into individual building inventories
- [x] Require Test Extractor placement within resource range
- [x] Preserve normal placement for non-extractor buildings
- [x] Separate extraction detection shapes from physical placement blockers
- [x] Extend debug HUD for deposits, extraction status, and stored ore
- [x] Rename small prototype to Test Extractor
- [x] Retire the obsolete Prototype Extraction recipe asset
- [x] Complete final camera/build/selection/extraction/demolition regression tests

**Status: Complete**

### 1D — Basic Storage & Logistics (Chat 05)

- [x] Define shared item-count inventory capacity and unlimited-capacity fallback
- [x] Implement partial acceptance and capacity-aware finite-deposit extraction
- [x] Create dedicated Test Storage scene and BuildingDefinition (200 capacity)
- [x] Add Test Storage to building selection (key 3), rotation, selection, and demolition
- [x] Implement safe `InventoryComponent.transfer_to()` item movement
- [x] Validate partial transfers, full destinations, empty sources, invalid/self transfers, and conservation
- [x] Add `LogisticsTransferComponent` and nearest-eligible storage discovery within a configurable radius
- [x] Transfer Test Ore automatically on a timed interval, ignoring disabled placement ghosts
- [x] Display inventory contents/capacity, transfer status, and last successful transfer in the debug HUD
- [x] Regression-test existing camera, building, extraction, selection, and demolition systems
- [x] Complete finite-resource conservation regression: 250 deposit + 50 extractor + 200 storage = 500
- [ ] Build physical conveyors, ports, inserters, and more complex routing (follow-up milestone)
- [x] Add production recipe input availability, consumption, and outputs from actual inputs (**completed in Chat 06**)
- [ ] Explore machine-operation/power constraints (follow-up)

**Chat 05 Status: Complete — Direct proximity-based logistics working; physical conveyors remain planned.**

### 1E — Production Inputs & First Manufacturing Chain (Chat 06)

- [x] Review and preserve existing `ProductionRecipe`, `ItemAmount`, `ProducerComponent`, and `InventoryComponent` architecture
- [x] Choose independent manufacturing input/output inventories to prevent capacity conflicts
- [x] Add recipe input validation and duplicate-input aggregation
- [x] Validate total output-space requirements before manufacturing
- [x] Implement guarded, synchronous input consumption and full-cycle output creation with rollback attempt on unexpected failure
- [x] Connect safe transactions to the timed `ProducerComponent`; report waiting/blocked statuses
- [x] Create permanent `Test Ingot` and `Test Ore Smelting` resources (**2 ore → 1 ingot, 2 seconds**)
- [x] Create Test Smelter scene and BuildingDefinition (**50 input / 100 output**)
- [x] Register smelter with Build Mode as **key 4**; support selection, rotation, overlap blocking, demolition, and Build HUD highlighting
- [x] Implement `LogisticsInputComponent` to pull ore from stocked nearby Test Storage using safe transfers
- [x] Configure input logistics (**up to 5 ore per second**, range **5**, target buffer **10**)
- [x] Expose separate machine input/output quantities and capacity through the Production Debug HUD
- [x] Add shared live production and extraction activity progress bar, with stopped/blocked statuses
- [x] Correct extractor status when inventory is full or deposit depleted
- [x] Verify smelter output-full blocking, retention of ingredients, and 0% progress
- [x] Pass **36/36** Chat 06 manufacturing test assertions and re-run Chat 05 inventory transfer regression
- [x] Verify finite-500 resource conservation with deposit, extractor, storage, smelter input, and manufactured ingots
- [x] Commit and push tested Chat 06 gameplay changes to `main`
- [x] Document gameplay milestone and troubleshooting

**Chat 06 Status: Complete — First automatically supplied Test Smelter produces Test Ingots with separated inventories and live progress.**

#### Future Logistics and Manufacturing Follow-Ups

- [ ] Automate finished-ingot transfer out of the smelter and support downstream destinations
- [ ] Prototype physical conveyor/inserter/port routing beyond proximity transfers
- [ ] Add more production recipes, machine tiers, and configurable downstream processing
- [ ] Introduce power/fuel/machine-operation constraints where they improve gameplay
- [ ] Improve the prototype production debug display into a final player-facing machine interface

### 1E.1 — Recipe Selection & Input Acceptance Foundation (Chat 07, first checkpoint)

- [x] Confirm physical-belt, ammunition-first factory-defense game direction in [GAME_VISION.md](GAME_VISION.md)
- [x] Add per-machine `available_recipes` list while retaining existing active `recipe`
- [x] Implement conservative `select_recipe()` changes without deleting input/output inventory items
- [x] Add read-only `accepts_input_item()` based on the currently selected recipe
- [x] Gate temporary smelter input logistics using the producer's active-recipe acceptance decision
- [x] Update Test Smelter scene with recipe list and ProducerComponent reference
- [x] Pass **10/10** recipe-selection, **6/6** ingredient-acceptance, and **5/5** recipe-aware logistics tests
- [x] Rerun **36/36** Chat 06 manufacturing checks, existing inventory-transfer tests, and active factory gameplay
- [x] Commit and push this checkpoint's tested gameplay and isolated test scenes to `main`
- [x] Document architecture, development log, roadmap, and troubleshooting

**Checkpoint status: Complete.** This is recipe-control infrastructure, not yet a player recipe-selection UI and not yet physical material transport.

### 1E.2 — Machine Input/Output Ports & Logical Item Handoffs (Chat 07, second checkpoint)

- [x] Add reusable `ItemPortComponent extends Marker3D` with `INPUT`/`OUTPUT` roles
- [x] Define recipe-aware and universal-storage admission policies
- [x] Validate full-request free capacity and full source item availability without modifying inventory
- [x] Place and orient `InputPort` and `OutputPort` on the Test Smelter, referencing correct inventories and producer
- [x] Verify port world positions and outward directions after a 90° building rotation
- [x] Add safe manually invoked port-to-port transfers using existing `InventoryComponent.transfer_to()`
- [x] Reject invalid source/destination roles, unsupported items, same-inventory transfers and full destinations
- [x] Validate complete ore → smelter → ingot → storage handoff with blocked export and resource conservation
- [x] Pass **29/29** port checks; rerun **21/21** Chat 07 recipe checks, **36/36** Chat 06 checks, inventory tests and normal factory
- [x] Commit and push tested port scripts, scene changes and four new test scenes to `main`
- [x] Document architecture, dev log, roadmap and port-specific diagnostic expectations

**Checkpoint status: Complete — safe logical handoffs and orientable port markers, not yet an operational physical conveyor network.**

### 1E.3 — Straight Conveyors, Snapping and Build Placement (Chat 07.4)

- [x] Add world-space endpoint geometry and strict connection tolerances
- [x] Create ConveyorStraight scene with visible mesh, directional markers and footprint
- [x] Track at most one previous and one next belt; clean up reciprocal links on deletion
- [x] Implement straight snap-after, read-only snap previews, and snap-before with rotation support
- [x] Register Conveyor Belt as slot **5**, preserving the four original shortcuts
- [x] Make Build Mode ghost snap to the nearest compatible open input/output
- [x] Commit exactly one new conveyor per snapped click, or roll back on a rejected connection
- [x] Provide reliable selection/demolition and distinct Layer 2 / Layer 3 hitbox responsibilities
- [x] Pass **40/40** conveyor regression checks and verify main factory gameplay
- [x] Commit and push the tested conveyor milestone to main
- [x] Document the milestone and remaining work

**Status: Complete — connected straight conveyor geometry and placement, but no inventory transport over belts.**

### 1E.4 — Automatic Corner Conversion and Directional Conveyor Visuals (Chat 07.5, 2026-10-27)

- [x] Add tested right- and left-turn conveyor scene endpoints and world-space alignment.
- [x] Keep **one Conveyor Belt construction tool (key 5)**, with a straight placement ghost; no separate corner build-menu entries.
- [x] Convert an existing straight conveyor **in place** when a new perpendicular, correctly oriented straight is placed adjacent to its available output; retain incoming links and node identity.
- [x] Guard occupied outputs and invalid geometry; roll back unsuccessful conversions without altering the existing line.
- [x] Verify left/right conversion, rotation of connected assemblies and reciprocal-link cleanup on demolition.
- [x] Add visible steel-gray L-shaped placeholder corner meshes, widened to match straight-belt width.
- [x] Add bright directional arrows under `OutputEndpoint` for placed straight belts, converted corners, and placement ghosts.
- [x] Verify actual Build Mode turns and different travel directions, plus selection/demolition and an inspected collision overlay.
- [x] Push corner scripts, scenes and local test assets to GitHub `main`.
- [ ] Replace the committed overlapping-box corner mesh implementation with exact continuous single-surface geometry, if desired; clean up stepped seams and make physics/interaction footprints precise.
- [ ] Complete a single consolidated regression run of all prior and new test scenes, then record its aggregate result.

**Status: Core 90° construction and directional cues working.** Reported individual local passes include 8/8 corner connection, 8/8 left-corner, 6/6 corner-preview, 8/8 turn-intent, 8/8 piece-selection, 8/8 in-place conversion, 8/8 full-chain, and 8/8 visual-geometry checks, in addition to successful main-game construction and demolition. These were observed at different checkpoints; a final single-run total is **not** claimed. Closed-loop final connections and item transportation remain unimplemented/unverified.

#### Remaining Logistics Follow-Ups After Chat 07

- [ ] Verify and implement explicit closure of already placed conveyor loops, without creating an overlapping new belt; guard endpoint availability.
- [ ] Normalize `InteractionHitbox` size/slight rotation and refine corner-shaped collision/selection footprints.
- [ ] Simplify legacy corner ghost selection and remove redundant debug/reset paths when safe.
- [ ] Connect machine and storage input/output ports to conveyor endpoints.
- [ ] Prevent distant or disconnected manual port handoffs from being used by gameplay logistics.
- [x] Implement one-item, generic, connection-validated timed belt-to-belt transport and backpressure with tested conservation (Chat 08 foundation).
- [ ] Finalize throughput tuning, visible travel, machine/belt interface rates and broader end-to-end capacity behavior.
- [ ] Design universal small/medium/large slot-and-stack storage.
- [ ] Add separate placeable splitters and mergers after straight/turn routing works.
- [ ] Replace proximity logistics only after physical belts pass manufacturing regression checks.
- [ ] Build ammunition supply and supply-dependent defense for the First Night slice.

### 1E.5 — Generic Physical Conveyor Transport Foundation (Chat 08, 2026-10-27)

- [x] Add one-item `CargoInventory` and reusable `ConveyorTransportComponent` to `ConveyorStraight`.
- [x] Preserve item definitions generically; no ore-, ingot-, metal- or ammo-specific belt logic.
- [x] Require reciprocal directed segment links and aligned endpoints for belt-to-belt handoffs.
- [x] Add automatic timer, blockage preservation, and resumed transfers.
- [x] Verify right/left corner conversion retains cargo and progress.
- [x] Verify a six-segment chain carries three distinct item definitions without overtaking or loss.
- [x] Block **player-tool demolition** of occupied or invalidly configured belts.
- [x] Pass **44/44** assertions across six separately executed Godot test scenes; rerun integration and gameplay checks.
- [x] Push tested gameplay changes to GitHub `main`.
- [x] Add a generic visible box for occupied straight and in-place left/right corner belts, synchronized with travel progress.
- [ ] Add **distinct item-specific** meshes/materials/models based on `ItemDefinition` (the current box is shared).
- [x] Add Test Extractor OutputPort and reuse Test Smelter input/output ports; implement read-only port-to-belt snap transforms, reciprocal physical connections, guarded loading/unloading and automatic timer-driven transfers.
- [x] Integrate building-port snapping and connection commits into **player-facing Build Mode**; include placement obstruction checks and occupied-port previews (completed after the 08.3F foundation).
- [x] Add universal physical input/output ports to Test Storage (subsequent Chat 08 gameplay integration).
- [x] Pass isolated Extractor → three belts → Smelter → Test Ingot production route (seeded ore, manually advanced timers, without storage).
- [ ] Test full Extractor → Belt → Storage → Belt → Smelter → Belt → Storage in actual gameplay; replace proximity logistics only when safe.
- [ ] Decide a safe item recovery/drop policy for non-player belt destruction and persistence.
- [ ] Refine loop closure, speed/capacity balancing, exact corner collision shapes, and comprehensive test orchestration.

**Historical checkpoint status (08 foundation):** Belt-to-belt cargo transport validated before Build Mode integration. **Superseded:** The normal game now supports physical connections between buildings; legacy proximity components have not yet been formally retired.
### 1E.6 — Building Port Integration & Isolated Production Route (Chat 08, 2026-10-27)

- [x] Add conveyor cargo visuals for straight and left/right corners; preserve generic `ItemDefinition` behavior.
- [x] Add Extractor OutputPort and validate 90-degree building rotation.
- [x] Implement read-only building-port preview transforms and exclusive, persistent belt-to-port connections.
- [x] Enforce reciprocal links, current physical marker alignment, valid producer output ownership and recipe-controlled input acceptance.
- [x] Implement guarded loading and unloading for any valid item type, plus timer-driven building input/output handoffs and full-destination backpressure.
- [x] Pass **86/86** newer checks across ten separate Godot test scenes (total Chat 08 **130/130** across sixteen separate reported suites).
- [x] Validate isolated Extractor → three connected belts → Smelter: two seeded ore produce one ingot with correct accounting.
- [x] Commit and push this code and regression suite to `main`.
- [x] Support normal in-game placement/snap discovery and hookup from player-built belts to buildings via `WorldInteraction` (subsequent Chat 08.3F/08.3G integration).
- [x] Add Test Storage physical ports and player-built routes through Storage; final full-chain isolation from legacy proximity logic remains to be validated.
- [ ] Test deposit-fed extraction, simultaneous item traffic, steady throughput and removal of proximity transfers without breaking the original factory.

**Historical checkpoint status (08.3F-1):** The isolated seeded-ore test passed before normal Build Mode hookups existed. **Superseded by 08.3G:** Building-port links and output export work during player placement. Distinct item visuals, safe cargo recovery, and verified retirement of the parallel proximity flow remain pending.
### 1E.7 — Full Player-Built Conveyor Logistics, Unified Grid & Routing Buildings (Chat 08.3G, 2026-10-30)

- [x] Implement free-end and missing-corner preview/commit, including source/receiver existing-straight conversions.
- [x] Implement exact two-ended bridging, fractional straight connectors and perpendicular variable-leg L connectors with real collision/selection and item transport.
- [x] Normalize physical item velocity over variable connector lengths using `ConveyorPathMotion`.
- [x] Apply `FactoryGrid` origin parity and rotated port alignment to all building definitions.
- [x] Convert Merger to **1×1, 3 IN / 1 OUT**, with three independent bounded input buffers, one output buffer, round-robin fairness and per-lane counters.
- [x] Add **1×1 Splitter, 1 IN / 3 OUT**, with three independently buffered outputs, disconnected/full output skipping and conservation.
- [x] Add the build slots **6** / **7** and real-time Merger/Splitter input/output diagnostics.
- [x] Receive developer-reported passing isolated regressions for grid/merger/splitter after redesign, and live evidence of 13 Splitter transfers (**5/4/4**).
- [x] Verify that small gaps can be physically filled and their item movement appears speed-consistent in live gameplay.
- [x] Confirm live 1×1 Merger with three incoming conveyor routes and successful output-full **backpressure/recovery**. The user confirmed operation; numerical `From A/B/C` HUD counters were not separately captured and remain an optional benchmarking follow-up.
- [x] Complete final 20/20 manual Godot regression scenes (four rounds) and user-confirmed ore-to-ingot factory chain in live gameplay. **Separately verifying physical-only item conservation with legacy proximity scripts disabled/accounted for remains pending.**
- [x] Accept **core Chat 08 physical logistics milestone** and record verification evidence in the devlog/regression checklist (2026-10-30); leave robustness/migration items as follow-up work.
- [ ] Add safe cargo-recovery handling for destructive events and then retire/gate old proximity logistics after conservation tests.

**Status: Core physical logistics milestone accepted (2026-10-30): 20/20 manual regression scenes passed; Merger, Splitter, blocked-output recovery and full ore-to-ingot gameplay confirmed.** Legacy proximity retirement, measured physical-only conservation and destructive-event cargo recovery are explicitly deferred. See [CHAT_08_FINAL_REGRESSION.md](CHAT_08_FINAL_REGRESSION.md). Earlier 08.3F sections are historical checkpoints.

### 1E.8 — Physical-Only Factory and Ammunition Production (2026-10-31)

- [x] Verify finite-deposit conservation through physically connected Extractor → Storage → Smelter → Storage, without legacy proximity movement (**9/9** Godot checks).
- [x] Add `Prototype Rounds` and a reusable `1 Test Ingot → 4 Prototype Rounds` recipe (temporary prototype ratio).
- [x] Add 2×2 Prototype Ammunition Press using existing producer/input/output components, independent inventories and physical conveyor ports (**9/9** isolated checks).
- [x] Register Ammunition Press in Build Mode slot **8**, with rotation, HUD selection and safe demolition (**9/9** integration checks).
- [x] Verify live production and physical delivery of Prototype Rounds to normal Test Storage (**6 rounds visible** in the user's HUD screenshot).
- [ ] Finalize ammunition balance, ammunition-specific cargo graphics and the turret's combat behavior.

**Status: Ammunition production and physical warehouse delivery developer-verified.** The old proximity components remain in source for compatibility, but their extractor/smelter scene nodes are disabled; retain them until the migration is fully documented and broader conservation coverage is complete.

### 1F — Enemy & Defense Prototype

**Defense foundation accepted:** The 1×1 ammunition-fed turret has a physical input port, 40-round magazine, guarded firing transactions, and cooldown. Both the isolated ammo regression (**10/10**) and main-scene Build Mode slot **9** regression (**12/12**) passed locally in Godot 4.6.2. The Debug HUD displays magazine quantity, port connection, readiness, cooldown and shot count. **Live ammunition connection now accepted (2026-11-01):** A normal gameplay screenshot showed the turret's ammunition conveyor connected and its magazine holding **9 / 40 Prototype Rounds** with `Status: Ready`, `Cooldown: 0.00 s`, and `Fired Shots: 0`. Automated turret targeting and instant-hit damage are integrated and were verified with the stationary target in both Godot regression tests and live gameplay. Visible projectiles, line of sight and moving-zombie encounters remain separate improvements.

- [x] Validate turret ammunition-only input, backpressure, firing/cooldown, conservation and demolition (**10/10** isolated regression).
- [x] Validate turret Build Mode slot 9, HUD, port placement, ammo input and connection cleanup (**12/12** local Godot regression).
- [x] Confirm physical delivery of factory-produced Prototype Rounds to a player-placed turret's magazine (**9 / 40 rounds, live HUD screenshot**).
- [x] Pass isolated turret targeting, cooldown, conservation and dummy damage regression (**12/12** in local Godot 4.6.2).
- [x] Validate the main-scene turret/hostile dummy combat integration (**11/11 passed locally in Godot 4.6.2**).
- [x] Validate automatic turret fire and visible target defeat during normal player-controlled gameplay (**TARGET DEFEATED** shown in user screenshot, 2026-11-01).
- [x] Validate main-scene automatic targeting and ammunition-dependent instant-hit damage in the isolated integration test (**11/11**).
- [x] Confirm the first regular-play combat victory against the stationary target (**TARGET DEFEATED** displayed); visible projectile simulation remains a later step.
- [x] Validate isolated moving-zombie approach, structure reacquisition and turret compatibility (**9/9** in local Godot 4.6.2).
- [x] Validate moving zombie integration in the main game (**12/12 local Godot tests passed**, Nov 1, 2026). Static target remains unchanged.
- [x] Manually verify the moving zombie approaches a placed Storage building and stops beside it in the playable main world (2026-11-01 screenshot; precise stop distance previously checked by automated tests).
- [x] Manually verify a physical-ammunition-fed turret defeats the moving zombie in the playable main world (user screenshot shows two separate **TARGET DEFEATED** labels; green zombie approached the newly placed turret).
- [ ] Add navigation toward player structures
- [x] Validate non-destructive BuildingHealthComponent and zombie melee damage (**12/12 local Godot tests passed**).
- [x] Validate 100 HP across eight player-buildable structure scenes, shared durability HUD, preserved stored cargo and zero-HP targeting (**11/11 passed in local Godot 4.6.2**).
- [x] Re-run the adjusted `tests/zombie_building_melee_test.tscn` after scene changes (**12/12 passed locally**).
- [x] Validate live zombie melee in the Main scene with durable factory buildings (**12/12 local Godot integration tests passed**).
- [x] Attach ZombieMeleeComponent to the playable moving zombie using 10 HP per attack and a one-second cooldown; validated in the Main-scene integration regression (**12/12**).
- [x] Confirm in regular gameplay that a moving zombie damages an Extractor to **0 / 100 HP**, with the building still present and **19 Test Ore** visible in its inventory (manual screenshot, 2026-11-01). The earlier 12/12 integration test specifically verified Storage stock and conveyor-link preservation; that was not independently visible in this latest screenshot.
- [x] Validate **actual Main-world building destruction at zero HP** using `res://tests/live_zombie_destruction_test.tscn` (**12/12 passed locally in Godot 4.6.2 on 2026-11-02**). The fatal tenth hit removes only the building, preserves neighboring belts and spawns salvage; failed recovery leaves the 0-HP structure intact for retry.
- [x] Confirm in regular F5 gameplay that a zombie destroys a player-placed structure and leaves visible wreckage while clearing the building HUD (**2026-11-02 screenshot: green zombie beside WRECKAGE**). The screenshot does not show a resource-filled cache; material accounting was established in earlier automated regressions.
- [x] Validate **Step 09.18F1: Independent conveyor durability** across straight, right-corner and left-corner shapes (**50 HP**, one cargo slot). `res://tests/conveyor_durability_foundation_test.tscn` passed **12/12 locally in Godot 4.6.2**.
- [x] Step 09.18F2: Validate zombies selecting, attacking and destroying straight/left/right conveyor segments in Main, with salvage, protected neighboring belts and safe recovery retry. `res://tests/live_zombie_conveyor_destruction_test.tscn` **12/12 passed locally in Godot 4.6.2 on 2026-11-02**, including the corrected diagonal retargeting arrival.
- [x] Step 09.18F3: Confirm in F5 gameplay that the moving zombie destroys placed conveyor sections and leaves visible **WRECKAGE**; screenshot shows two distinct wreckage placeholders near the green zombie (2026-11-02). The screenshot does not directly show independent neighbor-belt survival or recovered cargo; those were verified in the 12/12 automated belt-destruction suite.
- [x] Step 09.18F4: Validate **conveyor HP, cargo and connection display** for intact straight/left/right belts, dynamic damage/cargo updates, and automatic selected-belt HUD cleanup at destruction (`res://tests/conveyor_health_hud_test.tscn`, **12/12 passed in local Godot 4.6.2 on 2026-11-02**).
- [x] Step 09.18F5: Confirm in regular F5 gameplay that selecting a conveyor displays its health and logistics: screenshot shows a yellow-selected belt at **40/50 HP**, Intact, 0/1 cargo, and disconnected input/output, with the moving green zombie nearby (**2026-11-02**). Selected-object clearing on destruction was previously confirmed by the 12/12 HUD regression and F5 wreckage screenshots.
- [ ] Polish the conveyor HUD's automatically generated scene name (e.g. `@Node3D@10`) into a readable belt type/label during the planned UI pass.
- [x] Final regression Round 1 — moving enemy/combat compatibility: `prototype_moving_zombie_test.tscn`, `live_moving_zombie_integration_test.tscn`, `zombie_building_melee_test.tscn`, `live_zombie_melee_integration_test.tscn`. (all four suites passed locally in Godot 4.6.2, 2026-11-02).
- [x] Final regression Round 2 — factory/logistics compatibility: `conveyor_physical_only_conservation_test.tscn` (**9/9**), `ammunition_press_build_mode_test.tscn` (**9/9**), `defensive_turret_build_mode_test.tscn` (**12/12**). **All 30/30 checks passed in local Godot 4.6.2** (confirmed 2026-11-02).
- [x] Final regression Round 3 — destructive recovery/selection: `live_zombie_destruction_test.tscn`, `controlled_destruction_transaction_test.tscn`, `world_salvage_destruction_test.tscn`, and `live_zombie_conveyor_destruction_test.tscn` (**all 4 scenes and all 48/48 checks passed locally in Godot 4.6.2, confirmed 2026-11-02**).
- [x] Validate **lossless destruction cargo recovery** for Storage, multi-inventory manufacturing and cargo-bearing belts (`tests/destruction_cargo_recovery_test.tscn`: **12/12 passed locally in Godot 4.6.2**). Current test escrow uses 100% recovery as a temporary safe default, **not** final salvage balance.
- [x] Validate **controlled source removal after escrow** using `tests/controlled_destruction_transaction_test.tscn` (**12/12 passed locally in Godot 4.6.2**). Confirmed queued deletion, stopped processing, safe reciprocal disconnection, salvage capacity refusal, and unaffected neighboring belts.
- [x] Validate **Main-world surviving salvage placeholders** through `tests/world_salvage_destruction_test.tscn` (**12/12 passed locally in Godot 4.6.2**; 15/15 source items retained in five independent world caches). These caches are runtime-only and not yet player-pickable.
- [ ] Future follow-up: implement player collection and save/load persistence for wreckage salvage, plus resource-loss balancing. Current caches remain runtime-only; the accepted destruction milestone delivers lossless in-world salvage and safe removal, not pickup/persistence.
- [ ] Decide optional repair of damaged surviving structures and rebuilding/salvage for destroyed structures; **0-HP permanent disabled state is not the intended final gameplay**.
- [ ] Add basic defensive structure
- [ ] Add player/factory survival test

**Phase 1 Status: In Progress**

---

### 1G — Unlocked Building Catalog & Player-Customizable Build Hotbar (In Progress)

**Phase entry:** Step 09.18 building/conveyor destruction has passed three final regression rounds and F5 gameplay validation. Custom hotbar work is now underway. Its model and conveyor identity migration have been accepted, with 80/80 targeted conveyor regressions passed. Live number-key routing and dynamic HUD are newly implemented and awaiting the 1G3 Godot test; catalog UI and disk persistence are still future work.

- [x] **Phase 1G1 — Stable-ID hotbar foundation:** `res://tests/build_hotbar_configuration_test.tscn` passed **12/12** locally in Godot 4.6.2 (2026-11-02). Covers defaults, Turret → key 1, Storage → key 9, swaps, empty/locked slots, JSON payloads and catalog reordering.
- [ ] Add a Build Catalog menu listing all unlocked `BuildingDefinition` entries, organized by building category; handle locked entries explicitly.
- [x] **Phase 1G3 — Configurable live number keys and dynamic Build HUD:** `WorldInteraction` resolves 1–9 through stable building IDs and the HUD displays assignments, selection, and empty slots. `res://tests/build_hotbar_keyboard_integration_test.tscn` **12/12 passed locally in Godot 4.6.2 (confirmed 2026-11-04)**: Turret → 1, Storage → 9, Conveyor Belt → 4, empty/locked slots, and legacy defaults. First regression exposed a test-only autogenerated Turret preview node-name assumption, now corrected.
- [x] **Phase 1G3 F5 gameplay acceptance:** The developer confirmed that key **1–9 highlights switch correctly** in normal F5 gameplay (2026-11-04). Actual reassignment remains available in the model/API; player-editable controls are the next Build Catalog milestone.
- [ ] **Step 09.18G — Wreckage inspection and safe cleanup:** A discovered usability gap after F5 testing: world salvage had no selection hitbox, highlight, inventory HUD or cleanup. Implemented selectable Layer-2 wreckage, contents/status display and empty-only demolition; **12-case F6 test pending** at `res://tests/wreckage_selection_cleanup_test.tscn`. Stocked caches remain protected until player salvage collection is designed and tested.
- [ ] **Phase 1G4 — Unlocked Build Catalog menu:** Provide a selectable list of unlocked buildings, assign/swap/clear slots without affecting world placement, and later persist the configuration across sessions.
- [ ] Allow players to assign, swap, remove, and rearrange items in nine initial hotbar slots. Assigned number keys select the corresponding building while Build Mode is active.
- [x] **Phase 1G2 — Stable conveyor identity:** Replaced **22 hard-coded slot-5 comparisons** in `scripts/world_interaction.gd` with `_is_conveyor_selected()` checking `BuildingDefinition.building_id == "conveyor_belt"`. The developer confirmed `res://tests/conveyor_building_identity_test.tscn` **12/12 passed locally in Godot 4.6.2 (2026-11-04)**, including both corner variants with Conveyor Belt moved from definition index 4 to index 0, and negative tests for the former slot.
- [x] **Phase 1G2 regression Round A — Port snapping and corners (37 checks):** `conveyor_building_placement_snap_test.tscn` (8/8), `conveyor_receiver_auto_snap_test.tscn` (11/11), `conveyor_source_corner_auto_snap_test.tscn` (10/10), `conveyor_terminal_building_corner_test.tscn` (8/8). **37/37 passed locally in Godot 4.6.2 (2026-11-04).**
- [x] **Phase 1G2 regression Round B — Gap and bridge connectors (43 checks):** `conveyor_missing_corner_placement_test.tscn` (9/9), `conveyor_dual_ended_bridge_test.tscn` (11/11), `conveyor_fractional_bridge_test.tscn` (12/12), `conveyor_offset_corner_bridge_test.tscn` (11/11). **43/43 checks passed locally in Godot 4.6.2 (2026-11-04)**. Phase 1G2 closes with **80/80** targeted port, corner, snap and bridge regression checks.
- [ ] Complete a focused F5 default-key compatibility check; then make remapping available through the in-game Build Catalog so custom keys can be tested manually. Dynamic Build HUD and remapped corner previews passed the isolated 1G3 regression.
- [ ] Persist slot choices by stable `BuildingDefinition.building_id` and restore them on restart; validate changes against building unlock state.
- [ ] Add Godot regression coverage for slot customization, swaps, locked building refusal, controller/keyboard input, menu focus, saves/reloads, and previously passed conveyor tests.

**Scope:** UI/input and persistence only. The catalog model is not yet wired to the playable game; keep the current fixed shortcut system in place until placement, HUD and saving are individually validated. The accepted destruction milestone remains unchanged.

---

### Phase 1G6 — Building Catalog Expansion (Checkpoint 1)

- [x] Organize unlocked Building Catalog dropdown options by `BuildingDefinition.category` without altering stable-ID assignments.
- [x] Add `tests/build_catalog_category_test.tscn` to check grouped entries, assignment swaps, and Restore Defaults.
- [x] Validate category regression in Godot 4.6.2 (**3/3 checks passed**, 2026-11-06) and confirm the categorized M-menu dropdowns during regular F5 gameplay.
- [ ] Evaluate future building expansion only after reviewing vertical-slice priorities. Splitter and Merger physical routing are already implemented.
- [ ] Keep unlock/research progression and per-save settings with future main save/load architecture.

**Status: Checkpoint 1 complete — automated and manual validation confirmed.**

---

## Phase 2 — Zombie Colony Prototype

**Goal:** Combine factory automation and defense into a playable scenario.

Planned systems:

- small abandoned settlement
- zombie spawning zones
- resource extraction
- production chain
- defensive perimeter
- day/night progression
- increasing enemy pressure
- basic player progression
- factory expansion decisions

---

## Phase 3 — First Night Vertical Slice

**Goal:** Create the first polished, showcase-ready gameplay experience.

The player should be able to:

1. Enter a hostile colony world.
2. Explore the immediate area.
3. Locate useful resources.
4. Establish a small industrial base.
5. Build a basic production chain.
6. Prepare defensive structures.
7. Survive the first major zombie attack.

This milestone should feel like a small but complete version of the larger game concept.

---

## Phase 4 — Expansion

After the First Night vertical slice is stable, evaluate:

- larger factory systems
- more complex logistics
- additional zombie types
- abandoned towns and cities
- vehicle systems
- technology progression
- larger maps
- additional planets
- different enemy factions
- advanced warfare systems
- performance optimization

---

## Current Position

Completed:

- Phase 0 foundation
- Phase 1A camera/player interaction foundation
- Phase 1B factory/production foundation
- Phase 1C resource nodes, deposit-aware extraction, and placement validation
- Phase 1D (Chat 05) capacity-aware inventories, dedicated storage, direct automatic transfers, and storage/logistics debugging
- Phase 1E (Chat 06) guarded recipe-based manufacturing, two-inventory Test Smelter, stocked-storage input logistics, progress/status feedback, and successful conservation/regression testing

**Chat 07 recipe, machine-port and straight-conveyor checkpoints completed:** Recipe controls (**21/21** checks), safe manual machine-port handoffs (**29/29**) and buildable, snapped straight conveyor links (**40/40**) have developer-reported passing regression tests, alongside earlier manufacturing (**36/36**) and inventory/gameplay tests. Tested conveyor code was pushed to main. Details: Phase 1E.1–1E.3 and [ARCHITECTURE.md](ARCHITECTURE.md).

**Chat 07.5 checkpoint:** In-place left/right corner conversion, yellow arrows, visual L-shaped placeholders and tested connection/demolition behavior remain working.

**Accepted milestone (Chat 08.3G-3K, 2026-10-30):** Player-built physical belts, corners, variable-length connectors, uniform cargo pacing, shared grid and 1×1 Merger/Splitter are implemented on GitHub `main`. **All 20 final individual manual Godot test scenes passed**. The Splitter's live HUD recorded **13 routed items (5/4/4)**, the three-input Merger worked in gameplay, and the developer confirmed downstream backpressure/recovery and the complete ore-to-ingot factory chain. Exact live Merger per-lane counters were not captured, and safe retirement of legacy proximity scripts still requires a physical-only conservation test. Details: [CHAT_08_FINAL_REGRESSION.md](CHAT_08_FINAL_REGRESSION.md).

**Current next step (2026-11-01):** The live physical ammo chain into the turret magazine is accepted (**9 / 40 rounds**). Turret ammo-only (**10/10**), Build Mode (**12/12**), and isolated targeting/damage (**12/12**) regressions have passed locally. The player-buildable turret now has the ammo-gated targeting script, and a stationary 30-HP target is in the main world at **(-6, 0, -6)**. The `tests/live_turret_combat_integration_test.tscn` regression has now passed **11/11**, confirming main-scene targeting, belt-fed ammo, hits and defeated-state UI. Player-controlled live combat is accepted: the developer's screenshot shows the stationary dummy's **TARGET DEFEATED** state next to the ammunition-fed turret and factory conveyors. Shot counters were not visible in the screenshot; those were separately verified by the **11/11** main-scene regression. The `res://tests/live_moving_zombie_integration_test.tscn` integration suite passed **12/12** locally after the isolated movement suite passed **9/9**. The developer visually confirmed the moving zombie approaching and stopping beside player-built Storage in regular gameplay. The live moving-enemy encounter is now accepted: the moving zombie approached a newly placed turret, and the user screenshot shows both the original stationary target and the moving zombie defeated. The isolated BuildingHealth/ZombieMelee suite passed **12/12**. Eight player-buildable structure scenes now carry 100 HP and the Production Debug HUD displays it. The `res://tests/building_health_integration_test.tscn` scene passed **11/11** in local Godot 4.6.2, including cargo/port preservation and shared durability HUD. The adjusted isolated melee regression passed **12/12** after universal building health was added. The Main moving-zombie scene now includes ZombieMeleeComponent with 10 damage and a 1-second cooldown; `res://tests/live_zombie_melee_integration_test.tscn` passed **12/12** locally in Godot, validating melee, health, inventory and port preservation, and target reassignment. At zero HP structures currently remain present with cargo and ports intact **only as a testing safeguard**. The confirmed final design is that structures and conveyor sections can be destroyed, with safe local disconnection, cargo resolution and appropriate wreckage. Destroying one component must not remove an entire otherwise-undamaged belt network. Live zombie melee is regression-validated. Manual F5 gameplay acceptance is complete using a Test Extractor: the moving zombie reduced it to **0 / 100 HP**, and its HUD showed **Disabled** without deleting the building. Its production status separately still read **Extracting**, so automatic operational shutdown is the next implementation goal. A separate moving zombie is now placed in Main at **(8, 0, -7)**, and the static dummy remains at **(-6, 0, -6)**. Pathfinding and collision avoidance remain unimplemented; zombie melee has passed the dedicated integration regression and awaits manual gameplay validation. Zombie movement, spawned waves, projectile visuals, building damage, cargo recovery, slotted storage and persistence remain follow-ups.


---

### Phase E3d5a — Blueprint Construction Priorities and Waiting Queue (2026-11-10)

- [x] Add High / Normal / Low priority metadata to authorized construction jobs without changing their completion time, power/material/worker requirements, or physical factory behavior.
- [x] In sandbox Blueprint Selection Mode (Q), press **H**, **N**, or **L** to assign the selected planned sites to High, Normal, or Low priority. E and Ctrl+E keep their existing authorization behavior.
- [x] Add a stable waiting queue: **High → Normal → Low**, FIFO within each priority. Construction jobs enter only if their state is genuinely QUEUED; constructed/started/cancelled sites are pruned.
- [x] Show selection priority counts, pending queue length and next queued job in the Factory Blueprints HUD.
- [x] Retain sandbox's explicit debug requirement override: it still starts test construction immediately. Priority **does not** fabricate workers, reserve materials, create power, or throttle work before the worker system exists.
- [x] **Godot F6 validation:** `res://tests/blueprint_construction_priority_e3d5a_test.tscn` — **15/15 checkpoints passed** (developer screenshot, 2026-11-10).
- [x] Manual sandbox Q → select → H/N/L priority assignment validated (developer screenshot, 2026-11-10): six selected planned Storage blueprints, priority mix **H 2 | N 2 | L 2**, waiting queue 0 as expected before authorization. Selected-only E authorization was already covered by automated regression; a separate manual post-E construction screenshot has not been supplied.
- [ ] Implement actual finite worker-drone dispatch, real availability providers, power/material checks and progression only after isolated tests. Don't enable the new queue in Main until those requirements exist.

**Status: E3d5a priority assignment accepted — 15/15 automated checks and manual six-blueprint H2/N2/L2 assignment verified. Actual finite worker dispatch remains future scope.**



### Phase E3d5b — Finite Construction Worker Slots (Foundation; 2026-11-10)

- [x] Add `BlueprintConstructionSlotScheduler` as an isolated finite-capacity scheduler with explicit slot configuration (1–16).
- [x] Order eligible authorized jobs by **High → Normal → Low**, with stable registration-order ties; allow jobs blocked by power/material availability to remain waiting without consuming slots.
- [x] Keep active jobs non-preemptive when a higher-priority job joins the queue; when readiness is lost, pause while retaining progress and release the worker slot.
- [x] Resume paused work when readiness and a slot are available; completion/cancellation releases the slot and allows the next eligible job to start.
- [x] Add `res://tests/blueprint_construction_slots_e3d5b_test.tscn` (15 checks covering capacity, priority, explicit readiness, no-preemption, pause/resume, completion/cancellation, and isolation).
- [x] **Godot F6 verification passed (15/15)** on 2026-11-10 (developer-provided output screenshot). This is an **isolated test-only service**; not instantiated in Main or the regular Factory Testing Sandbox and has no physical worker drones.
- [ ] Next: real power and delivered-material readiness providers; assign finite physical worker-drone availability only after those services have their own regressions.

**Status:** E3d5b isolated scheduler accepted — **15/15 automated checks passed**. Real readiness providers and physical drone dispatch are future milestones; existing E3d5a UI and normal gameplay are unchanged.


### Phase E3d5c1 — Read-Only Construction Readiness Probe (Staged; 2026-11-10)

- [x] Add an isolated `BlueprintConstructionReadinessProbe` that accepts only authorized live sites; unknown/malformed power reports fail closed.
- [x] Check a caller-provided, nonempty construction bill of materials against a real live `InventoryComponent`; report shortages per `ItemDefinition`, and reject invalid costs.
- [x] Keep inventory, jobs, construction progress, authorization and worker slots untouched. **Sufficient warehouse stock is NOT a material reservation** and must never be forwarded to the E3d5b scheduler as `materials_ready=true`.
- [x] Stage 15 scripted safety checks in `res://tests/blueprint_construction_readiness_e3d5c1_test.tscn`, including shared-stock double-count prevention by refusing dispatch.
- [ ] **Godot 4.6.2 F6 acceptance pending:** developer screenshot/log of all 15 checks with no parser/runtime errors.
- [ ] E3d5c2: define real per-building construction costs and implement atomic material reservation/escrow with release/recovery on cancellation, and conservation tests. A distinct real power-coverage provider must be validated before worker dispatch.
- [ ] E3d5c3: integrate the verified power provider + reservation ownership with E3d5b finite scheduler behind a sandbox-only opt-in. Do not enable this in Main or remove the sandbox debug override until regression-tested.
- [ ] Future construction management UI: clickable priority, authorize, cancel and queue buttons, retaining H/N/L and other shortcuts as optional alternatives.

**Boundary:** This checkpoint is a read-only observation utility, not a source of actionable construction readiness. Factory Testing Sandbox and Main scenes are unchanged.

### E3d5c1 — Accepted (2026-11-11)

- [x] **15/15 Godot 4.6.2 F6 tests passed** (PASS A–O), confirmed by developer screenshot for `res://tests/blueprint_construction_readiness_e3d5c1_test.tscn`. No new errors visible in Output.

### E3d5c2a — Atomic Material Escrow Foundation (Staged; F6 Pending)

- [x] Isolated one-inventory, one-site ledger: valid authorized QUEUED sites can atomically reserve positive integer construction bills, with no debit on invalid or insufficient bills.
- [x] Repeated and competing reservations cannot double-debit physical inventory. Source items are held in escrow, not only inspected.
- [x] Site cancellation or unexpected removal attempts an exact refund. If the original inventory is full/unavailable, a stable ID retains held items for alternative recovery; refund never deliberately drops items.
- [x] Only a job whose real structure has activated can commit/consume its escrow once.
- [x] New isolated `res://tests/blueprint_construction_material_escrow_e3d5c2a_test.tscn` with **16 A–P checks pending developer F6 validation**.
- [ ] E3d5c2b: definition-owned real construction bills, cost balancing and missing-data rejection.
- [ ] E3d5c3: verified power coverage and sandbox-only scheduler integration after independently tested reservation ownership.
- [ ] Clickable priority/authorize/cancel and queue UI in a later phase, retaining keyboard alternatives.

**Safety boundary:** No changes to Main, Factory Testing Sandbox, conveyor logistics, combat, live construction, or the explicit sandbox-only debug readiness override. Physical drones and save/load of escrow are not yet implemented.

### E3d5c2a — Construction Material Escrow Accepted (2026-11-11)

- [x] **Godot 4.6.2 F6: 16/16 tests A–P passed**, confirmed by developer Output screenshot from `res://tests/blueprint_construction_material_escrow_e3d5c2a_test.tscn`. No errors visible in supplied Output.

### E3d5c2b — Definition-Owned Construction Material Costs (Staged; F6 Pending)

- [x] Reuse existing `ItemAmount` data type: `BuildingDefinition.construction_materials: Array[ItemAmount]`.
- [x] Add provisional Test Ore/Test Ingot construction bills to all nine existing `data/buildings/*.tres` resources. Original construction durations and building scenes remain unchanged. These prototype numbers are not final game balance.
- [x] Add read-only `ConstructionMaterialBill.inspect()/get_costs()` for valid, nonempty, positive, unique item bills. Missing/invalid costs fail closed.
- [x] Stage `res://tests/blueprint_construction_costs_e3d5c2b_test.tscn`, **17 tests A–Q**, including escrow ownership, competing jobs, refunds, paused construction, and successful completion.
- [ ] **Local Godot 4.6.2 F6 verification pending.** Do not connect this bill resolver to live construction until accepted and power/material dispatch contracts are tested.
- [ ] Next: validated power coverage, per-site escrow-to-scheduler adapter, and Main Hub initial inventory/bootstrap. Future clickable construction controls will supplement H/N/L keyboard shortcuts.

**Isolation:** Existing WorldInteraction, Main, Factory Testing Sandbox, conveyor logistics, combat, production recipes and sandbox debug readiness override are unchanged. Construction materials are metadata in regular sandbox play; player building authorization does not yet debit them.

### E3d5c2b — Definition Construction Costs Accepted (2026-11-11)

- [x] **All 17/17 Godot 4.6.2 F6 checks passed** (A–Q), confirmed by developer Output screenshot. Nine definition-owned cost bills validate, existing build durations are retained, malformed bills fail closed, escrow refunds cannot double-spend, and construction pause/finish conserves time and materials. No errors visible in supplied Output.

### E3d5c3a — Isolated Explicit Power Network and Footprint Coverage (Staged; F6 Pending)

- [x] Stage `ConstructionPowerNetworkNode` as an opt-in, offline-by-default node for a future completed Main Hub/Power Pole. Explicit `operational`, `is_source`, and `source_online` states are controlled by the test fixture only for now, **not** by a real power provider.
- [x] Stage `ConstructionPowerCoverageNetwork`: links are explicit, range-checked graph edges, never inferred from overlapping construction coverage circles. Energized status requires an operational live source and a valid connected path; disconnected, disabled, moved or deleted relays fail closed.
- [x] A construction site is covered only when **one energized node covers all four actual rotated footprint corners**. This intentionally conservative rule avoids partial-footprint false positives; planned sites can be previewed without authorizing construction.
- [x] Stage `res://tests/construction_power_coverage_e3d5c3a_test.tscn` with **16 A–P isolated checks** for offline sources, link requirements, outage, physical relay loss, multi-relay chains, rotation, and no implicit worker/material/time grants.
- [ ] **Godot 4.6.2 F6 validation pending.** Review developer screenshot/errors before integrating power with materials and scheduling.
- [ ] Future E3d5c3b: actual completed Hub/Power Pole ownership, generator availability, and energy budget/supply-demand rules. E3d5c3c: escrow-backed scheduler integration behind a sandbox-only opt-in, tested with power loss and restoration.
- [ ] UI buttons and Main Hub drone charging remain separate future checkpoints.

**Safety boundary:** This is *topology and construction coverage only*, using synthetic fixture power states. It does not create actual electrical energy, allocate consumer demand, produce charging or authorize jobs. No edits to WorldInteraction, Main, Factory Testing Sandbox, cargo, combat, or debug construction override.

### E3d5c3a — Power Topology Accepted (2026-11-11)

- [x] **All 16/16 Godot 4.6.2 F6 checks A–P passed**, confirmed by developer Output screenshot. Verified explicit links, disconnected/disabled/moved/destroyed relays, generator outage, complete rotated footprint coverage, and no automatic worker/material/time grants. No new errors visible in Output.

### E3d5c3b1 — Completed Power Structure Ownership (Staged; F6 Pending)

- [x] Stage **isolated prototype scenes** for a *prebuilt* Main Hub generator and a player-constructible-but-not-yet-listed Power Pole relay. The pole definition includes a 6-second construction timer and 2 Test Ingot provisional cost.
- [x] Add `PrototypePowerStructure` runtime: completed physical structure health, service enable and generator enable determine its child `ConstructionPowerNetworkNode.operational` and `source_online` state. The Main Hub starts with a **12-unit nameplate generation rating**; the pole generates **zero** and must receive power via an explicit link.
- [x] Planned/queued/half-built poles have NO electrical node; `ConstructionSite` adds the actual physical relay scene only after all construction job gates and its timer complete. Damaged/depleted structures stay offline even when toggled back on.
- [x] Keep topology fail-closed when an existing power structure parent is queued for deletion; no immediate ghost electricity.
- [x] Stage `res://tests/completed_power_structures_e3d5c3b1_test.tscn` with **16 A–P scripted checks**, including construction lifecycle, generator and pole shutdown, health destruction, parent removal, explicit links and no job-readiness bypass.
- [ ] **Godot 4.6.2 F6 acceptance pending.** Also rerun E3d5c3a 16/16 when this checkpoint passes to ensure topology compatibility.
- [ ] Next: capacity-limited **real energy allocation** (generator rating vs consumer demand), outage/recovery, explicit link provenance; then opt-in escrow-backed worker scheduler integration. Starter Hub scene placement in actual gameplay remains future scope.
- [ ] Clickable priority/authorize/queue controls and drone charging remain future work.

**Isolation:** Main and Factory Testing Sandbox remain untouched; neither new scene appears on the build hotbar. The Hub's fixed rating is **not** an energy-demand allocator, and prototype operational flags must NOT be used as verified construction power readiness until allocation, ownership, and coordinator tests pass.

### E3d5c3b1 — Completed Power Structures: Dedicated F6 Passed (2026-11-11)

- [x] Developer Godot 4.6.2 screenshot confirms **all 16/16 A–P checks passed** in `res://tests/completed_power_structures_e3d5c3b1_test.tscn`.
- [x] Verified Hub source online state, physical pole activation only after construction completion, generator/service shutdown, relay health depletion, queued-for-removal protection and unchanged construction job gates.
- [ ] **Compatibility gate remains outstanding:** rerun `res://tests/construction_power_coverage_e3d5c3a_test.tscn` (16 checks) after the new owning-parent deletion guard. Do not proceed to energy demand allocation until compatibility is confirmed.

### E3d5c3b1 — Completed Power Structures: Compatibility Accepted (2026-11-11)

- [x] **Post-implementation E3d5c3a regression: 16/16 A–P PASSED** in developer Godot 4.6.2 screenshot, with no errors visible in Output.
- [x] Together with the separate E3d5c3b1 16/16 acceptance, **32/32 power topology and completed-structure checks passed** on the current implementation.

### E3d5c3b2 — Finite Construction Power Budget Prototype (Staged; F6 Pending)

- [x] Add read-only `ConstructionPowerCoverageNetwork.get_operational_component()`, traversing explicit valid power links without granting permission or assuming sources exist.
- [x] Add isolated `PrototypeConstructionPowerAllocator`: sum **online, intact, completed `PrototypePowerStructure` nameplate ratings** per connected component. Offline, destroyed, disconnected, or bare/synthetic test nodes supply **zero** available generation.
- [x] Require an authorized live `ConstructionSite`, explicit positive integer-like demand in prototype service, and full rotated footprint coverage by an energized relay. Only grant whole demands; total allocations cannot exceed that component's current rating.
- [x] Preserve active `CONSTRUCTING` jobs first (non-preemptive), then High → Normal → Low with stable FIFO ordering for waiting sites. Recompute as generator output, topology, health, and requests change. Power allocations are observations only and do **not** change `ConstructionJob`, actual inventory, escrow, worker slots, or timers.
- [x] Stage `res://tests/finite_construction_power_e3d5c3b2_test.tscn` with **18 checks A–R**, including real completed sources, bounded demand, queued priorities, active-work preference, generator outage, multiple disconnected/connected sources, link loss, fake-source rejection, cancellation, and health depletion.
- [ ] **Godot 4.6.2 F6 validation pending.** Then rerun E3d5c3a (16 checks) and E3d5c3b1 (16 checks) to validate the additive topology API.
- [ ] Next: define production demand and realistic energy accounting (fuel/consumption, charging budgets), then a fail-closed sandbox-only coordinator using **per-site escrow ownership**, verified power allocation, and E3d5b worker slots. No Main integration until all component tests and regressions pass.

**Safety:** This stage allocates prototype *nameplate budget*, NOT measured generated energy; no live supply/fuel model or persistent power reservation exists yet. The new allocator is never instantiated by Main or the Factory Testing Sandbox. No gameplay power, materials, worker service, or existing debug bypass is changed.

### E3d5c3b2 — Test-Q Harness Fix (2026-11-11; Retest Pending)

- [x] Investigate developer F6 debugger error at line 216 of `finite_construction_power_e3d5c3b2_test.gd`: an already-freed `ConstructionSite` was passed into a typed allocator method.
- [x] Replace invalid post-`free()` call with a `WeakRef` validity assertion and before/after count of allocation entries; verify surviving Normal allocation remains five power units. **Only isolated test and documentation changed**.
- [ ] Rerun `res://tests/finite_construction_power_e3d5c3b2_test.tscn` — 18 checks A–R pending. Do not mark E3d5c3b2 accepted based on the failed first run.
- [ ] After successful retest, rerun E3d5c3a and E3d5c3b1 topology/structure tests to protect the current 32/32 compatibility baseline.

### E3d5c3b2 — Finite Power Allocation Dedicated F6 Accepted (2026-11-11)

- [x] **Godot 4.6.2 F6: all 18/18 checks A–R passed**, confirmed in developer-provided Output screenshot after correcting the test-Q use-after-free. No errors visible in the supplied Output.
- [x] Verified 12-unit nameplate budget limits, all-or-nothing construction demands, active job non-preemption, priority queue preference, explicit shared-versus-independent grids, outage and destruction behavior, fake source rejection, and release of cancelled/freed site allocations.
- [ ] **Compatibility regression still required on the current code:** `res://tests/construction_power_coverage_e3d5c3a_test.tscn` (16 checks) and `res://tests/completed_power_structures_e3d5c3b1_test.tscn` (16 checks). Prior passes are not a substitute for rerunning after E3d5c3b2's topology API changes.
- [ ] Only then proceed to the next isolated checkpoint connecting verified power, actual per-site material escrow, and finite worker-slot scheduling. Do not enable the new systems in Main or remove the sandbox debug override until integrated regressions pass.

**Status:** E3d5c3b2 dedicated allocator test accepted **18/18**, but full compatibility milestone pending **32 power regression checks**. Allocation is still a prototype nameplate-demand observation, not measured energy delivery.

### E3d5c3b2 — Full Power Regression Accepted (2026-11-11)

- [x] **E3d5c3a post-change compatibility 16/16 passed**, confirmed by developer Godot 4.6.2 Output screenshot (A–P).
- [x] **E3d5c3b1 post-change compatibility 16/16 passed**, confirmed by separate developer Godot 4.6.2 Output screenshot (A–P).
- [x] With E3d5c3b2's dedicated **18/18**, all **50/50 relevant power checks** passed on the current implementation; no errors visible in either new screenshot.
- [x] E3d5c3b2 accepted as an isolated finite *nameplate-budget* allocator (not measured electrical delivery or live construction authority).

### E3d5c3c1 — Isolated Power/Materials/Workers Readiness Coordinator (Staged; F6 Pending)

- [x] Add an opt-in `BlueprintConstructionReadinessCoordinator` that composes the already-tested `ConstructionMaterialBill`, `BlueprintConstructionMaterialEscrow`, `PrototypeConstructionPowerAllocator`, and finite `BlueprintConstructionSlotScheduler`, without modifying their existing dispatch logic.
- [x] Restrict registration to freshly authorized, fully gated `QUEUED` jobs with valid building material bills and positive finite prototype power demands. Debug/bootstrap-gate bypasses cannot register.
- [x] Reconcile in a deliberate sequence: **High → Normal → Low** material reservation (existing active work protected), then request finite power **only for owned escrow bills**, then pass verified flags to the existing worker scheduler. All-or-nothing material escrow prevents double spending; jobs without materials do not occupy a power allocation.
- [x] Keep active jobs non-preemptive; outages pause and release worker slots, preserve material escrow and construction progress, and allow queued/paused jobs to resume when resources return. Completion commits escrow; cancellation refunds. No automatic timer advancing occurs in the coordinator.
- [x] Stage `res://tests/construction_readiness_coordinator_e3d5c3c1_test.tscn` with **18 A–R F6 checks** spanning scarce materials, priority ordering, worker caps, no preemption, cancellation, power outage/recovery, timed completion and material conservation.
- [ ] **Run the 18-check F6 scene and review errors/screenshots before enabling any integration in Factory Testing Sandbox.**
- [ ] After acceptance, run E3d5b finite-worker (15), E3d5c2a escrow (16), and E3d5c3b2 power allocator (18) regressions. UI buttons, save/load, starter stock and physical drones remain future phases.

**Hard safety boundary:** This coordinator is **not** instantiated in Main or the Factory Testing Sandbox and still relies on prototype generator **nameplate ratings**, not measured generation. It is an isolated integration test, not player-facing construction enforcement. Neither normal sandbox debug readiness nor logistics/combat code is changed.

### E3d5c3c1 — Integrated Readiness Coordinator Accepted (2026-11-11)

- [x] **Godot 4.6.2 F6: 18/18 A–R tests PASSED** in `res://tests/construction_readiness_coordinator_e3d5c3c1_test.tscn`, verified by developer-supplied Output screenshot. No new errors visible in Output.
- [x] Isolated test confirms complete material escrow before power requests, actual power allocation before finite workers, priority ordering, non-preemption, pause/resume, cancellation refund, completed building activation, and conservation of test items.
- [ ] **Compatibility acceptance pending:** rerun `res://tests/blueprint_construction_slots_e3d5b_test.tscn` (15 checks), `res://tests/blueprint_construction_material_escrow_e3d5c2a_test.tscn` (16 checks), and `res://tests/finite_construction_power_e3d5c3b2_test.tscn` (18 checks), for **49 regression checks**. Prior passes predate the isolated coordinator.
- [ ] Do not attach the coordinator to Factory Testing Sandbox/Main or remove the explicit sandbox debug requirement override until compatibility checks and live integration prerequisites (save/load escrow recovery, source validity, Main Hub starter inventory, actual energy/charging, construction UI and world destruction) have been resolved.

**Status:** E3d5c3c1 dedicated integration F6 is **accepted 18/18**, but post-change **49/49 compatibility regression verification remains outstanding**. Finite allocation still derives from prototype nameplate ratings, not metered real power.

### E3d5c3c1 — Construction Readiness Full Compatibility Accepted (2026-11-11)

- [x] **E3d5b bounded worker scheduler post-integration F6: 15/15 passed**, developer screenshot.
- [x] **E3d5c2a material escrow post-integration F6: 16/16 passed**, developer screenshot.
- [x] **E3d5c3b2 finite power allocation post-integration F6: 18/18 passed**, developer screenshot.
- [x] **49/49 compatibility checks passed**, plus the 18/18 dedicated E3d5c3c1 integration checks = **67/67 accepted**. No errors visible in the three compatibility screenshots.
- [x] E3d5c3c1 accepted as **isolated service integration**. Main and Factory Testing Sandbox still use existing gameplay/debug paths.

### E3d5c3c2 — One-Time Main Hub Starter Inventory (Staged; F6 Pending)

- [x] Confirmed the actual Factory Testing Sandbox still has `blueprint_sandbox_debug_requirements = true` and no physical Hub starter inventory/source registered with the coordinator. Turning that override off now would strand normal blueprint jobs.
- [x] Add a finite `InventoryComponent` (capacity 40, **initially empty**) to the existing isolated `prototype_main_hub.tscn`; neither Main nor Factory Testing Sandbox instantiates this Hub yet.
- [x] Add explicit `PrototypeMainHubStarterStock.seed_fresh_hub(hub, items)` service that accepts ONLY a live, intact, operational, actual prototype Main Hub scene with an empty finite inventory. Reject null/detached or damaged Hub, invalid/nonpositive items, duplicate logical IDs, insufficient capacity, and a previously initialized Hub.
- [x] Test-only **provisional starter loadout**: 20 Test Ingots and 8 Test Ore, created exactly once and marked on the specific Hub. Inventory transfer and material escrow handle subsequent item movement/spending, cancellation, and completion without any recurring refill or magical logistics.
- [x] Stage `res://tests/main_hub_starter_inventory_e3d5c3c2_test.tscn` with **16 A–P** checks, covering one-time semantics, failure/capacity, transfers, escrow, no-worker bypass, completion, and disabled/damaged structures.
- [ ] **Local Godot 4.6.2 F6 acceptance pending**, followed by rerun of E3d5c3b1 (16 completed-structure checks) and E3d5c3c1 (18 coordinator checks) for compatibility.
- [ ] Important unsolved before live gameplay: persist the one-time starter marker and escrow across save/load; decide which inventory physically supplies build drones and delivery; implement real supplied electrical energy, construction UI and safe opt-in switch from debug bypass.

**No Factory Testing Sandbox or Main scene/control modifications.** The starter service runs only if explicitly invoked; constructing a Hub scene alone creates no starting resources. The 20/8 item quantities are provisional prototype economy values, not final balancing.

### E3d5c3c2 — Hub Inventory Load Failure: Diagnostic Gate (2026-11-11)

- [ ] **Developer's first F6 run halted at Test B, line 49:** `assert(stock != null and stock.is_inside_tree())`; Godot debugger displayed an assertion failure. Full 16/16 acceptance is NOT established.
- [x] GitHub `prototype_main_hub.tscn` declares a direct child named `InventoryComponent` with script `inventory_component.gd` and finite capacity 40. The separate bootstrap lookup expects exactly this live, typed child.
- [x] Stage a test-only diagnostic before the failed assertion: show the loaded `scene_file_path`, each actual Hub child name/class/script/tree state, and whether the raw InventoryComponent node is typed correctly. Stop safely on failure; **do not fabricate a replacement inventory or bypass the fault**.
- [ ] Rerun `res://tests/main_hub_starter_inventory_e3d5c3c2_test.tscn` and capture **Output diagnostic lines plus both Debugger errors**; compare local Hub scene contents with GitHub if the child is absent.
- [ ] Do not mark E3d5c3c2 accepted until all 16 checks A–P pass. Power-structure/coordinator regression still pending after that.

**Scope:** only the isolated F6 fixture and documentation were changed. Main and Factory Testing Sandbox remain untouched.

### E3d5c3c2 — Main Hub Scene Parser Correction (2026-11-11; F6 Pending)

- [x] Developer confirmed local working copy and Git HEAD both declare `InventoryComponent` with capacity 40, yet fresh Godot 4.6.2 editor and F6 instance show only four Hub children and an absent raw inventory node.
- [x] Found two `#`-prefixed comments immediately before the new Hub inventory child in `prototype_main_hub.tscn`. Godot's documented text-scene comment syntax uses `;`, not `#`. Remove the unsupported lines without altering the InventoryComponent script, node name, capacity, or existing power/health components.
- [ ] Verify in the Godot scene editor that PrototypeMainHub has a fifth direct child, `InventoryComponent`, and that `res://tests/main_hub_starter_inventory_e3d5c3c2_test.tscn` passes A–P (16 checks). Cause is strongly suspected but still requires developer runtime confirmation.
- [ ] After 16/16, rerun E3d5c3b1 completed power structures (16) and E3d5c3c1 integrated readiness (18) before any live construction integration.

**No game behavior or material supply changed:** only scene-file comment formatting and checkpoint documentation were corrected.

### E3d5c3c2 — One-Time Main Hub Starter Inventory Accepted (2026-11-11)

- [x] **Godot 4.6.2 F6: all 16/16 checks A–P passed**, confirmed by developer-provided Output screenshot. No errors visible in Output.
- [x] Developer also confirmed `InventoryComponent` is present as the fifth direct child of `PrototypeMainHub` in the refreshed Godot scene editor. The TSCN comment-syntax fix preceded this recovery; do not reintroduce invalid hash comments into scene resources.
- [x] One-time 20 Test Ingots / 8 Test Ore prototype starter stock, finite capacity 40, duplicate-seeding rejection, invalid input rejection, inventory transfers, escrow holding/cancellation, and completed building consumption all passed.
- [ ] **Post-change compatibility still required:** rerun `res://tests/completed_power_structures_e3d5c3b1_test.tscn` (16) and `res://tests/construction_readiness_coordinator_e3d5c3c1_test.tscn` (18). Target **34/34 regression checks**, beyond this checkpoint's dedicated 16/16.
- [ ] Next development checkpoint only after those regressions: safely plan a sandbox-only feature gate, persisted starter inventory / escrow recovery, material delivery, and real generated energy. Keep existing sandbox debug construction override unchanged until these are verified.

**Acceptance scope:** E3d5c3c2 is accepted **in isolation**, not enabled in Main or the Factory Testing Sandbox. Do not claim live resource delivery or save/load integrity from this test.

### E3d5c3c2 — Post-Change Compatibility Accepted (2026-11-11)

- [x] **E3d5c3b1 completed power structures: 16/16 F6 passed**, developer screenshot on the updated Hub scene.
- [x] **E3d5c3c1 construction readiness coordinator: 18/18 F6 passed**, developer screenshot on the updated Hub scene.
- [x] **34/34 compatibility checks passed** after the E3d5c3c2 inventory addition and TSCN parser correction. With the starter-inventory suite's prior 16/16, the latest focused verification is **50/50 checks accepted**. No new errors visible in the submitted Output.
- [x] Accept E3d5c3c2 as an isolated Hub bootstrap and inventory-ownership checkpoint; live sandbox integration is still OFF.

### E3d5c3d1 — Read-Only Construction Requirements Inspection (Staged; F6 Pending)

- [x] Add isolated `BlueprintConstructionRequirementsInspector.inspect()` for each valid ConstructionSite: show definition-owned material costs, exact stock deficits when a live inventory is supplied, actual per-job escrow ownership, prototype bounded power allocation, limited worker assignment, priority, progress and job state.
- [x] Keep **warehouse sufficiency distinct from escrow** and **coverage distinct from power allocation**. A source outage can be observed even if the worker scheduler has not yet reconciled; inspection never mutates job state or resolves stale worker assignments.
- [x] An all-gates-observed status is explicitly `prototype_gates_observed`. `live_construction_ready` remains **false** until real energy, persistence, delivery and worker-drone services are implemented; the sandbox debug requirements override is not authoritative.
- [x] Stage `res://tests/construction_requirements_inspector_e3d5c3d1_test.tscn` with **18 A–R** automated checks for fail-closed missing providers, costs, shortages, escrow, allocated power, workers, outage, paused time and no side effects.
- [ ] **Godot 4.6.2 F6 pending.** After passing, implement a separately gated, clickable sandbox requirements panel (read-only first); do not replace existing construction controls or debug bypass.
- [ ] Longer-term: persistence, material transport to sites, real power generation/energy metering, physical worker drones, UI authorize/priority/cancel buttons, world destruction and in-game save/load.

**Scope:** The new inspector and F6 scene are isolated: no edits to Main, Factory Testing Sandbox, WorldInteraction, existing construction jobs, the escrow, power network, worker scheduler or cargo/combat.

### E3d5c3d1 — Construction Requirements Inspector Accepted (2026-11-11)

- [x] **Godot 4.6.2 F6: 18/18 checks A–R passed**, confirmed by developer Output screenshot. No errors visible in supplied Output.
- [x] Inspection distinguishes real building bills, warehouse sufficiency, actual escrow ownership, prototype power allocation, worker assignment, and independent job-state snapshots. Read-only operation cannot consume materials, alter jobs, or advance timers.
- [x] Inspector intentionally returns `live_construction_ready = false` even when prototype flags all appear available. The Factory Testing Sandbox still uses its explicit debug-gate override.

### E3d5c3d2a — Clickable Requirements Panel (Isolated UI; F6 Pending)

- [x] Add standalone `BlueprintConstructionRequirementsPanel` CanvasLayer with an actual **clickable open/close button** at the top-right, a scrollable read-only status panel, and weak references to an explicit test target or existing `blueprint_area_selected` group.
- [x] Render bill item names/counts, exact material shortages when inventory exists, separate escrow status, prototype allocation, worker assignment, state/priority/progress and **Live readiness: NOT VERIFIED**. Missing services display **UNKNOWN**, not fake availability.
- [x] UI only calls `BlueprintConstructionRequirementsInspector.inspect()`. No construction authorize, reserve, timer, scheduler dispatch, inventory changes, or power mutation. Only the isolated F6 fixture drives its test services explicitly.
- [x] Stage `res://tests/blueprint_requirements_panel_e3d5c3d2a_test.tscn` with **18 checks A–R**, including programmatic toggle, missing data, stock shortages, escrow, power, workers, generator outage, paused progress, cancellation/refunds, and selection-group fallback.
- [ ] **Godot 4.6.2 F6 acceptance pending** (18/18) AND manual game-window click test: toggle panel closed/open and inspect displayed data.
- [ ] After successful UI verification, add the panel to Factory Testing Sandbox behind a separate read-only feature flag. Keep all debug-construction gates unchanged; do not install a real coordinator or automatically seed a Hub inventory in gameplay.
- [ ] Later: interactive construction management controls for authorize/priority/cancel, after separately proving those actions cannot bypass real material/power/worker gates.

**Isolation:** No edits to `WorldInteraction`, `main.tscn`, `factory_testing_sandbox.tscn`, active HUD, construction jobs, real inventory, cargo/conveyors, or combat. This is an isolated UI-test checkpoint only.

### E3d5c3d2a — Read-Only Clickable Panel: Automated F6 Accepted (2026-11-11)

- [x] Developer's Godot 4.6.2 F6 Output screenshot confirms **18/18 checks A–R passed** in `res://tests/blueprint_requirements_panel_e3d5c3d2a_test.tscn`; no errors visible in the supplied Output.
- [x] Automated checks cover button press signals, initial and missing service states, exact material shortages, real escrow versus free inventory, prototype power/worker status, outages, stale worker reporting, job progress, refunds, and blueprint selection group fallback, without the UI changing gameplay.
- [ ] **Manual game-window visual and mouse-click acceptance remains pending.** Open the running F6 window, visually confirm the top-right Construction Requirements button and readable panel contents, click Close and reopen using the mouse, and provide a screenshot or confirmation.
- [ ] Only after manual acceptance, stage E3d5c3d2b: separately gated, read-only panel in Factory Testing Sandbox. Preserve `blueprint_sandbox_debug_requirements = true`, existing controls, cargo conservation, factory, and combat behavior.

**Status:** E3d5c3d2a **automated tests accepted 18/18**, but the complete UI milestone is NOT yet accepted because human-visible interaction remains unverified.

### E3d5c3d2a — Requirements Panel Visual Check Accepted (2026-11-11)

- [x] Developer-provided two running-window screenshots show the top-right **Close Construction Requirements** button and readable scrollable panel: Test Storage material bill, priority, progress, stock vs reservation, prototype power/workers, and `Live readiness: NOT VERIFIED`.
- [x] Automated A–R passed 18/18 previously. The GUI layout/visual milestone is accepted.
- [ ] Both screenshots show the **open** panel. Actual physical close/reopen mouse clicks have not yet been independently confirmed, although scripted press-signal checks passed.

### E3d5c3d2b — Sandbox UI Feature Gate (Staged; F6 Pending)

- [x] Add `SandboxConstructionRequirementsFeatureGate` Node, with exported `enable_read_only_requirements_panel = false` as the **default**.
- [x] Place one disabled feature-gate node in `scenes/core/factory_testing_sandbox.tscn`. When explicitly enabled, it creates only `BlueprintConstructionRequirementsPanel` and follows `blueprint_area_selected`; no inventory/escrow/power/scheduler provider is invented.
- [x] Stage `res://tests/blueprint_requirements_sandbox_e3d5c3d2b_test.tscn`, **16 checks A–P**: instantiate the real sandbox scene, opt in only the F6 fixture instance, verify selection, button toggles, material bill, UNKNOWN providers, no unauthorized job progress, and preservation of the sandbox debug override and HUD.
- [ ] **Godot 4.6.2 F6 16/16 pending** plus a manual running-window click-close/reopen check and a sandbox plan/area-selection interaction.
- [ ] Only after successful F6/manual acceptance consider enabling the panel by default in Factory Testing Sandbox. Main, WorldInteraction, cargo, combat, scheduling, save/load, and real construction authority are out of scope.

**Safety:** `blueprint_sandbox_debug_requirements = true` remains untouched. The panel is visual-only, displays `Live readiness: NOT VERIFIED`, and has no real source inventory until a separate provider is implemented.

### E3d5c3d2b — Sandbox UI Gate Automated F6 Passed (2026-11-11)

- [x] Developer Godot 4.6.2 Output screenshot confirms **all 16/16 A–P checks passed** in `res://tests/blueprint_requirements_sandbox_e3d5c3d2b_test.tscn`; no errors visible in the supplied Output.
- [x] Verified disabled-by-default gate in the committed Factory Testing Sandbox, opt-in UI for the test instance, existing blueprint/priority/debug flags, single read-only panel, selection tracking, bill/priority/progress labels, UNKNOWN providers, and no UI-driven authorization or timer advancement.
- [x] Existing Factory Testing Sandbox HUD, blueprint route tool and `blueprint_sandbox_debug_requirements = true` remain unchanged in the isolated fixture.
- [ ] **Manual in-game window acceptance pending:** physically click the top-right button to close/reopen, confirm readability/visibility in the actual sandbox environment and that ordinary blueprint selection continues working. The Output's MANUAL lines are instructions, not proof of clicks.
- [ ] Keep the feature flag **off by default** until manual verification. Do not connect real construction materials/power/workers or change Main gameplay.

**E3d5c3d2b status:** 16/16 automated checks accepted; full UI integration acceptance remains contingent on manual evidence.

### E3d5c3d2b — Running Sandbox Visual Review (2026-11-11)

- [x] Developer screenshot shows the real Factory Testing Sandbox with the opt-in Construction Requirements panel, Test Storage bill (3 Test Ingots), High priority, queued progress, UNKNOWN stock/escrow/power/workers, and the Factory Blueprints HUD.
- [!] Visual issue identified: the requirements button/panel **overlaps the existing Production Debug HUD in the top-right**; do not enable the panel by default until layout regression and real mouse interactions pass.
- [ ] Screenshot shows the panel open; physical mouse close/reopen is not yet independently confirmed. Automated E3d5c3d2b remains accepted 16/16.

### E3d5c3d2c — Adaptive Sandbox HUD Dock (Staged; F6 Pending)

- [x] Add `BlueprintConstructionRequirementsPanel.dock_after_production_debug()` to place the toggle button and scrollable panel **below actual ProductionDebugHUD/InfoPanel geometry** rather than hiding the existing debug text and progress bar.
- [x] Update only the opt-in `SandboxConstructionRequirementsFeatureGate` to update placement dynamically as the Production Debug HUD expands or contracts. If insufficient right-side vertical space, dock below the upper-left Factory Blueprints summary instead.
- [x] Keep `enable_read_only_requirements_panel = false` and `blueprint_sandbox_debug_requirements = true` unchanged in the committed Factory Testing Sandbox. No WorldInteraction, inventory, escrow, workers, power service, logistics, combat, or UI authorization code is modified.
- [x] Stage `res://tests/blueprint_requirements_hud_dock_e3d5c3d2c_test.tscn` with **10 A–J** isolated F6 checks: no HUD overlap, button/panel within viewport, real bill data, UNKNOWN services, tall-debug fallback, toggles, and zero construction side effects.
- [ ] **Godot 4.6.2 F6 10/10 pending**, then manual screenshot showing both HUDs simultaneously and confirmation that actual mouse clicks close/reopen the panel.
- [ ] After layout acceptance, rerun E3d5c3d2b (16) plus E3d5c3d2a (18) before considering default-on sandbox UI.

**Do not claim the live sandbox requirements gate is enabled or real construction readiness is verified.** This is a visual, read-only compatibility checkpoint.

### E3d5c3d2c — Adaptive HUD Dock Automated and Visual Verification (2026-11-11)

- [x] **Godot 4.6.2 F6 10/10 A–J passed** in `res://tests/blueprint_requirements_hud_dock_e3d5c3d2c_test.tscn`, confirmed by developer Output screenshot with no visible test failures.
- [x] Developer's running Factory Testing Sandbox screenshot confirms **Production Debug** unobstructed at upper-right, **Construction Requirements** immediately beneath it, and **Factory Blueprints** unobstructed at upper-left. The selected planned Test Storage, three-Test-Ingot bill, Normal priority, zero progress, and UNKNOWN disconnected services display correctly.
- [x] Visual overlap defect addressed in the isolated opt-in sandbox view; no construction, cargo, worker, power or combat behavior was changed.
- [ ] Actual physical close/reopen **mouse clicks are not independently confirmed** by the two screenshots, although F6 PASS I verifies programmed button-signal toggling.
- [ ] Before turning the requirements feature gate on by default, **rerun E3d5c3d2a (18 checks) and E3d5c3d2b (16 checks)** under the current HUD-docking code; confirm normal-area selection in the sandbox window and actual clickable open/close behavior.
- [ ] Do not mistake UNKNOWN services or sandbox debug bypass for real construction readiness. Keep the sandbox feature gate default OFF until this final UI acceptance.

**Checkpoint state:** E3d5c3d2c automated 10/10 and visual nonoverlap accepted; 34 earlier UI regression checks and real mouse-toggle confirmation pending.

### E3d5c3d2b — Post-HUD-Docking UI Regression Accepted (2026-11-11)

- [x] Developer screenshots (two Output views) confirm **E3d5c3d2b all 16/16 checks A–P passed** in Godot 4.6.2 after E3d5c3d2c docking changes.
- [x] Current sandbox visual screenshots show Production Debug above Construction Requirements and Factory Blueprints clear at left. Test fixture reports sandbox still default-off, with original build/debug controls preserved.
- [x] The extra `Hit nothing` Output is the existing WorldInteraction empty-selection raycast log, not a failing assertion. The screenshots do not identify the particular click that caused the log.
- [ ] **E3d5c3d2a standalone panel 18/18 current-code regression still pending.** The provided new Output screenshots show E3d5c3d2b again, not the standalone suite.
- [ ] Physical close/reopen button mouse-interaction confirmation remains pending; open-panel screenshots and automated pressed-signal checks do not alone demonstrate it.
- [ ] Maintain the sandbox requirements feature gate disabled by default until both final checks pass. No live materials, power or workers should be inferred from read-only displays.

**Current UI verification:** E3d5c3d2c 10/10 and updated E3d5c3d2b 16/16 = **26 current-code checks passed**; E3d5c3d2a 18 more required for 44/44.

### E3d5c3d2a/b/c — All Post-Docking Automated UI Regressions Accepted (2026-11-11)

- [x] **E3d5c3d2a standalone panel rerun: 18/18 A–R PASSED** in developer Godot 4.6.2 Output screenshot after the adaptive docking change, with no visible test failures.
- [x] **E3d5c3d2b sandbox UI rerun: 16/16** accepted previously on the current code.
- [x] **E3d5c3d2c adaptive HUD docking: 10/10** accepted previously on the current code.
- [x] **44/44 current-code automated UI checks PASSED**, covering read-only inspection, selection fallback, visual-safe HUD positioning and the sandbox opt-in gate.
- [x] Developer's new standalone screenshot shows legible Test Storage details (3 Test Ingots, warehouse sufficient but not reserved, prototype power/worker waiting and live readiness NOT VERIFIED).
- [ ] **Physical mouse-click close/reopen confirmation remains outstanding.** The screenshots show the panel open and automated pressed signals, but not the real button's closed/reopened states in sequence.
- [ ] Keep `enable_read_only_requirements_panel = false` in Factory Testing Sandbox until user confirms real mouse interaction. Do not enable production resource/power/worker readiness or remove `blueprint_sandbox_debug_requirements = true`.

**Next controlled checkpoint after mouse acceptance:** enable the read-only panel by default ONLY in Factory Testing Sandbox, retain its ability to be closed, and test it in a regular F6 sandbox launch plus one controlled selection/conveyor/combat smoke test. Main and live construction authority remain unchanged.

### E3d5c3d2a/b/c — Manual Close Verified; UI Regression Matrix Complete (2026-11-11)

- [x] Developer-supplied screenshot of the standalone F6 window shows the **closed** Construction Requirements panel and the **Construction Requirements** button. This confirms a physical UI close action was successful, complementing previous open-panel screenshots and automated toggle assertions.
- [x] All current-code E3d5c3d2a/b/c UI suites **44/44 automated checks passed**, and the sandbox HUD-overlap fix passed visual inspection.
- [ ] Physical open-after-close mouse operation has not been explicitly confirmed; test it in the next default-on sandbox smoke run.

### E3d5c3d2d — Requirements Button Enabled for Regular Factory Testing (Staged; F6 Pending)

- [x] Change only the **Factory Testing Sandbox scene** `ConstructionRequirementsFeatureGate.enable_read_only_requirements_panel` from false to **true**. The component class's default remains false for all other scenes. The panel is still **initially closed** and opens only when clicked.
- [x] Retain Production Debug adaptive docking and blueprint selection observation; do not connect nonexistent power/stock/escrow/worker services, and always display UNKNOWN and `Live readiness: NOT VERIFIED`.
- [x] Update E3d5c3d2b (16-check) and E3d5c3d2c (10-check) test fixtures to reflect the intentional scene-default change, preserving their original safety, behavior and HUD assertions.
- [x] Stage `res://tests/sandbox_requirements_default_on_e3d5c3d2d_test.tscn` with **12 A–L** checks: generic gate off vs sandbox scene on; single closed UI; HUD coexistence; toggle states; selected blueprint material bill; UNKNOWN providers; no construction authorization/time changes; unchanged keyboard debug controls; and no new UI in Main.
- [ ] **Godot 4.6.2 F6 12/12 pending**, followed by E3d5c3d2b 16/16 and E3d5c3d2c 10/10 compatibility reruns under the new scene default.
- [ ] Manually run `res://scenes/core/factory_testing_sandbox.tscn` with F6: confirm button shown while panel CLOSED, click open / close / reopen, and check normal blueprint selection, conveyor placement and debug HUD without interference.
- [ ] Next: a separate scoped design/test for clickable selected-blueprint priorities and authorization, forwarding to existing validated commands without bypassing materials/power/worker gates.

**Safe boundary:** `main.tscn`, `WorldInteraction`, gameplay scheduling, power allocation, inventory/escrow, logistics, and combat remain unchanged; `blueprint_sandbox_debug_requirements = true` stays enabled in the Factory Testing Sandbox for prototype testing.

### E3d5c3d2d — Default-On Sandbox UI Dedicated F6 Accepted (2026-11-11)

- [x] Developer Godot 4.6.2 screenshot confirms `ALL 12 E3D5C3D2D DEFAULT-ON SANDBOX REQUIREMENTS TESTS PASSED` (PASS A–L); no failed assertions visible.
- [x] Running-window screenshot shows Factory Blueprints, Production Debug and the read-only Construction Requirements panel coexisting without overlap; selected High-priority Test Storage appears with Test Ingot x3 and UNKNOWN unconnected services.
- [x] Confirmed committed Factory Testing Sandbox enables the requirements **button** by default and leaves the debug construction override intact. The panel starts closed and does not grant real power, materials or workers.
- [ ] Current-code post-enable regressions still pending: `res://tests/blueprint_requirements_sandbox_e3d5c3d2b_test.tscn` (16) and `res://tests/blueprint_requirements_hud_dock_e3d5c3d2c_test.tscn` (10).
- [ ] Manual regular sandbox F6 smoke: physically open, close and reopen the button; select/deselect blueprints; test a small conveyor route and existing HUD/placement without errors. This is separate from programmatic button signal checks.
- [ ] Only after these checks accept E3d5c3d2d in full. Next: isolated clickable priority controls using existing validated blueprint commands, with no construction-readiness bypass.

**Status:** Dedicated 12/12 accepted; **26 compatibility checks and manual F6 smoke remain**. Production Main, gameplay power, material escrow, worker scheduling, conveyors and combat are unchanged.

### E3d5c3d2d — Post-Enable Sandbox UI Regression Passed 16/16 (2026-11-11)

- [x] Developer submitted four screenshots showing the updated E3d5c3d2b Factory Sandbox Requirements UI test passing **all 16/16 A–P** checks after the default-on change, with no failing assertions visible.
- [x] Paired running-window screenshots show Production Debug, Factory Blueprints and Construction Requirements without visible overlap. The read-only panel displays queued High-priority Test Storage with 3 Test Ingots and UNKNOWN stock/escrow/power/workers.
- [x] Together with previously accepted E3d5c3d2d dedicated **12/12**, the current default-on checkpoint has **28/38 verified checks**.
- [ ] Run `res://tests/blueprint_requirements_hud_dock_e3d5c3d2c_test.tscn` in Godot F6 and verify **10/10 A–J** on default-on sandbox.
- [ ] Perform manual physical mouse OPEN/CLOSE/REOPEN in regular `res://scenes/core/factory_testing_sandbox.tscn`; verify normal blueprint selection and conveyor placement still work. Open-panel screenshots do not independently verify the entire toggle sequence.
- [ ] Retain real-readiness UNKNOWN/NOT VERIFIED disclosures and sandbox debug-gate bypass; physical drones, real power and resource delivery are still separate work.

**E3d5c3d2d status:** dedicated suite 12/12 + sandbox regression 16/16 passed, final HUD dock 10 and manual smoke pending. This evidence update makes no gameplay changes.

### E3d5c3d2d — Full Automated Default-On UI Matrix Accepted (2026-11-11)

- [x] Developer Godot 4.6.2 F6 screenshot confirms **E3d5c3d2c Adaptive HUD Dock 10/10 A–J PASSED** after default-on enablement, with no errors visible in the Output.
- [x] Previously accepted E3d5c3d2d dedicated **12/12** and updated E3d5c3d2b sandbox **16/16** plus E3d5c3d2c **10/10** = **38/38 current-code automated checks**.
- [x] Production Debug HUD, Factory Blueprints, and Construction Requirements coexist without layout overlap in the provided visual tests. Read-only UNKNOWN services and `Live readiness: NOT VERIFIED` remain truthful.
- [ ] **Final manual regular-sandbox smoke remains:** run `res://scenes/core/factory_testing_sandbox.tscn` using F6 (not just an automated test scene); physically click Construction Requirements OPEN → CLOSED → OPEN; create, select, deselect a blueprint; place a short straight/corner conveyor route; ensure existing HUD, selection, deletion and debug behavior still work.
- [ ] After the manual gameplay smoke, accept E3d5c3d2d completely and start **E3d5c3e1 — Clickable Construction Priorities**, beginning with a safe isolated test layer and forwarding to existing validated priority/selection commands only. Keep H/N/L alternatives.

**Scope:** All **38/38 automated checks accepted**; regular sandbox manual gameplay smoke still pending. This is evidence only, with no live construction-services integration.

### E3d5c3d2d — Manual Sandbox Click-Selection Gap Found (2026-11-11)

- [x] Developer supplied normal Factory Testing Sandbox screenshots showing Construction Requirements physically **closed**, then **opened**, and a placed Storage / conveyor blueprint.
- [!] **Manual smoke NOT ACCEPTED:** user reports that they cannot click the placed blueprint to select/inspect it. Factory Blueprints continues showing `Selected: 0` with the read-only requirements panel showing no selected site.
- [x] Code review identifies the cause: WorldInteraction uses Q+DRAG to create `blueprint_area_selected` membership. Ordinary left-click in Blueprint Mode instead enters placement; ConstructionSite is not in normal selectable-object group, and the requirements panel only observes existing group membership. It was not a confirmed power, worker, or inventory issue.
- [ ] Accept E3d5c3d2d completely only after a new click-inspection smoke and basic conveyor/blueprint placement confirmation. Previous **38/38 automated UI checks remain accepted** but do not establish direct mouse inspection.

### E3d5c3d2e — Direct Blueprint Click Inspection (Staged; F6 Pending)

- [x] Add sandbox-only `enable_blueprint_click_inspection = true` while leaving this opt-in false in WorldInteraction default and the production Main scene.
- [x] In the ordinary left-click path (before Blueprint Mode attempts another placement), detect an existing managed ConstructionSite by its existing layer-2 reserved-footprint ray hitbox. Only when a read-only listener exists, emit `blueprint_inspection_requested(site)` and consume that click instead of placing another object. Empty-ground placement and Shift-route clicks continue through established paths; Q-area drag still owns input independently.
- [x] Connect the existing requirements feature gate to the new inspection signal; clicking a blueprint sets the panel's informational target and opens it, **without** changing `blueprint_area_selected`, job priority, authorization, reservations, power, workers or timers.
- [x] When entering Q selection mode, clear the pinned inspection target so the existing `blueprint_area_selected` group can drive the read-only panel again.
- [x] Stage `res://tests/blueprint_click_inspection_e3d5c3d2e_test.tscn`, **16 checks A–P**, including actual layer-2 physics hit testing, direct input handling, valid/invalid site guards, Q selection, priority independence, UNKNOWN providers, and Main unchanged.
- [ ] **Godot 4.6.2 F6 pending**. Then manually click an existing Storage or conveyor blueprint in the normal Factory Testing Sandbox while in Blueprint Mode. Confirm the requirements panel opens for that blueprint, Q+drag selection and placement still work, and no duplicate site is created.
- [ ] After passing, rerun E3d5c3d2d default-on 12, E3d5c3d2b sandbox 16, E3d5c3d2c dock 10 and E3d4a/b area-selection regressions before further UI work.

**Safety:** This is only inspection input and presentation. Main, production power/material/worker requirements, conveyor cargo logistics and combat remain unchanged. Sandbox debug construction override remains enabled for testing.

### E3d5c3d2e — Direct Blueprint Click Inspection Automated F6 Accepted (2026-11-11)

- [x] Developer's Godot 4.6.2 Output screenshot reports **ALL 16 E3D5C3D2E DIRECT BLUEPRINT CLICK INSPECTION TESTS PASSED**, checks A–P, with no visible assertion failure.
- [x] Actual site collision raycast, direct-click inspection dispatch, second-click reopening, invalid-site guards, preservation of Q-area selection and priority commands, and Main opt-out all passed in the isolated fixture.
- [x] Accompanying F6 game-window screenshot shows Construction Requirements displaying a planned Test Storage (3 Test Ingots, Normal priority, 0% progress, stock/power/workers UNKNOWN), while Factory Blueprints reports **Selected: 0**. This difference is intentional: inspection is not Q-batch selection.
- [ ] **Manual regular-sandbox validation remains:** F6 `res://scenes/core/factory_testing_sandbox.tscn`; place Storage in Blueprint Mode, left-click its existing footprint and confirm panel opens without placing a duplicate; then Q+drag a planned Storage to confirm the green highlight, selection count and read-only requirements update; verify a short conveyor placement/turn.
- [ ] Post-change targeted regressions: E3d5c3d2d default-on UI (12), E3d5c3d2b sandbox UI (16), E3d5c3d2c HUD docking (10), E3d4a area selection (10), and E3d4b advanced area selection (13). Run them in small batches after manual inspection confirmation.
- [ ] E3d5c3d2d complete gameplay acceptance and E3d5c3e1 clickable priority buttons remain gated on normal sandbox input verification.
- [!] `Footprint blocked or preview invalid` and `Hit nothing` appeared after test completion. They are non-fatal debug diagnostics, but investigate if reproducible on intended valid placements.

**E3d5c3d2e status: 16/16 isolated automated tests accepted; live sandbox physical interaction and post-change regressions pending.** Real construction readiness remains unverified.

### E3d5c3d2d/e — Normal Sandbox Blueprint Interaction Accepted (2026-11-11)

- [x] Developer provided five screenshots from regular Godot 4.6.2 Factory Testing Sandbox: clicked Storage inspection appears in Construction Requirements while `Selected: 0` remains correct for the separate Q-area selection workflow.
- [x] Q+Drag successfully selects one Storage blueprint (green outline, `Selected: 1`, Test Storage bill and Normal priority shown).
- [x] Conveyor blueprint inspection reports `Conveyor Belt` with **1 Test Ingot**; a multi-turn conveyor loop with correct directional arrows and corners is visible.
- [x] Area selection of **22 planned blueprints** shows priority distribution **7 High / 7 Normal / 8 Low**, confirming multi-selection and existing priority controls remain usable.
- [x] Requirements panel open/close and the existing Factory Blueprints / Production Debug HUDs have been visually verified across regular sandbox tests; construction readiness remains explicitly `NOT VERIFIED`.
- [x] **E3d5c3d2d default-on read-only UI** and **E3d5c3d2e direct click inspection** accepted for manual sandbox functionality, alongside their previously accepted **38/38** and **16/16** dedicated automated checks.
- [ ] Post-E3d5c3d2e regression batch remains: E3d4a Q-area selection, E3d4b Shift/Alt area selection, and updated E3d5c3d2b/c/d UI compatibility. These must pass before the next live UI integration or gameplay construction changes.

### E3d5c3e1a — Clickable Construction Priority Request Buttons (Isolated; F6 Pending)

- [x] Add standalone `BlueprintConstructionPriorityButtons` component (HBoxContainer) with physically clickable High, Normal, Low controls and `priority_requested(priority)` signal.
- [x] Fail-closed default: disabled unless an external caller explicitly sets selection availability, reject invalid priorities, mouse interactions stop at the UI, and absolutely **no ConstructionJob, priority queue, resource, power, scheduler or blueprint mutation** occurs within the component.
- [x] Stage `res://tests/construction_priority_buttons_e3d5c3e1a_test.tscn` with **12 A–L** tests: labels/order, disabled state, signal requests, invalid IDs, non-mutation of a planned job, and a standalone game-window manual click check.
- [ ] **Godot 4.6.2 F6 acceptance pending** (12/12) and actual mouse High/Normal/Low click visibility. This initial module is NOT inserted into Factory Testing Sandbox or Main.
- [ ] E3d5c3e1b (later): connect signals to existing `WorldInteraction._set_selected_blueprint_priority()` via a guarded sandbox adapter only when Q-area selection has eligible planned blueprints; preserve H/N/L keyboard shortcuts and the direct-click inspection distinction.
- [ ] Authorization buttons, worker drones, physical power delivery and resource logistics remain separate later checkpoints.

**Checkpoint isolation:** The only new code here is an independently testable priority-button view and its F6 test. No existing gameplay or sandbox UI scene is edited.

### E3d5c3e1b — Compact L/N/H Stack Beside Build Hotbar (Staged; F6 Pending)

- [x] User chose **small vertical priority buttons marked L / N / H**, beside the **left edge of the existing nine-slot build hotbar**, instead of three wide horizontal High/Normal/Low buttons. Requested top-to-bottom order: L, N, H.
- [x] Refactor `BlueprintConstructionPriorityButtons` into a narrow **48×30 px per-button VBox** with 2 px gaps and Low/Normal/High tooltips. Retain its existing `priority_requested` signal and fail-closed disabled behavior.
- [x] Add **sandbox-only** `SandboxConstructionPriorityDock` CanvasLayer that follows `BuildHUD/VisualHotbar` screen geometry (8 px to the left, vertically centered), stays hidden outside Blueprint Mode, and enables buttons only while Q-area mode contains at least one eligible selected PLANNED job.
- [x] Clicking L/N/H calls existing guarded `WorldInteraction._set_selected_blueprint_priority()`; the dock does not call `ConstructionJob.set_priority`, authorize jobs, alter resource escrow, power allocation, worker slots or timers. Single-click inspection remains independent; H/N/L keyboard alternatives remain.
- [x] Opt in only `scenes/core/factory_testing_sandbox.tscn` to the new dock; Main and shared BuildHUD scene unchanged. Existing `blueprint_sandbox_debug_requirements = true` and all construction logistics remain unchanged.
- [x] Update the still-pending isolated E3d5c3e1a test assertions for compact labels and dimensions while retaining its original **12 A–L** checks.
- [x] Stage `res://tests/sandbox_vertical_priority_dock_e3d5c3e1b_test.tscn` with **16 A–P** checks for disabled behavior, vertical order, left-of-hotbar positioning, Q selection, Low/Normal/High requests through existing controller, unselected blueprint preservation, keyboard compatibility, and non-authorizing safety.
- [ ] **Godot 4.6.2 F6 pending:** E3d5c3e1b 16/16 and updated standalone E3d5c3e1a 12/12. Then manually F6 Factory Testing Sandbox: Blueprint Mode → Q+drag blueprints → click L, N, H stack beside hotbar → verify HUD priority counts; verify button disabled on Q exit and single-click inspection unchanged.
- [ ] Earlier post-inspection regressions E3d4a/b blueprint selection and E3d5c3d2b/c/d UI remain for a follow-up targeted batch before further gameplay construction integration.

**This is still sandbox prototype UI**: no genuine materials/power/worker providers have been attached; `Live readiness: NOT VERIFIED` continues to apply.

**2026-11-11 E3d5c3e1b test follow-up (F6 retest pending):** Test M initially failed because the synthetic H key event set `keycode` but not `physical_keycode` (the property read by `WorldInteraction`). The isolated test fixture now supplies both and cycles H → N → L → H, checking the unselected plan is unchanged. Gameplay input handling and the L/N/H dock were not modified. Re-pull `main` and rerun the 16-check F6 fixture, then the separate 12-check button fixture and manual mouse tests. Preserve construction readiness/worker/power safety gating.

**2026-11-11 developer F6 evidence:** [x] E3d5c3e1b vertical priority dock **16/16 checks PASSED** after physical-key fixture correction. [x] Visual alignment beside hotbar confirmed, with zero-selection disable behavior visible in regular sandbox. [ ] E3d5c3e1a standalone 12-check F6 suite. [ ] Manual Q+drag select blueprint(s) and click L/N/H; verify selected priority counters update, unselected remain unchanged, and disable on Q exit. [ ] Earlier E3d4a/b and E3d5c3d2b/c/d regression suites. These follow-up notes supersede the earlier pending status for the 16-check dock test only.

**2026-11-11 manual acceptance:** [x] Developer reports compact L/N/H click checks passed during normal sandbox gameplay. Output demonstrates High/Normal/Low selected-site priority changes, Q toggle/off/re-entry, and 2 selected green-highlighted planned blueprints with H0/N1/L1. [x] Zero progress and independent read-only requirements preserved. [ ] Separate 12/12 E3d5c3e1a isolated fixture remains unverified in evidence. [ ] E3d4a/b selection and E3d5c3d2b/c/d requirements UI targeted regression suites. No change to Main or to actual readiness material/power/worker providers.

### 2026-11-11 — E3d5c3e1b + Dependent UI Regression Acceptance

- [x] E3d5c3e1b vertical L/N/H sandbox dock: **16/16** automated F6, prior screenshots; actual layout and manual selected-blueprint priority interactions accepted.
- [x] E3d5c3e1a isolated L/N/H request-only buttons: **12/12** F6, newly submitted screenshot.
- [x] E3d4a basic Q area-selection: **10/10** F6.
- [x] E3d4b advanced Shift/Alt area-selection: **13/13** F6.
- [x] E3d5c3d2b sandbox requirements read-only UI: **16/16** F6.
- [x] E3d5c3d2c adaptive requirements HUD dock: **10/10** F6.
- [x] E3d5c3d2d default-on sandbox requirements panel: **12/12** F6.
- **Acceptance totals: 73/73 new regression checks and 89/89 including the prior dock suite.** All previously listed pending UI/selection regression suites are now evidenced. This dated acceptance supersedes earlier checklist items marked F6 pending.
- [ ] Next milestone: separately stage the intentional blueprint authorization UI/workflow without conflating priority with permission to build. Existing E and Ctrl+E paths should remain intact. **No production dispatch or live readiness claim** until material escrow, delivered power, finite workers, resource recovery and save/load paths are integrated and validated.

### E3d5c4a — Explicit Sandbox Blueprint Authorization Dock (Staged; F6 Pending)

- [x] Keep the validated Q+drag, L/N/H, E = selected, Ctrl+E = all and single-click inspection boundaries. **Changing priority never authorizes work.**
- [x] Introduce a signal-only `BlueprintConstructionAuthorizationButtons` view with distinct **Authorize Selected** and **Authorize All** actions, stop-filtered mouse clicks, live candidate counts and disabled defaults.
- [x] Introduce an opt-in `SandboxConstructionAuthorizationDock` above the existing nine-slot hotbar, without moving or replacing the vertical L/N/H dock. Only `factory_testing_sandbox.tscn` enables it; Main is unchanged.
- [x] Route Selected through `WorldInteraction._authorize_selected_blueprint_sites()` and All through `_authorize_all_blueprint_sites()`. All requires a **second explicit Confirm All click**; changing the candidate set or leaving Blueprint Mode invalidates confirmation. Ctrl+E continues to work directly.
- [x] Revalidate currently managed PLANNED blueprints at action time, never merely trust a UI signal, and clear Q-selection after successful authorization in the same way as E/Ctrl+E.
- [x] Add `res://tests/sandbox_blueprint_authorization_test.tscn` with **18 A–R isolated checks**, including priority/inspection isolation, confirmation invalidation, keyboard compatibility and a debug-bypass-OFF assertion that authorized jobs remain QUEUED with three missing requirements and zero time advancement.
- [ ] **Developer Godot 4.6.2 F6 pending:** Run the 18-case scene and manually verify both UI actions in normal Factory Testing Sandbox. Then rerun the E3d5c3e1b priority dock (16), E3d4b advanced selection (13) and E3d1 batch authorization (7) fixtures as the targeted regression gate.
- [ ] Integrate *genuine* item-delivery escrow, delivered power, finite worker capacity, cancellation/destruction recovery and save/load **before** any non-debug production readiness adapter or automatic construction dispatch.

**Safety boundary:** This UI uses the existing sandbox `blueprint_sandbox_debug_requirements = true` override only when the player explicitly authorizes a plan. The 18-case fixture turns that override **off** and expects QUEUED, not CONSTRUCTING. The isolated `BlueprintConstructionReadinessCoordinator` is not installed in Main or the playable sandbox. Prototype nameplate power is not delivered electricity, and unconnected requirements remain UNKNOWN / Live readiness NOT VERIFIED. Prior 89/89 acceptance is unchanged; the new 18/18 is **not yet verified**.

### E3d5c4a — Automated Authorization Acceptance (2026-11-11)

- [x] Developer-supplied Godot 4.6.2 Output screenshot verifies **18/18 A–R tests PASS** for `res://tests/sandbox_blueprint_authorization_test.tscn`.
- [x] The test leaves **six authorized jobs QUEUED, zero CONSTRUCTING, zero progress**, using its deliberate sandbox-debug-requirements-OFF fixture. Existing requirements inspection correctly reports **UNKNOWN** material stock/reservations, power and workers and **Live readiness NOT VERIFIED**.
- [x] Selected-only authorization, two-click All confirmation and candidate-set invalidation, L/N/H nonauthorization, direct-click inspection isolation and physical-key E/Ctrl+E fallbacks passed their isolated assertions.
- [ ] **Still pending:** actual normal-sandbox physical mouse clicks on Authorize Selected and Authorize All / Confirm All, placement/conveyor smoke, and three targeted post-change F6 regressions: `sandbox_vertical_priority_dock_e3d5c3e1b_test.tscn` **16**, `blueprint_area_selection_e3d4b_test.tscn` **13**, `batch_blueprint_authorization_e3d1_test.tscn` **7** (36 total).
- [ ] Do not treat the sandbox bypass or isolated coordinator as live construction readiness. Genuine material delivery/escrow, delivered power, finite worker capacity, recovery and save/load remain unverified.

**Note:** The automated test Output also logs `Placement blocked` **after** its final PASS line. The source of this residual message is not established; investigate only if reproducible during an intentional normal-sandbox placement attempt. This acceptance supersedes the earlier E3d5c4a automated F6-pending note, not its separate manual/regression gates.

### E3d5c4a — Targeted Post-Authorization Regression Gate Passed (2026-11-11)

- [x] Godot 4.6.2 F6: `sandbox_vertical_priority_dock_e3d5c3e1b_test.tscn` **16/16 PASS**. Confirms compact L/N/H geometry, valid selected-priority changes, physical H/N/L alternatives, no automatic job authorization, Main opt-out and preserved timers.
- [x] Godot 4.6.2 F6: `blueprint_area_selection_e3d4b_test.tscn` **13/13 PASS**. Confirms Q selection, Shift-add, Alt-remove, E selected-only, Ctrl+E all, unchanged progress, default Main opt-out.
- [x] Godot 4.6.2 F6: `batch_blueprint_authorization_e3d1_test.tscn` **7/7 PASS**. Confirms batch filtering, idempotence, active Blueprint Mode requirement and QUEUED/no-readiness-bypass when sandbox debug flags are disabled.
- **36/36 targeted regressions accepted; E3d5c4a authorization dedicated 18/18 + targeted 36/36 = 54/54 verified checks** on current implementation (separate F6 runs, not consolidated CI). The previous 89/89 UI milestone remains historically accepted; overlapping suites must not be counted as distinct new tests.
- [ ] **Remaining player-facing acceptance:** physical mouse Authorize Selected and two-click Authorize All / Confirm All in normal Factory Testing Sandbox; verify timers, cancel/selection behavior and a short conveyor turn/placement smoke. Three F6 screenshots verify automated fixtures, not these manual UI actions.
- [ ] No production connection to `BlueprintConstructionReadinessCoordinator` until actual material escrow/delivery, delivered power, worker capacity, recovery and save/load are proven. Main retains feature opt-out.

These results supersede the earlier E3d5c4a pending-regression checklist, but **not** the still-pending manual sandbox interaction gate.

### E3d5c4a — Player-Facing Sandbox Authorization Accepted (2026-11-11)

- [x] Developer reports the entire regular Factory Testing Sandbox manual authorization and conveyor smoke sequence passed. The supplied game screenshot independently shows Blueprint Mode with **four Q-selected planned blueprints**, selected priority composition **H1 / N2 / L1**, green selected-site highlights, compact **L/N/H** dock beside the hotbar and **Authorize Selected (4)** / **Authorize All (4)** buttons above it.
- [x] Acceptance evidence: developer-reported manual use of Selected and two-click All authorization, preserved timers and conveyor behavior; new authorization fixture **18/18** and targeted priority/selection/batch regressions **36/36** previously verified by Godot F6 screenshots.
- [x] **E3d5c4a accepted for Factory Testing Sandbox user-facing authorization only.** The screenshot is a pre-authorization selection state; the post-click behavior is accepted on the developer's report, not independently demonstrated by this image.
- [ ] Next: *isolated, fail-closed* authorization-to-readiness admission design/tests. Do not connect prototype nameplate power or test stock to production; actual delivered power, logistics, atomic escrow/recovery, bounded workers and save/load remain hard launch gates.

### E3d5c4b — Isolated Authorization-to-Readiness Admission (Staged; F6 Pending)

- [x] Introduce `BlueprintConstructionReadinessAdmission`, an explicit test-only handoff that defaults **OFF** and requires the Factory Testing Sandbox controller, enabled authorization dock, and sandbox debug readiness bypass **OFF**.
- [x] Allow admission only for **already-authorized, managed, live QUEUED** ConstructionSites with unfulfilled **power / materials / workers** gates, valid positive power demand and an external configured `BlueprintConstructionReadinessCoordinator`. Priority alone and PLANNED sites are rejected.
- [x] Delegate only to the existing coordinator's `track_site()` and provide explicit `admit_waiting()` discovery from WorldInteraction's authorized waiting priority queue. Neither method grants job flags, runs `reconcile()`, advances time, invents cargo/power, or dispatches worker drones.
- [x] Stage `res://tests/blueprint_readiness_admission_e3d5c4b_test.tscn` with **16 A–P checks** for feature-gate isolation, queued-only permission, invalid power demand, duplicate rejection, E selected-only / Ctrl+E-style All handoff, empty-stock fail closed, a test-only atomic-escrow supply with no generator, and Main/playable-scene opt-out.
- [ ] **Godot 4.6.2 F6 pending**: run 16-check isolated scene before any normal-sandbox wiring. Optional follow-up regression: `construction_readiness_coordinator_e3d5c3c1_test.tscn` 18 checks plus `sandbox_blueprint_authorization_test.tscn` 18 checks.
- [ ] True delivered inventory, electrical energy, finite physical worker drones, cancelled-job escrow recovery under full/absent stock, and robust save/load still block real dispatch. This admission foundation is **not installed** in either playable scene.

**Safety:** Existing prototype power allocator reports nameplate capacity, not electrical delivery. The isolated fixture may inject ingots into a test inventory, but the actual factory has not connected conveyor-delivered construction stock to escrow. Treat Live readiness as NOT VERIFIED.

### E3d5c4b — Isolated Readiness Admission F6 Acceptance (2026-11-11)

- [x] Developer screenshot confirms **ALL 16 E3D5C4B READINESS ADMISSION TESTS PASSED** in Godot 4.6.2, including default-off/test-only gating, already-authorized QUEUED-only admission, invalid demand rejection, priority-independent authorization, duplicate refusal, and no admission while sandbox debug bypass is active.
- [x] The fixture's controlled 3-ingot transfer into test stock gives one High-priority escrow without generators or workers; jobs remain QUEUED with no progress.
- [ ] Gameplay readiness remains unverified. This success does **not** test conveyor-delivered construction cargo, metered/delivered electricity, real worker drones, lossless persistence, or full recovery behavior in playable worlds.
- [ ] Next isolated material-supply step: a bounded input/staging inventory that transfers real item units instead of directly granting test stock, then proves escrow conservation, blocked refunds, and rerouting recovery under missing power. It is **not** proof of conveyor connectivity and must not be wired into production.

### E3d5c4c — Bounded Construction Material Staging and Recovery (Staged; F6 Pending)

- [x] Add test-only `BlueprintConstructionMaterialStaging`, disabled by default and absent from Main/Factory Testing Sandbox. Its own bounded `InventoryComponent` begins empty, accepts only definition-bill item types and validates inventory source ownership, capacity, and positive quantities.
- [x] Receive items only through existing `InventoryComponent.transfer_to()`, conserving physically accounted inventory units. This tests inventory transfers, **not** conveyor path, port, movement-time or delivery provenance.
- [x] Let the isolated readiness coordinator escrow **only from the staging buffer**, after both jobs are explicitly authorized. With no generators and no workers it remains QUEUED, even when a complete 3-ingot bill is held.
- [x] Cover partial delivery, priority-ordered reservation, duplicate prevention, cancellation when staging is too full to accept an escrow refund, fallback recovery to a separate inventory, and re-staging so the next job can reserve its own exact bill.
- [x] Stage `res://tests/blueprint_material_staging_e3d5c4c_test.tscn` with **16 A–P assertions**; no existing scenes or gameplay controllers were edited.
- [ ] **Developer Godot 4.6.2 F6 pending:** expect `ALL 16 E3D5C4C MATERIAL STAGING AND RECOVERY TESTS PASSED`. If successful, recheck earlier E3d5c2a escrow (16) and E3d5c3c1 readiness coordinator (18) if integration changes follow.
- [ ] Future physical connection must validate real conveyor endpoints, actual completed cargo movement, transfer ownership and refusal of disconnected/ghost sources. Metered delivered electrical power, worker drones, job recovery persistence/save-load remain separate production gates.

**Do not enable this test staging model as a playable provider.** It only proves a bounded inventory transfer path into escrow under isolated conditions; it cannot prove cargo came from a conveyor or that a real worker received building supplies.

### E3d5c4c — Developer F6 Acceptance (2026-11-11)

- [x] Developer's Godot 4.6.2 Output screenshot confirms **ALL 16 E3D5C4C MATERIAL STAGING AND RECOVERY TESTS PASSED**, A–P.
- [x] Test proves a bounded empty staging buffer, item filtering, partial transfer, High-priority escrow only after a complete three-ingot bill, conservation of all five ingots, blocked refund to a full buffer, alternate-source recovery and reuse by the second job. With no generated power/worker authority, the jobs remain QUEUED.
- [ ] This confirms only **inventory-to-inventory** staging, not physically connected conveyor unloading, delivered electrical power, drones, save/load or production readiness.
- [ ] Next isolated gate: validate a **real connected belt output endpoint and timed cargo** against a bill-filtering construction staging INPUT port, then escrow only what physically reaches that port. Keep playable scenes unchanged and do not claim live readiness.

### E3d5c4d — Physically Connected Conveyor-to-Staging Input (Staged; Godot F6 Pending)

- [x] Extend disabled-by-default `BlueprintConstructionMaterialStaging` with read-only `accepts_delivered_item()`, checking definition bill membership, live source and buffer, quantity and available capacity without moving items.
- [x] Add `BlueprintConstructionStagingInputPort`, a separate disabled-by-default subclass of `ItemPortComponent`. It binds only to an explicitly enabled staging inventory, requires `INPUT` direction / `ANY_ITEM` base policy, and overrides `can_accept_item()` to reject any item not on the construction bill or beyond staging capacity.
- [x] Exercise the **existing** `ConveyorBuildingSnap`, `ConveyorSegment.try_connect_building_port`, `ConveyorBuildingTransfer` and `ConveyorTransportTimer` rather than bypassing a connected belt. Direction, reciprocal port ownership, aligned physical endpoints, cargo travel interval and full-capacity backpressure must be respected.
- [x] Stage `res://tests/blueprint_physical_staging_e3d5c4d_test.tscn`, **16 A–P checks**. Supply starts with a test ore, which the bill-filtered port rejects and the test safely recovers; it then carries **four ingots** over an aligned, connected timed conveyor. Three enter staging and are atomically escrowed for one authorized job; a fourth waits during backpressure, is rejected when disconnected/misaligned, and completes only once a valid opening exists. All four ingots and the rejected ore must remain conserved.
- [x] The test leaves the construction job **QUEUED with zero progress and no workers**, because it has no generator. Main and regular Factory Testing Sandbox do not instantiate the input port or staging.
- [ ] **Developer Godot 4.6.2 F6 pending:** expect `ALL 16 E3D5C4D PHYSICAL CONVEYOR STAGING TESTS PASSED`. If successful, rerun `blueprint_material_staging_e3d5c4c_test.tscn` (16) and a representative `conveyor_automatic_unloading_test.tscn` (9) before further gameplay wiring.
- [ ] **Still required:** attachment to actual built/authorized sites and footprint ownership, end-to-end generated cargo across a complete factory, material provenance/recovery under demolition, metered delivered electricity, finite real worker drones, save/load and robust transactional recovery. Do not route into Main or disable the sandbox debug gates.

**Boundary:** This isolated synthetic output node and the physically connected belt prove the existing timed port-transfer mechanism can deliver to a construction-bill-filtered staging buffer. They do not prove that the player can construct or connect a receiver, that the origin is a real producing building, or that a complete game's construction readiness is verified.

### E3d5c4d — Godot Physical-Conveyor Staging Acceptance (2026-11-11)

- [x] Developer screenshot confirms **ALL 16 E3D5C4D PHYSICAL CONVEYOR STAGING TESTS PASSED**, A–P, in Godot 4.6.2.
- [x] The isolated real conveyor segment validated reciprocal source/receiver ports, endpoint alignment, timed delivery, bill-filtering (ore rejected), three-ingot bounded staging, fourth-ingot backpressure, misalignment rejection and recovery, and escrow of physically received material. The job remained QUEUED with no energy/worker authority.
- [ ] This does not yet test items genuinely manufactured by a real factory building nor the full source-building-to-smelter-to-staging path. Main and regular Factory Testing Sandbox are unchanged; production readiness remains NOT VERIFIED.
- [ ] Next: isolate a real `TestStorage` → conveyor → `TestSmelter` recipe → multiple conveyors → bill-filtered staging → escrow chain in one F6 suite, with explicit inventory provenance and no production dispatch.

### E3d5c4e — Real Smelter Manufacturing Chain to Construction Staging (Staged; F6 Pending)

- [x] Add an **isolated F6 test fixture only**: `res://tests/blueprint_factory_construction_chain_e3d5c4e_test.tscn`. Main, Factory Testing Sandbox, and gameplay controllers are unchanged.
- [x] Use the actual `TestStorage` inventory as a starting store for **eight explicitly seeded Test Ore**, an aligned connected conveyor to the **real TestSmelter INPUT**, and the Smelter's existing **2 ore → 1 ingot** timed manufacturing recipe.
- [x] Connect the real Smelter OUTPUT to **two reciprocal ConveyorSegment belts** leading to a separate construction-bill-filtered staging INPUT port. The existing `ConveyorBuildingSnap`, `ConveyorSegment.snap_after`, `ConveyorTransportTimer`, `ConveyorBuildingTransfer`, and `ProducerComponent._process` must perform the actual movement and manufacturing; no ingots are seeded.
- [x] Stage **16 A–P checks** for empty-factory fail-closed behavior, port geometry, recipe supply and timing, two-belt transportation, three-unit staging capacity/backpressure, four ingots from eight consumed ore, isolated coordinator escrow, QUEUED/no-power/no-worker readiness, misalignment recovery, cancellation and lossless refund to an alternative existing inventory.
- [ ] **Godot 4.6.2 F6 PENDING**. Expect `ALL 16 E3D5C4E FACTORY-TO-CONSTRUCTION LOGISTICS TESTS PASSED` only if the actual fixture validates successfully. If not, use the failing PASS boundary to fix the smallest isolated issue and re-run.
- [ ] When accepted, re-run E3d5c4d physical input (16), E3d5c4c staging escrow (16), and representative smelter/conveyor regressions before wiring any live providers.

**Limitations:** This proves a manufactured product can traverse a real multi-segment factory chain into construction material escrow; raw ore is still seeded into real Storage rather than mined from a real Extractor/resource node. The construction receiver is test-only, not player-buildable. Real delivered electricity, construction workers, dismantling recovery and save/load are not integrated; no automatic dispatch may be enabled.

### E3d5c4e — Assertion Correction After Initial F6 Run (2026-11-11)

- [x] Developer screenshot shows the first E3d5c4e F6 execution stopped at **line 286 / PASS M**, where the test incorrectly expected **three** missing readiness requirements *after* the isolated coordinator had successfully escrowed the full three-ingot material bill.
- [x] Corrected the **test only**: `get_wait_reasons()` must contain precisely `power` and `workers` (2), **not** `materials`, once real escrow is held. The job must still be **QUEUED**, with zero active workers and zero timer progress.
- [ ] **Rerun the updated E3d5c4e F6 fixture**. Do not count the first halted run as 16/16 and do not modify the coordinator to preserve an artificially missing materials flag. Construction readiness is still NOT VERIFIED for live gameplay.

### E3d5c4e — Factory-to-Construction Logistics F6 Accepted (2026-11-11)

- [x] Developer-supplied Godot 4.6.2 screenshot confirms **ALL 16 E3D5C4E FACTORY-TO-CONSTRUCTION LOGISTICS TESTS PASSED** (A–P) following correction of the PASS M wait-reasons assertion.
- [x] Actual TestSmelter recipe produced **4 ingots from 8 seeded ore**, transported them through connected timed belts, escrowed three into an authorized construction job and buffered the fourth under backpressure. Cancellation recovered the full bill with no loss. The job remained QUEUED: real power and workers absent.
- [ ] No claim of extractor-mined ore, production-delivered electrical power, physical construction workers, persistent recovery, or production scene readiness.
- [ ] Next isolated source verification: actual Test Ore Deposit + TestExtractor → timed connected conveyor → Storage INPUT with backpressure and resource conservation, before expanding into a complete extractor→smelter→construction fixture.

### E3d5c4f — Real Finite Ore Extraction to Storage by Conveyor (Staged; F6 Pending)

- [x] Introduce **isolated test scene only** `res://tests/blueprint_extraction_storage_e3d5c4f_test.tscn`; production Main, regular Factory Testing Sandbox, blueprint authorization, conveyor and resource components are unchanged.
- [x] Instantiate the actual `TestOreDeposit` finite node (starting **500 ore**) and `TestExtractor` scene. Require the existing `ExtractionArea` physics overlap scan to discover the actual deposit, then advance `ExtractorComponent._process()` to mine ore from its resource ledger; **no test ore is directly inserted into any inventory**.
- [x] Connect actual Extractor OUTPUT → existing `ConveyorSegment` INPUT and its OUTPUT → actual `TestStorage` INPUT using reciprocal port ownership and `ConveyorBuildingSnap` endpoint geometry, then use the existing conveyor timer and cargo inventory to transport real mined ore.
- [x] Stage **12 A–L F6 checks** for empty-deposit fail-closed behavior, finite depletion and mining time, reciprocal physical port connections, non-instant belt transit, three-item bounded Storage capacity, fourth-item backpressure, disconnection, clearance and reconnection recovery, and exact **500-unit conservation** across deposit remainder, extractor, belt, Storage and a drain inventory.
- [ ] **Godot 4.6.2 F6 PENDING:** expect `ALL 12 E3D5C4F FINITE EXTRACTION AND STORAGE LOGISTICS TESTS PASSED` only after the developer's Godot run. Fix any isolated geometry/physics assertion that fails before combining with the Smelter chain.
- [ ] After acceptance, build an extractor→storage→smelter→construction-staging *combined* test and re-run E3d5c4e, while keeping delivered electricity, finite real workers, cancellation recovery and save/load as separate production launch gates.

**Boundary:** The new test intentionally isolates **extraction-to-storage**, rather than claiming one verified combined production chain. It does not install a playable receiver, readiness provider, worker drone or resource-power shortcut.

### E3d5c4f — Finite Extraction and Storage Logistics F6 Accepted (2026-11-11)

- [x] Godot 4.6.2 developer Output screenshot confirms **ALL 12 E3D5C4F FINITE EXTRACTION AND STORAGE LOGISTICS TESTS PASSED** (A–L), including physics deposit discovery, timed mining, actual Extractor OUTPUT and Storage INPUT reciprocal conveyor connections, travel timing, three-unit capacity, fourth-item backpressure, physical disconnection and reconnection.
- [x] Initial finite Test Ore Deposit **500** units conserved across **496** remaining deposit ore and **4** extracted units distributed between Storage and a drain inventory; no ore directly inserted into inventory in this isolated source fixture.
- [ ] This is not a combined deposit→smelter→construction test, nor evidence of production-delivered power, physical worker capacity or save/load. Next: an isolated combined chain with mined ore and a real Smelter recipe; keep gameplay scenes unchanged.

### E3d5c4g — Complete Mined-Ore Factory-to-Construction Chain (Staged; F6 Pending)

- [x] Stage the **isolated F6-only** scene `res://tests/blueprint_mined_ore_construction_chain_e3d5c4g_test.tscn`, extending the already accepted E3d5c4e Smelter-to-staging and E3d5c4f Extractor-to-Storage foundations, without modifying playable scenes or construction code.
- [x] Use actual finite `TestOreDeposit` (500 starting ore), physical `TestExtractor` overlap discovery and eight 1-second mining cycles; ore then travels over a **physically connected mining belt** into real `TestStorage`. **No inventory receives seeded ore or ingots.**
- [x] Preserve downstream `TestStorage OUTPUT → belt → TestSmelter INPUT`, authentic **2 ore → 1 ingot** recipe timing, `TestSmelter OUTPUT → two belts → bill-filtered construction staging INPUT`, and exactly **three ingots escrowed + one buffered**. Total four conveyors.
- [x] Stage **18 A–R checks** for all real endpoint connections, finite deposit physics discovery, empty-factory refusal, ore mining and transfer, genuine Smelter input consumption, timed two-belt ingot delivery, full staging backpressure, misalignment/recovery, escrow and cancellation refund into an alternate real Storage inventory.
- [x] Conservation assertion: **492 ore remaining in finite deposit + (4 real ingots × 2 ore each) = 500 original ore-equivalent units**, both before and after cancellation. This is a manufacturing mass-balance check, not literal item-count equality between ore and ingots.
- [ ] **Developer Godot 4.6.2 F6 PENDING**: expect `ALL 18 E3D5C4G MINED-ORE FACTORY-TO-CONSTRUCTION TESTS PASSED`. Do not infer this from correct file syntax or GitHub commit. If stopped at an assertion, correct the isolated test or confirmed logic defect only and rerun.
- [ ] Recheck E3d5c4f 12/12 and E3d5c4e 16/16 if any shared logistics behavior changes.
- [ ] Production gating still requires player-buildable material receipt/ownership, real delivered electricity, bounded actual worker drones, destruction recovery, persisted escrow and save/load. Keep priority-only selection unable to authorize, and do not wire the coordinator into Main or Factory Testing Sandbox.

**Scope:** This is the first staged *combined fixture* for actual finite mining → Storage → actual recipe → timed belts → staging → escrow. The fixture manually steps existing production methods for determinism; it does not prove autonomous player-placed infrastructure, real delivered electricity, worker construction, or recovery/persistence in a normal saved world.

### E3d5c4g — Godot F6 Integrated Mining-to-Construction Acceptance (2026-11-11)

- [x] Developer screenshot confirms **ALL 18 E3D5C4G MINED-ORE FACTORY-TO-CONSTRUCTION TESTS PASSED** (A–R) in Godot 4.6.2.
- [x] Starting from a real finite 500-unit TestOreDeposit, the Extractor mined eight ore and existing reciprocal conveyor links delivered them to Storage, Smelter and construction staging as four recipe-produced ingots. Three ingots were escrowed; the fourth remained buffered after backpressure recovery.
- [x] Confirmed 500-unit **ore-equivalent** balance (492 remaining ore + 4 ingots × 2 ore) and refund-on-cancel without duplication. Authorized work stayed QUEUED with no power/workers and zero construction progress.
- [ ] This is verified **only as an isolated manually-stepped F6 factory fixture**, not as player-placed, saved construction logistics. Next stage: bind staging and input-port ownership to a particular authorized ConstructionSite without allowing cross-site reuse or automatically authorizing/dispatching jobs.

### E3d5c4h — Per-Site Construction Material Staging Ownership (Staged; F6 Pending)

- [x] Add disabled-by-default isolated `BlueprintConstructionSiteStagingRegistry`, which permits an **already-authorized QUEUED** `ConstructionSite` to claim exactly one bill-matching `BlueprintConstructionMaterialStaging` inventory and exactly one matching bound `BlueprintConstructionStagingInputPort`.
- [x] Introduce read-only `matches_definition()` on test staging and `get_bound_staging()` on the test-only input port. These identity checks do not change inventory, connections or construction readiness.
- [x] Explicit `reserve_for_site(site, escrow)` derives the **complete** bill from the registered ConstructionSite's `BuildingDefinition` and obtains stock **only** from that site's claimed staging buffer, delegating transactional debits/refunds to existing `BlueprintConstructionMaterialEscrow`.
- [x] Reject PLANNED/unapproved jobs, High-priority-only metadata, mismatched building material bills, mixed port/buffer pairs, duplicate site/port/staging claims, partial supply, repeated escrow and disabled feature gates. The registry neither starts construction nor interacts with power/worker providers.
- [x] Deliberately retain cancelled/stale ownership claims. A stocked or cancelled site's staging receiver cannot be silently reused; release/retarget policy requires future inventory/escrow recovery and save-load design.
- [x] Stage `res://tests/blueprint_site_staging_ownership_e3d5c4h_test.tscn` with **16 A–P checks**: two independent sites, two separately supplied three-ingot bills, cross-site isolation, full-buffer cancellation/refund to alternate stock, and exact nine-ingot conservation.
- [ ] **Godot 4.6.2 F6 pending:** expect `ALL 16 E3D5C4H PER-SITE CONSTRUCTION STAGING OWNERSHIP TESTS PASSED`. No local execution or pass claimed yet.
- [ ] Next acceptance after F6: regress the previously accepted E3d5c4c (16) and E3d5c4d (16) isolated staging and physical-input tests; then develop player-buildable receiver/site attachment and explicit recovery/persistence, before any production readiness.
- [ ] Real per-site physically delivered material, building/destruction recovery, metered electricity, physical worker drones, escrow persistence and save/load are **not verified**. Production Main and normal Factory Testing Sandbox remain untouched.

**Scope distinction:** E3d5c4g has independently verified the complete mined factory chain. E3d5c4h verifies **ownership/escrow identity** using explicit test-supplied ingots rather than replaying that production chain. The service is test-only and is NOT yet installed as an authoritative provider in either game scene.

### E3d5c4i — Isolated ConstructionSite-Aligned Material Receiver (Staged; F6 Pending)

- [x] Build a **separate, opt-in** `BlueprintConstructionAnchoredStagingPort` subclass of the tested bill-filtered physical input. It aligns to an actual `ConstructionSite.get_planned_port_named("InputPort")` marker, but **is never parented under the site**, because cancelling the site queues that node for deletion while materials/escrow may remain outstanding.
- [x] Permit attachment only for an explicitly authorized **QUEUED** site with a valid planned INPUT marker, bill-matching staging inventory, and a successful unique claim in the existing E3d5c4h staging ownership registry. PLANNED/priority-only sites and competing sites fail closed. A failed ownership claim disables the new port.
- [x] Keep the site's planned marker as **geometry only**, not an active `ItemPortComponent`. A separate receiver Node3D hosts the real port; the existing `ConveyorBuildingSnap`, reciprocal conveyor building-port connection, and `ConveyorTransportTimer` continue to enforce physical timed cargo transfer.
- [x] Refuse input if the blueprint moves away from the anchored port, if ownership/buffer identity changes, or if the job stops being QUEUED. Cancellation or site removal disables incoming cargo; escrow and buffered items are retained for explicit recovery. Do not release stale ownership automatically.
- [x] Stage `res://tests/blueprint_anchored_receiver_e3d5c4i_test.tscn` with **16 A–P Godot checks**: authorization and priority isolation, site planned marker geometry, exclusive port/buffer claim, correct and incorrect cargo, timed delivery, staged escrow, movement/misalignment blocking, full-buffer backpressure, cancellation intake cutoff, alternate refund and conservation of seven ingots plus one rejected ore.
- [ ] **Developer Godot 4.6.2 F6 pending:** expect `ALL 16 E3D5C4I ANCHORED CONSTRUCTION RECEIVER TESTS PASSED`; rerun E3d5c4h 16/16 and E3d5c4d 16/16 if issues occur or runtime behavior changes.
- [ ] **Not integrated into Main or Factory Testing Sandbox.** A production receiver still needs real player placement, site demolition/cancellation ownership release, live delivered electricity, actual bounded worker drones, persisted escrow/receiver/cargo, and save/load recovery. No real construction readiness/dispatch may use this test adapter.

**Safety:** This is *alignment to an actual planned site's port*, not a player-buildable receiver implementation. Test supplies come from an isolated synthetic source; E3d5c4g separately verified full mined/factory provenance.

### E3d5c4i — Site-Aligned Receiver F6 Acceptance (2026-11-11)

- [x] Developer Godot 4.6.2 Output screenshot confirms **ALL 16 E3D5C4I ANCHORED CONSTRUCTION RECEIVER TESTS PASSED** (A–P).
- [x] Isolated real planned-port geometry, authorization-only attachment, exclusive staging ownership, connected belt travel, wrong cargo refusal, backpressure, shifted-site alignment rejection, cancellation cutoff and alternative material recovery all passed.
- [x] Exact quantity conservation established for **7 ingots and 1 rejected ore** in the isolated source/receiver test. Missing production power and workers never permit construction.
- [ ] Receiver cleanup remains **unverified after the ConstructionSite is actually freed**; E3d5c4i only guards intake and retains claimed/held stock. Next implement a fail-closed, read-only decommission/recovery audit that refuses site/receiver reuse until belt cargo, buffer and escrow are explicitly cleared. Do not release ownership merely because the site was cancelled.
- [ ] Still no playable scene integration, production-delivered electricity, finite worker drones, or save/load.
