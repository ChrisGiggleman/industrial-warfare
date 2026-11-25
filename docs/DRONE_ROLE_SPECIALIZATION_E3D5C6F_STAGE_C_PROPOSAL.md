# E3d5c6f Stage C — Specialized Drone Cancellation and Physical Cargo Recovery (Proposed)

**Prepared 2026-11-25. READ-ONLY ARCHITECTURE AUDIT NEXT; NOT YET IMPLEMENTED OR APPROVED FOR GAMEPLAY CODE.**

## Accepted entry baseline
E3d5c6f Stage B4 is accepted via developer-local fresh **68/68 unique F6 scenes, 923 manifest-expected check sections**. The opt-in two-drone Press vertical slice preserves five-ingot provenance (Storage 15→10, site buffer, original escrow), distinct logistics/builder physical flight, single tick owner, original power/scheduler and 18-second timer. These are not claims of Main integration, generalized multi-job reuse, or canceled-site recovery. The logistics drone's existing nonterminal return retains original cargo/site provenance.

## C0 read-only source audit (recommended next authorized step)
Inspect exact current implementations of: supplier/return reservations; storage discovery/docks; physical worker drone; owned site staging registry, buffer and port; construction escrow; Stage A role contracts; B2/B3 controllers; scheduler/coordinator; previous E3d5c6c recovery and E3d5c6e blackout recovery. Produce a detailed phase-by-phase table showing **custody owner, claimed source/return capacity, power/battery state, cancellation action, failure rollback and authority to rearm**. Determine missing specialized-role APIs and risks without changing code.

## Candidate phased implementation after separate approval
- **C1:** Cancel before pickup or during outbound flight. Release only the exact original supplier claim; empty logistics drone returns safely. No inventory debit.
- **C2:** Cancel while five ingots are physically in logistics cargo. Use genuine nearest eligible completed Storage, original return-capacity claims, finite physical flight and exact-once deposit. No remote refund, lost items, or free charging.
- **C3:** Cancel after delivery into site-owned buffer or original escrow. Refund/physical recovery must follow original site custody; no buffer retarget, duplicate ledger or teleport. Test capacity-blocked, site-loss and repeat cancellation.
- **C4:** Cancel during distinct builder arrival/construction/blackout. Revoke original scheduler worker slot, freeze progress, return builder using real battery/power; resolve held escrow and physical recovery before any safe reuse.
- **C5:** Targeted and fresh deduplicated regression, then opt-in manual playable review. Main integration requires later separate approval.

## Nonnegotiable invariants
One authoritative explicit simulation tick. Original site/job, escrow, power and worker scheduler retain authority. Real goods only: Storage ↔ physically flying logistics drone ↔ site-owned buffer ↔ original escrow. No new worker readiness from logistics, no synthetic materials, no duplicate stock/capacity claims, no teleporting cargo, no free energy, no second dispatcher, no improperly recycled receipt. All new paths default OFF outside the opt-in E3d5c6f scene. Preserve all accepted tests/scenes, local uncommitted .tres/.tscn files, `main` and unmerged draft PR #1.

**Recommendation:** Approve only **C0 read-only architecture audit** first. Do not start C1 code until the phase-by-phase recovery design is reviewed. Ore varieties, coal/solar/wind, silos, research docks, full fleet scheduling and zombie combat remain separate later milestones.
