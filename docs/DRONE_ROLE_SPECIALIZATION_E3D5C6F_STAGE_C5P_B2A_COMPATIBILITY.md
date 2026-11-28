# C5P-B2a targeted compatibility gate

2026-11-27: Developer confirmed final C5P-B2a compatibility Wave 2 10/10 F6 scenes and 121/121 expected sections (including B1 labeled sections). B2a CLOSED / ACCEPTED: targeted 22/22 suites / 296/296 expected sections (12/175 + 10/121); isolated 1 suite / 11/11 labeled sections accepted separately; fresh B2a 23 suites / 307 expected sections. Historical unique coverage 75/1018, not fresh full regression. Expected runtime 967bc44 plus documentation checkpoints; local HEAD and individual logs not independently inspected. B2b implementation awaits explicit approval of docs/DRONE_ROLE_SPECIALIZATION_E3D5C6F_STAGE_C5P_B2B_PLAN.md; B2c/B3/C5P-C/C5B/Main integration pending. Documentation only; no gameplay, existing tests or historical manifest changes.

2026-11-27: Developer confirmed C5P-B2a compatibility Wave 1 all 12/12 F6 scenes passed locally in Godot against 175 manifest-expected sections. Fresh targeted compatibility progress 12/22 suites and 175/296 expected sections; isolated 1 suite / 11 labeled sections accepted separately. Cumulative historical unique acceptance remains 75 suites / 1018 sections, not fresh full regression. Runtime expected 967bc44 plus documentation-only checkpoints; local HEAD and logs not independently inspected. Final Wave 2 (10 suites / 121 expected sections, including B1 labeled sections) pending. No gameplay, existing tests, historical manifest or Main changes. C5P-B2b/B2c/B3 remain blocked pending acceptance and separate approval.

2026-11-27: Developer confirmed C5P-B2a isolated F6 all 11/11 labeled sections passed locally in Godot against candidate runtime 967bc44e9c89d593f1dc7833e5710bec35f7f996; local HEAD/logs not independently inspected. Cumulative historical unique acceptance 75 suites / 1018 sections; not fresh full regression. Targeted compatibility 22 suites / 296 expected sections pending in two waves. B2b/B2c/B3 blocked; no gameplay, existing tests, historical manifest or Main changes.

Selection: power coverage, completed structures, finite allocation, readiness, escrow, charging, unified construction, power interruption, all specialized role/controller fixtures and B1 battery-independent fixture. Counts from historical manifest and B1 labeled sections. Remaining suites deferred to C5P-C fresh full regression. Stop on error; no new acceptance until developer confirms.

## Wave 1 — 12 suites / 175 expected sections

- `res://tests/blueprint_construction_material_escrow_e3d5c2a_test.tscn` — 16
- `res://tests/playable_construction_power_e3d5c5x1_test.tscn` — 9
- `res://tests/blueprint_owned_readiness_e3d5c4r_test.tscn` — 18
- `res://tests/construction_readiness_coordinator_e3d5c3c1_test.tscn` — 18
- `res://tests/blueprint_construction_readiness_e3d5c1_test.tscn` — 15
- `res://tests/construction_power_coverage_e3d5c3a_test.tscn` — 16
- `res://tests/completed_power_structures_e3d5c3b1_test.tscn` — 16
- `res://tests/finite_construction_power_e3d5c3b2_test.tscn` — 18
- `res://tests/drone_finite_hub_charging_e3d5c5x7a_test.tscn` — 13
- `res://tests/playable_unified_construction_e3d5c6d_stage_a_test.tscn` — 16
- `res://tests/playable_drone_power_interruption_e3d5c6e_stage_a_test.tscn` — 14
- `res://tests/specialized_drone_role_guards_e3d5c6f_stage_a_test.tscn` — 6

## Wave 2 — 10 suites / 121 expected sections

- `res://tests/specialized_drone_handoff_e3d5c6f_stage_a_test.tscn` — 7
- `res://tests/specialized_drone_single_owner_e3d5c6f_b1_test.tscn` — 9
- `res://tests/specialized_drone_logistics_e3d5c6f_b2_test.tscn` — 9
- `res://tests/specialized_drone_builder_e3d5c6f_b3_test.tscn` — 12
- `res://tests/specialized_drone_pre_pickup_cancel_e3d5c6f_c1_test.tscn` — 12
- `res://tests/specialized_drone_loaded_cancel_e3d5c6f_c2_test.tscn` — 16
- `res://tests/specialized_drone_staging_recovery_e3d5c6f_c3_test.tscn` — 18
- `res://tests/specialized_drone_builder_blackout_e3d5c6f_c4a_test.tscn` — 14
- `res://tests/specialized_drone_builder_cancel_e3d5c6f_c4b_test.tscn` — 14
- `res://tests/specialized_drone_battery_independent_e3d5c6f_c5p_b1_test.tscn` — 10
