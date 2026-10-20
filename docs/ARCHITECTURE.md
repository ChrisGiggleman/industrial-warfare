# Industrial Warfare — Technical Architecture

This document describes the current technical organization of the Industrial Warfare Godot project.

The architecture is intentionally modular so individual systems can be tested, replaced, and expanded without turning a single controller into the entire game.

---

## Engine Baseline

- Engine: Godot 4.6.2 Stable Official
- Renderer: Forward+
- Primary language: GDScript
- Initial platform: Windows desktop
- Initial game mode: Single-player

---

## Project Structure

```text
res://
├── assets/
├── data/
│   ├── buildings/
│   ├── items/
│   └── resource_nodes/
├── docs/
│   └── screenshots/
├── scenes/
│   ├── buildings/
│   ├── core/
│   ├── resource_nodes/
│   └── ui/
├── scripts/
│   ├── components/
│   └── data/
├── tests/
├── icon.svg
└── project.godot
```

### Folder Responsibilities

- `data/` — concrete `.tres` game-data assets.
- `scripts/data/` — reusable custom `Resource` classes that define data schemas.
- `scripts/components/` — reusable gameplay components attached to scene child nodes.
- `scenes/buildings/` — reusable physical building scenes.
- `scenes/resource_nodes/` — selectable world resource scenes.
- `scenes/core/` — primary game scenes such as `main.tscn`.
- `scenes/ui/` — reusable interface scenes.
- `docs/` — design, architecture, troubleshooting, roadmap, and devlog documentation.

---

## Coding and Naming Conventions

- Project folders and filenames use lowercase `snake_case`.
- Custom class names use PascalCase, such as `BuildingDefinition`.
- GDScript uses tabs for indentation.
- Input actions describe player intent instead of hardware keys.
- Large scripts are divided with section headers:

```gdscript
# =============================================================================
# SECTION NAME
# =============================================================================
```

- Gameplay systems should prefer exported references, reusable components, and data resources over hard-coded scene paths and building-specific logic.

---

## Main Scene Architecture

The current main scene coordinates world, camera, interaction, and UI systems.

Conceptually:

```text
Main
├── Ground
├── DirectionalLight3D
├── WorldEnvironment
├── ReferenceCube
├── CameraRig
│   └── Camera3D
├── WorldInteraction
├── BuildHUD
└── ProductionDebugHUD
```

---

## Camera System

The camera uses a `CameraRig` Node3D with `Camera3D` as a child.

```text
CameraRig
└── Camera3D
```

`camera_controller.gd` currently provides:

- RTS-style WASD panning
- Mouse-wheel zoom
- Configurable movement and zoom limits

Camera control remains available during normal interaction and Build Mode.

---

## Input Architecture

Gameplay code references Godot Input Map actions instead of hard-coded keys.

Current examples include:

- `move_forward`
- `move_backward`
- `move_left`
- `move_right`
- `primary_action`
- `secondary_action`
- `camera_zoom_in`
- `camera_zoom_out`
- `toggle_placement_mode`
- `rotate_placement`
- `select_building_1`
- `select_building_2`
- `select_building_3`
- `demolish_selected`

The current prototype bindings include:

- WASD — camera movement
- Mouse wheel — zoom
- LMB — primary interaction
- RMB — secondary/cancel interaction
- `B` — Build Mode
- `R` — rotate building
- `1` / `2` / `3` — Test Extractor / Large Building / Test Storage
- `Delete` — toggle Demolition Tool while in Build Mode

---

## World Interaction Architecture

`world_interaction.gd` coordinates player interaction with the 3D world.

Its current responsibilities include:

- object selection
- Build Mode state
- placement ghost creation
- grid snapping
- physical-footprint and extractor resource-range placement checks
- building selection
- building instantiation
- runtime definition injection
- placement rotation
- Demolition Tool behavior
- communication with the Build HUD
- communication with the Production Debug HUD

