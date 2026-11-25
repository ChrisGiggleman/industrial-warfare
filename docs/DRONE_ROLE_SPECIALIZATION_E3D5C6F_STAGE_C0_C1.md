# E3d5c6f C0 audit and C1 implementation gate

### 2026-11-25 — E3d5c6f C1 FULLY ACCEPTED; C2 proposal

Developer confirmed C1 targeted compatibility 22/22 F6 scenes passed locally against 295 manifest-expected sections on 2026-11-25, following isolated 12/12 acceptance. C1 FULLY ACCEPTED: 23 gate scene runs / 307 associated expected sections, of which 22/295 overlap B4. Unique accepted coverage 69 suites / 935 expected sections; last fresh full B4 68/923 remains distinct. Assistant did not run Godot or inspect individual assertion logs. Next C2 scoped plan awaits explicit implementation approval. [C2 implementation plan](DRONE_ROLE_SPECIALIZATION_E3D5C6F_STAGE_C2_PLAN.md). Documentation-only checkpoint; Main, all previously accepted scenes/tests, local edits and draft PR #1 preserved. No C2 gameplay code or new F6 fixture yet.


### 2026-11-25 — C1 isolated ACCEPTED; compatibility PENDING

Developer confirmed all 12/12 labeled C1 sections passed locally in Godot against implementation commit acec11e64df4d9987a8156e63bc68f7ff59ad56f. Assistant did not execute Godot. Cumulative unique accepted coverage 69 suites / 935 expected sections (68/923 historical fresh B4 + 1/12 C1); no fresh full 69-suite regression claimed. Targeted compatibility 22 existing scenes / 295 manifest-expected sections PENDING; these overlap B4 and must not inflate unique coverage. C2 remains gated on developer-local compatibility acceptance. Main, accepted scenes/tests, local edits and unmerged draft PR #1 preserved. [Compatibility guide](DRONE_ROLE_SPECIALIZATION_E3D5C6F_STAGE_C1_COMPATIBILITY.md).


Approved by developer after B4 68/68 unique local F6 scenes / 923 manifest-expected sections. Base fd4772b1562ab. No new Godot run claimed.

## C0 custody and authority
| Phase | Custody | Cancellation |
|---|---|---|
| Before dispatch / reserved / outbound / arrived before collect | Original Storage | Release exact supplier claim, no debit, empty metered return |
| Collected / delivery flight / arrival before unload | Logistics cargo | Reserve real eligible return dock capacity, physical deposit exactly once (C2) |
| Delivered before escrow | Original locked staging | Capture exact site/job/port/buffer/hover, physical collection (C3) |
| Escrow held / empty logistics return | Original escrow | Original cancellation signal refunds same buffer; retain escrow if unsettled, then recover physically (C3) |
| Builder flight / work / paused | Escrow then original staging | Original scheduler/coordinator revoke worker/power, builder empty return; logistics recovery separately (C4) |
| Complete | Committed bill | Reject cancellation; destruction separate |

No remote refunds, fabricated stock, duplicate reservation or free energy. One authoritative tick; normal B2/B3 guards reject terminal jobs, so a dedicated terminal phase must continue return after site cancellation. Role revocation is a tombstone, not a material refund. Original recovery audit and power parking scopes do not include specialized scene; do not install the old dispatcher. Capture custody before cancellation; verify settlement after synchronous callbacks. Full cargo, storage loss, unsettled escrow, alternate dock and site-loss recovery deferred to C2/C3. Construction blackout differs from battery exhaustion; hub charging requires actual spare generation. C4 handles parked/active builder release; no canceled job resumes.

## C1 implementation
Default-off B2 companion methods on same controller and tick token. C1 explicitly separates reserve, launch and arrival from collection; it never collects or continues successful delivery (normal B2 remains unchanged when C1 off). Original job.cancel triggers supplier release and role revocation, terminal phase verifies physical zero cargo, source 15, empty staging/escrow and no active worker. Uses existing metered return and pre-pickup rearm with original supplier/return/coordinator/scheduler services. A single finite hub charging service uses the existing left logistics berth only in exact opt-in scope; no drone repositioning. Unlaunched reservation has no flight assignment to rearm. Revoked lease remains a tombstone; C1 does not authorize another mission or implement generalized fleet reuse. No old scene/test edits, no Main changes.

F6 pending: res://tests/specialized_drone_pre_pickup_cancel_e3d5c6f_c1_test.tscn — 12 labeled sections A–L (labels may appear out of alphabetical order), final banner E3d5c6f C1 isolated F6: 12/12 labeled sections passed. No assistant Godot execution. Stop on first error. After local isolated acceptance, targeted compatibility then C2 approval. Historical baseline remains 68/923, not incremented until developer confirms. Preserve local .tres/.tscn edits and draft PR #1 unmerged.
