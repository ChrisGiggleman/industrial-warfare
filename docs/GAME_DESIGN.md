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

Current prototype limitations: Test Ore is the only mineable world resource; physical conveyors, advanced routing, and a finalized player-facing mining UI remain unimplemented. Chat 05 added capacity-limited inventories and short-range extractor-to-storage delivery; Chat 06 added storage-to-smelter input delivery and real ore-to-ingot manufacturing. The committed test deposit is currently finite with 500 starting units, rather than infinite; this is a test configuration.

### Production

**Implemented in Chat 06 as the first actual manufacturing chain.** Machines use data-defined recipes with required inputs, outputs, and a production cycle duration.

The first permanent recipe is:

```text
2 Test Ore  --2 seconds-->  1 Test Ingot
```

- `test_ingot.tres` is the first manufactured item; `test_smelting.tres` describes its conversion recipe.
- The placeable **Test Smelter** is building option **4** and has **two independent inventories**: 50-unit input storage for raw material and 100-unit output storage for finished products.
- Production begins only when every recipe ingredient is available and all outputs have room; the cycle completes with input consumption and finished-item creation.
- When ingredients are missing or output storage is full, production stops, resets progress, and reports its operating status. A verified capacity-limit test stopped at **2/2 ingots** without consuming more ore.
- Recipe validation and synchronous transaction/rollback logic are implemented in the reusable `ProducerComponent`, rather than hardcoded per building.
- The player can inspect live input quantities, required materials, output quantities, inventory capacities, machine status, and a progress bar in the **Production Debug HUD**.

For player feedback, processing and extraction share a reusable progress indicator tied to their actual cycle timers. It moves only while work can proceed; blocked machines show **0%** and an explicit reason. Storage and resource deposits do not display a processing bar.

**Not yet implemented:** smelter finished-product export, downstream manufacturing steps, machine power/fuel consumption, recipe selection UI, research/recipe unlocks, and final machine art/animations.

### Storage

**Implemented and extended in Chats 05–06.** Test Storage is a placeable, selectable, rotatable, demolishable building with a shared **200-unit** inventory. Test Extractor has **50 units** of internal inventory. Each individual inventory counts all its own item types toward its capacity and accepts only what fits.

The Test Smelter reuses the same inventory component class twice for **separate** raw-material and product capacities. Its input inventory holds up to **50 units** (logistics normally targets a 10-ore buffer); the independent output inventory holds **100 finished units**. Ore in the input inventory does **not** consume ingot output capacity.

The debug view reports storage inventory totals and item quantities, while manufacturing buildings report each buffer separately. Dedicated item filters, slot sizes, permanent inventory networks, storage tiers, persistence, and final artwork/UI remain future work.

### Logistics

**Implemented as an automatic short-range chain across Chats 05–06:**

- **Extractor → Storage:** `LogisticsTransferComponent` transfers Test Ore into the nearest eligible Test Storage in a 5-world-unit radius, requesting up to 5 units every 1 second. Transfers respect source availability, destination capacity, and conservation.
- **Storage → Smelter:** `LogisticsInputComponent` on the smelter finds eligible stocked storage within 5 world units and uses the same `InventoryComponent.transfer_to()` primitive. It requests up to 5 Test Ore every 1 second, normally refilling the smelter's input inventory toward **10** ore, rather than filling all 50 slots.

The completed prototype production route is:

**Test Ore Deposit → Test Extractor → Test Storage → Test Smelter → Test Ingots**

Transfers are still deliberately **abstract and proximity-based**. There are no visible belts, inserters, ports, or routed conveyor networks. Finished ingots currently remain inside the smelter's output inventory until future output logistics are implemented.

Extractor logistics reports its status, most recent attempt, and most recent successful transfer. Smelter input logistics also exposes transfer state and the latest quantity moved. Configured transfer rates are upper bounds, not guaranteed throughput.

### Production Feedback

**Implemented in Chat 06:** An extractor or manufacturer has a clear state such as `Extracting`, `Inventory Full`, `Producing`, `Waiting for Inputs`, or `Output Blocked`, as appropriate. Selecting a machine displays one shared HUD `ActivityProgressBar` reflecting its active interval (e.g., 1-second extraction or 2-second smelting).

This is a functional early **debug/player-information interface**. More polished per-building information panels, small world-space progress indicators, machine animations, and status icons remain potential future enhancements.

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

1. RTS camera, selection, construction, rotation, and demolition systems.
2. Data-driven building/item/recipe definitions and reusable runtime components.
3. Finite/infinite deposit extraction with source-dependent placement and capacity-aware mining.
4. Dedicated storage, safe partial inventory transfers, and automatic short-range extractor-to-storage logistics.
5. Actual manufacturing with validated input consumption and output capacity protection; a Test Smelter with separate 50-input/100-output inventories and a 2-ore-to-1-ingot recipe.
6. Automatic storage-to-smelter input logistics (up to 5 ore per second; target buffer of 10).
7. Live input/output inventory HUD, machine status, and shared extraction/manufacturing progress indicator.
8. Chat 06's **36/36** standalone manufacturing assertions and successful end-to-end resource conservation checks.

Potential next milestones, to prioritize before starting the next development chat:

1. Transfer finished ingots out of smelters and introduce a downstream use or recipient, or prototype conveyor/inserter/port routing on top of `InventoryComponent.transfer_to()`.
2. Explore machine-operation constraints (power/fuel), output logistics, and multi-machine scalability.
3. Begin the first zombie enemy, structure damage/health, and basic defense to advance the First Night vertical slice.

The finite-500-ore test is a **regression fixture**, not a finalized resource economy. Historical Chat 05 conservation was 250 deposit + 50 extractor + 200 storage = 500. Chat 06 accounted for **236 deposit + 50 extractor + 200 storage + 10 smelter ore + (2 ingots × 2 ore)** = **500** ore equivalents.

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