Building-specific production and inventory behavior does **not** belong in `WorldInteraction`.

---

## Interaction States

### Normal Mode

- LMB raycasts into the world.
- Selectable objects can be selected.
- Clicking ground or empty space clears selection.
- Selected objects control their own visual feedback.
- Selected building data is forwarded to the Production Debug HUD.

### Build Mode

Entered with `B`.

- Normal selection is disabled.
- The active building receives a placement ghost.
- Mouse position is projected onto the ground.
- Placement snaps to a configurable 1-meter grid.
- Green indicates valid placement.
- Red indicates blocked placement.
- `R` rotates in 90-degree increments.
- `1`, `2`, and `3` select prototype building definitions, including Test Storage.
- LMB places a valid building.
- RMB exits Build Mode.

### Demolition Tool

Demolition exists inside Build Mode.

- `Delete` enters or leaves the Demolition Tool.
- Placement ghost is removed while demolition is active.
- Valid `player_built` targets receive red hover feedback.
- LMB demolishes the current valid target.
- Non-player-built objects such as `ReferenceCube` remain protected.
- RMB exits Build Mode completely.

---

## Physics Layers

| Layer | Purpose |
|---|---|
| 1 | Ground / placement surfaces |
| 2 | Selectable-object collision, including ore deposits |
| 3 | Placement blockers |

Placement ground raycasts use Layer 1.

Selection and resource-deposit detection use Layer 2; an extractor's range check confirms the hit belongs to a `ResourceNodeRuntime`.

Physical footprint overlap queries use Layer 3.

An extractor's `Area3D` detector shape is not a physical construction blocker. This separation allows independent ground, footprint, and resource-range checks.

---

## Object Groups

### `selectable`

Marks logical objects that may be selected.

A collider may be a child of the logical object. `WorldInteraction` walks upward through the node hierarchy until it finds a `selectable` ancestor.

### `player_built`

Marks structures the player is allowed to demolish.

A building may be both:

- `selectable`
- `player_built`

`ReferenceCube` is selectable but intentionally not player-built.

### `logistics_storage`

Identifies real storage building roots eligible for proximity-based automatic item delivery. The logistics component filters out disabled placement ghosts, pending-deletion instances, missing inventories, full destinations, and out-of-range buildings.

---

## Selectable Object Visual State

`selectable_object.gd` owns selection and demolition visual feedback.

Current priority:

1. Demolition hover
2. Normal selection
3. Original material

The interaction controller requests state changes but does not directly manage each object's material implementation.

This keeps interaction logic separate from presentation.

---

## Data-Driven Building Definitions

Building metadata is represented by the custom resource class:

`BuildingDefinition`

Current fields:

- `building_id`
- `display_name`
- `description`
- `category`
- `building_scene`

Prototype assets:

- `res://data/buildings/test_extractor.tres`
- `res://data/buildings/test_building_large.tres`
- `res://data/buildings/test_storage.tres`

The separation is:

```text
BuildingDefinition (.tres)
        ↓ references
Building Scene (.tscn)
```

The `.tres` file describes **what the building is**.

The `.tscn` file describes **how the building exists in the world**.

`WorldInteraction` stores construction options as:

```gdscript
Array[BuildingDefinition]
```

It no longer maintains a separate hard-coded `Array[PackedScene]`.

---

## Runtime Building Placement

Placement flow:

```text
Selected BuildingDefinition
        ↓
building_scene
        ↓
Placement Ghost / Validation
        ↓
Instantiate Building Scene
        ↓
Add to Current World
        ↓
Initialize BuildingRuntime
```

The selected `BuildingDefinition` is used for both ghost creation and actual placement.

This keeps construction data centralized and allows future building metadata such as costs, icons, unlock rules, and categories to be added without hard-coding individual buildings into the interaction controller.

---

## Placement Ghost

The placement ghost is a temporary instance of the selected building scene.

It:

