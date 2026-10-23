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

---

## 2026-10-18 — Chat 04: Resource Nodes & Extraction Foundation

Chat 04 replaced the small building's temporary free-output recipe with real, location-dependent resource extraction. Earlier Chat 03 producer tests remain recorded above as history; the current Test Extractor uses an `ExtractorComponent`, not the original autonomous extraction recipe.

### Resource-Node Data and World Scene

Created:

- `res://scripts/data/resource_node_definition.gd` — `ResourceNodeDefinition` data schema.
- `res://data/resource_nodes/test_ore_deposit.tres` — Test Ore Deposit definition, linked to `Test Ore`.
- `res://scripts/components/resource_node_runtime.gd` — `ResourceNodeRuntime` instance state and extraction API.
- `res://scenes/resource_nodes/TestOreDeposit.tscn` — selectable test deposit with mesh, collision, and runtime component.

Definitions contain an ID, display name, description, `ItemDefinition`, `infinite_resource` flag, and `starting_amount`. Runtime nodes track `remaining_amount` and provide `extract(amount) -> int` so callers receive only the quantity actually available.

Tested **infinite deposits** (no depletion) and **finite deposits** (supply decreases and production stops at zero). The prototype Test Ore Deposit is configured for infinite supply by default; the starting amount is retained for finite-mode testing.

### Extractor Component and Inventory

Created `res://scripts/components/extractor_component.gd`.

The small test building now has:

- `BuildingRuntime` and its own `InventoryComponent`.
- `ExtractorComponent` with configurable extraction amount and interval (prototype defaults: 1 unit / 1 second).
- `ExtractionArea` (`Area3D`) using a 2.5-unit-radius detection shape and Layer 2 collision mask.

The component identifies nearby deposits through their `ResourceNodeRuntime`, requests resources from `extract()`, and adds the returned amount to the building's inventory. Without an in-range deposit, the extractor does not produce resources. Different placed extractors continue to hold independent inventories.

### Extractor-Specific Placement Rule

Updated `res://scripts/world_interaction.gd` so physical occupancy and resource access are separate checks:

- Physical building collision shapes are tested against placement blockers (Layer 3).
- A placement ghost with `ExtractorComponent` additionally queries its extraction shape against resource-node colliders (Layer 2).
- Extractor placement is red/invalid without a reachable resource deposit and green/valid when one is in range.
- Buildings without `ExtractorComponent`, including Test Building Large, remain placeable without ore.

The placement ghost still has gameplay processing disabled so previews do not run extraction.

### Debug HUD and Selection

Extended `res://scripts/production_debug_hud.gd`:

- Selected deposits show resource name and infinite supply or finite remaining/starting supply.
- Selected extractors show building name, extractor type, status, resource name, and live inventory quantity.
- Status differentiates **No Resource In Range**, **Extracting**, and **Resource Depleted** where applicable.
- Existing non-extractor building and empty-selection behavior remains available.

The resource deposit retains normal selectable-object highlighting.

### Prototype Naming and Asset Cleanup

Renamed the small prototype into a named extractor:

- `scenes/buildings/test_building.tscn` → `scenes/buildings/test_extractor.tscn`
- `data/buildings/test_building.tres` → `data/buildings/test_extractor.tres`
- Scene root `TestBuilding` → `TestExtractor`
- Building ID `test_extractor`, display name **Test Extractor**, category **Extraction**

Removed the obsolete `res://data/recipes/prototype_extraction.tres` asset after reference checks and a successful gameplay test. Kept the reusable `ProducerComponent`, `ProductionRecipe`, and `ItemAmount` framework for future manufacturing machines.

### Troubleshooting and Fixes

- **Unexpectedly large no-build area:** The placement ghost originally treated the extractor's spherical `ExtractionArea` collision as a physical building footprint. Changed footprint tracking to include only `CollisionShape3D` nodes belonging directly to `PhysicsBody3D`; detection-area shapes are not placement blockers.
- **Missing placement validator during editing:** Restored `_is_placement_clear()` after an intermediate script edit removed it.
- **GDScript indentation errors:** Corrected mixed/incorrect indentation around the extractor rule and ghost-color branches; retained tabs throughout the script.

