# Playable automatic drone final compatibility regression

Status: pending on 2026-11-18. Developer confirmed Stage C automated 13/13 and manual 9/9. This checklist is a fresh regression gate, not previously reported results.

Run every scene separately with F6 after pulling main. Verify the suite's expected check groups and successful completion output, including the four inventory transfer PASS groups (no ALL banner). Do not count extra conservation notes as extra checks. Record failures, script errors, or incomplete output. Stage C itself already passed 13/13; optionally rerun, but do not count it twice.

## Manifest
| Scene under res://tests/ | Expected checks | Current gate |
|---|---:|---|
| `inventory_trasnfer_test.tscn` | 4 | Pending |
| `item_port_transfer_test.tscn` | 7 | Pending |
| `manufacturing_transaction_test.tscn` | 9 | Pending |
| `recipe_output_capacity_test.tscn` | 11 | Pending |
| `conveyor_automatic_loading_test.tscn` | 10 | Pending |
| `conveyor_automatic_unloading_test.tscn` | 9 | Pending |
| `conveyor_connected_transport_test.tscn` | 7 | Pending |
| `conveyor_splitter_test.tscn` | 10 | Pending |
| `conveyor_merger_test.tscn` | 10 | Pending |
| `conveyor_physical_only_conservation_test.tscn` | 9 | Pending |
| `timed_storage_conveyor_delivery_test.tscn` | 6 | Pending |
| `blueprint_construction_material_escrow_e3d5c2a_test.tscn` | 16 | Pending |
| `unified_receiver_consolidation_e3d5c5v_test.tscn` | 56 | Pending |
| `playable_construction_logistics_e3d5c5w_test.tscn` | 13 | Pending |
| `playable_construction_power_e3d5c5x1_test.tscn` | 9 | Pending |
| `playable_construction_drone_e3d5c5x2_test.tscn` | 11 | Pending |
| `drone_storage_discovery_e3d5c5x3_test.tscn` | 12 | Pending |
| `drone_supplier_reservations_e3d5c5x4a_test.tscn` | 12 | Pending |
| `world_salvage_destruction_test.tscn` | 12 | Pending |
| `destruction_cargo_recovery_test.tscn` | 12 | Pending |
| `drone_return_reservations_e3d5c5x4b_test.tscn` | 14 | Pending |
| `prototype_construction_worker_drone_e3d5c4u_test.tscn` | 16 | Pending |
| `prototype_drone_worker_readiness_e3d5c4v_test.tscn` | 21 | Pending |
| `prototype_construction_drone_fleet_e3d5c4w_test.tscn` | 21 | Pending |
| `prototype_drone_battery_dock_e3d5c4x_test.tscn` | 20 | Pending |
| `prototype_construction_drone_reuse_e3d5c4y_test.tscn` | 20 | Pending |
| `prototype_construction_drone_tick_e3d5c4z_test.tscn` | 20 | Pending |
| `sandbox_construction_drone_bridge_e3d5c5a_test.tscn` | 20 | Pending |
| `drone_physical_pickup_e3d5c5x5a_test.tscn` | 12 | Pending |
| `blueprint_material_staging_e3d5c4c_test.tscn` | 16 | Pending |
| `blueprint_physical_staging_e3d5c4d_test.tscn` | 16 | Pending |
| `blueprint_site_staging_ownership_e3d5c4h_test.tscn` | 16 | Pending |
| `blueprint_anchored_receiver_e3d5c4i_test.tscn` | 16 | Pending |
| `blueprint_owned_readiness_e3d5c4r_test.tscn` | 18 | Pending |
| `blueprint_receiver_recovery_audit_e3d5c4j_test.tscn` | 12 | Pending |
| `drone_physical_delivery_e3d5c5x5b_test.tscn` | 13 | Pending |
| `construction_readiness_coordinator_e3d5c3c1_test.tscn` | 18 | Pending |
| `blueprint_construction_readiness_e3d5c1_test.tscn` | 15 | Pending |
| `drone_delivered_worker_e3d5c5x5c_test.tscn` | 16 | Pending |
| `drone_cancelled_cargo_recovery_e3d5c5x6_test.tscn` | 13 | Pending |
| `construction_power_coverage_e3d5c3a_test.tscn` | 16 | Pending |
| `completed_power_structures_e3d5c3b1_test.tscn` | 16 | Pending |
| `finite_construction_power_e3d5c3b2_test.tscn` | 18 | Pending |
| `drone_finite_hub_charging_e3d5c5x7a_test.tscn` | 13 | Pending |
| `drone_cargo_worker_reuse_e3d5c5x7b_test.tscn` | 16 | Pending |
| `drone_pre_pickup_cancellation_e3d5c5x7c1_test.tscn` | 12 | Pending |
| `drone_post_delivery_cancellation_e3d5c5x7c2_test.tscn` | 13 | Pending |
| `drone_lost_site_recovery_e3d5c5x7c3_test.tscn` | 14 | Pending |
| `drone_automatic_dispatch_e3d5c5x8a_test.tscn` | 14 | Pending |
| `drone_automatic_lifecycle_e3d5c5x8b_test.tscn` | 15 | Pending |
| `playable_automatic_construction_drone_stage_a_test.tscn` | 8 | Pending |
| `playable_automatic_construction_drone_stage_b_test.tscn` | 8 | Pending |
| **Total (52 suites)** | **741** | **Pending** |

## Optional local batch runner

From the repository root in PowerShell, with Godot 4.6.2 project already imported:

```powershell
.\tools\run_playable_drone_final_regression.ps1 -GodotExe "C:\path\to\Godot_v4.6.2-stable_win64_console.exe"
```

Use the actual console executable path on your computer. The runner launches one process per scene, waits for the exact success line inferred from that scene's GDScript (special case inventory transfer), saves stdout/stderr and a CSV in a new temporary folder, and stops the separate process once the banner is seen (or timeout). It is a convenience launcher, not a new test authority; results are labeled CANDIDATE or REVIEW, not accepted. It has not been run by the assistant. Headless/CLI behavior may differ from editor F6; inspect logs, verify check groups, and rerun any REVIEW suite with F6. The four inventory PASS lines must all be present. A banner alone does not prove check totals; expected counts come from the manifest. Review warnings/errors and actual output. Report exact suite statuses and counts for final acceptance. Do not add logs to git. No gameplay or test code changed.

Expected compatibility 52/52 suites, 741/741 checks. Combined with accepted Stage C 13/13 = 53 suites / 754 checks. Manual 9/9 remains separate. Targeted, not full-project regression.
