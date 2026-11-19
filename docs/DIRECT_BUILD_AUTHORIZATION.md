# E3d5c6b — Direct Build Authorization (proposed, not implemented)

2026-11-18. Prerequisite E3d5c6a fully accepted: 56/56 targeted automated suites, 785/785 checks, expansion manual 9/9; historical Storage manual 9/9 separate. Developer reported local Godot results. See BUILDING_EXPANSION_FINAL_REGRESSION.md and HANDOFF.md. This is a proposed sequence, not a code change or test claim.

## Player workflow agreed earlier

- Build mode: a valid placement click is itself explicit authorization. Create a non-operational construction site and submit the same original job to the same queue at Normal priority, with no second E. A queued job may wait for stock, worker, route/power/energy; click does not promise immediate dispatch.
- Blueprint mode: placement stays PLANNED; Q+drag and L/N/H only change priority, E/Ctrl+E explicitly authorize existing selected/all plans. No change to existing behavior.
- Both paths share the same ownership, inventory, receiver, queue, escrow, worker, power, timing, cancellation and lifecycle authority. No immediate completed buildings, free resources, duplicate jobs/drivers or preemption.

## Source inspection before implementation

Inspect actual main versions of `scripts/world_interaction.gd` (especially _try_place_object, _commit_blueprint_from_preview, _create_blueprint_site, _authorize_blueprint_site, current preview/footprint/snap and cancellation paths), `scripts/ui/playable_automatic_construction_drone_sandbox.gd` (scene allowlist, verified services, enrollment), existing expansion scene and A/B/C tests, construction site/queue/readiness contracts, relevant catalog and input handlers. Check whether selected transforms are fresh and how activation failures are handled. Do not treat proposed method signatures as confirmed APIs. GitHub source takes precedence.

## Proposed phased gates

A — isolated direct placement authorization. Default-off switch and exact new experimental scene; only canonical Storage/Press initially, preserve legacy behavior outside new scope including all prior accepted scenes and Main. Intercept direct placement before legacy instant/timed/conveyor routes in the new scope. Reuse current validated preview transform and site creation and original authorization. Fail closed on invalid placement, unsupported definition, missing verified services or failed enrollment; avoid orphan authorized jobs or fallback completed buildings. No requirement to change general-scene behavior. Test invalid/blocked/stale placement, duplicate clicks, successful Normal job, no materials/time bypass, no E necessary, explicit Blueprint authorization unchanged, priority/order and scope opt-out. Inspect before choosing rollback behavior; preserve evidence and existing ownership invariants.

B — real playable direct construction. New isolated test verifies physical 3/5-unit pickup/delivery, finite power/work/battery, 10/18-second construction, actual building activation, mixed Direct/Blueprint orders, missing materials/power, cancellation before pickup/loaded/delivered/working, no duplicates, return/recharge; original accepted behavior unchanged.

C — manual mouse/key workflow, final targeted regression with accepted 56/785 plus new suites, document acceptance. New scene HUD should distinguish Direct Build authorization from Blueprint planning, show queued/waiting state, and avoid misleading unsupported placement. No Main activation.

Later separately gated: automatic conveyor segments and straight/corner/waypoint route snapping; splitter/merger; pole coverage registration; multi-item/multi-trip and large bills; multi-drone; persistence; expanded destruction recovery; specialized Ammo Silos. Do not unlock protected staging in this milestone.

## Acceptance discipline

Inspect current HEAD, stage scoped changes, commit to main with non-force expected-head update, provide exact pull/F6 steps and expected banners. User runs local Godot 4.6.2, reports actual results, record isolated then compatibility and manual acceptance without double-counting. Handoff at each major gate. No independent runtime claims without execution.
