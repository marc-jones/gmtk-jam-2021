extends RigidBody2D

signal person_saved

var max_speed = 80

onready var audio = get_tree().get_root().get_node("Audio")

func _ready():
	add_to_group("person")

func _integrate_forces(state):
	if state.linear_velocity.length() > max_speed:
		state.linear_velocity = state.linear_velocity.normalized()*max_speed

func over_window(shrink_location):
	# AttachPoint presence and absense is being used to determine whether this
	# character has been registered for deletion
	if has_node("AttachPoint"):
		audio.play_sound("saved")
		emit_signal("person_saved", get_position())
		$AttachPoint.queue_free()
		$Tween.interpolate_property(self, "position", get_position(),
			shrink_location, 0.4, Tween.TRANS_EXPO, Tween.EASE_OUT)
		$Tween.interpolate_property(self, "scale", Vector2(1.0, 1.0),
			Vector2(0.0, 0.0), 0.4, Tween.TRANS_EXPO, Tween.EASE_OUT)
		$Tween.connect("tween_all_completed", self, "queue_free")
		$Tween.start()
