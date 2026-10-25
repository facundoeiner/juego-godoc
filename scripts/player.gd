class_name TopDownPlayer
extends Node2D

var speed := 185.0
var walkable_rects: Array[Rect2] = []
var obstacle_rects: Array[Rect2] = []
var input_enabled := true
var facing := Vector2.DOWN
var flashlight_on := false
var night_mode := false
var _is_moving := false
var _walk_time := 0.0

func setup(rects: Array[Rect2], obstacles: Array[Rect2]) -> void:
	walkable_rects = rects
	obstacle_rects = obstacles
	queue_redraw()

func _physics_process(delta: float) -> void:
	_is_moving = false
	if not input_enabled:
		queue_redraw()
		return
	var direction := _read_direction()
	if direction.length_squared() > 0.0:
		direction = direction.normalized()
		facing = direction
		_is_moving = true
		_walk_time += delta * 9.0
		var amount := speed * delta
		var next_x := position + Vector2(direction.x * amount, 0.0)
		if _point_is_valid(next_x):
			position.x = next_x.x
		var next_y := position + Vector2(0.0, direction.y * amount)
		if _point_is_valid(next_y):
			position.y = next_y.y
	queue_redraw()

func _read_direction() -> Vector2:
	var direction := Vector2.ZERO
	if Input.is_physical_key_pressed(KEY_A) or Input.is_action_pressed("ui_left"):
		direction.x -= 1.0
	if Input.is_physical_key_pressed(KEY_D) or Input.is_action_pressed("ui_right"):
		direction.x += 1.0
	if Input.is_physical_key_pressed(KEY_W) or Input.is_action_pressed("ui_up"):
		direction.y -= 1.0
	if Input.is_physical_key_pressed(KEY_S) or Input.is_action_pressed("ui_down"):
		direction.y += 1.0
	return direction

func _point_is_valid(point: Vector2) -> bool:
	var inside := false
	for rect in walkable_rects:
		if rect.has_point(point):
			inside = true
			break
	if not inside:
		return false
	for obstacle in obstacle_rects:
		if obstacle.grow(11.0).has_point(point):
			return false
	return true

func _draw() -> void:
	var bob := 0.0
	if _is_moving:
		bob = sin(_walk_time) * 1.5
	draw_polygon(_ellipse(Vector2(0.0, 7.0), Vector2(14.0, 7.0)), Color(0.05, 0.04, 0.07, 0.38))
	draw_line(Vector2(-7.0, 6.0 + bob), Vector2(-7.0, 16.0), Color(0.22, 0.17, 0.25), 6.0)
	draw_line(Vector2(7.0, 6.0 - bob), Vector2(7.0, 16.0), Color(0.22, 0.17, 0.25), 6.0)
	draw_circle(Vector2(-12.0, -3.0 - bob), 4.0, Color(0.88, 0.64, 0.46))
	draw_circle(Vector2(12.0, -3.0 + bob), 4.0, Color(0.88, 0.64, 0.46))
	draw_polygon(_ellipse(Vector2(0.0, -7.0 - bob), Vector2(11.0, 14.0)), Color(0.24, 0.47, 0.64))
	draw_polygon(_ellipse(Vector2(0.0, -9.0 - bob), Vector2(8.0, 9.0)), Color(0.32, 0.65, 0.72))
	draw_circle(Vector2(0.0, -24.0 - bob), 11.0, Color(0.94, 0.72, 0.53))
	draw_colored_polygon(PackedVector2Array([
		Vector2(-10.0, -27.0 - bob),
		Vector2(-8.0, -37.0 - bob),
		Vector2(8.0, -37.0 - bob),
		Vector2(11.0, -27.0 - bob)
	]), Color(0.28, 0.17, 0.12))
	draw_rect(Rect2(-13.0, -37.0 - bob, 26.0, 5.0), Color(0.56, 0.30, 0.16))
	draw_circle(Vector2(-4.0, -24.0 - bob), 1.5, Color(0.12, 0.08, 0.07))
	draw_circle(Vector2(4.0, -24.0 - bob), 1.5, Color(0.12, 0.08, 0.07))
	var look := Vector2(facing.x * 2.0, facing.y)
	if look.length_squared() < 0.1:
		look = Vector2.DOWN
	look = look.normalized()
	draw_circle(Vector2(look.x * 5.0, -23.0 - bob + look.y * 2.0), 1.8, Color(0.12, 0.08, 0.07))
	if flashlight_on:
		var angle := facing.angle()
		var light_center := Vector2(facing.x * 20.0, facing.y * 20.0)
		draw_circle(light_center, 72.0, Color(1.0, 0.91, 0.58, 0.07))
		var cone := PackedVector2Array([
			Vector2(0.0, -13.0),
			Vector2(cos(angle - 0.48), sin(angle - 0.48)) * 150.0 + light_center,
			Vector2(cos(angle + 0.48), sin(angle + 0.48)) * 150.0 + light_center
		])
		draw_colored_polygon(cone, Color(1.0, 0.91, 0.58, 0.08))

func _ellipse(center: Vector2, radius: Vector2, points: int = 24) -> PackedVector2Array:
	var polygon := PackedVector2Array()
	for index in points:
		var angle := TAU * float(index) / float(points)
		polygon.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	return polygon
