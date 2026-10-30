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

**Historical Chat 07.4 status:** ConveyorStraight item flow direction is local **+Z to -Z**; at that checkpoint, perpendicular belts were not connected automatically. **Chat 07.5 later added working in-place right/left corner conversion and direction arrows.** There is still no autonomous item travel or machine-to-belt connection, and proximity logistics remains active. The earlier six straight-conveyor test scenes passed **40/40** checks.

---

## 2026-10-27 — Chat 07.5: Corner Rotation, Visual Clarity and Loop Diagnosis

### Perpendicular Belt Looks Connected But Does Not Become a Corner

**Symptom:** An adjacent straight appears to touch a preceding belt, but `AUTO CORNER SUCCESS` is absent. Tests appear to work only for one of the four Y rotations.

**Key lesson:** Before changing snap distances or collision shapes, **look at the direction of travel**. The prototype originally had symmetric gray belts with no visible input/output cue. A perpendicular belt can face *back toward* the source and should be rejected by the directed-connection rules. For a source at 0° (travel world -Z), the next belt to its local right (+X) must face **270°**; the next belt to its local left (-X) must face **90°**. This relationship rotates with the source (0°, 90°, 180°, 270°).

**Resolution:** Added `OutputEndpoint/DirectionArrow` under the straight conveyor scene, with a bright unshaded arrow that remains visible in green ghosts and follows the OutputEndpoint after automatic corner conversion. User screenshots confirmed arrows following both clockwise/counterclockwise-looking layouts. `R` rotates the preview, but don't infer transport direction from a symmetric rectangle; follow the arrow.

**Diagnostic sequence:** Check existing output availability; check new belt cell and arrow direction; verify expected source-local left/right offset and `ConveyorTurnIntent`; then inspect `AUTO CORNER SUCCESS | Turn: RIGHT/LEFT`, `Source found`, `Before`, and `Placement valid` in Output. If the incoming or outgoing link is already occupied, another connection must not be forced. A splitter is a separate future building.

### Next Straight Belt Snaps in the Wrong Direction After a Turn

**Cause:** Early `get_snap_preview_transform_after()` inherited the entire source conveyor root basis; a corner's OutputEndpoint points perpendicular to that root. The receiver then previews in the source's old straight direction instead of the corner's output direction.

**Fix:** Use `source_output.global_transform.basis.orthonormalized()` for the new snapped preview basis, with existing endpoint-position calculation and geometrical validations unchanged. Keep the direction-preserving snap candidate guards in `WorldInteraction`. Godot local -Z is travel-forward. Reported in-game tests demonstrated additional straight segments after converted turns.

### L-Shaped Surface Has Seams or Collision Boxes Extend Beyond Bend

**Cause / current state:** `ConveyorCornerVisualMesh` in the GitHub checkpoint merges two gray rectangular arms (width 0.8, height 0.2). This provides a usable L-shaped placeholder but may show a stepped edge or redundant overlap. The converter duplicates prototype corner scene `ConveyorBody` and `InteractionHitbox` shapes. Debug boxes can enclose empty space outside the exact L surface.

**Result / next refinement:** Screenshots and user gameplay inspection confirmed arrow visibility, placement, selection and demolition even with the prototype collider envelopes. Do **not** treat that gameplay pass as proof of exact mesh/collider alignment. Future refinement can use a single polygon surface and tailored corner-shaped physics/selection geometry without changing endpoints or link semantics.

### Visually Closed Conveyor Ring Does Not Prove a Directed Loop

**Reason:** Our belt nodes currently store one `previous_segment` and one `next_segment`. Adding a belt onto an occupied grid cell is correctly blocked; physically adjoining two pre-existing free endpoints requires an explicit final link. A rectangular visual arrangement with arrows is insufficient evidence that the final last-to-first `try_connect_to()` succeeded.

**Next work:** Implement safe explicit loop closure, verify each reciprocal link and no occupied ports, then separately test eventual item circulation/backpressure. Do not disable placement collision checks to force overlapping belts.

---

## 2026-10-27 — Chat 08: Conveyor Transport Integration & Cargo Safety Notes

No unresolved failure was reported during this milestone; the notes below document important diagnostic boundaries from **44/44** separately run transport checks and successful main-game regression.

### A Belt Exists but Its Item Does Not Move

