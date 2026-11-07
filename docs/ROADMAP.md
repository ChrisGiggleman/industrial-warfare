# Industrial Warfare — Development Roadmap

This roadmap tracks the major development stages for Industrial Warfare.

The current goal is to build a small, playable vertical slice before expanding into larger systems.

---

## Timed Storage — Conveyor Delivery Compatibility (2026-11-07)

- [x] `construction_footprint_ports_test.tscn`: **4/4 passed locally**; unfinished sites reserve the physics footprint and expose no inventory/port.
- [x] Add `tests/timed_storage_conveyor_delivery_test.tscn` covering site completion, a physically snapped conveyor, one ore delivery, item conservation, and disconnection cleanup.
- [x] Run `timed_storage_conveyor_delivery_test.tscn` in Godot 4.6.2: **6/6 passed** (2026-11-07), including actual cargo delivery and conservation.
- [ ] Verify player-built conveyor connection in F6 sandbox to completed timed Storage.
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
