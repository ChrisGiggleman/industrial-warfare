# Industrial Warfare — Technical Architecture

This document describes the technical organization of the Industrial Warfare Godot project. **Current operational status is updated through Chat 08.3G-3K (2026-10-30); older Chat 07–08.3F sections below are retained as historical checkpoints and may describe features that were subsequently implemented.**

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
│   ├── recipes/
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
- `select_building_4`
- `demolish_selected`

The current prototype bindings include:

- WASD — camera movement
- Mouse wheel — zoom
- LMB — primary interaction
- RMB — secondary/cancel interaction
- `B` — Build Mode
- `R` — rotate building
- `1` / `2` / `3` / `4` — Test Extractor / Large Building / Test Storage / Test Smelter
- `5` — Conveyor Belt, with straight/corner/bridge automatic placement
- `6` — 1×1 Conveyor Merger (3 IN / 1 OUT)
- `7` — 1×1 Conveyor Splitter (1 IN / 3 OUT)
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
- `1`–`7` select the current building definitions, including conveyor, Merger and Splitter. Eligible new buildings use `FactoryGrid`'s rotated-footprint grid origin; conveyors use their physical endpoint snapping and geometry checks.
- LMB places a valid building.
- RMB exits Build Mode.

### Demolition Tool

Demolition exists inside Build Mode.

- `Delete` enters or leaves the Demolition Tool.
- Placement ghost is removed while demolition is active.
- Valid `player_built` targets receive red hover feedback.
- LMB demolishes the current valid target when safe. Occupied conveyor buffers and non-empty Merger/Splitter inventories prevent unsafe removal.
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
- `res://data/buildings/test_smelter.tres`

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

Current smelter scene (`res://scenes/buildings/test_smelter.tscn`):

```text
TestSmelter [selectable, player_built]
├── BuildingBody (StaticBody3D)
│   └── CollisionShape3D
├── BuildingMesh
├── BuildingRuntime
├── InputInventory (InventoryComponent, max_capacity = 50)
├── OutputInventory (InventoryComponent, max_capacity = 100)
├── ProducerComponent
└── LogisticsInputComponent
```

The smelter references `res://data/recipes/test_smelting.tres` and reuses the same inventory component class in two **distinct instances**. Incoming ore and finished ingots never compete for the same inventory capacity. Its `selection_mesh` export references `BuildingMesh` so normal selection and demolition-hover materials work.

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
├── InputInventory
├── OutputInventory
├── ProducerComponent
└── PowerConsumerComponent (planned)
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

`ExtractorComponent` finds its sibling `InventoryComponent` and tracks a nearby deposit using `ExtractionArea` overlap signals plus a deferred initial scan. The Test Extractor has a radius-2.5 detection sphere and defaults to one ore per one-second extraction cycle. Extraction first checks the inventory's available space and requests at most that amount from the deposit, so full inventories do not deplete finite resources. Only the actual extracted amount enters inventory; an out-of-range or depleted node does not generate ore. `ExtractorComponent.extraction_status` reports `Extracting`, `Inventory Full`, `No Resource In Range`, `Resource Depleted`, or a configuration issue, and the extraction timer resets when the component cannot operate.

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

- `res://data/items/test_ore.tres` — raw material
- `res://data/items/test_ingot.tres` — processed material from the smelting recipe

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

Current scene values: **Test Extractor 50 units**, **Test Storage 200 units**, **Test Smelter input 50 units**, and **Test Smelter output 100 units**. Capacity applies to each separate inventory instance. Item slots, stack sizes, item filters, persistence, and a final user-facing inventory UI are not implemented.

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

This is a **direct, proximity-limited logistics prototype**. The extractor-to-storage-to-smelter processing chain now works automatically, but physical conveyors, inserters, ports, network routing, and finished-ingot export have not been implemented.

### Resource Flow

```text
Test Ore Deposit (finite / infinite)
    ↓ ResourceNodeRuntime.extract() [limited by free extractor space]
Test Extractor
    ├── InventoryComponent (50)
    ├── ExtractorComponent
    └── LogisticsTransferComponent
           ↓ transfer_to() [up to 5 units per second; range 5]
Test Storage
    └── InventoryComponent (200)
           ↓ LogisticsInputComponent finds stocked storage and uses transfer_to()
Test Smelter
    ├── InputInventory (50; ore buffer target 10)
    ├── ProducerComponent [2 ore -> 1 ingot every 2 seconds]
    └── OutputInventory (100; stores ingots)
```

**Chat 05 historical regression:** 500 starting ore = **250 deposit + 50 extractor + 200 storage**.

**Chat 06 complete-chain regression:** 500 starting ore equivalents = **236 deposit + 50 extractor + 200 storage + 10 smelter input + (2 ingots × 2 ore)**. Production, transfers, and blocking were also regression-tested independently. Neither test observed resource loss or duplication.

### Test Assets

The committed test scene is `res://tests/inventory_trasnfer_test.tscn` and references `res://scripts/components/test_inventory_transfer.gd`. These are the current file paths (including the `trasnfer` filename typo). The test covers partial/full/empty/invalid transfers and item conservation. A later tidy-up can rename/move the test files and update resource references.