1. Inspect the belt root for **CargoInventory** (`InventoryComponent.max_capacity = 1`), **ConveyorTransportComponent** (`cargo_inventory` referencing that child), and **ConveyorTransportTimer** (automatic processing enabled in real gameplay). The three children are already installed on `ConveyorStraight.tscn`.
2. Confirm a real `next_segment` whose `previous_segment` points back to the source. A visually touching belt or visually closed ring is insufficient.
3. Confirm `OutputEndpoint` and `InputEndpoint` still pass `LogisticsConnectionGeometry.are_endpoints_aligned()` using the strict connection gap; rotated corners point away from their root basis.
4. Inspect `transport_status`: `Empty`, `Moving`, `Blocked`, or `Transferred`. An occupied next buffer, missing connection, or unaligned output correctly leaves the item upstream.
5. **Chat 08 update:** Building-port connections and automatic loading/unloading now work in isolated, code-connected tests. However, `WorldInteraction` Build Mode still does **not** create machine-to-belt connections during ordinary placement; the running factory still uses proximity logistics. Check `input_building_port` / `output_building_port` and reciprocal `ItemPortComponent.connected_conveyor` in integration tests.

### A Test Creates Duplicate Cargo Components

The older connected/timed regression tests originally added cargo and timers dynamically. After the scene gained built-in children, the test helpers were revised to **reuse existing** `ConveyorTransportComponent` and `ConveyorTransportTimer` nodes before creating any fallback nodes. Keep that pattern in future tests.

### A Converted Corner Seems to Lose Cargo or Progress

`ConveyorCornerConversion.try_convert_and_connect()` changes the existing straight belt's output transform and mesh/hitboxes **in place**, preserving its root identity and transport children. Use `tests/conveyor_corner_cargo_test.tscn` (8/8 reported checks) to verify both turn directions and timer preservation. Do not replace the entire belt node on conversion.

### Demolition Is Rejected for a Conveyor

`ConveyorSegment.can_demolish_safely()` requires a valid one-unit CargoInventory with **zero** stored items. `WorldInteraction` blocks player-tool deletion otherwise; unloading the item makes removal eligible. This safeguard applies to **player demolition only**: direct `queue_free()`, deleting a parent/world scene, and future enemy destruction have no cargo recovery policy and must not be assumed resource-safe.

### Generic Item Compatibility

Transport methods use `ItemDefinition` and do not discriminate between Test Ore, Test Ingot, ammunition or future item types. The timed test, converted-corner test and six-belt chain each included newly constructed item definitions. Item eligibility at a **receiving building** will be the responsibility of `ItemPortComponent` and the active production recipe, not the belt.

---
## 2026-10-27 — Chat 08: Visual Cargo, Machine Port & Physical Factory Diagnostics

### Stack Overflow When Running the Cargo Visual Test

**Observed:** Godot reported `Stack overflow (stack size: 1024)` with a stack frame in `conveyor_direction_arrow.gd` during `conveyor_cargo_visual_test.tscn` execution.

**Root cause identified from the Inspector screenshot:** The live `ConveyorStraight/CargoVisual` `MeshInstance3D` had `conveyor_cargo_visual_test.gd` attached instead of the intended `scripts/components/conveyor_cargo_visual.gd`. An executable test scene script must never be attached to a runtime visual child. Correct the CargoVisual script property (mesh can remain empty because `_ready()` builds it). The developer reran the straight and corner visual suites successfully.

### Duplicate Script Declarations When Adding Unloading

**Observed:** An illustrative file outline from the instructions was pasted after the actual loading function, adding duplicate `extends RefCounted`, `class_name ConveyorBuildingTransfer` and stub functions.

**Fix:** Retain the original file header and complete `try_load_into_belt()` only once; delete the illustrative pasted outline and append the full `static func try_unload_from_belt()` at column zero. Preserve existing indenting within each method. The developer corrected the script and reported successful unloading tests.

### Test Scene Is Missing From Godot

Adding `try_unload_from_belt()` does not create `tests/conveyor_building_unloading_test.gd` or `.tscn`. Create a regular root `Node` test scene, attach the existing test script (not the runtime transfer helper), save at `res://tests/conveyor_building_unloading_test.tscn`, then run via F6. The developer subsequently reported **10/10** unloading checks.

### Building Snaps Visually But Items Do Not Transfer

- `ConveyorBuildingSnap.get_preview_transform()` returns **only a suggested transform**. A preview by itself makes no persistent connection or inventory movement; player-facing `WorldInteraction` integration is still pending.
- Verify the exact opposing `ItemPortComponent` roles and current `LogisticsConnectionGeometry.are_endpoints_aligned()` at `ConveyorSegment.CONNECTION_GAP = 0.05`. Check port and belt inputs/outputs are unoccupied; one building port may serve one belt.
- Establish and inspect reciprocal state via `ConveyorSegment.try_connect_building_port()`, `ItemPortComponent.connected_conveyor`, `ConveyorSegment.input_building_port` and `output_building_port`. Removing either endpoint should clear references.
- Loading checks `can_provide_item()` on the source and the one-unit belt capacity. Unloading checks `can_accept_item()`: active recipe, correct producer input reference and free input space; unsupported items and full inventories are expected to block without item loss.
- The transport timer automatically loads an **empty** belt; it must finish its `travel_interval` before trying to deliver to an attached building input. A finished-but-blocked item keeps its progress and retries when capacity is available.
- Keep the old `LogisticsTransferComponent` / `LogisticsInputComponent` **disabled in isolated physical-routing tests** so proximity transfers cannot mask or interfere with conveyor accounting. Ordinary player gameplay still uses them until migration is validated.

