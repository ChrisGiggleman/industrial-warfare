# Industrial Warfare — Development Log

---

## 2026-11-09 — E3c2a Sandbox Storage Connections Passed (16/16); E3c2b Snap Preview Staged

**Developer Godot 4.6.2 evidence:** Two screenshots show the mixed planned/finished factory and `ALL 16 CONNECTED STORAGE BLUEPRINT E3C2A TESTS PASSED` (A–P), with normal debugger shutdown. Sandbox shared claims, Storage-first/belt-first port connections, rotation, upstream route activation, ore conservation, backpressure, cancellation, corner preview and Main opt-out were validated.

**E3c2b Stage 1 — new preview change, NOT YET VALIDATED:**

- Added `BlueprintStoragePortSnapPreview.find_nearest()`, a read-only helper that proposes a future belt transform from unfinished job-driven **Test Storage** input or output markers. It respects both E3b and legacy port claims, player-selected R direction, the established 0.65-tile snap radius, and conveyor grid alignment.
- The opt-in `WorldInteraction._get_storage_blueprint_snap_preview()` rejects candidates whose real placement footprint is blocked. The straight conveyor blueprint preview resolves the snap using the **raw world mouse hit**, before normal grid rounding, and displays exactly the transform that will be committed. The old free-grid fallback still applies when no valid snap exists.
- The factory sandbox already enables `enable_connected_storage_blueprints`; Main's default remains **false**, so ordinary conveyors, corner/bridge placement, existing cargo transport and production combat are unchanged.
- New `res://tests/storage_blueprint_preview_snap_e3c2b_test.tscn` has **14 pending F6 checks** for input/output, matching orientation, exact and fractional cursor positioning, forbidden/occupied claims, cancellation return, rotated Storage, enabled/disabled flags and Main opt-out.
- This stage **does not** change actual construction, reservation ownership, reciprocal port activation, worker/material/power readiness, or save/load. Physical links remain owned by the separately validated E3c2a service.

**Next:** Execute the E3c2b 14-check F6 scene in Godot. If it passes, manually test B/5/P/R/LMB/E/X around planned Storage input/output ports, confirm visual hard-snapping and prior normal conveyor placement, then rerun legacy logistics regression.

---

## 2026-11-09 — E3c1 Storage Activation Accepted (18/18); Sandbox E3c2a Staged

**Godot 4.6.2 evidence:** Developer Output screenshot confirms `ALL 18 PLANNED STORAGE PORT ACTIVATION E3C1 TESTS PASSED` (A–R). Storage-first and belt-first construction, real input/output port reciprocity, mixed upstream route ownership, rotation, stale/moved or occupied endpoints, cancellation, demolition, cargo backpressure and conservation were validated.

**E3c2a opt-in sandbox integration — new, awaiting Godot validation:**

- `BlueprintConveyorRouteCoordinator` can now optionally create one E3c0 `PlannedEndpointClaimBroker` and attach both its existing E2b conveyor-route registry and the E3b Storage-port registry to this same broker, with an E3c1 `PlannedBuildingPortActivator`. The feature must be enabled before the coordinator enters the scene tree.
- The controller’s `enable_connected_storage_blueprints` flag defaults **false**. It is enabled in `factory_testing_sandbox.tscn` alongside existing blueprint flags. The original Main scene remains unchanged.
- Upon placing either an unfinished `test_storage` or a straight conveyor blueprint, the controller notifies the coordinator. Newly placed belts first inspect existing unfinished Storage input/output markers for exclusive claims, then seek neighboring belt links. Newly placed Storage can also discover previously placed belts; both construction orders are supported.
- The existing operational conveyor and Storage port-connection methods are used only after both constructions have completed and the activators revalidate their corresponding reservations. Unfinished blueprints remain nonoperational.
- New `res://tests/connected_storage_blueprint_e3c2a_test.tscn` has **16 pending F6 checks**: sandbox-only flags and service ownership; Storage-first input/output, mixed upstream conveyor, broker claim release; deferred real activation; ore-through-Storage conservation and blocked output; Storage cancellation; belt-first planning; rotated Storage; wrong-facing rejection; existing right-corner cancellation; and Main opt-out.
- **Not implemented in this gate:** automatic preview snapping to future Storage ports, UI visual connection lines, player mouse/keyboard acceptance, production power/material/worker availability, and universal save/load. Existing grid snapping remains; players must correctly align belt rotations and tile positions to match the future ports.

**Next:** Run the E3c2a F6 scene. If it passes, implement and separately test future-port preview snapping and manual player E/X/R/LMB controls before expanding from Storage to other production buildings.

---

## 2026-11-09 — E3c0 Shared Claims Passed (18/18); E3c1 Physical Port Activation Staged

**Godot 4.6.2 evidence:** The developer's latest Output screenshot shows `ALL 18 SHARED BLUEPRINT ENDPOINT OWNERSHIP E3C0 TESTS PASSED` (A–R). Opposing claim orders, independent belt input/output, Storage input/output, cancellation, freed sites, completed-belt destruction and final claim cleanup all passed. E3c0 is accepted as an isolated system.

**E3c1 isolated implementation — NOT YET VALIDATED IN GODOT:**

- Added `scripts/components/planned_building_port_activator.gd`, an isolated listener to the validated E3b registry's `reservation_ready` signal. It revalidates the completed Storage `ItemPortComponent`, completed `ConveyorSegment`, expected port direction, original junction and endpoint vacancy before committing.
- Actual activation calls the existing operational `ConveyorSegment.try_connect_building_port()` method rather than manually assigning connection references. Successful commits require reciprocal `port.connected_conveyor` and belt `input_building_port` / `output_building_port`, release the exact reservation (and E3c0 broker keys), then emit `connection_committed`.
- Failed connections leave the reservation pending; the separate `try_commit(id)` path can retry after a moved endpoint, occupied port or invalid direction is corrected. Cargo is never moved during connection activation itself.
- New `res://tests/planned_storage_port_activation_e3c1_test.tscn` contains **18 pending F6 checks**, including mixed E2b belt-to-belt and E3b belt-to-Storage links with one shared broker; Storage-first and belt-first completion; rotated ports; buffered ore transfer through Storage input and output; blocked-output conservation; moved or occupied connections; cancellation, destroyed endpoints and reciprocal cleanup.
- No `WorldInteraction`, Factory Testing Sandbox, Main scene, worker/power/material services or save/load code was changed. **E3c1 is NOT yet a manual player-facing feature** and the new tests are not claimed to have passed.

**Next:** Run the E3c1 18-check F6 scene, inspect any assertions before proceeding. Once accepted, integrate shared claims and Storage-port reservation/activation into sandbox-only blueprint planning with independent scripted and manual regression gates.

---

## 2026-11-09 — E3b Storage Port Reservations Accepted (18/18); Shared Claims E3c0 Staged

**Evidence:** Developer Godot 4.6.2 Output screenshot shows `ALL 18 PLANNED BUILDING PORT RESERVATION E3B TESTS PASSED` (A–R), with normal debugger shutdown. Independent input/output claims, both build orders, released/cancelled endpoints, moved geometry, completed-object removal and non-operational status were all verified.

**E3c0 implementation — awaiting first local Godot execution:**

- Added `scripts/components/planned_endpoint_claim_broker.gd`, a shared endpoint authority using stable `ConstructionSite` identity plus directional side. Both E2b belt routes and E3b Storage-port routes now claim the exact same `belt in/out` keys when connected to one broker.
- Each claim transaction reserves both keys atomically. Owner strings include the registry instance ID and local reservation ID, ensuring one system cannot accidentally release the other registry's claim.
- `PlannedConveyorRouteReservations.set_claim_broker()` and `PlannedBuildingPortReservations.set_claim_broker()` are **optional** so earlier isolated suites still work. A broker cannot be attached after pending reservations exist, or rebound later. When a registry's reservation ends, its broker keys are released even if its construction sites were freed.
- Added `res://tests/shared_blueprint_endpoint_ownership_e3c0_test.tscn` with **18 planned checks**: belt-first and Storage-first competition, separate in/out claims on one conveyor and one Storage, cancelled construction, unexpected removal, freed sites, completed-belt destruction, and final cleanup. **F6 validation is pending.**
- This is deliberately a shared-ownership *prerequisite*, not a physical connection. Existing `WorldInteraction`, sandbox scene, cargo transport and Main remain unchanged; E3b is **not yet enabled alongside E2b in the player sandbox**.
- **Next after E3c0 passes:** E3c1 read-only real port readiness and one-time physical activation with cargo conservation, then isolated sandbox wiring and manual acceptance. Do not interpret E3c0 as end-to-end factory operation.

---

## 2026-11-09 — E3a Planned Storage Port Geometry Passed (15/15); E3b Reservations Staged

**Godot 4.6.2 evidence:** Developer-provided Output screenshot confirms `ALL 15 PLANNED BUILDING PORT GEOMETRY E3A TESTS PASSED` (PASS A–O): directed future Storage input/output port matching, separate rotated junctions, invalid-facing and offset rejection, queued/paused acceptance, cancellation/completion rejection and no premature inventory activation.

**E3b source checkpoint — local Godot validation pending:**

- Added `scripts/components/planned_building_port_reservations.gd`. Each directed reservation exclusively claims one unfinished building input or output and the matching conveyor blueprint output or input **within this isolated registry**.
- Per-reservation completion, cancellation and exit observers retain immutable claim keys and completed real-object references across deletion of the temporary sites. Distinct callbacks allow one Storage plan to reserve both its input and output without missing construction events.
- `get_ready_candidate()` is read-only and requires both completed instances, correct real `ItemPortComponent` direction, an unoccupied conveyor endpoint, unchanged original junction and matching endpoint geometry. It does **not** connect or transfer cargo.
- Cancelling, unexpectedly removing or destroying a site/finished object releases both claims. Existing live-belt-to-planned-Storage `ConstructionSite.reserve_conveyor()` claims are respected.
- Added `res://tests/planned_building_port_reservations_e3b_test.tscn` with **18 pending F6 checks** for independent input/output claims, duplicate rejection, Storage-first and belt-first completion, rotated sites, stale alignment, freed-site cleanup, cancellation, unexpected deletion, completed-object destruction and legacy-reservation priority.
- Important boundary: E3b does **not yet share a single claim broker with E2b conveyor-to-conveyor reservations**. Exclusive ownership *across both registries* is an explicit prerequisite before wiring E3b into `BlueprintConveyorRouteCoordinator`. No gameplay scene, cargo transfer code or independent save system changed.

**Next:** Run E3b's 18-check scene. Only after it passes, design shared claim ownership and a separately validated reciprocal physical port-activation transaction (E3c) before sandbox UI integration.

---

## 2026-11-09 — Post-E2c2 Compatibility Passed (45/45), E3a Geometry Staged

**Godot 4.6.2 evidence:** The developer supplied four Output screenshots verifying the full post-E2c2 regression set: E2b planned route reservations **16/16**, E2c1 physical activation **15/15**, planned Storage Build Mode **6/6**, and conveyor corner cargo **8/8**. Total **45/45**. No failed checks were shown.

**Next gated implementation (not yet Godot validated):**

- Added `scripts/components/planned_building_port_geometry.gd`: read-only inspection of an unfinished job-driven building's planned `InputPort` or `OutputPort` marker against a still-planned straight conveyor site's directed `OutputEndpoint` or `InputEndpoint`, respectively.
- Uses the proven `LogisticsConnectionGeometry.are_endpoints_aligned()` with the operational belt's connection-gap tolerance. The Storage input and output are separate; a reverse-facing belt, wrong port, lateral offset, or excessive gap is rejected.
- Supports correctly rotated planned Storage and job states PLANNED/QUEUED/CONSTRUCTING/PAUSED. Cancelled or completed placeholders are no longer valid connection targets; operational building ports must be handled by a later activation transaction.
- New `res://tests/planned_building_port_geometry_e3a_test.tscn` has **15 scripted checks**; developer F6 **pending**. It does not create any reservation, power, material delivery, worker, cargo inventory or physical logistics link.
- `WorldInteraction`, `BlueprintConveyorRouteCoordinator`, Main, operational factory systems, combat and save/load remain unchanged in this checkpoint.

**Later, separately tested:** E3b exclusive Storage future-input/future-output ownership with cancellation and build-order survival; E3c reciprocal real port activation and cargo conservation. The existing delayed-connection Storage code remains intact.

---

## 2026-11-09 — Blueprint E Authorization Independent of Preview Rotation

**Manual Godot evidence:** Developer provided four screenshots and confirmed an already-placed planned corner successfully authorizes and builds with **E** no matter which direction the currently selected conveyor placement preview faces.

- The earlier reported extra-rotation restriction was not reproduced for E authorization; no change to blueprint cursor targeting is warranted.
- The receiving belt still needs to face the correct direction **when placing the route** to form a valid directed connection. Optional automatic orientation of the next placement preview can be considered separately after broader logistics regressions.
- Automated E2c2 **17/17** and all six prior manual checks remain accepted. This additional check closes the outstanding direction-vs-authorization question.
- **Next gate remains pending:** post-E2c2 E2b (16), E2c1 (15), planned Storage Build Mode (6), and conveyor corner cargo (8), totaling **45 checks**, before extending blueprint routes to unfinished Storage ports.

---

## 2026-11-09 — Manual Connected Conveyor Corner Acceptance

**Manual Godot evidence:** Developer confirmed all six player-control steps in the Factory Testing Sandbox passed and supplied three game screenshots showing translucent connected corner blueprints and completed working 90-degree conveyor layouts.

- Player-facing right/left corner planning, blueprinted direction cues, E authorization and timed construction, X cancellation/return to straight, and regular P-off conveyor placement were all reported successful.
- This complements the separately verified automated **17/17 E2c2** suite; the Main scene remains opted out.
- **UX observation (not yet diagnosed):** The developer reports needing to rotate the selected conveyor so it faces the intended direction before a corner blueprint can be built. Direction-correct placement of the receiving belt is an intentional port requirement; however, authorization of an *already placed* site via E should not depend on current ghost rotation. The current `_blueprint_site_under_mouse()` selection-ray path and `_authorize_blueprint_site()` do not inspect ghost yaw. A focused manual confirmation is needed before changing the UI or ray selection.
- No gameplay fix is claimed by this documentation checkpoint. Explore optional automatic receiver preview orientation after distinguishing route placement from E authorization.
- **Next compatibility gate:** rerun E2b reservations (16), E2c1 activation (15), planned Storage Build Mode (6), and conveyor corner cargo (8) — **45 checks** — after accepting the player-facing integration. Then proceed toward planned-building port links with end-to-end inventory conservation.

---

## 2026-11-09 — E2c2 Connected Conveyor Blueprint Automation Passed (17/17)

**Godot 4.6.2 evidence:** Developer supplied the game view and Output screenshots for `res://tests/connected_conveyor_blueprint_e2c2_test.tscn`, showing PASS A–Q and `ALL 17 CONNECTED CONVEYOR BLUEPRINT E2C2 TESTS PASSED`. The rendered factory sandbox contains a mix of planned translucent conveyor segments and completed directional belts.

- New player-sandbox route coordinator creates exclusive pending straight/left/right neighbor reservations without creating live transport on unfinished sites.
- Both mirrored planned-corner shapes and real physical completion were validated; cancellation restores an unfinished source to a straight blueprint.
- Source-first/receiver-first build activation and a three-belt, two-hop cargo conservation scenario passed.
- Compact blueprint labels and Main's opt-out defaults were also covered.
- Output includes routine `Extractor has no resource node` and `Hit nothing` diagnostics after the passing summary; no failing E2c2 checks are shown.
- **This was an automated F6 scene**, not a manual player-input acceptance of B/5/P/LMB/R/E/X. Manual right/left blueprint placement, cancellation/replanning and normal P-off belt construction remain the next gate.
- Continue to protect existing Main, combat, cargo, and the eventual integrated save/load design. Production power, physical material delivery and worker drones are not yet implemented.

**Next:** Complete manual E2c2 input tests, then rerun E2b (16), E2c1 (15), planned Storage Build Mode (6), and corner cargo (8) regressions before planning belt connections to unfinished Storage.

---

## 2026-11-09 — E2c2 Sandbox Connected Blueprint Corners Staged (17 Checks Pending)

**Status:** New opt-in code committed to `main`, **not yet Godot validated**. E2c1 physical activation passed all 15 checks in the developer's previous F6 screenshot.

- Added `BlueprintConveyorRouteCoordinator` as a sandbox-only Node. It owns a `PlannedConveyorRouteReservations` registry and `PlannedConveyorRouteActivator` instance, scans nearby unfinished straight-belt sites on placement, and reserves up to one directed incoming and one outgoing link.
- The existing `WorldInteraction._create_straight_conveyor_blueprint()` now notifies the coordinator only when `enable_connected_conveyor_blueprints` is enabled; the flag is true in `factory_testing_sandbox.tscn` and **false by default** for Main and all other scenes.
- `ConstructionSite.set_planned_conveyor_turn()` replaces a non-operational straight placeholder mesh with the existing `ConveyorCornerVisualMesh` left/right shape, copies the appropriate corner output marker transform, changes the directional arrow, and retains an original marker for safe rollback. `clear_planned_conveyor_turn()` restores straight geometry on reservation cancellation.
- The E2b registry now emits `reservation_released` after removing a claim. The coordinator uses `WeakRef` for planned source sites and only clears still-unfinished source visuals; it cannot resurrect deleted sites or change completed conveyors.
- Compact `PLANNED` labels reduce overlap on adjacent one-tile conveyor blueprints. No visual plan contains live `CargoInventory`, transport timers, or active links before construction.
- `res://tests/connected_conveyor_blueprint_e2c2_test.tscn` contains **17 scripted checks** for standalone/straight and mirrored corners, output marker transforms, cancellation rollback, source-/receiver-first completion, three-segment chains, ore conservation and Main opt-out. **Developer F6 execution remains pending.**
- No standalone save/load feature, real Power Station, drones, or new enemy factions were introduced. Building-port blueprint connections, manual full-route editing and short-gap bridges are not included in this initial E2c2 gate.

**Next:** Run the 17-check scene. If it passes, manually use B/5/P/LMB to lay a straight-to-right or straight-to-left plan and confirm the corner visually updates before E authorization. Then rerun E2b, E2c1 and legacy cargo/Build Mode regressions before broadening planning to unfinished Storage ports.

---

## 2026-11-09 — E2c1 Deferred Physical Connections Accepted (15/15)

**Godot 4.6.2 evidence:** Developer Output screenshot reports `ALL 15 PLANNED CONVEYOR ACTIVATION E2C1 TESTS PASSED` (A–O), with normal debugger shutdown.

- Direct, right-turn and left-turn routes activate only after both real conveyors complete, regardless of which finished first.
- Reciprocal links and multi-segment chains transfer physical cargo with no duplication; waiting ore is retained before activation.
- Stale geometry, occupied ports, cancelled construction and demolished endpoints do not create unsafe connections.
- The existing operational connection helper remained unchanged. Player-facing Blueprint Mode had not yet been integrated in E2c1.

**Next gate:** E2c2 sandbox-only connection discovery and planned-corner visual indicators; revalidate the completed activation flow and legacy Build Mode separately. The Main scene and power infrastructure remain unchanged.

---

## 2026-11-09 — E2c1 Deferred Conveyor Activation Staged (15 Checks Pending)

**Source checkpoint, not yet tested in Godot:** Added `scripts/components/planned_conveyor_route_activator.gd` and `res://tests/planned_conveyor_activation_e2c1_test.tscn`.

- The isolated `PlannedConveyorRouteActivator` listens to the validated E2b registry's `reservation_ready` signal. It attempts a physical connection only after `get_ready_candidate()` confirms both completed real belts, compatible endpoints, matching planned turn and unchanged junction.
- `ConveyorExistingConnection.try_connect_candidate()` performs the already-tested direct/left/right transaction and independently revalidates the final geometry. Reciprocal belt references must exist before the adapter releases reservation claims and emits `connection_committed`.
- A missed or rejected connection leaves the reservation pending, including moved geometry or occupied ports. `try_commit(id)` supports explicit retry after those conditions are corrected; no premature cargo transfer occurs.
- The new **15-check E2c1 F6 scene** covers receiver/source-first direct links, right/left corner conversion, held and delivered ore, two-link route conservation, stale geometry rejection/retry, occupied input/output protection, cancellation and completed-belt deletion. **Pending developer execution; not yet 15/15.**
- No changes to live `WorldInteraction`, building HUD, Main, factory construction sites, existing operational conveyor modules, AI/combat, or save/load. The physical activation adapter is not yet connected to player-created blueprints.
- **After passing:** create a separate sandbox-only E2c2 gate to register placed blueprint neighbors, render the planned turn and authorize actual connection activation. Test all manual controls and cargo/demolition regressions.

---

## 2026-11-09 — E2b Exclusive Route Reservations Accepted (16/16)

**Godot 4.6.2 evidence:** The developer's latest Output screenshot shows `ALL 16 PLANNED CONVEYOR RESERVATION E2B TESTS PASSED`, all PASS A–P, and normal debugger shutdown.

- Exclusive directed input/output claims remain safe through three-belt completion, including the shared middle segment receiving both reservation callbacks.
- Plans survive arbitrary job completion order and construction-site retirement without generating premature physical links.
- Right/left corner candidates, stale physical endpoint rejection, cancellation, completed-belt removal, orphaned site cleanup and claim release all passed.
- Earlier failures due to incomplete shared-site callbacks and unsafe casts of freed construction sites are now covered by successful tests.
- No changes to operational conveyor, live Build Mode or Main scene were required to accept this result.

**Next gated implementation:** E2c isolated activation should reuse `ConveyorExistingConnection.try_connect_candidate()` only after `get_ready_candidate()` verifies that both endpoints are completed, oriented, vacant and unchanged. Save UI and planned L-shaped visuals for a later independently tested checkpoint.

---

## 2026-11-09 — E2b Freed-Site Reservation Cleanup Fixed (Retest Pending)

**Godot 4.6.2 evidence:** After the first callback fix, the developer's next F6 screenshot stopped in `PlannedConveyorRouteReservations.release()` at the old line 120, invoked from test I (the explicit A→B release). The Debugger message was `Trying to cast a freed object.` The run had reached test I, so the earlier two-route completion failure no longer appears to be the current blocker.

**Root cause and corrective patch:**

- When a construction job completes, its placeholder `ConstructionSite` is retired. The registry intentionally retains the route reservation and completed `ConveyorSegment` references across that retirement.
- `release()` nonetheless cast `record["source"]` and `record["receiver"]` directly to `ConstructionSite`, which throws in Godot if either stored Variant refers to an already-freed Object.
- Cleanup now checks `is_instance_valid()` on raw saved site and belt Variants **before casting**, disconnecting observers only for existing objects. Exclusive claims are always released using the immutable source/receiver endpoint keys instead of touching freed sites.
- Applied the same validity-before-cast guard to `has_completed_endpoint()`, `get_ready_candidate()`, and the site-exit observer, to avoid related stale-object cast errors during future teardown.
- Test G now explicitly confirms A, B and C sites have been freed before continuing to test readiness. Test I directly exercises releasing A→B after those sites are gone while preserving B→C.
- No operational conveyor, cargo, or player Build Mode scripts were modified.

**Status:** Fix committed to `main`, **16/16 Godot validation still pending**. Next run: `res://tests/planned_conveyor_reservations_e2b_test.tscn` with F6.

---

## 2026-11-09 — E2b First Local Run Failed; Shared-Site Callbacks Revised

**Developer Godot 4.6.2 evidence:** `planned_conveyor_reservations_e2b_test.tscn` stopped at line 99 in test F, with `ready_ids` containing only one ID where `[ab, bc]` was expected. The initial screenshot shows Debugger Errors (4); their detailed messages were not visible. **Do not mark E2b passed.**

