extends Node2D

var pressed_attach_point
var drag_position
var joined_bool = false
var display_attach_points = false

var neg_col = "b45252"
var pos_col = "8ab060"

var attach_packaged = preload("res://nodes/AttachOverlay.tscn")

func _draw():
	if not pressed_attach_point == null and not drag_position == null:
		var col = neg_col
		if joined_bool:
			col = pos_col
		draw_line(pressed_attach_point.get_global_position(), drag_position,
			Color("#dd" + col), 6.0, true)

func _process(_delta):
	update()
	if display_attach_points:
		update_display_attach_points()

func start_display_attach_points():
	display_attach_points = true
	for child in get_tree().get_nodes_in_group("attach_points"):
		var attach_overlay = attach_packaged.instance()
		attach_overlay.set_position(child.get_global_position())
		$AttachPoints.add_child(attach_overlay)

func update_display_attach_points():
	var attach_points = get_tree().get_nodes_in_group("attach_points")
	var attach_overlays = $AttachPoints.get_children()
	while len(attach_points) < len(attach_overlays):
		$AttachPoints.remove_child(attach_overlays[0])
		attach_overlays[0].queue_free()
	while len(attach_points) > len(attach_overlays):
		var attach_overlay = attach_packaged.instance()
		$AttachPoints.add_child(attach_overlay)
	attach_overlays = $AttachPoints.get_children()
	for idx in range(len(attach_points)):
		attach_overlays[idx].set_position(attach_points[idx].get_global_position())

func end_display_attach_points():
	display_attach_points = false
	for child in $AttachPoints.get_children():
		child.queue_free()
