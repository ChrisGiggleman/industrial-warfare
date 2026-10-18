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

Current prototype limitations: one test resource type, no transport between inventories, no inventory capacity rules, and no player-facing mining UI.

### Production

Machines should use data-defined recipes.

A production recipe can conceptually define:

- required inputs
- produced outputs
- production time

Chat 03 proved a standalone autonomous output recipe. In Chat 04, the Test Extractor switched to actual world-node extraction; the original temporary recipe asset was retired. The separate `ProductionRecipe` / `ProducerComponent` framework remains for future processing and manufacturing machines. Recipe input checking/consumption, logistics, power, and capacity are not implemented yet.

### Storage

Buildings should be able to hold resource quantities independently.

Dedicated storage structures can later add:

- capacity
- item restrictions
- logistics connections
- transfer rules

### Logistics

Conveyors and other transport systems should connect otherwise independent inventories and production machines.

Logistics should be introduced after production and inventory behavior are stable.

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

The current prototype has completed reliable placement, data-driven building definitions, reusable item/inventory data, the first timed producer framework, and deposit-based resource extraction.

Upcoming priorities:

1. basic storage capacity and a dedicated storage building
2. controlled inventory-to-inventory item transfer
3. first automated logistics or conveyor experiment
4. recipe input checks and consumption for manufacturing machines
5. basic machine/power constraints
6. hostile enemies, building health, and defensive structures

This sequence is intended to establish a small functioning factory loop before adding combat pressure.

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
