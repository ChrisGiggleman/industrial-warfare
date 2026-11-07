# Industrial Warfare — Development Log

This document tracks meaningful development milestones, design decisions, technical changes, testing, troubleshooting, and showcase-ready progress.

The development log intentionally summarizes completed milestones rather than recording every individual edit.

---

## 2026-11-07 — Timed Storage Physical Belt Delivery Regression

- User confirmed all **4/4 construction footprint and port** checks passed in Godot 4.6.2.
- Reviewed existing `ConveyorBuildingSnap`, `ConveyorTransportTimer`, `ConveyorTransportComponent`, and `ItemPortComponent`; retained the existing physical movement mechanisms.
- Added `tests/timed_storage_conveyor_delivery_test.tscn`: completed Storage accepts an aligned conveyor input, transports one Test Ore into Storage, preserves total source/belt/destination inventory, and cleans up connections on disconnect.
- Live gameplay logic remains unchanged. **All 6/6 checks passed locally in Godot 4.6.2 on 2026-11-07**, including physical connection, item delivery, conservation and disconnection. Advanced connection reservation during construction is a separate follow-up.

---


## 2026-11-07 — Construction Footprint and Port Readiness

- Accepted testing sandbox: 3/3 Godot checks and player confirmation of a nonattacking zombie in F6 sandbox play.
- Reviewed `ConstructionSite`, `ItemPortComponent`, and the existing 3D placement blocker mask.
- Added `tests/construction_footprint_ports_test.tscn` to verify the unfinished site's physical overlap, absence of inventory/ports during construction, and real Storage inventory/ports on completion.
- No game-system modifications: this test establishes the prerequisite for safe delayed conveyor connection. The next checkpoint will validate connecting physical belts and moving actual items.
- **Validation pending:** Four new Godot checks, then subsequent logistics tests.

---


## 2026-11-07 — Safe Factory Testing Sandbox

- Added `scenes/core/factory_testing_sandbox.tscn` for interruption-free factory testing. The green moving zombie remains visible but its processing is disabled, so it does not walk or melee attack in this scene.
- Enabled timed Test Storage construction in the sandbox. Normal `scenes/core/main.tscn` is unchanged and retains active zombie behavior and its existing construction settings.
- Added `tests/factory_testing_sandbox_test.tscn` with three tests checking disabled sandbox zombie, normal Main behavior, and retained build HUD/catalog. **3/3 passed** locally in Godot 4.6.2 (2026-11-07). Player additionally confirmed the sandbox runs as intended with the green zombie inactive.
- Run the sandbox scene directly with **F6**; run the normal Main scene using **F5**. Since this is a separate scene copy, synchronize it if Main receives future gameplay or scene changes.

---


### Timed Storage Controller Integration — Local Validation (2026-11-06)

- Godot confirmed **4/4** world-controller integration checks passed (default instant placement, nonoperational site, activation at 100%, invalid-definition rejection).
- Next validation is a controlled F5 session with `WorldInteraction.enable_timed_storage_construction` enabled temporarily in the Main scene Inspector. Keep the default false until regular placement and downstream conveyor cases are regression-tested.
- Only standalone Test Storage placement is supported; snapped-to-belt Storage still takes the original immediate-connection route.
- Manual F5 evidence (2026-11-06): blue construction site shown at 47%, then completed Storage building with IN/OUT port markers. Timed standalone build activation accepted visually; automated checks 14/14 passed across three scenes. Actual port cargo transfer after construction and site/conveyor collision compatibility remain future checks.


## 2026-11-06 — Construction Site and World Integration Follow-up

- Local Godot **4/4 ConstructionSite** checks passed, confirming footprint, pending state, delayed real Storage, preserved transform and ports.
- Added opt-in `WorldInteraction.enable_timed_storage_construction` (default false) and `storage_construction_seconds` to stage the first standalone Storage construction in the live controller. Existing Main and conveyor snap placement remain unchanged by default.
- Added `tests/timed_storage_placement_test.tscn` for world-controller integration checks; these have **not** been run locally yet.
- Next: pass the test, validate automatic placement and safe activation, then enable timed construction in F5.

---


## 2026-11-06 — Zombie-Planet Demo Focus and Construction Lifecycle Foundation

- Confirmed the immediate vertical slice: one zombie world with persistent factory growth, ammunition-fed defenses, and turret/wall-led territorial expansion. Planet-hopping and alternate enemy factions remain long-term campaign goals.
- Added `scripts/components/construction_lifecycle.gd`: isolated planned/constructing/complete state transitions, required duration, progress, remaining work, optional worker multiplier, and one-time completion signal.
- Added `tests/construction_lifecycle_test.gd` and `tests/construction_lifecycle_test.tscn` covering six construction-state and timing regression groups.
- The lifecycle model passed **all 6/6** local Godot regression checks (user-confirmed screenshot).
- Added `ConstructionSite` prototype and `tests/construction_site_test.tscn` to demonstrate a timed, reserved Storage footprint and delayed creation of an operational Storage building. This is isolated test-only integration pending Godot verification; main Build Mode is unchanged.
- The model is intentionally **not yet wired into live placement**: current buildings remain instantly constructed until isolated tests pass and gameplay-system shutdown/activation rules are implemented and validated.
- No main-scene, conveyor, hotbar, production, combat, or salvage behavior was changed. The construction test requires execution in Godot 4.6.2.

---


## 2026-11-05 — Phase 1G6: Building Catalog Expansion, Checkpoint 1

- Reviewed existing `BuildingDefinition.category` values, hotbar stable-ID assignment model, and implemented 1×1 Splitter/Merger routing components.
- Organized each Building Catalog slot dropdown by existing unlocked building categories, with nonselectable category separators. Empty option, assignment metadata, swapping, and Restore Defaults retain their original behavior.
- Added `res://tests/build_catalog_category_test.tscn` to validate grouping, selecting a grouped building, hotbar redraw, and restoring defaults.
- This is a **catalog presentation improvement only**. No new manufacturing recipes, logistics functionality, save files, or progression systems are introduced.
- **Validation complete (2026-11-06):** Godot 4.6.2 category regression passed all **3/3** checks. Player confirmed that the in-game M menu works and dropdown entries are grouped by building category. Checkpoint 1 accepted.

---


## 2026-11-04 — Phase 1G5: Visual Hotbar UI, Checkpoint 1

### Architecture
- Reused the existing nine-slot `BuildHotbarConfiguration` stable-ID model, WorldInteraction shortcut routing, and Building Catalog.
- Added `scripts/ui/build_hotbar_visual.gd` as a presentation-only view attached to `VisualHotbar` in the existing `build_hud.tscn`.
- Moved the visible build shortcuts into nine bottom-centered horizontal tiles. The previous text slot labels remain hidden but continue to update for existing regression compatibility.
- Each tile includes shortcut number, generated placeholder graphic, compact name, selection border, and tooltip.
- Icon textures are cached by building ID. Catalog swaps, empty assignments, locked buildings, selection changes, and Restore Defaults redraw the view via existing HUD synchronization.
- Build Mode visibility follows the original BuildPanel. No changes to placement, conveyors, combat, or save/load architecture.

### Testing
- New runnable scene: `res://tests/build_hotbar_visual_test.tscn` (six regression groups).
- Re-run `res://tests/build_hotbar_keyboard_integration_test.tscn` and `res://tests/build_hotbar_configuration_test.tscn` to check existing behavior.
- Manual checklist: enter Build Mode, inspect all nine icons, press 1–9, open M catalog and swap a selection, clear a slot, restore defaults, exit Build Mode, verify placement and conveyor corner behavior.
- **Verification status:** Code committed to GitHub. Godot runtime/regression tests await execution on the local Godot 4.6.2 installation.


### Manual Validation and Layout Follow-up (2026-11-05)
- Godot 4.6.2 visual hotbar regression: all six checks passed on the local machine.
- In-game screenshot confirmed the nine centered tiles, selected highlight, and customized assignment order.
- Manual conveyor/corner placement confirmed working by the player.
- Corrected BuildPanel's anchor preset to bottom-left (with explicit horizontal anchors) to address controls clipping at the left edge.
- **Pending:** verify left-side control panel positioning after pulling this final layout correction. No gameplay systems or save/load behavior changed.

### Deferred
- Production artwork and locked-tile research presentation.
- Per-saved-game assignments, which must be integrated with the main save/load design.

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

---

## 2026-10-24 — Chat 07: Straight Conveyor Geometry, Snapping and Placement (Third Checkpoint)

### Implemented Features

- Built LogisticsConnectionGeometry for independent world-space distance, facing and forward alignment tests.
- Added ConveyorStraight scene with BeltMesh and input/output Marker3D endpoints; item flow will be local +Z → -Z, but item movement is NOT implemented.
- Added ConveyorSegment previous/next links, strict 0.05-unit connect tolerance, and safe disconnect/scene exit cleanup.
- Implemented automatic snap-after and snap-before calculations, including nonmutating ghost preview transforms and occupied-endpoint guards.
- Added Conveyor Belt building definition, key 5 and HUD slot while preserving the original four buildings.
- Integrated nearest-compatible-endpoint search in WorldInteraction and permanent snapped placement that creates exactly one belt before returning to regular building logic.
- Added steel-gray placeholder material, selection and demolition visual methods, and separate Layer 2 Area3D input hitbox and Layer 3 placement-blocking body.

### Testing

| Scene | Developer-reported checks |
| --- | --- |
| logistics_connection_geometry_test.tscn | **8/8** |
| conveyor_alignment_test.tscn | **9/9** |
| conveyor_connection_state_test.tscn | **8/8** |
| conveyor_snapping_test.tscn | **5/5** |
| conveyor_snap_preview_test.tscn | **5/5** |
| conveyor_snap_before_test.tscn | **5/5** |

**40/40 conveyor checks passed.** The developer also confirmed successful real-game snap-before and snap-after placement, rotation, selection, demolition and unchanged factory manufacturing. The local milestone was pushed to GitHub main. These are Godot 4.6.2 editor tests, not a CI run.

### Bugs Resolved and Lessons

- An early failed ConveyorSegment cast assertion was caused by attaching the wrong script to the conveyor scene root. Attaching conveyor_segment.gd to ConveyorStraight resolved it.
- The conveyor mesh initially appeared dark; an explicit material fixed the appearance.
- Mouse selection/demolition was initially inaccurate due to collision shapes offset from the visible mesh. Values meant for Shape Size had been entered as node Transform Position. Correcting parent/child positions and using a separate interaction Area3D produced correct gold and red highlights and reliable deletion.
- A temporary placement guard intentionally printed "Conveyor snap preview only — placement not enabled yet" until connecting on click was implemented. The permanent snapped-placement branch must execute **before** the normal building instantiation to avoid duplicate objects. Final logs showed success for Before: false and Before: true.
- Perpendicular belts can look like a corner but do not yet provide a functional turn; visual touch is not a connection.

### Remaining Work

True corner scenes/automatic turn geometry, direct machine-port connections, item motion/throughput/backpressure, universal slot-based storage, and ammunition/defense remain planned. Proximity logistics is still the active resource-delivery mechanism.

**Nonblocking code-review cleanup:** The committed InteractionHitbox BoxShape3D lacks an explicit size override (so Godot uses its default cube), and its CollisionShape3D has slight Y rotation. The gameplay test passed, but normalize these when designing exact corners. A redundant conveyor_snap_source reset near the end of world_interaction.gd can also be removed during a later cleanup.

---

## 2026-10-27 — Chat 07.5: Automatic Conveyor Turns, L-Shaped Visuals and Direction Indicators (Fourth Checkpoint)

### Construction and Connection Changes

