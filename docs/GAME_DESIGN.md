# Industrial Warfare — Game Design

## High-Level Concept

Industrial Warfare is a top-down 3D factory automation and industrial combat game.

The player lands on hostile worlds, gathers resources, builds automated production systems, expands industrial infrastructure, and defends that infrastructure from enemy factions that vary by planet.

The game combines:

- factory automation
- logistics
- resource extraction
- exploration
- base building
- defensive warfare
- abandoned settlements and cities
- planet-specific enemy factions

---

## Core Gameplay Loop

The core loop is:

**Explore → Gather → Build → Automate → Defend → Expand**

The same loop should repeat at increasing scale.

Early progression focuses on establishing basic production. Later expansion should provide greater industrial capability while increasing exposure to threats.

---

## Core Design Pillars

### 1. Build

The player should transform undeveloped or reclaimed territory into a functioning industrial base.

The factory can include:

- resource extraction
- processing
- manufacturing
- storage
- logistics
- power
- defensive infrastructure

The factory itself should become one of the player's primary tools for survival.

### 2. Automate

Manual work should gradually be replaced by machines and logistics.

The player should feel clear progression from:

```text
limited production
        ↓
repeatable machine production
        ↓
connected production chains
        ↓
automated industrial systems
```

Automation should be rewarding because the factory becomes more capable, reliable, and efficient.

### 3. Expand

Better resources and strategic positions should require expansion beyond the starting area.

Expansion should create both opportunity and risk.

A larger industrial footprint may require:

- longer logistics routes
- more power
- additional defenses
- protection of remote extraction sites

### 4. Defend

The world should actively resist industrial expansion.

Enemy factions may threaten:

- the player
- production buildings
- resource operations
- logistics routes
- power infrastructure
- defensive positions

Defense should be integrated into factory design rather than existing as a separate minigame.

### 5. Explore

The world should contain meaningful locations rather than only empty terrain.

Possible locations include:

- abandoned settlements
- towns
- small cities
- industrial ruins
- resource-rich areas
- enemy-controlled zones

Exploration should provide resources, strategic opportunities, information, or danger.

---

## Factory Gameplay Direction

The factory should grow through understandable stages.

### Resource Extraction

**Implemented in the Chat 04 prototype.** Raw ore now comes from selectable world deposits, rather than being created for free by a production recipe.

- Each resource deposit has a data definition specifying its resource item and whether its supply is infinite or finite.
- `ResourceNodeRuntime` reports the quantity actually available during extraction.
- The **Test Extractor** has a detection area and must be placed within range of a compatible world resource node.
- An extractor outside resource range has invalid/red placement feedback and cannot be built there.
- Once placed near a deposit, the extractor collects Test Ore automatically and stores it in its own inventory.
- A prototype infinite deposit does not deplete; a finite deposit decreases in supply and stops yielding ore at zero.
- Selection/debug information shows deposit supply and extractor status, including stored quantity.

**Current design direction:** Infinite deposits are the default for the early factory-and-defense loop so players can focus on building and defending production. Finite deposits are supported for later balance experiments, special resources, or scarcity-oriented scenarios. This is a direction, not a finalized economy balance.

Current prototype limitations: one test resource type, no physical conveyors or distribution networks, and no final player-facing mining UI. Chat 05 added capacity-limited inventories and short-range automatic transfers. The committed test deposit is currently finite with 500 starting units, rather than infinite; this is a test configuration.

### Production

Machines should use data-defined recipes.

A production recipe can conceptually define:

- required inputs
- produced outputs
- production time

Chat 03 proved a standalone autonomous output recipe. In Chat 04, the Test Extractor switched to actual world-node extraction; the original temporary recipe asset was retired. The separate `ProductionRecipe` / `ProducerComponent` framework remains for future processing and manufacturing machines. Recipe input checking/consumption and machine power are not implemented yet. Chat 05 added inventory capacities and direct proximity-based logistics; these have not yet been integrated with manufacturing input consumption.

### Storage

**Implemented as a prototype in Chat 05.** Test Storage is a placeable, selectable, rotatable, demolishable building with a shared **200-unit** inventory. The Test Extractor has **50 units** of internal inventory. Shared capacity counts all resource types together; inventories accept only the amount that fits, and a full extractor does not waste ore from finite deposits.