### Reproducing the Physical Factory Check

Run `res://tests/conveyor_physical_factory_test.tscn` in Godot 4.6.2. It seeds two ore in the actual Test Extractor inventory, connects three belts to the Test Smelter in code, manually advances belt transport timers and the ProducerComponent, and asserts one finished ingot and conservation (**9/9 reported**). This does **not** simulate mining, Build Mode placement, real-time steady throughput or an operational route through Storage. The isolated Extractor may print `Extractor has no resource node` because there is no deposit in the test.

### Scope to Keep Separate

Chat 08 added **86** newer separately run checks after the prior 44-check foundation, for **130/130** locally reported checks across individually executed suites. Repeated regressions are not included twice in this total. No combined CI report is claimed. Remaining issues: direct cargo destruction policy, actual Build Mode port snapping, Storage ports, multiple concurrent items, loop closing, unique item art, and safe disabling of proximity transport.

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

---

## 2026-10-30 — Chat 08.3G: Conveyor Line Appears Joined but the Last Corner Will Not Connect

### Symptom

Two physically touching conveyor runs show adjacent collision outlines, but their final 90° connection is blocked. A new straight belt may snap to one open endpoint while another existing belt is already occupying the intended receiver tile.

### Cause / Resolution

Different junction types need distinct commit paths:

- **Free tile:** preview/place a new missing corner.
- **Existing straight with free input:** convert the receiver in place.
- **Existing straight with free output:** convert the source while preserving its building input or previous conveyor.
- **Two free ends with a nonstandard gap:** use an exact fractional straight or offset L connector.
- **Multiple upstream belts sharing one downstream route:** use a dedicated Merger instead of a three-way plain corner.

The previous free-end-only search could not turn an occupied receiver, and a player-rotated ghost could make a correct connection appear geometrically blocked. Current `WorldInteraction` priority and temporary mesh previews handle compatible cases. Revalidate inputs/outputs on click; do not commit a stale preview.

### Verification

Receiver auto-snap **11/11**, building-safe source auto-snap **10/10**, and isolated missing-corner and bridge suites were reported passed. Both source- and receiver-side conversion produced successful live connection logs.

---

## 2026-10-30 — Chat 08.3G: Extractor Half-Tile Belts Leave a Narrow Gap

### Symptom

A run built directly from an Extractor's output occupies coordinates such as `1.5, 0.5, -0.5, -1.5` on the relevant axis. A separate integer-grid conveyor lies nearby but cannot be joined with an ordinary 1-unit straight or corner. The Output panel reports `Off-grid corner preview` followed by `Placement blocked`.

### Cause / Resolution

A one-tile segment is the wrong geometry for a fractional or perpendicular half-grid gap. `ConveyorFractionalBridge` supports a real variable-length **straight** segment between free aligned endpoints, while `ConveyorOffsetCornerBridge` supports an L with separately measured incoming and outgoing legs. Both use proper visual mesh, physical collision, selection shapes, endpoint transforms and normal cargo transport.

The shared `FactoryGrid` now snaps all footprint-defined buildings, not just Smelters/Mergers; invalid building-to-existing-belt snapping is refused instead of pulling a new building off-grid. **Existing** legacy half-grid conveyors are not automatically repositioned.

### Verification

Isolated fractional/offset regression tests were reported passed, followed by a live screenshot showing the gap filled and ore moving across it.

---

## 2026-10-30 — Chat 08.3G: Cargo Appears to Slow Down on Short Connectors

### Symptom

Items cross a short conveyor junction visibly, but their perceived speed slows and then accelerates on the next normal belt.

### Cause / Resolution

The prototype originally used one fixed timer interval for every segment independent of its length. A 0.65-unit connector taking the same interval as a 1-unit belt gives inconsistent physical speed, while an unequal-leg L path using a 50/50 time split gives a speed discontinuity at the corner.

`ConveyorPathMotion` now calculates path length from input/output endpoints, scales special segment travel duration to that length, and allocates visual progress according to leg distances. Do not change item counts or transfer eligibility to solve an animation timing issue.

### Verification

The developer reported that the live cargo movement correction made short and standard conveyors appear to run at the same speed. Follow-up isolated speed regressions were also reported successful.

---

## 2026-10-30 — Chat 08.3G: A 2×2 Merger Output Sits Between Conveyor Grid Lanes

### Symptom