Detailed fixes belong in `TROUBLESHOOTING.md`.

### Final Regression Test — Passed

Verified together:

- WASD panning and mouse-wheel zoom.
- Normal selection, highlight, and HUD updates.
- Build Mode, building-slot switching, rotation, valid/invalid ghost feedback, and placement.
- Extractor blocked away from ore and placeable near a deposit.
- Extraction transfers real resources to the placed extractor inventory.
- Infinite supply information and finite-depletion behavior.
- Large Test Building remains usable without nearby deposits.
- Demolition and protection of non-player-built objects.
- No new Godot debugger errors in the final gameplay check.

### Milestone Status

**Chat 04 — Resource Nodes & Extraction Foundation: Complete.**

Next planned work: basic inventory storage and simple item transfer/logistics, followed by recipe inputs, further factory systems, and the first zombie/defense prototype.

---

## 2026-10-20 — Chat 05: Storage & Basic Factory Logistics

**Milestone status: Complete.** Gameplay implementation and final manual regression tests passed in Godot 4.6.2 Stable.

### Inventory Capacity & Safe Item Accounting

- Extended `InventoryComponent` with a shared item-count `max_capacity` (0 = unlimited), `get_total_amount()`, `get_available_space()`, and `is_full()`.
- `add_item(item, amount) -> int` accepts only the quantity that fits and returns the actual amount stored.
- Made `ExtractorComponent` check free inventory capacity *before* extracting from finite deposits; full inventories no longer consume ore.
- Implemented `InventoryComponent.transfer_to(destination, item, amount) -> int` with source availability checks, destination capacity limits, partial transfers, self-transfer rejection, and rejected-item restoration.

### Dedicated Storage Building

- Added `scenes/buildings/test_storage.tscn` and `data/buildings/test_storage.tres`.
- Reused `BuildingRuntime`, `InventoryComponent`, selectable-object highlighting, placement collision, rotation, and demolition.
- The storage prototype has a rectangular 1.0 × 1.0 × 2.8 mesh/collision footprint and default capacity **200**.
- Added `logistics_storage` to the actual storage building root; retained `selectable` and `player_built`.
- Registered storage in `WorldInteraction.buildable_definitions`; key **3** selects storage, alongside key **1** Test Extractor and key **2** Large Building.
- Updated the Build HUD to show and highlight all three options.

### Automatic Logistics

- Added `scripts/components/logistics_transfer_component.gd` to Test Extractor as a sibling of its inventory/extractor components.
- Configured `transfer_item` (Test Ore), `transfer_amount = 5` per cycle, `transfer_interval = 1.0` second, and `transfer_range = 5.0` world units.
- The component selects the nearest eligible `logistics_storage` group member by **building-origin distance**, ignoring full destinations, missing inventories, queued-for-deletion nodes, and disabled placement ghosts.
- Nearby inventories receive up to the configured amount each cycle using `transfer_to()`; actual throughput depends on ore availability.
- Status tracking reports `Initializing`, `Transferring`, `Waiting for Resources`, or `No Eligible Storage`, with last attempt and last successful transfer quantities. `No Eligible Storage` currently covers both out-of-range and full storage.

### Production Debug HUD

- Added storage totals, capacity used, and an `INVENTORY CONTENTS` listing by `ItemDefinition`.
- Added extractor inventory capacity/full status and a `LOGISTICS STATUS` section with configured maximum transfer rate, latest attempt amount, and last successful amount.
- Preserved resource-node remaining/starting amounts and existing selection behavior.
- The `Status: Extracting` line currently indicates a valid ore source, not necessarily active mining when inventory is full; this wording is a future refinement.

### Tests and Observed Results

