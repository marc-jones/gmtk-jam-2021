extends RigidBody2D

var max_speed = 80

func _ready():
	pass # Replace with function body.

func _integrate_forces(state):
	if state.linear_velocity.length()>max_speed:
		state.linear_velocity=state.linear_velocity.normalized()*max_speed
