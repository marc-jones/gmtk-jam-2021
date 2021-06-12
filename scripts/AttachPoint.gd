extends Node2D

var radius = 30.0

var radius_squared = radius*radius

var overlay_packed = preload("res://nodes/AttachOverlay.tscn")
onready var global = get_tree().get_root().get_node("Global")

func _ready():
	add_to_group("attach_points")

func has_point(input_vec):
	return(get_global_position().distance_squared_to(input_vec) <= radius_squared)

func _process(delta):
	if global.display_attach_overlay:
		if not has_node("AttachOverlay"):
			add_child(overlay_packed.instance())
	else:
		if has_node("AttachOverlay"):
			$AttachOverlay.queue_free()
			remove_child($AttachOverlay)
