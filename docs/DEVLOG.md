# Industrial Warfare — Development Log

This document tracks meaningful development milestones, design decisions, technical changes, testing, troubleshooting, and showcase-ready progress.

The development log intentionally summarizes completed milestones rather than recording every individual edit.

---

## 2026-10-11 — Project Foundation

### Engine and Project

Created the Industrial Warfare project with:

- Godot Engine 4.6.2 Stable Official
- Forward+ renderer
- Windows desktop as the initial platform
- Single-player as the initial development target

Project path:

```text
E:\GameDev\industrial-warfare
```

### Initial Structure

Created the initial project organization:

```text
assets/
data/
docs/
docs/screenshots/
scenes/
scripts/
tests/
```

Created the core documentation files:

- `DEVLOG.md`
- `ROADMAP.md`
- `GAME_DESIGN.md`
- `ARCHITECTURE.md`
- `TROUBLESHOOTING.md`
- `FUTURE_FEATURES.md`

### Source Control

Initialized Git using the `main` branch.

Created the public GitHub repository:

```text
ChrisGiggleman/industrial-warfare
```

Connected the local repository to `origin` and pushed the project to GitHub.

### Godot Configuration

Configured:

- 1920 × 1080 base resolution
- `canvas_items` stretch mode
- `keep` stretch aspect
- resizable window
- initial Input Map actions

Initial input actions included camera movement, interaction, mouse actions, and zoom.

### Main Scene Foundation

Created:

```text
res://scenes/core/main.tscn
```

Initial world setup included:

- ground
- DirectionalLight3D
- WorldEnvironment
- Camera3D
- ReferenceCube

### Troubleshooting

Resolved an early PowerShell relative-path mistake while creating documentation files.

### Visual Milestone

The project opened successfully in Godot and entered source control with a clean baseline.

### Status

**Project Foundation: Complete**

---

## 2026-10-12 — Chat 02: Camera & Player Interaction Foundation

### Camera

Created a `CameraRig` architecture and added:

- WASD camera movement
- mouse-wheel zoom
- movement/zoom tuning
- frame-rate independent motion

### Mouse and World Interaction

Created:

```text
res://scripts/world_interaction.gd
```

Added mouse-to-world raycasting and separated player interaction from the camera controller.

### Selectable Objects

Created a reusable selection system using the `selectable` group.

Implemented:

- collider-to-logical-object parent traversal
- persistent selection state
- gold material highlight
- deselection on ground/empty-space clicks

Selection presentation was moved into:

```text
res://scripts/selectable_object.gd
```

### Physics Layer Conventions

Established:

- Layer 1 — Ground / placement surfaces
- Layer 2 — Selectable-object collision
- Layer 3 — Placement blockers

This allows ground placement raycasts and occupancy checks to remain independent.

### Build Mode

Added Build Mode with `B`.

Implemented:

- 1-meter grid snapping
- placement validity checking
- green/red placement feedback
- LMB placement
- RMB cancellation/exit

### Runtime Building Placement

Created prototype building scenes:

- `test_building.tscn`
- `test_building_large.tscn`

Added runtime instantiation and placement blocking.

### Placement Ghost

Replaced the temporary flat marker with a full translucent building ghost.

The ghost:

- follows snapped placement
- uses the actual building footprint
- turns green/red based on validity
- is safely removed when Build Mode ends

### Rotation

Added `R` rotation in 90-degree increments.

Placement validity uses the actual rotated collision shape, allowing rectangular footprints to validate correctly.

### Multiple Building Types

Added prototype building selection:

- `1` — small test building
- `2` — large test building

Switching buildings recreates the ghost and preserves footprint-aware validation.

### Build HUD

Created a temporary Build HUD showing:

- current build mode
- building slots
- selected building
- control hints

### Demolition Tool

Moved demolition into Build Mode.

Implemented:

- `Delete` tool toggle
- red demolition HUD state
- red demolition-hover targeting
- LMB demolition
- `player_built` protection rules
- safe return to placement mode

`ReferenceCube` remains selectable but cannot be demolished.

### Refactor and Regression Test

Cleaned the interaction code by:

- removing obsolete HoverMarker logic
- using named constants for masks/rotation/ghost alpha
- improving method names
- improving demolition cleanup
- organizing scripts with section headers

Regression-tested:

- camera movement
- zoom
- selection/deselection
- Build Mode
- building switching
- grid snapping
- placement ghost
- valid/invalid coloring
- collision blocking
- rotation
- rotated footprints
- placement
- demolition
- protected objects

No gameplay regressions were found.

### Status

**Chat 02 — Camera & Player Interaction Foundation: Complete**

---

## 2026-10-14 — Chat 03: Factory Building & Production Foundation

Chat 03 moved Industrial Warfare from a construction prototype into the first reusable factory-production architecture.

### Data-Driven Building Definitions

Created:

```text
res://scripts/data/building_definition.gd
```

`BuildingDefinition` currently stores:

- building ID
- display name
- description
- category
- building scene

Created:

- `res://data/buildings/test_building.tres`
- `res://data/buildings/test_building_large.tres`

