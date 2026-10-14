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

### First Runtime Building Placement

- Created reusable `test_building.tscn`.
- Structured the building with a ground-level `Node3D` root.
- Added visible mesh and matching collision.
- Added the global `selectable` group for reusable selectable scenes.
- Connected the building scene to `WorldInteraction` using `PackedScene`.
- Implemented runtime building instantiation.
- Left-click now places a building on valid grid cells while placement mode is active.
- Placement is blocked on occupied cells.
- Newly placed buildings immediately act as placement blockers.
- Verified multiple buildings can be placed during a single play session.

### Building Placement Ghost

- Added a translucent building preview using the configured `PackedScene`.
- Placement ghost follows the grid-snapped placement position.
- Ghost collision is disabled so it does not interfere with placement validity checks.
- Added placement ghost cleanup when exiting Build Mode.
- Added safeguards to prevent multiple placement ghosts from accumulating.
- Confirmed placed buildings remain after the temporary ghost is removed.
- Verified camera movement, zoom, selection, highlighting, placement validity, and Build Mode continue working together.

### Finalized Building Ghost Preview

- Replaced the temporary placement tile with the actual building ghost as the placement indicator.
- Placement ghost now displays:
  - translucent green when placement is valid
  - translucent red when placement is blocked
- Removed the old green/red square preview from normal placement visuals.
- Placement ghost is created when Build Mode starts and safely removed when Build Mode ends.
- Added cleanup safeguards to prevent multiple placement ghosts from accumulating.
- Verified building placement, collision blocking, selection highlighting, camera movement, and zoom continue working correctly.

### Placement Rotation

- Added the `rotate_placement` input action bound to `R`.
- Placement rotation advances in 90-degree increments.
- Rotation cycles through:
  - 0°
  - 90°
  - 180°
  - 270°
- Placement ghost updates to the selected rotation.
- Runtime-instantiated buildings inherit the current placement rotation.
- Verified camera movement, zoom, Build Mode, placement validity, selection, and highlighting continue to work correctly.

### Directional Test Building

- Changed TestBuilding from a square footprint to a rectangular prototype.
- Building mesh and collision now measure 0.8 × 1.0 × 1.8 meters.
- Verified placement ghost visibly rotates in 90-degree increments.
- Placed buildings preserve their selected rotation.
- Runtime buildings remain selectable and use the gold selection highlight.
- Existing camera, zoom, Build Mode, and placement blocking systems continue to work.

### Rotation-Aware Placement Footprints

- Updated placement validity checks to use the placement ghost's actual collision shapes.
- Removed the previous fixed 1×1 placement-check box.
- Placement validity now respects the real dimensions of the placeable scene.
- Rotating the placement ghost also rotates the placement-validity footprint.
- Verified rectangular buildings correctly report blocked placement when any portion overlaps an existing placement blocker.
- Confirmed placement, rotation, selection, highlighting, camera movement, and zoom continue to function correctly.

### Placement Mode Cancellation

- Added Right Mouse Button cancellation using the existing `secondary_action`.
- Right-click exits Build Mode without placing an object.
- Placement ghost is cleaned up through the existing placement-mode shutdown logic.
- Normal object selection resumes immediately after cancellation.
- Verified rotation, placement, WASD movement, and camera zoom continue working.

### Multiple Buildable Objects

- Replaced the single placeable PackedScene with an array of buildable scenes.
- Added build-selection inputs:
  - `1` — TestBuilding
  - `2` — TestBuildingLarge
- Added runtime tracking of the currently selected building type.
- Placement ghost is recreated immediately when switching building types.
- Each building automatically uses its own collision shape for placement validity.
- Rotation continues to work for each selected building.
- Verified multiple building types can be placed during the same Build Mode session.
- Placement blocking prevents overlap between different building types.

### Demolition Tool and Visual Targeting

- Moved demolition from normal interaction into Build Mode.
- Added a dedicated demolition tool toggled with Delete.
- Placement ghost is hidden while demolition mode is active.
- Added demolition-specific HUD state:
  - Red `DEMOLITION MODE` title
  - `LMB - Demolish`
  - `Delete - Return to Build`
- Added red hover highlighting for player-built structures targeted for demolition.
- Hover highlighting follows the mouse and clears when leaving the target.
- ReferenceCube and other non-player-built objects remain protected from demolition.
- Leaving demolition mode restores the placement ghost.
- Leaving Build Mode clears demolition state and all demolition highlighting.
- Verified build, rotate, switch building type, select, demolish, rebuild, camera movement, and zoom all continue to work correctly.

## Chat 02 — Camera & Player Interaction Foundation Complete

