extends Node2D

var rope_packed = preload("res://nodes/Rope.tscn")
onready var overlay = get_node("Overlay")

var mouse_pressed = false

func _ready():
	pass

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			mouse_pressed = true
			for attach_point in get_tree().get_nodes_in_group("attach_points"):
				if attach_point.has_point(event.position):
					overlay.pressed_attach_point = attach_point
					overlay.start_display_attach_points()
		else:
			mouse_pressed = false
			if not overlay.pressed_attach_point == null:
				for attach_point in get_tree().get_nodes_in_group("attach_points"):
					if (attach_point.has_point(event.position) and
						not attach_point == overlay.pressed_attach_point):
						create_rope(overlay.pressed_attach_point,
							attach_point)
				overlay.pressed_attach_point = null
				overlay.end_display_attach_points()

func create_rope(start_attach_point, end_attach_point):
	if has_node("Rope"):
		var old_rope = get_node("Rope")
		remove_child(old_rope)
		old_rope.queue_free()
	var rope = rope_packed.instance()
	rope.init(start_attach_point, end_attach_point)
	add_child(rope)

func _process(delta):
	if not overlay.pressed_attach_point == null:
		var mouse_pos = get_viewport().get_mouse_position()
		overlay.drag_position = mouse_pos
		overlay.joined_bool = false
		for attach_point in get_tree().get_nodes_in_group("attach_points"):
			if attach_point.has_point(mouse_pos):
				overlay.drag_position = attach_point.get_global_position()
				overlay.joined_bool = true
