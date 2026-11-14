extends Node3D

# E3d5c5f — source identity across authorization and live belt delivery.
# All new behavior is opt-in and limited to a real sandbox test instance.
# Source substitution/deletion never creates stock, releases claims or
# grants any blueprint construction readiness.

func _ready() -> void:
	call_deferred("_checks")


func _place(world: Node, definition: BuildingDefinition, at: Vector3) -> ConstructionSite:
	var transform := Transform3D(Basis.IDENTITY, at)
	assert(world.call("_blueprint_placement_clear", definition, transform))
	var site := world.call("_create_blueprint_site", definition, transform) as ConstructionSite
	assert(site != null and site.job.state == ConstructionJob.State.PLANNED)
	site.set_process(false)
	return site


func _source(sandbox: Node3D, item: ItemDefinition, name_text: String,
	amount: int
) -> Dictionary:
	var building := Node3D.new()
	building.name = name_text
	sandbox.add_child(building)
	var stock := InventoryComponent.new()
	stock.max_capacity = 10
	building.add_child(stock)
	assert(stock.add_item(item, amount) == amount)
	var output := ItemPortComponent.new()
	output.name = "OutputPort"
	output.direction = ItemPortComponent.PortDirection.OUTPUT
	output.show_port_label = false
	output.inventory = stock
	building.add_child(output)
	return {"building": building, "stock": stock, "output": output}


