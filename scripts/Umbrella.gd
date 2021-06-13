extends RigidBody2D

var max_speed = 40

func _ready():
	add_to_group("umbrella")

func _integrate_forces(state):
	if state.linear_velocity.length() > max_speed:
		state.linear_velocity = state.linear_velocity.normalized()*max_speed
