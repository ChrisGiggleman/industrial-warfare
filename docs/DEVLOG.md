# Industrial Warfare — Development Log

This document tracks the development history of Industrial Warfare.

The goal is to record meaningful development steps, design decisions, technical changes, problems, fixes, lessons learned, and visual milestones throughout the project.

---

## 2026-10-11 — Project Foundation

### Engine

- Godot Engine 4.6.2 Stable Official
- Renderer: Forward+
- Initial target: Windows desktop
- Initial game mode: Single-player

### Project Created

Created the Godot project:

`E:\GameDev\industrial-warfare\`

The project was intentionally created before any gameplay scenes or scripts so that the technical foundation could be organized first.

### Initial Folder Structure

Created the following project folders:

- `assets/`
- `data/`
- `docs/`
- `docs/screenshots/`
- `scenes/`
- `scripts/`
- `tests/`

### Documentation Structure

Created:

- `DEVLOG.md`
- `ROADMAP.md`
- `GAME_DESIGN.md`
- `ARCHITECTURE.md`
- `TROUBLESHOOTING.md`
- `FUTURE_FEATURES.md`

### Naming Convention

Project folders use lowercase `snake_case`.

Examples:

- `enemy_ai`
- `world_generation`
- `factory_buildings`

### Troubleshooting

While creating the documentation files in PowerShell, the terminal was already inside the `docs` directory.

The original command:

`New-Item docs\DEVLOG.md -ItemType File`

therefore attempted to create:

`docs\docs\DEVLOG.md`

This resulted in a `DirectoryNotFoundException`.

The issue was fixed by removing the extra `docs\` path:

`New-Item DEVLOG.md -ItemType File`

### Lesson Learned

Relative paths depend on the terminal's current working directory.

Always check the PowerShell prompt before running commands that create or modify files.

### Visual Milestone 001

Industrial Warfare was successfully created and opened for the first time in Godot 4.6.2.

Screenshot:

`docs/screenshots/001_project_created.png`

### Git Environment

Verified Git installation:

`git version 2.55.0.windows.5`

Git commands are being run from:

`E:\GameDev\industrial-warfare`

### Source Control — ~8:00 PM

Initialized the project as a Git repository using the `main` branch.

Verified local Git configuration and staged the initial project foundation.

Created the first commit:

`c4ede73 - Initial project foundation`

The initial commit contains:

- Godot project configuration
- Git configuration files
- Project folder structure
- Documentation structure
- Initial development screenshot
- Godot import metadata

Generated `.godot/` cache data is excluded from source control.

### Milestone

Industrial Warfare entered source control with a clean working tree.

---

## Next

- Connect the local repository to GitHub.
- Push the `main` branch.
- Continue essential Godot project configuration.

### GitHub Repository — ~8:20 PM

Created the public GitHub repository:

`ChrisGiggleman/industrial-warfare`

Connected the local repository to GitHub using the `origin` remote.

Pushed the local `main` branch to GitHub for the first time using:

`git push -u origin main`

The local `main` branch is now configured to track:

`origin/main`

### Milestone

The Industrial Warfare project is now publicly backed up and version-controlled on GitHub.

### Godot Project Configuration — ~9:20 PM

Configured the initial Godot project settings for the prototype.

Display configuration:

- Base resolution: 1920 × 1080
- Stretch mode: `canvas_items`
- Stretch aspect: `keep`
- Window resizing enabled

### Initial Input Map

Created the first gameplay input actions:

- `move_forward` — W
- `move_backward` — S
- `move_left` — A
- `move_right` — D
- `interact` — E
- `primary_action` — Left Mouse Button
- `secondary_action` — Right Mouse Button
- `camera_zoom_in` — Mouse Wheel Up
- `camera_zoom_out` — Mouse Wheel Down

Movement controls use physical keyboard bindings so input remains based on key position rather than keyboard character layout.

### Main Scene Foundation

Created:

`res://scenes/core/main.tscn`

Initial scene structure:

```text
Main
├── Camera3D
├── Ground
├── DirectionalLight3D
├── WorldEnvironment
└── ReferenceCube

## 2026-10-12 — Camera Controller Foundation

### Completed
- Added a `CameraRig` Node3D to the main scene.
- Reparented `Camera3D` beneath `CameraRig`.
- Created the project's first GDScript:
  - `res://scripts/camera_controller.gd`
- Verified script execution using `_ready()`.
- Added basic WASD camera panning using the existing Input Map actions.
- Camera movement operates across the X/Z world plane.
- Movement is frame-rate independent using `delta`.
- Initial camera movement speed is `10.0`.

