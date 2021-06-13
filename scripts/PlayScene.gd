extends Node2D

var rope_packed = preload("res://nodes/Rope.tscn")
var person_packed = preload("res://nodes/Person.tscn")
var points_text_packed = preload("res://nodes/PointsText.tscn")
onready var overlay = get_node("Overlay")

var mouse_pressed = false

var min_person_wait = 5.0
var max_person_wait = 10.0

var min_person_y_offset = -50
var max_person_y_offset = -150

var person_x_margin = 10

var neg_col = "#b45252"
var pos_col = "#8ab060"

var person_saved_score = 1000
var person_death_score = -500

onready var global = get_tree().get_root().get_node("Global")

func _ready():
	$PeopleCatcher.connect("body_entered", self, "person_off_screen")
	setup_timer()

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			mouse_pressed = true
			for attach_point in get_tree().get_nodes_in_group("attach_points"):
				if attach_point.has_point(event.position):
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
	if has_node("Rope"):
		var old_rope = get_node("Rope")
		remove_child(old_rope)
		old_rope.queue_free()
	var rope = rope_packed.instance()
	rope.init(start_attach_point, end_attach_point)
	add_child(rope)

func _process(delta):
	if not overlay.pressed_attach_point == null:
		var mouse_pos = get_viewport().get_mouse_position()
		overlay.drag_position = mouse_pos
		overlay.joined_bool = false
		for attach_point in get_tree().get_nodes_in_group("attach_points"):
			if attach_point.has_point(mouse_pos):
				overlay.drag_position = attach_point.get_global_position()
				overlay.joined_bool = true

func person_off_screen(body):
	var text_pos = body.get_position()
	var viewport_size = get_viewport_rect().size
	text_pos.y = viewport_size.y
	text_pos.x = clamp(text_pos.x, person_x_margin, viewport_size.x-person_x_margin)
	register_points(text_pos, person_death_score)
	body.queue_free()

func setup_timer():
	$PersonTimer.wait_time = rand_range(min_person_wait, max_person_wait)
	$PersonTimer.connect("timeout", self, "spawn_person")
	$PersonTimer.start()

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

func register_points(location, amount):
	add_points_indicator(location, amount)

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