---

## Production Recipes & Safe Producer Transactions (Chat 06)

The former Chat 03 output-only producer has been replaced with a real input-consuming manufacturing component. The retired `data/recipes/prototype_extraction.tres` is historical, not active.

- `scripts/data/production_recipe.gd`: `ProductionRecipe` defines a recipe ID, name, positive cycle time, and arrays of `ItemAmount` for required inputs and produced outputs.
- `scripts/data/item_amount.gd`: each `ItemAmount` pairs an `ItemDefinition` reference with an integer quantity.
- `data/recipes/test_smelting.tres`: **2 Test Ore → 1 Test Ingot, 2 seconds**. The recipe uses the same `test_ore.tres` reference as extraction and logistics.
- `scripts/components/producer_component.gd`: `ProducerComponent` receives explicitly assigned, distinct `input_inventory` and `output_inventory` references.

### Production Preconditions and Transaction

1. `has_required_inputs()` rejects missing inventories/recipes and invalid input entries, aggregates repeated ingredient requirements, and confirms every required quantity is present.
2. `can_store_recipe_outputs()` validates every output entry and verifies enough free space for the **sum** of output quantities in the separate output inventory; it recognizes unlimited capacity.
3. `_process(delta)` only advances `production_progress` while inputs and output space are available. Invalid, missing-input, or output-full states reset progress and set `production_status`.
4. At cycle completion, `try_complete_recipe_cycle()` repeats the checks, removes the required inputs, adds finished outputs, and returns success only after all requested outputs are stored.
5. `_rollback_recipe_cycle()` attempts to remove any partial outputs and restore consumed ingredients if a synchronous operation fails unexpectedly.

These safeguards prevent free-output generation, ordinary partial production, and normal capacity-related item loss. Exceptional rollback failures are reported by the component and need stronger fault-injection tests if the simulation later allows interleaved inventory mutations.

**Blocked states:** The prototype resets the cycle rather than preserving partial progress when ingredients or output space are unavailable. For output-full smelting, the HUD shows `Output Blocked` and 0% progress while retained ore and ingots stay unchanged.

### Storage-to-Smelter Input Logistics (Chat 06)

`scripts/components/logistics_input_component.gd` attaches to the smelter and requests ore from the nearest eligible, stocked `logistics_storage` node within **5 world units**. It uses `InventoryComponent.transfer_to()` and does not create or destroy items.

Current Inspector configuration:

- `input_inventory`: smelter `InputInventory` node (not `OutputInventory`)
- `transfer_item`: `data/items/test_ore.tres`
- `transfer_amount`: up to **5** ore per attempt
- `transfer_interval`: **1.0** second
- `transfer_range`: **5.0** world units
- `target_buffer_amount`: **10** ore (a logistics refill target, not the physical 50-unit capacity)

It validates nearby candidate storage and requested buffer/capacity limits, then transfers at most what is available and required. It exposes `logistics_status` and `last_transfer_amount` for debug use. Existing extractor-to-storage `LogisticsTransferComponent` remains separate.

### Recipe Selection and Input Acceptance (Chat 07 — Implemented)

`ProducerComponent` now exposes two separate recipe concepts:

- `@export var recipe: ProductionRecipe` is the **active** recipe used by all manufacturing timing, input consumption, and output creation functions.
- `@export var available_recipes: Array[ProductionRecipe]` is the **allowlist** of recipes that this particular manufacturing machine may select. The Test Smelter's scene assigns its existing `test_smelting.tres` to both the active recipe and the list (one available recipe for now).
- `select_recipe(new_recipe) -> bool` accepts only non-null recipes from the allowlist with positive production time and nonempty input/output arrays. Re-selecting the active recipe is a no-op. For an actual change, the input inventory reference must exist and **must be empty**; the method never discards ingredients or completed outputs. A successful selection resets progress to zero and sets `production_status = "Recipe Changed"`. This is a conservative interim recipe-change rule, not a final item-ejection UI.
- `accepts_input_item(item: ItemDefinition) -> bool` is a read-only ingredient-type predicate against the **active** recipe's positive-quantity input entries. It rejects null or unrelated items, does not check inventory capacity, and never inserts, removes, or consumes items.

`LogisticsInputComponent` now has an exported `producer_component: ProducerComponent` reference (assigned to `../ProducerComponent` in `test_smelter.tscn`). In its timed `_process`, the temporary short-range logistics component **fails closed** before storage discovery/transfer if the producer is missing (`Producer Missing`) or its configured `transfer_item` is not required by the active recipe (`Item Not Required by Recipe`); `last_transfer_amount` is reset to zero. Matching Test Ore continues to transfer normally.

**Boundary / next-step caveat:** `transfer_item` is still statically assigned to Test Ore on the current smelter. Switching to a recipe requiring other ingredients *blocks* unsuitable ore but does **not** cause automatic sourcing of the replacement ingredient or support multiple ingredients in one logistics component. Item type acceptance is **not** the same as insertion capacity; future physical conveyor input ports must combine the recipe predicate with inventory/slot/throughput checks and atomic resource movement. Proximity movement remains temporary compatibility scaffolding, not the intended final transport system.

