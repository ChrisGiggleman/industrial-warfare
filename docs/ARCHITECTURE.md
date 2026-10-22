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
- `1`, `2`, `3`, and `4` select Test Extractor, Large Building, Test Storage, and Test Smelter respectively.
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

## Current Factory Data Flow

**Implemented:** one finite or infinite resource deposit can feed a Test Extractor; extracted ore moves to nearby Test Storage, and nearby Test Smelters pull ore into their independent input inventories. After each valid 2-second cycle, the smelter consumes 2 ore and deposits 1 ingot into its output inventory.

The working prototype uses direct proximity transfers rather than physical conveyance. There is currently **no automatic finished-ingot output from the smelter to downstream storage or other machines**, and the prototype does not yet implement power, fuel, or conveyor routing.

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

`production_debug_hud.gd` reads diagnostics from the selected object's components and refreshes them while selected:

- **Resource node:** deposit name, item, remaining/starting supply or infinite supply.
- **Extractor:** component-owned `extraction_status`, detected resource, stored ore, 50-unit inventory/capacity, extraction logistics status and transfer telemetry.
- **Storage:** 200-unit capacity, total stored quantities, and per-item contents.
- **Smelter:** recipe name, `production_status`, required input amounts and quantities, separate input (50) and output (100) inventory totals, and finished ingot quantities.
- **Other/non-producing objects:** neutral recipe or default selection information.

The shared `ActivityProgressBar` is a `ProgressBar` under `ProductionDebugHUD/InfoPanel/PanelMargin/InfoContent`, alongside `InfoLabel`. It displays:

- `ProducerComponent.production_progress / recipe.production_time × 100` for manufacturing;
- `ExtractorComponent.extraction_timer / extraction_interval × 100` for extraction.

The bar reads gameplay-owned timers and statuses; the HUD **never moves resources**. Blocked machines show 0% and an explanatory status; storage, deposits, and cleared selections hide the bar. This is still a debug/player-information prototype, not a finalized machine management screen.

---

## Current Architectural Boundaries

**Implemented through Chat 07's first checkpoint:** All prior Chat 06 systems, plus per-machine recipe allowlists, guarded recipe switching, active-recipe input-item eligibility, and recipe-gated temporary storage-to-smelter delivery. All 21 new recipe tests and the earlier 36 manufacturing checks were reported passing, together with inventory-transfer and in-game regressions.

**Planned:** the player-facing recipe selector, dynamic/multi-ingredient material intake, actual input-port admission with capacity limits, universal slot-and-stack small/medium/large storage, physical conveyor segments and ports, dedicated splitter/merger buildings, ammunition production/defense, power/fuel, construction costs, research/unlocks, save/load, zombies/defense, and finalized UI. The temporary proximity-transfer path remains in use until belt-driven logistics are proven.

---

## Architectural Principles

Industrial Warfare currently follows these rules:

1. Keep interaction, data, runtime behavior, and UI responsibilities separate.
2. Prefer reusable components over large monolithic building scripts.
3. Prefer custom `Resource` data over hard-coded per-building logic.
4. Add only the complexity required by the current milestone.
5. Regression-test established systems after architectural changes.
6. Keep placeholder visuals acceptable while gameplay systems are being proven.