### Testing
- W, A, S, and D movement tested successfully.
- Diagonal movement tested successfully.
- Camera stops when movement input is released.
- No runtime errors encountered after final setup.

### Notes
- Current movement speed feels slightly slow and will be tuned after camera zoom is implemented.

### Camera Zoom and Tuning
- Added mouse-wheel camera zoom using existing input actions.
- Added minimum and maximum zoom limits.
- Camera zoom keeps the existing viewing angle.
- Tuned camera movement speed from `10.0` to `16.0` after playtesting.
- Verified WASD movement works correctly at multiple zoom levels.

### Mouse / World Interaction Foundation

- Added collision to the 20 × 20 meter ground plane using `StaticBody3D` and `CollisionShape3D`.
- Added a dedicated `WorldInteraction` Node.
- Created `res://scripts/world_interaction.gd`.
- Added an exported reference to `Camera3D`.
- Implemented mouse-to-world raycasting using the existing `primary_action` input.
- Verified that left-clicking the ground returns:
  - the collider that was hit
  - the exact 3D world position
- Confirmed camera movement and zoom continue to work correctly.

### Selectable Object Foundation

- Added collision to the existing `ReferenceCube`.
- Added the `ReferenceCube` to the `selectable` scene group.
- Updated `WorldInteraction` to distinguish between raw physics colliders and logical selectable objects.
- Implemented parent traversal so collisions on child physics bodies can resolve to their selectable parent object.
- Verified:
  - Ground clicks report `StaticBody3D`.
  - Cube clicks report `ReferenceCube`.
  - Raycast hit positions are correctly returned on different cube faces.

  ### Visible Selection Feedback

- Added `selectable_object.gd` to the `ReferenceCube`.
- Added persistent selection tracking in `world_interaction.gd`.
- Selectable objects now receive a simple visual selection state.
- The test cube scales to 110% when selected.
- Clicking the ground deselects the current object and restores its original scale.
- Verified repeated selections do not stack the scale effect.

### Material-Based Selection Highlight

- Replaced the temporary scale-based selection effect with a material-based highlight.
- `selectable_object.gd` now creates a gold `StandardMaterial3D` for selected objects.
- Selecting the ReferenceCube applies the highlight material.
- Deselecting restores the object's original material.
- Confirmed selection, deselection, WASD movement, camera zoom, and raycasting continue to work correctly.

### Selection Behavior Completed

- Added deselection when clicking empty space.
- Selection now behaves consistently across selectable objects, non-selectable ground, and empty space.
- Confirmed material highlighting, deselection, raycasting, camera movement, and zoom all work together without errors.

### Placement Surface Collision Separation

- Separated placement-surface detection from selectable-object detection using physics collision layers.
- Ground remains on Collision Layer 1.
- ReferenceCube collision moved to Collision Layer 2.
- Hover/placement ray now queries only Layer 1.
- HoverMarker tracks the ground underneath selectable objects rather than climbing onto their collision surfaces.
- Object selection continues to detect and highlight ReferenceCube correctly.
- Verified camera movement and zoom remain functional.

### Grid-Snapped Placement Tracking

- Added configurable `grid_size` to the world interaction system.
- HoverMarker now snaps its X/Z position to a 1-meter placement grid.
- Vertical position continues to come from the ground surface.
- Verified grid snapping works while camera movement, zoom, selection, and collision-layer separation remain functional.

### Placement Validity Prototype

- Added Collision Layer 3 for placement-blocking objects.
- ReferenceCube now belongs to:
  - Layer 2 — selectable objects
  - Layer 3 — placement blockers
- Added a 1×1 placement occupancy check using `PhysicsShapeQueryParameters3D`.
- Placement preview now changes color based on occupancy:
  - Green — valid/open grid cell
  - Red — blocked grid cell
- Verified placement checks remain independent from object selection.
- Camera movement, zoom, selection, and grid snapping continue to work correctly.

### Placement Mode Foundation

- Added the `toggle_placement_mode` input action bound to `B`.
- Added placement-mode state tracking to `WorldInteraction`.
- Placement preview is hidden during normal interaction mode.
- Pressing `B` enables placement mode and displays the grid-snapped placement preview.
- Entering placement mode automatically deselects the currently selected object.
- Object selection is disabled while placement mode is active.
- Pressing `B` again exits placement mode and hides the placement preview.
- Verified WASD camera movement and zoom continue working in both modes.