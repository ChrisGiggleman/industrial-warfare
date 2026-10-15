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

Raw resources should come from world locations or resource nodes.

Extractor/miner buildings should eventually:

- operate on valid resource locations
- generate raw materials
- store or output those materials
- optionally deplete or interact with resource availability later

### Production

Machines should use data-defined recipes.

A production recipe can conceptually define:

- required inputs
- produced outputs
- production time

The initial prototype proves autonomous output production first. Input consumption, logistics, power, and capacity can be added in later milestones.

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

The current prototype should prioritize:

1. reliable building placement
2. data-driven building definitions
3. item and inventory representation
4. autonomous production
5. resource extraction
6. simple production inputs
7. storage and logistics
8. basic machine/power constraints
9. hostile enemies and defensive structures

This order is intended to prove the factory side of the loop before adding combat pressure.

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
