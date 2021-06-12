extends Node2D

var radius = 30.0

var radius_squared = radius*radius

func _ready():
	add_to_group("attach_points")

func has_point(input_vec):
	return(get_global_position().distance_squared_to(input_vec) <= radius_squared)
