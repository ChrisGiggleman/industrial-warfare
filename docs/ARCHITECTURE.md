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