- follows the snapped placement position
- tests only `PhysicsBody3D` collision shapes for physical footprint overlaps
- excludes `Area3D` detection shapes from physical footprint blockers
- disables collision shapes for ordinary ghost physics interactions
- additionally checks resource range when the ghost has `ExtractorComponent`
- turns translucent green when valid
- turns translucent red when blocked
- respects current rotation

The ghost's root uses:

```gdscript
process_mode = Node.PROCESS_MODE_DISABLED
```

This is important because building scenes may contain gameplay components such as producers. A visual placement preview must not run extraction, production, or other gameplay logic.

Resource-range validation builds a `PhysicsShapeQueryParameters3D` from the extractor ghost's `ExtractionArea/CollisionShape3D` and queries resource colliders on Layer 2; actual extraction runs only after placement.

The ghost is destroyed when:

- Build Mode ends
- Demolition Mode begins
- the selected building changes
- a replacement ghost is created

---

## Runtime Building Composition

Placed buildings use reusable child components rather than placing all gameplay behavior on the root script.

Current Test Extractor scene (`res://scenes/buildings/test_extractor.tscn`):

```text
TestExtractor [selectable, player_built]
├── BuildingBody (StaticBody3D)
│   └── CollisionShape3D
├── BuildingMesh
├── BuildingRuntime
├── InventoryComponent
├── ExtractorComponent
├── LogisticsTransferComponent
└── ExtractionArea (Area3D, Layer 2 detection)
    └── CollisionShape3D (radius 2.5)
```

The building root owns selectable-object behavior. The large test building remains a non-extractor and requires no nearby ore.

Current storage scene (`res://scenes/buildings/test_storage.tscn`):

```text
TestStorage [selectable, player_built, logistics_storage]
├── BuildingBody (StaticBody3D) + CollisionShape3D
├── BuildingMesh (1 × 1 × 2.8)
├── BuildingRuntime
└── InventoryComponent (max_capacity = 200)
```

The Test Extractor's inventory capacity is 50. Its `LogisticsTransferComponent` and `ExtractorComponent` share the same root but remain independent components.

### `BuildingRuntime`

`building_runtime.gd` stores the `BuildingDefinition` associated with the placed building instance.

Initialization flow:

```text
WorldInteraction
        ↓
selected BuildingDefinition
        ↓
instantiate building_scene
        ↓
find BuildingRuntime
        ↓
initialize(definition)
```

This allows an individual building to know which data definition created it.

### Component Philosophy

Not every building requires every component.

Future scenes can be composed from only the behavior they need, for example:

```text
Storage Building
├── BuildingRuntime
└── InventoryComponent

Extractor
├── BuildingRuntime
├── InventoryComponent
├── ExtractorComponent
├── LogisticsTransferComponent
└── ExtractionArea

Future Powered Machine
├── BuildingRuntime
├── InventoryComponent
├── ProducerComponent
└── PowerConsumerComponent
```

---

## World Resource Nodes & Extraction

The resource-node system consists of:

- `scripts/data/resource_node_definition.gd`: `ResourceNodeDefinition` with `resource_node_id`, `display_name`, `description`, `resource_item: ItemDefinition`, `infinite_resource`, and `starting_amount`.
- `data/resource_nodes/test_ore_deposit.tres`: Test Ore Deposit data, currently configured for a **finite 500-unit regression test** (infinite mode remains supported).
- `scenes/resource_nodes/TestOreDeposit.tscn`: selectable deposit mesh, Layer 2 collision body, and `ResourceNodeRuntime`.
- `scripts/components/resource_node_runtime.gd`: per-deposit `remaining_amount` and `extract(amount: int) -> int`.
- `scripts/components/extractor_component.gd`: per-building resource detection, interval timing, and inventory delivery.

`ResourceNodeRuntime.extract()` returns the requested valid amount for infinite deposits without depletion; for finite deposits it returns at most the available quantity and subtracts it from remaining supply. Invalid/nonpositive requests return zero. Both modes were runtime-tested.