**Isolation and fix candidate:**

- The A→B→C test reuses the middle blueprint B as receiver of one reserved route and source of another. Both claims must receive the same `building_completed` event, and neither may steal the other's endpoint.
- Replaced bound shared-method site observers with **distinct per-reservation Callable closures** for completion, cancellation, and tree exit. Saved the exact handles in each reservation record and disconnects them on release; connection failures now roll back their claim. Completed-belt removal observers also use distinct stored closures.
- Added read-only `has_completed_endpoint()` introspection and expanded test E to assert both route records receive the middle belt's completion. Test F now prints candidate and emitted-signal diagnostics if the two-ready assertion fails again.
- No physical conveyor activation, corner conversion, user placement routing, Main scene, or cargo transport code was changed.

**Status:** Fix committed for another local Godot F6 run; **16/16 not yet validated**. If it fails, inspect the detailed Debugger errors and the new diagnostic line before further changes.

---

## 2026-11-09 — E2a Route Geometry Accepted (12/12), E2b Reservations Staged

**Godot evidence:** Developer-supplied Output screenshot confirms all twelve `planned_conveyor_route_geometry_e2a_test.tscn` checks passed in Godot 4.6.2: straight links, right/left turns, rotations, invalid gaps/facing, cancellation, paused/queued eligibility, and finished-site rejection.

**E2b isolated implementation, not yet Godot validated:**

- New `scripts/components/planned_conveyor_route_reservations.gd` tracks exclusive output-to-input blueprint endpoint claims. Each directed reservation records source/receiver site references, anticipated `mode`, `turn`, `junction`, and immutable endpoint keys.
- Every reserved site can be independently authorized and built. The registry listens for `building_completed`, retaining finished real conveyor references even after the site leaves the tree; only after both real belts exist and geometry is revalidated can it emit `reservation_ready`. The signal is not a command to connect until a later activation transaction explicitly validates/commits the route.
- Cancelling either unfinished site, unexpectedly removing one, destroying a completed belt, or explicitly releasing a route clears both endpoint claims. Shared middle blueprint sites may own one input and one output without conflict.
- `get_ready_candidate()` uses the original real-conveyor endpoint finder on the completed instances and rejects moved, occupied, incompatible or stale endpoints. This avoids physical cargo transfers or false connector links while waiting.
- New `res://tests/planned_conveyor_reservations_e2b_test.tscn` has **16 F6 checks**, including a three-belt route, duplicate blocking, completion in either order, right and left turns, release after site retirement, stale geometry rejection, cancellation and demolition. **Developer execution pending.**
- Existing `WorldInteraction`, `ConstructionSite`, operational conveyor components, Main scene, production and save/load architecture were **not modified** for E2b. Player-facing right-angle blueprint visuals and physical connection activation remain E2c.

**Next:** Run the E2b F6 scene. Do not enable automatic blueprint connections until E2b passes and the E2c activation/cargo tests are designed.

---

## 2026-11-09 — E1 Manual Acceptance and E2a Planned Corner Discovery Staged

**Manual acceptance:** The developer confirmed all seven E1 Factory Testing Sandbox steps completed. Screenshots show a set of transparent `PLANNED 0%` directional conveyor sites and the equivalent constructed real belts. Mouse placement, visible direction, E authorization and two-second build completion, X cancellation and released-space reuse, and normal P-off Build Mode are reported working.

**Observed limitation:** Perpendicular blueprint straights currently remain separate pieces and do not create a real 90-degree planned corner. This is **expected E1 scope**, because P-mode intentionally avoids the live `ConveyorCornerConversion` and endpoint-connection paths. The goal is to restore automatic turning for blueprints after they can reserve a graph edge safely.

**E2a source checkpoint (not yet Godot validated):**

- Added `scripts/components/planned_conveyor_route_geometry.gd` to inspect two unfinished straight-conveyor sites and return a direct, right-turn, or left-turn candidate. It uses the exact output transform from the corresponding existing real corner PackedScene and the established physical endpoint gap/direction thresholds, without creating or modifying an active conveyor.
- Eligibility excludes cancelled and completed jobs, unrelated definitions, invalid orientation and misplaced receivers. Queued and paused sites still carry valid geometry.
- Added `res://tests/planned_conveyor_route_geometry_e2a_test.tscn` with **12 scripted checks**, covering direct adjacency, unmodified blueprint state, right/left templates, rotated layouts, incorrect facing/distance, invalid/self targets, pause, cancellation and completion. **Run in Godot F6 before continuing.**
- This is intentionally discovery-only. It does **not** change the on-screen corner shape, store an exclusive route reservation, activate a link, or modify cargo. E2b will own pending route claims and release them during cancellation; E2c will commit the correct corner shape and connect only fully built endpoints after revalidation.
- Existing Main gameplay, functional conveyor geometry/cargo, zombie systems and save architecture remain unchanged.

---

## 2026-11-09 — Straight Conveyor Blueprint E1 Automated Regression Passed (14/14)

**Evidence:** Developer-provided Godot 4.6.2 Output screenshot of `res://tests/conveyor_blueprint_e1_test.tscn`, showing all PASS A–N and `ALL 14 STRAIGHT CONVEYOR BLUEPRINT E1 TESTS PASSED`.

- Scripted regression verifies that cardinal straight conveyor plans reserve a one-tile footprint, preserve planned endpoint geometry and direction, and lack operational cargo/transport before construction completes.
- Authorization fails closed without power/material/worker availability, pauses without lost progress, and creates one real `ConveyorSegment` with inventory and transport on the two-second job's completion.
- Invalid rotations and overlapping plans are rejected, cancelling a plan prevents activation, and its tile can be reused; completed belts do not create phantom links or duplicate instances.
- The sandbox test-only requirements override remains separate from actual future power, materials and construction workers. Main Build Mode is still opted out.
- The screenshot contains `Hit nothing` after the successful test summary. No test assertion failed; this is a separate interaction diagnostic, not a construction regression.
- **Pending:** Manual keyboard/mouse test for B/P/5/LMB/E, direction arrows, completion and X cancellation in the Factory Testing Sandbox. Scripted assertions cannot prove the real cursor controls or belt visuals.
- **After manual acceptance:** Recheck normal live conveyor Build Mode before enabling the E2 connection-graph work. No gameplay code changed for this documentation checkpoint.

---

## 2026-11-09 — Conveyor Compatibility Passed and Straight Blueprint E1 Staged

**Validated in Godot 4.6.2:** Developer-provided Output screenshots show the post-Blueprint-Mode `planned_storage_build_mode_test.tscn` passed **6/6** and `conveyor_corner_cargo_test.tscn` passed **8/8**, a combined **14/14** on the prior E0 controller revision.

**Phase E1 implementation — pending local validation:**

- Added `scripts/components/conveyor_blueprint_placement.gd` to check one straight conveyor's cardinal orientation and integer-grid tile against other unfinished footprints, same-frame completed conveyor tiles and physical placement blockers.
- The sandbox's existing P Blueprint Mode can now place **stand-alone straight belt sites only** using the definition's two-second duration. Selected conveyor ghosts in P mode use a dedicated no-snap preview instead of the existing live conveyor corner/bridge/port discovery. The normal non-P conveyor placement route is untouched.
- Planned belt sites are non-operational: only reserved collision, future endpoint markers, `PLANNED` progress and a visible direction arrow exist. No `CargoInventory`, `ConveyorTransportTimer`, completed port links or transport is created before job completion.
- E authorization and X cancellation reuse the previously validated blueprint job controls; the explicit sandbox debug override supplies synthetic readiness for testing only.
- The new `res://tests/conveyor_blueprint_e1_test.tscn` contains **14 scripted checks**, including geometry, reservation exclusivity, queued requirements, pause/resume, 2-second activation, direction, no phantom physical connections, duplicate rejection and cancellation/reuse. **Not yet run in Godot.**
- **Deliberately out of scope:** planned belt-to-belt linking, planned Storage input/output snaps, corner chains, build-order-independent physical connection and construction materials/power/drones. All require dedicated E2/E3 architecture and regression tests.
- Main scene remains opted out. No standalone save system or new enemy factions were introduced.

**Next acceptance:** Run E1 F6 14-check test; then manual belt-plan P/LMB/E and cancellation X in the zombie-free Factory Testing Sandbox before adding any live conveyor graph behavior.

---

## 2026-11-09 — Blueprint Cancellation and Footprint Reuse Manually Accepted

**Evidence:** Developer screenshot of a translucent `PLANNED 0%` Storage site in Godot 4.6.2 and explicit confirmation that all six manual steps passed in the Factory Testing Sandbox.

- Successfully placed an unauthorised blueprint while Blueprint Mode was active.
- Attempted another Storage blueprint on the same footprint and confirmed that the duplicate was rejected.
- Hovered the original site and pressed **X** to cancel; the unfinished reservation disappeared.
- Successfully placed a new plan on the previously reserved footprint.
- Combined with the preceding seven-step cursor/E authorization test and the scripted Blueprint Mode suite **12/12**, the non-conveyor building Blueprint Planning interactions are now accepted in the sandbox.
- This acceptance confirms player-reported overlap/cancellation outcomes; the screenshot independently shows the blueprint placeholder and `PLANNED 0%` label. No new power generation, worker drones, physical material delivery, conveyor-blueprint topology, or main-game save system was introduced.
- **Next compatibility gate:** Re-run `res://tests/planned_storage_build_mode_test.tscn` (**6 checks**) and `res://tests/conveyor_corner_cargo_test.tscn` (**8 checks**) on the current branch. Earlier results predate the Blueprint Mode controller edits.
- **Future gate:** Design directional planned-conveyor graph reservation, activation/corner semantics and cancellation before enabling conveyor Blueprint Mode. Keep the normal Build Mode and Main scene unchanged until this is validated.

---

## 2026-11-09 — Manual Blueprint Storage Authorization Accepted

**Manual Godot F6 evidence:** Developer explicitly confirmed all seven Factory Testing Sandbox instructions completed successfully.

- Entered Build Mode with **B**, selected Storage with **3**, and toggled the distinct **BLUEPRINT MODE (TEST)** interface with **P**.
- Left-clicked an open area to create a translucent Storage plan displaying `PLANNED 0%`.
- Hovered the planned site and pressed **E**; construction began and progressed to a completed real Storage after the definition-defined duration.
- This verifies actual cursor/keyboard interaction for blueprint placement and authorization beyond the earlier **12/12** scripted test.
- **Not yet manually accepted:** Hover + **X** to cancel a new unbuilt blueprint; duplicate/overlapping placement rejection and safe replacement after cancellation. These are the next targeted tests.
- No gameplay changes were made during this acceptance checkpoint; Main remains opt-out, and the sandbox debug requirements bypass is still a testing aid rather than actual grid/material/worker implementation.

---

## 2026-11-08 — Sandbox Blueprint Planning Scripted Regression Passed (12/12)

**Godot evidence:** Player-provided screenshot of `res://tests/blueprint_sandbox_mode_test.tscn` showing `ALL 12 SANDBOX BLUEPRINT PLANNING TESTS PASSED` in Godot 4.6.2 (PASS A-L).

- Sandbox-only Blueprint Mode and explicit readiness override remain opt-in. Main scene defaults are unchanged.
- The script verified P toggle and HUD, rotated Storage plan geometry, footprint/off-grid rejection, unsupported belt fail-closed behavior, queued work with missing resources, progress pausing, completed real Storage activation, defensive-plan cancellation and test-only authorization override.
- The screenshot also shows `Extractor has no resource node` after the passing checks. This is an existing placement validation diagnostic, not a failed check; investigate only if manual blueprint interaction is affected.
- These scripted checks directly invoke the controller methods rather than exercising mouse ray targeting or real E/X keyboard input. Manual cursor-driven plan, authorize and cancel testing is now the next acceptance gate.
- **No code change was necessary to record this pass.** Before directional conveyor blueprints, confirm manual interaction and rerun key legacy Build Mode/cargo checks. Keep all new features sandbox-only until independently validated.

---

## 2026-11-08 — Sandbox Blueprint Planning Mode (Building Phase) Staged

**Status:** New opt-in implementation and `res://tests/blueprint_sandbox_mode_test.tscn` committed, **12 checks pending local Godot F6**. No Main scene activation.

- Added `WorldInteraction.enable_blueprint_planning` (false by default) and `blueprint_sandbox_debug_requirements` (false by default). Both are explicitly enabled only in `factory_testing_sandbox.tscn`. This test override is not a real power supply, material-delivery system or construction-drone service.
- In the sandbox's Build Mode, **P** toggles building Blueprint Planning Mode, **LMB** plans a non-operational building footprint, **E** authorizes the blueprint under the cursor, and **X** cancels it. Existing **B**, **R**, **Delete**, configurable 1–9 hotbar and normal Build Mode remain in place.
- Planned structures use the validated opt-in `ConstructionSite.setup_with_definition_job()` and the new `BuildingDefinition.construction_seconds` data. Spatial rules reject overlapping plans and off-grid origins, with physics queries protecting existing built obstacles.
- A blueprint does not produce resources or fire weapons; completion alone creates the real operational scene. The HUD distinguishes BLUEPRINT MODE (TEST), planned/queued/constructing/paused labels, and displays the user controls.
- This first interactive phase intentionally rejects placing blueprint conveyor segments and does not permit a planned building ghost to snap to a live conveyor without a deferred-port reservation. Those functions need further topology and safe connection regressions, not premature activation.
- Test suite **A–L** checks opt-in isolation, UI toggle, rotated footprint, occupancy, fail-closed invalid objects, no-service queuing, pause/resume, delayed real Storage activation, cancellation protection and sandbox-only explicit readiness override.
- Before expanding to blueprint conveyors or making this the default build path, the developer must run the 12-check F6 scene, manually verify the actual cursor interaction, and recheck old placement and cargo paths.

---

## 2026-11-08 — Per-Definition Construction Durations Validated (12/12)

**Godot evidence:** User Output screenshot for `res://tests/building_construction_duration_test.tscn` showing all twelve assertions passed in Godot 4.6.2.

- All nine buildable definitions carry positive, independently editable duration metadata.
- Storage blueprint stays inactive until authorized and requirements are available; loss of power pauses its ten-second timer without losing progress.
- A conveyor blueprint is only endpoint geometry until its two-second build ends, when actual cargo and transport components are instantiated.
- Merger and splitter metadata remain distinct from machines; ammunition press waits for workers.
- The original manual-duration Storage path was explicitly verified unchanged.

**Next gate:** Introduce sandbox-only, opt-in Blueprint Planning controls using the existing construction-site and job abstractions. Begin with non-conveyor building placement, authorization and cancellation. Physical planned-belt topology is separately gated. Do not enable power/material/worker debug overrides in Main.

---

## 2026-11-08 — Legacy Construction Compatibility Complete (23/23)

**Godot 4.6.2 evidence:** Two new developer screenshots show `planned_conveyor_port_finder_test.tscn` passed **7/7** and `planned_storage_build_mode_test.tscn` passed **6/6** after universal-site integration.

- Finder still handles rotated unfinished Storage ports, range/direction filtering, fractional cursor placement and reserved/exhausted ports.
- Factory Testing Sandbox alone enables planned snapping; the Build Mode controller still reserves belts without precompletion cargo flow, receives cargo after activation without duplication, and leaves Main scene defaults unchanged.
- Together with Round 1 (Construction Site 4/4 and Planned Storage Conveyor 6/6), all **23/23 legacy compatibility checks passed** on the opt-in construction-site branch.

### Gate D1 — Per-Definition Construction Durations (staged for validation)

- `BuildingDefinition` now includes editable `construction_seconds` for universal jobs, with positive values assigned to all nine existing buildable resources. These are provisional balance values, not final pacing.
- Timings: straight belt 2s; merger/splitter 5s; Storage 10s; extractor 12s; turret 15s; smelter 16s; ammunition press 18s; large prototype 20s.
- New `ConstructionSite.setup_with_definition_job()` reads the resource duration and rejects zero/negative/nonfinite durations. Existing `setup()` and sandbox Storage's configurable duration are untouched.
- `res://tests/building_construction_duration_test.tscn` adds **12 focused F6 checks**, including resource data, planned inactivity, queued power requirements, pause/resume, live Storage completion, delayed conveyor activation, logistics blueprints and legacy behavior.
- **Not yet validated in Godot.** Do not enable this new path in `WorldInteraction` or Main until the developer confirms 12/12.
- Blueprint Planning Mode, materials, power network, drones and full main save/load remain later independent checkpoints.

---

## 2026-11-08 — Legacy Construction Compatibility Round 1 Passed (10/10)

**Godot 4.6.2 evidence:** The developer provided Output screenshots for the two original regression scenes after opt-in universal-site changes.

- `res://tests/construction_site_test.tscn`: **4/4 PASS**, confirming site footprint reservation, no premature Storage activation, completed Storage identity/rotation/inventory and real ports, and retirement of the placeholder.
- `res://tests/planned_storage_conveyor_test.tscn`: **6/6 PASS**, confirming rotated planned marker geometry, exclusive belt reservation, blocked cargo before completion, later physical connection, cargo conservation, and safe rejection of moved belts.
- **Total: 10/10 checks passed after universal site integration.** No live gameplay code was changed following these results.

**Round 2 remains pending:** `res://tests/planned_conveyor_port_finder_test.tscn` (**7 checks**) and `res://tests/planned_storage_build_mode_test.tscn` (**6 checks**). These must pass on the current branch before moving to universal construction in Build Mode.

---

## 2026-11-08 — Universal Construction Site Integration Validated (15/15)

**Godot evidence:** The developer supplied an Output panel screenshot for `res://tests/universal_construction_site_test.tscn` showing **PASS A–O** and `ALL 15 UNIVERSAL CONSTRUCTION SITE TESTS PASSED` in Godot 4.6.2.

- Optional `ConstructionSite.setup_with_job()` began as a blueprint with an occupied footprint and without an operational inventory.
- Planned Storage reserved a physical belt without connecting or consuming its cargo. Unpowered queued jobs made no progress; authorized work could pause/resume while retaining progress and cargo.
- Finishing the job activated one real Storage building and its reserved port; waiting Test Ore entered the completed inventory without duplication or loss.
- Conveyor blueprints exposed directional markers without cargo or transport components; completing the short job created an actual working conveyor.
- Multiport merger blueprints preserved input/output markers; cancelling planned, queued and paused work prevented live entity activation.
- The test validates **isolated opt-in sites**, not live WorldInteraction/Blueprint Mode or a physical power grid.

**Compatibility gate (still pending):** rerun the legacy `construction_site_test.tscn` (4 checks), `planned_storage_conveyor_test.tscn` (6), `planned_conveyor_port_finder_test.tscn` (7), and `planned_storage_build_mode_test.tscn` (6), in that order. No new gameplay code was committed in response to this test result.

---

## 2026-11-08 — Construction Job Validated; Universal Site Opt-In Staged

**Godot validation:** Developer screenshot confirms `res://tests/construction_job_test.tscn` passed **14/14** in Godot 4.6.2, covering planned authorization, queued blockers, power loss, worker gating, pause/resume, work multiplier, cancellation, and exactly-once completion.

### Gate C implementation (pending developer F6 validation)

- Added `ConstructionSite.setup_with_job()` as an opt-in path, keeping the original `setup()` + auto-starting `ConstructionLifecycle` unchanged.
- The new job-driven path reserves the world footprint and exposes only non-operational blueprint markers until authorized work finishes. It pauses and resumes progress according to the `ConstructionJob` supplied requirement flags, and cancellation queues the empty site for retirement.
- Planned geometry now copies all direct `ItemPortComponent` children, supporting multiport mergers and splitters; directional conveyor `InputEndpoint` and `OutputEndpoint` markers are also copied without instantiating a live conveyor cargo buffer or timer.
- `PlannedConveyorPortFinder` now checks `ConstructionSite.accepts_planned_connections()`, which preserves legacy Storage behavior while allowing future planned/queued job-site reservations.
- Successful job completion creates the actual building or conveyor once, retaining final world transform, existing runtime components, and strict physical port link validation for any reserved completed belts.
- New `res://tests/universal_construction_site_test.tscn` contains **15 focused assertions** for Storage, conveyor, merger, planned-port reservations, inactive cargo, queue/power pause, completion, conservation, and cancellation. **Not yet run in Godot.**
- No `WorldInteraction` or Main scene construction path was enabled. The job's power/material/worker inputs are test-provided availability values; no grid, drones, material delivery or standalone save system was introduced.

**Test order:** New universal site F6 scene, then legacy construction site and planned conveyor finder/Build Mode regression scenes. Manual end-to-end corner-to-Storage inventory accounting remains separate acceptance work.

---

## 2026-11-08 — Salvage Regression Accepted and Construction Job Gate B Staged

**Validated in Godot 4.6.2:** Player screenshot reports `ALL 12 WRECKAGE SELECTION AND CLEANUP TESTS PASSED` for `res://tests/wreckage_selection_cleanup_test.tscn`.

- Wreckage is selectable through its intended Layer-2 hitbox and reports content through the shared HUD.
- Empty wreckage cleanup preserves unrelated world objects. Stocked wreckage remains protected until its materials are recovered safely.
- Ten recovered resources remained conserved when the cache became clearable.
- This completes the focused corner cargo **8/8**, conveyor demolition **6/6**, and wreckage cleanup **12/12** regression sequence: **26/26 checks**, each run separately in local Godot.

**Next implementation checkpoint — isolated, not yet Godot validated:**

- New `scripts/components/construction_job.gd` wraps the existing `ConstructionLifecycle` and adds blueprint authorization, queueing, requirement blockers, pauses, resumes, cancellations, and one-time completion.
- New `res://tests/construction_job_test.tscn` contains **14 targeted assertions**, covering all job states, gate loss/recovery, work multiplier, idempotence, cancellation and an explicit instant prototype exception.
- No changes to existing live construction sites, WorldInteraction, conveyor logistics, demolition services, zombie gameplay or the save architecture. Power/material/worker flags are **read-only external availability snapshots supplied by future services**, not implemented networks or resource deliveries.
- **Pending:** Developer runs the 14-check F6 scene before any scene/world integration. A manual item-counted corner-to-completed-Storage receipt test also remains separate acceptance work.

---

## 2026-11-08 — Conveyor Demolition Safety Regression Accepted (6/6)

**Local Godot evidence:** Player-provided Output screenshot for `res://tests/conveyor_cargo_demolition_test.tscn` on Godot 4.6.2, showing `ALL 6 DEMOLITION SAFETY TESTS PASSED` and all original resources conserved.

- Empty belts allow guarded player demolition; occupied belts refuse it while retaining their cargo.
- Successfully unloaded belts become eligible again; invalid cargo configuration is rejected.
- Generic item types receive the same protection as ore.
- These scripted checks do not prove live click interaction with stocked world salvage; that separate test remains pending.
- No runtime gameplay code changed at this checkpoint.

**Next test gate:** `res://tests/wreckage_selection_cleanup_test.tscn` (12 expected assertions), before isolated universal construction job implementation.

---

## 2026-11-08 — Corner Cargo Regression Accepted (8/8)

**Local Godot 4.6.2 evidence:** Player-provided Output panel screenshot for `res://tests/conveyor_corner_cargo_test.tscn`, reporting `ALL 8 CORNER CARGO TESTS PASSED`.

- Real conveyor components retained cargo and travel progress through in-place right-turn conversion.
- Right-turn cargo delivery, occupied-output backpressure, post-blockage resumption and rotated left-turn transfer passed.
- Three distinct item types remained conserved within the scripted test; no reported errors.
- This suite does not replace a manual, item-counted end-to-end delivery into a completed Storage building.
- No gameplay/runtime code changes were made for this checkpoint.