Inputs align, but the output points between tile centers, leading to unexpected spacing or forced bridge solutions when building larger routes.

### Cause / Resolution

The earlier 2×2 Merger output was centered along an even-width wall where grid-aligned conveyor centers lie at `±0.5` offsets. Its output port initially used the seam at `0.0` rather than one of those lanes.

The final design has been **replaced** by a **1×1** Merger and Splitter, each with a port at the midpoint of each of four sides. The shared-grid test now checks five building types and their rotated physical port centers.

### Verification

The current five-building grid suite, 1×1 three-input Merger suite and 1×1 three-output Splitter suite were all reported passed. Merger three-way *physical connections* were observed in live gameplay. All three live `From A/B/C` throughput counters are **not yet confirmed together**.

---

## 2026-10-30 — Chat 08.3G: Merger Input Appears Stalled

### Diagnostic procedure

A Merger with three independent inputs and one output can receive items more quickly than its output line can remove them. This is normal bounded-buffer **backpressure**, not automatically a wiring failure.

1. Select the Merger and inspect **Input A/B/C**, **Output**, each port's **Connected/Disconnected** status, `From A/B/C` counters, and `Next lane`.
2. If the output is `1/1`, unblock the outgoing conveyor and observe whether the counters resume. No input may silently lose or overwrite stored items.
3. If the output has space yet one active lane's completed count never rises, verify the affected physical input port, arrow direction, inventory capacity and corresponding Extractor's output.
4. Check that the legacy proximity-transfer components are not also delivering the same ore independently of the new belt graph.
5. Use `res://tests/conveyor_merger_test.tscn` for isolated three-lane scheduling and conservation checks before changing transfer rules.

**Updated verification (2026-10-30):** The final isolated Merger suite passed, the developer confirmed the three-input Merger was operating correctly in live gameplay, and **backpressure plus recovery** were subsequently confirmed with a temporarily blocked downstream route. The screenshot did not contain numeric `From A/B/C` values, so detailed per-lane throughput benchmarking remains open.

---

## 2026-10-30 — Chat 08.3G: Splitter Seems to Ignore an Output

### Diagnostic procedure

The current 1×1 Splitter has **one input** and **three independent output buffers**; routing is round-robin among **connected outputs with space**. A missing/blocked output is intentionally skipped rather than having cargo teleported or dropped.

Inspect `Output A/B/C` connection status, buffer occupancy, `To A/B/C` counts and the next lane. If all outputs are blocked, the input waits. The `conveyor_splitter_test.tscn` isolated suite exercises disconnected and full outlets.

**Live verification:** The Production Debug HUD showed **13 completed splits** distributed **A=5, B=4, C=4**, all three outputs connected, and output buffers `0/1` at the captured moment. This establishes real three-output routing during that session, not final sustained-traffic performance.

---

## 2026-10-30 — Godot Reports Files Modified Outside the Editor After `git pull`

### Cause / Safe action

The GitHub edits changed `main.tscn` and related scene resources while the Godot editor was open. Choose **Reload from disk** to use the pulled version **only after saving or otherwise preserving any unsaved scene changes**. Then inspect the Debugger for the first parser/runtime error and run the changed test scenes individually with **F6**.

For the complete final release gate, refer to [CHAT_08_FINAL_REGRESSION.md](CHAT_08_FINAL_REGRESSION.md).


---

## 2026-10-30 — Final Logistics Acceptance: Backpressure Recovery and Ore-to-Ingot Route

### Verified outcome

- The developer reported all **20/20** final manual regression test scenes passed in four rounds of five.
- The three-input Merger was observed in the main game and its operation confirmed.
- Blocking the Merger's downstream output produced expected **backpressure**; restoring downstream capacity resumed transfer. The developer confirmed both stages.
- The developer confirmed the complete **ore-to-ingot factory chain** operating in normal gameplay.
- The Splitter's earlier live HUD independently recorded **13 successful transfers (A=5, B=4, C=4)**.

### Remaining diagnostics if a later build behaves differently

When ore reaches a Smelter unexpectedly or appears to bypass a belt, **first check whether the older `LogisticsTransferComponent` / `LogisticsInputComponent` proximity transfers are still active**. A successful visible conveyor chain does not prove these older scripts have been turned off. Before removing them, record source deposit ore, each machine/storage/belt inventory, consumed ore and output ingots in a common ore-equivalent accounting snapshot to prove physical-only conservation. Do not change working logistics code just to make debug counters match without confirming the transfer path.

**Status:** Core Chat 08 logistics accepted. Numerical Merger lane counts, legacy transfer migration, cargo-destruction recovery and blocked-port live stress checks are later hardening work. See [CHAT_08_FINAL_REGRESSION.md](CHAT_08_FINAL_REGRESSION.md).
