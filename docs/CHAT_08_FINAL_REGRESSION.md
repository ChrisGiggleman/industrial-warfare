# Industrial Warfare — Chat 08 Final Logistics Regression

**Prepared:** 2026-10-30  
**Engine:** Godot 4.6.2 Stable / Forward+ / GDScript  
**Repository:** `ChrisGiggleman/industrial-warfare`, branch `main`  
**Status:** Regression plan and documentation checkpoint. **Final regression not yet completed as a single pass.**

This checklist distinguishes **historical Godot passes**, **recent gameplay observations**, and **pending acceptance**. A committed test is not considered passed merely because it exists. Run each scene individually using **F6**, record its actual final PASS banner, and confirm no parser errors or unwanted continuing processes.

## A. Critical regression scenes

Each of the following `.tscn` files has been verified as present in `res://tests/` on GitHub `main`.

| Order | Scene | Purpose | Final-check status |
|---|---|---|---|
| 1 | `factory_grid_all_buildings_test.tscn` | All five building definitions and 52 rotated input/output lane checks | **Previously passed** (reported after 1×1 conversion); final rerun pending |
| 2 | `conveyor_building_placement_snap_test.tscn` | Building-to-conveyor snapping | Historical pass; final rerun pending |
| 3 | `conveyor_dual_port_snap_test.tscn` | Independent building inputs and outputs | Historical pass; final rerun pending |
| 4 | `conveyor_existing_endpoint_test.tscn` | Discover valid free existing endpoints | Historical pass; final rerun pending |
| 5 | `conveyor_existing_connection_test.tscn` | Commit/revalidate existing connections | Historical pass; final rerun pending |
| 6 | `conveyor_receiver_corner_test.tscn` | Existing receiver corner conversion | Historical pass; final rerun pending |
| 7 | `conveyor_receiver_auto_snap_test.tscn` | Automatic receiver corner discovery, click, cargo safety | **11/11 previously passed**; final rerun pending |
| 8 | `conveyor_source_corner_auto_snap_test.tscn` | Corner conversion without disconnecting building output | **10/10 previously passed**; final rerun pending |
| 9 | `conveyor_missing_corner_preview_test.tscn` | Missing L-shaped corner discovery | Historical pass; final rerun pending |
| 10 | `conveyor_missing_corner_placement_test.tscn` | Permanent missing corner and item flow | Historical pass; final rerun pending |
| 11 | `conveyor_dual_ended_bridge_test.tscn` | Exact free-end two-ended bridge | Historical pass; final rerun pending |
| 12 | `conveyor_bridge_discovery_test.tscn` | Two-ended bridge search/validation | Historical pass; final rerun pending |
| 13 | `conveyor_fractional_bridge_test.tscn` | Short straight real connector + length-based pacing | Reported passing after length/speed fix; final rerun pending |
| 14 | `conveyor_offset_corner_bridge_test.tscn` | Half-grid perpendicular connector + path length | Reported passing after length/speed fix; final rerun pending |
| 15 | `conveyor_corner_cargo_visual_test.tscn` | Cargo visualization across corners | Historical pass; final rerun pending |
| 16 | `conveyor_automatic_loading_test.tscn` | Port-to-belt loading | Historical pass; final rerun pending |
| 17 | `conveyor_automatic_unloading_test.tscn` | Belt-to-port unloading | Historical pass; final rerun pending |
| 18 | `conveyor_physical_factory_test.tscn` | Integrated ore-to-smelter physical transport | Historical pass; final rerun pending |
| 19 | `conveyor_merger_test.tscn` | 1×1 Merger, **3 inputs → 1 output**, lane fairness and backpressure | **10/10 previously passed**; final rerun pending |
| 20 | `conveyor_splitter_test.tscn` | 1×1 Splitter, **1 input → 3 outputs**, blocked/disconnected output behavior | **10/10 previously passed**; final rerun pending |

**Efficient run order:** Start with 1, 13, 14, 19, 20 (highest-change risk), then run the remainder in table order. If a single suite fails, stop and fix that specific regression before treating this as a milestone pass.

## B. Live factory acceptance

### Confirmed in main-game screenshots and logs

- Directed straight belts, existing receiver-corner connection, automatic source-corner connection, and missing-corner bridging constructed successfully.
- Small fractional/offset gaps were filled by a **real** conveyor; the user observed item flow at consistent speed following the length-based motion correction.
- A 1×1 Merger was constructed with three physically attached input lines and an output connected to Storage.
- A 1×1 Splitter was constructed with all three output ports connected; its Production Debug HUD showed **13 completed splits (A=5, B=4, C=4)** and output buffers 0/1 at screenshot time. This validates all three lanes routing items during a live session.

### Still required before marking Chat 08 fully complete

1. **Merger live throughput:** Run three actively supplied inputs. Select Merger; record `From A`, `From B`, `From C`, total completed merges, input inventory levels and output connection. Counters must rise for each *active* source over time when output space is available. Capturing only the connection log is not enough to claim live 3-way transport.
2. **Merger backpressure:** Temporarily block the downstream belt. Confirm output saturates, inputs retain cargo without loss, and flow resumes when the obstruction is cleared.
3. **Splitter repeat:** Confirm that `To A/B/C` continue increasing with a steady input. Temporarily fill/disconnect one output and confirm other available ports still receive items, then restore it.
4. **Full physical chain:** Connect Extractor → Storage → Smelter → destination Storage. Confirm ore is consumed only through the selected recipe and ingots reach the destination through physical conveyors; note any still-active legacy proximity transfer components separately.
5. **Selection, construction and demolition:** Ensure selected buildings and belts highlight properly. Empty belts should demolish; conveyors carrying items and non-empty Merger/Splitter buffers must be protected.
6. **Collision/placement refusal:** A blocked tile or occupied port must not silently reconnect, duplicate items, or create visually overlapping belts.
7. **Restart after pull:** If Godot detects `main.tscn` modified outside the editor, reload from disk only after preserving unsaved scene edits, then check Debugger errors.

## C. Safety and conservation assertions

- Standard belts carry **one buffered item**; movement along a physical segment or junction preserves item type/count.
- Fractional and offset connectors change travel **duration and visual path**, not inventory transfer policy.
- A straight or corner conveyor has only one upstream and one downstream connection. Multiple incoming lines require the explicit **Merger**.
- Merger's three independent input inventories are capacity-limited; a full output delays transfers instead of discarding cargo.
- Splitter sends items only toward connected, accepting outputs, cycling available output lanes fairly.
- Normal storage accepts supported items without recipe filtering. Producer inputs must still obey their selected recipes.
- Watch for obsolete proximity logistics still enabled alongside physical routes; that can make a cargo total appear duplicated or make a conveyor look irrelevant. Do not disable legacy components without a conservation regression.

## D. Release gate and GitHub workflow

**This documentation commit is a checkpoint, not final acceptance.** Do not mark the final Chat 08 logistics milestone complete until Section A is rerun and all pending Section B behavior is observed.

After successful tests, use VS Code PowerShell:

```powershell
git status
git add .
git commit -m "Checkpoint: Chat 08 final logistics regression verified"
git push origin main
```

Skip commit/push if `git status` shows nothing to commit (GitHub-side documentation changes may already be present). Review any unexpected untracked files before staging them.

**Next planned work after acceptance:** remove/gate prototype proximity transfers once a deposit-driven full physical chain is proven, add safe cargo recovery during demolition, and progress toward ammunition production/defense per `GAME_VISION.md`.
