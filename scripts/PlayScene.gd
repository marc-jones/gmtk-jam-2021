extends Node2D

# Disable exposition for faster development
var debug = false

var global_time = 5*60

var rope_packed = preload("res://nodes/Rope.tscn")
var person_packed = preload("res://nodes/Person.tscn")
var umbrella_packed = preload("res://nodes/Umbrella.tscn")
var points_text_packed = preload("res://nodes/PointsText.tscn")
var exposition_packed = preload("res://nodes/Exposition.tscn")
onready var overlay = get_node("Overlay")

var mouse_pressed = false

var min_person_wait = 5.0
var max_person_wait = 10.0
var min_person_y_offset = -50
var max_person_y_offset = -150
var person_x_margin = 10

var max_umbrella_number = 1
var min_umbrella_wait = 5.0
var max_umbrella_wait = 10.0
var umbrella_x_margin = 30
var umbrella_y_offset = 20

var neg_col = "#b45252"
var pos_col = "#8ab060"

var person_saved_score = 1000
var person_death_score = -500

onready var global = get_tree().get_root().get_node("Global")
onready var audio = get_tree().get_root().get_node("Audio")

func _ready():
	$PeopleCatcher.connect("body_entered", self, "person_off_screen")
	$UmbrellaCatcher.connect("body_entered", self, "umbrella_off_screen")
	setup_global_timer()
	connect_buttons()

func setup_global_timer():
	$GlobalTimer.set_wait_time(global_time)
	$HUD.update_timer(global_time)
	$GlobalTimer.connect("timeout", self, "game_end")

func update_global_timer():
	$HUD.update_timer($GlobalTimer.time_left)
	
func game_end():
	$PersonTimer.stop()
	$UmbrellaTimer.stop()
	$GlobalTimer.stop()
	$GameEnd/Rows/Text.text = "You scored " + str($HUD.points) + " points!"
	$GameEnd.scale = Vector2.ZERO
	$GameEnd.show()
	$Tween.interpolate_property($GameEnd, "scale", Vector2.ZERO, Vector2.ONE,
		0.6, Tween.TRANS_BACK, Tween.EASE_OUT)
	$Tween.start()

func begin():
	if debug:
		exposition_over()
	else:
		add_exposition()

func _input(event):
	if event is InputEventScreenTouch and not $GameEnd.visible:
		if event.pressed:
			mouse_pressed = true
			for attach_point in get_tree().get_nodes_in_group("attach_points"):
				if attach_point.has_point(event.position):
					audio.play_sound("start_rope")
					overlay.pressed_attach_point = attach_point
					global.display_attach_overlay = true
		else:
			mouse_pressed = false
			if not overlay.pressed_attach_point == null:
				for attach_point in get_tree().get_nodes_in_group("attach_points"):
					if (attach_point.has_point(event.position) and
						not attach_point == overlay.pressed_attach_point):
						create_rope(overlay.pressed_attach_point,
							attach_point)
				overlay.pressed_attach_point = null
				global.display_attach_overlay = false

func create_rope(start_attach_point, end_attach_point):
	if (is_instance_valid(start_attach_point) and
		is_instance_valid(end_attach_point)):
		audio.play_sound("create_rope")
		if $Entities.has_node("Rope"):
			var old_rope = $Entities.get_node("Rope")
			$Entities.remove_child(old_rope)
			old_rope.queue_free()
		var rope = rope_packed.instance()
		rope.init(start_attach_point, end_attach_point)
		$Entities.add_child(rope)

func _process(delta):
	if not $GlobalTimer.is_stopped():
		update_global_timer()
	if not overlay.pressed_attach_point == null:
		var mouse_pos = get_viewport().get_mouse_position()
		overlay.drag_position = mouse_pos
		overlay.joined_bool = false
		for attach_point in get_tree().get_nodes_in_group("attach_points"):
			var hovering = attach_point.has_point(mouse_pos)
			if attach_point == overlay.hovering_attach_point and not hovering:
				overlay.hovering_attach_point = null
			if hovering:
				if (not attach_point == overlay.pressed_attach_point and
					not attach_point == overlay.hovering_attach_point):
					if not audio.is_sound_playing("end_rope"):
						audio.play_sound("end_rope")
					overlay.hovering_attach_point = attach_point
				overlay.drag_position = attach_point.get_global_position()
				overlay.joined_bool = true

