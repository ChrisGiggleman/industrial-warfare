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

### 1C — Next Factory Gameplay Milestones

Recommended next targets:

- [ ] Add world resource-node definition and prototype resource node
- [ ] Restrict extractor production to a valid resource source
- [ ] Add recipe input checking and input consumption
- [ ] Add simple storage capacity
- [ ] Add a basic storage building
- [ ] Add simple transfer/logistics behavior
- [ ] Prototype conveyors
- [ ] Add basic machine/power state
- [ ] Replace or evolve temporary production debug UI as needed

### 1D — Enemy & Defense Prototype

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

Current development should continue inside Phase 1 with resource extraction, production inputs, storage/logistics, and then the first enemy/defense prototype.
