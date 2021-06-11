extends Node2D

var pressed_position
var drag_position

var rope_packed = preload("res://nodes/Rope.tscn")

func _ready():
	pass

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			pressed_position = event.position
		else:
			create_rope(pressed_position, event.position)
			pressed_position = null
			update()
	if event is InputEventScreenDrag:
		if not pressed_position == null:
			drag_position = event.position
			update()

func _draw():
	if not pressed_position == null:
		draw_line(pressed_position, drag_position,
			Color(255, 0, 0), 2)

func create_rope(start_position, end_position):
	if has_node("Rope"):
		var old_rope = get_node("Rope")
		remove_child(old_rope)
		old_rope.queue_free()
	var rope = rope_packed.instance()
	rope.init(start_position, end_position)
	add_child(rope)