### Chat 07 Regression Assets

- `tests/recipe_selection_test.tscn` / `.gd`: **10/10** recipe switching, unsupported/invalid recipes, input-buffer safety, output preservation, and manufacturing after switching.
- `tests/recipe_input_acceptance_test.tscn` / `.gd`: **6/6** active-recipe eligibility, null/invalid ingredients, recipe changes, and read-only behavior.
- `tests/recipe_logistics_acceptance_test.tscn` / `.gd`: **5/5** reference validation, incompatible transfers rejected, conservation, and normal transfers after restoring the recipe.
- **21/21 new Chat 07 tests passed**. The user reran **36/36 Chat 06 manufacturing checks**, the Chat 05 inventory-transfer regression groups, and the active factory gameplay successfully. These are locally executed Godot 4.6.2 tests; no automated CI run is claimed.

The isolated logistics test suppresses automatic `_process` on its instantiated producer and logistics components after adding them to the scene, invokes transfer checks manually, and queues the temporary smelter/storage instances for deletion. This prevents residual transfer log messages after assertions finish.

### Manufacturing and Timing Test Assets

- `tests/recipe_input_availability_test.tscn` — **8 passed**
- `tests/recipe_output_capacity_test.tscn` — **11 passed**
- `tests/manufacturing_transaction_test.tscn` — **9 passed**
- `tests/timed_manufacturing_test.tscn` — **8 passed**

**Chat 06 total: 36/36 passed**, plus the existing Chat 05 inventory transfer test groups.

---

## Reusable Item Ports & Safe Logical Handoffs (Chat 07 — Steps 07.3A–07.3E)

`scripts/components/item_port_component.gd` defines `ItemPortComponent extends Marker3D`, a reusable 3D machine/storage connection point. Markers provide local position/orientation without visible gameplay geometry. **They are not connected conveyor belts yet.**

### Port Configuration and Rules

- `PortDirection.INPUT` receives items; `PortDirection.OUTPUT` supplies items. Source and destination directions must agree with their roles.
- `InputPolicy.RECIPE_INPUTS` admits only valid items in `ProducerComponent.recipe` via the existing `accepts_input_item()`; the input port verifies that its `inventory` is exactly the producer's `input_inventory`.
- `InputPolicy.ANY_ITEM` is intended for universal storage. It admits any non-null item *subject to capacity*, without a `ProducerComponent`.
- `can_accept_item(item, amount = 1) -> bool` requires an input port, non-null item, positive amount, valid inventory, a passing policy, and enough available space for the **entire** amount. `InventoryComponent.get_available_space() == -1` signifies unlimited storage. It is read-only.
- `can_provide_item(item, amount = 1) -> bool` requires an output port and a valid inventory containing the full quantity; if a producer is assigned, the port inventory must match `producer.output_inventory`. It is read-only.
- `try_transfer_to_port(destination_port, item, amount = 1) -> int` validates distinct and compatible ports/inventories, full source availability, and full destination acceptance before calling the already-tested `InventoryComponent.transfer_to()`. It returns the actual quantity transferred or zero on validation failure. Current port handoffs are **all-or-nothing at the port precheck**; no requested partial fill if destination has insufficient space.

### Test Smelter Scene Composition

`scenes/buildings/test_smelter.tscn` has two new **direct child** `Marker3D` nodes using `ItemPortComponent`:

| Port | Local position | Local Y rotation | Inventory | Producer |
| --- | --- | --- | --- | --- |
| `InputPort` | `(-0.85, 0.5, 0)` | `+90°` | `../InputInventory` | `../ProducerComponent` |
| `OutputPort` | `(0.85, 0.5, 0)` | `-90°` | `../OutputInventory` | `../ProducerComponent` |

The input uses `RECIPE_INPUTS`, and the output uses direction `OUTPUT`. With `Marker3D` children, the ports' world positions and outward-facing `-Z` axes follow the building rotation; the 07.3C test validates the 90° case. These local positions are provisional until connection-grid rules are established.

### Chat 07 Port Test Assets

| Isolated test scene | Reported checks |
| --- | --- |
| `tests/item_port_foundation_test.tscn` | **7/7** — basic acceptance, policy, capacities and nonmutation |
| `tests/item_port_integration_test.tscn` | **8/8** — scene references, directions, positions, building rotation, safe queries |
| `tests/item_port_transfer_test.tscn` | **7/7** — invalid direction/quantity, recipe blocking, full-request capacity, self-transfer, universal storage conservation |
| `tests/item_port_real_smelter_test.tscn` | **7/7** — six Test Ore supplied, two complete smelting cycles, two ingots handled through real smelter ports, full storage rejection, **six ore-equivalents conserved** |

The developer reported **29/29** port tests passing, plus a final regression of **21/21** previous Chat 07 recipe checks, **36/36** earlier manufacturing checks, existing inventory-transfer regression tests, and the normal factory in Godot 4.6.2. The test scenes run locally in the editor; this does **not** claim a CI run.

### Current Transport Boundary