**Next test gate:** `res://tests/conveyor_cargo_demolition_test.tscn` (six guarded-demolition checks), then `res://tests/wreckage_selection_cleanup_test.tscn` (12 salvage/selection checks) before isolated universal construction job implementation.

---

## 2026-11-08 — Manual Opposite-Direction Corner and Buffered Ammunition

**Evidence:** Player screenshot and explicit confirmation that the opposite 90-degree conveyor layout works in the Godot 4.6.2 Factory Testing Sandbox.

- The completed Storage and neighboring belts remain visually aligned with arrows following the turns.
- The selected conveyor's Production Debug HUD shows `Input: Previous conveyor`, `Output: Building port`, and `Cargo: Prototype Rounds x1`. This confirms it has received a buffered ammunition item and remains physically linked to a building port.
- This image does not yet prove the item emptied into Storage or establish end-to-end inventory conservation; those remain a focused follow-up.
- Both manual right-turn and opposite-turn physical connection checks are accepted. The known automated bidirectional Storage regression remains **8/8 PASS**.
- No gameplay code modified. Before universal construction rollout, finish corner cargo/conservation and demolition/salvage safety regressions.

**Next local regression:** `res://tests/conveyor_corner_cargo_test.tscn` (8 scripted assertions), followed by cargo demolition and salvage safety scenes.

---

## 2026-11-08 — Manual Outgoing Conveyor Right-Turn Preservation

**Evidence:** Player screenshot from the Godot 4.6.2 Factory Testing Sandbox after Storage completion.

- The Storage construction placeholder is replaced by the real building, with a visibly continuous outgoing conveyor route that turns 90 degrees.
- The selected conveyor directly next to the completed Storage shows `Input: Building port` and `Output: Next conveyor` in Production Debug, confirming its existing building connection and first downstream physical link survived construction.
- The selected belt reports HP 50/50 and empty cargo; this screenshot is not proof that cargo has traversed the corner or that every downstream link is connected.
- No gameplay source changes were necessary. The reverse/left-turn, corner transport, and player demolition/salvage checks remain open.

**Next gate:** Build the opposite-direction turn from a new Storage output route and verify the same two HUD fields after completion, then continue cargo conservation and destruction testing.

---

## 2026-11-08 — Manual Planned Storage Input/Output Acceptance

**Evidence:** Three player-provided Factory Testing Sandbox screenshots from Godot 4.6.2.

- At 6% construction, Storage remains a translucent reserved footprint with conveyor segments placed at both planned ends and their yellow direction arrows visually aligned.
- After Storage completed, the output-side conveyor Production Debug HUD displayed `Input: Building port` and `Output: Disconnected`, confirming its input is physically linked to Storage output.
- The input-side conveyor Production Debug HUD displayed `Input: Disconnected` and `Output: Building port`, confirming its output is physically linked to Storage input.
- Combined with the preceding automated bidirectional regression **8/8**, this accepts visible planned-port bidirectional reservation and postconstruction physical connection.
- These screenshots do **not** establish a new manual ore/ammunition transport-conservation result. Left/right corner paths, cargo, demolition and salvage interactions remain to validate before universal construction rollout.
- The Factory Testing Sandbox and Main gameplay scripts remain unchanged.

**Next gate:** Manual left/right corner paths near the completed Storage, then focused existing Godot corner regression scenes.

---

## 2026-11-08 — Bidirectional Planned Storage Conveyor Regression Accepted

**Local test:** `res://tests/planned_storage_bidirectional_conveyor_test.tscn`  
**Outcome:** **8/8 PASS** in Godot 4.6.2, confirmed by player-provided Output panel screenshot.

- Rotated unfinished Storage exposes planned input/output markers without active ports or inventories.
- Independent planned input and output conveyor reservations remain exclusive and inactive until Storage construction completes.
- Completion establishes reciprocal physical port connections; subsequent inbound delivery and outbound loading conserve all three seeded item units.
- Unrouted cargo remains buffered and protected from player demolition; detaching the outbound port preserves the remaining input link and cargo.
- These are scripted, code-driven test assertions; the actual in-game cursor snapping, 90-degree turns, and demolition interactions around unfinished Storage still require manual F6 acceptance.
- A separate design proposal for universal construction jobs, blueprint planning and connected power infrastructure is in `docs/CONSTRUCTION_AND_POWER_ARCHITECTURE.md`.
- No gameplay runtime implementation changed during this regression acceptance; main game remains unaffected.

**Next gate:** Manual input/output hard-snap and corner checks in the zombie-free Factory Testing Sandbox, followed by broader logistics and salvage regressions before universal construction implementation.

---


## 2026-11-08 — Next-Phase Design Checkpoint and Handoff

**Status:** Design documentation only. No new runtime gameplay implementation in this checkpoint.

### Accepted construction progress

- Timed Storage, unfinished footprint collisions, port activation, physical cargo delivery, and inventory conservation passed dedicated Godot regressions and manual sandbox testing in prior checkpoints.
- Planned Storage conveyor discovery **7/7** and sandbox Build Mode integration **6/6** passed in Godot 4.6.2. User confirmed the conveyor placement ghost now hard-snaps to unfinished Storage.
- Reserved conveyors activate their physical building connection when construction completes. Both planned input/output, corners, demolition, and full conveyor regression acceptance remain follow-up work, rather than assumed complete.
- Factory Testing Sandbox retains the green zombie disabled for uninterrupted construction checks; Main gameplay behavior remains a separate baseline.

### New design decisions

- All placed structures, **including every conveyor segment**, should eventually be time-built, with lightweight belts significantly faster than machines or defensive works. Current live implementation remains staged and not universal.
- Add **Blueprint Planning Mode** so players can preplan layouts and port alignments, then authorize construction separately. Holograms reserve plans but cannot operate or claim territory.
- Introduce a Main Hub with initial emergency power, Power Stations to generate electricity, and linked Power Poles/Relays to extend electrical and construction coverage.
- Power, defended territory, and drone-service reach are different concepts. A powered location is not automatically safe.
- Plan three upgrade tiers of poles with increasing coverage and **different drone charging rates** (slow, medium, fast); final numerical balance and power constraints require later design.
- The player-operated AI drone can eventually scout beyond grid support using limited battery and return for recharging; later worker drones from the hub construct authorized structures with speed/capacity research upgrades.
- Keep shared industrial materials as real physical logistics competing between ammunition, expansion construction, and eventually research.
- Preserve one zombie-planet playable demo as the near-term objective. Planetary conquest and multiple hostile factions are long-term campaign/replayability goals, not a roguelike reset mechanic.

### Next engineering sequence

1. Close remaining construction/conveyor regression cases (both planned ports, turns, selection, removal and resource conservation).
2. Review current scripts/scenes and design universal blueprint/construction jobs together with power-coverage rules.
3. Implement small opt-in checkpoints for universal construction, preplanning, grid coverage, and later drones/material costs, with local Godot validation between milestones.
4. Continue using GitHub `main` as the reviewed checkpoint branch and avoid independent save/load architecture.

---

This document tracks meaningful development milestones, design decisions, technical changes, testing, troubleshooting, and showcase-ready progress.

The development log intentionally summarizes completed milestones rather than recording every individual edit.

---

## 2026-11-07 — Planned Conveyor Hard-Snap Follow-up

- Player confirmed construction-site reservations connect automatically at 100%, but the yellow conveyor ghost does not hard-snap to the unfinished Storage site.
- Reviewed the live `WorldInteraction` preview and identified that `PlannedConveyorPortFinder` was called with a grid-rounded cursor world position. Storage port geometry may be fractional, which can push the rounded search position outside the strict snap radius.
- Updated planned-port preview discovery to receive the original `hit_position` from the ground raycast; the finder retains its direction and radius checks and the actual snap transform is unchanged.
- Extended the planned finder regression to seven checks, including a fractional raw cursor hit near a planned port.
- **Automated validation passed:** updated finder **7/7** and WorldInteraction test **6/6** in Godot 4.6.2 (player-confirmed screenshots, 2026-11-07). **Manual F6 yellow-ghost hard-snap verification passed** (player confirmed snapping works, 2026-11-07). Input/output variants and full conveyor regressions remain follow-up acceptance checks.

---


## 2026-11-07 — Planned Conveyor Ghost Snap Follow-up

- Manual sandbox testing confirmed the conveyor can reserve a planned connection and connect at construction completion, but the preview ghost did not snap when positioned over the blueprint.
- Root cause investigated: finder compared mouse-to-belt-origin only, even though players aim at the planned Storage port itself. Updated finder to accept proximity to **either** planned port or intended belt origin, preserving the strict heading/radius checks.
- Added a specific port-cursor scenario to `tests/planned_conveyor_port_finder_test.tscn`, now six checks.
- **Pending local F6 validation:** planned-port finder and sandbox Build Mode integration regression, followed by in-game ghost snapping, adjacent-lane, and rotation checks.

---


## 2026-11-07 — Sandbox Planned Conveyor Build Mode Integration

- Confirmed **5/5** `PlannedConveyorPortFinder` discovery checks passed in Godot 4.6.2.
- Added `WorldInteraction.enable_planned_storage_conveyor_snap` (default **false**), a separate planned Storage preview target and safe collision handling for the intended reserved-footprint body.
- Implemented opt-in straight-belt placement that reserves the aligned construction-site port. It does not form an operational connection until the real Storage becomes available.
- Enabled the feature only in `factory_testing_sandbox.tscn`; `main.tscn` remains unchanged.
- Added `tests/planned_storage_build_mode_test.tscn` with six isolated world-integration checks. **Local Godot verification passed: 6/6 checks** (2026-11-07); manual player placement and corner/selection regressions follow.
- No changes made to the existing conveyor transport algorithms, zombie combat, or main game save architecture.

---


## 2026-11-07 — Planned Conveyor Preview Discovery

- Six planned-reservation regression checks passed in local Godot 4.6.2, including cargo conservation, deferred port connection, and rejection of a moved belt.
- Added `PlannedConveyorPortFinder`, a preview-only candidate finder that applies search radius, player-selected conveyor heading, reserved-port restrictions, and construction-state validation.
- Added `tests/planned_conveyor_port_finder_test.tscn` with five focused discovery checks. **Pending local Godot verification.**
- Existing `WorldInteraction` placement remains unchanged. The next stage will integrate preview and click routing after the finder test passes.

---


## 2026-11-07 — Planned Port Reservation Foundation

- Added marker-only planned Storage port geometry, matching completed building port transforms while keeping unfinished sites free of operational `ItemPortComponent` instances or inventories.
- Added optional `ConstructionSite.reserve_conveyor()` plus `get_planned_belt_transform()`; reservations do not move or transfer cargo. Upon completion, each reserved belt is connected only if the existing strict `ConveyorSegment.try_connect_building_port()` validation still passes.
- Added six focused checks in `res://tests/planned_storage_conveyor_test.tscn` for early isolation, one-item holding, delayed connection, conserved delivery, and moved-belt refusal.
- **Local Godot verification: 6/6 planned-reservation tests passed on 2026-11-07.** Player-facing Build Mode snapping around blueprints is deferred pending the next isolated discovery regression; existing production, hotbar, combat, and Main scene scripts are unchanged.

---


## 2026-11-07 — Timed Storage Physical Belt Delivery Regression

- User confirmed all **4/4 construction footprint and port** checks passed in Godot 4.6.2.
- Reviewed existing `ConveyorBuildingSnap`, `ConveyorTransportTimer`, `ConveyorTransportComponent`, and `ItemPortComponent`; retained the existing physical movement mechanisms.
- Added `tests/timed_storage_conveyor_delivery_test.tscn`: completed Storage accepts an aligned conveyor input, transports one Test Ore into Storage, preserves total source/belt/destination inventory, and cleans up connections on disconnect.
- Live gameplay logic remains unchanged. **All 6/6 checks passed locally in Godot 4.6.2 on 2026-11-07**, including physical connection, item delivery, conservation and disconnection. **F6 factory sandbox acceptance:** screenshot shows completed Storage with 11 Prototype Rounds / 200 capacity and 100/100 HP beside the connected ammunition conveyor network. The full live connection-and-delivery loop is accepted; automatic connection reservation during construction remains separate.

---


## 2026-11-07 — Construction Footprint and Port Readiness

- Accepted testing sandbox: 3/3 Godot checks and player confirmation of a nonattacking zombie in F6 sandbox play.
- Reviewed `ConstructionSite`, `ItemPortComponent`, and the existing 3D placement blocker mask.
- Added `tests/construction_footprint_ports_test.tscn` to verify the unfinished site's physical overlap, absence of inventory/ports during construction, and real Storage inventory/ports on completion.
- No game-system modifications: this test establishes the prerequisite for safe delayed conveyor connection. The next checkpoint will validate connecting physical belts and moving actual items.
- **Validation pending:** Four new Godot checks, then subsequent logistics tests.

---


## 2026-11-07 — Safe Factory Testing Sandbox

- Added `scenes/core/factory_testing_sandbox.tscn` for interruption-free factory testing. The green moving zombie remains visible but its processing is disabled, so it does not walk or melee attack in this scene.
- Enabled timed Test Storage construction in the sandbox. Normal `scenes/core/main.tscn` is unchanged and retains active zombie behavior and its existing construction settings.
- Added `tests/factory_testing_sandbox_test.tscn` with three tests checking disabled sandbox zombie, normal Main behavior, and retained build HUD/catalog. **3/3 passed** locally in Godot 4.6.2 (2026-11-07). Player additionally confirmed the sandbox runs as intended with the green zombie inactive.
- Run the sandbox scene directly with **F6**; run the normal Main scene using **F5**. Since this is a separate scene copy, synchronize it if Main receives future gameplay or scene changes.

---


### Timed Storage Controller Integration — Local Validation (2026-11-06)

- Godot confirmed **4/4** world-controller integration checks passed (default instant placement, nonoperational site, activation at 100%, invalid-definition rejection).
- Next validation is a controlled F5 session with `WorldInteraction.enable_timed_storage_construction` enabled temporarily in the Main scene Inspector. Keep the default false until regular placement and downstream conveyor cases are regression-tested.
- Only standalone Test Storage placement is supported; snapped-to-belt Storage still takes the original immediate-connection route.
- Manual F5 evidence (2026-11-06): blue construction site shown at 47%, then completed Storage building with IN/OUT port markers. Timed standalone build activation accepted visually; automated checks 14/14 passed across three scenes. Actual port cargo transfer after construction and site/conveyor collision compatibility remain future checks.


## 2026-11-06 — Construction Site and World Integration Follow-up

- Local Godot **4/4 ConstructionSite** checks passed, confirming footprint, pending state, delayed real Storage, preserved transform and ports.
- Added opt-in `WorldInteraction.enable_timed_storage_construction` (default false) and `storage_construction_seconds` to stage the first standalone Storage construction in the live controller. Existing Main and conveyor snap placement remain unchanged by default.
- Added `tests/timed_storage_placement_test.tscn` for world-controller integration checks; these have **not** been run locally yet.
- Next: pass the test, validate automatic placement and safe activation, then enable timed construction in F5.

---


## 2026-11-06 — Zombie-Planet Demo Focus and Construction Lifecycle Foundation

- Confirmed the immediate vertical slice: one zombie world with persistent factory growth, ammunition-fed defenses, and turret/wall-led territorial expansion. Planet-hopping and alternate enemy factions remain long-term campaign goals.
- Added `scripts/components/construction_lifecycle.gd`: isolated planned/constructing/complete state transitions, required duration, progress, remaining work, optional worker multiplier, and one-time completion signal.
- Added `tests/construction_lifecycle_test.gd` and `tests/construction_lifecycle_test.tscn` covering six construction-state and timing regression groups.
- The lifecycle model passed **all 6/6** local Godot regression checks (user-confirmed screenshot).
- Added `ConstructionSite` prototype and `tests/construction_site_test.tscn` to demonstrate a timed, reserved Storage footprint and delayed creation of an operational Storage building. This is isolated test-only integration pending Godot verification; main Build Mode is unchanged.
- The model is intentionally **not yet wired into live placement**: current buildings remain instantly constructed until isolated tests pass and gameplay-system shutdown/activation rules are implemented and validated.
- No main-scene, conveyor, hotbar, production, combat, or salvage behavior was changed. The construction test requires execution in Godot 4.6.2.

---


## 2026-11-05 — Phase 1G6: Building Catalog Expansion, Checkpoint 1

- Reviewed existing `BuildingDefinition.category` values, hotbar stable-ID assignment model, and implemented 1×1 Splitter/Merger routing components.
- Organized each Building Catalog slot dropdown by existing unlocked building categories, with nonselectable category separators. Empty option, assignment metadata, swapping, and Restore Defaults retain their original behavior.
- Added `res://tests/build_catalog_category_test.tscn` to validate grouping, selecting a grouped building, hotbar redraw, and restoring defaults.
- This is a **catalog presentation improvement only**. No new manufacturing recipes, logistics functionality, save files, or progression systems are introduced.
- **Validation complete (2026-11-06):** Godot 4.6.2 category regression passed all **3/3** checks. Player confirmed that the in-game M menu works and dropdown entries are grouped by building category. Checkpoint 1 accepted.

---


## 2026-11-04 — Phase 1G5: Visual Hotbar UI, Checkpoint 1

### Architecture
- Reused the existing nine-slot `BuildHotbarConfiguration` stable-ID model, WorldInteraction shortcut routing, and Building Catalog.
- Added `scripts/ui/build_hotbar_visual.gd` as a presentation-only view attached to `VisualHotbar` in the existing `build_hud.tscn`.
- Moved the visible build shortcuts into nine bottom-centered horizontal tiles. The previous text slot labels remain hidden but continue to update for existing regression compatibility.
- Each tile includes shortcut number, generated placeholder graphic, compact name, selection border, and tooltip.
- Icon textures are cached by building ID. Catalog swaps, empty assignments, locked buildings, selection changes, and Restore Defaults redraw the view via existing HUD synchronization.
- Build Mode visibility follows the original BuildPanel. No changes to placement, conveyors, combat, or save/load architecture.

### Testing
- New runnable scene: `res://tests/build_hotbar_visual_test.tscn` (six regression groups).
- Re-run `res://tests/build_hotbar_keyboard_integration_test.tscn` and `res://tests/build_hotbar_configuration_test.tscn` to check existing behavior.
- Manual checklist: enter Build Mode, inspect all nine icons, press 1–9, open M catalog and swap a selection, clear a slot, restore defaults, exit Build Mode, verify placement and conveyor corner behavior.
- **Verification status:** Code committed to GitHub. Godot runtime/regression tests await execution on the local Godot 4.6.2 installation.


### Manual Validation and Layout Follow-up (2026-11-05)
- Godot 4.6.2 visual hotbar regression: all six checks passed on the local machine.
- In-game screenshot confirmed the nine centered tiles, selected highlight, and customized assignment order.
- Manual conveyor/corner placement confirmed working by the player.
- Corrected BuildPanel's anchor preset to bottom-left (with explicit horizontal anchors) to address controls clipping at the left edge.
- **Pending:** verify left-side control panel positioning after pulling this final layout correction. No gameplay systems or save/load behavior changed.

### Deferred
- Production artwork and locked-tile research presentation.
- Per-saved-game assignments, which must be integrated with the main save/load design.

---


## 2026-10-11 — Project Foundation

### Engine and Project

Created the Industrial Warfare project with:

- Godot Engine 4.6.2 Stable Official
- Forward+ renderer
- Windows desktop as the initial platform
- Single-player as the initial development target

Project path:

```text
E:\GameDev\industrial-warfare
```

### Initial Structure

Created the initial project organization:

```text
assets/
data/
docs/
docs/screenshots/
scenes/
scripts/
tests/
```

Created the core documentation files:

- `DEVLOG.md`
- `ROADMAP.md`
- `GAME_DESIGN.md`
- `ARCHITECTURE.md`
- `TROUBLESHOOTING.md`
- `FUTURE_FEATURES.md`

### Source Control

Initialized Git using the `main` branch.

Created the public GitHub repository:

```text
ChrisGiggleman/industrial-warfare
```

Connected the local repository to `origin` and pushed the project to GitHub.

### Godot Configuration

Configured:

- 1920 × 1080 base resolution
- `canvas_items` stretch mode
- `keep` stretch aspect
- resizable window
- initial Input Map actions

Initial input actions included camera movement, interaction, mouse actions, and zoom.

### Main Scene Foundation

Created:

```text
res://scenes/core/main.tscn
```

Initial world setup included:

- ground
- DirectionalLight3D
- WorldEnvironment
- Camera3D
- ReferenceCube

### Troubleshooting

Resolved an early PowerShell relative-path mistake while creating documentation files.

### Visual Milestone

The project opened successfully in Godot and entered source control with a clean baseline.

### Status

**Project Foundation: Complete**

---

## 2026-10-12 — Chat 02: Camera & Player Interaction Foundation

### Camera

Created a `CameraRig` architecture and added:

- WASD camera movement
- mouse-wheel zoom
- movement/zoom tuning
- frame-rate independent motion

### Mouse and World Interaction

Created:

```text
res://scripts/world_interaction.gd
```

Added mouse-to-world raycasting and separated player interaction from the camera controller.

### Selectable Objects

Created a reusable selection system using the `selectable` group.

Implemented:

- collider-to-logical-object parent traversal
- persistent selection state
- gold material highlight
- deselection on ground/empty-space clicks

Selection presentation was moved into:

```text
res://scripts/selectable_object.gd
```

### Physics Layer Conventions

Established:

- Layer 1 — Ground / placement surfaces
- Layer 2 — Selectable-object collision
- Layer 3 — Placement blockers

This allows ground placement raycasts and occupancy checks to remain independent.

### Build Mode

Added Build Mode with `B`.

Implemented:

- 1-meter grid snapping
- placement validity checking
- green/red placement feedback
- LMB placement
- RMB cancellation/exit

### Runtime Building Placement

Created prototype building scenes:

- `test_building.tscn`
- `test_building_large.tscn`

Added runtime instantiation and placement blocking.

### Placement Ghost

Replaced the temporary flat marker with a full translucent building ghost.

The ghost:

- follows snapped placement
- uses the actual building footprint
- turns green/red based on validity
- is safely removed when Build Mode ends

### Rotation

Added `R` rotation in 90-degree increments.

Placement validity uses the actual rotated collision shape, allowing rectangular footprints to validate correctly.

### Multiple Building Types

Added prototype building selection:

- `1` — small test building
- `2` — large test building

Switching buildings recreates the ghost and preserves footprint-aware validation.

### Build HUD

Created a temporary Build HUD showing:

- current build mode
- building slots
- selected building
- control hints

### Demolition Tool

Moved demolition into Build Mode.

Implemented:

- `Delete` tool toggle
- red demolition HUD state
- red demolition-hover targeting
- LMB demolition
- `player_built` protection rules
- safe return to placement mode

`ReferenceCube` remains selectable but cannot be demolished.

### Refactor and Regression Test

Cleaned the interaction code by:

- removing obsolete HoverMarker logic
- using named constants for masks/rotation/ghost alpha
- improving method names
- improving demolition cleanup
- organizing scripts with section headers

Regression-tested:

- camera movement
- zoom
- selection/deselection
- Build Mode
- building switching
- grid snapping
- placement ghost
- valid/invalid coloring
- collision blocking
- rotation
- rotated footprints
- placement
- demolition
- protected objects

No gameplay regressions were found.

### Status

**Chat 02 — Camera & Player Interaction Foundation: Complete**

---

## 2026-10-14 — Chat 03: Factory Building & Production Foundation

Chat 03 moved Industrial Warfare from a construction prototype into the first reusable factory-production architecture.

### Data-Driven Building Definitions