- Added `scenes/logistics/conveyor_corner.tscn` and `conveyor_corner_left.tscn` with oriented endpoints; developed safe right/left corner chains and rotation/connection tests.
- Added `ConveyorTurnIntent` and `ConveyorPieceSelector` as helpers for turn classification and shape references. The settled build interaction is **not** a mouse-selected corner ghost: it uses a normal straight preview through the single Conveyor Belt tool (key 5).
- Added `ConveyorCornerConversion.try_convert_and_connect()`: when a new perpendicular straight belt is correctly oriented next to an eligible straight belt's free output, the **existing belt** changes into a corner in place. Its identity and incoming connection remain intact; occupied outputs, invalid turns and misaligned endpoints fail without consuming an existing link.
- `WorldInteraction` integrates the perpendicular neighbor detector with normal placement, alongside the existing straight snap-before/after route. Successful turns report `AUTO CORNER SUCCESS | Turn: RIGHT/LEFT`.
- Added `ConveyorCornerVisualMesh` to provide gray L-shaped placeholder geometry. The version committed at this checkpoint merges **two rectangular arms** with SurfaceTool and uses width 0.8, height 0.2, arm length 0.6 and offset 0.2. Screenshots show usable filled-looking bends; a truly unified polygonal top and exact seam/collider matching remain refinements.
- Added `DirectionArrow` beneath `ConveyorStraight/OutputEndpoint`. Its unshaded yellow arrow follows each segment's actual output marker: straight belts, green construction ghosts, and corners converted in place show flow direction even before item motion is implemented.

### Validation Evidence (Local Godot Editor)

| Test or manual check | Reported/observed outcome |
| --- | --- |
| Right-corner scene connection and demolition | 8/8 |
| Left-corner scene connection and demolition | 8/8 |
| Corner snap-preview geometry | 6/6 |
| Conveyor turn intent | 8/8 |
| Conveyor piece selector | 8/8 |
| In-place corner conversion | 8/8 |
| Connected conveyor full-chain regression | 8/8 |
| L-shaped corner visual mesh regression | 8/8 |
| Main game: right/left auto-corners, extended straight chains, rotated layouts | Successful screenshots/output |
| Green preview direction arrow, selection, demolition, collision overlay | Successful user inspection |

The individual test outcomes were shared over several steps; **no claim is made that every old and new test was rerun together**. No GitHub CI run is claimed. The developer subsequently showed `main` synchronized to `origin/main` with a clean working tree; the new source files and tests were verified in the remote repository.

### Problems, Decisions and Remaining Scope

- Multiple apparently incorrect 90° placements were caused primarily by **ambiguous visual direction**: a plain rectangular belt looks identical at 90° and 270°, even though their outputs face opposite world directions. Visible arrows clarified valid orientation. Positive Y rotations in Godot do not necessarily match a player's intuitive notion of rotating right; retain endpoint-facing checks rather than accepting opposite-facing connections.
- Snapping after a converted corner must use its **OutputEndpoint world basis**, not only the segment root basis, because a corner's output is rotated relative to its root.
- A visual ring of belts is not proof of a closed directed graph. The final already-existing endpoint-to-endpoint loop connection needs separate gameplay integration and validation.
- The initial corner had narrow or missing-looking bend regions. The revised arm widths improve continuity, but the committed mesh still uses two joined boxes; exact continuous visual surfaces, collision/hitbox shape cleanup, and edge seams can be refined without changing established logistics links.
- **Not implemented:** item movement along conveyors, throughput, backpressure, belt-to-machine/storage port hookup, autonomous finished-product export, or dedicated splitter/merger buildings. The extractor → storage → smelter still runs on temporary proximity-based logistics.

**Next milestone:** validate final construction/connection regressions, improve precise hitboxes and corner surfaces, implement safe existing-belt loop closure, then introduce machine/storage port-to-belt links and conservation-tested conveyor item flow.

---

## 2026-10-27 — Chat 08: Generic Belt-to-Belt Transport Foundation (First Milestone)

### Implemented

- Created `ConveyorTransportComponent` with a strict one-unit `CargoInventory` buffer. All item operations use `ItemDefinition` and existing `InventoryComponent.transfer_to()`; no resource-specific belt behavior is hardcoded.
- Created `ConveyorTransportLink.try_transfer_forward()` to require reciprocal directed belt links and current endpoint alignment before handing off cargo.
- Created `ConveyorTransportTimer` with a configurable 1.0-second prototype travel interval and frame-driven update. A full/disconnected downstream belt blocks the current item without duplication or loss; movement resumes once there is space.
- Added `CargoInventory`, `ConveyorTransportComponent`, and `ConveyorTransportTimer` as direct children of the live `ConveyorStraight` scene, leaving existing snapping, arrows and corner-conversion geometry untouched.
- Verified that converting a straight belt into either automatic corner preserves the node, the held item, and the timer's partial progress.
- Added `ConveyorSegment.can_demolish_safely()` and a guard in `WorldInteraction` so **player demolition** rejects occupied or invalidly configured conveyor cargo buffers.

### Reported Local Godot Results

| Test | Checks |
| --- | --- |
| Cargo buffer | 7/7 |
| Connected directed transfer | 7/7 |
| Timed generic transport | 8/8 |
| Corner cargo preservation | 8/8 |
| Six-segment full chain | 8/8 |
| Player demolition safety policy | 6/6 |
| **Total across six separate suites** | **44/44** |

The updated connected (7/7), timed (8/8) and original full-chain construction (8/8) regressions were rerun after scene integration. The developer also confirmed normal game placement, rotation, yellow arrows, right/left corners, empty-belt demolition, and the original extractor → storage → smelter chain still worked. These are developer-run editor validations, **not a single combined CI report**.

### Important Design Decisions and Remaining Work

- **Universal cargo:** belts accept any valid `ItemDefinition`; receiving manufacturing ports will filter using the active recipe, while general storage accepts ordinary items subject to capacity.
- **Strict physical links:** automatic belt handoffs must use directed, geometry-valid next/previous connections; the low-level inventory helper alone is not an authorization to transfer.
- **Prototype throughput:** each segment currently carries one item unit and uses a 1-second interval; final belt occupancy, speed, visible travel interpolation and throughput balance remain open.
- **Safety scope:** only demolition through `WorldInteraction` is cargo-blocked. Direct `queue_free()`, scene teardown and eventual enemy destruction need a cargo recovery/dropping policy.
- **Not yet a physical factory:** no building-to-belt snap/load/unload path, visible cargo models, separate splitter/merger, intentional closed-loop closure or automated ingot export. Temporary proximity logistics remains active.

The user committed and pushed the tested gameplay milestone to GitHub `main` before this documentation update. **Next milestone:** visible generic cargo on belts, then machine/storage port connections and full ore-to-ingot physical routing, with regression checks at each step.

---

## 2026-10-27 — Chat 08: Visible Cargo, Building Connections and Physical Factory Test (Second Milestone)

### Implemented & Tested

- Created `ConveyorCargoVisual` as a read-only `MeshInstance3D` placeholder. The real ConveyorStraight scene now has a `CargoVisual` child, hidden when empty and interpolating from input to output along straight belts or an L-shaped local path on converted left/right corners. The carried `ItemDefinition` is generic; distinct item-specific artwork is not implemented yet.
- Added `OutputPort` to `test_extractor.tscn`, referencing the extractor's existing 50-unit inventory. Existing Test Smelter input/output ports continue to use the producer's selected recipe and separate inventories.
- Added `ConveyorBuildingSnap` to calculate read-only building-port snap transforms for either port direction and rotated buildings; extended it to reject occupied building and belt endpoints.
- Added reciprocal `connected_conveyor` / `input_building_port` / `output_building_port` references with alignment checks, exclusive connection ownership and cleanup on endpoint removal. Geometric alignment alone does not authorize transferring items.
- Added `ConveyorBuildingTransfer` for generic one-item output loading and guarded input unloading. Active-recipe filtering rejects irrelevant materials, full destinations retain cargo, and all transactions use conservation-aware InventoryComponent methods.
- Updated `ConveyorTransportTimer` to automatically load empty belts from connected output ports and to unload after the travel interval into connected input ports; forward belt-to-belt transfers, congestion retention and recovery remain available.
- Verified a real Extractor and Smelter with a three-belt route: **2 Test Ore seeded in the extractor → physically carried to Smelter → 1 Test Ingot manufactured**, with manual deterministic timer and producer updates and proximity/extraction processing disabled.

### Local Godot 4.6.2 Test Record

| Test scene | Result |
| --- | --- |
| `conveyor_cargo_visual_test.tscn` | 6/6 |
| `conveyor_corner_cargo_visual_test.tscn` | 8/8 |
| `extractor_output_port_test.tscn` | 7/7 |
| `conveyor_building_snap_test.tscn` | 10/10 (after occupancy expansion) |
| `conveyor_building_connection_test.tscn` | 8/8 |
| `conveyor_building_loading_test.tscn` | 9/9 |
| `conveyor_building_unloading_test.tscn` | 10/10 |
| `conveyor_automatic_unloading_test.tscn` | 9/9 |
| `conveyor_automatic_loading_test.tscn` | 10/10 |
| `conveyor_physical_factory_test.tscn` | 9/9 |
| **Second milestone subtotal** | **86/86** |

With the first milestone **44/44**, Chat 08 now has **130/130 reported checks over individually run suites**. Connected/timed/full transport and automatic unloading regressions were rerun successfully during development. The final physical factory integration test passed 9/9, and the developer pushed the changes to `main`. No single consolidated CI run is claimed.

### Problems Resolved

- `CargoVisual` initially had the **test script** (`conveyor_cargo_visual_test.gd`) attached instead of `conveyor_cargo_visual.gd`, producing a stack overflow during scene initialization. Assigning the correct component script restored passing straight/corner visual tests.
- An explanatory pseudo-code example was accidentally pasted at the bottom of `conveyor_building_transfer.gd`, duplicating `extends RefCounted` and `class_name` declarations. Removing that sample and appending only the complete top-level `try_unload_from_belt()` function corrected the file.
- The `conveyor_building_unloading_test` script/scene were initially missing; they were created separately and the new unloading test passed 10/10. `Extractor has no resource node` appeared in isolated tests because no deposit was instantiated; it was not a port/transport failure.

### Boundaries and Next Work

- The normal player factory does **not yet snap belts to building ports through Build Mode**. The completed physical route exists in an isolated test which positions and connects its actors in code, seeds ore instead of mining, and manually drives timers.
- The temporary Extractor → Storage → Smelter proximity logistics remains enabled in normal gameplay. It must be gated or replaced only after safe physical routes and regression coverage exist, to prevent overlapping transfer systems.
- Test Storage still needs dedicated universal input/output ports and a validated complete physical route via storage. Further tests should cover multiple simultaneous items, throughput and transfer order under frame-driven updates.
- The generic orange placeholder is common to all item definitions; distinct item visual models, splitter/merger buildings, explicit loop closure, improved corner colliders and cargo recovery for non-player destruction remain open.

**Next milestone:** integrate building-port preview/connection into `WorldInteraction` carefully, test player-created Extractor → Belt → Smelter networks, and add Storage port support before switching off proximity logistics.

---

## 2026-10-27–30 — Chat 08.3F–08.3G: Player-Built Physical Logistics, Grid Alignment and 1×1 Routing Buildings

### Goals and design decisions

The user identified recurring final-junction failures while building a real Extractor → Storage → Smelter route and returning belts to previously placed factories. Core decisions:

