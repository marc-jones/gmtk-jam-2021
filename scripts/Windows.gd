tool
extends Node2D

var row_coords = [160, 250, 430, 520, 610]
var number_of_cols = 5

var open_window = [2, 430]

var window_packed = preload("res://nodes/Window.tscn")

func _ready():
	var tmp_node = add_window()
	var window_size = tmp_node.texture.get_size() * tmp_node.scale
	tmp_node.queue_free()
	var x_spacing = (get_viewport_rect().size.x - number_of_cols*window_size.x) / (number_of_cols + 1)
	for col_idx in range(number_of_cols):
		for row in row_coords:
			var window = add_window()
			window.set_position(Vector2(x_spacing*(col_idx+1) + (col_idx+0.5)*window_size.x, row))
			if open_window[0] == col_idx and open_window[1] == row:
				window.open()

func add_window():
	var node = window_packed.instance()
	add_child(node)
	return(node)