Created:

```text
res://scripts/data/building_definition.gd
```

`BuildingDefinition` currently stores:

- building ID
- display name
- description
- category
- building scene

Created:

- `res://data/buildings/test_building.tres`
- `res://data/buildings/test_building_large.tres`

The `.tres` file now describes what a building is, while the `.tscn` file describes how it physically exists.

### Build-System Refactor

Refactored `WorldInteraction` from a direct `Array[PackedScene]` to:

```gdscript
Array[BuildingDefinition]
```

The selected definition now supplies the scene used for:

- placement preview
- placement validation
- runtime construction

Removed the legacy `buildable_scenes` collection after regression testing.

### Building Runtime Component

Created:

```text
res://scripts/components/building_runtime.gd
```

Placed buildings receive the `BuildingDefinition` that created them.

Current flow:

```text
BuildingDefinition
        ↓
building_scene
        ↓
placed building
        ↓
BuildingRuntime.initialize(definition)
```

This gives each placed building access to its own data identity without hard-coding building-specific behavior into `WorldInteraction`.

### Item Definition

Created:

```text
res://scripts/data/item_definition.gd
```

Created the first item asset:

```text
res://data/items/test_ore.tres
```

`Test Ore` is the prototype raw material used to validate inventory and production behavior.

### Item Amount

Created:

```text
res://scripts/data/item_amount.gd
```

`ItemAmount` represents an `ItemDefinition` plus an integer amount.

This is used by recipe input/output arrays.

### Inventory Component

Created:

```text
res://scripts/components/inventory_component.gd
```

Current inventory operations:

- add item
- remove item
- get quantity
- check quantity

Verified with temporary runtime tests:

```text
Inventory added - Test Ore: 5
Has 5 Test Ore: true
Removed 2 Test Ore: true
Inventory remaining - Test Ore: 3
```

Temporary test code was removed after verification.

Multiple placed buildings were confirmed to maintain independent inventory instances.

### Production Recipe Data

Created:

```text
res://scripts/data/production_recipe.gd
```

Created:

```text
res://data/recipes/prototype_extraction.tres
```

Prototype recipe:

```text
Prototype Extraction
Production Time: 2 seconds
Inputs: none
Outputs: 1 Test Ore
```

The recipe format supports input arrays for future processing recipes, but input consumption is not implemented yet.

### Producer Component

Created:

```text
res://scripts/components/producer_component.gd
```

Added `ProducerComponent` only to the small `TestBuilding`.

The large prototype intentionally remains a non-producer for comparison.

Production flow:

```text
ProducerComponent
        ↓
Prototype Extraction
        ↓
wait 2 seconds
        ↓
1 Test Ore
        ↓
InventoryComponent
```

Verified autonomous production and independent inventory counts across multiple placed producers.

### Placement Ghost Gameplay Safety

Because placement ghosts instantiate the same building scene as real buildings, producer components would otherwise exist inside the preview.

The ghost root now uses disabled process mode so gameplay scripts do not run on temporary placement previews.

Verified that placement ghosts do not produce resources.

### Production Debug HUD

Created:

```text
res://scenes/ui/production_debug_hud.tscn
res://scripts/production_debug_hud.gd
```

The temporary debug HUD displays live selected-building information.

Producer example:

```text
PRODUCTION DEBUG

Building: Test Building
Recipe: Prototype Extraction
Stored Test Ore: 7
```

Non-producer example:

```text
Building: Test Building Large
Recipe: None
```

Non-building selection:

```text
Selected object has no building data.
```

No selection:

```text
No building selected.
```

The stored resource count updates live while production continues.

Temporary production console spam was removed after the HUD became the primary production-debug view.

### Troubleshooting and Lessons

Notable issues encountered:

- a `Resource` script was accidentally attached to `Main` Node3D
- GDScript indentation errors occurred while inserting nested test blocks
- the fixes reinforced the distinction between data resources, node scripts, and indentation-based GDScript structure

See `TROUBLESHOOTING.md` for reusable fixes.

### Regression Coverage

Throughout Chat 03, changes were regression-tested against the established interaction foundation.

Verified systems include:

- camera movement
- camera zoom
- normal selection
- selection clearing
- Build Mode
- building switching
- grid snapping
- placement ghost
- valid/invalid placement
- rotation
- rotated footprints
- runtime placement
- Demolition Tool
- protected non-player-built objects
- data-driven building selection
- BuildingRuntime initialization
- independent building inventories
- autonomous production
- non-producing control building
- placement-ghost production safety
- Production Debug HUD selection states

No persistent gameplay regressions remained at the end of the milestone.

### Architecture Milestone

The first factory gameplay foundation is now:

```text
BuildingDefinition
        ↓
Building Scene
        ↓
BuildingRuntime
        │
        ├── InventoryComponent
        └── ProducerComponent
                ↓
        ProductionRecipe
                ↓
            ItemAmount
                ↓
          ItemDefinition
```

### Current Limitations

Intentionally deferred:

- world resource nodes
- recipe input consumption
- storage capacity
- conveyors/logistics
- power networks
- build costs
- research/unlocks
- machine upgrades
- save/load
- polished factory UI

### Status

**Chat 03 — Factory Building & Production Foundation: Complete**

The project now has its first autonomous, data-driven production building.

---

## 2026-10-18 — Chat 04: Resource Nodes & Extraction Foundation

Chat 04 replaced the small building's temporary free-output recipe with real, location-dependent resource extraction. Earlier Chat 03 producer tests remain recorded above as history; the current Test Extractor uses an `ExtractorComponent`, not the original autonomous extraction recipe.

### Resource-Node Data and World Scene

Created:

- `res://scripts/data/resource_node_definition.gd` — `ResourceNodeDefinition` data schema.
- `res://data/resource_nodes/test_ore_deposit.tres` — Test Ore Deposit definition, linked to `Test Ore`.
- `res://scripts/components/resource_node_runtime.gd` — `ResourceNodeRuntime` instance state and extraction API.
- `res://scenes/resource_nodes/TestOreDeposit.tscn` — selectable test deposit with mesh, collision, and runtime component.

Definitions contain an ID, display name, description, `ItemDefinition`, `infinite_resource` flag, and `starting_amount`. Runtime nodes track `remaining_amount` and provide `extract(amount) -> int` so callers receive only the quantity actually available.

Tested **infinite deposits** (no depletion) and **finite deposits** (supply decreases and production stops at zero). The prototype Test Ore Deposit is configured for infinite supply by default; the starting amount is retained for finite-mode testing.

### Extractor Component and Inventory

Created `res://scripts/components/extractor_component.gd`.

The small test building now has:

- `BuildingRuntime` and its own `InventoryComponent`.
- `ExtractorComponent` with configurable extraction amount and interval (prototype defaults: 1 unit / 1 second).
- `ExtractionArea` (`Area3D`) using a 2.5-unit-radius detection shape and Layer 2 collision mask.

The component identifies nearby deposits through their `ResourceNodeRuntime`, requests resources from `extract()`, and adds the returned amount to the building's inventory. Without an in-range deposit, the extractor does not produce resources. Different placed extractors continue to hold independent inventories.

### Extractor-Specific Placement Rule

Updated `res://scripts/world_interaction.gd` so physical occupancy and resource access are separate checks:

- Physical building collision shapes are tested against placement blockers (Layer 3).
- A placement ghost with `ExtractorComponent` additionally queries its extraction shape against resource-node colliders (Layer 2).
- Extractor placement is red/invalid without a reachable resource deposit and green/valid when one is in range.
- Buildings without `ExtractorComponent`, including Test Building Large, remain placeable without ore.

The placement ghost still has gameplay processing disabled so previews do not run extraction.

### Debug HUD and Selection

Extended `res://scripts/production_debug_hud.gd`:

- Selected deposits show resource name and infinite supply or finite remaining/starting supply.
- Selected extractors show building name, extractor type, status, resource name, and live inventory quantity.
- Status differentiates **No Resource In Range**, **Extracting**, and **Resource Depleted** where applicable.
- Existing non-extractor building and empty-selection behavior remains available.

The resource deposit retains normal selectable-object highlighting.

### Prototype Naming and Asset Cleanup

Renamed the small prototype into a named extractor:

- `scenes/buildings/test_building.tscn` → `scenes/buildings/test_extractor.tscn`
- `data/buildings/test_building.tres` → `data/buildings/test_extractor.tres`
- Scene root `TestBuilding` → `TestExtractor`
- Building ID `test_extractor`, display name **Test Extractor**, category **Extraction**

Removed the obsolete `res://data/recipes/prototype_extraction.tres` asset after reference checks and a successful gameplay test. Kept the reusable `ProducerComponent`, `ProductionRecipe`, and `ItemAmount` framework for future manufacturing machines.

### Troubleshooting and Fixes

- **Unexpectedly large no-build area:** The placement ghost originally treated the extractor's spherical `ExtractionArea` collision as a physical building footprint. Changed footprint tracking to include only `CollisionShape3D` nodes belonging directly to `PhysicsBody3D`; detection-area shapes are not placement blockers.
- **Missing placement validator during editing:** Restored `_is_placement_clear()` after an intermediate script edit removed it.
- **GDScript indentation errors:** Corrected mixed/incorrect indentation around the extractor rule and ghost-color branches; retained tabs throughout the script.

Detailed fixes belong in `TROUBLESHOOTING.md`.

### Final Regression Test — Passed

Verified together:

- WASD panning and mouse-wheel zoom.
- Normal selection, highlight, and HUD updates.
- Build Mode, building-slot switching, rotation, valid/invalid ghost feedback, and placement.
- Extractor blocked away from ore and placeable near a deposit.
- Extraction transfers real resources to the placed extractor inventory.
- Infinite supply information and finite-depletion behavior.
- Large Test Building remains usable without nearby deposits.
- Demolition and protection of non-player-built objects.
- No new Godot debugger errors in the final gameplay check.

### Milestone Status

**Chat 04 — Resource Nodes & Extraction Foundation: Complete.**

Next planned work: basic inventory storage and simple item transfer/logistics, followed by recipe inputs, further factory systems, and the first zombie/defense prototype.

---

## 2026-10-20 — Chat 05: Storage & Basic Factory Logistics

**Milestone status: Complete.** Gameplay implementation and final manual regression tests passed in Godot 4.6.2 Stable.

### Inventory Capacity & Safe Item Accounting

- Extended `InventoryComponent` with a shared item-count `max_capacity` (0 = unlimited), `get_total_amount()`, `get_available_space()`, and `is_full()`.
- `add_item(item, amount) -> int` accepts only the quantity that fits and returns the actual amount stored.
- Made `ExtractorComponent` check free inventory capacity *before* extracting from finite deposits; full inventories no longer consume ore.
- Implemented `InventoryComponent.transfer_to(destination, item, amount) -> int` with source availability checks, destination capacity limits, partial transfers, self-transfer rejection, and rejected-item restoration.

### Dedicated Storage Building

- Added `scenes/buildings/test_storage.tscn` and `data/buildings/test_storage.tres`.
- Reused `BuildingRuntime`, `InventoryComponent`, selectable-object highlighting, placement collision, rotation, and demolition.
- The storage prototype has a rectangular 1.0 × 1.0 × 2.8 mesh/collision footprint and default capacity **200**.
- Added `logistics_storage` to the actual storage building root; retained `selectable` and `player_built`.
- Registered storage in `WorldInteraction.buildable_definitions`; key **3** selects storage, alongside key **1** Test Extractor and key **2** Large Building.
- Updated the Build HUD to show and highlight all three options.

### Automatic Logistics

- Added `scripts/components/logistics_transfer_component.gd` to Test Extractor as a sibling of its inventory/extractor components.
- Configured `transfer_item` (Test Ore), `transfer_amount = 5` per cycle, `transfer_interval = 1.0` second, and `transfer_range = 5.0` world units.
- The component selects the nearest eligible `logistics_storage` group member by **building-origin distance**, ignoring full destinations, missing inventories, queued-for-deletion nodes, and disabled placement ghosts.
- Nearby inventories receive up to the configured amount each cycle using `transfer_to()`; actual throughput depends on ore availability.
- Status tracking reports `Initializing`, `Transferring`, `Waiting for Resources`, or `No Eligible Storage`, with last attempt and last successful transfer quantities. `No Eligible Storage` currently covers both out-of-range and full storage.

### Production Debug HUD

- Added storage totals, capacity used, and an `INVENTORY CONTENTS` listing by `ItemDefinition`.
- Added extractor inventory capacity/full status and a `LOGISTICS STATUS` section with configured maximum transfer rate, latest attempt amount, and last successful amount.
- Preserved resource-node remaining/starting amounts and existing selection behavior.
- The `Status: Extracting` line currently indicates a valid ore source, not necessarily active mining when inventory is full; this wording is a future refinement.

### Tests and Observed Results

- An isolated Godot inventory test passed partial transfer, full destination, empty source, and invalid/self/zero-quantity transfer cases.
- Gameplay checks passed extraction, proximity-limited storage discovery, timed transfers, HUD updates, blocked transfers at storage capacity, extractor accumulation when storage is full, and existing placement/rotation/selection/demolition behavior.
- **Final finite-resource conservation test:** starting deposit **500**, remaining deposit **250**, extractor inventory **50/50**, storage inventory **200/200**. Total: **250 + 50 + 200 = 500**.
- The committed `data/resource_nodes/test_ore_deposit.tres` is currently set to a **finite 500-unit** test deposit; this is a testing configuration, not a finalized economy choice.
- Storage capacity was restored to **200** after short capacity-limit tests.

### Scope and Follow-Ups

This is a proximity-based, direct inventory transfer prototype—not a visible conveyor network. Conveyor belts, routing/ports, multi-machine flow, power, production input consumption, and refined logistics statuses remain future work.

The tested source/scenes were committed and pushed to `main` before this documentation update.

---

## 2026-10-20–21 — Chat 06: Production Inputs & First Manufacturing Chain

**Milestone status: Complete.** First automated ore-to-ingot manufacturing chain implemented and tested in Godot 4.6.2 Stable. Gameplay changes were committed and pushed to `main` before this documentation entry.

### Architecture Review and Decisions

- Preserved the existing data-driven `BuildingDefinition`, `BuildingRuntime`, `ItemDefinition`, `ItemAmount`, `ProductionRecipe`, and `InventoryComponent` architecture rather than introducing a parallel manufacturing system.
- Chose **separate input and output inventories** for manufacturing machines before implementation, preventing raw materials and finished products from competing for the same capacity.
- Configured the Test Smelter with `InputInventory` capacity **50** and `OutputInventory` capacity **100**, both using independent instances of the existing `InventoryComponent`.
- Agreed that all machines that extract or manufacture items should expose understandable operating statuses and a reusable, live activity progress indicator. Pure storage buildings have no processing progress bar.

### Safe Recipe-Based Manufacturing

Extended `scripts/components/producer_component.gd` with:

- `input_inventory` and `output_inventory` references for independent material buffers.
- `has_required_inputs()` to validate nonempty recipes, required quantities, and duplicate ingredient entries without consuming items.
- `can_store_recipe_outputs()` to reject missing/invalid outputs and ensure **all** output units fit within output inventory capacity.
- `try_complete_recipe_cycle()` to check inputs and output space, consume recipe ingredients, create finished products, and report success only for a complete cycle.
- `_rollback_recipe_cycle()` to attempt recovery if a synchronous removal or output addition unexpectedly fails; normal and blocked paths passed tests. Exceptional rollback-failure scenarios remain a future hardening area.
- A guarded timed production loop that advances only when inputs and output space are available; otherwise it resets progress and exposes statuses such as `Waiting for Inputs` or `Output Blocked`.
- Removal of the obsolete output-only production method that could generate items without consuming inputs.

For the first recipe, `data/recipes/test_smelting.tres` transforms **2 Test Ore → 1 Test Ingot** in a **2-second** production cycle. The new permanent output item is `data/items/test_ingot.tres`.

### Test Smelter Building

Added:

- `scenes/buildings/test_smelter.tscn`
- `data/buildings/test_smelter.tres`

The Test Smelter uses reusable selection, collision, rotation, placement, and demolition behavior, plus these child components:

- `BuildingRuntime`
- `InputInventory` (50)
- `OutputInventory` (100)
- `ProducerComponent`, with references to the smelting recipe and both inventories
- `LogisticsInputComponent`

Registered the smelter as construction option **4** by adding `select_building_4` to `project.godot`, adding the definition to `WorldInteraction.buildable_definitions`, and extending the Build HUD to render and highlight `[4] Test Smelter`. Existing slots 1–3 continue to work.

### Storage-to-Smelter Input Logistics

Implemented `scripts/components/logistics_input_component.gd` as a separate reusable component so the existing extractor-to-storage transfer logic remains intact.

- Searches the `logistics_storage` group for the nearest eligible stocked storage building using building-origin distance.
- Ignores out-of-range candidates, invalid inventories, deletion-queued objects, and disabled placement ghosts.
- Requests the configured `ItemDefinition` from nearby storage via the established `InventoryComponent.transfer_to()` method; it does not create items.
- Uses default configuration: Test Ore, **up to 5 units per attempt**, **1-second interval**, **5-world-unit range**, and a **10-ore input buffer target** (independent of the physical 50-unit input capacity).
- Reports transfer status and recent quantity for debugging.

**Working automated flow:** finite Test Ore Deposit → Test Extractor → Test Storage → Test Smelter input → timed smelting → Test Smelter output (Test Ingots). This is proximity-based, direct inventory movement, not a visual conveyor system.

### Production and Extraction HUD

Enhanced `scripts/production_debug_hud.gd` and `scenes/ui/production_debug_hud.tscn`:

- Selected smelters show recipe, live `production_status`, input ingredient quantities and requirements, input capacity, output item quantities, and output capacity.
- Corrected the original producer HUD assumption that all buildings store items in a child named `InventoryComponent`; smelter results now come from `OutputInventory`.
- Added `InfoContent` and one shared `ActivityProgressBar` under the HUD panel.
- Manufacturing progress reads `ProducerComponent.production_progress / recipe.production_time`.
- Extraction progress reads `ExtractorComponent.extraction_timer / extraction_interval`.
- The indicator resets to 0% when blocked and is hidden for storage, resource deposits, and no selection.

Updated `scripts/components/extractor_component.gd` with an explicit `extraction_status` and timer gating for no deposit, depletion, full inventory, missing data, and invalid intervals. The extractor HUD now displays the component's true status instead of claiming `Extracting` while its inventory is full.

### Tests and Verified Results

Added standalone Godot regression suites:

| Test scene | Result |
| --- | --- |
| `tests/recipe_input_availability_test.tscn` | **8/8 passed** |
| `tests/recipe_output_capacity_test.tscn` | **11/11 passed** |
| `tests/manufacturing_transaction_test.tscn` | **9/9 passed** |
| `tests/timed_manufacturing_test.tscn` | **8/8 passed** |

**Total: 36/36 Chat 06 assertions passed.** Existing Chat 05 inventory-transfer tests (four test groups) also passed during final regression testing.

Gameplay verification also covered key 4 selection, placement, rotation, overlap blocking, selection highlight, demolition highlight/removal, automatic resource transfers, ingot accumulation, and the shared activity progress bar for both extractor and smelter.

**Output-full safeguard:** temporarily set the smelter output capacity to **2**. The HUD showed `Output Blocked`, **2/2** ingots, **10/50** input ore, and **0%** progress. Inputs and outputs remained unchanged while blocked. The output capacity was subsequently restored to **100** and saved.

**Resource conservation:** in a verified single-deposit, finite-500-ore test, **236 remaining in deposit + 50 in extractor + 200 in storage + 10 in smelter input + 2 ingots × 2 ore each = 500 ore equivalents**. A later final end-to-end test was reported successful, though its exact terminal inventory counts were not recorded in chat. No loss or duplication was observed in these tests.

### Troubleshooting and Lessons

- **Placed smelter selected but did not turn gold/red:** `selectable_object.gd` was attached, but the exported `Selection Mesh` reference was unset. Assigning the `BuildingMesh` child resolved normal selection and demolition-hover highlighting.
- **HUD continually reported 0 ingots despite active smelting:** its original lookup used `InventoryComponent`, whereas the smelter stores finished products in `OutputInventory`. Updating the HUD inventory lookup exposed the real count.
- **Build HUD lacked option 4 / did not highlight selection:** registering the input action alone was insufficient; the Main scene definition array and `Building4Label` selection handling also needed updates.
- **Extractor displayed `Extracting` at 50/50:** replaced duplicated, inferred HUD status strings with the component-owned `extraction_status`.
- **Commit hygiene:** removed trailing whitespace before staging and excluded an accidentally created untracked file containing a Git diff summary. The tested gameplay commit was pushed successfully; local Git status was then confirmed clean.

### Scope and Follow-Ups

**Implemented:** first real automated manufacturing recipe, independent machine input/output buffers, buffer-limited input logistics, reusable manufacturing/extraction progress, and end-to-end conservation testing.

**Not implemented yet:** finished-product export from the smelter, dedicated conveyors/inserters/ports, advanced multi-input routing, energy and fuel costs, production upgrades, a finalized player-facing machine panel, or defense/horde mechanics. These remain subsequent development milestones.

---

## 2026-10-22 — Chat 07: Recipe Selection & Recipe-Aware Input Logistics (First Checkpoint)

### Architectural Direction and Scope

After Chat 06, confirmed the intended gameplay is **physical conveyor-based** factory automation feeding ammunition manufacture and colony defense, rather than proximity-based “magic transfers.” The long-term design in [GAME_VISION.md](GAME_VISION.md) calls for selectable manufacturing recipes that determine allowed inputs; universal small, medium, and large storage with slots/stacks; one automatic-turn conveyor placement tool; and **dedicated placeable splitter and merger buildings**. The first zombie-colony world includes structures and settlements associated with enemy spawning; larger logistics systems and additional planets remain later design work.

This Chat 07 checkpoint deliberately implements **recipe rules first**, preserving the short-range logistics chain until belt transport has tested replacements.

### Gameplay Implementation (Steps 07.2A–07.2D)

- `ProducerComponent.available_recipes`: Inspector-configurable list of recipes supported by a machine; the existing `recipe` field continues to represent the active recipe. The Test Smelter registers `test_smelting.tres` in its available list.
- `ProducerComponent.select_recipe(new_recipe)`: validates allowlist, non-null selection, positive production time, and nonempty ingredient/output collections; avoids changing an already-selected recipe. A real change is allowed only with an existing **empty** input inventory. It preserves stored finished goods, resets production progress, and records `Recipe Changed`.
- `ProducerComponent.accepts_input_item(item)`: non-mutating check for a valid, positive-quantity ingredient in the active recipe. Eligibility automatically changes when the recipe changes; this method does not move items or check available space.
- `LogisticsInputComponent.producer_component`: optional-on-disk but **required for working transfers**; linked in the Test Smelter scene. Delivery stops safely with `Producer Missing` or `Item Not Required by Recipe` when the reference/ingredient is incompatible. The original Test Ore transfer rate, buffer and manufacturing logic were retained.
- Changes were edited and tested locally in Godot 4.6.2 and pushed successfully by the developer to GitHub `main`.

### Tests and Verification

| Scene / check | Reported result |
| --- | --- |
| `tests/recipe_selection_test.tscn` | **10/10 passed** |
| `tests/recipe_input_acceptance_test.tscn` | **6/6 passed** |
| `tests/recipe_logistics_acceptance_test.tscn` | **5/5 passed** |
| Chat 06 recipe input, output capacity, manufacturing transaction, and timing tests | **36/36 passed** |
| Chat 05 inventory transfer regression | **Passed** (existing groups) |
| Main game: extraction, storage-to-smelter supply, smelting, HUD, placement and demolition | **Passed** |

