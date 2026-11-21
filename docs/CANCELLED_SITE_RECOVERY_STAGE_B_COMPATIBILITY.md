# E3d5c6c — Stage B physical recovery acceptance and targeted compatibility

Updated **2026-11-21**. Engine **Godot 4.6.2 Stable**, GDScript, Forward+. Repository `ChrisGiggleman/industrial-warfare`, branch `main`.

## Stage B isolated acceptance — ACCEPTED

Developer explicitly confirmed in local Godot that **all 13/13 checks** in `res://tests/cancelled_site_physical_recovery_e3d5c6c_stage_b_test.tscn` passed, including the `ALL 13 CANCELLED SITE PHYSICAL RECOVERY E3D5C6C STAGE B TESTS PASSED` test sequence. This is **user-confirmed local execution**, not a test run by the assistant.

The accepted isolated tests A–M cover canonical original 3-ingot Storage and 5-ingot Press post-delivery/during-construction cancellation, Stage A immutable original staging custody, real capacity reservation at a registered Storage dock, physical original-hover pickup, actual debit only on arrival, finite battery flights to Storage and home, unavailable/blocked dock holding cargo safely, real reserved-capacity unload, finite generator-powered recharge, duplicate mission refusal and exact conservation. The Stage B implementation is **default OFF, isolated**: `PrototypeCancelledSiteRecoveryTransport` is not automatically installed in the original playable `playable_direct_build_authorization_e3d5c6b.tscn` or Main.

Prior Stage A custody 13/13 isolated plus **15/15 previously accepted compatibility suites / 218/218 checks** were fully accepted. Stage B's 13 new checks are unique: cumulative accepted milestone baseline = **60 unique suites / 836 checks** (earlier 58/810 + Stage A 13 + Stage B 13). No final fresh combined 60/836 run has been performed or reported. All compatibility reruns overlap accepted tests and cannot be added to unique totals.

## Stage B targeted compatibility — NOT YET RUN / NOT ACCEPTED

Because Stage B adds default-OFF flight states and an opt-in custody source accessor, rerun **26 prior accepted suites / 368 existing checks** covering drone motion, battery, inventory staging and escrow, original site/receiver claims, supplier/return reservations, cargo recovery, charging/reuse, cancellation, dispatch, and the Direct Build paths. Every listed scene was verified present on GitHub; counts were checked against the accepted 56-suite manifest or earlier Stage A/B/C isolated acceptance records.

Manifest source of truth: `tools/cancelled_site_physical_recovery_stage_b_compatibility.csv`.

| # | Test scene under `res://tests/` | Checks |
|---:|---|---:|
| 01 | `prototype_construction_worker_drone_e3d5c4u_test.tscn` | 16 |
| 02 | `prototype_drone_battery_dock_e3d5c4x_test.tscn` | 20 |
| 03 | `blueprint_material_staging_e3d5c4c_test.tscn` | 16 |
| 04 | `blueprint_physical_staging_e3d5c4d_test.tscn` | 16 |
| 05 | `blueprint_site_staging_ownership_e3d5c4h_test.tscn` | 16 |
| 06 | `blueprint_anchored_receiver_e3d5c4i_test.tscn` | 16 |
| 07 | `blueprint_receiver_recovery_audit_e3d5c4j_test.tscn` | 12 |
| 08 | `blueprint_construction_material_escrow_e3d5c2a_test.tscn` | 16 |
| 09 | `drone_storage_discovery_e3d5c5x3_test.tscn` | 12 |
| 10 | `drone_supplier_reservations_e3d5c5x4a_test.tscn` | 12 |
| 11 | `drone_return_reservations_e3d5c5x4b_test.tscn` | 14 |
| 12 | `drone_physical_pickup_e3d5c5x5a_test.tscn` | 12 |
| 13 | `drone_physical_delivery_e3d5c5x5b_test.tscn` | 13 |
| 14 | `drone_delivered_worker_e3d5c5x5c_test.tscn` | 16 |
| 15 | `drone_cancelled_cargo_recovery_e3d5c5x6_test.tscn` | 13 |
| 16 | `drone_finite_hub_charging_e3d5c5x7a_test.tscn` | 13 |
| 17 | `drone_cargo_worker_reuse_e3d5c5x7b_test.tscn` | 16 |
| 18 | `drone_pre_pickup_cancellation_e3d5c5x7c1_test.tscn` | 12 |
| 19 | `drone_post_delivery_cancellation_e3d5c5x7c2_test.tscn` | 13 |
| 20 | `drone_lost_site_recovery_e3d5c5x7c3_test.tscn` | 14 |
| 21 | `drone_automatic_dispatch_e3d5c5x8a_test.tscn` | 14 |
| 22 | `drone_automatic_lifecycle_e3d5c5x8b_test.tscn` | 15 |
| 23 | `playable_automatic_construction_drone_stage_c_test.tscn` | 13 |
| 24 | `playable_direct_build_authorization_e3d5c6b_test.tscn` | 11 |
| 25 | `playable_direct_build_authorization_e3d5c6b_stage_b_test.tscn` | 14 |
| 26 | `cancelled_site_custody_e3d5c6c_stage_a_test.tscn` | 13 |
| | **26 previously accepted suites** | **368** |

**How to run:** pull `main` using `git pull --ff-only origin main`; open each scene under `res://tests/` in Godot; press **F6**, inspect Output and Debugger for all PASS lines and successful final banner; repeat for each. **Do not** run the new Stage B isolated suite as part of these 26 compatibility reruns; Stage B's new 13 checks have already been locally accepted.

**If any suite stops or fails:** record the *first* Debugger assertion/parse error and preceding Output PASS lines. Never claim all 26 passing from partial output. Stop and fix narrowly before resuming. Only record **26/26 suites, 368/368 checks** when the developer confirms actual local results.

**After full compatibility:** record full Stage B acceptance, maintain **60/836** unique accepted baseline (no double count), and start **E3d5c6c Stage C — opt-in playable automatic cancelled-site recovery**, in a **new separate scene**, without changing Main, existing Direct Build scene or ordinary scenes.

## Future Stage C gameplay and separate gates

Required gameplay is: Direct Build or authorized Blueprint site cancelled after delivered materials → original Stage A custody ticket verifies unspent 3/5 ingots → the **same existing single drone**, after completing/rearming its prior assignment, physically visits the original retained site hover, picks up exact original materials, and returns to eligible Storage through a real capacity reservation and finite battery travel/recharge. Keep locked staging claims, accurate player feedback, no free inventory, no bypass power, no duplicate driver, and conservative wait on missing dock/capacity/energy. No silo/researched drone dock, multi-trip/item, fleet concurrency, conveyors/splitters, persistence or destruction expansion at this gate.

**E3d5c6b Direct Build Stage C manual 10/10 remains open.** Prior playable images proved Storage and Press completion (15→7 ingots), generator OFF pauses construction, and material return after *delivered* cancellation was missing in that original scene. Isolated Stage B success does not make auto-recovery functional in playable scenes yet.

## Development continuity

Consult `docs/HANDOFF.md`, `docs/CANCELLED_SITE_PHYSICAL_RECOVERY.md`, `docs/DEVLOG.md`, `docs/ROADMAP.md` and `docs/DRONE_CONSTRUCTION_LOGISTICS.md`. Preserve old accepted suites. Document each user-confirmed F6 test gate separately from changes that were merely committed but unrun.