Completed the first full player-interaction foundation for Industrial Warfare.

### Camera

- Added RTS-style camera movement using WASD.
- Added mouse-wheel zoom.
- Tuned camera movement speed for better world navigation.
- Camera controls remain available during normal interaction and Build Mode.

### Object Selection

- Added mouse raycasting from the active camera into the 3D world.
- Added the global `selectable` group for logical selectable objects.
- Selection raycasts walk upward through the collider hierarchy to locate the logical selectable root.
- Clicking a selectable object gives it a gold visual highlight.
- Clicking ground or empty space clears the current selection.
- Selection visuals are controlled by `selectable_object.gd`.

### Collision Layer Conventions

Established the initial physics-layer conventions:

- Layer 1 — Ground / placement surfaces
- Layer 2 — Selectable-object collision
- Layer 3 — Placement blockers

These layers allow placement queries to ignore buildings while still detecting the ground beneath them.

### Build Mode

Added a dedicated Build Mode controlled with `B`.

Build Mode currently supports:

- Building placement
- Grid snapping
- Placement validity checking
- Building rotation
- Multiple building types
- Placement preview ghost
- Build HUD
- Demolition Tool

Right-click exits Build Mode.

### Grid-Based Placement

- Added configurable grid snapping.
- Current grid size is 1 meter.
- X and Z placement coordinates snap to the grid.
- Ground raycasts determine placement height.

### Placement Ghost

- Replaced the original flat placement marker with a full building ghost.
- Placement ghost uses the selected building scene as its source.
- Ghost collision shapes are disabled from normal physics interaction.
- Actual collision-shape dimensions are reused for placement validation.
- Green ghost indicates valid placement.
- Red ghost indicates blocked placement.
- Ghost respects current building rotation.

The obsolete HoverMarker prototype was removed during the final refactor.

### Rotation

- `R` rotates the placement preview clockwise in 90-degree increments.
- Rotation cycles through:
  - 0 degrees
  - 90 degrees
  - 180 degrees
  - 270 degrees
- Placed structures inherit the preview rotation.
- Placement collision checks use the rotated collision-shape transform.

### Multiple Building Types

Added two prototype building scenes:

- Small Building
- Large Building

Build Mode controls:

- `1` — Small Building
- `2` — Large Building

Changing the selected building recreates the placement ghost and resets its rotation.

### Build HUD

Created a prototype Build HUD using a separate `build_hud.tscn` scene.

The HUD displays:

- Current mode
- Available building slots
- Selected building
- Current controls

The active building slot receives a gold selection marker.

This text-based HUD is intentionally temporary and can later be replaced by an icon-based quick-build hotbar.

### Demolition Tool

Moved demolition into Build Mode so destructive world modification cannot happen accidentally during normal selection.

Controls:

- `Delete` — Toggle Demolition Tool
- `LMB` — Demolish targeted player-built structure
- `Delete` again — Return to placement
- `RMB` — Exit Build Mode

Player-created structures belong to the global `player_built` group.

Non-player-built objects, including the ReferenceCube, remain protected.

### Demolition Feedback

- Demolition Mode changes the HUD title and controls.
- HUD uses red visual styling while demolition is active.
- Valid player-built targets turn red while underneath the mouse cursor.
- Red targeting follows the cursor between buildings.
- Highlight clears when:
  - moving away from a building
  - returning to Placement Mode
  - exiting Build Mode
  - demolishing the targeted structure

### Final Refactor

Performed a cleanup pass after all interaction systems were functional.

Changes included:

- Removed obsolete HoverMarker code and scene node.
- Renamed `_update_hover_marker()` to `_update_placement_preview()`.
- Renamed `_print_mouse_world_position()` to `_select_under_mouse()`.
- Removed an unused placement-check function parameter.
- Replaced physics-mask magic numbers with named constants.
- Replaced repeated rotation and ghost-alpha values with named constants.
- Improved demolition-hover cleanup.
- Improved comments and section organization.
- Refactored selectable-object visual state so demolition highlighting has priority over normal selection highlighting.

### Regression Test

Completed a full regression test after refactoring.

Verified successfully:

- Camera movement
- Camera zoom
- Object selection
- Selection clearing
- Build Mode entry/exit
- Small and Large Building selection
- Grid snapping
- Placement preview
- Valid/invalid placement colors
- Collision blocking
- Building rotation
- Rotation-aware footprints
- Object placement
- Demolition Mode
- Demolition hover highlighting
- Protected non-player-built objects
- Returning from demolition to placement
- Exiting Build Mode from demolition

No gameplay regressions were found.

### Status

Chat 02 — Camera & Player Interaction Foundation: COMPLETE