- An isolated Godot inventory test passed partial transfer, full destination, empty source, and invalid/self/zero-quantity transfer cases.
- Gameplay checks passed extraction, proximity-limited storage discovery, timed transfers, HUD updates, blocked transfers at storage capacity, extractor accumulation when storage is full, and existing placement/rotation/selection/demolition behavior.
- **Final finite-resource conservation test:** starting deposit **500**, remaining deposit **250**, extractor inventory **50/50**, storage inventory **200/200**. Total: **250 + 50 + 200 = 500**.
- The committed `data/resource_nodes/test_ore_deposit.tres` is currently set to a **finite 500-unit** test deposit; this is a testing configuration, not a finalized economy choice.
- Storage capacity was restored to **200** after short capacity-limit tests.

### Scope and Follow-Ups

This is a proximity-based, direct inventory transfer prototype—not a visible conveyor network. Conveyor belts, routing/ports, multi-machine flow, power, production input consumption, and refined logistics statuses remain future work.

The tested source/scenes were committed and pushed to `main` before this documentation update.

---

## 2026-10-20–21 — Chat 06: Production Inputs & First Manufacturing Chain

**Milestone status: Complete.** First automated ore-to-ingot manufacturing chain implemented and tested in Godot 4.6.2 Stable. Gameplay changes were committed and pushed to `main` before this documentation entry.

### Architecture Review and Decisions

- Preserved the existing data-driven `BuildingDefinition`, `BuildingRuntime`, `ItemDefinition`, `ItemAmount`, `ProductionRecipe`, and `InventoryComponent` architecture rather than introducing a parallel manufacturing system.
- Chose **separate input and output inventories** for manufacturing machines before implementation, preventing raw materials and finished products from competing for the same capacity.
- Configured the Test Smelter with `InputInventory` capacity **50** and `OutputInventory` capacity **100**, both using independent instances of the existing `InventoryComponent`.
- Agreed that all machines that extract or manufacture items should expose understandable operating statuses and a reusable, live activity progress indicator. Pure storage buildings have no processing progress bar.

### Safe Recipe-Based Manufacturing

Extended `scripts/components/producer_component.gd` with:

- `input_inventory` and `output_inventory` references for independent material buffers.
- `has_required_inputs()` to validate nonempty recipes, required quantities, and duplicate ingredient entries without consuming items.
- `can_store_recipe_outputs()` to reject missing/invalid outputs and ensure **all** output units fit within output inventory capacity.
- `try_complete_recipe_cycle()` to check inputs and output space, consume recipe ingredients, create finished products, and report success only for a complete cycle.
- `_rollback_recipe_cycle()` to attempt recovery if a synchronous removal or output addition unexpectedly fails; normal and blocked paths passed tests. Exceptional rollback-failure scenarios remain a future hardening area.
- A guarded timed production loop that advances only when inputs and output space are available; otherwise it resets progress and exposes statuses such as `Waiting for Inputs` or `Output Blocked`.
- Removal of the obsolete output-only production method that could generate items without consuming inputs.

For the first recipe, `data/recipes/test_smelting.tres` transforms **2 Test Ore → 1 Test Ingot** in a **2-second** production cycle. The new permanent output item is `data/items/test_ingot.tres`.

### Test Smelter Building

Added:

- `scenes/buildings/test_smelter.tscn`
- `data/buildings/test_smelter.tres`

The Test Smelter uses reusable selection, collision, rotation, placement, and demolition behavior, plus these child components:

- `BuildingRuntime`
- `InputInventory` (50)
- `OutputInventory` (100)
- `ProducerComponent`, with references to the smelting recipe and both inventories
- `LogisticsInputComponent`

Registered the smelter as construction option **4** by adding `select_building_4` to `project.godot`, adding the definition to `WorldInteraction.buildable_definitions`, and extending the Build HUD to render and highlight `[4] Test Smelter`. Existing slots 1–3 continue to work.

### Storage-to-Smelter Input Logistics

Implemented `scripts/components/logistics_input_component.gd` as a separate reusable component so the existing extractor-to-storage transfer logic remains intact.

