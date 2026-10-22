# Industrial Warfare — Game Vision & Design Principles

> **Document role:** The long-term creative and gameplay north star for Industrial Warfare.  
> **Established:** 2026-10-21, consolidating the original Chat 00 concept and design decisions through Chat 07.  
> **Status:** Living design reference — not a claim that all described features are implemented.  
> **First target:** Single-player "First Night" vertical slice on the zombie colony world.

## 1. Elevator Pitch

**Industrial Warfare is a 3D, RTS-controlled factory-automation and colony-defense game in which the player builds physical production lines that turn raw resources into ammunition and military capability, then uses that industrial output to survive attacks from hostile populations inhabiting the world.**

The factory is not separate from combat. Conveyor lines, materials, storage, production rate, ammunition supply, and defensive placement all influence survival. As the player expands into enemy-controlled territory, the factory becomes more powerful and more vulnerable.

**Core fantasy:** Build the industrial machine that keeps your colony alive while hostile worlds fight back.

**Core loop:** Explore → Extract → Manufacture → Transport → Arm → Defend → Expand.

## 2. Design Inspirations (Principles, Not Copies)

These games guide design decisions; Industrial Warfare must have its own implementation, art, interfaces, progression, and identity.

| Inspiration | Design principle we draw from it |
| --- | --- |
| [Satisfactory](https://store.steampowered.com/app/526870/Satisfactory/) | Physical conveyor-based logistics, machine recipes, connected input/output ports, and dedicated splitter/merger buildings |
| [BELTFED](https://store.steampowered.com/app/4879420/BELTFED/) | Factory-made weapons and ammunition directly sustaining combat |
| [They Are Billions](https://store.steampowered.com/app/644930/They_Are_Billions/) | RTS-style colony expansion, hostile swarms, defensive infrastructure, and survival pressure |

The objective is to combine **factory engineering, military production, and defensive strategy** into one cohesive game.

## 3. Non-Negotiable Gameplay Pillars

### A. Factory Production Drives Military Power

- Manufacturing military supplies is a principal objective of factory construction.
- **Ammunition is the primary intended end product** of the core factory chain, not just an incidental recipe.
- Ore, ingots, components, and intermediate goods exist to feed increasingly useful production chains.
- Weapons, defenses, and future military systems should consume supplies that the player produces or delivers.
- Broken or congested supply lines should eventually affect combat readiness (for example, turrets may run out of ammunition when not resupplied).
- Factory design and defensive placement should create meaningful tradeoffs.

### B. Logistics Is Physical, Readable, and Player-Built

- The **final gameplay model uses physical conveyor belts**, not invisible proximity-based transfers between nearby buildings.
- One **Conveyor Belt** construction tool places directional segments. Straight runs and left/right corners are determined by placement, connections, and direction; separate straight/left/right build-menu items are not required.
- **Conveyor Splitter** and **Conveyor Merger** are distinct, placeable logistics buildings. Ordinary conveyor belts do **not** autonomously branch, merge, or decide routing.
- Machines, storage, splitters, mergers, and conveyors will connect through explicit input/output connection rules.
- Disconnections, blocked outputs, unavailable inputs, full destinations, and throughput constraints must behave predictably without deleting or duplicating items.
- More advanced distribution rules (e.g., filtering/priority splitters), trains, and other logistics systems are potential later expansions.

**Prototype transition rule:** Existing Chat 05–06 short-range automatic inventory transfers are temporary scaffolding. Retain them until a tested physical conveyor chain replaces them. Do not expand proximity-transfer behavior as the final logistics design.

### C. Manufacturing Recipes Determine Machine Inputs

- A manufacturing building supports an appropriate set of selectable production recipes.
- The player chooses the active recipe for each machine.
- The selected recipe determines which ingredient types may enter that building through its input ports.
- Inputs that do not belong to the active recipe must be rejected safely rather than being absorbed or destroyed.
- The machine produces only when required ingredients are present and output capacity is available.
- Changing a recipe must not silently delete, transform, or strand previously stored items; safe recipe-switch rules must be designed and tested.
- A reusable, data-driven recipe and production architecture is preferred over hardcoding machine-specific behavior.

### D. Storage Is Flexible and Simple for Players

- Standard warehouses accept **any ordinary item type**, including raw materials, manufactured products, and ammunition.
- Offer three warehouse sizes: **Small, Medium, and Large**.
- Storage uses a configurable **number of item slots**, with per-item stack limits. Each slot holds one item type; multiple stacks may exist for the same item.
- Storage sizes differ mainly in available slot count/capacity, not mandatory raw-vs-finished resource restrictions.
- Actual slot counts, stack sizes, and balancing values remain undecided.
- Specialized structures such as ammunition magazines can be considered later for defense-related behavior, without making ordinary storage unable to hold ammunition.

### E. The World Is Occupied and Threatening

- The first playable world is a **zombie colony planet** with scattered buildings, low-density settlements, towns, industrial ruins, and eventually small cities.
- Hostile populations should be associated with meaningful **spawn buildings, nests, or hive-like locations**, not only arbitrary enemies appearing in empty space.
- Different structures/areas may support different enemy types, quantities, and tactical threats.
- Spawn locations and enemy-controlled territories create decisions: **clear, contain, bypass, or exploit** an area while expanding the factory.
- Buildings, extraction sites, supply lines, power infrastructure, and defensive positions may become enemy targets.
- Zombie behavior, spawn replenishment, threat escalation, and population limits need subsequent design and testing; none are finalized merely by this vision.
- Candidate future attraction systems include noise, light, pollution, heat, and nighttime changes; treat these as hypotheses rather than promised mechanics.

### F. Planet-Specific Warfare and Progression

- The zombie colony is the **first** planet/prototype, not the only planned setting.
- Future planets or environments may feature different enemy factions (e.g., creatures, hostile machines, or other adversaries) and different resources or defensive challenges.
- Enemy behavior and available resources should influence the factory layout, defenses, and expansion strategy.
- Multiple planets, interplanetary logistics, vehicles, trains, research tiers, and other major systems are **future possibilities** to evaluate after the core single-player game loop works.

## 4. Representative End-to-End Factory Chain

The long-term factory might follow this pattern (exact intermediate recipes are still to be designed):

```text
World Resource Deposit
        |
     Extractor
        |
  Conveyor Belt
        |
  Processing Machine / Smelter  [selected recipe controls accepted inputs]
        |
  Conveyor Belt
        |
  Component / Ammunition Factory
        |
  Conveyor Belt
        |
  General Storage or Defense Supply
        |
    Turrets / Defensive Systems
        |
  Survive attacks from hostile spawn buildings and surrounding territory
```

Optional logistics buildings:

- A **Splitter** distributes one incoming line to multiple outputs.
- A **Merger** combines multiple incoming lines into one output.
- A future smarter splitter may route by item type, priority, or overflow.

The player should be able to understand **where an item came from, where it is going, and why it is blocked**.

## 5. The First Night — Initial Playable Vertical Slice

The first complete gameplay milestone should prove the interaction between industrial production and a meaningful zombie threat.

**Target experience:**

1. Enter the zombie-colony world and inspect nearby terrain and abandoned structures.
2. Locate a resource deposit and establish an extractor.
3. Build a small physical conveyor-connected processing and ammunition-production chain.
4. Store and deliver usable ammunition to defensive structures.
5. Identify nearby hostile buildings or spawning areas.
6. Build a perimeter or other simple defenses while there is time to prepare.
7. Face a significant first-night zombie attack originating from the surrounding threat environment.
8. Survive or fail based partly on defensive positioning and the reliability of ammunition production/supply.

**Vertical-slice success criterion:** The player sees factory output become real defensive capability, and disruptions or insufficient production create understandable survival consequences.

This does not require multiple planets, trains, advanced enemies, splitters, detailed art, or a full campaign. Keep the smallest enjoyable and demonstrably functional version.

## 6. Visual and Interaction Direction

- **Engine baseline:** Godot 4.6.2 Stable, GDScript, desktop Windows target.
- **Presentation:** Detailed 3D industrial/post-apocalyptic aesthetic over time; dark, gritty factories, abandoned settlements, machinery, debris, and overwhelming hostile populations.
- **Controls:** RTS-style camera/navigation, click selection, grid-based placement, building rotation, and demolition.
- **Art workflow:** Placeholder geometry first; Blender is intended for eventual detailed 3D production assets and animation.
- **Gameplay first:** Maintain readable machine status, recipe selection, item movement, inventory contents, and clear feedback about blockages before prioritizing polish.

## 7. Confirmed Decisions vs. Design Questions

### Confirmed Direction as of Chat 07

- Factory automation and horde-defense are co-equal, connected systems.
- Ammunition manufacturing is the principal end-product goal of the production chain.
- Physical directional conveyor belts replace proximity transfer as final logistics.
- One conveyor placement tool makes straight segments and turns automatically.
- Splitters and mergers are dedicated, placeable logistics buildings.
- Manufacturing recipes are selected per machine and govern input acceptance.
- Standard warehouses are universal and come in three sizes with slots/stacks.
- The first world is a zombie-colony environment with structure/area-based hostile spawns.
- Different enemy types/factions can appear in different locations and later on different planets.
- First Night is the initial integrated vertical slice.
- Focus on modular, testable single-player systems before broader scope.

### Open Design Questions (Do Not Treat as Finalized)

- Exact storage slot counts, stack limits, and item sizes.
- Details of belt speed, item occupancy, placement drag, elevation, and connection resolution.
- Machine input/output port positioning and how recipe changes deal with buffered leftovers.
- Splitter/merger throughput and precise fairness/priority rules.
- Ammunition recipes, ammo types, loading/reloading, turret consumption, and defense balance.
- Zombie archetypes, spawn conditions, replenish/finite-population rules, pathfinding, and wave/day-night pacing.
- How strongly noise, light, pollution, and other factory signals attract enemies.
- Which vehicles, trains, planets, and technology systems to prioritize beyond the vertical slice.

A proposed mechanic moves from **Open Question** to **Confirmed Direction** only when intentionally agreed upon and documented.

## 8. How to Use This Document

| File | Role |
| --- | --- |
| **`docs/GAME_VISION.md`** | Why the game exists; intended experience; confirmed long-term direction and guardrails |
| `docs/GAME_DESIGN.md` | Detailed mechanics and the current design, including what is already implemented |
| `docs/ARCHITECTURE.md` | Actual component/scene/code structure and integration contracts |
| `docs/ROADMAP.md` | Current milestones, dependencies, and checked-off development work |
| `docs/FUTURE_FEATURES.md` | Interesting options not yet scheduled or committed |
| `docs/DEVLOG.md` | Historical record of changes, tests, problems, and lessons |

**Decision filter for every major feature:**

1. Does it improve physical factory automation, military production, enemy/world pressure, or their interaction?
2. Does it serve the First Night vertical slice or a deliberately chosen follow-up milestone?
3. Can it be implemented modularly and tested without breaking proven systems?
4. Is it a confirmed design choice, or should it remain in `FUTURE_FEATURES.md`?
5. Does it preserve an understandable player experience rather than adding complexity for its own sake?

**Development discipline:** Make one small change at a time, explain why, run regression/conservation tests, then commit gameplay changes and update documentation. The vision guides the work; the roadmap schedules it; the devlog records what actually happened.

---

*This document captures design intent, not an implementation claim. Update it only when the vision or an agreed design principle changes, and keep implementation status in the roadmap, architecture, and devlog.*
