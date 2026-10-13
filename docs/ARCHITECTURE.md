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