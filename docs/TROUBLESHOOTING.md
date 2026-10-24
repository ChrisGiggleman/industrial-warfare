# Industrial Warfare — Troubleshooting Log

This document records technical problems encountered during development, their causes, fixes, and reusable lessons.

The goal is to preserve solutions that may help diagnose similar problems later.

---

## Entry Format

Each troubleshooting entry should record:

- problem or symptom
- relevant environment/system
- exact error when available
- cause
- solution
- result
- lesson learned

---

## 2026-10-11 — PowerShell Documentation Path Error

### Problem

While creating the initial Markdown files, this command failed:

```powershell
New-Item docs\DEVLOG.md -ItemType File
```

PowerShell returned a `DirectoryNotFoundException`.

### Environment

The terminal was already located at:

```text
E:\GameDev\industrial-warfare\docs
```

### Cause

The relative path added `docs\` a second time, causing PowerShell to look for:

```text
E:\GameDev\industrial-warfare\docs\docs\DEVLOG.md
```

### Solution

Used the filename directly:

```powershell
New-Item DEVLOG.md -ItemType File
```

### Result

The documentation files were created successfully.

### Lesson Learned

Relative paths are resolved from the terminal's current working directory. Check the PowerShell prompt before running file-management commands.

---

## 2026-10-12 — Camera Controller Script Did Not Execute

### Problem

The expected output:

```text
Camera controller initialized.
```

did not appear.

An earlier attempt also produced a GDScript parse error.

### Cause

After correcting the script syntax, `camera_controller.gd` was no longer attached to the `CameraRig` node.

A script existing in the project does not execute automatically unless it is attached, instantiated, autoloaded, or otherwise called by the project.

### Solution

1. Corrected the GDScript syntax.
2. Selected `CameraRig`.
3. Attached:

```text
res://scripts/camera_controller.gd
```

4. Ran the project again.

### Result

The initialization message appeared and camera behavior worked.

### Lesson Learned

When code appears correct but never runs, verify that the script is attached to the expected active node.

---

## 2026-10-12 — Variant Type Warning Treated as Error

### Problem

Godot reported:

```text
The variable type is being inferred from a Variant value, so it will be typed as Variant. (Warning treated as error.)
```

### Cause

The generic `clamp()` helper caused the result to be inferred as `Variant` under the project's strict typing/warning behavior.

### Solution

Replaced the generic call with:

```gdscript
clampf()
```

and explicitly typed related values as `float`.

### Result

The warning/error was resolved.

### Lesson Learned

When working with strictly typed floating-point values, prefer type-specific helpers such as `clampf()` when available.

---

## 2026-10-12 — GDScript Indentation Error

### Problem

Godot reported errors including:

```text
Expected indented block after "if" block
```

and, during earlier edits:

```text
Used space character for indentation instead of tab as used before in the file
```

### Cause

GDScript uses indentation as syntax.

Several edits had one of these problems:

- a line that belonged inside an `if` block was aligned with the `if`
- a block was indented one level too far or too little
- tabs and spaces were mixed

This type of issue appeared more than once while editing `world_interaction.gd`.

### Solution

- Aligned the `if` statement with the correct surrounding scope.
- Indented statements controlled by the `if` exactly one additional level.
- Used tabs consistently.
- Used VS Code's indentation tools when needed.

### Result

The scripts parsed and all affected gameplay tests passed.

### Lesson Learned

In GDScript, visual indentation is program structure. When adding a block, verify both the parent scope and every child line before running the project.

---

## 2026-10-12 — Selection Highlight Stopped Working After Refactor

### Problem

Objects were still selectable, but `ReferenceCube` and `TestBuilding` no longer changed to the selected highlight material.

### Cause

`selectable_object.gd` had been refactored to use an exported `selection_mesh` reference.

Existing scenes had no value assigned to that new Inspector property, so the script had no `MeshInstance3D` to highlight.

### Solution

Assigned the correct mesh references:

- `ReferenceCube` → `Selection Mesh = ReferenceCube`
- `TestBuilding` → `Selection Mesh = BuildingMesh`

### Result

Selection highlighting returned.

### Lesson Learned

When a refactor introduces a new exported node reference, existing scenes may require manual Inspector updates.

---

## 2026-10-12 — Build HUD Appeared but Selected Slot Did Not Highlight

### Problem

The Build HUD appeared correctly, but the selected building slot did not receive its gold/yellow highlight.

### Cause

`WorldInteraction` had a valid `Build Hud Panel` reference for visibility, but its separate `Build Hud` root reference was empty.

Without the root reference, `WorldInteraction` could not call:

```text
set_selected_building()
```

### Solution

Assigned:

```text
Build Hud Panel → BuildHUD/BuildPanel
Build Hud       → BuildHUD
```

### Result

The HUD continued to show/hide correctly and the active building slot highlighted correctly.

### Lesson Learned

A visible UI scene does not guarantee every gameplay-to-UI reference is assigned. Distinct exported references may control separate responsibilities.

---

## 2026-10-12 — Build HUD Null Instance Caused by Node Name Mismatch

### Problem

Entering Build Mode produced an error similar to:

```text
Invalid assignment of property or key 'text' on a base object of type 'null instance'
```

### Cause

`build_hud.gd` referenced:

```text
$BuildPanel/PanelMargin/BuildInfo/CancelLabel
```

but the scene node was named:

```text
Cancellabel
```

Godot node paths are sensitive to exact spelling and capitalization.

The mismatch caused the expected label reference to resolve to `null`.

### Solution

Renamed the scene node exactly to:

```text
CancelLabel
```

and verified the script path matched the scene tree.

### Result

The null-instance error was resolved and Build HUD text updated correctly.

### Lesson Learned

When `$Node/Path` references unexpectedly return `null`, compare every scene-tree name against the script path, including capitalization.

---

## 2026-10-14 — BuildingDefinition Resource Script Attached to Node3D

### Problem

After creating `building_definition.gd`, Godot reported a type-assignment error.

### Error

```text
Script inherits from native type 'Resource', so it can't be assigned to an object of type: 'Node3D'
```

### Cause

`building_definition.gd` defines data:

```gdscript
extends Resource
class_name BuildingDefinition
```

The script had accidentally been placed in the Script property of the `Main` scene's `Node3D`.

A custom `Resource` script is not a Node script and cannot be attached to a `Node3D`.

### Solution

1. Selected the affected `Main` Node3D.
2. Removed `building_definition.gd` from its Script property.
3. Kept the script as a standalone custom Resource definition.
4. Created `.tres` assets using `BuildingDefinition`.

### Result

The project loaded normally and all existing interaction systems passed testing.

### Lesson Learned

Check the base class before attaching a script to a scene node.

- `Node`, `Node3D`, `Control`, and related classes can be attached to compatible scene nodes.
- `Resource` scripts define reusable data and are typically instantiated as `.tres` resources instead.

---

## 2026-10-17 — Extraction Sensor Caused an Oversized No-Build Radius

### Problem

After adding the Test Extractor's 2.5-unit spherical `ExtractionArea`, placement checks treated a much larger region around the building as occupied.

### Cause

The placement ghost collected every descendant `CollisionShape3D` as a physical footprint, including the sensor shape belonging to an `Area3D`. The sensor indicates mining reach, not building size.

### Solution

During ghost creation, disable child collision shapes for ghost physics but include a shape in `placement_ghost_collisions` **only** when its direct parent is a `PhysicsBody3D`.

```gdscript
placement_ghost_collisions.clear()
for child in placement_ghost.find_children("*", "CollisionShape3D", true, false):
    if child is CollisionShape3D:
        child.disabled = true
        if child.get_parent() is PhysicsBody3D:
            placement_ghost_collisions.append(child)