**Historical Chat 07 port boundary:** Port checks and `try_transfer_to_port()` are logical, manually invoked handoffs, not physically routed transfers. At that checkpoint, belt connections had geometry but no cargo handling. **Chat 08 update:** Timed, directed belt-to-belt transportation is now implemented and tested independently, but machine/storage ports are **not yet connected** to conveyors. Manual port handoffs still do not require physical adjacency. The existing nearby extractor/storage/smelter transfers remain active; universal slot/stack storage, splitter/mergers, ammunition supply and defense are future work.

---

## Straight Conveyor Construction and Connections — Chat 07.4 (Implemented)

### Geometry and Scene

- **LogisticsConnectionGeometry** (scripts/components/logistics_connection_geometry.gd) checks world-space proximity, opposite-facing endpoints and forward alignment. The default discovery gap is 0.75 world units, while committed belt links use a stricter 0.05 gap.
- **ConveyorStraight** (scenes/logistics/conveyor_straight.tscn) has a steel-gray BeltMesh (0.8 × 0.2 × 1.0, centered at local Y 0.3), InputEndpoint at (0, 0.5, +0.5) facing +Z, and OutputEndpoint at (0, 0.5, -0.5) facing -Z. Directional flow is local +Z to -Z.
- A separate ConveyorBody StaticBody3D on **collision Layer 3** provides the construction footprint. InteractionHitbox Area3D on **Layer 2** supports mouse selection and demolition. The root is in **player_built** and **selectable**, retains its ConveyorSegment script and uses BeltMesh for gold/red selection/demolition highlights.
- **Nonblocking follow-up:** The committed InteractionHitbox BoxShape3D does not explicitly specify its size (Godot default is 1 × 1 × 1) and the node has a slight Y rotation. Selection and demolition passed in gameplay; normalize these scene properties when working on corner collision/precision. Do not treat this observation as a failed test.

### Directed Connections and Snapping

- **ConveyorSegment** (scripts/components/conveyor_segment.gd) stores previous_segment and next_segment, limiting each straight segment to one incoming and one outgoing neighbor. try_connect_to() validates both scene-tree nodes, available endpoints and opposing world-space markers before storing reciprocal links. disconnect_next(), disconnect_previous(), disconnect_all() and _exit_tree() clear both sides safely when disconnected or demolished.
- snap_after() computes and commits straight-to-straight placement. get_snap_preview_transform_after() and get_snap_preview_transform_before() calculate **read-only world transforms**, without moving or connecting real belts.
- **WorldInteraction** searches available output and input endpoints of placed ConveyorSegment nodes within a 1.25-unit horizontal snap search radius, choosing the nearest valid candidate. A temporary ghost previews the resulting world transform, while conveyor_snap_source and conveyor_snap_before track the candidate and connection direction.
- On click, the snapped-conveyor branch executes **before normal building instantiation**: one conveyor is created, the ghost transform applied, and one directed link committed (new → existing when snap-before, existing → new when snap-after). A rejected link queues the newly created instance for deletion. Normal unsnapped buildings and free conveyor placement retain their existing path.
- Conveyor Belt is **BuildingDefinition slot 5 (key 5)** via data/buildings/conveyor_belt.tres, scenes/core/main.tscn, the project Input Map and BuildHUD. Slots 1–4 are unchanged.

### Verified Conveyor Regression Suite

| Isolated test scene | Developer-reported result |
| --- | --- |
| logistics_connection_geometry_test.tscn | **8/8** |
| conveyor_alignment_test.tscn | **9/9** |
| conveyor_connection_state_test.tscn | **8/8** |
| conveyor_snapping_test.tscn | **5/5** |
| conveyor_snap_preview_test.tscn | **5/5** |
| conveyor_snap_before_test.tscn | **5/5** |

**40/40** conveyor checks passed in local Godot 4.6.2 tests. Additional reported checks confirmed bidirectional snapped placement, orientation after rotating, selection/demolition, and unchanged extractor → storage → smelter behavior. No CI run is claimed.

**Historical Chat 07.4 boundary:** This checkpoint implemented straight-belt placement and connections only. **Chat 07.5 subsequently added in-place left/right turns and direction indicators**, as described below. The original proximity transfers and manually invoked machine-port transfers remain separate from physical belts, and links are geometry-validated when created.

---


## Automatic In-Place 90° Corners and Direction Indicators — Chat 07.5 (Implemented)

### Construction Decision

The sole player-facing Conveyor Belt build option (key **5**) places a **straight** belt ghost. The project deliberately no longer requires the user to aim at a separate left- or right-corner ghost. When the player places and rotates a new straight one grid cell to the local right or left of an existing **straight** conveyor's free output, `WorldInteraction._find_perpendicular_corner_candidate()` identifies the eligible earlier belt by transforming the new position into source-local coordinates and checking new-belt facing against the expected world-space direction. This works across rotated source orientations provided the new belt actually points **away** from the old belt. It is not a branch/splitter and never silently overrides occupied outputs.