- Searches the `logistics_storage` group for the nearest eligible stocked storage building using building-origin distance.
- Ignores out-of-range candidates, invalid inventories, deletion-queued objects, and disabled placement ghosts.
- Requests the configured `ItemDefinition` from nearby storage via the established `InventoryComponent.transfer_to()` method; it does not create items.
- Uses default configuration: Test Ore, **up to 5 units per attempt**, **1-second interval**, **5-world-unit range**, and a **10-ore input buffer target** (independent of the physical 50-unit input capacity).
- Reports transfer status and recent quantity for debugging.

**Working automated flow:** finite Test Ore Deposit → Test Extractor → Test Storage → Test Smelter input → timed smelting → Test Smelter output (Test Ingots). This is proximity-based, direct inventory movement, not a visual conveyor system.

### Production and Extraction HUD

Enhanced `scripts/production_debug_hud.gd` and `scenes/ui/production_debug_hud.tscn`:

- Selected smelters show recipe, live `production_status`, input ingredient quantities and requirements, input capacity, output item quantities, and output capacity.
- Corrected the original producer HUD assumption that all buildings store items in a child named `InventoryComponent`; smelter results now come from `OutputInventory`.
- Added `InfoContent` and one shared `ActivityProgressBar` under the HUD panel.
- Manufacturing progress reads `ProducerComponent.production_progress / recipe.production_time`.
- Extraction progress reads `ExtractorComponent.extraction_timer / extraction_interval`.
- The indicator resets to 0% when blocked and is hidden for storage, resource deposits, and no selection.

Updated `scripts/components/extractor_component.gd` with an explicit `extraction_status` and timer gating for no deposit, depletion, full inventory, missing data, and invalid intervals. The extractor HUD now displays the component's true status instead of claiming `Extracting` while its inventory is full.

### Tests and Verified Results

Added standalone Godot regression suites:

| Test scene | Result |
| --- | --- |
| `tests/recipe_input_availability_test.tscn` | **8/8 passed** |
| `tests/recipe_output_capacity_test.tscn` | **11/11 passed** |
| `tests/manufacturing_transaction_test.tscn` | **9/9 passed** |
| `tests/timed_manufacturing_test.tscn` | **8/8 passed** |

**Total: 36/36 Chat 06 assertions passed.** Existing Chat 05 inventory-transfer tests (four test groups) also passed during final regression testing.

Gameplay verification also covered key 4 selection, placement, rotation, overlap blocking, selection highlight, demolition highlight/removal, automatic resource transfers, ingot accumulation, and the shared activity progress bar for both extractor and smelter.

**Output-full safeguard:** temporarily set the smelter output capacity to **2**. The HUD showed `Output Blocked`, **2/2** ingots, **10/50** input ore, and **0%** progress. Inputs and outputs remained unchanged while blocked. The output capacity was subsequently restored to **100** and saved.

**Resource conservation:** in a verified single-deposit, finite-500-ore test, **236 remaining in deposit + 50 in extractor + 200 in storage + 10 in smelter input + 2 ingots × 2 ore each = 500 ore equivalents**. A later final end-to-end test was reported successful, though its exact terminal inventory counts were not recorded in chat. No loss or duplication was observed in these tests.

### Troubleshooting and Lessons

- **Placed smelter selected but did not turn gold/red:** `selectable_object.gd` was attached, but the exported `Selection Mesh` reference was unset. Assigning the `BuildingMesh` child resolved normal selection and demolition-hover highlighting.
- **HUD continually reported 0 ingots despite active smelting:** its original lookup used `InventoryComponent`, whereas the smelter stores finished products in `OutputInventory`. Updating the HUD inventory lookup exposed the real count.
- **Build HUD lacked option 4 / did not highlight selection:** registering the input action alone was insufficient; the Main scene definition array and `Building4Label` selection handling also needed updates.
- **Extractor displayed `Extracting` at 50/50:** replaced duplicated, inferred HUD status strings with the component-owned `extraction_status`.
- **Commit hygiene:** removed trailing whitespace before staging and excluded an accidentally created untracked file containing a Git diff summary. The tested gameplay commit was pushed successfully; local Git status was then confirmed clean.

