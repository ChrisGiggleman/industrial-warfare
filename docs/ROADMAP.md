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
