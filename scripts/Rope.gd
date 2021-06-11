extends Node2D

var rope_segment_height = 10.0
var rope_segment_radius = 4.0
var rope_thickness = 8.0

var start_position
var end_position
var curve

func _ready():
	create_segments()

func _physics_process(delta):
	update()

func _draw():
	refresh_curve()
	draw_polyline(curve.get_baked_points(), Color.black, rope_thickness)

func init(start_in, end_in):
	start_position = start_in
	end_position = end_in

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
	var length = start_position.distance_to(end_position)
	var angle = start_position.angle_to_point(end_position) + PI/2
	var previous_segment
	for idx in range(ceil(length / rope_segment_height)):
		var segment = RigidBody2D.new()
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