### Scope and Follow-Ups

**Implemented:** first real automated manufacturing recipe, independent machine input/output buffers, buffer-limited input logistics, reusable manufacturing/extraction progress, and end-to-end conservation testing.

**Not implemented yet:** finished-product export from the smelter, dedicated conveyors/inserters/ports, advanced multi-input routing, energy and fuel costs, production upgrades, a finalized player-facing machine panel, or defense/horde mechanics. These remain subsequent development milestones.

---

## 2026-10-22 — Chat 07: Recipe Selection & Recipe-Aware Input Logistics (First Checkpoint)

### Architectural Direction and Scope

After Chat 06, confirmed the intended gameplay is **physical conveyor-based** factory automation feeding ammunition manufacture and colony defense, rather than proximity-based “magic transfers.” The long-term design in [GAME_VISION.md](GAME_VISION.md) calls for selectable manufacturing recipes that determine allowed inputs; universal small, medium, and large storage with slots/stacks; one automatic-turn conveyor placement tool; and **dedicated placeable splitter and merger buildings**. The first zombie-colony world includes structures and settlements associated with enemy spawning; larger logistics systems and additional planets remain later design work.

This Chat 07 checkpoint deliberately implements **recipe rules first**, preserving the short-range logistics chain until belt transport has tested replacements.

### Gameplay Implementation (Steps 07.2A–07.2D)

- `ProducerComponent.available_recipes`: Inspector-configurable list of recipes supported by a machine; the existing `recipe` field continues to represent the active recipe. The Test Smelter registers `test_smelting.tres` in its available list.
- `ProducerComponent.select_recipe(new_recipe)`: validates allowlist, non-null selection, positive production time, and nonempty ingredient/output collections; avoids changing an already-selected recipe. A real change is allowed only with an existing **empty** input inventory. It preserves stored finished goods, resets production progress, and records `Recipe Changed`.
- `ProducerComponent.accepts_input_item(item)`: non-mutating check for a valid, positive-quantity ingredient in the active recipe. Eligibility automatically changes when the recipe changes; this method does not move items or check available space.
- `LogisticsInputComponent.producer_component`: optional-on-disk but **required for working transfers**; linked in the Test Smelter scene. Delivery stops safely with `Producer Missing` or `Item Not Required by Recipe` when the reference/ingredient is incompatible. The original Test Ore transfer rate, buffer and manufacturing logic were retained.
- Changes were edited and tested locally in Godot 4.6.2 and pushed successfully by the developer to GitHub `main`.

### Tests and Verification

| Scene / check | Reported result |
| --- | --- |
| `tests/recipe_selection_test.tscn` | **10/10 passed** |
| `tests/recipe_input_acceptance_test.tscn` | **6/6 passed** |
| `tests/recipe_logistics_acceptance_test.tscn` | **5/5 passed** |
| Chat 06 recipe input, output capacity, manufacturing transaction, and timing tests | **36/36 passed** |
| Chat 05 inventory transfer regression | **Passed** (existing groups) |
| Main game: extraction, storage-to-smelter supply, smelting, HUD, placement and demolition | **Passed** |

**Total of 21 new Chat 07 assertions/groups and 36 earlier manufacturing assertions reported passing.** This checkpoint added no resource-conservation failure or game regression in the user-run tests. Tests were performed in the Godot editor, not in GitHub CI.

### Troubleshooting and Cleanup

- An isolated recipe-aware logistics test initially printed automatic transfer messages *after* its PASS banner. Resolved by disabling both the logistics and producer nodes' frame processing after scene insertion, manually invoking transfer attempts, and queueing temporary buildings for deletion before final results.
- A subsequent GDScript parser error (`Used space character for indentation instead of tab`, including around line 83) came from space indentation inserted into a tab-indented test script. Replacing affected leading whitespace with one tab inside `_ready()` resolved it; the test reran successfully with **5/5** passes and no trailing transfer messages.