**Total of 21 new Chat 07 assertions/groups and 36 earlier manufacturing assertions reported passing.** This checkpoint added no resource-conservation failure or game regression in the user-run tests. Tests were performed in the Godot editor, not in GitHub CI.

### Troubleshooting and Cleanup

- An isolated recipe-aware logistics test initially printed automatic transfer messages *after* its PASS banner. Resolved by disabling both the logistics and producer nodes' frame processing after scene insertion, manually invoking transfer attempts, and queueing temporary buildings for deletion before final results.
- A subsequent GDScript parser error (`Used space character for indentation instead of tab`, including around line 83) came from space indentation inserted into a tab-indented test script. Replacing affected leading whitespace with one tab inside `_ready()` resolved it; the test reran successfully with **5/5** passes and no trailing transfer messages.

### Current Boundaries / Next Work

- The Test Smelter still has **one configured permanent smelting recipe**; no production selection UI or additional persistent ore/ammunition recipes have been added.
- Ingredient eligibility is separate from physical insertion. Dynamic or multi-ingredient conveyor admission, stack/slot capacity, and input/output port behavior are still to be designed and tested.
- Short-range transfers are temporary scaffolding, not final gameplay logistics. Finished ingots remain in the smelter output inventory until belt transport and destinations are implemented.
- Next focus: review and incrementally design machine input/output ports and admission/hand-off contracts for later conveyors, while retaining current regressions and the First Night ammunition-and-defense objective.

---

## 2026-10-22 — Chat 07: Physical Port Foundation & Logical Handoffs (Second Checkpoint)

### Implementation (Steps 07.3A–07.3E)

- Created reusable `scripts/components/item_port_component.gd` (`ItemPortComponent extends Marker3D`) with `INPUT`/`OUTPUT` directions, recipe-specific vs universal item acceptance, and explicit inventory and optional producer references.
- Implemented **read-only** `can_accept_item()` (recipe eligibility, full-request available capacity, input role and correct inventory) and `can_provide_item()` (output role, item availability and output-inventory identity).
- Attached sibling `InputPort` and `OutputPort` `Marker3D` nodes to `scenes/buildings/test_smelter.tscn`, positioned on opposite X faces at local `(-0.85, 0.5, 0)` and `(0.85, 0.5, 0)`; oriented Y `+90°` and `-90°`. Bound InputPort to `InputInventory` and OutputPort to `OutputInventory`, each referencing `ProducerComponent`.
- Added `try_transfer_to_port()` to guard destination role, self-transfer, ingredient acceptance, source availability, requested capacity, then delegate accounting to `InventoryComponent.transfer_to()`. Failed prechecks return zero without changing inventories.
- Proved the complete *manual* workflow on a real Test Smelter: initial six ore in source, two ore supplied per cycle, two smelting cycles produce two ingots; one goes to capacity-1 storage and a second remains in the output buffer when storage is full; source retains two ore. Total **6 ore equivalents** conserved.

### Validation and Regression Checkpoint

| Test scene or coverage | Developer-reported result |
| --- | --- |
| `item_port_foundation_test.tscn` | **7/7 passed** |
| `item_port_integration_test.tscn` | **8/8 passed** |
| `item_port_transfer_test.tscn` | **7/7 passed** |
| `item_port_real_smelter_test.tscn` | **7/7 passed** |
| Earlier Chat 07 recipe selection / acceptance / logistics | **21/21 passed** |
| Earlier Chat 06 manufacturing suite | **36/36 passed** |
| Inventory transfer regression | **Passed** |
| Main extractor → storage → smelter production, interactions and HUD | **Passed** |

**29/29 new port tests**, **21/21 earlier Chat 07 recipe tests**, and **36/36 previous manufacturing checks**: **86 checks** across those named groups, in addition to inventory-transfer and gameplay regressions. These are reported local Godot 4.6.2 test runs, not GitHub Actions results. The developer confirmed the port milestone gameplay/test files were pushed successfully to GitHub `main`.

### Architecture Decision and Boundaries

The port component currently exposes a safe **logical transfer**, not a physically connected network. There are no placed conveyors, connection/adjacency validation, route selection, belt throughput timing, storage slot/stack layout, or automatic ingot export from the smelter. Existing proximity transfers were intentionally retained in the playable prototype.

The next incremental development priority is **connection validation between oriented ports and future directional belt segments**, followed by test-first belt placement/connection and item movement. Dedicated splitters and mergers remain distinct planned placeable buildings. Ammunition manufacture feeding defensive structures and a zombie colony First Night remains the primary game loop objective.

---

## 2026-10-24 — Chat 07: Straight Conveyor Geometry, Snapping and Placement (Third Checkpoint)

### Implemented Features

- Built LogisticsConnectionGeometry for independent world-space distance, facing and forward alignment tests.
- Added ConveyorStraight scene with BeltMesh and input/output Marker3D endpoints; item flow will be local +Z → -Z, but item movement is NOT implemented.
- Added ConveyorSegment previous/next links, strict 0.05-unit connect tolerance, and safe disconnect/scene exit cleanup.
- Implemented automatic snap-after and snap-before calculations, including nonmutating ghost preview transforms and occupied-endpoint guards.
- Added Conveyor Belt building definition, key 5 and HUD slot while preserving the original four buildings.
- Integrated nearest-compatible-endpoint search in WorldInteraction and permanent snapped placement that creates exactly one belt before returning to regular building logic.
- Added steel-gray placeholder material, selection and demolition visual methods, and separate Layer 2 Area3D input hitbox and Layer 3 placement-blocking body.

### Testing

| Scene | Developer-reported checks |
| --- | --- |
| logistics_connection_geometry_test.tscn | **8/8** |
| conveyor_alignment_test.tscn | **9/9** |
| conveyor_connection_state_test.tscn | **8/8** |
| conveyor_snapping_test.tscn | **5/5** |
| conveyor_snap_preview_test.tscn | **5/5** |
| conveyor_snap_before_test.tscn | **5/5** |

**40/40 conveyor checks passed.** The developer also confirmed successful real-game snap-before and snap-after placement, rotation, selection, demolition and unchanged factory manufacturing. The local milestone was pushed to GitHub main. These are Godot 4.6.2 editor tests, not a CI run.

### Bugs Resolved and Lessons

- An early failed ConveyorSegment cast assertion was caused by attaching the wrong script to the conveyor scene root. Attaching conveyor_segment.gd to ConveyorStraight resolved it.
- The conveyor mesh initially appeared dark; an explicit material fixed the appearance.
- Mouse selection/demolition was initially inaccurate due to collision shapes offset from the visible mesh. Values meant for Shape Size had been entered as node Transform Position. Correcting parent/child positions and using a separate interaction Area3D produced correct gold and red highlights and reliable deletion.
- A temporary placement guard intentionally printed "Conveyor snap preview only — placement not enabled yet" until connecting on click was implemented. The permanent snapped-placement branch must execute **before** the normal building instantiation to avoid duplicate objects. Final logs showed success for Before: false and Before: true.
- Perpendicular belts can look like a corner but do not yet provide a functional turn; visual touch is not a connection.

### Remaining Work

True corner scenes/automatic turn geometry, direct machine-port connections, item motion/throughput/backpressure, universal slot-based storage, and ammunition/defense remain planned. Proximity logistics is still the active resource-delivery mechanism.

**Nonblocking code-review cleanup:** The committed InteractionHitbox BoxShape3D lacks an explicit size override (so Godot uses its default cube), and its CollisionShape3D has slight Y rotation. The gameplay test passed, but normalize these when designing exact corners. A redundant conveyor_snap_source reset near the end of world_interaction.gd can also be removed during a later cleanup.

---

## 2026-10-27 — Chat 07.5: Automatic Conveyor Turns, L-Shaped Visuals and Direction Indicators (Fourth Checkpoint)

### Construction and Connection Changes

- Added `scenes/logistics/conveyor_corner.tscn` and `conveyor_corner_left.tscn` with oriented endpoints; developed safe right/left corner chains and rotation/connection tests.
- Added `ConveyorTurnIntent` and `ConveyorPieceSelector` as helpers for turn classification and shape references. The settled build interaction is **not** a mouse-selected corner ghost: it uses a normal straight preview through the single Conveyor Belt tool (key 5).
- Added `ConveyorCornerConversion.try_convert_and_connect()`: when a new perpendicular straight belt is correctly oriented next to an eligible straight belt's free output, the **existing belt** changes into a corner in place. Its identity and incoming connection remain intact; occupied outputs, invalid turns and misaligned endpoints fail without consuming an existing link.
- `WorldInteraction` integrates the perpendicular neighbor detector with normal placement, alongside the existing straight snap-before/after route. Successful turns report `AUTO CORNER SUCCESS | Turn: RIGHT/LEFT`.
- Added `ConveyorCornerVisualMesh` to provide gray L-shaped placeholder geometry. The version committed at this checkpoint merges **two rectangular arms** with SurfaceTool and uses width 0.8, height 0.2, arm length 0.6 and offset 0.2. Screenshots show usable filled-looking bends; a truly unified polygonal top and exact seam/collider matching remain refinements.
- Added `DirectionArrow` beneath `ConveyorStraight/OutputEndpoint`. Its unshaded yellow arrow follows each segment's actual output marker: straight belts, green construction ghosts, and corners converted in place show flow direction even before item motion is implemented.

### Validation Evidence (Local Godot Editor)

| Test or manual check | Reported/observed outcome |
| --- | --- |
| Right-corner scene connection and demolition | 8/8 |
| Left-corner scene connection and demolition | 8/8 |
| Corner snap-preview geometry | 6/6 |
| Conveyor turn intent | 8/8 |
| Conveyor piece selector | 8/8 |
| In-place corner conversion | 8/8 |
| Connected conveyor full-chain regression | 8/8 |
| L-shaped corner visual mesh regression | 8/8 |
| Main game: right/left auto-corners, extended straight chains, rotated layouts | Successful screenshots/output |
| Green preview direction arrow, selection, demolition, collision overlay | Successful user inspection |

The individual test outcomes were shared over several steps; **no claim is made that every old and new test was rerun together**. No GitHub CI run is claimed. The developer subsequently showed `main` synchronized to `origin/main` with a clean working tree; the new source files and tests were verified in the remote repository.

### Problems, Decisions and Remaining Scope

- Multiple apparently incorrect 90° placements were caused primarily by **ambiguous visual direction**: a plain rectangular belt looks identical at 90° and 270°, even though their outputs face opposite world directions. Visible arrows clarified valid orientation. Positive Y rotations in Godot do not necessarily match a player's intuitive notion of rotating right; retain endpoint-facing checks rather than accepting opposite-facing connections.
- Snapping after a converted corner must use its **OutputEndpoint world basis**, not only the segment root basis, because a corner's output is rotated relative to its root.
- A visual ring of belts is not proof of a closed directed graph. The final already-existing endpoint-to-endpoint loop connection needs separate gameplay integration and validation.
- The initial corner had narrow or missing-looking bend regions. The revised arm widths improve continuity, but the committed mesh still uses two joined boxes; exact continuous visual surfaces, collision/hitbox shape cleanup, and edge seams can be refined without changing established logistics links.
- **Not implemented:** item movement along conveyors, throughput, backpressure, belt-to-machine/storage port hookup, autonomous finished-product export, or dedicated splitter/merger buildings. The extractor → storage → smelter still runs on temporary proximity-based logistics.

**Next milestone:** validate final construction/connection regressions, improve precise hitboxes and corner surfaces, implement safe existing-belt loop closure, then introduce machine/storage port-to-belt links and conservation-tested conveyor item flow.

---

## 2026-10-27 — Chat 08: Generic Belt-to-Belt Transport Foundation (First Milestone)

### Implemented

- Created `ConveyorTransportComponent` with a strict one-unit `CargoInventory` buffer. All item operations use `ItemDefinition` and existing `InventoryComponent.transfer_to()`; no resource-specific belt behavior is hardcoded.
- Created `ConveyorTransportLink.try_transfer_forward()` to require reciprocal directed belt links and current endpoint alignment before handing off cargo.
- Created `ConveyorTransportTimer` with a configurable 1.0-second prototype travel interval and frame-driven update. A full/disconnected downstream belt blocks the current item without duplication or loss; movement resumes once there is space.
- Added `CargoInventory`, `ConveyorTransportComponent`, and `ConveyorTransportTimer` as direct children of the live `ConveyorStraight` scene, leaving existing snapping, arrows and corner-conversion geometry untouched.
- Verified that converting a straight belt into either automatic corner preserves the node, the held item, and the timer's partial progress.
- Added `ConveyorSegment.can_demolish_safely()` and a guard in `WorldInteraction` so **player demolition** rejects occupied or invalidly configured conveyor cargo buffers.

### Reported Local Godot Results

| Test | Checks |
| --- | --- |
| Cargo buffer | 7/7 |
| Connected directed transfer | 7/7 |
| Timed generic transport | 8/8 |
| Corner cargo preservation | 8/8 |
| Six-segment full chain | 8/8 |
| Player demolition safety policy | 6/6 |
| **Total across six separate suites** | **44/44** |

The updated connected (7/7), timed (8/8) and original full-chain construction (8/8) regressions were rerun after scene integration. The developer also confirmed normal game placement, rotation, yellow arrows, right/left corners, empty-belt demolition, and the original extractor → storage → smelter chain still worked. These are developer-run editor validations, **not a single combined CI report**.

### Important Design Decisions and Remaining Work

- **Universal cargo:** belts accept any valid `ItemDefinition`; receiving manufacturing ports will filter using the active recipe, while general storage accepts ordinary items subject to capacity.
- **Strict physical links:** automatic belt handoffs must use directed, geometry-valid next/previous connections; the low-level inventory helper alone is not an authorization to transfer.
- **Prototype throughput:** each segment currently carries one item unit and uses a 1-second interval; final belt occupancy, speed, visible travel interpolation and throughput balance remain open.
- **Safety scope:** only demolition through `WorldInteraction` is cargo-blocked. Direct `queue_free()`, scene teardown and eventual enemy destruction need a cargo recovery/dropping policy.
- **Not yet a physical factory:** no building-to-belt snap/load/unload path, visible cargo models, separate splitter/merger, intentional closed-loop closure or automated ingot export. Temporary proximity logistics remains active.

The user committed and pushed the tested gameplay milestone to GitHub `main` before this documentation update. **Next milestone:** visible generic cargo on belts, then machine/storage port connections and full ore-to-ingot physical routing, with regression checks at each step.

---

## 2026-10-27 — Chat 08: Visible Cargo, Building Connections and Physical Factory Test (Second Milestone)

### Implemented & Tested

- Created `ConveyorCargoVisual` as a read-only `MeshInstance3D` placeholder. The real ConveyorStraight scene now has a `CargoVisual` child, hidden when empty and interpolating from input to output along straight belts or an L-shaped local path on converted left/right corners. The carried `ItemDefinition` is generic; distinct item-specific artwork is not implemented yet.
- Added `OutputPort` to `test_extractor.tscn`, referencing the extractor's existing 50-unit inventory. Existing Test Smelter input/output ports continue to use the producer's selected recipe and separate inventories.
- Added `ConveyorBuildingSnap` to calculate read-only building-port snap transforms for either port direction and rotated buildings; extended it to reject occupied building and belt endpoints.
- Added reciprocal `connected_conveyor` / `input_building_port` / `output_building_port` references with alignment checks, exclusive connection ownership and cleanup on endpoint removal. Geometric alignment alone does not authorize transferring items.
- Added `ConveyorBuildingTransfer` for generic one-item output loading and guarded input unloading. Active-recipe filtering rejects irrelevant materials, full destinations retain cargo, and all transactions use conservation-aware InventoryComponent methods.
- Updated `ConveyorTransportTimer` to automatically load empty belts from connected output ports and to unload after the travel interval into connected input ports; forward belt-to-belt transfers, congestion retention and recovery remain available.
- Verified a real Extractor and Smelter with a three-belt route: **2 Test Ore seeded in the extractor → physically carried to Smelter → 1 Test Ingot manufactured**, with manual deterministic timer and producer updates and proximity/extraction processing disabled.

### Local Godot 4.6.2 Test Record

| Test scene | Result |
| --- | --- |
| `conveyor_cargo_visual_test.tscn` | 6/6 |
| `conveyor_corner_cargo_visual_test.tscn` | 8/8 |
| `extractor_output_port_test.tscn` | 7/7 |
| `conveyor_building_snap_test.tscn` | 10/10 (after occupancy expansion) |
| `conveyor_building_connection_test.tscn` | 8/8 |
| `conveyor_building_loading_test.tscn` | 9/9 |
| `conveyor_building_unloading_test.tscn` | 10/10 |
| `conveyor_automatic_unloading_test.tscn` | 9/9 |
| `conveyor_automatic_loading_test.tscn` | 10/10 |
| `conveyor_physical_factory_test.tscn` | 9/9 |
| **Second milestone subtotal** | **86/86** |

With the first milestone **44/44**, Chat 08 now has **130/130 reported checks over individually run suites**. Connected/timed/full transport and automatic unloading regressions were rerun successfully during development. The final physical factory integration test passed 9/9, and the developer pushed the changes to `main`. No single consolidated CI run is claimed.

### Problems Resolved

- `CargoVisual` initially had the **test script** (`conveyor_cargo_visual_test.gd`) attached instead of `conveyor_cargo_visual.gd`, producing a stack overflow during scene initialization. Assigning the correct component script restored passing straight/corner visual tests.
- An explanatory pseudo-code example was accidentally pasted at the bottom of `conveyor_building_transfer.gd`, duplicating `extends RefCounted` and `class_name` declarations. Removing that sample and appending only the complete top-level `try_unload_from_belt()` function corrected the file.
- The `conveyor_building_unloading_test` script/scene were initially missing; they were created separately and the new unloading test passed 10/10. `Extractor has no resource node` appeared in isolated tests because no deposit was instantiated; it was not a port/transport failure.

### Boundaries and Next Work

- The normal player factory does **not yet snap belts to building ports through Build Mode**. The completed physical route exists in an isolated test which positions and connects its actors in code, seeds ore instead of mining, and manually drives timers.
- The temporary Extractor → Storage → Smelter proximity logistics remains enabled in normal gameplay. It must be gated or replaced only after safe physical routes and regression coverage exist, to prevent overlapping transfer systems.
- Test Storage still needs dedicated universal input/output ports and a validated complete physical route via storage. Further tests should cover multiple simultaneous items, throughput and transfer order under frame-driven updates.
- The generic orange placeholder is common to all item definitions; distinct item visual models, splitter/merger buildings, explicit loop closure, improved corner colliders and cargo recovery for non-player destruction remain open.

**Next milestone:** integrate building-port preview/connection into `WorldInteraction` carefully, test player-created Extractor → Belt → Smelter networks, and add Storage port support before switching off proximity logistics.

---

## 2026-10-27–30 — Chat 08.3F–08.3G: Player-Built Physical Logistics, Grid Alignment and 1×1 Routing Buildings

### Goals and design decisions

The user identified recurring final-junction failures while building a real Extractor → Storage → Smelter route and returning belts to previously placed factories. Core decisions:

