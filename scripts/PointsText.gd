extends Node2D

var tween_duration = 1.0
var tween_curve = Tween.TRANS_EXPO
var tween_ease = Tween.EASE_OUT

func _ready():
	$Tween.interpolate_property(self, "position", get_position(),
		get_position()+Vector2(0, -50), tween_duration, tween_curve, tween_ease)
	$Tween.interpolate_property(self, "scale", Vector2.ONE,
		Vector2.ONE*1.5, tween_duration, tween_curve, tween_ease)
	$Tween.interpolate_property(self, "modulate", Color(1,1,1,1),
		Color(1,1,1,0), tween_duration, tween_curve, Tween.EASE_IN)
	$Tween.connect("tween_all_completed", self, "queue_free")
	$Tween.start()

func set_text(input_text, colour):
	$Label.text = input_text
	$Label.set("custom_colors/font_color", colour)
