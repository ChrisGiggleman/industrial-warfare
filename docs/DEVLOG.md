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