### Current Boundaries / Next Work

- The Test Smelter still has **one configured permanent smelting recipe**; no production selection UI or additional persistent ore/ammunition recipes have been added.
- Ingredient eligibility is separate from physical insertion. Dynamic or multi-ingredient conveyor admission, stack/slot capacity, and input/output port behavior are still to be designed and tested.
- Short-range transfers are temporary scaffolding, not final gameplay logistics. Finished ingots remain in the smelter output inventory until belt transport and destinations are implemented.
- Next focus: review and incrementally design machine input/output ports and admission/hand-off contracts for later conveyors, while retaining current regressions and the First Night ammunition-and-defense objective.

---

## 2026-10-22 — Chat 07: Physical Port Foundation & Logical Handoffs (Second Checkpoint)

### Implementation (Steps 07.3A–07.3E)

- Created reusable `scripts/components/item_port_component.gd` (`ItemPortComponent extends Marker3D`) with `INPUT`/`OUTPUT` directions, recipe-specific vs universal item acceptance, and explicit inventory and optional producer references.
- Implemented **read-only** `can_accept_item()` (recipe eligibility, full-request available capacity, input role and correct inventory) and `can_provide_item()` (output role, item availability and output-inventory identity).
- Attached sibling `InputPort` and `OutputPort` `Marker3D` nodes to `scenes/buildings/test_smelter.tscn`, positioned on opposite X faces at local `(-0.85, 0.5, 0)` and `(0.85, 0.5, 0)`; oriented Y `+90°` and `-90°`. Bound InputPort to `InputInventory` and OutputPort to `OutputInventory`, each referencing `ProducerComponent`.
- Added `try_transfer_to_port()` to guard destination role, self-transfer, ingredient acceptance, source availability, requested capacity, then delegate accounting to `InventoryComponent.transfer_to()`. Failed prechecks return zero without changing inventories.
- Proved the complete *manual* workflow on a real Test Smelter: initial six ore in source, two ore supplied per cycle, two smelting cycles produce two ingots; one goes to capacity-1 storage and a second remains in the output buffer when storage is full; source retains two ore. Total **6 ore equivalents** conserved.

### Validation and Regression Checkpoint

| Test scene or coverage | Developer-reported result |
| --- | --- |
| `item_port_foundation_test.tscn` | **7/7 passed** |
| `item_port_integration_test.tscn` | **8/8 passed** |
| `item_port_transfer_test.tscn` | **7/7 passed** |
| `item_port_real_smelter_test.tscn` | **7/7 passed** |
| Earlier Chat 07 recipe selection / acceptance / logistics | **21/21 passed** |
| Earlier Chat 06 manufacturing suite | **36/36 passed** |
| Inventory transfer regression | **Passed** |
| Main extractor → storage → smelter production, interactions and HUD | **Passed** |

**29/29 new port tests**, **21/21 earlier Chat 07 recipe tests**, and **36/36 previous manufacturing checks**: **86 checks** across those named groups, in addition to inventory-transfer and gameplay regressions. These are reported local Godot 4.6.2 test runs, not GitHub Actions results. The developer confirmed the port milestone gameplay/test files were pushed successfully to GitHub `main`.

### Architecture Decision and Boundaries

The port component currently exposes a safe **logical transfer**, not a physically connected network. There are no placed conveyors, connection/adjacency validation, route selection, belt throughput timing, storage slot/stack layout, or automatic ingot export from the smelter. Existing proximity transfers were intentionally retained in the playable prototype.

The next incremental development priority is **connection validation between oriented ports and future directional belt segments**, followed by test-first belt placement/connection and item movement. Dedicated splitters and mergers remain distinct planned placeable buildings. Ammunition manufacture feeding defensive structures and a zombie colony First Night remains the primary game loop objective.