`WorldInteraction._try_place_object()` retains normal placement/snap-before/after branches and calls `ConveyorCornerConversion.try_convert_and_connect(source, receiver, turn)` for eligible new adjacent straight pieces. The previous conveyor **changes in place**; the new piece stays straight. The conversion helper uses `ConveyorPieceSelector` to access right/left scene templates and validates `ConveyorTurnIntent.Turn.RIGHT/LEFT`, available endpoints, and straight-source shape. It temporarily changes the source OutputEndpoint transform, invokes the preexisting geometry-validated `try_connect_to()`, and restores the original output on a failed connection. Only a successful connection commits new mesh and duplicated body/interaction shapes. The segment retains its node identity, previous link and reciprocal references; `_exit_tree()` continues to clean up when demolished.

### Scene Geometry and Visuals

- `scenes/logistics/conveyor_corner.tscn` and `conveyor_corner_left.tscn` provide right/left endpoint orientations and prototype collision transforms. OutputEndpoint is **local +X** for right and **local -X** for left; standard straight flow is from local +Z input toward local -Z output.
- `scripts/components/conveyor_corner_visual_mesh.gd` generates a placeholder `ArrayMesh` using SurfaceTool and **two combined box arms**, each 0.8 wide and 0.2 high. A visually filled bend and directional arrows were demonstrated. The committed implementation is **not** yet a mathematically unified outline/polygon surface; slight stepped seams and precise corner-shaped colliders remain refinements.
- `scripts/components/conveyor_direction_arrow.gd` is attached to `ConveyorStraight/OutputEndpoint/DirectionArrow`. Its unshaded yellow arrow uses local -Z forward, offset above/inward from the output marker. It follows each conveyor's real output direction in the green build ghost and on placed straight and converted corner belts. No item movement or animation is implied.
- The straight scene's `ConveyorBody` remains the physical placement-blocking StaticBody3D on **layer 3**, and `InteractionHitbox` remains a selection/demolition Area3D on **layer 2**. The corner converter swaps template shapes and transforms on successful turns, but those prototype boxes do not perfectly outline the visible L; a manual Visible Collision Shapes inspection, selection and demolition were reported successful. The default/rotated hitbox cleanup remains pending.

### Endpoint Snapping and Rotation

- `ConveyorSegment.get_snap_preview_transform_after()` now computes its preview basis from **`source_output.global_transform.basis`**, not the source root's basis. This is necessary because converted corner outputs do not point along the root's local -Z.
- `LogisticsConnectionGeometry.are_endpoints_aligned()` still requires opposing endpoint-facing directions, spatial coincidence (within the connection tolerance) and a valid forward direction for any permitted residual gap. Arbitrary 90°/180° facing cannot connect merely because meshes overlap.
- The `R` control currently cycles Godot **Y rotations 0 → 90 → 180 → 270 → 0**. With a 0° straight pointing world -Z, 90° points -X, 180° +Z, and 270° +X. Arrow indicators remove the prior visual ambiguity: a belt rotated to point back toward the preceding belt is correctly rejected, not a corner-snap defect.
- `ConveyorTurnIntent` and `ConveyorPieceSelector` and their tests remain useful utilities; runtime Build Mode uses the **existing-straight conversion** workflow rather than continuous mouse-position ghost shape-switching. Some old helper/debug code remains to clean up later.

### Test Coverage and Boundaries

Individually reported local Godot suites include corner connection **8/8**, left corner **8/8**, corner snap preview **6/6**, turn intent **8/8**, piece selector **8/8**, in-place conversion **8/8**, full-chain link/rotation/demolition **8/8**, and corner visual mesh **8/8**. Main-game screenshots show right/left turns, arrows following different rotations, green preview arrows and successful selection/demolition; a single consolidated final test-run total was not independently reported. These are **developer-executed Godot tests, not automated CI**.

**Still out of scope:** closing an already-placed belt loop as an explicit final directed link; belt item travel, throughput/backpressure; machine/storage input/output port hookup; automatic smelter export; universal slotted storage; separate splitter/merger buildings. Physical conveyor construction is not yet physical material transport. Current extractor → storage → smelter transfers still use temporary proximity logic.

---

## Physical Conveyor Cargo & Timed Item Transportation — Chat 08 (Foundation Implemented)

### Real Conveyor Scene Composition

`scenes/logistics/conveyor_straight.tscn` now contains three additional direct child nodes:

- `CargoInventory` (`InventoryComponent`, `max_capacity = 1`) stores one item **unit** per belt for the initial prototype.
- `ConveyorTransportComponent` references that inventory and exposes read-only held-item lookup, guarded inventory loading and low-level buffer-to-buffer transfer. Its functions accept **any valid `ItemDefinition`**; no Test Ore, copper, iron or ammunition identifiers are hardcoded.
- `ConveyorTransportTimer` supplies a configurable per-segment `travel_interval` (currently **1.0 second**), `elapsed_seconds`, `transport_status` and `successful_transfers`. `_process(delta)` calls `advance_transport(delta)`. Empty belts reset elapsed progress, occupied belts advance their timers, and a blocked output retains its cargo and completed progress.

`ConveyorTransportLink.try_transfer_forward(source)` is the **connection-aware** handoff layer. It checks scene-tree validity, a real `next_segment`/`previous_segment` reciprocal link, aligned output/input markers (using `ConveyorSegment.CONNECTION_GAP`), and both cargo components. It then delegates to the existing capacity- and conservation-aware inventory transfer. Direct lower-level cargo helpers do **not** enforce physical routing by themselves and must not be called as independent automatic gameplay logistics.

