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
