extends Node2D

var points = 0
var neg_col = "#b45252"
var pos_col = "#8ab060"

func record_points(amount):
	points += amount
	points = clamp(points, 0, points)
	$Number.text = "%010d" % points
	if amount < 0:
		$AnimationPlayer.play("negative")
	else:
		$AnimationPlayer.play("positive")

func update_timer(time_left):
	var minutes = "%02d" % (int(time_left) / 60)
	var seconds = "%02d" % (int(time_left) % 60)
	$Clock.text = minutes + ':' + seconds