`ExtractorComponent` finds its sibling `InventoryComponent` and tracks a nearby deposit using `ExtractionArea` overlap signals plus a deferred initial scan. The Test Extractor has a radius-2.5 detection sphere and defaults to one ore per one-second extraction cycle. Extraction first checks the inventory's available space and requests at most that amount from the deposit, so full inventories do not deplete finite resources. Only the actual extracted amount enters inventory; an out-of-range or depleted node does not generate ore.

```text
TestOreDeposit
    ├── ResourceNodeDefinition (Test Ore, infinite/finite supply)
    └── ResourceNodeRuntime.extract(amount)
                      │ actual extracted amount
                      ↓
TestExtractor.ExtractorComponent
                      ↓
TestExtractor.InventoryComponent.add_item(item, amount)
```

Placement validation and runtime extraction are separate: `WorldInteraction` queries whether an extractor *can reach* a resource at a proposed location; the placed `ExtractorComponent` later performs timed extraction.

---

## Item Data Architecture

Items are represented by:

`ItemDefinition`

Current fields:

- `item_id`
- `display_name`
- `description`

Prototype item:

- `res://data/items/test_ore.tres`

The inventory and recipe systems use `ItemDefinition` resources rather than scattering item-name strings throughout gameplay code.

---

## Item Amount Data

`ItemAmount` represents:

```text
ItemDefinition + integer quantity
```

It is used by recipe input and output arrays.

Current fields:

- `item`
- `amount`

This resource can also be reused later for systems such as building costs if that remains appropriate.

---

## Inventory Architecture

`InventoryComponent` stores a per-building `Dictionary` of `ItemDefinition -> integer quantity`. Capacity is **shared across item types**, not a separate limit per item. Inventories remain independent until a transfer occurs.

- `max_capacity`: maximum total units; **0 means unlimited**.
- `get_total_amount()`: current total across all types.
- `get_available_space()`: free units, or **-1 for unlimited**.
- `is_full()`: whether a limited inventory has reached capacity.
- `add_item(item, amount) -> int`: partial acceptance, returning the number successfully added.
- `remove_item(item, amount) -> bool`: full requested removal or rejection.
- `get_amount(item)` and `has_amount(item, amount)`: quantity queries.
- `transfer_to(destination, item, amount) -> int`: move up to the source's quantity and destination's free capacity, rejecting self-transfers, missing destinations, and invalid amounts. Any unaccepted units are returned to the source.

Current scene values: **Test Extractor 50 units**, **Test Storage 200 units**. Item slots, stack sizes, item filters, persistence, and a final user-facing inventory UI are not implemented.

---

## Storage & Automatic Logistics (Chat 05)

`data/buildings/test_storage.tres` references `scenes/buildings/test_storage.tscn`. The storage root belongs to `logistics_storage`, `selectable`, and `player_built`.

`scripts/components/logistics_transfer_component.gd` is a reusable `LogisticsTransferComponent`. The current Test Extractor uses:

- `transfer_item = test_ore.tres` (explicit `ItemDefinition`)
- `transfer_amount = 5` units per cycle
- `transfer_interval = 1.0` second
- `transfer_range = 5.0` world units between building origins

At every transfer interval, this component scans the `logistics_storage` group, skips disabled preview ghosts and invalid/full destinations, selects the **nearest eligible** storage in range, and calls `InventoryComponent.transfer_to()`. It reports `logistics_status`, `last_transfer_amount` (most recent attempt), and `last_successful_transfer_amount` (persists when movement stops).

`No Eligible Storage` currently combines full, absent, and out-of-range destinations. `Transferring` means the previous cycle moved something; `Waiting for Resources` indicates a destination exists but the source had nothing to move. The configured transfer amount / interval is a **maximum rate**, not measured throughput.

This is a **direct, proximity-limited logistics prototype**. Physical conveyors, inserters, ports, routing networks, and automated multi-machine production chains have not been implemented.

### Resource Flow

