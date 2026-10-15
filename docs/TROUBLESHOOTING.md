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

## Diagnostic Checklist

When a new error appears:

1. Read the first parser/runtime error, not only the final cascade message.
2. Confirm the script is attached to the intended node or exists only as data when appropriate.
3. Check exported references in the Inspector.
4. Compare script node paths to exact scene-tree names.
5. Check indentation and tabs.
6. Verify custom `Resource` scripts are not attached to Node types.
7. Re-run the smallest relevant gameplay test before changing additional systems.
