# Industrial Warfare — Game Design

> **Game vision:** Read [GAME_VISION.md](GAME_VISION.md) first for the long-term design pillars, agreed Chat 07 decisions (recipe-controlled inputs, physical conveyors, universal slot-based storage, dedicated splitter/merger buildings), ammunition-focused factory objectives, and structure-based enemy spawns. This document records detailed mechanics and current implementation; early proximity transfers are temporary scaffolding, not final logistics.

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

Current prototype limits: Test Ore remains the mineable world resource and the test deposit is configured with **500 finite units** for regression work. Physical conveyors, routed machine ports, Merger and Splitter are now implemented; advanced distribution filters, finalized extraction UI, permanent saves and production balance are not. Earlier proximity-based transfers from Chats 05–06 are retained as temporary compatibility scaffolding and should not be confused with the player-built belt routes.

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

**Current update (Chat 08):** Physical Smelter output ports and belt-to-storage ingot export have been exercised in live factory construction. Recipe selection controls and recipe-aware input acceptance remain component-level capabilities, not a finished player-facing recipe menu. Downstream ammunition manufacturing, power/fuel consumption, research/unlocks, and final machine art/animations remain planned.

### Storage

**Implemented and extended in Chats 05–06.** Test Storage is a placeable, selectable, rotatable, demolishable building with a shared **200-unit** inventory. Test Extractor has **50 units** of internal inventory. Each individual inventory counts all its own item types toward its capacity and accepts only what fits.

The Test Smelter reuses the same inventory component class twice for **separate** raw-material and product capacities. Its input inventory holds up to **50 units** (logistics normally targets a 10-ore buffer); the independent output inventory holds **100 finished units**. Ore in the input inventory does **not** consume ingot output capacity.

The debug view reports storage inventory totals and item quantities, while manufacturing buildings report each buffer separately. Dedicated item filters, slot sizes, permanent inventory networks, storage tiers, persistence, and final artwork/UI remain future work.

### Logistics

**Implemented through Chat 08.3G–08.3K:** Player-built, directional, cargo-carrying conveyors now link real building ports. Logistics is physically visible, construction-driven and subject to occupancy/throughput constraints; it is no longer correct to describe the current prototype as having no visible belts or no routed networks.

- **Build Mode:** One conveyor belt tool (key **5**) creates straight segments; automatic left/right turns and source/receiver-side corner conversion handle compatible 90° connections. Missing corners, existing free endpoints, exact bridges, and short fractional/offset connectors can close appropriate gaps without moving existing machines.
- **Grid alignment:** `FactoryGrid` uses a shared one-unit logical grid. Odd footprints (including both 1×1 routing buildings) use integer-centered origins; even footprints use half-unit origins. Rotated machine ports align with conveyor lanes, with offset connectors available for legacy half-grid situations.
- **Physical movement:** Each belt is a directed, capacity-limited item carrier. Real `InputEndpoint` and `OutputEndpoint` markers, reciprocal connections, port occupancy, collision checks and backpressure govern transfers. The timer and orange placeholder cargo visual use path-length-aware motion for fractional and L-shaped segments; cargo retains the same physical speed through short connectors.
- **Recipe inputs and universal storage:** Smelter ports accept ingredients according to the selected recipe; general storage accepts material types independent of recipe choice. Earlier Test Extractor → Test Storage → Test Smelter proximity transfers still exist as legacy prototype scaffolding and require controlled migration to avoid duplicate item movement.
- **Merger, build slot 6:** A **1×1**, **3 IN / 1 OUT** placeable building. Independent bounded input buffers arbitrate fairly to one output buffer. Incoming lines do not merge spontaneously at ordinary belt corners.
- **Splitter, build slot 7:** A **1×1**, **1 IN / 3 OUT** placeable building. The one input buffer distributes items round-robin to available connected outputs; disconnected/full outputs are skipped, with blocked items retained rather than lost.
- **Debugging:** Selecting a routing building shows per-lane inventory/port status, completed transfer counts and the next scheduled lane.

**Observed and developer-confirmed live evidence (2026-10-30):** Small gaps were filled and cargo visibly moved smoothly through the connectors. A constructed 1×1 Splitter displayed **13 completed splits: A 5, B 4, C 4** with all three outlets connected. The three-input Merger was connected and confirmed operational in gameplay; its backpressure and subsequent recovery were also confirmed. The complete ore-to-ingot factory chain worked in live gameplay. Numeric live `From A/B/C` values and a physical-only resource-conservation tally were not supplied.

**Important boundaries:** No unrestricted 3-way connections on a plain belt, no finalized smart filtering/priorities, no safe automatic item-recovery behavior for destructive cargo removal, and no declaration that the temporary proximity-transfer path has been retired. See [CHAT_08_FINAL_REGRESSION.md](CHAT_08_FINAL_REGRESSION.md) for the final regression and outstanding game-session checks.

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

### Working gameplay foundations

1. RTS camera, selection, building placement/rotation and protected demolition.
2. Data-defined items, buildings, recipes, inventory capacities and ore deposits.
3. Test Extractor mining finite resource nodes; Test Smelter processes **2 Test Ore → 1 Test Ingot**.
4. Physically linked building ports and visible, time-based conveyor transport.
5. Straight belt placement, automatic corners, missing-corner joining, source/receiver conversion, two-ended bridges and length-aware fractional/offset connections.
6. Shared factory footprint grid with rotation-aware ports; 1×1 3-input Merger and 1×1 3-output Splitter.
7. Per-building Production Debug HUD, including inventory statuses, progress bars and routing-lane transfer counters.
8. Developer-reported **20/20 manual regression scenes passed** in four rounds, plus verified live Splitter 5/4/4 distribution and confirmed three-input Merger, backpressure/recovery, and full ore-to-ingot factory operation. These are individual Godot F6 runs and developer observations, **not** a single CI suite.

### Accepted milestone and upcoming work

**Core Chat 08 factory logistics: ACCEPTED (2026-10-30).** All 20 listed manual Godot regressions passed; the Merger, Splitter, blocked-output recovery and ore-to-ingot production chain have developer-confirmed gameplay operation. See [CHAT_08_FINAL_REGRESSION.md](CHAT_08_FINAL_REGRESSION.md) for the evidence and limitations.

- **Follow-up hardening:** Check physical-only ore-equivalent conservation with redundant proximity scripts disabled/accounted for *before* retiring that scaffolding; capture detailed throughput telemetry for sustained traffic.
- **System robustness:** Protect/restore cargo through demolition or destruction and verify occupied-port refusal during complex builds.
- **Next game feature:** Progress toward ammunition production and delivery to defensive structures, then the First Night zombie-defense vertical slice; universal slotted storage tiers, final art/FX, and power are later enhancements.

The finite-500-ore deposit remains a regression fixture, not the final resource economy. The historic Chat 06 conservation snapshot was **236 deposit + 50 extractor + 200 storage + 10 smelter input + (2 ingots × 2 ore)** = **500** ore equivalents; this does not describe the new conveyor/multi-building layouts.

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
