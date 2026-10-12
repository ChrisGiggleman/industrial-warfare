# Industrial Warfare — Troubleshooting Log

This document records technical problems encountered during development, their causes, solutions, and lessons learned.

The purpose is to create a reusable knowledge base as the project grows.

---

## 2026-10-11 — PowerShell Documentation Path Error

### Problem

While creating the initial Markdown documentation files with PowerShell, the following command failed:

`New-Item docs\DEVLOG.md -ItemType File`

PowerShell returned a `DirectoryNotFoundException`.

### Environment

Current terminal location:

`E:\GameDev\industrial-warfare\docs`

### Cause

The terminal was already inside the `docs` directory.

Adding `docs\` to the filename caused PowerShell to attempt to access:

`E:\GameDev\industrial-warfare\docs\docs\DEVLOG.md`

The nested `docs` directory did not exist.

### Solution

Because the terminal was already inside the correct directory, the command was changed to:

`New-Item DEVLOG.md -ItemType File`

The same correction was used for the remaining Markdown files.

### Result

All documentation files were successfully created.

### Lesson Learned

Relative paths are resolved from the terminal's current working directory.

Before running file-management commands, verify the current location shown in the PowerShell prompt.

---

## Troubleshooting Entry Template

### Date — Problem Title

### Problem

Describe what happened.

### Environment

Record relevant information such as:

- Godot version
- Operating system
- Scene or system
- Relevant hardware or software

### Error

Record the exact error message when available.

### Cause

Describe the identified cause.

### Solution

Document the steps that fixed the issue.

### Result

Record whether the issue was fully resolved.

### Lesson Learned

Document anything that may help prevent or diagnose the problem in the future.