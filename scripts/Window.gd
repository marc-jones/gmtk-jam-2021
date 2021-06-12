tool
extends Sprite

var open_tex = preload("res://assets/window_open.svg")

func open():
	texture = open_tex
	$Area2D.monitorable = true
	$Area2D.monitoring = true
	$Area2D.connect("body_entered", self, "body_enter")

func body_enter(body):
	body.over_window(get_position())
