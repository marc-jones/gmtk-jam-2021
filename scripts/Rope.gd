extends Node2D

var rope_segment_height = 10.0
var rope_segment_radius = 4.0
var rope_thickness = 8.0

var start_attach_point
var end_attach_point
var curve

func _ready():
	create_segments()
	attach_to_objects()

func _physics_process(_delta):
	update()

func _draw():
	refresh_curve()
	draw_polyline(curve.get_baked_points(), Color("#a77b5b"), rope_thickness, true)

func init(start_in, end_in):
	start_attach_point = start_in
	end_attach_point = end_in

func refresh_curve():
	var segments = $Bodies.get_children()
	curve = Curve2D.new()
	curve.add_point(segments[0].get_position() +
		rope_segment_height*0.5*Vector2.UP.rotated(segments[0].get_rotation()))
	for child in segments:
		curve.add_point(child.get_position())
	curve.add_point(segments[-1].get_position() +
		rope_segment_height*0.5*Vector2.DOWN.rotated(segments[-1].get_rotation()))
	smooth_curve()

func smooth_curve():
	for idx in range(curve.get_point_count()):
		var prev_idx = idx-1
		var next_idx = idx+1
		if idx == 0 or idx == curve.get_point_count()-1:
			prev_idx = curve.get_point_count()-2
			next_idx = 1
		var idx_vec = curve.get_point_position(idx)
		var prev_vec = curve.get_point_position(prev_idx) - idx_vec
		var next_vec = curve.get_point_position(next_idx) - idx_vec
		var prev_len = prev_vec.length()
		var next_len = next_vec.length()
		var dir_vec = ((prev_len / next_len) * next_vec - prev_vec).normalized()
		curve.set_point_in(idx, -dir_vec*(prev_len/3))
		curve.set_point_out(idx, dir_vec*(next_len/3))

func create_segments():
	var start_position = start_attach_point.get_global_position()
	var end_position = end_attach_point.get_global_position()
	var length = start_position.distance_to(end_position)
	var angle = start_position.angle_to_point(end_position) + PI/2
	var previous_segment
	for idx in range(ceil(length / rope_segment_height)):
		var segment = RigidBody2D.new()
		segment.set_collision_layer_bit(0, false)
		segment.set_collision_layer_bit(2, true)
		var shape = CollisionShape2D.new()
		var capsule = CapsuleShape2D.new()
		capsule.set_height(rope_segment_height)
		capsule.set_radius(rope_segment_radius)
		shape.set_shape(capsule)
		segment.add_child(shape)
		segment.set_position(start_position +
			(rope_segment_height*idx + rope_segment_height*0.5) *
			start_position.direction_to(end_position))
		segment.set_rotation(angle)
		segment.set_mass(0.1)
		$Bodies.add_child(segment)
		if not previous_segment == null:
			var joint = PinJoint2D.new()
			joint.set_position(start_position +
				(rope_segment_height*(idx-0.5) + rope_segment_height*0.5) *
				start_position.direction_to(end_position))
			joint.node_a = previous_segment.get_path()
			joint.node_b = segment.get_path()
			$Joints.add_child(joint)
		previous_segment = segment

func attach_to_objects():
	var segments = $Bodies.get_children()
	var start_joint = PinJoint2D.new()
	start_joint.set_position(segments[0].get_position() +
		rope_segment_height*0.5*Vector2.UP.rotated(segments[0].get_rotation()))
	start_joint.node_a = segments[0].get_path()
	start_joint.node_b = start_attach_point.get_parent().get_path()
	$Joints.add_child(start_joint)

	var end_joint = PinJoint2D.new()
	end_joint.set_position(segments[-1].get_position() +
		rope_segment_height*0.5*Vector2.DOWN.rotated(segments[0].get_rotation()))
	end_joint.node_a = segments[-1].get_path()
	end_joint.node_b = end_attach_point.get_parent().get_path()
	$Joints.add_child(end_joint)