- **Construction order should not matter** when the endpoints and turn direction are actually compatible.
- **Conveyors remain physical:** no magical item movement or forced joining of visually touching but incompatible arrows.
- Use a **shared 1-unit factory grid**, taking rotated footprint parity into account, instead of independently rounding buildings and conveyors.
- Support correct final connections with new missing corners, in-place source or receiver corner conversion, exact bridges, fractional straight spans and offset L-shaped connectors.
- Dedicated **Merger**/**Splitter** are not ordinary belt turns. Final prototypes are each **1×1** with a port on every side: **3 IN → 1 OUT** and **1 IN → 3 OUT** respectively.
- Keep inventories bounded, preserve cargo and existing building links, and reject invalid occupancy rather than overwriting old connections.

### Major construction features committed

1. **Smelter dual-port and building port foundation:** Independent input/output ports, directed build previews, building-to-existing-belt snapping and reciprocal links. In-game logs showed successful building hookups and ore/ingot movement.
2. **Conveyor bridge and corner discovery:** Read-only previews, collision/endpoint revalidation on click, separate missing-corner and existing-receiver/source conversion paths, and safe two-ended bridge commits. The user reproduced prior impossible loop-closure cases and verified automatic corners connecting successfully.
3. **`FactoryGrid` consistency:** Footprint-aware odd/even building origins, rotated grid lanes and shared coordinate tests. All current building types use grid-aware placement; placement snap-to-belt rejects transforms that would put a new building off-grid.
4. **Fractional/offset geometry:** `conveyor_fractional_bridge.gd` and `conveyor_offset_corner_bridge.gd` construct actual cargo-carrying variable-length straight and L-shaped segments, with properly adjusted endpoints, physics and selection hitboxes. These resolve half-tile Extractor spacing and small perpendicular gaps when free endpoints are directionally compatible.
5. **Constant physical item speed:** `conveyor_path_motion.gd` scales connector travel time according to path length and allocates corner interpolation proportionally to each leg. A developer live check confirmed that ore moved at the same apparent speed over short and regular belts after the change.
6. **1×1 routing buildings:** `conveyor_merger.tscn` with `ConveyorMergerComponent` has three separate input buffers and a single output; `conveyor_splitter.tscn` with `ConveyorSplitterComponent` has one input and three independent bounded output buffers. Both route fairly under backpressure and require physical connections. Build Mode uses **6** for Merger and **7** for Splitter.
7. **Diagnostics and safe demolition:** Production Debug HUD shows port connections, input/output buffer quantities and per-lane completed transfer counters. Full Merger/Splitter buffers block unsafe player demolition; standard cargo-bearing conveyors retain their cargo-protection rules.

### Reported validation (Godot 4.6.2 Stable, local)

| Checkpoint | Reported outcome |
|---|---|
| Original Smelter dual-port snap | 8/8 |
| Dual-ended conveyor bridge | 11/11 |
| Bridge discovery | 10/10 |
| Factory-grid alignment (progressively expanded) | 9/9 early; latest suite covers five building types and 52 rotated lanes |
| Existing endpoint/connection and receiver-corner work | Individual suites passed; regression runs also reported |
| Existing receiver auto-snap | 11/11 |
| Building-safe source corner auto-snap | 10/10 |
| Fractional straight connector | Initial 10/10; additional later assertions passed after Build Mode and speed changes |
| Offset L-shaped connector | Initial 10/10; additional later assertions passed after constant-speed correction |
| 1×1 Merger: 3 inputs, 1 output | 10/10 |
| 1×1 Splitter: 1 input, 3 outputs | 10/10 |
| Live Splitter production | **13 completed splits**, `To A: 5`, `B: 4`, `C: 4`; three physically connected output ports |

These are **reported individual test runs**, not a single scripted or CI-based full regression. Exact test-scene names and a reproducible acceptance sequence are in [CHAT_08_FINAL_REGRESSION.md](CHAT_08_FINAL_REGRESSION.md).

### Important troubleshooting and lessons

- A translucent conveyor ghost can be visually correct but still fail to commit; always distinguish *snap discovery* from validated permanent connection.
- Opposite-facing/free endpoints are essential. A corner may redirect a single flow but cannot safely combine two occupied incoming branches.
- The first Merger design used a 2×2 body whose output center could sit between grid lanes; it was replaced by the final 1×1, four-port layout.
- Short conveyor segments taking the same interval as regular 1-unit belts looked slower; constant distance-based timing fixed the visual inconsistency without changing inventories.
- A busy Merger may stall because **three supplies share one bounded output**, not because a building-input port was disconnected. Per-lane counts and output occupancy must be inspected together.
- Before editing a long controller script, locate changes by major section headers, inspect parser errors at their first occurrence, and use discrete test scenes as regression gates.
- GitHub file edits can trigger Godot's “newer on disk” prompt; preserve unsaved edits and reload the pulled scene resources.

### Current acceptance status and remaining work (2026-10-30)

**Completed and observed:** Physical conveyor connections, short-gap placement, constant cargo speed, 1×1 Merger construction with three connected incoming lanes, and three-way Splitter cargo distribution in the main game. The developer reported the latest grid/Merger/Splitter isolated tests all passing.

**Not yet fully observed:** The 1×1 Merger's live **`From A`, `From B`, `From C`** counters all progressing during a sustained three-input/one-output production run. In particular, a paused input must be distinguished from a full output buffer; do not claim final full Merger acceptance solely from construction screenshots.

**Remaining release gate:** Run the critical scenes as a single final manual regression pass, verify Merger backpressure/recovery, confirm full deposit-driven physical mining→smelting→destination delivery without double counting retained proximity scaffolding, and inspect collision/selection/demolition behavior. Then create the final accepted GitHub checkpoint.

**Future product goals:** Gradually retire prototype proximity logistics with conservation checks, cargo recovery for destructive events, universal tiered slot/stack storage, polished visual cues, ammunition manufacture, defense and zombie First Night gameplay.

---

## 2026-10-30 — Chat 08 Final Logistics Acceptance Checkpoint (Core Systems)

### Final manual regression

The developer ran **all 20** enumerated Godot `F6` test scenes over **four rounds of five tests**, confirming every round passed. Covered grid alignment and rotated ports; three-input Merger and three-output Splitter; existing and missing corner conversion; endpoint discovery; two-ended and fractional/offset bridges; cargo path visuals; automatic machine loading/unloading; and isolated physical ore-to-ingot transport.

**Evidence status:** These are developer-reported local editor results, not one automated GitHub CI run. See [CHAT_08_FINAL_REGRESSION.md](CHAT_08_FINAL_REGRESSION.md) for the exact scene list.

### Live gameplay completion

- **Merger (1×1, 3 IN / 1 OUT):** Three connected source routes showed physical item transport; developer subsequently confirmed Merger operation in the live factory. Detailed `From A/B/C` HUD values were not separately captured.
- **Splitter (1×1, 1 IN / 3 OUT):** Live Production Debug HUD captured **13 successful splits**, distributed A=5, B=4, C=4; all three output ports connected.
- **Backpressure:** Developer explicitly confirmed that the Merger retained cargo under blocked-output conditions and resumed after space became available.
- **Ore-to-ingot production:** Developer explicitly confirmed a fully working ore-to-ingot factory chain in gameplay, beyond the earlier seeded isolated physical factory test. No numerical end-to-end resource-conservation snapshot was supplied for this new run.

### Milestone decision

**Core Chat 08 physical factory-logistics milestone: ACCEPTED (2026-10-30).** Both the manual regression and the principal player-visible production/routing behavior have passed.

This acceptance **does not** mean everything in the long-term logistics roadmap is finished. We have not separately verified that legacy proximity-based scripts were disabled for the latest live run; a confirmed functioning belt chain does not, by itself, prove there are no parallel automatic proximity transfers. Do not remove that legacy logic without a controlled physical-only conservation regression.

### Carry-forward work (later milestone)

1. Confirm physical-only resource accounting and carefully retire/gate redundant short-range proximity transfer scripts.
2. Improve diagnostic snapshots/throughput benchmarking (Merger lane counts; Splitter blocked-output sustained-traffic behavior).
3. Confirm demolition, collision refusal and cargo-recovery behavior in complex live builds; establish persistence and player-friendly build visuals.
4. Continue the original gameplay vision toward ammunition production, defensive supply and the zombie First Night vertical slice.

**Documentation checkpoint:** `GAME_DESIGN.md`, `ARCHITECTURE.md`, `TROUBLESHOOTING.md`, `ROADMAP.md` and this log capture implementation and engineering lessons. This entry supersedes earlier *historical* statements that Merger/backpressure and full factory live verification were still pending.


---

## 2026-10-31 — Physical-Only Production, Ammunition Acceptance and First Turret Foundation

### Verified by local Godot tests

- `tests/conveyor_physical_only_conservation_test.tscn`: **9/9 passed**. A 500-unit finite ore deposit supplied a physical-only Extractor → Storage → Smelter → Storage route. Legacy proximity scripts were disabled during the test. After two ore were converted into one ingot, 498 ore + (1 ingot × 2 ore) equaled the initial 500 ore equivalents.
- `tests/prototype_ammunition_press_test.tscn`: **9/9 passed**. The data-defined ammunition recipe accepts only Test Ingots, creates four Prototype Rounds per ingot, and protects finished rounds during output blockage and recovery. Conveyor export to warehouse and eight-round conservation were tested.
- `tests/ammunition_press_build_mode_test.tscn`: **9/9 passed**. Slot 8, keyboard selection, highlighting, rotation, grid-aligned ports, connection cleanup and demolition safety all passed.
- **Live main-game observation:** User supplied a screenshot with a physically connected manufacturing line and the selected final Test Storage HUD showing **6 Prototype Rounds / 200 capacity**. This verifies that manufactured ammunition arrived in normal storage during gameplay. Rounds are moved one at a time, so an intermediate storage count need not be divisible by the four-round recipe batch.

### Safeguards and deferred scope

- The older proximity transfer components still exist in the repository for compatibility, but their scene nodes are configured disabled. They were explicitly disabled during the physical-only conservation run. Do not remove their scripts merely because the new route works.
- The Prototype Ammunition Press is production-ready as a **prototype**, not balanced or visually final. The current recipe is **1 Test Ingot → 4 Prototype Rounds over 2 seconds**; actual military recipes and resource economy remain design decisions.
- New **isolated** 1×1 defensive turret foundation: `DefensiveTurretComponent`, ammunition-only `TurretAmmunitionPort`, `prototype_defensive_turret.tscn`, and `prototype_defensive_turret_test.tscn`. The first checkpoint verifies physical ammo receipt, one-round firing, cooldown, blocked/full magazines, resource conservation and protected demolition. **This newly committed turret test has not yet been run locally**, so it is not accepted as passed.
- The turret is **not** in Build Mode yet and will not auto-shoot enemies. Targeting, projectiles, damage, zombie behavior and defense balance are follow-on features.

### Next acceptance gate

Run `res://tests/prototype_defensive_turret_test.tscn` with **F6** in Godot 4.6.2. Record the result and fix any isolated test issues before registering the turret in the main Build HUD. Preserve the existing conveyor, recipe and warehouse test suites.


---

## 2026-10-31 — Turret Ammunition Foundation Accepted; Build Mode Slot 9 Prepared

### Local test results

The developer ran `res://tests/prototype_defensive_turret_test.tscn` in Godot 4.6.2 and supplied console output confirming **all 10/10 tests passed**. Verified: ammunition-only port acceptance, rejection of ore and ingots, one-way physical belt connection, backpressure, correct one-round firing transactions, cooldown, conservation, magazine capacity recovery, safe demolition, and physical connection cleanup.

### Next integration checkpoint (committed, pending local test)

- Registered **Prototype Defensive Turret** as construction **slot 9** (`9` key), preserving existing slots 1–8.
- Updated `BuildHUD` scene and script with the ninth selection label; adjusted its vertical layout.
- Added `ProductionDebugHUD` turret-specific display showing ammunition quantity/capacity, input-port connection status, cooldown, firing readiness, shot count and an explicit note that **targeting is not implemented**.
- Added `tests/defensive_turret_build_mode_test.tscn` with 12 checks against the real Main scene, building rotation/grid, incoming conveyor, ammo handling, HUD and cleanup.
- Updated the older ammunition press Build Mode regression to continue checking its original eight slots within the new nine-slot roster.

**Acceptance gate:** Run the new 12-case turret Build Mode test in local Godot before claiming the slot 9 integration is validated. Then confirm live delivery of factory-produced Prototype Rounds into the turret magazine. Automatic targeting, firing, damage, zombies and combat balancing remain unimplemented.


### Follow-up acceptance: turret Build Mode slot 9

The developer ran `res://tests/defensive_turret_build_mode_test.tscn` in Godot 4.6.2 and supplied the Output screenshot confirming **all 12/12 checks passed**. Verified existing eight build slots and new slot 9, preview and 90-degree rotation, grid-aligned turret input, ammunition-only acceptance, physical conveyor delivery, loaded-turret demolition protection, Production Debug HUD (connected state/1 of 40 rounds/readiness), a single simulated shot updating the counter, port cleanup, and switching between slots 8 and 9. This completes the local automated acceptance of turret Build Mode integration.

**Next live-game checkpoint:** Use the already-working ammunition factory to feed a placed turret through real conveyors. Existing Storage provides a universal output port; a Storage → Conveyor → Turret connection avoids disrupting the Ammunition Press's single occupied output port. Expect the turret HUD's magazine count to increase while `Fired Shots` stays at zero because no automatic targeting or in-game firing action is implemented yet. Visual targeting, enemy behavior and damage remain pending.


---

## 2026-11-01 — Live Ammunition-Fed Turret Accepted; Isolated Targeting Checkpoint

### Accepted live-game evidence

A screenshot of the player-built factory and selected Defensive Turret HUD confirms physical ammunition supply into the turret: **Ammo Conveyor Connected; Ammunition 9 / 40; Status Ready; Cooldown 0.00 seconds; Fired Shots 0**. This is the first accepted complete physical chain from extraction, smelting and ammunition manufacturing through storage/conveyors into a turret magazine during normal gameplay.

The zero-shot count is correct: no automatic combat behavior was attached to the live turret at the time of acceptance.

### New combat foundation (not yet locally tested)

- `CombatHealthComponent`: generic positive health, guarded damage transaction and death signal.
- `prototype_zombie_target.tscn`: stationary hostile placeholder with visible body and 30 health (not yet a moving zombie).
- `TurretTargetingComponent`: optional child component that scans the `hostile_targets` group, selects the nearest living target within a horizontal range (default 7 world units), and uses the existing `DefensiveTurretComponent.try_fire()` transaction before applying a temporary 10 damage instant hit. Every shot consumes one Prototype Round, obeys cooldown and skips out-of-range, friendly and already-dead targets.
- `tests/defensive_turret_targeting_test.tscn`: isolated 12-case Godot regression covering range, nearest selection, no-target/no-ammo behavior, cooldown, exact damage, target defeat and retargeting, and conservation.

**Important:** This targeting behavior is **not yet attached to the Build Mode turret**. There is no projectile simulation, line-of-sight check, target movement, zombie spawning, building damage or enemy attack behavior. Run the new isolated test first, then integrate into live gameplay only after local verification.

### Next check

Run the targeting regression with F6 in Godot 4.6.2. Preserve the previously passing turret ammo/Build Mode suites, conveyor factory, and ammunition production tests.


### Follow-up acceptance: isolated targeting/damage regression

The developer supplied Godot 4.6.2 output confirming **12/12** tests passed in `res://tests/defensive_turret_targeting_test.tscn`: no-target and out-of-range ammo preservation, ignoring non-hostiles, nearest-hostile targeting, real one-round consumption, cooldown, 10 damage per hit to a 30-HP dummy, skipping defeated targets, retargeting, empty-magazine protection and ammo/shot conservation.

### Player-world combat integration (committed; local validation pending)

- Attached the validated `TurretTargetingComponent` to `prototype_defensive_turret.tscn`. Its range is 7 units and damage 10 per authorized shot; it consumes rounds exclusively through `DefensiveTurretComponent.try_fire()`.
- Placed a stationary `PrototypeZombieTarget` instance at **(-6, 0, -6)** inside the main world's ground area, farther than 7 units from origin to avoid disrupting older slot-9 regression tests. This is a static test dummy, not a zombie with AI or movement.
- Added a visible target health/defeated Label3D and read-only combat statistics to the turret Production Debug HUD (current target, hits, defeated count). Preserved the existing magazine/cooldown/counter display.
- Updated the older turret Build Mode regression's combat label assertion to reflect automatic targeting now being attached.
- Added `res://tests/live_turret_combat_integration_test.tscn`, an **11-case** integration test against the real Main scene, connected physical belt, ammunition inventory, range detection, automatic fire, target health, visible defeat state, HUD and disconnect cleanup.

**Not yet validated locally:** The full scene integration, player-built turret automatic fire and on-screen damage. Do not claim live combat acceptance until the new F6 test and a manual in-game demonstration pass. Instant damage is a temporary placeholder; projectiles, LOS checks, zombie movement/spawning, death animations and combat balancing are future work.


### Follow-up acceptance: real Main-scene combat integration

On **2026-11-01**, the developer ran `res://tests/live_turret_combat_integration_test.tscn` in Godot 4.6.2 and supplied the full Output screenshot confirming **all 11/11 tests passed**.

Verified in the main scene: the stationary 30-HP target exists, slot 9 builds a turret containing automatic targeting, target distance gates firing, no-ammunition preserves health, a real conveyor attaches to the magazine port, each delivered round authorizes one 10-damage shot, cooldown prevents phantom hits, three rounds defeat the dummy without loss, defeated targets stop receiving hits, the target displays `TARGET DEFEATED`, combat counters update in the Production Debug HUD, and empty-turret removal does not break the existing conveyor.

**Next checkpoint (not yet accepted):** Manual, player-controlled gameplay with an ammunition-fed turret near the static target at (-6, 0, -6). Verify that the target health label and turret HUD update while rounds are physically delivered and the dummy is defeated in the running main world. Do not count this as proof of moving zombies, projectile simulation, enemy attack AI or line-of-sight.


### Follow-up acceptance: manual factory-powered combat

On **2026-11-01**, the developer supplied a screenshot from regular gameplay showing the ammunition-fed turret and its physical conveyor chain beside the stationary target whose health label reads **TARGET DEFEATED**. This confirms the first visual combat victory in the playable main world. The screenshot does not display the turret's shot counters; those 3-hit/30-HP values were separately confirmed by the **11/11** live-world integration regression.

**Next step:** Add an isolated moving-enemy prototype. Keep the original stationary target and production systems unchanged. The first movement prototype may approach a selected player-built structure directly on the X/Z plane, but collision avoidance, pathfinding, building attacks, enemy spawning and wave logic remain separate unimplemented features.


### New isolated milestone: moving-zombie foundation (not yet tested locally)

The first moving enemy is deliberately **separate** from `prototype_zombie_target.tscn`, which remains the accepted stationary reference in the main playable scene.

- `ZombieApproachComponent` finds the nearest real `player_built` structure with a `BuildingRuntime`, excluding construction previews and conveyors.
- Walks in the X/Z plane at a temporary **2 units/second** and stops **1.5 units** from the structure center; large time steps are clamped to prevent overshoot.
- Reacquires a valid target after the previous structure is removed. Stops permanently when its `CombatHealthComponent` reaches zero.
- `scenes/enemies/prototype_moving_zombie.tscn` is a separate green placeholder with the existing combat health and label implementation.
- `tests/prototype_moving_zombie_test.tscn` contains nine isolated checks for idle behavior, excluding ghosts and conveyors, nearest structure selection, displacement and stopping distance, reacquisition after deletion, existing ammo-fed turret hits/cooldown, and immobility when defeated.

**Not integrated in Main yet.** The movement code uses straight-line motion only; no NavigationAgent3D, collision avoidance, body-to-body collisions, enemy attacks, structure health, spawners or waves have been implemented. Run the nine-case F6 regression in Godot 4.6.2 before adding enemy motion to the live factory.


### Moving-zombie foundation accepted; live-world integration pending

The developer ran `res://tests/prototype_moving_zombie_test.tscn` in Godot 4.6.2 and supplied Output confirming **all 9/9 tests passed**. This verifies no-target idle behavior, excluding ghosts and conveyors, approaching and stopping 1.5 units from the nearest actual building, reacquisition when a structure is deleted, compatible ammo-fed turret damage/cooldown, and no motion after death.

**Next implementation checkpoint:** The separate `PrototypeMovingZombie` is now instanced in `scenes/core/main.tscn` at **(8, 0, -7)**. The previously validated stationary `PrototypeZombieTarget` remains at **(-6, 0, -6)**. The new `res://tests/live_moving_zombie_integration_test.tscn` uses the actual Main scene and tests the absence of target/ignored ghosts, player-built storage approach, stopping distance, switching to an actual turret after storage removal, physical ammo delivery, three real hits, target death, HUD statistics, and conveyor cleanup.

**Status:** This main-world change has been committed and repository-reviewed, but its 12-case integration regression has **not** yet run in local Godot. Do not claim it passes until the user's F6 confirmation. Live gameplay movement also still requires manual observation. This remains direct X/Z motion, with no obstacle avoidance, NavigationAgent3D, structure damage, automatic spawning, or wave systems.


### Main-scene moving-zombie integration accepted — 12/12 checks

On **2026-11-01**, the developer ran `res://tests/live_moving_zombie_integration_test.tscn` in Godot 4.6.2 and supplied Output confirming **ALL 12 LIVE MOVING ZOMBIE INTEGRATION TESTS PASSED**.

The test exercised the real Main scene: one moving zombie coexists with the original stationary target; with no player structures it remains still; construction preview ghosts and loose conveyors are ignored; the enemy travels 2 world units per second toward player-built Storage and stops 1.5 units from it; after Storage removal it acquires a placed turret; without ammunition the turret cannot fire; after physical conveyor connection three delivered Prototype Rounds produce three guarded hits, defeat the moving zombie, and preserve the static target. Dead enemies cease motion, and the turret's combat HUD and conveyor cleanup remain correct.

**Next acceptance gate:** Manually launch the actual main game with F5, place a structure near the moving enemy at (8, 0, -7), and verify it visually approaches and stops. A later manual pass should supply a turret and observe the moving enemy's defeated state. This is still straight-line X/Z motion without navigation, obstacle avoidance, structure attacks, automatic waves, or projectiles.


### Manual movement accepted — zombie approaches player-built Storage

On **2026-11-01**, the developer supplied a gameplay screenshot showing the green **PrototypeMovingZombie** beside a placed Test Storage building, with its label **TARGET HP: 30 / 30**. The previously validated red stationary target is visible separately. The developer confirmed the zombie approached and stopped at Storage during live gameplay.

This establishes manual visual acceptance of the moving-enemy approach and stop behavior. The exact 1.5-unit stopping distance is supported by earlier isolated and main-scene automated tests, rather than being measured from this screenshot. The moving zombie has not yet been visibly defeated in a live, player-controlled run.

**Next validation:** In a fresh gameplay run or with the existing factory, place an ammunition-fed turret within 7 world units of the moving zombie and verify three hits, 30-to-0 HP, the **TARGET DEFEATED** label and no more firing at the defeated zombie. Keep the static target separate from that engagement. Do not infer navigation, zombie attacks, projectile simulation or building damage.


---

## 2026-11-01 — Moving-Zombie Combat Accepted; Isolated Structure-Damage Foundation

### Accepted normal gameplay

The developer supplied a normal-gameplay screenshot showing both the previously validated stationary target and the moving zombie with separate **TARGET DEFEATED** labels. The developer confirmed that the green moving zombie immediately approached a newly placed turret, which then defeated it using factory-supplied ammunition. This accepts the first moving-hostile victory in regular gameplay. The image does not show live shot counts; existing deterministic regressions separately verified three real 10-damage hits per 30-HP target.

### Building health and melee implementation (not yet locally validated)

- `BuildingHealthComponent` introduces 100 default HP, actual-damage accounting, a single zero-HP signal, and guarded damage application. **At zero HP, the building is kept in the scene**: no inventory, resources, or conveyor connections are silently deleted.
- `ZombieMeleeComponent` allows one attack per configured interval (temporary 10 damage/1 second) only when a living zombie is within physical melee range and `ZombieApproachComponent` reports `At Structure`. It requires an explicit health-enabled building, ignores previews, conveyors, invalid targets and cooldown violations, and stops attacking when the zombie is defeated.
- `ZombieApproachComponent` now ignores a health-enabled building whose health has reached zero and reacquires another valid structure. Buildings without the health component retain their existing movement-target behavior for backward compatibility, but are not damageable by the new melee component.
- `tests/zombie_building_melee_test.tscn` has **12 isolated checks** covering no-target behavior, undamageable buildings, previews and conveyor filtering, valid structure detection, approaching/range rules, damage, cooldown, exact zero-HP clamping, stored-ammunition preservation, retargeting and dead-zombie attack prevention.

**Safety/integration boundary:** Neither `scenes/enemies/prototype_moving_zombie.tscn` nor any player-buildable factory scene has had melee or BuildingHealth attached. Existing main-game behavior should remain non-destructive while the 12-case regression awaits local F6 validation. Player-facing building HP, combat destruction, salvage/recovery, obstacle navigation, zombie spawning and waves are still future increments.


### Building-health foundation accepted — 12/12 local Godot checks

The developer ran `res://tests/zombie_building_melee_test.tscn` in Godot 4.6.2 and provided output confirming **ALL 12 ISOLATED BUILDING HEALTH AND MELEE TESTS PASSED**. Tested exact melee distance and cooldown, one hit per interval, invalid targets, 25-HP overkill clamping, three saved ammunition units remaining inside a zero-HP storage unit, retargeting a healthy structure and zombie attack/movement stopping after death.

### Step 09.16 — Factory-wide durability and shared HUD (committed, unverified)

- Added `BuildingHealthComponent` directly to the eight player-buildable **structure** scenes: Extractor, Test Large, Storage, Smelter, Merger, Splitter, Ammunition Press and Defensive Turret. Each starts at 100 HP. Ordinary conveyor **segments** are not building-health targets and retain their current cargo logic.
- Production Debug HUD now appends a standardized **BUILDING DURABILITY** block with current/max HP and Intact/Disabled status after the existing building-specific display. This preserves all production, inventory, magazine and recipe information.
- Adapted `tests/zombie_building_melee_test.gd` so its special legacy **no-health** fixture explicitly removes the new default component, preserving that test's safety invariant, while its damageable fixtures edit the existing component rather than creating duplicate children.
- Added `tests/building_health_integration_test.tscn`, an **11-case** acceptance test against all nine construction slots. It verifies one health component per structure, no health on belts, shared HUD output, stored cargo and connected-port survival at zero HP, zombies ignoring disabled Storage, and turret magazine/demolition safety.

**Important:** Zero-HP status currently marks a structure as disabled for enemy targeting but does **not** yet automatically halt processing or transport. No building is destroyed, salvaged or removed, and no stored resources disappear. The live moving zombie still has no `ZombieMeleeComponent` attached. This integration must pass local Godot validation before real zombie attacks are enabled.


### Step 09.16A — Factory-wide durability integration accepted

On **2026-11-01**, the developer ran `res://tests/building_health_integration_test.tscn` locally in Godot 4.6.2 and supplied output confirming **ALL 11 BUILDING HEALTH INTEGRATION TESTS PASSED**.

Verified all nine build slots remain registered; exactly eight non-belt structures each have one initialized 100-HP component; ordinary conveyors do not gain building HP; all eight building Debug HUD views show durability; Storage inventory and physical output port references persist through damage and zero HP; zombies skip disabled Storage; a loaded turret keeps its ammunition, HUD and demolition safety; construction ghosts are not targeted.

The teardown message `Extractor has no resource node` occurs after the tests and does not indicate an assertion failure.

**Next regression gate:** Re-run `res://tests/zombie_building_melee_test.tscn` (12 checks) with its modified no-health fixture now that the regular Storage scene includes health. This new re-run is pending; do not enable `ZombieMeleeComponent` on the live moving zombie until confirmed. Zero HP currently preserves inventory and links but does not automatically halt production or implement destruction, repair, or salvage.


### Step 09.16B — Adjusted isolated melee re-test accepted (12/12)

The developer ran the updated `res://tests/zombie_building_melee_test.tscn` after all eight non-belt structures gained their 100-HP component. The Godot 4.6.2 screenshot shows **ALL 12 ISOLATED BUILDING HEALTH AND MELEE TESTS PASSED**, confirming the no-health fixture, melee distance and cooldown, damage clamp, resource preservation, retargeting and prevention of further attacks from defeated zombies remain correct.

### Step 09.17 — Live structure attacks integrated (local acceptance pending)

- Attached `ZombieMeleeComponent` to `scenes/enemies/prototype_moving_zombie.tscn` with an exported NodePath to its existing MovementComponent. The live moving zombie now has **10 melee damage**, a **1.0-second** attack interval, and a **1.55-world-unit** attack range.
- The component only deals damage to the currently approached, intact `BuildingHealthComponent` target. Its attack routine never deletes the building, inventory, resource items or physical conveyors.
- Updated the historical isolated melee test to reuse the scene's built-in melee component instead of injecting a duplicate.
- Updated `prototype_moving_zombie_test.gd` and `live_moving_zombie_integration_test.gd` to disable the new melee process during their deterministic movement-only assertions, preserving their original scopes.
- Added `tests/live_zombie_melee_integration_test.tscn` with **12 Main-scene integration checks**. It tests the wired live zombie, empty/ghost targeting, stored ammo with a connected belt, range gating, first hit, cooldown, 10 exact hits taking 100-HP Storage to zero, no inventory or port loss, disabled-building retargeting, attacking a second structure, defeated-zombie immobility and health HUD updates.

**Not yet locally tested:** The new 12-case Main-scene zombie melee integration. Before accepting this gameplay milestone, run the F6 regression, then manually verify health decreasing on a placed Storage building. A zero-HP building still remains in place and may continue production/transport; production shutdown, damage visuals, destruction, repairs, salvage, obstacle pathfinding and wave spawning remain future work.


### Step 09.17A — Live zombie melee integration regression accepted (12/12)

The developer ran `res://tests/live_zombie_melee_integration_test.tscn` in Godot 4.6.2 and supplied Output confirming **ALL 12 LIVE ZOMBIE MELEE INTEGRATION TESTS PASSED**.

The real Main-scene zombie was verified to carry a wired melee component. The test confirmed no attacks without a structure, rejection of construction ghosts and conveyor belts, live Storage at 100 HP retaining seven Prototype Rounds and a connected belt, no premature hit outside range, 10 damage on reaching Storage, cooldown blocking extra hits, ten hits reaching exactly zero HP, inventory and port survival after defeat, target reassignment to a second intact building, and complete cessation of zombie movement and attacking after its own defeat.

**Acceptance boundary:** Integration regression is passed; manual player-controlled F5 gameplay validation remains pending. The next check is to build and select Storage near the green moving zombie at (8, 0, -7), confirm the Debug HUD durability decreases by 10 HP per melee hit, and observe the structure remaining present at zero HP. Do not require a turret for this defensive-loss test, and do not claim production shutdown, repair, salvage, pathfinding or wave spawning from it.


### Step 09.17B — Live player-controlled zombie attack accepted

On **2026-11-01**, the developer reported placing a Test Extractor near the moving zombie in the actual F5 main game. The zombie attacked until the Extractor reached **HP: 0 / 100**, while the building remained visibly present. The selected Extractor's Production Debug HUD showed **Status: Disabled** in the Building Durability section and **Stored Test Ore: 19 (19 / 50 capacity)**. This is visual confirmation of non-destructive health depletion for the Extractor. The prior **12/12** Main-scene melee regression specifically validated Storage inventory and physical port preservation at zero HP.

**Important observed gap:** The same screenshot still displayed `Status: Extracting` under the Extractor production section, despite durability being disabled. Operational shutdown at zero health is **not implemented yet**; the screenshot alone cannot establish whether additional ore was produced after reaching zero. The progress bar is not a health indicator.

**Next design/implementation milestone:** Introduce health-aware operation gates for extraction, recipe processing, ammunition-fed turret firing, and building conveyor transfers. A disabled structure should stop operating without destroying resources, changing physical connections, or resetting partial progress. Design repair/reactivation separately and verify disabled behavior with isolated regression scenes before changing live systems. Automatic physical destruction, cargo salvage, repair interfaces, navigation, and wave spawning remain out of scope.


### Game-design correction — Real structures and conveyors must be destructible

The developer clarified that the present `Disabled` status at zero HP is **only a testing safeguard**. It must not become the final gameplay outcome. In the playable game, zombies should be able to destroy **both factory buildings and conveyor segments**.

**Confirmed requirement:** A building at zero HP leaves normal operation and is destroyed through a controlled lifecycle; belts can be separately damaged and severed. Destroying a single building or conveyor does not erase the entire connected factory network. The game should show placeholder wreckage/debris until final art exists.

**Engineering gates before enabling physical removal:** Explicitly disconnect ports, resolve machine inventories and cargo on destroyed belts without silent duplication, define recoverable drops/salvage/loss, verify neighbor belts remain intact, and handle target reassignment and blocked logistics safely. Existing 0-HP preservation tests remain regression fixtures for the transition, not a statement of the intended final destruction rules. Optional repair of damaged structures and rebuild/salvage of destroyed ones are separate design decisions.

`GAME_DESIGN.md` and `ROADMAP.md` now document this requirement. No gameplay destruction code has been changed as part of this design clarification.


### Upcoming UI milestone — Player-configurable build hotbar

The developer requested that, after real building and conveyor destruction is implemented, the player should be able to open a menu of **unlocked** buildings and assign any of them to any number key. Example: **Defensive Turret → 1**, **Storage → 9**.

The planned Build Catalog and nine-slot customizable hotbar are documented in `GAME_DESIGN.md` and Phase **1G** of `ROADMAP.md`. Unlocked buildings can be assigned, reordered or swapped without affecting the existing factory. Preferences should persist across sessions by stable `building_id` rather than the `buildable_definitions` array index. The future refactor must specifically eliminate the `selected_building_index == 4` Conveyor Belt logic before allowing arbitrary slot mappings, preserving the current belt placement and snapping regressions.

**Status:** Design captured only. No UI, hotkey, progression, or save files have been modified. The immediate priority remains destruction of buildings and conveyor segments with safe cargo handling.


---

## Step 09.18A — Destruction Cargo Recovery Preflight (2026-11-01)

**Status: new isolated code committed, Godot validation pending.** No live factory destruction is enabled.

- Added `scripts/components/destruction_cargo_recovery.gd` (`DestructionCargoRecovery`), a reusable inventory recovery helper that collects all descendant `InventoryComponent` instances exactly once, rejecting invalid item identities, missing sources, same-tree recovery targets, and recovery caches with insufficient total space.
- Once preflight succeeds, resources move via the **existing** `InventoryComponent.transfer_to()` logic. This is item-generic (ore, ingots, ammunition and future `ItemDefinition` resources), and repeated calls on an emptied source are idempotent.
- Added `res://tests/destruction_cargo_recovery_test.tscn` (12 checks). It covers capacity refusal without partial transfer, 7 ore + 4 rounds from Storage, recovery from the 2-buffer Ammunition Press, recovery from a cargo-bearing belt, correct local port/belt disconnection through the existing `_exit_tree` path, keeping neighboring belt cargo intact, and a final accounting of **19/19** recoverable units.
- For this checkpoint, the recovery destination is an independent in-memory `InventoryComponent`, **not** yet a visible or pickable salvage crate. The test manually invokes removal only after escrow succeeds. Automatic damage, health-triggered world deletion, wreckage, belt health and enemy belt targeting remain unchanged.

**Design reminder:** The final game destroys buildings and damaged conveyor segments. The temporary zero-HP Disabled state is a test safeguard only. First establish 100% recoverable test escrow (an accounting baseline); tune salvage/loss rates later when dedicated world drops exist. Do not expose player demolition or combat deletion through this new helper until Godot has validated it.


### Step 09.18A — Destruction cargo regression accepted (12/12)

The developer ran `res://tests/destruction_cargo_recovery_test.tscn` in Godot 4.6.2 and supplied output confirming **ALL 12 DESTRUCTION CARGO RECOVERY TESTS PASSED**. After correcting the intentionally malformed inventory-key preflight in `destruction_cargo_recovery.gd`, both source and destination accounting passed, including all **19/19** ore, ingot and ammunition units recovered without duplication. The linked-belt test also confirmed surviving neighbors retain cargo and detach only the removed segment.

### Step 09.18B — Controlled destruction transaction (code committed, Godot test pending)

- Added `scripts/components/destruction_transaction.gd` (`DestructionTransaction`). It is a standalone helper **not wired into live zombie damage or Build Mode**. It accepts only real `player_built` buildings with `BuildingRuntime` or a `ConveyorSegment`; rejects preview ghosts, arbitrary nodes, queued sources and unattached recovery caches.
- Its `try_destroy()` first checks complete salvage capacity and moves all source-owned inventory into a separately live `InventoryComponent`. On success it disables source processing, explicitly severs the source's reciprocal building-port or belt links, then queues **only that source** for deletion. Failed preflight leaves the structure and physical connections untouched.
- Added `tests/controlled_destruction_transaction_test.tscn` with **12 checks** for rejection cases, insufficient recovery capacity, warehouse-output and two-belt linking, source removal, immediate port disconnection, duplicate removal refusal, neighbor cargo preservation, separately destroying cargo-bearing belts, multi-buffer manufacturer recovery, invalid key refusal and exact **19-unit** final conservation.

**Current boundary:** This is the first test-only transaction capable of genuinely queueing buildings and belts for removal. Live damage-to-destruction, enemy conveyor targeting, wreckage visuals and actual in-world salvage cache/pickups remain separate milestones. The 12-case scene requires an F6 pass before any live behavior is changed.


### Step 09.18B — Controlled destruction accepted (12/12)

The developer ran `res://tests/controlled_destruction_transaction_test.tscn` in local Godot 4.6.2, confirming **ALL 12 CONTROLLED DESTRUCTION TRANSACTION TESTS PASSED**. Validated invalid/preview rejection, insufficient salvage capacity preventing removal, immediate local port/belt disconnection, queued removal, duplicate refusal, neighboring belt cargo preservation, independent belt destruction, two-buffer Ammunition Press recovery, invalid item refusal, and **19/19** item accounting.

### Step 09.18C — Main-world salvage placeholders (committed, F6 test pending)

- Created `WorldSalvageCache` (`scripts/components/world_salvage_cache.gd`) and `scenes/logistics/world_salvage_cache.tscn`, a non-colliding placeholder wreckage mesh with a readable count and a dedicated unlimited `InventoryComponent`. Empty sites read `WRECKAGE`; salvaged sites read `SALVAGE: N`. The object is in `salvage_caches`, **not** `player_built`.
- Added `WorldDestructionService` (`scripts/components/world_destruction_service.gd`) as a Main scene child. Its `try_destroy_with_salvage(source)` creates the cache as an independent sibling at the affected site, uses the previously tested `DestructionTransaction.try_destroy()`, and retains its cargo even after the source is freed. Failed transactions remove the empty placeholder immediately rather than leaving phantom salvage.
- New `res://tests/world_salvage_destruction_test.tscn` uses the real Main scene and checks 12 cases for valid targets, junk/ghost exclusion, stocked storage with two connected belts, accurate 7-item salvage at a destroyed site, repeated deletion refusal, invalid manufacturer inventory refusal, two-buffer manufacturer salvage, individual adjacent belt destruction, empty wreckage, summed **15-item** conservation across five independent surviving world caches, and enemy/world safety.

**Validation boundary:** Repository checks pending completion; **no local F6 run has passed yet**. Main has the inactive service but live zombies do not invoke it on zero HP. Salvage is a runtime in-world holder and visual placeholder, **not yet player-pickable or persisted to disk**, and 100% recovery remains prototype balancing. Conveyor HP, zombie belt targeting, damage-triggered removal, special wreckage FX and player salvage collection will be handled in later checkpoints.


### Step 09.18C — Main-world salvage regression accepted (12/12)

The developer supplied Godot 4.6.2 output from `res://tests/world_salvage_destruction_test.tscn`: **ALL 12 MAIN-WORLD SALVAGE DESTRUCTION TESTS PASSED**. Validated five independent world-owned wreckage caches, empty wreckage and two cargo-bearing belts, rejection of duplicate/invalid deletion, uninterrupted surviving world nodes, and conservation of **15/15** initial item units after source removal.

### Step 09.18D — Health-triggered Main-world building destruction (committed, F6 test pending)

- `BuildingHealthComponent._ready()` now connects the existing `health_depleted` signal to the owning Main scene's `WorldDestructionService`, when present. Preview ghosts and independent isolated scenes remain excluded. No automatic removal is implemented for enemy targets or belts here.
- `WorldDestructionService.destroy_on_zero_hp` defaults to **true** in Main. When health reaches zero, the service invokes its already-tested inventory recovery, reciprocal port cleanup, stopped-processing state and single-source queue for deletion. A world-owned cache with recovered items remains at the original site. An unsuccessful salvage transaction **never deletes source data**; it leaves a 0-HP structure in place and increments `failed_health_destructions` for later recovery/retry.
- The service clears any `WorldInteraction` selection and `ProductionDebugHUD` selection referencing a successfully destroyed structure before frame-end freeing. Movement/target selection skips queued or dead structures and should reacquire intact targets.
- The historical `building_health_integration_test.gd` (11 checks) and `live_zombie_melee_integration_test.gd` (12 checks) explicitly switch off automatic world destruction so their original zero-health-disabled safety contracts can still be tested independently.
- New `res://tests/live_zombie_destruction_test.tscn` (**12 checks**, local Godot run pending) tests the Main scene, preview protection, real Storage with stocked adjacent belts, nine nonlethal hits, tenth-hit removal, salvage and HUD cleanup, local disconnections, surviving conveyor cargo, zombie reacquisition of another building, non-melee health depletion triggering the same path, invalid-inventory rollback and explicit recovery retry. Expected accounting: **12 recovered units across three wreckage caches + two surviving belt units**.

**Validation boundary:** The code is committed but live F5 gameplay must wait until the new F6 regression passes. The final game also requires damageable belts, zombie belt targeting, salvage pickup/persistence, and improved wreckage presentation; none is claimed complete.


### Step 09.18D — Zombie-triggered building destruction accepted (12/12)

On **2026-11-02**, the developer ran `res://tests/live_zombie_destruction_test.tscn` in Godot 4.6.2. All **12/12** integration checks passed (PASS A–L; screenshot provided). The tested Main scene automatically listened for building health depletion. A live moving zombie struck a selected, stocked Storage structure: its tenth hit took HP to zero and queued actual deletion. The world-owned salvage held seven Storage items and the selection/HUD cleared; both neighboring conveyor belts stayed intact and retained their cargo. The zombie subsequently targeted and damaged another healthy building, whose depletion through a separate damage call used the same destruction transaction. A deliberately malformed inventory failed salvage safely, leaving a 0-HP structure available for later retry; the recovery was then completed. End-of-test accounting: **12 units stored across three wreckage caches plus two units on the surviving belts**.

**Next acceptance gate:** Player-controlled **F5** test, not yet confirmed. Build a real Extractor or Storage near the prototype moving zombie (avoid placing a defensive turret nearby), observe the final 0-HP attack physically removing the structure, verify wreckage remains with the correct `WRECKAGE` or `SALVAGE: N` placeholder, and ensure the selection HUD clears cleanly.

**Still pending:** zombie damage to conveyor segments, isolated belt health/destruction tests, recoverable player pickups, save/load of salvage, production-chain hardening, final wreckage FX, and progression toward the customizable build catalog/hotbar.


### Step 09.18E — Zombie destruction verified in real gameplay

On **2026-11-02**, the developer ran regular F5 gameplay and showed a green moving zombie next to a visible **WRECKAGE** placeholder where its attacked player structure had been. The previous structure was no longer visible; the Production Debug HUD was not showing it. This is the accepted player-controlled destruction/wreckage milestone. The screenshot shows an **empty wreckage** placeholder; stored material recovery and preservation of neighboring conveyors were verified separately by the passing 12-case regressions.

### Step 09.18F1 — Conveyor durability across all belt geometries (committed; local validation pending)

- Added `scripts/components/conveyor_health_component.gd` (`ConveyorHealthComponent`). Every belt starts at **50 HP**, accepts clamped positive damage, emits a single depletion signal at zero, and ignores repeated hits after depletion. It does **not** itself remove a belt or trigger attacks yet.
- Attached the component to all three physical belt scene shapes used by `ConveyorPieceSelector`: `conveyor_straight.tscn`, `conveyor_corner.tscn` (right), and `conveyor_corner_left.tscn`. Both corner scenes now include an independent one-item `CargoInventory` for safe future salvage/recovery. These added corner buffers do **not** add transport timers or alter the established belt-transfer mechanism.
- Added `res://tests/conveyor_durability_foundation_test.tscn` (**12 checks pending local F6 validation**): Main scene compatibility, straight/right/left durability and buffer counts, ghost safety, physically attached Storage and two straight belts, invalid/partial/overkill damage, exactly-once depletion signaling, no automatic removal, malformed cargo fail-closed behavior, explicit zero-HP straight-belt destruction and neighbor preservation, cargo-bearing right-corner and empty left-corner salvage, and final accounting of two recovered units plus one live neighboring belt unit.
- **Scope boundary:** Automatic destruction on belt HP depletion and zombie targeting/melee against belts are NOT enabled in Step 09.18F1. Existing player demolition checks remain unchanged. The next checkpoint will wire belt targeting and guarded destruction only after the separate health regression passes.


### Step 09.18F1 — All three conveyor durability variants accepted (12/12)

The developer supplied local Godot 4.6.2 output for `res://tests/conveyor_durability_foundation_test.tscn` confirming **ALL 12 CONVEYOR DURABILITY FOUNDATION TESTS PASSED**. Straight and left/right corner belts each initialized at 50 HP with one cargo slot. The test verified overkill clamping, a single depletion event, construction-preview safety, no automatic deletion in its isolated fixture, existing Storage/belt connections, invalid cargo refusal, three explicit destruction transactions and conserved item counts (two units in salvage plus one on a surviving belt).

### Step 09.18F2 — Zombie-targeted conveyor destruction (code committed; F6 pending)

- `ZombieApproachComponent` now supports exported `target_conveyors` (default false for standalone historical regressions, explicitly true in `prototype_moving_zombie.tscn`). Valid conveyor targets require `player_built`, no preview/deletion, and an intact `ConveyorHealthComponent`. Healthy buildings remain eligible; the nearest valid target wins. Depleted belts are skipped when retargeting.
- `ZombieMeleeComponent` now routes existing 10-damage, one-second-cooldown melee attacks through either `BuildingHealthComponent` or `ConveyorHealthComponent`, depending on the selected target. Building-only tests retain their original safeguards.
- `ConveyorHealthComponent` connects `health_depleted` to the owning Main-world service, when present. `WorldDestructionService.destroy_conveyors_on_zero_hp` defaults true in Main and triggers the already-tested lossless salvage transaction, local port and belt disconnections, source removal, wreckage, and selection cleanup. If recovery fails, the belt is not removed and can be recovered explicitly later.
- Existing movement and building-melee regression fixtures explicitly set `movement.target_conveyors = false`; the historical F1 durability suite sets `service.destroy_conveyors_on_zero_hp = false` to preserve its original manual-deletion checks.
- New `res://tests/live_zombie_conveyor_destruction_test.tscn` (**12 assertions groups, pending local Godot F6**) exercises Main-world live zombie belt preference, preview exclusion, physical Storage→belt→belt connections, melee range and cooldown, a fifth 10-HP hit destroying an occupied straight belt, local disconnection and neighboring cargo preservation, retargeting and damaging another straight belt, invalid cargo fail-closed recovery with manual retry, and destroying both corner shapes with salvage conservation.

**Validation boundary:** Code has been committed but Godot and live player-controlled F5 gameplay have not yet validated the new belt-targeting behavior. Existing wreckage remains an uncollectable runtime placeholder. Do not regard the customizable build hotbar as implemented; it remains planned after the destruction milestone.


### Step 09.18F2 — Diagonal belt arrival regression fix (pending local re-test)

The first local F6 run of `res://tests/live_zombie_conveyor_destruction_test.tscn` stopped at the PASS I retargeting arrival assertion (line 166 in the initial revision): a moving zombie had selected the second intact conveyor after destroying its upstream neighbor, but `movement_status` had not yet become `At Structure`. This occurred **after** the test's initial destruction and salvage checks. Root cause is suspected floating-point drift at the diagonal 1.5-unit stopping boundary, not proven until local re-test.

Updated `ZombieApproachComponent` to treat movement within **0.001 world units** above stopping distance as arrived; the move distance and combat range are unchanged. Updated PASS I to allow up to four normal 0.1-second movement ticks to settle and to print zombie position, selected target and movement status if the assertion still fails. No changes were made to inventory transfer, source deletion, damage, or belt geometry. The full 12-case run and relevant historical movement regressions remain **unverified after this correction**.


### Step 09.18F2 — Live zombie conveyor destruction regression accepted (12/12)

On **2026-11-02**, the developer reran `res://tests/live_zombie_conveyor_destruction_test.tscn` in Godot 4.6.2 and provided output confirming **ALL 12 LIVE ZOMBIE CONVEYOR DESTRUCTION TESTS PASSED** (PASS A–L). The first run had stopped on the second-belt arrival assertion in PASS I; after adding a **0.001-unit arrival tolerance** and bounded diagnostic settling to the regression, the entire suite passed.

The accepted run validated: Main-world belt targeting and guarded destruction; construction-preview exclusion; connected Storage → first belt → second belt with cargo; approach/range gating and 10-HP melee; one-second attack cooldown; fifth hit destroying a 50-HP straight belt; local connection severing and preservation of Storage/neighbor belt stock; retargeting the next straight belt; invalid cargo blocking deletion until recovery retry; and zombie-triggered removal of a loaded right-corner and empty left-corner belt. Final item accounting: **one salvaged ore, one salvaged ingot, one salvaged ammunition round, plus three ore still stored in the surviving Storage**.

**Remaining acceptance:** Player-controlled F5 demonstration of conveyor destruction, wreckage, and intact adjacent conveyor pieces. After F5, rerun the relevant historical movement, melee, building destruction, and conveyor logistics regressions because enemy targeting and arrival tolerance changed. Do not treat salvage collection, save/load, or the planned customizable build catalog/hotbar as complete.


### Step 09.18F3 — Conveyor destruction observed in playable F5 world

On **2026-11-02**, the developer showed two distinct **WRECKAGE** placeholders near the moving green zombie in regular gameplay, confirming player-placed conveyor destruction now produces visible wreckage. The Production Debug HUD said **No object selected**, consistent with the selected destroyed segment being removed. Cargo preservation and intact neighboring belt behavior had previously passed the 12-case integration regression, but cannot be inferred independently from this screenshot.

**User-reported UI gap:** Clicking an intact conveyor did not reveal its health. Root cause in `ProductionDebugHUD._refresh_display()`: it only handled resource-node and BuildingRuntime branches; `ConveyorSegment` objects have neither, so their HP was not displayed. The empty-selection label after destruction is expected.

### Step 09.18F4 — Conveyor durability, cargo and connection HUD (code committed; F6 pending)

- `scripts/production_debug_hud.gd` now checks for `ConveyorSegment` before resource nodes and buildings. The shared HUD renders the selected belt's identity, **HP current / maximum**, **Intact / Destroyed**, actual `CargoInventory` count and item display names, plus physical input/output link status (building port, previous/next conveyor, disconnected).
- The change is read-only; no conveyor transport, collision, melee, durability, or damage/destruction code was modified. Existing non-conveyor HUD displays keep their original paths. The activity progress bar remains hidden for conveyors.
- Added `res://tests/conveyor_health_hud_test.tscn` (**12 checks; local Godot 4.6.2 verification pending**), covering WorldInteraction selection, all three belt shapes, dynamic HP and cargo changes, building/neighbor belt links, HUD progress visibility, automatic clearing of selection upon damage-triggered belt destruction, salvage accounting, and reselecting the intact next segment.

**Next:** Run the new HUD test scene in Godot, fix any resulting errors, then verify by F5 selecting an intact belt and watching its displayed HP change while the zombie attacks. Before closing the destruction milestone, rerun important legacy logistics/movement/combat regressions. The customizable Build Catalog/hotbar remains the next planned major UI feature.


### Step 09.18F4 — Conveyor health and cargo HUD accepted (12/12)

On **2026-11-02**, the developer ran `res://tests/conveyor_health_hud_test.tscn` in Godot 4.6.2 and supplied output confirming **ALL 12 CONVEYOR HEALTH HUD TESTS PASSED** (PASS A–L). The local run verified a clean initial HUD, selection and 50/50-HP display across straight and both corner segments, changes to displayed HP after damage, live inventory quantities and item names, connected building/downstream/previous-belt input-output labels, hidden production progress for belts, selected-belt removal clearing HUD/selection, cargo preserved in wreckage, and reselecting the surviving downstream belt.

**Next acceptance:** In regular F5 gameplay, select an intact belt with a zombie approaching and verify the Production Debug HUD changes from **HP: 50 / 50** through 10-HP decrements, then clears when that belt is destroyed. This manual check has **not yet been provided**. Afterward, run a final historical regression set for movement, melee, building destruction, conveyor logistics and cargo conservation, including the new arrival tolerance and both types of damageable targets. Preserve the planned unlocked-building catalog and customizable quickbar as the next major UI phase once the destruction milestone is accepted.


### Step 09.18F5 — Conveyor durability HUD confirmed in player-controlled F5 gameplay

On **2026-11-02**, the developer submitted a screenshot of the actual F5 game showing a **yellow-selected intact conveyor** next to the moving green zombie. The Production Debug HUD showed **Conveyor Durability: HP 40 / 50, Status: Intact**, **Cargo: Empty, Capacity: 0 / 1**, and **Input: Disconnected, Output: Disconnected**. This confirms the new selected-belt HUD displays a partially damaged live conveyor; the missing-health-display issue is resolved. The screenshot also shows multiple earlier wreckage caches from destroyed conveyors. Automatic selection/HUD clearing on final destruction is separately covered by the passing **12/12** HUD regression and prior F5 wreckage observation.

Minor future UI polish: selected belt's runtime node name currently appears as a Godot-generated label such as `@Node3D@10`; show an intuitive building/belt type or user-facing name in a later UI pass, without changing the working combat or cargo flows.

### Step 09.18 — Final historical regression gates (planned)

Before calling full building-and-conveyor destruction complete and moving into the **customizable Build Catalog/hotbar**, rerun representative Godot scenes in three manageable rounds:

1. **Movement and combat** — `prototype_moving_zombie_test.tscn`, `live_moving_zombie_integration_test.tscn`, `zombie_building_melee_test.tscn`, `live_zombie_melee_integration_test.tscn`. These must remain compatible with the new `target_conveyors` flag and 0.001-unit arrival tolerance.
2. **Factory/physical logistics** — `conveyor_physical_only_conservation_test.tscn`, `ammunition_press_build_mode_test.tscn`, and `defensive_turret_build_mode_test.tscn` (additional belt connection tests as needed), guarding item conservation and core construction.
3. **Destructive recovery** — `live_zombie_destruction_test.tscn`, `controlled_destruction_transaction_test.tscn`, `world_salvage_destruction_test.tscn`, `live_zombie_conveyor_destruction_test.tscn`. Existing focused conveyor HUD and 50-HP durability suites already passed and can be revisited if any regression fails.

**Status:** The new F5 HUD demonstration is accepted. These historical reruns have **not yet been confirmed** after the latest combat/UI changes. Do not mark regression rounds as passed until local Godot results are supplied.


### Step 09.18 — Final regression Round 1 accepted, Round 2 pending

The developer confirmed that all **four movement and combat test suites passed locally in Godot 4.6.2** on 2026-11-02. These covered the prototype moving zombie, main-world moving zombie, isolated building melee and main-world melee integration. The existing building-only test fixtures therefore remain compatible with recent enemy conveyor targeting and movement-arrival adjustments.

**Next gate — Round 2 factory and physical logistics:** Run the three existing scenes for physical-only resource conservation (**9 checks**), ammunition production building placement (**9 checks**), and defensive building placement (**12 checks**), for a total of **30 checks**. These round-two reruns are pending; do not mark them passed without local results. Round 3 will cover destruction and salvage recovery. No gameplay code was changed for this documentation checkpoint.


### Step 09.18 — Final regression Round 2 accepted (30/30)

On **2026-11-02**, the developer confirmed that all three factory/logistics regression suites passed again in local Godot 4.6.2. `conveyor_physical_only_conservation_test.tscn` passed **9/9**, `ammunition_press_build_mode_test.tscn` passed **9/9**, and `defensive_turret_build_mode_test.tscn` passed **12/12**, totaling **30/30** checks. Physical resource accounting, ammunition-press build logic and turret build/connection safeguards therefore remain compatible with the new zombie building/conveyor destruction changes.

### Step 09.18 — Final regression Round 3 (pending)

The final destruction and salvage verification uses four existing Godot F6 scenes, each containing 12 checks (**48 checks total**): `live_zombie_destruction_test.tscn`, `controlled_destruction_transaction_test.tscn`, `world_salvage_destruction_test.tscn`, and `live_zombie_conveyor_destruction_test.tscn`.

Confirm lossless building/belt destruction, nearby conveyor survival, independent world wreckage caches, guarded recovery refusal and retry, live zombie targeting and conveyor breakage. The focused conveyor health HUD has already passed 12/12 and has F5 gameplay evidence, so rerun it only if a new regression affects selection or UI.

**Status:** Rounds 1 and 2 are accepted; Round 3 is not yet rerun after the latest changes. Do not call the overall destruction milestone closed until the local results arrive. Customizable Building Catalog/1–9 hotbar is scheduled next.


### Step 09.18 — Destruction milestone accepted after final Round 3 (48/48)

On **2026-11-02**, the developer confirmed the four final destruction and salvage test suites all passed again in local Godot 4.6.2, **48/48 checks**. These covered Main-scene zombie building destruction, guarded transactions, persistent-in-scene salvage/wreckage, and zombie conveyor/corner destruction. With Round 1 (all four movement/combat suites) and Round 2 (**30/30 factory/logistics checks**) already passed, the **core building and conveyor destruction milestone is complete**.

Acceptance includes automatic zombie damage to 100-HP buildings and 50-HP belt segments, local disconnection, destroyed source removal, world wreckage placeholders and lossless inventory/cargo accounting. Manual F5 gameplay previously confirmed building and conveyor wreckage and the selected conveyor's **40/50 HP** display.

Deferred systems: player-pickable salvage, persistence between saves, destruction balancing, final debris effects, more advanced zombie navigation and waves. These do not invalidate the accepted foundation.

### Phase 1G1 — Stable building IDs and configurable hotbar model (committed; F6 pending)

- Existing `WorldInteraction` uses nine Build Mode slots indexed into `buildable_definitions`; the Build HUD hardcodes all nine labels, and numerous specialized Conveyor Belt branches compare `selected_building_index == 4`. Changing keys prematurely would break logistics, so live input/UI remains unchanged at this step.
- Added `scripts/components/build_hotbar_configuration.gd` with `BuildHotbarConfiguration`, an independent nine-slot assignment model. Catalog items are keyed by stable `BuildingDefinition.building_id`; all nine prototype buildings start unlocked until the progression system exists.
- The model supports default ordering, catalog enumeration, lookup by slot, swapping existing assignments, clearing and replacing slots, locking/unlocking with safe unequip, and JSON-compatible save/restore payloads (versioned ID strings). Restoration rejects malformed payloads and ignores missing, duplicated or currently locked IDs. No file is written on disk yet.
- Added `res://tests/build_hotbar_configuration_test.tscn` with **12 checks awaiting local Godot validation**, including Turret → key 1, Storage → key 9, moving the belt out of slot 5, restoring a JSON snapshot after catalog reordering, unlock restrictions and malformed save safety.
- **Next:** Pass the isolated F6 test. Then replace the 4-index Conveyor Belt assumptions with definition identity/type in a separate regression, connect configurable slot selection to the existing Build HUD, and add the unlocked-building menu and disk persistence. The current playable factory and combat systems remain unchanged.


### Phase 1G1 — Stable-ID hotbar model accepted (12/12)

The developer supplied local Godot 4.6.2 output confirming **ALL 12 BUILD HOTBAR CONFIGURATION FOUNDATION TESTS PASSED** on 2026-11-02. The test verified all nine unique building IDs, unchanged default slots, Turret → 1 and Storage → 9 swaps, moved/cleared Conveyor Belt assignments, unlock guards, stable-ID JSON-compatible snapshots and restores after catalog reordering, and malformed/duplicate/locked ID rejection without changing live Build Mode.

### Phase 1G2 — Conveyor tool identity migration (code committed; F6 pending)

The existing `scripts/world_interaction.gd` contained **22** comparisons of `selected_building_index == 4` or `!= 4` governing conveyor-specific snap previews, corner discovery, bridge/offset placement, debug keys H/J/K and ghost-scene overrides. They all now call the shared `_is_conveyor_selected()` helper, which tests `_get_selected_building_definition().building_id == &"conveyor_belt"`. The helper avoids relying on the definition's current array position or assigned quick-build number. No changes were made to actual conveyor transport/snapping algorithms, Build HUD labels, current numeric input routing, or physical placement geometry.

Added `res://tests/conveyor_building_identity_test.tscn` (**12 checks pending local Godot 4.6.2 validation**). This uses an isolated Main scene to verify default Conveyor Belt selection and both left/right ghost-scene overrides, rejected overrides when Turret is selected, all nine original building identities, hotbar data-model assignment independently from Main, and a simulated catalog reordering that puts Conveyor Belt at index **0** and Test Extractor at index **4**. It then proves corners still preview at index 0, the old index 4 cannot trigger conveyor previews, invalid selections remain harmless, and the original catalog/ghost cleanup still work.

**Regression boundary:** This is an identity-only refactor. Arbitrary number-key remapping and user-facing Build Catalog are **not enabled** until this F6 test and related physical conveyor placement regressions pass. Continue respecting the current 1–9 Build HUD labels and existing construction controls.


### Phase 1G2 — Stable conveyor identity regression accepted (12/12; 2026-11-04)

The developer supplied a Godot 4.6.2 screenshot confirming **ALL 12 CONVEYOR BUILDING IDENTITY TESTS PASSED**. The migration from 22 `selected_building_index == 4` / `!= 4` branches to the stable `building_id == &"conveyor_belt"` helper preserved straight, left-corner and right-corner placement ghosts. Tests also passed when Conveyor Belt occupied catalog index 0 and Extractor occupied the former index 4, including guards against using conveyor previews on non-conveyor types. The original catalog and placement cleanup remained intact.

The messages `Extractor has no resource node` appeared **after** the success sentinel and are expected for temporary Extractor instances/ghosts in an isolated test without a deposit; they do not overturn the 12 passed assertions.

Before activating hotbar remapping, rerun eight relevant historical Godot F6 scenes (no code changes in this checkpoint), arranged in two focused groups:

- **Round A (37 checks):** `conveyor_building_placement_snap_test.tscn` (8), `conveyor_receiver_auto_snap_test.tscn` (11), `conveyor_source_corner_auto_snap_test.tscn` (10), `conveyor_terminal_building_corner_test.tscn` (8). These protect building input/output snaps and in-place source, receiver and terminal corner conversions.
- **Round B (43 checks):** `conveyor_missing_corner_placement_test.tscn` (9), `conveyor_dual_ended_bridge_test.tscn` (11), `conveyor_fractional_bridge_test.tscn` (12), `conveyor_offset_corner_bridge_test.tscn` (11). These protect missing corners and short, full-length and offset connectors.

**Status:** 1G2 identity regression accepted, historical targeted rounds **pending local Godot reruns (80 checks)**. The active numeric input layout and Build HUD remain fixed. The UI/catalog work follows these passes, with persistent hotbar save/load and eventual unlock progression still unimplemented.


### Phase 1G2 — Targeted conveyor regression Round A accepted (37/37; 2026-11-04)

The developer confirmed that **all four** historical building-port snapping and conveyor-corner F6 scenes passed in Godot 4.6.2 after the 22-branch conveyor identity refactor. The results were: `conveyor_building_placement_snap_test.tscn` **8/8**, `conveyor_receiver_auto_snap_test.tscn` **11/11**, `conveyor_source_corner_auto_snap_test.tscn` **10/10**, and `conveyor_terminal_building_corner_test.tscn` **8/8**, for **37/37**. This confirms those established building-port and corner behaviors remain compatible with selecting Conveyor Belt by `building_id`.

**Next gate — Round B (43 checks; pending local F6):** `conveyor_missing_corner_placement_test.tscn` (9), `conveyor_dual_ended_bridge_test.tscn` (11), `conveyor_fractional_bridge_test.tscn` (12), and `conveyor_offset_corner_bridge_test.tscn` (11). All four scenes are verified present on GitHub main, but **have not yet been rerun** after this refactor.

No production code or hotbar input behavior was modified in this documentation checkpoint. Once Round B passes, proceed incrementally with actual configurable numeric key selection and the dynamic Build HUD, preserving the full conveyor placement/snap pipeline.


### Phase 1G2 — Conveyor gap and bridge regression Round B accepted (43/43; 2026-11-04)

The developer confirmed all four historical bridge/gap F6 suites passed locally in Godot 4.6.2 after the stable-ID conveyor-tool refactor. The reported results were `conveyor_missing_corner_placement_test.tscn` **9/9**, `conveyor_dual_ended_bridge_test.tscn` **11/11**, `conveyor_fractional_bridge_test.tscn` **12/12**, and `conveyor_offset_corner_bridge_test.tscn` **11/11**, for **43/43**. Together with Round A **37/37**, Phase 1G2's **80/80 targeted conveyor regression checks passed**. This accepts the transition from fixed index-4 Conveyor Belt gates to stable `building_id` checks.

### Phase 1G3 — Configurable number-key selection and dynamic Build HUD (committed; F6 pending)

- Updated `scripts/world_interaction.gd` to instantiate a `BuildHotbarConfiguration` at startup, register the nine existing `BuildingDefinition` assets, and apply the original default hotbar assignments. Number keys 1–9 now resolve **slot → stable building ID → active definition index** through `_select_hotbar_slot()`. This preserves the existing underlying placement/snapping implementation and the original InputMap handling for keys 1–5, with physical keys 6–9 as before.
- Added controller APIs `assign_hotbar_slot()`, `clear_hotbar_slot()`, and `set_hotbar_unlocked()` for a future unlocked-building catalog menu. A cleared/locked slot is visually empty and its key does nothing; if the currently selected building loses its assignment, the controller selects an available fallback or clears the placement ghost if no slots remain.
- Updated `scripts/build_hud.gd` to show the actual assigned building for each key and highlight the slot containing the selected building. The familiar prototype labels are retained by small player-facing name aliases. An unassigned slot displays `Empty`. `selected_building_index` continues referring to the real definition for placement.
- Added `res://tests/build_hotbar_keyboard_integration_test.tscn` (**12 cases; local Godot run pending**). It drives the real Main-world keyboard handler and Build HUD, confirming legacy keys, assigning **Turret → 1** and **Storage → 9**, moving **Conveyor Belt → 4** while preserving right/left corner ghosts, changing key 5 to Smelter, empty slot behavior, unlock restrictions, reset defaults, and Build Mode cleanup.
- **Deliberate scope boundary:** The keyboard remapping APIs are live, but **no user-facing catalog menu exists yet** and assignments **are not saved to disk**. Do not call the new UI complete until a player can open a menu and persist changes across sessions. The 1G3 Godot regression still needs a local run before normal F5 validation.


### Phase 1G3 — First keyboard/HUD F6 regression stopped at Turret preview identity (2026-11-04)

The first local `res://tests/build_hotbar_keyboard_integration_test.tscn` run stopped at the **PASS F** assertion (original line 88) after successfully establishing the Turret's mapped building definition and stable ID. The old assertion tested whether the new preview scene root's `Node.name` began with `PrototypeDefensiveTurret`. Repeated quick-build selection can queue the previous preview for deletion until frame-end, causing Godot to give the newly instanced preview an autogenerated name; this name is not a reliable gameplay identity.

Replaced both name-based assertions (default key 9 and remapped key 1) with `_is_turret_preview()`, checking the active building ID, actual packed-scene path, `TurretComponent` type, and `construction_preview` group. No production code, HUD logic, keyboard routing, inventory, or conveyor placement was changed in this correction.

**Status:** Test-only correction committed; **full 12/12 local rerun pending**. Do not mark 1G3 accepted until the Godot result is supplied.


### Phase 1G3 — Live build hotbar keyboard/HUD regression accepted (12/12)

The developer reran `res://tests/build_hotbar_keyboard_integration_test.tscn` in local Godot 4.6.2 and supplied output showing **ALL 12 BUILD HOTBAR KEYBOARD INTEGRATION TESTS PASSED**. The previously failing Turret preview assertion now checks actual scene/component identity instead of the unstable auto-generated runtime node name. All A–L checks passed: default hotbar layout and labels, keys 5 and 9, remapping Turret to key 1, Storage to key 9, Conveyor Belt to key 4 (including both corner previews), key 5 becoming Smelter, inert empty slots, unlock restrictions, default reset and Build Mode cleanup.

The `Extractor has no resource node` diagnostic was emitted after the success sentinel, as expected for temporary prototype Extractor instances without a deposit.

**Next acceptance:** Manual F5 smoke test of the default number-key layout and dynamic Build HUD. Player-created remappings cannot yet be tested through the F5 UI because the unlocked Build Catalog/editor is still pending. Phase 1G4 will provide those controls, followed by a remapped F5 acceptance test and persistent hotbar file storage. No production code was changed during this results checkpoint.


### Phase 1G3 — Default-key highlights confirmed in F5; wreckage interaction gap found

On **2026-11-04**, the developer confirmed the **1–9 shortcut highlights switch correctly** during regular F5 gameplay. The associated screenshot showed a functioning factory, enemies and surviving wreckage, including a `SALVAGE: 15` cache. The exact individual key mappings were covered separately by the accepted 12/12 keyboard integration suite. Phase 1G3 is accepted.

**Usability report:** Wreckage could not be clicked, highlighted, inspected or cleaned up. This is due to the original `WorldSalvageCache` scene having only a mesh/label/inventory, with no physics selection collider or selectable group. The debug HUD also lacked a salvage-specific display. The project requires safe cleanup without silently discarding recovered resources.

### Step 09.18G — Wreckage selection, inventory info and protected cleanup (committed; F6 pending)

- Added `selectable` group membership and a **Layer-2-only StaticBody3D collision box** to `world_salvage_cache.tscn`. It does not use the factory placement-blocker physics layer and is never added to `player_built`, so zombie structure targeting and normal conveyor placement rules are unchanged.
- `WorldSalvageCache` now implements `set_selected()` and `set_demolition_hover()` with yellow inspection highlighting, red empty-wreckage demolition hover and amber protected-stock hover. The new `can_clear_safely()` check requires the inventory dictionary to be truly empty; it refuses malformed/unknown inventory contents and does not use only the reported total.
- The `ProductionDebugHUD` now detects selected wreckage independently of building/conveyor components, displays **Total Items**, the actual stored item names and quantities and a clear `Protected: recover contents before cleanup` or `Empty: can remove in Demolition Mode` instruction. It remains read-only.
- `WorldInteraction` includes WorldSalvageCache in demolition targeting and exposes `_try_clear_salvage_cache()`: only empty wreckage can be queued for removal. If selected, its HUD and selection clear immediately; stocked wreckage is never deleted or drained by the demolition action.
- New `res://tests/wreckage_selection_cleanup_test.tscn` contains **12 isolated Main-world integration checks pending local F6 validation**. These cover salvage ownership and groups, selection-layer raycast, highlighting/HUD, progress-bar absence, empty cleanup, cargo-bearing wreckage item inspection and protection, malformed contents refusal, a simulated lossless inventory transfer into an independent test container and cleanup only afterward, with **10/10** transferred resources preserved.
- **Scope boundary:** This checkpoint does **not** implement salvage pickup, inventory transfer from the player's hand, storage access through the world, or saving salvage between sessions. A stocked salvage cache remains protected from player demolition until a dedicated collection/recovery interaction exists. The planned in-game Build Catalog resumes after this safety checkpoint passes.