Right/left automatic corner conversion changes the existing belt **in place**, so the new inventory and timer nodes survive with the same object identity. Dedicated `conveyor_corner*.tscn` templates remain geometry templates; in normal Build Mode, the `ConveyorStraight` instance is converted when a compatible perpendicular belt is placed.

### Cargo-Safe Player Demolition

`ConveyorSegment.can_demolish_safely()` returns true only when its expected one-unit `CargoInventory` exists and is empty. `WorldInteraction._try_demolish_under_mouse()` consults this method before queueing a **player-selected** conveyor for deletion. Occupied or misconfigured belts are rejected; normal building demolition is unchanged. This does **not** guard arbitrary direct `queue_free()`, world teardown, or future combat destruction; those lifecycle cases require an explicit item recovery/drop policy before implementation.

### Local Godot Validation (Chat 08)

| Test scene | Reported assertions |
| --- | --- |
| `conveyor_transport_buffer_test.tscn` | 7/7 — one-item generic buffer and conservation |
| `conveyor_connected_transport_test.tscn` | 7/7 — directed physical links, misalignment, reverse blocking |
| `conveyor_timed_transport_test.tscn` | 8/8 — timed updates, blockage recovery and distinct item definitions |
| `conveyor_corner_cargo_test.tscn` | 8/8 — in-place left/right conversion preserves cargo/timers |
| `conveyor_full_transport_test.tscn` | 8/8 — six-segment straight/corner chain, item ordering, end-of-line backpressure |
| `conveyor_cargo_demolition_test.tscn` | 6/6 — occupied cargo protection and generic item handling |

**44/44 assertions across six separately reported suites**, plus rerun connected/timed/full-chain regressions and developer-confirmed main-game construction, corners, demolition and existing factory behavior. These are **local Godot test runs**, not one consolidated CI execution.

### Operational Boundary

**Status at the first Chat 08 checkpoint (historical):** Belt-to-belt movement was implemented, but building connections, item visuals and automatic machine loading/unloading were not yet in place. These have since been added to the isolated, code-driven Chat 08 integration tests described below. Player-facing Build Mode does **not** yet discover and connect machine ports, so the ordinary factory still uses proximity logistics.

---
## Cargo Visuals, Physical Machine Ports & Factory Integration — Chat 08 (Second Milestone)

### Generic Cargo Visualization — 08.2D

- `scripts/components/conveyor_cargo_visual.gd` (`ConveyorCargoVisual extends MeshInstance3D`) reads `ConveyorTransportComponent.get_held_item()` and `ConveyorTransportTimer.elapsed_seconds / travel_interval`, producing a simple visible box while occupied and hiding it when empty. It never modifies inventory or transfer timing.
- Straight belts interpolate between local input/output markers. In-place left/right converted corners use a two-part local-space L path (`input → bend → output`), including under rotated parents. Blocked cargo remains at the output until a transfer succeeds.
- The `CargoVisual` child is present on `scenes/logistics/conveyor_straight.tscn` and survives in-place corner conversion. **One generic metallic cube is used for all items currently**; item-specific models, materials and more detailed turn animation are future art/gameplay work.

### Building Ports, Read-Only Snap Transforms & Persistent Links — 08.3A–08.3D

- `scenes/buildings/test_extractor.tscn` now has an `OutputPort` (`ItemPortComponent`): local `(0, 0.5, -1.0)`, local Y rotation 0°, `direction = OUTPUT`, inventory `../InventoryComponent`, no producer reference.
- The existing Test Smelter retains its recipe-filtered `InputPort` and manufactured-product `OutputPort`; Test Storage still has **no dedicated physical input/output ports**.
- `ConveyorBuildingSnap.get_preview_transform(port, belt)` computes a read-only transform for building OUTPUT → belt INPUT or belt OUTPUT → building INPUT, accounting for building rotation and port/belt occupancy. This helper is **not yet wired into `WorldInteraction` Build Mode**.
- `ItemPortComponent.connected_conveyor` and `ConveyorSegment.input_building_port`/`output_building_port` hold reciprocal runtime links. `ConveyorSegment.try_connect_building_port()` checks roles, tree validity, inventory ownership/policy where applicable, strict endpoint alignment, and occupied ends. Existing belt-to-belt connection code rejects conflicting machine links.
- `disconnect_building_port()`, expanded `disconnect_all()` and the `ItemPortComponent._exit_tree()` callback clean up corresponding references when one endpoint is removed. Connection creation/removal alone does not transfer cargo.

### Loading, Unloading & Automatic Timing — 08.3E