func _checks() -> void:
	var def := load("res://data/buildings/test_storage.tres") as BuildingDefinition
	var ingot := load("res://data/items/test_ingot.tres") as ItemDefinition
	assert(def != null and ingot != null)
	var main := (load("res://scenes/core/main.tscn") as PackedScene).instantiate()
	assert(main.get_node_or_null("ConstructionDroneLifecycleGate") == null)
	main.free()
	print("PASS A: Main gameplay remains isolated from source validation")

	var packed := load("res://scenes/core/factory_testing_sandbox.tscn") as PackedScene
	assert(packed != null)
	var sandbox := packed.instantiate() as Node3D
	var gate := sandbox.get_node("ConstructionDroneLifecycleGate") as SandboxConstructionDroneLifecycleGate
	var world: Node = sandbox.get_node("WorldInteraction")
	assert(not gate.enable_isolated_bridge)
	assert(not gate.enable_isolated_authorization_autowire)
	assert(not gate.enable_isolated_output_enrollment)
	assert(bool(world.get("blueprint_sandbox_debug_requirements")))
	print("PASS B: Committed sandbox still defaults all source gates OFF")

	add_child(sandbox)
	world.set_process(false)
	var swap_site := _place(world, def, Vector3(-5, 0, 2))
	var gone_site := _place(world, def, Vector3(-13, 0, 2))
	var live_site := _place(world, def, Vector3(-5, 0, 10))
	var removed_live_site := _place(world, def, Vector3(-13, 0, 10))
	assert(swap_site.job.state == ConstructionJob.State.PLANNED)
	assert(gone_site.job.state == ConstructionJob.State.PLANNED)
	assert(live_site.job.state == ConstructionJob.State.PLANNED)
	assert(removed_live_site.job.state == ConstructionJob.State.PLANNED)
	print("PASS C: Four actual player blueprints are PLANNED and not authorized")

	var swap_source: Dictionary = _source(sandbox, ingot, "SwapPreAuthorization", 2)
	var gone_source: Dictionary = _source(sandbox, ingot, "DeletedPreAuthorization", 2)
	var live_source: Dictionary = _source(sandbox, ingot, "SourceForRealBelt", 4)
	var removed_source: Dictionary = _source(sandbox, ingot, "DeletedAfterAuthorization", 3)
	var swap_output := swap_source["output"] as ItemPortComponent
	var gone_output := gone_source["output"] as ItemPortComponent
	var live_output := live_source["output"] as ItemPortComponent
	var removed_output := removed_source["output"] as ItemPortComponent
	assert(gate.prepare_player_site_from_output(swap_site, swap_output) == null)
	print("PASS D: Unconfigured gate refuses existing outputs before opt-in")

	var registry := BlueprintConstructionSiteStagingRegistry.new()
	registry.enable_isolated_site_registry = true
	sandbox.add_child(registry)
	var escrow := BlueprintConstructionMaterialEscrow.new()
	sandbox.add_child(escrow)
	gate.enable_isolated_bridge = true
	gate.enable_isolated_authorization_autowire = true
	gate.enable_isolated_output_enrollment = true
	assert(not gate.configure_authorization_autowire(registry, escrow))
	world.set("blueprint_sandbox_debug_requirements", false)
	assert(gate.configure_authorization_autowire(registry, escrow))
	assert(not gate.configure_authorization_autowire(registry, escrow))
	print("PASS E: Real sandbox debug bypass must be OFF to enroll output sources")

	var swapped_staging := gate.prepare_player_site_from_output(swap_site, swap_output)
	assert(swapped_staging != null)
	var original_swap := swap_source["stock"] as InventoryComponent
	assert(swapped_staging.matches_source_inventory(original_swap))
	var replacement := InventoryComponent.new()
	replacement.max_capacity = 10
	(swap_source["building"] as Node3D).add_child(replacement)
	swap_output.inventory = replacement
	assert(replacement.get_total_amount() == 0)
	print("PASS F: Enrolled output can be redirected to a different same-owner inventory")

	assert(world.call("_authorize_blueprint_site", swap_site))
	assert(gate.receiver_for_authorized_site(swap_site) == null)
	assert(swap_site.job.state == ConstructionJob.State.QUEUED)
	assert(registry.claim_count() == 0)
	assert(swapped_staging.get_staged_inventory().get_total_amount() == 0)
	print("PASS G: Authorization refuses replaced inventory with no receiver or claim")

	var gone_staging := gate.prepare_player_site_from_output(gone_site, gone_output)
	assert(gone_staging != null)
	gone_output.queue_free()
	assert(gone_output.is_queued_for_deletion())
	assert(world.call("_authorize_blueprint_site", gone_site))
	assert(gate.receiver_for_authorized_site(gone_site) == null)
	assert(registry.claim_count() == 0)
	print("PASS H: Pre-authorization source deletion fails closed")

	var live_staging := gate.prepare_player_site_from_output(live_site, live_output)
	assert(live_staging != null)
	var live_stock := live_source["stock"] as InventoryComponent
	var live_buffer: InventoryComponent = live_staging.get_staged_inventory()
	assert(live_staging.matches_source_inventory(live_stock))
	assert(live_buffer.get_total_amount() == 0)
	assert(live_stock.get_amount(ingot) == 4)
	print("PASS I: Valid source enrollment creates only empty bill-sized staging")

	assert(live_site.job.set_priority(ConstructionJob.Priority.HIGH))
	assert(live_site.job.state == ConstructionJob.State.PLANNED)
	assert(gate.receiver_for_authorized_site(live_site) == null)
	print("PASS J: Priority alone cannot bind any source or authorize building")

	assert(world.call("_authorize_blueprint_site", live_site))
	var receiver := gate.receiver_for_authorized_site(live_site)
	assert(receiver != null and receiver.matches_attached_site())
	assert(receiver.enable_isolated_escrow_intake_lock)
	assert(receiver.enable_isolated_output_source_guard)
	assert(not receiver.is_output_source_locked())
	assert(receiver.can_accept_item(ingot))
	assert(registry.claim_count() == 1)
	print("PASS K: Real authorization binds escrow AND original output identity")

	var belt := (
		load("res://scenes/logistics/conveyor_straight.tscn") as PackedScene
	).instantiate() as ConveyorSegment
	assert(belt != null)
	sandbox.add_child(belt)
	var timer := belt.get_node("ConveyorTransportTimer") as ConveyorTransportTimer
	var cargo := belt.get_node("ConveyorTransportComponent") as ConveyorTransportComponent
	assert(timer != null and cargo != null)
	timer.set_process(false)
	timer.travel_interval = 1.0
	var snap: Dictionary = ConveyorBuildingSnap.get_preview_transform(receiver, belt)
	assert(snap.has("transform"))
	belt.global_transform = snap["transform"]
	assert(belt.try_connect_building_port(receiver))
	var endpoint := belt.get_node("InputEndpoint") as Marker3D
	assert(endpoint != null)
	var supplier := live_source["building"] as Node3D
	supplier.global_transform = Transform3D(
		endpoint.global_transform.basis * Basis(Vector3.UP, PI),
		endpoint.global_position
	)
	assert(LogisticsConnectionGeometry.are_endpoints_aligned(
		live_output, endpoint, ConveyorSegment.CONNECTION_GAP
	))
	assert(belt.try_connect_building_port(live_output))
	print("PASS L: Reciprocal physical belt links enrolled source to its receiver")

	timer._process(0.01)
	assert(cargo.get_held_item() == ingot)
	assert(timer.advance_transport(1.0))
	assert(live_buffer.get_amount(ingot) == 1)
	assert(live_stock.get_amount(ingot) == 3)
	assert(escrow.held_count() == 0)
	print("PASS M: First real ingot travels from pinned source into owned buffer")

	timer._process(0.01)
	assert(cargo.get_held_item() == ingot)
	var replacement_live := InventoryComponent.new()
	replacement_live.max_capacity = 10
	supplier.add_child(replacement_live)
	live_output.inventory = replacement_live
	assert(receiver.is_output_source_locked())
	assert(not receiver.can_accept_item(ingot))
	assert(not timer.advance_transport(1.0))
	assert(cargo.cargo_inventory.get_amount(ingot) == 1)
	print("PASS N: Post-authorization inventory swap blocks belt before delivery")

	live_output.inventory = live_stock
	assert(receiver.is_output_source_locked())
	assert(not receiver.can_accept_item(ingot))
	assert(not timer.advance_transport(0.01))
	print("PASS O: Restoring original pointer cannot clear observed source tampering")

	receiver.enable_isolated_output_source_guard = false
	assert(receiver.is_output_source_locked())
	assert(not receiver.can_accept_item(ingot))
	receiver.enable_isolated_output_source_guard = true
	assert(receiver.is_output_source_locked())
	assert(live_buffer.get_amount(ingot) == 1)
	print("PASS P: Feature toggle never reopens a compromised material receiver")

	var removed_staging := gate.prepare_player_site_from_output(
		removed_live_site, removed_output
	)
	assert(removed_staging != null)
	assert(world.call("_authorize_blueprint_site", removed_live_site))
	var removed_port := gate.receiver_for_authorized_site(removed_live_site)
	assert(removed_port != null and not removed_port.is_output_source_locked())
	assert(registry.claim_count() == 2)
	removed_output.queue_free()
	assert(removed_output.is_queued_for_deletion())
	assert(removed_port.is_output_source_locked())
	assert(not removed_port.can_accept_item(ingot))
	print("PASS Q: Removing an authorized site's original output closes that intake")

	assert(live_site.job.cancel())
	assert(removed_live_site.job.cancel())
	assert(escrow.held_count() == 0)
	assert(registry.claim_count() == 2)
	assert(not receiver.can_accept_item(ingot))
	assert(not removed_port.can_accept_item(ingot))
	print("PASS R: Cancellation closes both receivers without releasing owner claims")

	var recovered := InventoryComponent.new()
	recovered.max_capacity = 3
	sandbox.add_child(recovered)
	assert(cargo.cargo_inventory.transfer_to(recovered, ingot, 1) == 1)
	assert(recovered.get_amount(ingot) == 1)
	assert(live_buffer.get_amount(ingot) == 1)
	assert(live_stock.get_amount(ingot) == 2)
	assert(recovered.get_amount(ingot) + live_buffer.get_amount(ingot)
		+ live_stock.get_amount(ingot) == 4)
	print("PASS S: Blocked cargo recovers; original four ingots remain accounted for")

	assert(swap_site.job.state == ConstructionJob.State.QUEUED)
	assert(gone_site.job.state == ConstructionJob.State.QUEUED)
	assert(gate.receiver_for_authorized_site(swap_site) == null)
	assert(gate.receiver_for_authorized_site(gone_site) == null)
	assert(registry.claim_count() == 2)
	assert(sandbox.get_node_or_null("ConstructionPriorityDock") != null)
	assert(sandbox.get_node_or_null("ConstructionAuthorizationDock") != null)
	assert(sandbox.get_node_or_null("PrototypeConstructionDroneTickController") == null)
	print("PASS T: Invalid sources never gain receivers; existing UI and workers unchanged")

	print("ALL 20 E3D5C5F FACTORY SOURCE IDENTITY TESTS PASSED")
	print("TEST ONLY: Explicit sources; permanent observed-fault intake lock; no auto-discovery or save.")