```text
Test Ore Deposit (finite / infinite)
    ↓ ResourceNodeRuntime.extract() [limited by free extractor space]
Test Extractor
    ├── InventoryComponent (50)
    ├── ExtractorComponent
    └── LogisticsTransferComponent
           ↓ transfer_to() [up to 5 units / second; range 5]
Test Storage
    └── InventoryComponent (200)
```

**Final regression:** finite starting amount 500 = **250 remaining + 50 in extractor + 200 in storage**, with no lost or duplicated resources observed.

### Test Assets

The committed test scene is `res://tests/inventory_trasnfer_test.tscn` and references `res://scripts/components/test_inventory_transfer.gd`. These are the current file paths (including the `trasnfer` filename typo). The test covers partial/full/empty/invalid transfers and item conservation. A later tidy-up can rename/move the test files and update resource references.



---

## Production Recipe & Producer Framework

The reusable Chat 03 framework remains in the codebase:

- `scripts/data/production_recipe.gd` — `ProductionRecipe` with `recipe_id`, `display_name`, `production_time`, and input/output arrays of `ItemAmount`.
- `scripts/components/producer_component.gd` — `ProducerComponent`, which times a recipe and adds its outputs to an `InventoryComponent`.

The original `data/recipes/prototype_extraction.tres` was a **historical Chat 03 test asset**, deleted in Chat 04 after the small building switched to world-node extraction. No current Test Extractor scene has a `ProducerComponent`; the reusable recipe/producer classes are retained for future manufacturing buildings.

Recipe input availability and consumption are not implemented yet.

---

## Current Factory Data Flow

Production and extraction remain separate architectures: the actual gameplay path is **Test Ore Deposit → Test Extractor inventory → range-limited Test Storage inventory**. The reusable `ProductionRecipe` and `ProducerComponent` remain available for later manufacturing but do not yet consume inputs or participate in a conveyor network.

---

## Build HUD

`build_hud.gd` owns construction-mode presentation.

Responsibilities include:

- selected building slot
- Build Mode state
- Demolition Mode state
- control reminders
- mode-specific styling

`WorldInteraction` communicates with the HUD through methods rather than directly modifying individual labels.

The current Build HUD is a prototype and may later evolve into an icon-based quick-build interface.

---

## Production Debug HUD

`production_debug_hud.gd` refreshes diagnostics for the selected object:

- **Resource node:** deposit name, item, and remaining/starting amount or infinite supply.
- **Extractor:** detected resource, status, stored quantity, inventory capacity/full flag, and logistics status, configured maximum transfer rate, latest transfer amount, and latest successful transfer amount.
- **Storage:** total stored item count, capacity used, and quantities per `ItemDefinition`.
- **Other producer/non-extractor:** recipe or `Recipe: None`, where appropriate.
- **No selection:** neutral diagnostic message.

This HUD is a prototype, not player-facing final UI. Current `Status: Extracting` means a usable deposit exists, even if extraction is stopped by inventory capacity. Full and unreachable storage both currently produce `No Eligible Storage`.

---

## Current Architectural Boundaries

**Implemented through Chat 05:** camera, selection, placement, demolition, data-driven buildings, resource extraction, capacity-limited inventories, partial item transfers, dedicated storage, automatic nearby delivery, inventory HUD, and basic logistics debug telemetry.

**Planned:** recipe input checking/consumption, actual conveyors and logistics routing/ports, explicit full-vs-unreachable status, power networks, machine constraints, construction costs, research/unlocks, save/load, and polished UI.

---

## Architectural Principles

Industrial Warfare currently follows these rules:

1. Keep interaction, data, runtime behavior, and UI responsibilities separate.
2. Prefer reusable components over large monolithic building scripts.
3. Prefer custom `Resource` data over hard-coded per-building logic.
4. Add only the complexity required by the current milestone.
5. Regression-test established systems after architectural changes.
6. Keep placeholder visuals acceptable while gameplay systems are being proven.
