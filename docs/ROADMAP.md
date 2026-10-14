# Industrial Warfare — Development Roadmap

This roadmap tracks the major development stages for Industrial Warfare.

The current goal is to build a small, playable vertical slice before expanding into larger systems.

---

## Phase 0 — Foundation

Goal: Establish a clean and maintainable technical base.

- [x] Create Godot 4.6.2 project
- [x] Establish initial project folders
- [x] Create documentation structure
- [x] Configure Git and GitHub
- [x] Review and finalize `.gitignore`
- [x] Define naming and coding conventions
- [x] Configure essential Godot project settings
- [x] Create initial input mappings
- [x] Create a basic main/test scene
- [x] Make the first Git commit

---

## Phase 1 — Core Prototype

Goal: Prove the basic game loop in a simple test environment.

Planned systems:

- Player camera and movement
- Basic world terrain
- Resource nodes
- Resource collection
- Basic building placement
- Basic conveyor/logistics prototype
- Simple storage
- Basic power or machine operation
- Simple zombie enemy
- Enemy movement toward player structures
- Basic defensive structure
- Basic health and damage system

---

## Phase 2 — Zombie Colony Prototype

Goal: Combine factory automation and defense into a playable scenario.

Planned systems:

- Small abandoned settlement
- Zombie spawning zones
- Resource extraction
- Production chain
- Defensive perimeter
- Day/night progression
- Increasing enemy pressure
- Basic player progression
- Factory expansion decisions

---

## Phase 3 — First Night Vertical Slice

Goal: Create the first polished, showcase-ready gameplay experience.

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

- Larger factory systems
- More complex logistics
- Additional zombie types
- Abandoned towns and cities
- Vehicle systems
- Technology progression
- Larger maps
- Additional planets
- Different enemy factions
- Advanced warfare systems
- Performance optimization

## Phase 1 Checklist

- [x] Create CameraRig architecture
- [x] Create first GDScript
- [x] Connect camera controller to existing input actions
- [x] Implement basic WASD camera panning
- [x] Implement camera zoom
- [x] Tune camera movement and zoom speeds
- [x] Add ground collision
- [x] Create WorldInteraction controller
- [x] Cast a 3D ray from the mouse cursor
- [x] Detect clicked world position
- [x] Detect clicked collider
- [x] Make test objects selectable
- [x] Add visible selection feedback
- [x] Replace temporary scale selection with material highlight
- [x] Complete basic selectable-object interaction loop
- [x] Separate placement-surface raycasting from selectable-object collision
- [x] Add grid snapping to placement cursor
- [x] Add placement occupancy checking
- [x] Add valid/invalid placement feedback
- [x] Add basic placement mode
- [x] Toggle placement mode with input action
- [x] Disable normal selection while placement mode is active
- [x] Show placement preview only during placement mode
- [x] Place first test object
- [x] Create reusable test building scene
- [x] Instantiate first building at runtime
- [x] Prevent placement on occupied grid cells
- [x] Support multiple runtime placements
- [x] Add building placement ghost
- [x] Remove placement ghost when exiting Build Mode
- [x] Show placement validity directly on building ghost
- [x] Remove temporary placement tile from placement visuals
- [x] Clean up placement ghost when leaving Build Mode
- [x] Add 90-degree placement rotation
- [x] Apply placement rotation to ghost preview
- [x] Preserve rotation on placed buildings
- [x] Support rectangular building footprints
- [x] Make placement validity rotation-aware
- [x] Use actual building collision shape for placement checks
- [x] Cancel placement mode with secondary action
- [x] Support multiple buildable scenes
- [x] Switch buildable type during Build Mode
- [x] Preserve footprint-aware placement across building types
- [x] Add demolition tool
- [x] Restrict demolition to player-built structures
- [x] Move demolition into Build Mode
- [x] Add demolition HUD state
- [x] Add demolition hover targeting
- [x] Clear demolition state when leaving Build Mode

## Camera & Player Interaction Foundation

- [x] Create RTS-style camera rig
- [x] Add WASD camera movement
- [x] Add mouse-wheel camera zoom
- [x] Add world mouse raycasting
- [x] Add selectable-object system
- [x] Add visual selection feedback
- [x] Establish collision-layer conventions
- [x] Add Build Mode
- [x] Add grid-snapped placement
- [x] Add placement validity checks
- [x] Add building placement ghost
- [x] Add valid/invalid ghost coloring
- [x] Add 90-degree building rotation
- [x] Add rotation-aware placement footprints
- [x] Add multiple prototype building types
- [x] Add prototype Build HUD
- [x] Add player-built object classification
- [x] Add demolition tool
- [x] Restrict demolition to Build Mode
- [x] Add demolition HUD state
- [x] Add demolition hover targeting
- [x] Complete interaction-system refactor
- [x] Complete final regression test

**Status: Complete**

## Building Definition and Building Runtime Foundation 

- [x] Create reusable BuildingDefinition resource
- [x] Create data-driven prototype building definitions
- [x] Refactor Build Mode to use BuildingDefinition data
- [x] Remove legacy PackedScene buildable collection
- [x] Add reusable BuildingRuntime component
- [x] Assign BuildingDefinition data to placed building instances
- [ ] Create reusable item/resource definition system
- [ ] Create basic building inventory component
- [ ] Create production recipe definition system
- [ ] Create reusable producer component
- [ ] Create first autonomous prototype producer

## Factory & Production Foundation

- [x] Create BuildingDefinition resource architecture
- [x] Create prototype building data assets
- [x] Make Build Mode data-driven
- [x] Add BuildingRuntime component
- [x] Inject building definitions into runtime instances
- [ ] Create ItemDefinition resource
- [ ] Create reusable InventoryComponent
- [ ] Create ProductionRecipe resource
- [ ] Create ProducerComponent
- [ ] Produce first test resource automatically

**Status: In Progress**