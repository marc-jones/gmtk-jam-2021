extends Node2D

func _ready():
	$Rows/Menu.connect("pressed", get_parent(), "return_to_menu", [self])
