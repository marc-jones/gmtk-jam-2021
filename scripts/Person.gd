extends RigidBody2D

signal points_change

var max_speed = 80

func _ready():
	pass # Replace with function body.

func _integrate_forces(state):
	if state.linear_velocity.length() > max_speed:
		state.linear_velocity = state.linear_velocity.normalized()*max_speed

func over_window(shrink_location):
	$AttachPoint.queue_free()
	$Tween.interpolate_property(self, "position", get_position(),
		shrink_location, 0.4, Tween.TRANS_EXPO, Tween.EASE_OUT)
	$Tween.interpolate_property(self, "scale", Vector2(1.0, 1.0),
		Vector2(0.0, 0.0), 0.4, Tween.TRANS_EXPO, Tween.EASE_OUT)
	$Tween.connect("tween_all_completed", self, "queue_free")
	$Tween.start()