func person_off_screen(body):
	if not $GameEnd.visible:
		audio.play_sound("falling")
		var text_pos = body.get_position()
		var viewport_size = get_viewport_rect().size
		text_pos.y = viewport_size.y
		text_pos.x = clamp(text_pos.x, person_x_margin, viewport_size.x-person_x_margin)
		register_points(text_pos, person_death_score)
		body.queue_free()

func umbrella_off_screen(body):
	body.queue_free()

func setup_timer():
	$PersonTimer.wait_time = rand_range(min_person_wait, max_person_wait)
	$PersonTimer.connect("timeout", self, "spawn_person")
	$PersonTimer.start()
	$UmbrellaTimer.wait_time = rand_range(min_person_wait, max_person_wait)
	$UmbrellaTimer.connect("timeout", self, "spawn_umbrella")
	$UmbrellaTimer.start()

func spawn_person():
	var viewport_rect = get_viewport_rect()
	# left
	var person = person_packed.instance()
	person.connect("person_saved", self, "register_points", [person_saved_score])
	person.set_position(Vector2(
		rand_range(person_x_margin, viewport_rect.size.x/2-person_x_margin),
		rand_range(min_person_y_offset, max_person_y_offset)
	))
	$Entities.add_child(person)
	# right
	person = person_packed.instance()
	person.connect("person_saved", self, "register_points", [person_saved_score])
	person.set_position(Vector2(
		rand_range(viewport_rect.size.x/2+person_x_margin, viewport_rect.size.x-person_x_margin),
		rand_range(min_person_y_offset, max_person_y_offset)
	))
	$Entities.add_child(person)
	$PersonTimer.wait_time = rand_range(min_person_wait, max_person_wait)
	$PersonTimer.start()

func spawn_umbrella():
	var umbrellas = get_tree().get_nodes_in_group("umbrella")
	if len(umbrellas) < max_umbrella_number:
		var viewport_rect = get_viewport_rect()
		var umbrella = umbrella_packed.instance()
		var possible_positions = [
			Vector2(
				rand_range(
					umbrella_x_margin,
					viewport_rect.size.x/2-umbrella_x_margin),
				viewport_rect.size.y + umbrella_y_offset
			),
			Vector2(
				rand_range(
					viewport_rect.size.x/2+umbrella_x_margin,
					viewport_rect.size.x-umbrella_x_margin),
				viewport_rect.size.y + umbrella_y_offset
			)
		]
		possible_positions.shuffle()
		umbrella.set_position(possible_positions[0])
		$Entities.add_child(umbrella)
		$UmbrellaTimer.wait_time = rand_range(min_umbrella_wait, max_umbrella_wait)
		$UmbrellaTimer.start()

func spawn_starting_people():
	var viewport_rect = get_viewport_rect()
	# left
	var person = person_packed.instance()
	person.connect("person_saved", self, "register_points", [person_saved_score])
	person.set_position(Vector2(viewport_rect.size.x/6, min_person_y_offset))
	$Entities.add_child(person)
	# right
	person = person_packed.instance()
	person.connect("person_saved", self, "register_points", [person_saved_score])
	person.set_position(Vector2(5*viewport_rect.size.x/6, min_person_y_offset))
	$Entities.add_child(person)

func register_points(location, amount):
	if not $GameEnd.visible:
		add_points_indicator(location, amount)
		$HUD.record_points(amount)

func add_points_indicator(location, amount):
	var points_text = points_text_packed.instance()
	var text = "+"
	var col = pos_col
	if amount < 0:
		text = ""
		col = neg_col
	text += str(amount)
	points_text.set_text(text, col)
	points_text.set_position(location)
	$Overlay.add_child(points_text)

func add_exposition():
	var exposition = exposition_packed.instance()
	exposition.connect("exposition_done", self, "exposition_over")
	add_child(exposition)

func exposition_over():
	if has_node("Exposition"):
		$Exposition.queue_free()
	setup_timer()
	spawn_starting_people()
	$GlobalTimer.start()

func connect_buttons():
	$GameEnd/Rows/Menu.connect("pressed", self, "return_to_menu")
	$GameEnd/Rows/Tweet.connect("pressed", self, "tweet")

func return_to_menu():
	$Entities.hide()
	get_parent().return_to_menu(self)

func tweet():
	var _return = OS.shell_open("http://twitter.com/share?text=" +
		"I scored " + str($HUD.points) + " in Raining Men!&url=" +
		"https://manicmoleman.itch.io/raining-men" +
		"&hashtags=gmtkjam,GodotEngine")
