# Playable automatic drone final compatibility regression

**Status: FULLY ACCEPTED on 2026-11-18.** Developer explicitly reported all 52/52 regression suites and 741/741 checks passed locally in Godot. Each supplied suite name and count exactly matches the committed CSV manifest at fee58a9. Combined with accepted Stage C automated 13/13, 53/53 targeted suites / 754/754 automated checks; manual gameplay 9/9 accepted separately. No independent assistant execution or runner-use claim.

For any future rerun, run every scene separately with F6 after pulling main. Verify the suite's expected check groups and successful completion output, including the four inventory transfer PASS groups (no ALL banner). Do not count extra conservation notes as extra checks. Record failures, script errors, or incomplete output. Stage C itself already passed 13/13; optionally rerun, but do not count it twice.

## Manifest
| Scene under res://tests/ | Expected checks | Current gate |
|---|---:|---|
| `inventory_trasnfer_test.tscn` | 4 | Passed |
| `item_port_transfer_test.tscn` | 7 | Passed |
| `manufacturing_transaction_test.tscn` | 9 | Passed |
| `recipe_output_capacity_test.tscn` | 11 | Passed |
| `conveyor_automatic_loading_test.tscn` | 10 | Passed |
| `conveyor_automatic_unloading_test.tscn` | 9 | Passed |
| `conveyor_connected_transport_test.tscn` | 7 | Passed |
| `conveyor_splitter_test.tscn` | 10 | Passed |
| `conveyor_merger_test.tscn` | 10 | Passed |
| `conveyor_physical_only_conservation_test.tscn` | 9 | Passed |
| `timed_storage_conveyor_delivery_test.tscn` | 6 | Passed |
| `blueprint_construction_material_escrow_e3d5c2a_test.tscn` | 16 | Passed |
| `unified_receiver_consolidation_e3d5c5v_test.tscn` | 56 | Passed |
| `playable_construction_logistics_e3d5c5w_test.tscn` | 13 | Passed |
| `playable_construction_power_e3d5c5x1_test.tscn` | 9 | Passed |
| `playable_construction_drone_e3d5c5x2_test.tscn` | 11 | Passed |
| `drone_storage_discovery_e3d5c5x3_test.tscn` | 12 | Passed |
| `drone_supplier_reservations_e3d5c5x4a_test.tscn` | 12 | Passed |
| `world_salvage_destruction_test.tscn` | 12 | Passed |
| `destruction_cargo_recovery_test.tscn` | 12 | Passed |
| `drone_return_reservations_e3d5c5x4b_test.tscn` | 14 | Passed |
| `prototype_construction_worker_drone_e3d5c4u_test.tscn` | 16 | Passed |
| `prototype_drone_worker_readiness_e3d5c4v_test.tscn` | 21 | Passed |
| `prototype_construction_drone_fleet_e3d5c4w_test.tscn` | 21 | Passed |
| `prototype_drone_battery_dock_e3d5c4x_test.tscn` | 20 | Passed |
| `prototype_construction_drone_reuse_e3d5c4y_test.tscn` | 20 | Passed |
| `prototype_construction_drone_tick_e3d5c4z_test.tscn` | 20 | Passed |
| `sandbox_construction_drone_bridge_e3d5c5a_test.tscn` | 20 | Passed |
| `drone_physical_pickup_e3d5c5x5a_test.tscn` | 12 | Passed |
| `blueprint_material_staging_e3d5c4c_test.tscn` | 16 | Passed |
| `blueprint_physical_staging_e3d5c4d_test.tscn` | 16 | Passed |
| `blueprint_site_staging_ownership_e3d5c4h_test.tscn` | 16 | Passed |
| `blueprint_anchored_receiver_e3d5c4i_test.tscn` | 16 | Passed |
| `blueprint_owned_readiness_e3d5c4r_test.tscn` | 18 | Passed |
| `blueprint_receiver_recovery_audit_e3d5c4j_test.tscn` | 12 | Passed |
| `drone_physical_delivery_e3d5c5x5b_test.tscn` | 13 | Passed |
| `construction_readiness_coordinator_e3d5c3c1_test.tscn` | 18 | Passed |
| `blueprint_construction_readiness_e3d5c1_test.tscn` | 15 | Passed |
| `drone_delivered_worker_e3d5c5x5c_test.tscn` | 16 | Passed |
| `drone_cancelled_cargo_recovery_e3d5c5x6_test.tscn` | 13 | Passed |
| `construction_power_coverage_e3d5c3a_test.tscn` | 16 | Passed |
| `completed_power_structures_e3d5c3b1_test.tscn` | 16 | Passed |
| `finite_construction_power_e3d5c3b2_test.tscn` | 18 | Passed |
| `drone_finite_hub_charging_e3d5c5x7a_test.tscn` | 13 | Passed |
| `drone_cargo_worker_reuse_e3d5c5x7b_test.tscn` | 16 | Passed |
| `drone_pre_pickup_cancellation_e3d5c5x7c1_test.tscn` | 12 | Passed |
| `drone_post_delivery_cancellation_e3d5c5x7c2_test.tscn` | 13 | Passed |
| `drone_lost_site_recovery_e3d5c5x7c3_test.tscn` | 14 | Passed |
| `drone_automatic_dispatch_e3d5c5x8a_test.tscn` | 14 | Passed |
| `drone_automatic_lifecycle_e3d5c5x8b_test.tscn` | 15 | Passed |
| `playable_automatic_construction_drone_stage_a_test.tscn` | 8 | Passed |
| `playable_automatic_construction_drone_stage_b_test.tscn` | 8 | Passed |
| **Total (52 suites)** | **741** | **Passed** |

## Optional local batch runner

From the repository root in PowerShell, with Godot 4.6.2 project already imported:

```powershell
.\tools\run_playable_drone_final_regression.ps1 -GodotExe "C:\path\to\Godot_v4.6.2-stable_win64_console.exe"
```

Use the actual console executable path on your computer. The runner launches one process per scene, waits for the exact success line inferred from that scene's GDScript (special case inventory transfer), saves stdout/stderr and a CSV in a new temporary folder, and stops the separate process once the banner is seen (or timeout). It is a convenience launcher, not a new test authority; results are labeled CANDIDATE or REVIEW, not accepted. It has not been run by the assistant. Headless/CLI behavior may differ from editor F6; inspect logs, verify check groups, and rerun any REVIEW suite with F6. The four inventory PASS lines must all be present. A banner alone does not prove check totals; expected counts come from the manifest. Review warnings/errors and actual output. Report exact suite statuses and counts for final acceptance. Do not add logs to git. No gameplay or test code changed.

Accepted compatibility 52/52 suites, 741/741 checks. Combined with accepted Stage C 13/13 = 53 suites / 754 checks. Manual 9/9 remains separate. Targeted, not full-project regression.
