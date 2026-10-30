extends RefCounted
class_name ConveyorPathMotion


# =============================================================================
# UNIFORM CARGO SPEED OVER DIFFERENT BELT LENGTHS
# =============================================================================

# An ordinary 1-unit conveyor takes its exported timer interval to travel.
# Special-length conveyors retain that SAME physical speed by scaling their
# travel interval to the measured input-to-output path length.
#
# Visual movement uses exactly the same path geometry, with corner progress
# allocated proportionally to each leg instead of always splitting 50/50.
#
# Does not modify inventory contents or connection logic.

const STANDARD_LENGTH: float = 1.0
const MIN_INTERVAL: float = 0.05


static func _is_corner(
	input_endpoint: Marker3D,
	output_endpoint: Marker3D
) -> bool:
	var input_forward: Vector3 = (
		input_endpoint.transform.basis * Vector3.FORWARD
	).normalized()
	var output_forward: Vector3 = (
		output_endpoint.transform.basis * Vector3.FORWARD
	).normalized()
	return absf(input_forward.dot(output_forward)) < 0.1


static func _bend_position(
	input_endpoint: Marker3D,
	output_endpoint: Marker3D
) -> Vector3:
	var start: Vector3 = input_endpoint.position
	var finish: Vector3 = output_endpoint.position
	return Vector3(start.x, start.y, finish.z)


static func get_path_length(
	input_endpoint: Marker3D,
	output_endpoint: Marker3D
) -> float:
	if not is_instance_valid(input_endpoint):
		return 0.0
	if not is_instance_valid(output_endpoint):
		return 0.0

	var start: Vector3 = input_endpoint.position
	var finish: Vector3 = output_endpoint.position
	if not _is_corner(input_endpoint, output_endpoint):
		return start.distance_to(finish)

	var bend: Vector3 = _bend_position(input_endpoint, output_endpoint)
	return start.distance_to(bend) + bend.distance_to(finish)


static func position_at_progress(
	input_endpoint: Marker3D,
	output_endpoint: Marker3D,
	progress: float
) -> Vector3:
	if not is_instance_valid(input_endpoint):
		return Vector3.ZERO
	if not is_instance_valid(output_endpoint):
		return Vector3.ZERO

	var start: Vector3 = input_endpoint.position
	var finish: Vector3 = output_endpoint.position
	var fraction: float = clampf(progress, 0.0, 1.0)

	if not _is_corner(input_endpoint, output_endpoint):
		return start.lerp(finish, fraction)

	var bend: Vector3 = _bend_position(input_endpoint, output_endpoint)
	var first_length: float = start.distance_to(bend)
	var second_length: float = bend.distance_to(finish)
	var total_length: float = first_length + second_length
	if total_length <= 0.00001:
		return start

	var travelled: float = fraction * total_length

	if travelled <= first_length:
		if first_length <= 0.00001:
			return bend
		return start.lerp(bend, travelled / first_length)

	if second_length <= 0.00001:
		return finish
	return bend.lerp(
		finish,
		(travelled - first_length) / second_length
	)


static func configure_segment(segment: ConveyorSegment) -> bool:
	if not is_instance_valid(segment):
		return false

	var input_endpoint := (
		segment.get_node_or_null("InputEndpoint") as Marker3D
	)
	var output_endpoint := (
		segment.get_node_or_null("OutputEndpoint") as Marker3D
	)
	var timer := (
		segment.get_node_or_null("ConveyorTransportTimer")
		as ConveyorTransportTimer
	)

	if (
		not is_instance_valid(input_endpoint)
		or not is_instance_valid(output_endpoint)
		or not is_instance_valid(timer)
	):
		return false

	var length: float = get_path_length(input_endpoint, output_endpoint)
	if length <= 0.0:
		return false

	# Keep the original prefab timing as the units/second baseline.
	# Storing it allows safe reconfiguration without double-scaling.
	if not segment.has_meta("base_travel_interval"):
		segment.set_meta("base_travel_interval", timer.travel_interval)

	var base_interval: float = float(
		segment.get_meta("base_travel_interval")
	)
	if base_interval <= 0.0:
		return false

	timer.travel_interval = maxf(
		MIN_INTERVAL,
		base_interval * (length / STANDARD_LENGTH)
	)
	return true