```

This keeps the physical footprint separate from the extraction range. The extractor's `ExtractionArea` remains available as a shape resource for the separate manual range query.

### Result

The large false no-build zone disappeared, while existing building collision blocking continued to work.

### Lesson Learned

Distinguish **physical occupancy** (`PhysicsBody3D` shapes, Layer 3 blocker queries) from **sensing/interaction reach** (`Area3D` shapes, Layer 2 detection).

---

## 2026-10-17 — Placement Helper Accidentally Removed During Script Editing

### Problem

While adding extractor-specific placement validation, `world_interaction.gd` temporarily lost the existing `_is_placement_clear()` method.

### Cause

A replacement edit in a long script overwrote an adjacent helper section.

### Solution

Restored `_is_placement_clear()` under the physical placement validation section. It tests only the recorded physical ghost collision shapes against the placement blocker collision mask. Kept `_extractor_has_resource_node()` as a **separate** helper so non-extractor buildings do not require ore.

### Result

The project parsed again, and both generic footprint blocking and extractor range restrictions passed runtime tests.

### Lesson Learned

Use large section headers to find replacement boundaries, prefer small surgical edits, and verify neighboring function definitions after modifying long scripts.

---

## 2026-10-17 — GDScript Indentation Error in Extractor Placement Preview

### Problem

After linking resource-range checks to placement-preview colors, Godot reported an indentation/unindent error around the ghost-material color block.

### Cause

The inserted code did not preserve the correct tab-based nesting of `if result`, placement validation, and material updates.

### Solution

Reindented the entire affected conditional block using tabs, preserving the intended sequence:

1. Raycast to ground and snap ghost position.
2. Check physical footprint with `_is_placement_clear()`.
3. If the ghost contains `ExtractorComponent`, also call `_extractor_has_resource_node()`.
4. Apply valid/invalid ghost color.
5. Set placement invalid when there is no ground hit.

### Result

The script compiled without errors. User-tested behavior confirmed blocked far-away extractor placement, permitted near-deposit placement, and normal placement for the large test building.

### Lesson Learned

GDScript indentation is executable structure, not presentation. Match the parent block's indentation before adding nested conditions.

---

## 2026-10-20 — Chat 05: Duplicate Discovery Logic After Function Replacement

### Problem

While updating `LogisticsTransferComponent._process()` to activate timed transfers, the previous discovery-only statements remained after the new transfer-debug print block. This left a **second** `var nearby_storage` (and `var current_storage_id`) declaration inside the same function.

### Cause

Only part of the old `STORAGE DISCOVERY UPDATE` section was replaced, instead of replacing the entire previous `_process()` body.

### Solution / Result

Removed the leftover discovery-only block after the new `TRANSFER DEBUG OUTPUT` section. Retained the separate `_find_nearby_storage()` helper, one `_process(delta)` function, and one declaration of each local variable. Godot launched and automatic transfers passed gameplay tests.

### Lesson

When replacing an entire long function, use the **large section header** as the start and the following function/section boundary as the end; check for duplicated variable declarations and duplicated control-flow exits.

---

## 2026-10-20 — Chat 05: Storage Group Creation vs Assignment

### Problem

The `logistics_storage` group appeared in the Test Storage scene's Groups tab, but its checkbox was initially unchecked.

### Solution / Result

Enabled the group on the **TestStorage root** while retaining `selectable` and `player_built`. Nearby detection later reported valid storage and automatic transfers worked.

### Lesson

Creating a Godot scene group does not automatically assign it to the selected node. Confirm the checkbox, save the scene, and test the instance in the main world.

---

## 2026-10-20 — Chat 05: Last Transfer Shows Zero When Storage Is Full

### Symptom

The logistics Output log showed successful transfers, but the HUD later displayed `Last Transfer: 0` and `Status: No Eligible Storage`.

### Explanation

The debug field `last_transfer_amount` tracks the **latest transfer attempt**, not the last successful one. When storage became full or unavailable, the logistics code intentionally reset it to zero. `No Eligible Storage` currently includes both full destinations and destinations outside range.

### Solution / Result

Kept the attempt counter and added `last_successful_transfer_amount`, which only updates after a positive transfer. The HUD now shows both counters and verified that the last successful amount persists after transfers stop.

### Lesson

Distinguish a current operating/attempt state from historical successful throughput. Do not interpret `No Eligible Storage` alone as a range failure.

---

## 2026-10-20 — Chat 05: Committed Test Scene Filename Typo (Non-blocking Cleanup)

The isolated transfer test currently lives at `tests/inventory_trasnfer_test.tscn` and references `scripts/components/test_inventory_transfer.gd`. These paths differ from the original intended `tests/test_inventory_transfer.tscn` / `tests/test_inventory_transfer.gd`.

The committed scene references the existing script path and the user-tested isolated transfer cases passed. **Do not rename only one file**; when tidying this later, move both to consistent test paths and update the scene's script resource reference in Godot, then re-run F6.

---

## 2026-10-20–21 — Chat 06: Smelter Selected but Selection/Demolition Highlight Missing

### Problem

The newly placed Test Smelter could be selected and displayed in the Production Debug HUD, but it did not become gold on normal selection or red on demolition hover.

### Cause

The root `TestSmelter` had the existing `selectable_object.gd` script and correct `selectable` / `player_built` groups, but its exported **Selection Mesh** reference was empty. The script could not apply the temporary highlight material without a specific `MeshInstance3D`.

### Solution / Result

In `scenes/buildings/test_smelter.tscn`, selected the root node and assigned **Selection Mesh → BuildingMesh** in the Inspector. Both normal selection highlighting and demolition-hover highlighting then worked. No new GDScript code was needed.

### Lesson

A working raycast and HUD selection do not prove visual feedback is wired. When reusing a component with exported node references, configure every required Inspector reference on each new scene.

---

## 2026-10-20–21 — Chat 06: Ingot Counter Stayed at Zero Despite Active Manufacturing

### Problem

Automatic extractor-to-storage and storage-to-smelter transfers ran, and the smelter repeatedly received ore, but the Production Debug HUD displayed `Stored Test Ingot: 0`. This initially appeared to be a manufacturing failure.

### Cause

The historical HUD assumed a building had one child named `InventoryComponent`. The smelter intentionally has two separate nodes: `InputInventory` for Test Ore and `OutputInventory` for finished Test Ingots. The HUD was reading the missing/old inventory reference instead of the producer's output buffer.

### Solution / Result

Updated `_refresh_building_display()` in `scripts/production_debug_hud.gd` to resolve the manufacturer's `OutputInventory` (and, later, to show `ProducerComponent.input_inventory` and both capacities). Live Test Ingot counts became visible; screenshots showed accumulated ingots and separate 50-unit input / 100-unit output capacities.

### Lesson

Differentiate **incorrect instrumentation** from a broken gameplay pipeline. Inspect the correct inventory instance before changing resource-transfer or manufacturing logic.

---

## 2026-10-20–21 — Chat 06: Fourth Building Input Worked but Construction HUD Did Not Update

### Problem

The `select_building_4` Input Map action was configured and `WorldInteraction` handled index `3`, but the Test Smelter did not appear in the Build HUD. After adding a text label, it still did not highlight.

### Cause

Registering a key action is only one part of a data-driven construction option. The `WorldInteraction.buildable_definitions` array initially contained only three definitions. The HUD scene/script also had only three building labels and three corresponding reset/highlight branches.

### Solution / Result

- Added `data/buildings/test_smelter.tres` as index `3` (fourth entry) of `buildable_definitions` in `main.tscn`.
- Duplicated and renamed the HUD label to `Building4Label`, with text `[4] Test Smelter`.
- Extended `build_hud.gd` to reset and highlight the fourth option using the same gold selected state.

The `4` key then selected a valid smelter placement ghost and correctly highlighted the build option. Existing slots 1–3 continued working.

### Lesson

Treat key mapping, building definition registration, HUD label creation, and HUD selection logic as separate integration points; a missing one can resemble a controller bug.

---

## 2026-10-20–21 — Chat 06: Extractor Said "Extracting" When Inventory Was Full

### Problem

A Test Extractor displayed `Status: Extracting` and `Inventory Capacity: 50 / 50` simultaneously. This was misleading because the capacity-aware extraction logic could not remove additional ore.

### Cause

The original HUD inferred the status from whether a viable resource deposit existed; it was not reporting whether `ExtractorComponent` could currently work. Older hardcoded status strings also risked duplicated status text once component-owned statuses were introduced.

### Solution / Result

- Added `ExtractorComponent.extraction_status` and guarded progress timing for missing/depleted resources, missing inventories, full capacity, and invalid intervals.
- Made `_refresh_extractor_display()` read `extractor_component.extraction_status` as the single status source.
- Removed older fixed `Status:` append lines and reused the shared `ActivityProgressBar` for real extraction timing.

Tested the extractor filling to `50/50`; the HUD correctly showed `Inventory Full` and 0% progress. Active extraction and smelting continued displaying live progress.

### Lesson

Operational UI should read state from the responsible gameplay component instead of guessing from a few conditions inside the HUD.

---

## 2026-10-20–21 — Chat 06: Smelter Output Cap Reached and Manufacturing Stopped

### Observation / Verification

To verify that no ore was consumed after reaching the finished-product limit, the Test Smelter's `OutputInventory.max_capacity` was temporarily reduced from 100 to **2**.

Once two ingots had been produced, the HUD showed:

- `Production Status: Output Blocked`
- `InputInventory: 10 / 50` Test Ore
- `OutputInventory: 2 / 2` Test Ingots
- Production progress: `0%`

The blocked quantities remained stable during the waiting period. Restored the capacity to **100** afterward.

### Lesson

Testing a short-term capacity override is faster and safer than waiting for a large prototype inventory to fill. Remember to restore and save the normal scene configuration after the test.

---

## 2026-10-20–21 — Chat 06: Git Diff Whitespace and Accidental Untracked File

### Problem

Before committing the Chat 06 changes, `git diff --check` found trailing whitespace in `scripts/production_debug_hud.gd` and `scripts/world_interaction.gd`. After a successful push, `git status` listed an unexpected untracked file with an unusual name containing `automated manufacturing chain`.

### Cause

The first issue was trailing whitespace at the ends of script lines. Inspection of the 2,132-byte untracked file revealed that it contained Git's staged `--stat` summary, not gameplay code; it appears to have been created accidentally during terminal use.

### Solution / Result

Used VS Code **Trim Trailing Whitespace**, then validated the staged changes. Committed and pushed the intended gameplay changes to `main`. Inspected the unexpected file's size and first lines with PowerShell `Get-ChildItem` and `Get-Content -LiteralPath` before deleting **only that inspected file** with `Remove-Item -LiteralPath`. A subsequent `git status` was clean.

### Lesson

Review new/untracked files before `git add .`, check staged diffs, and **inspect unknown files before deleting them**. If Git uses the `less` pager and shows `(END)`, press `Q` to return to PowerShell.

---

## 2026-10-20–21 — Chat 06: Resource Conservation Across Manufacturing

### Verification

Because the smelting recipe transforms **2 ore into 1 ingot**, conservation must be expressed in ore equivalents rather than total item count:

```text
Deposit ore
+ Extractor ore
+ Storage ore
+ Smelter input ore
+ (Smelter ingots × 2)
= Initial ore supply
```

Verified sample from a single finite-500-ore test:

```text
236 deposit + 50 extractor + 200 storage + 10 input + (2 × 2) = 500
```

During review, a screenshot's deposit quantity was initially read as 326 rather than 236, creating an apparent 90-unit discrepancy. Correcting the reading reconciled the total without gameplay code changes. A later final conservation run was also reported successful.

### Lesson

Verify that all displayed quantities come from the same run and that processed items are converted back into their input-equivalent counts before diagnosing duplication. Recheck readings before editing gameplay code.

---

## 2026-10-22 — Chat 07: Recipe Logistics Test Kept Transferring After PASS Banner

### Symptom

`recipe_logistics_acceptance_test.tscn` printed the expected 5/5 successes, but the test buildings continued automatically transferring ore after the final result banner.

### Cause

The temporary Test Smelter scene includes active `ProducerComponent` and `LogisticsInputComponent` nodes with normal frame processing. The test also invokes `logistics._process(1.1)` manually, creating uncontrolled additional updates after the assertions.

### Solution / Result

After attaching the temporary smelter and storage to the test scene, run `logistics.set_process(false)` and `producer.set_process(false)` on their actual child nodes. Perform transfers only with explicit manual `_process()` calls in the test. After successful assertions, call `smelter.queue_free()` and `storage.queue_free()` before printing the final PASS banner. The rerun showed 5/5 passes with no trailing transfers.

### Lesson

Test isolation requires disabling unrelated automatic processing **after** adding instantiated scenes to the tree, not just calling a process method manually. Clean up temporary nodes before final reporting.

---

## 2026-10-22 — Chat 07: Spaces Versus Tabs Parser Error in GDScript Test

### Symptom

Godot reported `Used space character for indentation instead of tab as used before in the file` (initially near line 83; another affected line appeared around line 97) in `tests/recipe_logistics_acceptance_test.gd`.

### Cause

Newly copied lines used leading spaces while the surrounding code inside `func _ready()` used tabs. GDScript does not accept mixing space and tab indentation within the same block.

### Solution / Result

Replace the affected line prefixes with **one tab** at the first indentation level inside `_ready()`, including `add_child(...)`, `set_process(false)`, and `queue_free()` statements. Save, rerun the isolated test with F6, and confirm all 5/5 PASS messages with no parser errors or extra transfers.

### Lesson

Match existing file indentation exactly when pasting snippets from chat or moving between VS Code and Godot. Keep GDScript files configured for tabs and inspect the **first** parser error rather than following cascading failures.

---

## 2026-10-22 — Chat 07: Port Handoff Diagnostic Notes (No New Reported Defect)

### What Was Verified

Port foundation, Test Smelter integration, manual safe-transfer, and real-smelter handoff test scenes passed **7 + 8 + 7 + 7 = 29** checks without new Godot parser/runtime errors. Recipe tests (21), manufacturing tests (36), inventory transfer, and normal factory also passed in the developer's final regression. This section records likely checks for future integration issues; **it does not describe a defect observed in this milestone**.

### If a Port Refuses a Valid-Looking Item

1. Check that the source has `direction = OUTPUT` and the receiver has `direction = INPUT`; ports cannot serve both roles in one handoff.
2. Check that both ports have valid `InventoryComponent` references and do **not** point to the same inventory.
3. For recipe-controlled input ports, ensure `InputPolicy.RECIPE_INPUTS`, a valid `producer_component`, and `inventory == producer_component.input_inventory`. Check the **active** recipe inputs, not merely `available_recipes`.
4. For general-purpose storage, select `InputPolicy.ANY_ITEM`; item eligibility is unrestricted but available inventory space still matters.
5. Ensure the source has the **entire** requested item quantity and the destination can hold the **entire** request. Port `try_transfer_to_port()` deliberately rejects oversized requests instead of partially filling the destination.
6. A producer-controlled output port must reference its producer's `OutputInventory`, not `InputInventory`.

### If Port Positions Do Not Rotate as Expected

- Confirm that `InputPort` and `OutputPort` are direct `Marker3D` children of `TestSmelter`.
- Confirm input local position `(-0.85, 0.5, 0)` and Y rotation `+90°`; output local position `(0.85, 0.5, 0)` and Y rotation `-90°`.
- Godot treats local `-Z` as forward. Verify *world* positions and forward vectors **after** rotating the parent 90°, as in `item_port_integration_test.tscn`.

### Important Transport Boundary

`try_transfer_to_port()` checks valid **logical** transfers only; it currently does **not** check physical adjacency, belt connections, distance or rate. A test manually calling this on distant ports can succeed by design. Do not diagnose that behavior as broken belt routing — **belt routing has not been implemented**. Physical-connectivity validation must be added before invoking port transfers from autonomous gameplay logic.

### Safe Isolation During Port Tests

For tests instantiating `test_smelter.tscn`, call `producer.set_process(false)` and `logistics.set_process(false)` after `add_child(smelter)`, then trigger manufacturing and transfers explicitly. Queue the temporary smelter for deletion before the PASS banner. Follow the existing tab-indentation convention in all GDScript files.

---

## 2026-10-24 — Chat 07: Conveyor Interaction and Placement Diagnostics

### ConveyorSegment Cast Assertion Failed

**Observed:** The conveyor connection-state test failed to cast an instantiated scene root to ConveyorSegment. **Cause:** The wrong script was attached to the ConveyorStraight root. Keep conveyor_segment.gd on that root, not on a child or endpoint; after correction the connection-state test passed **8/8**.

### Mouse Hover Targets Neighboring Conveyor Rather Than Intended One

**Observed:** The cursor above the middle belt highlighted another belt, and deletion was unreliable. The original CollisionShape3D node had mistaken transform offsets: values intended for BoxShape3D **Size** were entered as node **Transform Position**, putting a hitbox beside the visible BeltMesh.

**Fix:** Center both collision shapes on the belt mesh (local X/Z zero, near local Y 0.3). Use the ConveyorBody StaticBody3D on collision **Layer 3** for placement blocking, a separate InteractionHitbox Area3D on **Layer 2** for selection and demolition, and matching selection/demolition raycasts (Layer 2, areas enabled). Ensure ConveyorStraight has both selectable and player_built groups, plus the ConveyorSegment root script and a selection_mesh reference to BeltMesh.

**Result:** User confirmed correct selection highlights and demolition.

**Nonblocking scene cleanup:** The committed InteractionHitbox BoxShape3D does not explicitly store its size (the Godot default is 1 × 1 × 1), and its collision-shape node has a small Y rotation. User tests succeeded, but standardize these values before exact corner hitbox design. Do not grow the physical placement footprint just to improve mouse targeting.

### Snapping Preview Works But Can't Place, or Adds a Duplicate

**Observed:** The Output panel printed "Conveyor snap preview only — placement not enabled yet." That message came from an intentional temporary placement guard during visual-only preview testing, not a snapping math error.

**Fix:** Once the permanent snapping branch exists, remove the temporary guard. In WorldInteraction._try_place_object(), perform the special snapped-conveyor placement **before** generic new_object instantiation. Create only one new conveyor, apply the ghost transform, connect to the selected source in the right direction (snap-before means new → source; snap-after means source → new), return early on success and remove the provisional new belt on failure.

**Reported result:** Godot logs showed successful Before: false and Before: true placements, including orientation after rotating the original source.

### Snapping Only Works on One Belt End

**Cause:** Initial search evaluated only get_snap_preview_transform_after(). Add get_snap_preview_transform_before() and compare the nearest valid candidates. Keep their source, transform and before boolean in the result. Clear both conveyor_snap_source and conveyor_snap_before when the ghost is removed. The committed world_interaction.gd still has a redundant second source reset; removing it during a later edit is safe cleanup.

### Scope Reminder

The current ConveyorStraight item flow direction is local **+Z to -Z**. Visually perpendicular belts do **not** form a working 90° turn. There is no autonomous item travel or machine-to-belt connection yet; proximity logistics remains active. Six isolated conveyor test scenes passed **40/40** checks.

---

## Diagnostic Checklist

When a new error appears:

1. Read the first parser/runtime error, not only the final cascade message.
2. Confirm the script is attached to the intended node or exists only as data when appropriate.
3. Check exported references in the Inspector.
4. Compare script node paths to exact scene-tree names.
5. Check indentation and tabs.
6. Verify custom `Resource` scripts are not attached to Node types.
7. Confirm physical collision shapes and detection-only Area3D shapes are handled separately.
8. Check that helper functions were not overwritten when editing long scripts.
9. Re-run the smallest relevant gameplay test before changing additional systems.