- `ConveyorBuildingTransfer.try_load_into_belt()` loads one available `ItemDefinition` unit from the physically linked building OUTPUT through its real inventory into an empty belt. It rechecks reciprocal ownership, current endpoint geometry, quantity and capacity. For mixed-output inventories it currently chooses the first eligible dictionary entry; deliberate prioritization/filtering is pending.
- `ConveyorBuildingTransfer.try_unload_from_belt()` transfers one unit from the final belt to the physically linked building INPUT only if `ItemPortComponent.can_accept_item()` approves. `RECIPE_INPUTS` matches the active producer recipe; `ANY_ITEM` remains the proposed universal-storage policy. Unsupported items and full inventories remain blocked on the belt.
- `ConveyorTransportTimer._process(delta)` first attempts a generic building-output load **only when the belt is empty**, resetting travel progress on a successful load. Its `advance_transport(delta)` attempts a connected downstream belt first, or an attached building input after the travel interval. Successful transfers reset progress; blocked transfers retain the item and completed progress.
- Transfer helpers are safe for **physical inventory handoffs**, but their direct manual invocation is distinct from the timer-controlled travel cadence. One-item-per-segment capacity and 1.0-second default remain initial balance choices.

### Full Extractor → Conveyor → Smelter Integration — 08.3F-1

`tests/conveyor_physical_factory_test.tscn` instantiates real Extractor, three ConveyorStraight segments, and a real Smelter, computes/commits reciprocal endpoint links, seeds **two Test Ore** into the Extractor inventory, advances conveyor timers and the real `ProducerComponent` manually, and verifies **two ore become one Test Ingot**. Production waits for the second ore; final ore-equivalent accounting and cargo emptiness pass. The test disables resource extraction and both temporary proximity logistics components so they cannot interfere. This is an **isolated code-configured route**, not a player-built live factory or a test of an actual ore deposit.

### Chat 08 Test Evidence (Second Milestone)

| Isolated scene | Reported result |
| --- | --- |
| `conveyor_cargo_visual_test.tscn` | 6/6 |
| `conveyor_corner_cargo_visual_test.tscn` | 8/8 |
| `extractor_output_port_test.tscn` | 7/7 |
| `conveyor_building_snap_test.tscn` | 10/10 (expanded from seven) |
| `conveyor_building_connection_test.tscn` | 8/8 |
| `conveyor_building_loading_test.tscn` | 9/9 |
| `conveyor_building_unloading_test.tscn` | 10/10 |
| `conveyor_automatic_unloading_test.tscn` | 9/9 |
| `conveyor_automatic_loading_test.tscn` | 10/10 |
| `conveyor_physical_factory_test.tscn` | 9/9 |
| **Second milestone subtotal** | **86/86** |

With the earlier **44/44**, Chat 08 has **130/130 reported checks across separately run, non-duplicated test suites**, plus several additional repeated regression runs. The developer confirmed the final physical factory test passed 9/9 and pushed the new source to GitHub `main`. **No unified suite execution, GitHub CI run, or final live-game machine-to-belt snap demonstration is claimed.**

### Historical 08.3F boundary and subsequent update

At the **earlier** Chat 08.3F checkpoint, the machine-port preview was tested only in isolated scenes and universal Storage ports were still pending. **That is no longer the current state.** The player now builds port-connected storage/machine routes, directional belts, missing and existing corners, short fractional straight connectors and offset L-shaped segments. Two dedicated 1×1 routing buildings are buildable.

### Current construction and transport architecture (Chat 08.3G–08.3K)

| Layer | Primary scripts/resources | Responsibilities |
|---|---|---|
| Grid and data | `factory_grid.gd`, `building_definition.gd` | Shared 1-unit grid; odd-size integer origins, even-size half-tile origins; rotated footprints and grid-aligned ports |
| Construction | `world_interaction.gd`, `conveyor_building_placement_snap.gd` | Cursor preview, building-to-belt and belt-to-building linking, placement collision/occupancy, protected commit and demolition |
| Conveyor graph | `conveyor_segment.gd`, existing endpoint/discovery/connection, dual-port and bridge utilities | Directed one-input/one-output belt links, in-place source/receiver turns, existing/missing-corner joining |
| Nonstandard geometry | `conveyor_fractional_bridge.gd`, `conveyor_offset_corner_bridge.gd`, `conveyor_corner_visual_mesh.gd` | Real short straight and variable-leg perpendicular belts with appropriately sized mesh, collision and selection regions |
| Timing and visuals | `conveyor_transport_timer.gd`, `conveyor_path_motion.gd`, `conveyor_cargo_visual.gd` | One buffered item per segment; path-length-scaled travel duration; local-space visual interpolation along straight and L paths |
| Building ports | `item_port_component.gd`, `conveyor_building_transfer.gd` | Persistent physical port links, matching input/output direction, recipe filters, capacity and safe transfer |
| 3→1 Merger | `conveyor_merger_component.gd`, `conveyor_merger_building.gd`, `conveyor_merger.tscn` | Three separately buffered physical inputs, 1-unit output buffer, round-robin arbitration, per-lane counts and demolition safety |
| 1→3 Splitter | `conveyor_splitter_component.gd`, `conveyor_splitter_building.gd`, `conveyor_splitter.tscn` | One physical input, three independently buffered outputs, connected-output round-robin distribution and backpressure |
| Debug HUD | `production_debug_hud.gd` | Port connection status, per-lane buffers, completed transfers, next-lane selection and full-output diagnosis |