The Storage debug view reports total items, total capacity, and individual item quantities. Item filters, dedicated slot sizes, networks, storage tiers, persistence, and final artwork/UI remain future design work.

### Logistics

**Implemented at prototype level in Chat 05:** A Test Extractor can automatically move Test Ore into the nearest eligible Test Storage within **5 world units**, at **up to 5 items every 1 second**. The transfer preserves item counts, respects storage capacity, and stops when no eligible destination is available. The `logistics_storage` group identifies receivers and the logistics component ignores disabled placement previews.

The initial connection is deliberately **abstract and proximity-based**, not a visible conveyor belt or network. Future conveyors, connection ports, inserters, input/output routing, prioritization, and multi-machine chains should reuse the existing inventory accounting instead of reimplementing it.

The Debug HUD displays whether logistics is transferring, waiting for resources, or unable to find eligible storage, along with the configured maximum transfer rate, latest attempted quantity, and persistent last-successful quantity. More specific full/unreachable statuses are a future UX improvement.

### Power

Power is planned as a later factory constraint.

Production buildings may eventually require generated and distributed power, but power should not block early prototyping of the core production loop.

---

## Planet and Enemy Concept

Different planets or environments can contain different enemy factions.

The game should not rely on one universal enemy type.

Possible factions include:

- zombies
- biological creatures
- hostile machines
- rogue military forces
- alien organisms
- other planet-specific threats

Each faction should eventually influence how the player builds, expands, and defends the factory.

---

## First Prototype — Zombie Colony World

The first major gameplay prototype takes place on a world containing abandoned human settlements affected by a zombie outbreak.

The environment may include:

- low-density settlements
- towns
- industrial locations
- eventually small cities

Buildings and urban areas can function as hostile population centers.

Zombie-controlled locations may:

- contain enemies
- generate enemies
- protect valuable resources
- block expansion routes
- create persistent threats near the factory

The player may eventually choose to clear, contain, bypass, or exploit these areas.

---

## Factory and Enemy Interaction

Long-term gameplay should connect industrial growth to world pressure.

Possible relationships include:

- expansion exposing more territory
- remote resource sites becoming vulnerable
- logistics routes requiring protection
- valuable industrial areas attracting conflict
- defensive design affecting factory layout
- enemy-controlled settlements limiting expansion

The goal is for factory decisions and combat decisions to influence each other.

---

## First Night Vertical Slice

The First Night vertical slice is the first target for a complete playable experience.

The player should be able to:

1. Enter the world.
2. Explore the immediate area.
3. Locate basic resources.
4. Establish a small factory.
5. Build a simple production chain.
6. Construct defensive structures.
7. Prepare for an incoming zombie attack.
8. Survive the first major night attack.

The vertical slice does not need every planned feature.

Its purpose is to prove that factory building, automation, exploration, and defense work together as one coherent gameplay loop.

---

## Current Prototype Priorities

Completed to date:

1. Core placement, camera, selection, rotation, and demolition systems.
2. Data-driven buildings, items, production recipes, and a reusable producer framework.
3. Finite/infinite deposit-based extraction with capacity-aware mining.
4. Dedicated storage, shared inventory capacity, safe partial transfers, and automatic short-range logistics.
5. Storage/extractor inventory diagnostics and recent transfer activity.

Next priorities:

1. Implement actual manufacturing input validation and consumption to establish an ore-to-product production chain.
2. Prototype visible conveyors, ports, and routing rules that build on `InventoryComponent.transfer_to()`.
3. Explore machine operation/power constraints.
4. Add the first zombie enemy, structure health/damage, and basic defense to advance the First Night vertical slice.

The 500-unit finite-deposit regression (250 remaining + 50 extractor + 200 storage) demonstrates resource conservation, not finalized game economy values.

---

## Development Philosophy

Development should prioritize simple working systems before complexity.

Systems should be:

- understandable
- modular
- testable
- expandable
- documented

Temporary placeholder graphics, debug interfaces, and simplified mechanics are acceptable during early development.

Gameplay functionality is more important than visual polish during the prototype phase.
