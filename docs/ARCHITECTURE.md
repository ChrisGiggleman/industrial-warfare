# Industrial Warfare — Technical Architecture

This document describes the technical organization and development conventions for the Industrial Warfare Godot project.

The goal is to keep systems modular, understandable, testable, and easy to expand as the game grows.

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
├── docs/
├── scenes/
├── scripts/
├── tests/
├── icon.svg
└── project.godot

### Input Actions

Input action names use lowercase `snake_case` and describe player intent rather than specific hardware inputs.

Examples:

`move_forward`

`interact`

`primary_action`

`camera_zoom_in`

Gameplay code should reference input actions rather than hard-coded keyboard or mouse buttons.

## Camera System

The main camera uses a `CameraRig` architecture.

```text
CameraRig (Node3D)
└── Camera3D

## World Interaction System

Player interaction logic is separated from the camera controller.

```text
Main
├── CameraRig
│   └── Camera3D
└── WorldInteraction

### Selectable Objects

Logical game objects can be placed in the `selectable` scene group.

Physics colliders may exist as child nodes beneath the logical object. When a raycast hits a collider, the interaction system walks up the node hierarchy until it finds a node in the `selectable` group.

Example:

```text
ReferenceCube [selectable]
└── ReferenceCubeBody
    └── CollisionShape3D


Selectable objects expose a `set_selected()` method. The interaction system controls selection state, while each selectable object is responsible for its own visual feedback.

The current prototype uses a material override for selected objects. This can later be replaced by outlines, emission, selection rings, or shaders without changing the WorldInteraction selection logic.

### Interaction Collision Layers

Initial interaction collision-layer convention:

- Layer 1 — Ground / placement surfaces
- Layer 2 — Selectable objects

The hover/placement ray currently queries only Layer 1, allowing placement-position tracking to remain independent from selectable-object collision.

Selection raycasts remain capable of detecting selectable objects on Layer 2.

### Interaction Collision Layers

- Layer 1 — Ground / placement surfaces
- Layer 2 — Selectable objects
- Layer 3 — Placement blockers

Selectable objects may also belong to Layer 3 when they should prevent construction within their occupied space.

### Interaction Modes

`WorldInteraction` currently supports two basic interaction states:

- **Normal Mode**
  - Object selection is enabled.
  - Placement preview is hidden.

- **Placement Mode**
  - Activated with `toggle_placement_mode`.
  - Object selection is temporarily disabled.
  - Grid-snapped placement preview becomes active.
  - Placement validity is shown using green/red visual feedback.

The current implementation uses a Boolean placement-state flag. This keeps the early architecture simple while leaving room for a more advanced interaction-state system later if needed.

### Runtime Building Placement

Constructible objects are stored as reusable `.tscn` scenes and referenced through `PackedScene`.

Placement flow:

1. Player enters placement mode.
2. Mouse position is projected onto a valid placement surface.
3. Position is snapped to the placement grid.
4. Placement-blocker collision is checked.
5. If valid, the configured `PackedScene` is instantiated.
6. The new scene instance is added to the active world and positioned at the snapped location.

This allows future buildings and machines to use reusable scenes rather than being created directly by `WorldInteraction`.

### Placement Ghost

Build Mode uses a temporary instance of the configured `PackedScene` as a placement preview.

The ghost:
- has collision disabled
- follows the grid-snapped placement position
- displays translucent green when placement is valid
- displays translucent red when placement is blocked
- is destroyed when Build Mode ends

The actual placed building remains a separate scene instance with normal collision and selection behavior.

### Buildable Scene Collection

`WorldInteraction` stores buildable objects as an exported `Array[PackedScene]`.

The currently selected building is tracked by array index.

Prototype bindings:

- Slot 1 → `test_building.tscn`
- Slot 2 → `test_building_large.tscn`

Changing building selection recreates the placement ghost using the newly selected PackedScene. Placement validity therefore automatically uses the selected building's collision footprint.

### Demolition Tool

Demolition is treated as a tool within Build Mode rather than a normal-world interaction.

Player-built structures belong to the global `player_built` group.

Demolition flow:

1. Player enters Build Mode.
2. Delete toggles demolition mode.
3. Placement ghost is removed.
4. Mouse raycasting identifies player-built structures.
5. Valid demolition targets receive red hover feedback.
6. Left-click removes the targeted structure with `queue_free()`.
7. Delete returns to placement mode.
8. Leaving Build Mode clears demolition state and hover feedback.

## Player Interaction Architecture

Player interaction is currently coordinated by `WorldInteraction`.

The system is divided into three primary interaction states:

### Normal Mode

Normal Mode is used for non-destructive world interaction.

Current behavior:

- Left-click performs a camera-to-world raycast.
- The collider hierarchy is searched for a node belonging to the `selectable` group.
- The logical root object becomes selected.
- Selection visuals are delegated to the selected object through `set_selected()`.

### Build Mode

Build Mode is entered with `B`.

While active:

- Normal object selection is disabled.
- A placement ghost represents the currently selected building.
- Mouse position is projected onto Collision Layer 1.
- Placement snaps to the configured grid.
- Building collision shapes are reused to validate placement against Collision Layer 3.
- Green indicates valid placement.
- Red indicates blocked placement.
- `R` rotates the building in 90-degree increments.
- Number keys select the prototype building type.
- Right-click exits Build Mode.

### Demolition Tool

Demolition is implemented as a tool inside Build Mode rather than as a normal-world action.

Flow:

1. Enter Build Mode.
2. Press Delete.
3. Placement ghost is removed.
4. HUD switches to Demolition Mode.
5. Mouse raycasting searches for objects in the `player_built` group.
6. Valid targets receive red hover feedback.
7. Left-click removes the targeted object.
8. Delete returns to placement.
9. Right-click exits Build Mode completely.

This prevents destructive actions from being mixed with normal object selection.

## Object Groups

### `selectable`

Marks logical world objects that may be selected by the player.

The collider itself does not need to be the group member. WorldInteraction walks upward through the node hierarchy until a `selectable` ancestor is found.

### `player_built`

Marks structures created by the player that are allowed to be demolished.

Objects may be:

- selectable only
- selectable and player-built

The ReferenceCube is selectable but intentionally not player-built.

## Physics Layers

Current project conventions:

| Layer | Purpose |
|---|---|
| 1 | Ground / placement surfaces |
| 2 | Selectable-object collision |
| 3 | Placement blockers |

Placement ground raycasts use Layer 1.

Placement-overlap queries use Layer 3.

This separation allows the placement cursor to reach the ground beneath existing structures while independently checking whether the building footprint is blocked.

## Selectable Object Visual State

`selectable_object.gd` owns the object's interaction visuals.

Supported states:

1. Demolition hover
2. Normal selection
3. Original material

Demolition hover has higher visual priority than normal selection.

WorldInteraction requests state changes but does not directly modify object materials.

This keeps interaction logic and object presentation separated.

## Build HUD

`build_hud.gd` owns the presentation of current Build Mode state.

Responsibilities include:

- displaying selected building slot
- displaying Build Mode
- displaying Demolition Mode
- changing visual styling based on the active tool

WorldInteraction communicates with the HUD through methods rather than directly manipulating individual labels.

The current text HUD is a prototype and is expected to evolve into an icon-based quick-build interface later.

## Placement Ghost

The placement ghost is created from the currently selected buildable PackedScene.

Its normal physics collisions are disabled, but its CollisionShape3D resources are retained and used for placement-overlap queries.

This means placement validation automatically reflects:

- building dimensions
- building footprint
- building rotation

The ghost is temporary and is destroyed when:

- Build Mode ends
- Demolition Mode begins
- the selected building changes
- a replacement ghost is created