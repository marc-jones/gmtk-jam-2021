extends Node2D

var tween_duration = 1.0
var tween_curve = Tween.TRANS_LINEAR
var tween_ease = Tween.EASE_IN_OUT

var packed_play = preload("res://nodes/PlayScene.tscn")
var packed_credits = preload("res://nodes/CreditsScene.tscn")

onready var audio = get_tree().get_root().get_node("Audio")

func _ready():
	$Menu/Buttons/Start.connect("pressed", self, "start_game")
	$Menu/Buttons/Credits.connect("pressed", self, "start_credits")

func start_game():
	audio.play_sound("create_rope")
	var screen_y = get_viewport_rect().size.y
	var play_scene = packed_play.instance()
	play_scene.set_position(Vector2(0.0, screen_y))
	add_child(play_scene)
	$Tween.interpolate_property($Menu, "position",
		$Menu.get_position(), $Menu.get_position() + Vector2(0.0, -screen_y),
		tween_duration, tween_curve, tween_ease)
	$Tween.interpolate_property(play_scene, "position",
		play_scene.get_position(), Vector2(0.0, 0.0),
		tween_duration, tween_curve, tween_ease)
	$Tween.connect("tween_all_completed", play_scene, "begin", [], CONNECT_ONESHOT)
	$Tween.start()

func start_credits():
	audio.play_sound("create_rope")
	var screen_y = get_viewport_rect().size.y
	var credits_scene = packed_credits.instance()
	credits_scene.set_position(Vector2(0.0, screen_y))
	add_child(credits_scene)
	$Tween.interpolate_property($Menu, "position",
		$Menu.get_position(), $Menu.get_position() + Vector2(0.0, -screen_y),
		tween_duration, tween_curve, tween_ease)
	$Tween.interpolate_property(credits_scene, "position",
		credits_scene.get_position(), Vector2(0.0, 0.0),
		tween_duration, tween_curve, tween_ease)
	$Tween.start()

func return_to_menu(other_scene):
	audio.play_sound("create_rope")
	var screen_y = get_viewport_rect().size.y
	$Tween.interpolate_property($Menu, "position",
		$Menu.get_position(), Vector2.ZERO,
		tween_duration, tween_curve, tween_ease)
	$Tween.interpolate_property(other_scene, "position",
		other_scene.get_position(), other_scene.get_position() + Vector2(0.0, screen_y),
		tween_duration, tween_curve, tween_ease)
	$Tween.connect("tween_all_completed", other_scene, "queue_free", [], CONNECT_ONESHOT)
	$Tween.start()
