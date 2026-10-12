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