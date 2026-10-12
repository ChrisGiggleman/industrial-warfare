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

`E:\GameDev\industrial-warfare`

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

---

## Next

Continue establishing the project foundation before beginning gameplay development.