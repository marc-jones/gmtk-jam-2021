extends Node2D

var pressed_attach_point
var drag_position
var joined_bool = false
var display_attach_points = false

var neg_col = "b45252"
var pos_col = "8ab060"

var attach_packaged = preload("res://nodes/AttachOverlay.tscn")

func _draw():
	if not pressed_attach_point == null and not drag_position == null:
		var col = neg_col
		if joined_bool:
			col = pos_col
		draw_line(pressed_attach_point.get_global_position(), drag_position,
			Color("#dd" + col), 6.0, true)

func _process(_delta):
	update()
