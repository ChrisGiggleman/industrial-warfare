# Industrial Warfare — Godot F6 Copy Navigator (Cross-Chat Presentation Requirement)

**Developer-requested preference, accepted 2026-11-22:** This is the preferred format **for all future Industrial Warfare Godot test and playable scene instructions across new chats**. It applies to E3d5c6d Stage B Wave 2, Stage C playable verification, full regression, and later construction/factory/defense milestones.

## Recreate the interactive navigator in each chat

Show **one scene at a time** rather than a long uncopyable list. The user explicitly praised the Stage B Wave 1 copy navigator and asked to retain this feature in future conversations. Use the conversational UI's available **copy action and stateful Next/Previous controls**:

- Clear heading, stage and wave name, suite total, expected check total, and acceptance state.
- Test progress: **TEST N OF M** and a progress indicator; start with the first *unrun* test unless the user asks for a different point.
- Short friendly test title derived from verified manifest data and **exact, validated Godot `res://tests/<scene>.tscn` path** (or `res://scenes/core/<scene>.tscn` for hands-on playable scenes).
- Prominent **Copy scene path** button; its click **actually copies** the path to the clipboard. Do not render a decorative inactive button.
- Working **Previous** / **Next test** buttons; disable at first/last item and update *all* displayed test metadata when navigation changes. Do not change tests or create a new simulation loop to support this UI.
- Show expected individual assertion count and a verified source for the current wave (committed CSV/guide). Offer a plain fenced-code path if buttons aren't supported by a chat.
- For a lengthy wave, allow copy for every test with Previous/Next. Keep test completion claims grounded in developer's local Godot output, not UI navigation or clicking Next.
- Use **F6** for the current Godot test/playable scene, not **F5** running Main.
- After developer reports a wave passed, **record accepted wave in HANDOFF, DEVLOG, ROADMAP and DRONE_CONSTRUCTION_LOGISTICS**, and show a new navigator for the next pending wave, never re-request accepted evidence.

**Do not assume UI state survives a different conversation.** Reconstruct the navigator and its current position from the latest GitHub manifest/accepted checkpoint. Preserve all no-duplicate-dispatcher, exact source/staging, finite-power and Main-scene isolation safeguards independently of this presentation preference.

## Current continuation checkpoint (2026-11-22)

- Repo `ChrisGiggleman/industrial-warfare`, `main`, Godot 4.6.2 Stable.
- E3d5c6d Stage A new isolated automated F6 **16/16 accepted** (developer-reported).
- E3d5c6d Stage B **Wave 1 12/12 suites accepted locally**, covering **155 manifest-expected checks** (not assistant-run, no check-by-check logs supplied).
- **NEXT: Stage B Wave 2 — 27 suites / 381 expected rerun checks**, from `tools/unified_construction_e3d5c6d_stage_b_compatibility.csv` where `Wave=2`. Show a 27-item navigator exactly as above, starting Test 1 of 27. All target scene paths are under `res://tests/`; F6 each independently.
- After Wave 2 acceptance, Stage C real playable scene `res://scenes/core/playable_unified_construction_e3d5c6d.tscn` and later final fresh combined 62-suite baseline; neither is claimed run yet.