**Source/receiver corner distinction:** Conversion may turn an existing straight on its available input side or output side, provided its pre-existing building or belt link stays intact. A normal belt never accepts multiple sources. A multi-input join requires the Merger building.

**Transaction and obstruction constraints:** Discovery/ghost previews do not mutate permanent belts. Permanent links are revalidated before commit. Occupied ports, incompatible directions, intervening collision bodies and full buffers reject or defer transfer rather than destroying cargo. Cargo-bearing belts and filled routing buildings are protected from player demolition.

**Live evidence:** Splitter debug counters showed **A=5, B=4, C=4 (total 13)** in a single main-game session, with three outputs physically connected. Fractional connectors were visibly filled and cargo speed reported consistent after path-length correction. Merger 3-way physical hookup was observed; live `From A/B/C` progression is the remaining acceptance gate. Historical suites are separately reported, not consolidated CI.

## Current Factory Data Flow

Current player-built flows use explicit directional connections:

```text
World ore deposit → Test Extractor → Conveyor(s)
                                    → 1×1 Merger (up to 3 IN / 1 OUT)
                                    → Storage → Smelter → Output Conveyor
                                    → 1×1 Splitter (1 IN / up to 3 OUT)
                                    → Destination Storage
```

This is a **capability diagram**, not a claim that every arrow was exercised simultaneously in one recorded live test. The Smelter recipe remains **2 Test Ore → 1 Test Ingot**, with separate input/output buffers. The existing Chat 05/06 proximity-transfer components are retained as compatibility scaffolding; their current scene enablement must be checked before attributing every observed item transfer solely to belts.

**Performance/throughput:** Merger lanes are served fairly when output capacity permits. Three active incoming belts do not imply three times the throughput of one output belt; backpressure can legitimately hold ore in incoming buffers. Splitter routes one item at a time toward available outputs, and will retain buffered items if all output lanes are full or disconnected.

See [CHAT_08_FINAL_REGRESSION.md](CHAT_08_FINAL_REGRESSION.md) for the current run list and remaining live acceptance checks.

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

`production_debug_hud.gd` reads diagnostics from the selected object's components and refreshes them while selected:

- **Resource node:** deposit name, item, remaining/starting supply or infinite supply.
- **Extractor:** component-owned `extraction_status`, detected resource, stored ore, 50-unit inventory/capacity, extraction logistics status and transfer telemetry.
- **Storage:** 200-unit capacity, total stored quantities, and per-item contents.
- **Smelter:** recipe name, `production_status`, required input amounts and quantities, separate input (50) and output (100) inventory totals, and finished ingot quantities.
- **Merger:** Input A/B/C and output queue levels, port connection status, completed transfer counts `From A/B/C`, current lane and backpressure.
- **Splitter:** Input and output A/B/C queues, connectivity, `To A/B/C` counts, next lane and blocked-output status.
- **Other/non-producing objects:** neutral recipe or default selection information.

The shared `ActivityProgressBar` is a `ProgressBar` under `ProductionDebugHUD/InfoPanel/PanelMargin/InfoContent`, alongside `InfoLabel`. It displays:

- `ProducerComponent.production_progress / recipe.production_time × 100` for manufacturing;
- `ExtractorComponent.extraction_timer / extraction_interval × 100` for extraction.

The bar reads gameplay-owned timers and statuses; the HUD **never moves resources**. Blocked machines show 0% and an explanatory status; storage, deposits, and cleared selections hide the bar. This is still a debug/player-information prototype, not a finalized machine management screen.

---

## Current Architectural Boundaries

**Current implemented prototype (through 08.3G-3K):** Shared grid construction; physical extractor/storage/smelter ports; directional timed belts; automatic corners and both existing-end conversion types; two-ended and fractional/offset bridges; path-length-based cargo speed; 1×1, four-sided 3→1 Merger and 1→3 Splitter; and their bounded inventory/throughput feedback. Developer-reported isolated Godot suites for shared-grid, Merger and Splitter passed after the 1×1 redesign. These do **not** constitute a single unified CI run.

**Still pending:** Live Merger throughput counters for all three actively supplied inputs, backpressure recovery observation, final combined regression, explicit confirmation of a deposit-driven physical ore→ingot→destination route independent of legacy proximity transfers, safe recovery of cargo during destructive events, finalized slot/stack tiers, save/load, item-specific visuals, ammunition production, enemies/defense, power/fuel and larger-world performance.

**Safety:** Do not delete established proximity logic until item conservation can be verified with physical movement alone. Do not classify a Merger with a full output buffer as broken simply because one input temporarily stops. Full acceptance criteria live in [CHAT_08_FINAL_REGRESSION.md](CHAT_08_FINAL_REGRESSION.md).

## Architectural Principles

Industrial Warfare currently follows these rules:

1. Keep interaction, data, runtime behavior, and UI responsibilities separate.
2. Prefer reusable components over large monolithic building scripts.
3. Prefer custom `Resource` data over hard-coded per-building logic.
4. Add only the complexity required by the current milestone.
5. Regression-test established systems after architectural changes.
6. Keep placeholder visuals acceptable while gameplay systems are being proven.
