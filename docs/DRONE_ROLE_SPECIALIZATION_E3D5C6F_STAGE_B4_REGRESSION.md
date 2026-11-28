# E3d5c6f Stage B4 — Fresh Combined 68-Suite Regression

**FINAL ACCEPTED (2026-11-25): Developer confirmed all four fresh local Godot F6 waves passed: 20/245 + 20/333 + 20/258 + 8/87 = 68/68 unique suites against 923 manifest-expected check sections.** Earlier targeted runs are not added again.

## Authoritative manifest
[Four-wave CSV](../tools/specialized_drones_e3d5c6f_stage_b4_68_suite_regression.csv) `tools/specialized_drones_e3d5c6f_stage_b4_68_suite_regression.csv`, columns `Wave,Scene,ExpectedChecks,Origin`.

- Rows 1–63: copied **in exact original order** from [historically accepted E3d5c6e manifest](../tools/drone_power_interruption_e3d5c6e_final_63_suite_regression.csv), 63 distinct scene paths, source-reported **880 manifest-expected check groups**. This inherited number is not a newly verified per-assertion count.
- Rows 64–68: five **distinct** E3d5c6f fixtures, each taken from the existing committed `tests/*.tscn` plus its `tests/*.gd` source. Expected labeled PASS sections: Stage A role guards 6, Stage A handoff 7, B1 one-owner 9, B2 logistics 9, B3 builder 12, totaling **43** printed PASS sections. These are labeled groups, not measured assertion counts.
- **Overall**: **68 unique scenes, 923 manifest-expected check groups** (880 historical expected groups + 43 source-verified new labeled sections), no duplicate file names. All **68 named `tests/*.tscn` paths exist** on the E3d5c6f feature branch, verified against GitHub's repository tests directory. Never count previous Stage A/B1/B2/B3 targeted reruns again.
- Inherited historical numbers and new printed sections are both tracked in the CSV `ExpectedChecks` column for continuity; this does not claim independently verified 923 assertions.

## Wave order and expectations

| Wave | Manifest rows | Unique F6 scenes | Expected check groups | Focus |
|---|---:|---:|---:|---|
| 1 | 1–20 | 20 | 245 | Inventory, production/conveyors, first construction, early supply and destruction |
| 2 | 21–40 | 20 | 333 | Drone reservation/physical workers/battery, original staging/escrow, recovery |
| 3 | 41–60 | 20 | 258 | Power coverage, energy, finite charging, dispatch, multi-stage construction/cancel |
| 4 | 61–68 | 8 | 87 | Prior final recovery/blackout and new E3d5c6f A/B1/B2/B3 |
| **Total** | **1–68** | **68** | **923** | **FRESH EXECUTION PENDING** |

## Developer-local run protocol

1. Keep local feature branch `feature/e3d5c6f-stage-a-role-contracts`. Preserve any locally modified `.tscn/.tres` resource files; **do not reset, force-checkout, stash without asking, or merge draft PR #1**. To retrieve only new CSV/docs when safe: `git status --short` then `git pull --ff-only origin feature/e3d5c6f-stage-a-role-contracts`.
2. In Godot 4.6.2 run exactly **one current-scene F6 test per manifest row** using path `res://tests/<Scene>`. Use the interactive **Copy scene path / Previous / Next** navigator for each wave; do **not** F5 Main. Run in exact manifest order.
3. Verify expected printed PASS sections and final completion banner, with **no parser, assertion, or runtime errors**. A nonzero/partial output is not a pass. If first failure occurs, **STOP** and report wave, scene, first red error/source line, last PASS marker and screenshot. Do not automatically proceed through the remaining suites.
4. At full local success for a wave, report e.g. **`E3d5c6f B4 Wave 1: all 20/20 passed`**. Record that wave as developer-local acceptance in `HANDOFF.md`, `DEVLOG.md`, `ROADMAP.md`, `DRONE_CONSTRUCTION_LOGISTICS.md`, and this file. Then show the next unrun wave's interactive F6 navigator.
5. **Only** after all four waves pass locally, record new complete 68/68 suite acceptance **against 923 manifest-expected check groups**. This is a suite-level developer-local result, not independently audited check-by-check logs or assistant-executed Godot. B4 closeout may then be proposed; no source/gameplay changes needed for manifest.

## Preservation constraints

- No change to previously accepted scenes, fixtures, `main.tscn` or source gameplay code from this B4 manifest gate.
- No new autonomous dispatch, two-role cancellation recovery, charging/fleet scheduling or Main integration; all are future decisions.
- Draft PR #1 remains unmerged and `main` unchanged. E3d5c6e historical acceptance 63/63/880 remains intact but **does not substitute** for this fresh feature-branch 68-scene run.
- Current result: audit/manifest completed; **Wave 1 20/20 PASS** (245 expected), **Wave 2 20/20 PASS** (333), **Wave 3 20/20 PASS** (258), **Wave 4 8/8 PASS** (87): **68/68 suites ACCEPTED, associated 923 manifest-expected sections**. No assistant-run Godot, no independently inspected assertion-by-assertion log.

## Final acceptance (2026-11-25)

Developer explicitly reported Wave 4 **8/8** F6 scenes passed locally after earlier fresh Waves 1–3 each passed **20/20**. The committed deduplicated manifest is 68 unique paths and 923 manifest-expected groups, not individually audited assertions. Assistant did not run Godot. **Stage B4 and E3d5c6f isolated Stage B are accepted and closed.** Draft PR #1 remains unmerged, Main unchanged, broader cancellation-recovery and Main integration not implemented. [Closeout](DRONE_ROLE_SPECIALIZATION_E3D5C6F_STAGE_B4_CLOSEOUT.md).