The `.tres` file now describes what a building is, while the `.tscn` file describes how it physically exists.

### Build-System Refactor

Refactored `WorldInteraction` from a direct `Array[PackedScene]` to:

```gdscript
Array[BuildingDefinition]
```

The selected definition now supplies the scene used for:

- placement preview
- placement validation
- runtime construction

Removed the legacy `buildable_scenes` collection after regression testing.

### Building Runtime Component

Created:

```text
res://scripts/components/building_runtime.gd
```

Placed buildings receive the `BuildingDefinition` that created them.

Current flow:

```text
BuildingDefinition
        ↓
building_scene
        ↓
placed building
        ↓
BuildingRuntime.initialize(definition)
```

This gives each placed building access to its own data identity without hard-coding building-specific behavior into `WorldInteraction`.

### Item Definition

Created:

```text
res://scripts/data/item_definition.gd
```

Created the first item asset:

```text
res://data/items/test_ore.tres
```

`Test Ore` is the prototype raw material used to validate inventory and production behavior.

### Item Amount

Created:

```text
res://scripts/data/item_amount.gd
```

`ItemAmount` represents an `ItemDefinition` plus an integer amount.

This is used by recipe input/output arrays.

### Inventory Component

Created:

```text
res://scripts/components/inventory_component.gd
```

Current inventory operations:

- add item
- remove item
- get quantity
- check quantity

Verified with temporary runtime tests:

```text
Inventory added - Test Ore: 5
Has 5 Test Ore: true
Removed 2 Test Ore: true
Inventory remaining - Test Ore: 3
```

Temporary test code was removed after verification.

Multiple placed buildings were confirmed to maintain independent inventory instances.

### Production Recipe Data

Created:

```text
res://scripts/data/production_recipe.gd
```

Created:

```text
res://data/recipes/prototype_extraction.tres
```

Prototype recipe:

```text
Prototype Extraction
Production Time: 2 seconds
Inputs: none
Outputs: 1 Test Ore
```

The recipe format supports input arrays for future processing recipes, but input consumption is not implemented yet.

### Producer Component

Created:

```text
res://scripts/components/producer_component.gd
```

Added `ProducerComponent` only to the small `TestBuilding`.

The large prototype intentionally remains a non-producer for comparison.

Production flow:

```text
ProducerComponent
        ↓
Prototype Extraction
        ↓
wait 2 seconds
        ↓
1 Test Ore
        ↓
InventoryComponent
```

Verified autonomous production and independent inventory counts across multiple placed producers.

### Placement Ghost Gameplay Safety

Because placement ghosts instantiate the same building scene as real buildings, producer components would otherwise exist inside the preview.

The ghost root now uses disabled process mode so gameplay scripts do not run on temporary placement previews.

Verified that placement ghosts do not produce resources.

### Production Debug HUD

Created:

```text
res://scenes/ui/production_debug_hud.tscn
res://scripts/production_debug_hud.gd
```

The temporary debug HUD displays live selected-building information.

Producer example:

```text
PRODUCTION DEBUG

Building: Test Building
Recipe: Prototype Extraction
Stored Test Ore: 7
```

Non-producer example:

```text
Building: Test Building Large
Recipe: None
```

Non-building selection:

```text
Selected object has no building data.
```

No selection:

```text
No building selected.
```

The stored resource count updates live while production continues.

Temporary production console spam was removed after the HUD became the primary production-debug view.

### Troubleshooting and Lessons

Notable issues encountered:

- a `Resource` script was accidentally attached to `Main` Node3D
- GDScript indentation errors occurred while inserting nested test blocks
- the fixes reinforced the distinction between data resources, node scripts, and indentation-based GDScript structure

See `TROUBLESHOOTING.md` for reusable fixes.

### Regression Coverage

Throughout Chat 03, changes were regression-tested against the established interaction foundation.

Verified systems include:

- camera movement
- camera zoom
- normal selection
- selection clearing
- Build Mode
- building switching
- grid snapping
- placement ghost
- valid/invalid placement
- rotation
- rotated footprints
- runtime placement
- Demolition Tool
- protected non-player-built objects
- data-driven building selection
- BuildingRuntime initialization
- independent building inventories
- autonomous production
- non-producing control building
- placement-ghost production safety
- Production Debug HUD selection states

No persistent gameplay regressions remained at the end of the milestone.

### Architecture Milestone

The first factory gameplay foundation is now:

```text
BuildingDefinition
        ↓
Building Scene
        ↓
BuildingRuntime
        │
        ├── InventoryComponent
        └── ProducerComponent
                ↓
        ProductionRecipe
                ↓
            ItemAmount
                ↓
          ItemDefinition
```

### Current Limitations

Intentionally deferred:

- world resource nodes
- recipe input consumption
- storage capacity
- conveyors/logistics
- power networks
- build costs
- research/unlocks
- machine upgrades
- save/load
- polished factory UI

### Status

**Chat 03 — Factory Building & Production Foundation: Complete**

The project now has its first autonomous, data-driven production building.
