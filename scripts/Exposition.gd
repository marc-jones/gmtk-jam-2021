extends Node2D

signal exposition_done

var time_on_screen = 1.0
var tween_duration = 0.6
var tween_curve = Tween.TRANS_BACK

func _ready():
	add(1)

func add(num):
	$Tween.interpolate_property(get_node(str(num)), "scale", Vector2.ZERO,
		Vector2.ONE, tween_duration, tween_curve, Tween.EASE_OUT, time_on_screen)
	$Tween.connect("tween_all_completed", self, "remove", [num], CONNECT_ONESHOT)
	$Tween.start()

func remove(num):
	$Tween.interpolate_property(get_node(str(num)), "scale", Vector2.ONE,
		Vector2.ZERO, tween_duration, tween_curve, Tween.EASE_IN, time_on_screen)
	if num + 1 == get_child_count():
		$Tween.connect("tween_all_completed", self, "emit_signal",
			["exposition_done"], CONNECT_ONESHOT)
	else:
		$Tween.connect("tween_all_completed", self, "add", [num+1], CONNECT_ONESHOT)
	$Tween.start()