- **Construction order should not matter** when the endpoints and turn direction are actually compatible.
- **Conveyors remain physical:** no magical item movement or forced joining of visually touching but incompatible arrows.
- Use a **shared 1-unit factory grid**, taking rotated footprint parity into account, instead of independently rounding buildings and conveyors.
- Support correct final connections with new missing corners, in-place source or receiver corner conversion, exact bridges, fractional straight spans and offset L-shaped connectors.
- Dedicated **Merger**/**Splitter** are not ordinary belt turns. Final prototypes are each **1×1** with a port on every side: **3 IN → 1 OUT** and **1 IN → 3 OUT** respectively.
- Keep inventories bounded, preserve cargo and existing building links, and reject invalid occupancy rather than overwriting old connections.

### Major construction features committed

1. **Smelter dual-port and building port foundation:** Independent input/output ports, directed build previews, building-to-existing-belt snapping and reciprocal links. In-game logs showed successful building hookups and ore/ingot movement.
2. **Conveyor bridge and corner discovery:** Read-only previews, collision/endpoint revalidation on click, separate missing-corner and existing-receiver/source conversion paths, and safe two-ended bridge commits. The user reproduced prior impossible loop-closure cases and verified automatic corners connecting successfully.
3. **`FactoryGrid` consistency:** Footprint-aware odd/even building origins, rotated grid lanes and shared coordinate tests. All current building types use grid-aware placement; placement snap-to-belt rejects transforms that would put a new building off-grid.
4. **Fractional/offset geometry:** `conveyor_fractional_bridge.gd` and `conveyor_offset_corner_bridge.gd` construct actual cargo-carrying variable-length straight and L-shaped segments, with properly adjusted endpoints, physics and selection hitboxes. These resolve half-tile Extractor spacing and small perpendicular gaps when free endpoints are directionally compatible.
5. **Constant physical item speed:** `conveyor_path_motion.gd` scales connector travel time according to path length and allocates corner interpolation proportionally to each leg. A developer live check confirmed that ore moved at the same apparent speed over short and regular belts after the change.
6. **1×1 routing buildings:** `conveyor_merger.tscn` with `ConveyorMergerComponent` has three separate input buffers and a single output; `conveyor_splitter.tscn` with `ConveyorSplitterComponent` has one input and three independent bounded output buffers. Both route fairly under backpressure and require physical connections. Build Mode uses **6** for Merger and **7** for Splitter.
7. **Diagnostics and safe demolition:** Production Debug HUD shows port connections, input/output buffer quantities and per-lane completed transfer counters. Full Merger/Splitter buffers block unsafe player demolition; standard cargo-bearing conveyors retain their cargo-protection rules.

### Reported validation (Godot 4.6.2 Stable, local)

| Checkpoint | Reported outcome |
|---|---|
| Original Smelter dual-port snap | 8/8 |
| Dual-ended conveyor bridge | 11/11 |
| Bridge discovery | 10/10 |
| Factory-grid alignment (progressively expanded) | 9/9 early; latest suite covers five building types and 52 rotated lanes |
| Existing endpoint/connection and receiver-corner work | Individual suites passed; regression runs also reported |
| Existing receiver auto-snap | 11/11 |
| Building-safe source corner auto-snap | 10/10 |
| Fractional straight connector | Initial 10/10; additional later assertions passed after Build Mode and speed changes |
| Offset L-shaped connector | Initial 10/10; additional later assertions passed after constant-speed correction |
| 1×1 Merger: 3 inputs, 1 output | 10/10 |
| 1×1 Splitter: 1 input, 3 outputs | 10/10 |
| Live Splitter production | **13 completed splits**, `To A: 5`, `B: 4`, `C: 4`; three physically connected output ports |

These are **reported individual test runs**, not a single scripted or CI-based full regression. Exact test-scene names and a reproducible acceptance sequence are in [CHAT_08_FINAL_REGRESSION.md](CHAT_08_FINAL_REGRESSION.md).

### Important troubleshooting and lessons

- A translucent conveyor ghost can be visually correct but still fail to commit; always distinguish *snap discovery* from validated permanent connection.
- Opposite-facing/free endpoints are essential. A corner may redirect a single flow but cannot safely combine two occupied incoming branches.
- The first Merger design used a 2×2 body whose output center could sit between grid lanes; it was replaced by the final 1×1, four-port layout.
- Short conveyor segments taking the same interval as regular 1-unit belts looked slower; constant distance-based timing fixed the visual inconsistency without changing inventories.
- A busy Merger may stall because **three supplies share one bounded output**, not because a building-input port was disconnected. Per-lane counts and output occupancy must be inspected together.
- Before editing a long controller script, locate changes by major section headers, inspect parser errors at their first occurrence, and use discrete test scenes as regression gates.
- GitHub file edits can trigger Godot's “newer on disk” prompt; preserve unsaved edits and reload the pulled scene resources.

### Current acceptance status and remaining work (2026-10-30)

**Completed and observed:** Physical conveyor connections, short-gap placement, constant cargo speed, 1×1 Merger construction with three connected incoming lanes, and three-way Splitter cargo distribution in the main game. The developer reported the latest grid/Merger/Splitter isolated tests all passing.

**Not yet fully observed:** The 1×1 Merger's live **`From A`, `From B`, `From C`** counters all progressing during a sustained three-input/one-output production run. In particular, a paused input must be distinguished from a full output buffer; do not claim final full Merger acceptance solely from construction screenshots.

**Remaining release gate:** Run the critical scenes as a single final manual regression pass, verify Merger backpressure/recovery, confirm full deposit-driven physical mining→smelting→destination delivery without double counting retained proximity scaffolding, and inspect collision/selection/demolition behavior. Then create the final accepted GitHub checkpoint.

**Future product goals:** Gradually retire prototype proximity logistics with conservation checks, cargo recovery for destructive events, universal tiered slot/stack storage, polished visual cues, ammunition manufacture, defense and zombie First Night gameplay.

---

## 2026-10-30 — Chat 08 Final Logistics Acceptance Checkpoint (Core Systems)

### Final manual regression

The developer ran **all 20** enumerated Godot `F6` test scenes over **four rounds of five tests**, confirming every round passed. Covered grid alignment and rotated ports; three-input Merger and three-output Splitter; existing and missing corner conversion; endpoint discovery; two-ended and fractional/offset bridges; cargo path visuals; automatic machine loading/unloading; and isolated physical ore-to-ingot transport.

**Evidence status:** These are developer-reported local editor results, not one automated GitHub CI run. See [CHAT_08_FINAL_REGRESSION.md](CHAT_08_FINAL_REGRESSION.md) for the exact scene list.

### Live gameplay completion

- **Merger (1×1, 3 IN / 1 OUT):** Three connected source routes showed physical item transport; developer subsequently confirmed Merger operation in the live factory. Detailed `From A/B/C` HUD values were not separately captured.
- **Splitter (1×1, 1 IN / 3 OUT):** Live Production Debug HUD captured **13 successful splits**, distributed A=5, B=4, C=4; all three output ports connected.
- **Backpressure:** Developer explicitly confirmed that the Merger retained cargo under blocked-output conditions and resumed after space became available.
- **Ore-to-ingot production:** Developer explicitly confirmed a fully working ore-to-ingot factory chain in gameplay, beyond the earlier seeded isolated physical factory test. No numerical end-to-end resource-conservation snapshot was supplied for this new run.

### Milestone decision

**Core Chat 08 physical factory-logistics milestone: ACCEPTED (2026-10-30).** Both the manual regression and the principal player-visible production/routing behavior have passed.

This acceptance **does not** mean everything in the long-term logistics roadmap is finished. We have not separately verified that legacy proximity-based scripts were disabled for the latest live run; a confirmed functioning belt chain does not, by itself, prove there are no parallel automatic proximity transfers. Do not remove that legacy logic without a controlled physical-only conservation regression.

### Carry-forward work (later milestone)

1. Confirm physical-only resource accounting and carefully retire/gate redundant short-range proximity transfer scripts.
2. Improve diagnostic snapshots/throughput benchmarking (Merger lane counts; Splitter blocked-output sustained-traffic behavior).
3. Confirm demolition, collision refusal and cargo-recovery behavior in complex live builds; establish persistence and player-friendly build visuals.
4. Continue the original gameplay vision toward ammunition production, defensive supply and the zombie First Night vertical slice.

**Documentation checkpoint:** `GAME_DESIGN.md`, `ARCHITECTURE.md`, `TROUBLESHOOTING.md`, `ROADMAP.md` and this log capture implementation and engineering lessons. This entry supersedes earlier *historical* statements that Merger/backpressure and full factory live verification were still pending.


---

## 2026-10-31 — Physical-Only Production, Ammunition Acceptance and First Turret Foundation

### Verified by local Godot tests

- `tests/conveyor_physical_only_conservation_test.tscn`: **9/9 passed**. A 500-unit finite ore deposit supplied a physical-only Extractor → Storage → Smelter → Storage route. Legacy proximity scripts were disabled during the test. After two ore were converted into one ingot, 498 ore + (1 ingot × 2 ore) equaled the initial 500 ore equivalents.
- `tests/prototype_ammunition_press_test.tscn`: **9/9 passed**. The data-defined ammunition recipe accepts only Test Ingots, creates four Prototype Rounds per ingot, and protects finished rounds during output blockage and recovery. Conveyor export to warehouse and eight-round conservation were tested.
- `tests/ammunition_press_build_mode_test.tscn`: **9/9 passed**. Slot 8, keyboard selection, highlighting, rotation, grid-aligned ports, connection cleanup and demolition safety all passed.
- **Live main-game observation:** User supplied a screenshot with a physically connected manufacturing line and the selected final Test Storage HUD showing **6 Prototype Rounds / 200 capacity**. This verifies that manufactured ammunition arrived in normal storage during gameplay. Rounds are moved one at a time, so an intermediate storage count need not be divisible by the four-round recipe batch.

### Safeguards and deferred scope

- The older proximity transfer components still exist in the repository for compatibility, but their scene nodes are configured disabled. They were explicitly disabled during the physical-only conservation run. Do not remove their scripts merely because the new route works.
- The Prototype Ammunition Press is production-ready as a **prototype**, not balanced or visually final. The current recipe is **1 Test Ingot → 4 Prototype Rounds over 2 seconds**; actual military recipes and resource economy remain design decisions.
- New **isolated** 1×1 defensive turret foundation: `DefensiveTurretComponent`, ammunition-only `TurretAmmunitionPort`, `prototype_defensive_turret.tscn`, and `prototype_defensive_turret_test.tscn`. The first checkpoint verifies physical ammo receipt, one-round firing, cooldown, blocked/full magazines, resource conservation and protected demolition. **This newly committed turret test has not yet been run locally**, so it is not accepted as passed.
- The turret is **not** in Build Mode yet and will not auto-shoot enemies. Targeting, projectiles, damage, zombie behavior and defense balance are follow-on features.

### Next acceptance gate

Run `res://tests/prototype_defensive_turret_test.tscn` with **F6** in Godot 4.6.2. Record the result and fix any isolated test issues before registering the turret in the main Build HUD. Preserve the existing conveyor, recipe and warehouse test suites.


---

## 2026-10-31 — Turret Ammunition Foundation Accepted; Build Mode Slot 9 Prepared

### Local test results

The developer ran `res://tests/prototype_defensive_turret_test.tscn` in Godot 4.6.2 and supplied console output confirming **all 10/10 tests passed**. Verified: ammunition-only port acceptance, rejection of ore and ingots, one-way physical belt connection, backpressure, correct one-round firing transactions, cooldown, conservation, magazine capacity recovery, safe demolition, and physical connection cleanup.

### Next integration checkpoint (committed, pending local test)

- Registered **Prototype Defensive Turret** as construction **slot 9** (`9` key), preserving existing slots 1–8.
- Updated `BuildHUD` scene and script with the ninth selection label; adjusted its vertical layout.
- Added `ProductionDebugHUD` turret-specific display showing ammunition quantity/capacity, input-port connection status, cooldown, firing readiness, shot count and an explicit note that **targeting is not implemented**.
- Added `tests/defensive_turret_build_mode_test.tscn` with 12 checks against the real Main scene, building rotation/grid, incoming conveyor, ammo handling, HUD and cleanup.
- Updated the older ammunition press Build Mode regression to continue checking its original eight slots within the new nine-slot roster.

**Acceptance gate:** Run the new 12-case turret Build Mode test in local Godot before claiming the slot 9 integration is validated. Then confirm live delivery of factory-produced Prototype Rounds into the turret magazine. Automatic targeting, firing, damage, zombies and combat balancing remain unimplemented.


### Follow-up acceptance: turret Build Mode slot 9

The developer ran `res://tests/defensive_turret_build_mode_test.tscn` in Godot 4.6.2 and supplied the Output screenshot confirming **all 12/12 checks passed**. Verified existing eight build slots and new slot 9, preview and 90-degree rotation, grid-aligned turret input, ammunition-only acceptance, physical conveyor delivery, loaded-turret demolition protection, Production Debug HUD (connected state/1 of 40 rounds/readiness), a single simulated shot updating the counter, port cleanup, and switching between slots 8 and 9. This completes the local automated acceptance of turret Build Mode integration.

**Next live-game checkpoint:** Use the already-working ammunition factory to feed a placed turret through real conveyors. Existing Storage provides a universal output port; a Storage → Conveyor → Turret connection avoids disrupting the Ammunition Press's single occupied output port. Expect the turret HUD's magazine count to increase while `Fired Shots` stays at zero because no automatic targeting or in-game firing action is implemented yet. Visual targeting, enemy behavior and damage remain pending.


---

## 2026-11-01 — Live Ammunition-Fed Turret Accepted; Isolated Targeting Checkpoint

### Accepted live-game evidence

A screenshot of the player-built factory and selected Defensive Turret HUD confirms physical ammunition supply into the turret: **Ammo Conveyor Connected; Ammunition 9 / 40; Status Ready; Cooldown 0.00 seconds; Fired Shots 0**. This is the first accepted complete physical chain from extraction, smelting and ammunition manufacturing through storage/conveyors into a turret magazine during normal gameplay.

The zero-shot count is correct: no automatic combat behavior was attached to the live turret at the time of acceptance.

### New combat foundation (not yet locally tested)

- `CombatHealthComponent`: generic positive health, guarded damage transaction and death signal.
- `prototype_zombie_target.tscn`: stationary hostile placeholder with visible body and 30 health (not yet a moving zombie).
- `TurretTargetingComponent`: optional child component that scans the `hostile_targets` group, selects the nearest living target within a horizontal range (default 7 world units), and uses the existing `DefensiveTurretComponent.try_fire()` transaction before applying a temporary 10 damage instant hit. Every shot consumes one Prototype Round, obeys cooldown and skips out-of-range, friendly and already-dead targets.
- `tests/defensive_turret_targeting_test.tscn`: isolated 12-case Godot regression covering range, nearest selection, no-target/no-ammo behavior, cooldown, exact damage, target defeat and retargeting, and conservation.

**Important:** This targeting behavior is **not yet attached to the Build Mode turret**. There is no projectile simulation, line-of-sight check, target movement, zombie spawning, building damage or enemy attack behavior. Run the new isolated test first, then integrate into live gameplay only after local verification.

### Next check

Run the targeting regression with F6 in Godot 4.6.2. Preserve the previously passing turret ammo/Build Mode suites, conveyor factory, and ammunition production tests.


### Follow-up acceptance: isolated targeting/damage regression

The developer supplied Godot 4.6.2 output confirming **12/12** tests passed in `res://tests/defensive_turret_targeting_test.tscn`: no-target and out-of-range ammo preservation, ignoring non-hostiles, nearest-hostile targeting, real one-round consumption, cooldown, 10 damage per hit to a 30-HP dummy, skipping defeated targets, retargeting, empty-magazine protection and ammo/shot conservation.

### Player-world combat integration (committed; local validation pending)

- Attached the validated `TurretTargetingComponent` to `prototype_defensive_turret.tscn`. Its range is 7 units and damage 10 per authorized shot; it consumes rounds exclusively through `DefensiveTurretComponent.try_fire()`.
- Placed a stationary `PrototypeZombieTarget` instance at **(-6, 0, -6)** inside the main world's ground area, farther than 7 units from origin to avoid disrupting older slot-9 regression tests. This is a static test dummy, not a zombie with AI or movement.
- Added a visible target health/defeated Label3D and read-only combat statistics to the turret Production Debug HUD (current target, hits, defeated count). Preserved the existing magazine/cooldown/counter display.
- Updated the older turret Build Mode regression's combat label assertion to reflect automatic targeting now being attached.
- Added `res://tests/live_turret_combat_integration_test.tscn`, an **11-case** integration test against the real Main scene, connected physical belt, ammunition inventory, range detection, automatic fire, target health, visible defeat state, HUD and disconnect cleanup.

**Not yet validated locally:** The full scene integration, player-built turret automatic fire and on-screen damage. Do not claim live combat acceptance until the new F6 test and a manual in-game demonstration pass. Instant damage is a temporary placeholder; projectiles, LOS checks, zombie movement/spawning, death animations and combat balancing are future work.


### Follow-up acceptance: real Main-scene combat integration

On **2026-11-01**, the developer ran `res://tests/live_turret_combat_integration_test.tscn` in Godot 4.6.2 and supplied the full Output screenshot confirming **all 11/11 tests passed**.

Verified in the main scene: the stationary 30-HP target exists, slot 9 builds a turret containing automatic targeting, target distance gates firing, no-ammunition preserves health, a real conveyor attaches to the magazine port, each delivered round authorizes one 10-damage shot, cooldown prevents phantom hits, three rounds defeat the dummy without loss, defeated targets stop receiving hits, the target displays `TARGET DEFEATED`, combat counters update in the Production Debug HUD, and empty-turret removal does not break the existing conveyor.

**Next checkpoint (not yet accepted):** Manual, player-controlled gameplay with an ammunition-fed turret near the static target at (-6, 0, -6). Verify that the target health label and turret HUD update while rounds are physically delivered and the dummy is defeated in the running main world. Do not count this as proof of moving zombies, projectile simulation, enemy attack AI or line-of-sight.


### Follow-up acceptance: manual factory-powered combat

On **2026-11-01**, the developer supplied a screenshot from regular gameplay showing the ammunition-fed turret and its physical conveyor chain beside the stationary target whose health label reads **TARGET DEFEATED**. This confirms the first visual combat victory in the playable main world. The screenshot does not display the turret's shot counters; those 3-hit/30-HP values were separately confirmed by the **11/11** live-world integration regression.

**Next step:** Add an isolated moving-enemy prototype. Keep the original stationary target and production systems unchanged. The first movement prototype may approach a selected player-built structure directly on the X/Z plane, but collision avoidance, pathfinding, building attacks, enemy spawning and wave logic remain separate unimplemented features.


### New isolated milestone: moving-zombie foundation (not yet tested locally)

The first moving enemy is deliberately **separate** from `prototype_zombie_target.tscn`, which remains the accepted stationary reference in the main playable scene.

- `ZombieApproachComponent` finds the nearest real `player_built` structure with a `BuildingRuntime`, excluding construction previews and conveyors.
- Walks in the X/Z plane at a temporary **2 units/second** and stops **1.5 units** from the structure center; large time steps are clamped to prevent overshoot.
- Reacquires a valid target after the previous structure is removed. Stops permanently when its `CombatHealthComponent` reaches zero.
- `scenes/enemies/prototype_moving_zombie.tscn` is a separate green placeholder with the existing combat health and label implementation.
- `tests/prototype_moving_zombie_test.tscn` contains nine isolated checks for idle behavior, excluding ghosts and conveyors, nearest structure selection, displacement and stopping distance, reacquisition after deletion, existing ammo-fed turret hits/cooldown, and immobility when defeated.

**Not integrated in Main yet.** The movement code uses straight-line motion only; no NavigationAgent3D, collision avoidance, body-to-body collisions, enemy attacks, structure health, spawners or waves have been implemented. Run the nine-case F6 regression in Godot 4.6.2 before adding enemy motion to the live factory.


### Moving-zombie foundation accepted; live-world integration pending

The developer ran `res://tests/prototype_moving_zombie_test.tscn` in Godot 4.6.2 and supplied Output confirming **all 9/9 tests passed**. This verifies no-target idle behavior, excluding ghosts and conveyors, approaching and stopping 1.5 units from the nearest actual building, reacquisition when a structure is deleted, compatible ammo-fed turret damage/cooldown, and no motion after death.

**Next implementation checkpoint:** The separate `PrototypeMovingZombie` is now instanced in `scenes/core/main.tscn` at **(8, 0, -7)**. The previously validated stationary `PrototypeZombieTarget` remains at **(-6, 0, -6)**. The new `res://tests/live_moving_zombie_integration_test.tscn` uses the actual Main scene and tests the absence of target/ignored ghosts, player-built storage approach, stopping distance, switching to an actual turret after storage removal, physical ammo delivery, three real hits, target death, HUD statistics, and conveyor cleanup.

**Status:** This main-world change has been committed and repository-reviewed, but its 12-case integration regression has **not** yet run in local Godot. Do not claim it passes until the user's F6 confirmation. Live gameplay movement also still requires manual observation. This remains direct X/Z motion, with no obstacle avoidance, NavigationAgent3D, structure damage, automatic spawning, or wave systems.


### Main-scene moving-zombie integration accepted — 12/12 checks

On **2026-11-01**, the developer ran `res://tests/live_moving_zombie_integration_test.tscn` in Godot 4.6.2 and supplied Output confirming **ALL 12 LIVE MOVING ZOMBIE INTEGRATION TESTS PASSED**.

The test exercised the real Main scene: one moving zombie coexists with the original stationary target; with no player structures it remains still; construction preview ghosts and loose conveyors are ignored; the enemy travels 2 world units per second toward player-built Storage and stops 1.5 units from it; after Storage removal it acquires a placed turret; without ammunition the turret cannot fire; after physical conveyor connection three delivered Prototype Rounds produce three guarded hits, defeat the moving zombie, and preserve the static target. Dead enemies cease motion, and the turret's combat HUD and conveyor cleanup remain correct.

**Next acceptance gate:** Manually launch the actual main game with F5, place a structure near the moving enemy at (8, 0, -7), and verify it visually approaches and stops. A later manual pass should supply a turret and observe the moving enemy's defeated state. This is still straight-line X/Z motion without navigation, obstacle avoidance, structure attacks, automatic waves, or projectiles.


### Manual movement accepted — zombie approaches player-built Storage

On **2026-11-01**, the developer supplied a gameplay screenshot showing the green **PrototypeMovingZombie** beside a placed Test Storage building, with its label **TARGET HP: 30 / 30**. The previously validated red stationary target is visible separately. The developer confirmed the zombie approached and stopped at Storage during live gameplay.

This establishes manual visual acceptance of the moving-enemy approach and stop behavior. The exact 1.5-unit stopping distance is supported by earlier isolated and main-scene automated tests, rather than being measured from this screenshot. The moving zombie has not yet been visibly defeated in a live, player-controlled run.

**Next validation:** In a fresh gameplay run or with the existing factory, place an ammunition-fed turret within 7 world units of the moving zombie and verify three hits, 30-to-0 HP, the **TARGET DEFEATED** label and no more firing at the defeated zombie. Keep the static target separate from that engagement. Do not infer navigation, zombie attacks, projectile simulation or building damage.


---

## 2026-11-01 — Moving-Zombie Combat Accepted; Isolated Structure-Damage Foundation

### Accepted normal gameplay

The developer supplied a normal-gameplay screenshot showing both the previously validated stationary target and the moving zombie with separate **TARGET DEFEATED** labels. The developer confirmed that the green moving zombie immediately approached a newly placed turret, which then defeated it using factory-supplied ammunition. This accepts the first moving-hostile victory in regular gameplay. The image does not show live shot counts; existing deterministic regressions separately verified three real 10-damage hits per 30-HP target.

### Building health and melee implementation (not yet locally validated)

- `BuildingHealthComponent` introduces 100 default HP, actual-damage accounting, a single zero-HP signal, and guarded damage application. **At zero HP, the building is kept in the scene**: no inventory, resources, or conveyor connections are silently deleted.
- `ZombieMeleeComponent` allows one attack per configured interval (temporary 10 damage/1 second) only when a living zombie is within physical melee range and `ZombieApproachComponent` reports `At Structure`. It requires an explicit health-enabled building, ignores previews, conveyors, invalid targets and cooldown violations, and stops attacking when the zombie is defeated.
- `ZombieApproachComponent` now ignores a health-enabled building whose health has reached zero and reacquires another valid structure. Buildings without the health component retain their existing movement-target behavior for backward compatibility, but are not damageable by the new melee component.
- `tests/zombie_building_melee_test.tscn` has **12 isolated checks** covering no-target behavior, undamageable buildings, previews and conveyor filtering, valid structure detection, approaching/range rules, damage, cooldown, exact zero-HP clamping, stored-ammunition preservation, retargeting and dead-zombie attack prevention.

**Safety/integration boundary:** Neither `scenes/enemies/prototype_moving_zombie.tscn` nor any player-buildable factory scene has had melee or BuildingHealth attached. Existing main-game behavior should remain non-destructive while the 12-case regression awaits local F6 validation. Player-facing building HP, combat destruction, salvage/recovery, obstacle navigation, zombie spawning and waves are still future increments.


### Building-health foundation accepted — 12/12 local Godot checks

The developer ran `res://tests/zombie_building_melee_test.tscn` in Godot 4.6.2 and provided output confirming **ALL 12 ISOLATED BUILDING HEALTH AND MELEE TESTS PASSED**. Tested exact melee distance and cooldown, one hit per interval, invalid targets, 25-HP overkill clamping, three saved ammunition units remaining inside a zero-HP storage unit, retargeting a healthy structure and zombie attack/movement stopping after death.

### Step 09.16 — Factory-wide durability and shared HUD (committed, unverified)

- Added `BuildingHealthComponent` directly to the eight player-buildable **structure** scenes: Extractor, Test Large, Storage, Smelter, Merger, Splitter, Ammunition Press and Defensive Turret. Each starts at 100 HP. Ordinary conveyor **segments** are not building-health targets and retain their current cargo logic.
- Production Debug HUD now appends a standardized **BUILDING DURABILITY** block with current/max HP and Intact/Disabled status after the existing building-specific display. This preserves all production, inventory, magazine and recipe information.
- Adapted `tests/zombie_building_melee_test.gd` so its special legacy **no-health** fixture explicitly removes the new default component, preserving that test's safety invariant, while its damageable fixtures edit the existing component rather than creating duplicate children.
- Added `tests/building_health_integration_test.tscn`, an **11-case** acceptance test against all nine construction slots. It verifies one health component per structure, no health on belts, shared HUD output, stored cargo and connected-port survival at zero HP, zombies ignoring disabled Storage, and turret magazine/demolition safety.

**Important:** Zero-HP status currently marks a structure as disabled for enemy targeting but does **not** yet automatically halt processing or transport. No building is destroyed, salvaged or removed, and no stored resources disappear. The live moving zombie still has no `ZombieMeleeComponent` attached. This integration must pass local Godot validation before real zombie attacks are enabled.


### Step 09.16A — Factory-wide durability integration accepted

On **2026-11-01**, the developer ran `res://tests/building_health_integration_test.tscn` locally in Godot 4.6.2 and supplied output confirming **ALL 11 BUILDING HEALTH INTEGRATION TESTS PASSED**.

Verified all nine build slots remain registered; exactly eight non-belt structures each have one initialized 100-HP component; ordinary conveyors do not gain building HP; all eight building Debug HUD views show durability; Storage inventory and physical output port references persist through damage and zero HP; zombies skip disabled Storage; a loaded turret keeps its ammunition, HUD and demolition safety; construction ghosts are not targeted.

The teardown message `Extractor has no resource node` occurs after the tests and does not indicate an assertion failure.

**Next regression gate:** Re-run `res://tests/zombie_building_melee_test.tscn` (12 checks) with its modified no-health fixture now that the regular Storage scene includes health. This new re-run is pending; do not enable `ZombieMeleeComponent` on the live moving zombie until confirmed. Zero HP currently preserves inventory and links but does not automatically halt production or implement destruction, repair, or salvage.


### Step 09.16B — Adjusted isolated melee re-test accepted (12/12)

The developer ran the updated `res://tests/zombie_building_melee_test.tscn` after all eight non-belt structures gained their 100-HP component. The Godot 4.6.2 screenshot shows **ALL 12 ISOLATED BUILDING HEALTH AND MELEE TESTS PASSED**, confirming the no-health fixture, melee distance and cooldown, damage clamp, resource preservation, retargeting and prevention of further attacks from defeated zombies remain correct.

### Step 09.17 — Live structure attacks integrated (local acceptance pending)

- Attached `ZombieMeleeComponent` to `scenes/enemies/prototype_moving_zombie.tscn` with an exported NodePath to its existing MovementComponent. The live moving zombie now has **10 melee damage**, a **1.0-second** attack interval, and a **1.55-world-unit** attack range.
- The component only deals damage to the currently approached, intact `BuildingHealthComponent` target. Its attack routine never deletes the building, inventory, resource items or physical conveyors.
- Updated the historical isolated melee test to reuse the scene's built-in melee component instead of injecting a duplicate.
- Updated `prototype_moving_zombie_test.gd` and `live_moving_zombie_integration_test.gd` to disable the new melee process during their deterministic movement-only assertions, preserving their original scopes.
- Added `tests/live_zombie_melee_integration_test.tscn` with **12 Main-scene integration checks**. It tests the wired live zombie, empty/ghost targeting, stored ammo with a connected belt, range gating, first hit, cooldown, 10 exact hits taking 100-HP Storage to zero, no inventory or port loss, disabled-building retargeting, attacking a second structure, defeated-zombie immobility and health HUD updates.

**Not yet locally tested:** The new 12-case Main-scene zombie melee integration. Before accepting this gameplay milestone, run the F6 regression, then manually verify health decreasing on a placed Storage building. A zero-HP building still remains in place and may continue production/transport; production shutdown, damage visuals, destruction, repairs, salvage, obstacle pathfinding and wave spawning remain future work.


### Step 09.17A — Live zombie melee integration regression accepted (12/12)

The developer ran `res://tests/live_zombie_melee_integration_test.tscn` in Godot 4.6.2 and supplied Output confirming **ALL 12 LIVE ZOMBIE MELEE INTEGRATION TESTS PASSED**.

The real Main-scene zombie was verified to carry a wired melee component. The test confirmed no attacks without a structure, rejection of construction ghosts and conveyor belts, live Storage at 100 HP retaining seven Prototype Rounds and a connected belt, no premature hit outside range, 10 damage on reaching Storage, cooldown blocking extra hits, ten hits reaching exactly zero HP, inventory and port survival after defeat, target reassignment to a second intact building, and complete cessation of zombie movement and attacking after its own defeat.

**Acceptance boundary:** Integration regression is passed; manual player-controlled F5 gameplay validation remains pending. The next check is to build and select Storage near the green moving zombie at (8, 0, -7), confirm the Debug HUD durability decreases by 10 HP per melee hit, and observe the structure remaining present at zero HP. Do not require a turret for this defensive-loss test, and do not claim production shutdown, repair, salvage, pathfinding or wave spawning from it.


### Step 09.17B — Live player-controlled zombie attack accepted

On **2026-11-01**, the developer reported placing a Test Extractor near the moving zombie in the actual F5 main game. The zombie attacked until the Extractor reached **HP: 0 / 100**, while the building remained visibly present. The selected Extractor's Production Debug HUD showed **Status: Disabled** in the Building Durability section and **Stored Test Ore: 19 (19 / 50 capacity)**. This is visual confirmation of non-destructive health depletion for the Extractor. The prior **12/12** Main-scene melee regression specifically validated Storage inventory and physical port preservation at zero HP.

**Important observed gap:** The same screenshot still displayed `Status: Extracting` under the Extractor production section, despite durability being disabled. Operational shutdown at zero health is **not implemented yet**; the screenshot alone cannot establish whether additional ore was produced after reaching zero. The progress bar is not a health indicator.

**Next design/implementation milestone:** Introduce health-aware operation gates for extraction, recipe processing, ammunition-fed turret firing, and building conveyor transfers. A disabled structure should stop operating without destroying resources, changing physical connections, or resetting partial progress. Design repair/reactivation separately and verify disabled behavior with isolated regression scenes before changing live systems. Automatic physical destruction, cargo salvage, repair interfaces, navigation, and wave spawning remain out of scope.


### Game-design correction — Real structures and conveyors must be destructible

The developer clarified that the present `Disabled` status at zero HP is **only a testing safeguard**. It must not become the final gameplay outcome. In the playable game, zombies should be able to destroy **both factory buildings and conveyor segments**.

**Confirmed requirement:** A building at zero HP leaves normal operation and is destroyed through a controlled lifecycle; belts can be separately damaged and severed. Destroying a single building or conveyor does not erase the entire connected factory network. The game should show placeholder wreckage/debris until final art exists.

**Engineering gates before enabling physical removal:** Explicitly disconnect ports, resolve machine inventories and cargo on destroyed belts without silent duplication, define recoverable drops/salvage/loss, verify neighbor belts remain intact, and handle target reassignment and blocked logistics safely. Existing 0-HP preservation tests remain regression fixtures for the transition, not a statement of the intended final destruction rules. Optional repair of damaged structures and rebuild/salvage of destroyed ones are separate design decisions.

`GAME_DESIGN.md` and `ROADMAP.md` now document this requirement. No gameplay destruction code has been changed as part of this design clarification.


### Upcoming UI milestone — Player-configurable build hotbar

The developer requested that, after real building and conveyor destruction is implemented, the player should be able to open a menu of **unlocked** buildings and assign any of them to any number key. Example: **Defensive Turret → 1**, **Storage → 9**.

The planned Build Catalog and nine-slot customizable hotbar are documented in `GAME_DESIGN.md` and Phase **1G** of `ROADMAP.md`. Unlocked buildings can be assigned, reordered or swapped without affecting the existing factory. Preferences should persist across sessions by stable `building_id` rather than the `buildable_definitions` array index. The future refactor must specifically eliminate the `selected_building_index == 4` Conveyor Belt logic before allowing arbitrary slot mappings, preserving the current belt placement and snapping regressions.

**Status:** Design captured only. No UI, hotkey, progression, or save files have been modified. The immediate priority remains destruction of buildings and conveyor segments with safe cargo handling.


---

## Step 09.18A — Destruction Cargo Recovery Preflight (2026-11-01)

**Status: new isolated code committed, Godot validation pending.** No live factory destruction is enabled.

- Added `scripts/components/destruction_cargo_recovery.gd` (`DestructionCargoRecovery`), a reusable inventory recovery helper that collects all descendant `InventoryComponent` instances exactly once, rejecting invalid item identities, missing sources, same-tree recovery targets, and recovery caches with insufficient total space.
- Once preflight succeeds, resources move via the **existing** `InventoryComponent.transfer_to()` logic. This is item-generic (ore, ingots, ammunition and future `ItemDefinition` resources), and repeated calls on an emptied source are idempotent.
- Added `res://tests/destruction_cargo_recovery_test.tscn` (12 checks). It covers capacity refusal without partial transfer, 7 ore + 4 rounds from Storage, recovery from the 2-buffer Ammunition Press, recovery from a cargo-bearing belt, correct local port/belt disconnection through the existing `_exit_tree` path, keeping neighboring belt cargo intact, and a final accounting of **19/19** recoverable units.
- For this checkpoint, the recovery destination is an independent in-memory `InventoryComponent`, **not** yet a visible or pickable salvage crate. The test manually invokes removal only after escrow succeeds. Automatic damage, health-triggered world deletion, wreckage, belt health and enemy belt targeting remain unchanged.

**Design reminder:** The final game destroys buildings and damaged conveyor segments. The temporary zero-HP Disabled state is a test safeguard only. First establish 100% recoverable test escrow (an accounting baseline); tune salvage/loss rates later when dedicated world drops exist. Do not expose player demolition or combat deletion through this new helper until Godot has validated it.


### Step 09.18A — Destruction cargo regression accepted (12/12)

The developer ran `res://tests/destruction_cargo_recovery_test.tscn` in Godot 4.6.2 and supplied output confirming **ALL 12 DESTRUCTION CARGO RECOVERY TESTS PASSED**. After correcting the intentionally malformed inventory-key preflight in `destruction_cargo_recovery.gd`, both source and destination accounting passed, including all **19/19** ore, ingot and ammunition units recovered without duplication. The linked-belt test also confirmed surviving neighbors retain cargo and detach only the removed segment.

### Step 09.18B — Controlled destruction transaction (code committed, Godot test pending)

- Added `scripts/components/destruction_transaction.gd` (`DestructionTransaction`). It is a standalone helper **not wired into live zombie damage or Build Mode**. It accepts only real `player_built` buildings with `BuildingRuntime` or a `ConveyorSegment`; rejects preview ghosts, arbitrary nodes, queued sources and unattached recovery caches.
- Its `try_destroy()` first checks complete salvage capacity and moves all source-owned inventory into a separately live `InventoryComponent`. On success it disables source processing, explicitly severs the source's reciprocal building-port or belt links, then queues **only that source** for deletion. Failed preflight leaves the structure and physical connections untouched.
- Added `tests/controlled_destruction_transaction_test.tscn` with **12 checks** for rejection cases, insufficient recovery capacity, warehouse-output and two-belt linking, source removal, immediate port disconnection, duplicate removal refusal, neighbor cargo preservation, separately destroying cargo-bearing belts, multi-buffer manufacturer recovery, invalid key refusal and exact **19-unit** final conservation.

**Current boundary:** This is the first test-only transaction capable of genuinely queueing buildings and belts for removal. Live damage-to-destruction, enemy conveyor targeting, wreckage visuals and actual in-world salvage cache/pickups remain separate milestones. The 12-case scene requires an F6 pass before any live behavior is changed.


### Step 09.18B — Controlled destruction accepted (12/12)

The developer ran `res://tests/controlled_destruction_transaction_test.tscn` in local Godot 4.6.2, confirming **ALL 12 CONTROLLED DESTRUCTION TRANSACTION TESTS PASSED**. Validated invalid/preview rejection, insufficient salvage capacity preventing removal, immediate local port/belt disconnection, queued removal, duplicate refusal, neighboring belt cargo preservation, independent belt destruction, two-buffer Ammunition Press recovery, invalid item refusal, and **19/19** item accounting.

### Step 09.18C — Main-world salvage placeholders (committed, F6 test pending)

- Created `WorldSalvageCache` (`scripts/components/world_salvage_cache.gd`) and `scenes/logistics/world_salvage_cache.tscn`, a non-colliding placeholder wreckage mesh with a readable count and a dedicated unlimited `InventoryComponent`. Empty sites read `WRECKAGE`; salvaged sites read `SALVAGE: N`. The object is in `salvage_caches`, **not** `player_built`.
- Added `WorldDestructionService` (`scripts/components/world_destruction_service.gd`) as a Main scene child. Its `try_destroy_with_salvage(source)` creates the cache as an independent sibling at the affected site, uses the previously tested `DestructionTransaction.try_destroy()`, and retains its cargo even after the source is freed. Failed transactions remove the empty placeholder immediately rather than leaving phantom salvage.
- New `res://tests/world_salvage_destruction_test.tscn` uses the real Main scene and checks 12 cases for valid targets, junk/ghost exclusion, stocked storage with two connected belts, accurate 7-item salvage at a destroyed site, repeated deletion refusal, invalid manufacturer inventory refusal, two-buffer manufacturer salvage, individual adjacent belt destruction, empty wreckage, summed **15-item** conservation across five independent surviving world caches, and enemy/world safety.

**Validation boundary:** Repository checks pending completion; **no local F6 run has passed yet**. Main has the inactive service but live zombies do not invoke it on zero HP. Salvage is a runtime in-world holder and visual placeholder, **not yet player-pickable or persisted to disk**, and 100% recovery remains prototype balancing. Conveyor HP, zombie belt targeting, damage-triggered removal, special wreckage FX and player salvage collection will be handled in later checkpoints.


### Step 09.18C — Main-world salvage regression accepted (12/12)

The developer supplied Godot 4.6.2 output from `res://tests/world_salvage_destruction_test.tscn`: **ALL 12 MAIN-WORLD SALVAGE DESTRUCTION TESTS PASSED**. Validated five independent world-owned wreckage caches, empty wreckage and two cargo-bearing belts, rejection of duplicate/invalid deletion, uninterrupted surviving world nodes, and conservation of **15/15** initial item units after source removal.

### Step 09.18D — Health-triggered Main-world building destruction (committed, F6 test pending)

- `BuildingHealthComponent._ready()` now connects the existing `health_depleted` signal to the owning Main scene's `WorldDestructionService`, when present. Preview ghosts and independent isolated scenes remain excluded. No automatic removal is implemented for enemy targets or belts here.
- `WorldDestructionService.destroy_on_zero_hp` defaults to **true** in Main. When health reaches zero, the service invokes its already-tested inventory recovery, reciprocal port cleanup, stopped-processing state and single-source queue for deletion. A world-owned cache with recovered items remains at the original site. An unsuccessful salvage transaction **never deletes source data**; it leaves a 0-HP structure in place and increments `failed_health_destructions` for later recovery/retry.
- The service clears any `WorldInteraction` selection and `ProductionDebugHUD` selection referencing a successfully destroyed structure before frame-end freeing. Movement/target selection skips queued or dead structures and should reacquire intact targets.
- The historical `building_health_integration_test.gd` (11 checks) and `live_zombie_melee_integration_test.gd` (12 checks) explicitly switch off automatic world destruction so their original zero-health-disabled safety contracts can still be tested independently.
- New `res://tests/live_zombie_destruction_test.tscn` (**12 checks**, local Godot run pending) tests the Main scene, preview protection, real Storage with stocked adjacent belts, nine nonlethal hits, tenth-hit removal, salvage and HUD cleanup, local disconnections, surviving conveyor cargo, zombie reacquisition of another building, non-melee health depletion triggering the same path, invalid-inventory rollback and explicit recovery retry. Expected accounting: **12 recovered units across three wreckage caches + two surviving belt units**.

**Validation boundary:** The code is committed but live F5 gameplay must wait until the new F6 regression passes. The final game also requires damageable belts, zombie belt targeting, salvage pickup/persistence, and improved wreckage presentation; none is claimed complete.


### Step 09.18D — Zombie-triggered building destruction accepted (12/12)

On **2026-11-02**, the developer ran `res://tests/live_zombie_destruction_test.tscn` in Godot 4.6.2. All **12/12** integration checks passed (PASS A–L; screenshot provided). The tested Main scene automatically listened for building health depletion. A live moving zombie struck a selected, stocked Storage structure: its tenth hit took HP to zero and queued actual deletion. The world-owned salvage held seven Storage items and the selection/HUD cleared; both neighboring conveyor belts stayed intact and retained their cargo. The zombie subsequently targeted and damaged another healthy building, whose depletion through a separate damage call used the same destruction transaction. A deliberately malformed inventory failed salvage safely, leaving a 0-HP structure available for later retry; the recovery was then completed. End-of-test accounting: **12 units stored across three wreckage caches plus two units on the surviving belts**.

**Next acceptance gate:** Player-controlled **F5** test, not yet confirmed. Build a real Extractor or Storage near the prototype moving zombie (avoid placing a defensive turret nearby), observe the final 0-HP attack physically removing the structure, verify wreckage remains with the correct `WRECKAGE` or `SALVAGE: N` placeholder, and ensure the selection HUD clears cleanly.

**Still pending:** zombie damage to conveyor segments, isolated belt health/destruction tests, recoverable player pickups, save/load of salvage, production-chain hardening, final wreckage FX, and progression toward the customizable build catalog/hotbar.


### Step 09.18E — Zombie destruction verified in real gameplay

On **2026-11-02**, the developer ran regular F5 gameplay and showed a green moving zombie next to a visible **WRECKAGE** placeholder where its attacked player structure had been. The previous structure was no longer visible; the Production Debug HUD was not showing it. This is the accepted player-controlled destruction/wreckage milestone. The screenshot shows an **empty wreckage** placeholder; stored material recovery and preservation of neighboring conveyors were verified separately by the passing 12-case regressions.

### Step 09.18F1 — Conveyor durability across all belt geometries (committed; local validation pending)

- Added `scripts/components/conveyor_health_component.gd` (`ConveyorHealthComponent`). Every belt starts at **50 HP**, accepts clamped positive damage, emits a single depletion signal at zero, and ignores repeated hits after depletion. It does **not** itself remove a belt or trigger attacks yet.
- Attached the component to all three physical belt scene shapes used by `ConveyorPieceSelector`: `conveyor_straight.tscn`, `conveyor_corner.tscn` (right), and `conveyor_corner_left.tscn`. Both corner scenes now include an independent one-item `CargoInventory` for safe future salvage/recovery. These added corner buffers do **not** add transport timers or alter the established belt-transfer mechanism.
- Added `res://tests/conveyor_durability_foundation_test.tscn` (**12 checks pending local F6 validation**): Main scene compatibility, straight/right/left durability and buffer counts, ghost safety, physically attached Storage and two straight belts, invalid/partial/overkill damage, exactly-once depletion signaling, no automatic removal, malformed cargo fail-closed behavior, explicit zero-HP straight-belt destruction and neighbor preservation, cargo-bearing right-corner and empty left-corner salvage, and final accounting of two recovered units plus one live neighboring belt unit.
- **Scope boundary:** Automatic destruction on belt HP depletion and zombie targeting/melee against belts are NOT enabled in Step 09.18F1. Existing player demolition checks remain unchanged. The next checkpoint will wire belt targeting and guarded destruction only after the separate health regression passes.


### Step 09.18F1 — All three conveyor durability variants accepted (12/12)

The developer supplied local Godot 4.6.2 output for `res://tests/conveyor_durability_foundation_test.tscn` confirming **ALL 12 CONVEYOR DURABILITY FOUNDATION TESTS PASSED**. Straight and left/right corner belts each initialized at 50 HP with one cargo slot. The test verified overkill clamping, a single depletion event, construction-preview safety, no automatic deletion in its isolated fixture, existing Storage/belt connections, invalid cargo refusal, three explicit destruction transactions and conserved item counts (two units in salvage plus one on a surviving belt).

### Step 09.18F2 — Zombie-targeted conveyor destruction (code committed; F6 pending)

- `ZombieApproachComponent` now supports exported `target_conveyors` (default false for standalone historical regressions, explicitly true in `prototype_moving_zombie.tscn`). Valid conveyor targets require `player_built`, no preview/deletion, and an intact `ConveyorHealthComponent`. Healthy buildings remain eligible; the nearest valid target wins. Depleted belts are skipped when retargeting.
- `ZombieMeleeComponent` now routes existing 10-damage, one-second-cooldown melee attacks through either `BuildingHealthComponent` or `ConveyorHealthComponent`, depending on the selected target. Building-only tests retain their original safeguards.
- `ConveyorHealthComponent` connects `health_depleted` to the owning Main-world service, when present. `WorldDestructionService.destroy_conveyors_on_zero_hp` defaults true in Main and triggers the already-tested lossless salvage transaction, local port and belt disconnections, source removal, wreckage, and selection cleanup. If recovery fails, the belt is not removed and can be recovered explicitly later.
- Existing movement and building-melee regression fixtures explicitly set `movement.target_conveyors = false`; the historical F1 durability suite sets `service.destroy_conveyors_on_zero_hp = false` to preserve its original manual-deletion checks.
- New `res://tests/live_zombie_conveyor_destruction_test.tscn` (**12 assertions groups, pending local Godot F6**) exercises Main-world live zombie belt preference, preview exclusion, physical Storage→belt→belt connections, melee range and cooldown, a fifth 10-HP hit destroying an occupied straight belt, local disconnection and neighboring cargo preservation, retargeting and damaging another straight belt, invalid cargo fail-closed recovery with manual retry, and destroying both corner shapes with salvage conservation.

**Validation boundary:** Code has been committed but Godot and live player-controlled F5 gameplay have not yet validated the new belt-targeting behavior. Existing wreckage remains an uncollectable runtime placeholder. Do not regard the customizable build hotbar as implemented; it remains planned after the destruction milestone.


### Step 09.18F2 — Diagonal belt arrival regression fix (pending local re-test)

The first local F6 run of `res://tests/live_zombie_conveyor_destruction_test.tscn` stopped at the PASS I retargeting arrival assertion (line 166 in the initial revision): a moving zombie had selected the second intact conveyor after destroying its upstream neighbor, but `movement_status` had not yet become `At Structure`. This occurred **after** the test's initial destruction and salvage checks. Root cause is suspected floating-point drift at the diagonal 1.5-unit stopping boundary, not proven until local re-test.

Updated `ZombieApproachComponent` to treat movement within **0.001 world units** above stopping distance as arrived; the move distance and combat range are unchanged. Updated PASS I to allow up to four normal 0.1-second movement ticks to settle and to print zombie position, selected target and movement status if the assertion still fails. No changes were made to inventory transfer, source deletion, damage, or belt geometry. The full 12-case run and relevant historical movement regressions remain **unverified after this correction**.


### Step 09.18F2 — Live zombie conveyor destruction regression accepted (12/12)

On **2026-11-02**, the developer reran `res://tests/live_zombie_conveyor_destruction_test.tscn` in Godot 4.6.2 and provided output confirming **ALL 12 LIVE ZOMBIE CONVEYOR DESTRUCTION TESTS PASSED** (PASS A–L). The first run had stopped on the second-belt arrival assertion in PASS I; after adding a **0.001-unit arrival tolerance** and bounded diagnostic settling to the regression, the entire suite passed.

The accepted run validated: Main-world belt targeting and guarded destruction; construction-preview exclusion; connected Storage → first belt → second belt with cargo; approach/range gating and 10-HP melee; one-second attack cooldown; fifth hit destroying a 50-HP straight belt; local connection severing and preservation of Storage/neighbor belt stock; retargeting the next straight belt; invalid cargo blocking deletion until recovery retry; and zombie-triggered removal of a loaded right-corner and empty left-corner belt. Final item accounting: **one salvaged ore, one salvaged ingot, one salvaged ammunition round, plus three ore still stored in the surviving Storage**.

**Remaining acceptance:** Player-controlled F5 demonstration of conveyor destruction, wreckage, and intact adjacent conveyor pieces. After F5, rerun the relevant historical movement, melee, building destruction, and conveyor logistics regressions because enemy targeting and arrival tolerance changed. Do not treat salvage collection, save/load, or the planned customizable build catalog/hotbar as complete.


### Step 09.18F3 — Conveyor destruction observed in playable F5 world

On **2026-11-02**, the developer showed two distinct **WRECKAGE** placeholders near the moving green zombie in regular gameplay, confirming player-placed conveyor destruction now produces visible wreckage. The Production Debug HUD said **No object selected**, consistent with the selected destroyed segment being removed. Cargo preservation and intact neighboring belt behavior had previously passed the 12-case integration regression, but cannot be inferred independently from this screenshot.

**User-reported UI gap:** Clicking an intact conveyor did not reveal its health. Root cause in `ProductionDebugHUD._refresh_display()`: it only handled resource-node and BuildingRuntime branches; `ConveyorSegment` objects have neither, so their HP was not displayed. The empty-selection label after destruction is expected.

### Step 09.18F4 — Conveyor durability, cargo and connection HUD (code committed; F6 pending)

- `scripts/production_debug_hud.gd` now checks for `ConveyorSegment` before resource nodes and buildings. The shared HUD renders the selected belt's identity, **HP current / maximum**, **Intact / Destroyed**, actual `CargoInventory` count and item display names, plus physical input/output link status (building port, previous/next conveyor, disconnected).
- The change is read-only; no conveyor transport, collision, melee, durability, or damage/destruction code was modified. Existing non-conveyor HUD displays keep their original paths. The activity progress bar remains hidden for conveyors.
- Added `res://tests/conveyor_health_hud_test.tscn` (**12 checks; local Godot 4.6.2 verification pending**), covering WorldInteraction selection, all three belt shapes, dynamic HP and cargo changes, building/neighbor belt links, HUD progress visibility, automatic clearing of selection upon damage-triggered belt destruction, salvage accounting, and reselecting the intact next segment.

**Next:** Run the new HUD test scene in Godot, fix any resulting errors, then verify by F5 selecting an intact belt and watching its displayed HP change while the zombie attacks. Before closing the destruction milestone, rerun important legacy logistics/movement/combat regressions. The customizable Build Catalog/hotbar remains the next planned major UI feature.


### Step 09.18F4 — Conveyor health and cargo HUD accepted (12/12)

On **2026-11-02**, the developer ran `res://tests/conveyor_health_hud_test.tscn` in Godot 4.6.2 and supplied output confirming **ALL 12 CONVEYOR HEALTH HUD TESTS PASSED** (PASS A–L). The local run verified a clean initial HUD, selection and 50/50-HP display across straight and both corner segments, changes to displayed HP after damage, live inventory quantities and item names, connected building/downstream/previous-belt input-output labels, hidden production progress for belts, selected-belt removal clearing HUD/selection, cargo preserved in wreckage, and reselecting the surviving downstream belt.

**Next acceptance:** In regular F5 gameplay, select an intact belt with a zombie approaching and verify the Production Debug HUD changes from **HP: 50 / 50** through 10-HP decrements, then clears when that belt is destroyed. This manual check has **not yet been provided**. Afterward, run a final historical regression set for movement, melee, building destruction, conveyor logistics and cargo conservation, including the new arrival tolerance and both types of damageable targets. Preserve the planned unlocked-building catalog and customizable quickbar as the next major UI phase once the destruction milestone is accepted.


### Step 09.18F5 — Conveyor durability HUD confirmed in player-controlled F5 gameplay

On **2026-11-02**, the developer submitted a screenshot of the actual F5 game showing a **yellow-selected intact conveyor** next to the moving green zombie. The Production Debug HUD showed **Conveyor Durability: HP 40 / 50, Status: Intact**, **Cargo: Empty, Capacity: 0 / 1**, and **Input: Disconnected, Output: Disconnected**. This confirms the new selected-belt HUD displays a partially damaged live conveyor; the missing-health-display issue is resolved. The screenshot also shows multiple earlier wreckage caches from destroyed conveyors. Automatic selection/HUD clearing on final destruction is separately covered by the passing **12/12** HUD regression and prior F5 wreckage observation.

Minor future UI polish: selected belt's runtime node name currently appears as a Godot-generated label such as `@Node3D@10`; show an intuitive building/belt type or user-facing name in a later UI pass, without changing the working combat or cargo flows.

### Step 09.18 — Final historical regression gates (planned)

Before calling full building-and-conveyor destruction complete and moving into the **customizable Build Catalog/hotbar**, rerun representative Godot scenes in three manageable rounds:

1. **Movement and combat** — `prototype_moving_zombie_test.tscn`, `live_moving_zombie_integration_test.tscn`, `zombie_building_melee_test.tscn`, `live_zombie_melee_integration_test.tscn`. These must remain compatible with the new `target_conveyors` flag and 0.001-unit arrival tolerance.
2. **Factory/physical logistics** — `conveyor_physical_only_conservation_test.tscn`, `ammunition_press_build_mode_test.tscn`, and `defensive_turret_build_mode_test.tscn` (additional belt connection tests as needed), guarding item conservation and core construction.
3. **Destructive recovery** — `live_zombie_destruction_test.tscn`, `controlled_destruction_transaction_test.tscn`, `world_salvage_destruction_test.tscn`, `live_zombie_conveyor_destruction_test.tscn`. Existing focused conveyor HUD and 50-HP durability suites already passed and can be revisited if any regression fails.

**Status:** The new F5 HUD demonstration is accepted. These historical reruns have **not yet been confirmed** after the latest combat/UI changes. Do not mark regression rounds as passed until local Godot results are supplied.


### Step 09.18 — Final regression Round 1 accepted, Round 2 pending

The developer confirmed that all **four movement and combat test suites passed locally in Godot 4.6.2** on 2026-11-02. These covered the prototype moving zombie, main-world moving zombie, isolated building melee and main-world melee integration. The existing building-only test fixtures therefore remain compatible with recent enemy conveyor targeting and movement-arrival adjustments.

**Next gate — Round 2 factory and physical logistics:** Run the three existing scenes for physical-only resource conservation (**9 checks**), ammunition production building placement (**9 checks**), and defensive building placement (**12 checks**), for a total of **30 checks**. These round-two reruns are pending; do not mark them passed without local results. Round 3 will cover destruction and salvage recovery. No gameplay code was changed for this documentation checkpoint.


### Step 09.18 — Final regression Round 2 accepted (30/30)

On **2026-11-02**, the developer confirmed that all three factory/logistics regression suites passed again in local Godot 4.6.2. `conveyor_physical_only_conservation_test.tscn` passed **9/9**, `ammunition_press_build_mode_test.tscn` passed **9/9**, and `defensive_turret_build_mode_test.tscn` passed **12/12**, totaling **30/30** checks. Physical resource accounting, ammunition-press build logic and turret build/connection safeguards therefore remain compatible with the new zombie building/conveyor destruction changes.

### Step 09.18 — Final regression Round 3 (pending)

The final destruction and salvage verification uses four existing Godot F6 scenes, each containing 12 checks (**48 checks total**): `live_zombie_destruction_test.tscn`, `controlled_destruction_transaction_test.tscn`, `world_salvage_destruction_test.tscn`, and `live_zombie_conveyor_destruction_test.tscn`.

Confirm lossless building/belt destruction, nearby conveyor survival, independent world wreckage caches, guarded recovery refusal and retry, live zombie targeting and conveyor breakage. The focused conveyor health HUD has already passed 12/12 and has F5 gameplay evidence, so rerun it only if a new regression affects selection or UI.

**Status:** Rounds 1 and 2 are accepted; Round 3 is not yet rerun after the latest changes. Do not call the overall destruction milestone closed until the local results arrive. Customizable Building Catalog/1–9 hotbar is scheduled next.


### Step 09.18 — Destruction milestone accepted after final Round 3 (48/48)

On **2026-11-02**, the developer confirmed the four final destruction and salvage test suites all passed again in local Godot 4.6.2, **48/48 checks**. These covered Main-scene zombie building destruction, guarded transactions, persistent-in-scene salvage/wreckage, and zombie conveyor/corner destruction. With Round 1 (all four movement/combat suites) and Round 2 (**30/30 factory/logistics checks**) already passed, the **core building and conveyor destruction milestone is complete**.

Acceptance includes automatic zombie damage to 100-HP buildings and 50-HP belt segments, local disconnection, destroyed source removal, world wreckage placeholders and lossless inventory/cargo accounting. Manual F5 gameplay previously confirmed building and conveyor wreckage and the selected conveyor's **40/50 HP** display.

Deferred systems: player-pickable salvage, persistence between saves, destruction balancing, final debris effects, more advanced zombie navigation and waves. These do not invalidate the accepted foundation.

### Phase 1G1 — Stable building IDs and configurable hotbar model (committed; F6 pending)

- Existing `WorldInteraction` uses nine Build Mode slots indexed into `buildable_definitions`; the Build HUD hardcodes all nine labels, and numerous specialized Conveyor Belt branches compare `selected_building_index == 4`. Changing keys prematurely would break logistics, so live input/UI remains unchanged at this step.
- Added `scripts/components/build_hotbar_configuration.gd` with `BuildHotbarConfiguration`, an independent nine-slot assignment model. Catalog items are keyed by stable `BuildingDefinition.building_id`; all nine prototype buildings start unlocked until the progression system exists.
- The model supports default ordering, catalog enumeration, lookup by slot, swapping existing assignments, clearing and replacing slots, locking/unlocking with safe unequip, and JSON-compatible save/restore payloads (versioned ID strings). Restoration rejects malformed payloads and ignores missing, duplicated or currently locked IDs. No file is written on disk yet.
- Added `res://tests/build_hotbar_configuration_test.tscn` with **12 checks awaiting local Godot validation**, including Turret → key 1, Storage → key 9, moving the belt out of slot 5, restoring a JSON snapshot after catalog reordering, unlock restrictions and malformed save safety.
- **Next:** Pass the isolated F6 test. Then replace the 4-index Conveyor Belt assumptions with definition identity/type in a separate regression, connect configurable slot selection to the existing Build HUD, and add the unlocked-building menu and disk persistence. The current playable factory and combat systems remain unchanged.


### Phase 1G1 — Stable-ID hotbar model accepted (12/12)

The developer supplied local Godot 4.6.2 output confirming **ALL 12 BUILD HOTBAR CONFIGURATION FOUNDATION TESTS PASSED** on 2026-11-02. The test verified all nine unique building IDs, unchanged default slots, Turret → 1 and Storage → 9 swaps, moved/cleared Conveyor Belt assignments, unlock guards, stable-ID JSON-compatible snapshots and restores after catalog reordering, and malformed/duplicate/locked ID rejection without changing live Build Mode.

### Phase 1G2 — Conveyor tool identity migration (code committed; F6 pending)

The existing `scripts/world_interaction.gd` contained **22** comparisons of `selected_building_index == 4` or `!= 4` governing conveyor-specific snap previews, corner discovery, bridge/offset placement, debug keys H/J/K and ghost-scene overrides. They all now call the shared `_is_conveyor_selected()` helper, which tests `_get_selected_building_definition().building_id == &"conveyor_belt"`. The helper avoids relying on the definition's current array position or assigned quick-build number. No changes were made to actual conveyor transport/snapping algorithms, Build HUD labels, current numeric input routing, or physical placement geometry.

Added `res://tests/conveyor_building_identity_test.tscn` (**12 checks pending local Godot 4.6.2 validation**). This uses an isolated Main scene to verify default Conveyor Belt selection and both left/right ghost-scene overrides, rejected overrides when Turret is selected, all nine original building identities, hotbar data-model assignment independently from Main, and a simulated catalog reordering that puts Conveyor Belt at index **0** and Test Extractor at index **4**. It then proves corners still preview at index 0, the old index 4 cannot trigger conveyor previews, invalid selections remain harmless, and the original catalog/ghost cleanup still work.

**Regression boundary:** This is an identity-only refactor. Arbitrary number-key remapping and user-facing Build Catalog are **not enabled** until this F6 test and related physical conveyor placement regressions pass. Continue respecting the current 1–9 Build HUD labels and existing construction controls.


### Phase 1G2 — Stable conveyor identity regression accepted (12/12; 2026-11-04)

The developer supplied a Godot 4.6.2 screenshot confirming **ALL 12 CONVEYOR BUILDING IDENTITY TESTS PASSED**. The migration from 22 `selected_building_index == 4` / `!= 4` branches to the stable `building_id == &"conveyor_belt"` helper preserved straight, left-corner and right-corner placement ghosts. Tests also passed when Conveyor Belt occupied catalog index 0 and Extractor occupied the former index 4, including guards against using conveyor previews on non-conveyor types. The original catalog and placement cleanup remained intact.

The messages `Extractor has no resource node` appeared **after** the success sentinel and are expected for temporary Extractor instances/ghosts in an isolated test without a deposit; they do not overturn the 12 passed assertions.

Before activating hotbar remapping, rerun eight relevant historical Godot F6 scenes (no code changes in this checkpoint), arranged in two focused groups:

- **Round A (37 checks):** `conveyor_building_placement_snap_test.tscn` (8), `conveyor_receiver_auto_snap_test.tscn` (11), `conveyor_source_corner_auto_snap_test.tscn` (10), `conveyor_terminal_building_corner_test.tscn` (8). These protect building input/output snaps and in-place source, receiver and terminal corner conversions.
- **Round B (43 checks):** `conveyor_missing_corner_placement_test.tscn` (9), `conveyor_dual_ended_bridge_test.tscn` (11), `conveyor_fractional_bridge_test.tscn` (12), `conveyor_offset_corner_bridge_test.tscn` (11). These protect missing corners and short, full-length and offset connectors.

**Status:** 1G2 identity regression accepted, historical targeted rounds **pending local Godot reruns (80 checks)**. The active numeric input layout and Build HUD remain fixed. The UI/catalog work follows these passes, with persistent hotbar save/load and eventual unlock progression still unimplemented.


### Phase 1G2 — Targeted conveyor regression Round A accepted (37/37; 2026-11-04)

The developer confirmed that **all four** historical building-port snapping and conveyor-corner F6 scenes passed in Godot 4.6.2 after the 22-branch conveyor identity refactor. The results were: `conveyor_building_placement_snap_test.tscn` **8/8**, `conveyor_receiver_auto_snap_test.tscn` **11/11**, `conveyor_source_corner_auto_snap_test.tscn` **10/10**, and `conveyor_terminal_building_corner_test.tscn` **8/8**, for **37/37**. This confirms those established building-port and corner behaviors remain compatible with selecting Conveyor Belt by `building_id`.

**Next gate — Round B (43 checks; pending local F6):** `conveyor_missing_corner_placement_test.tscn` (9), `conveyor_dual_ended_bridge_test.tscn` (11), `conveyor_fractional_bridge_test.tscn` (12), and `conveyor_offset_corner_bridge_test.tscn` (11). All four scenes are verified present on GitHub main, but **have not yet been rerun** after this refactor.

No production code or hotbar input behavior was modified in this documentation checkpoint. Once Round B passes, proceed incrementally with actual configurable numeric key selection and the dynamic Build HUD, preserving the full conveyor placement/snap pipeline.


### Phase 1G2 — Conveyor gap and bridge regression Round B accepted (43/43; 2026-11-04)

The developer confirmed all four historical bridge/gap F6 suites passed locally in Godot 4.6.2 after the stable-ID conveyor-tool refactor. The reported results were `conveyor_missing_corner_placement_test.tscn` **9/9**, `conveyor_dual_ended_bridge_test.tscn` **11/11**, `conveyor_fractional_bridge_test.tscn` **12/12**, and `conveyor_offset_corner_bridge_test.tscn` **11/11**, for **43/43**. Together with Round A **37/37**, Phase 1G2's **80/80 targeted conveyor regression checks passed**. This accepts the transition from fixed index-4 Conveyor Belt gates to stable `building_id` checks.

### Phase 1G3 — Configurable number-key selection and dynamic Build HUD (committed; F6 pending)

- Updated `scripts/world_interaction.gd` to instantiate a `BuildHotbarConfiguration` at startup, register the nine existing `BuildingDefinition` assets, and apply the original default hotbar assignments. Number keys 1–9 now resolve **slot → stable building ID → active definition index** through `_select_hotbar_slot()`. This preserves the existing underlying placement/snapping implementation and the original InputMap handling for keys 1–5, with physical keys 6–9 as before.
- Added controller APIs `assign_hotbar_slot()`, `clear_hotbar_slot()`, and `set_hotbar_unlocked()` for a future unlocked-building catalog menu. A cleared/locked slot is visually empty and its key does nothing; if the currently selected building loses its assignment, the controller selects an available fallback or clears the placement ghost if no slots remain.
- Updated `scripts/build_hud.gd` to show the actual assigned building for each key and highlight the slot containing the selected building. The familiar prototype labels are retained by small player-facing name aliases. An unassigned slot displays `Empty`. `selected_building_index` continues referring to the real definition for placement.
- Added `res://tests/build_hotbar_keyboard_integration_test.tscn` (**12 cases; local Godot run pending**). It drives the real Main-world keyboard handler and Build HUD, confirming legacy keys, assigning **Turret → 1** and **Storage → 9**, moving **Conveyor Belt → 4** while preserving right/left corner ghosts, changing key 5 to Smelter, empty slot behavior, unlock restrictions, reset defaults, and Build Mode cleanup.
- **Deliberate scope boundary:** The keyboard remapping APIs are live, but **no user-facing catalog menu exists yet** and assignments **are not saved to disk**. Do not call the new UI complete until a player can open a menu and persist changes across sessions. The 1G3 Godot regression still needs a local run before normal F5 validation.


### Phase 1G3 — First keyboard/HUD F6 regression stopped at Turret preview identity (2026-11-04)

The first local `res://tests/build_hotbar_keyboard_integration_test.tscn` run stopped at the **PASS F** assertion (original line 88) after successfully establishing the Turret's mapped building definition and stable ID. The old assertion tested whether the new preview scene root's `Node.name` began with `PrototypeDefensiveTurret`. Repeated quick-build selection can queue the previous preview for deletion until frame-end, causing Godot to give the newly instanced preview an autogenerated name; this name is not a reliable gameplay identity.

Replaced both name-based assertions (default key 9 and remapped key 1) with `_is_turret_preview()`, checking the active building ID, actual packed-scene path, `TurretComponent` type, and `construction_preview` group. No production code, HUD logic, keyboard routing, inventory, or conveyor placement was changed in this correction.

**Status:** Test-only correction committed; **full 12/12 local rerun pending**. Do not mark 1G3 accepted until the Godot result is supplied.


### Phase 1G3 — Live build hotbar keyboard/HUD regression accepted (12/12)

The developer reran `res://tests/build_hotbar_keyboard_integration_test.tscn` in local Godot 4.6.2 and supplied output showing **ALL 12 BUILD HOTBAR KEYBOARD INTEGRATION TESTS PASSED**. The previously failing Turret preview assertion now checks actual scene/component identity instead of the unstable auto-generated runtime node name. All A–L checks passed: default hotbar layout and labels, keys 5 and 9, remapping Turret to key 1, Storage to key 9, Conveyor Belt to key 4 (including both corner previews), key 5 becoming Smelter, inert empty slots, unlock restrictions, default reset and Build Mode cleanup.

The `Extractor has no resource node` diagnostic was emitted after the success sentinel, as expected for temporary prototype Extractor instances without a deposit.

**Next acceptance:** Manual F5 smoke test of the default number-key layout and dynamic Build HUD. Player-created remappings cannot yet be tested through the F5 UI because the unlocked Build Catalog/editor is still pending. Phase 1G4 will provide those controls, followed by a remapped F5 acceptance test and persistent hotbar file storage. No production code was changed during this results checkpoint.


### Phase 1G3 — Default-key highlights confirmed in F5; wreckage interaction gap found

On **2026-11-04**, the developer confirmed the **1–9 shortcut highlights switch correctly** during regular F5 gameplay. The associated screenshot showed a functioning factory, enemies and surviving wreckage, including a `SALVAGE: 15` cache. The exact individual key mappings were covered separately by the accepted 12/12 keyboard integration suite. Phase 1G3 is accepted.

**Usability report:** Wreckage could not be clicked, highlighted, inspected or cleaned up. This is due to the original `WorldSalvageCache` scene having only a mesh/label/inventory, with no physics selection collider or selectable group. The debug HUD also lacked a salvage-specific display. The project requires safe cleanup without silently discarding recovered resources.

### Step 09.18G — Wreckage selection, inventory info and protected cleanup (committed; F6 pending)

- Added `selectable` group membership and a **Layer-2-only StaticBody3D collision box** to `world_salvage_cache.tscn`. It does not use the factory placement-blocker physics layer and is never added to `player_built`, so zombie structure targeting and normal conveyor placement rules are unchanged.
- `WorldSalvageCache` now implements `set_selected()` and `set_demolition_hover()` with yellow inspection highlighting, red empty-wreckage demolition hover and amber protected-stock hover. The new `can_clear_safely()` check requires the inventory dictionary to be truly empty; it refuses malformed/unknown inventory contents and does not use only the reported total.
- The `ProductionDebugHUD` now detects selected wreckage independently of building/conveyor components, displays **Total Items**, the actual stored item names and quantities and a clear `Protected: recover contents before cleanup` or `Empty: can remove in Demolition Mode` instruction. It remains read-only.
- `WorldInteraction` includes WorldSalvageCache in demolition targeting and exposes `_try_clear_salvage_cache()`: only empty wreckage can be queued for removal. If selected, its HUD and selection clear immediately; stocked wreckage is never deleted or drained by the demolition action.
- New `res://tests/wreckage_selection_cleanup_test.tscn` contains **12 isolated Main-world integration checks pending local F6 validation**. These cover salvage ownership and groups, selection-layer raycast, highlighting/HUD, progress-bar absence, empty cleanup, cargo-bearing wreckage item inspection and protection, malformed contents refusal, a simulated lossless inventory transfer into an independent test container and cleanup only afterward, with **10/10** transferred resources preserved.
- **Scope boundary:** This checkpoint does **not** implement salvage pickup, inventory transfer from the player's hand, storage access through the world, or saving salvage between sessions. A stocked salvage cache remains protected from player demolition until a dedicated collection/recovery interaction exists. The planned in-game Build Catalog resumes after this safety checkpoint passes.


### E3d5a — Blueprint construction priority metadata and sorted waiting jobs (2026-11-10; F6 pending)

Implemented in the Factory Testing Sandbox after E3d4b's successful area-selection validation. ConstructionJob now accepts High, Normal and Low priorities and signals changes without altering authorization or elapsed work. Within the Q selection tool, **H / N / L** assign priority to the selected planned structures; **E** still authorizes only the selection and **Ctrl+E** still authorizes all. The Factory Blueprints HUD shows the selected priority composition, waiting queue count and next waiting job. The queue stores weak references to authorized QUEUED sites and orders them by priority, then original authorization sequence; started, cancelled or destroyed jobs drop out of the waiting list.

**Important testing boundary:** The Factory Testing Sandbox retains its explicit power/material/worker availability bypass, so jobs normally move directly to CONSTRUCTING. This queue cannot allocate drones or make a blocked job start; it is scheduling metadata for future worker capacity. A dedicated regression temporarily disables sandbox debug readiness to verify real QUEUED order and requirement gates without weakening Main. Added `res://tests/blueprint_construction_priority_e3d5a_test.tscn` with 15 checkpoints; **all 15/15 passed** in developer-provided Godot 4.6.2 screenshot (2026-11-10). Manual Q-selection and H/N/L assignment accepted (2026-11-10): the developer supplied a Factory Testing Sandbox screenshot showing Planned 6, Selected 6, priorities H 2 / N 2 / L 2, Queued 0 and Building 0. The sandbox pre-authorization queue remains empty as expected. Automated regression covers E authorization; no manual post-E construction screenshot has been provided. Re-run existing E3d4b area selection and earlier construction regression after acceptance if necessary.



### E3d5b — Isolated finite-worker construction scheduler (2026-11-10; 15/15 F6 passed)

Added `scripts/components/blueprint_construction_slot_scheduler.gd`, a scheduler with 1–16 slots (two in the first test) and stable priority ordering. It accepts authorized queued sites registered through the existing priority queue, but **fails closed** until the caller supplies an explicit power/material readiness snapshot per site. It mirrors those external flags into the existing ConstructionJob availability gates and assigns finite worker permission. It neither fabricates resources nor advances time, starts an unauthorized blueprint, or creates physical drones.

Active jobs are non-preemptive. If power/material readiness disappears, a job pauses, retains elapsed work and frees its slot. Restoring readiness still requires a free slot. Completion and cancellation safely release capacity. Added `res://tests/blueprint_construction_slots_e3d5b_test.tscn` with 15 isolated checks. **Godot 4.6.2 F6 validation passed 15/15 checks**, confirmed by developer-provided screenshot on 2026-11-10. Normal Factory Testing Sandbox debug construction remains immediate because this service is not enabled or instantiated by WorldInteraction.

Next milestones: design and verify real power/material availability providers separately, then connect finite worker assignments to construction and physical drones. Maintain sandbox-only feature gating until regression-tested.
