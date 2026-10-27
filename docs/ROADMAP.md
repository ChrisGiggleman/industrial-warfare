# Industrial Warfare — Development Roadmap

This roadmap tracks the major development stages for Industrial Warfare.

The current goal is to build a small, playable vertical slice before expanding into larger systems.

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

#### Next Chat 07 Work — Operational Transport

- [ ] Verify and implement explicit closure of already placed conveyor loops, without creating an overlapping new belt; guard endpoint availability.
- [ ] Normalize `InteractionHitbox` size/slight rotation and refine corner-shaped collision/selection footprints.
- [ ] Simplify legacy corner ghost selection and remove redundant debug/reset paths when safe.
- [ ] Connect machine and storage input/output ports to conveyor endpoints.
- [ ] Prevent distant or disconnected manual port handoffs from being used by gameplay logistics.
- [ ] Implement actual item movement, timing, capacity, throughput and backpressure with resource conservation.
- [ ] Design universal small/medium/large slot-and-stack storage.
- [ ] Add separate placeable splitters and mergers after straight/turn routing works.
- [ ] Replace proximity logistics only after physical belts pass manufacturing regression checks.
- [ ] Build ammunition supply and supply-dependent defense for the First Night slice.

### 1F — Enemy & Defense Prototype

- [ ] Add simple zombie enemy
- [ ] Add navigation toward player structures
- [ ] Add building health
- [ ] Add enemy damage
- [ ] Add basic defensive structure
- [ ] Add player/factory survival test

**Phase 1 Status: In Progress**

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

**Latest milestone (Chat 07.5):** In-place automatic left/right corner conversion, directional yellow arrows, visual L-shaped placeholders, and connected-chain/demolition tests are now present on GitHub main. Individual Godot tests and gameplay demos passed; final consolidated regression totals are not claimed. Next: polish corner colliders/mesh seams, support intentional closed-loop connections, connect belts to machine/storage ports, and implement safe item travel, throughput/backpressure and conservation. Temporary proximity transfers remain active. Universal slot/stack storage, dedicated splitters/mergers and ammunition-fed defenses remain part of [GAME_VISION.md](GAME_VISION.md).
