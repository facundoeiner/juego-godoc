class_name PetDog
extends Node2D

var dog_name := ""
var coat_style := 0
var trait_text := ""
var trait_failure := ""
var needs := {
	"food": 60.0,
	"water": 60.0,
	"fun": 60.0,
	"toilet": 60.0,
	"energy": 70.0
}
var health := 100.0
var is_clone := false
var revealed := false
var following := false
var sleeping := false
var facing := Vector2.RIGHT
var bounds := Rect2(100.0, 100.0, 200.0, 150.0)
var bark_text := ""
var bark_timer := 0.0
var night_mode := false
var _wander_target := Vector2.ZERO
var _wander_pause := 0.0
var _route: Array[Vector2] = []
var _route_goal := Vector2.ZERO
var _animation_time := 0.0

func configure(p_name: String, p_coat: int, p_trait: String, p_failure: String, p_bounds: Rect2) -> void:
	dog_name = p_name
	coat_style = p_coat
	trait_text = p_trait
	trait_failure = p_failure
	bounds = p_bounds
	_wander_target = _random_point_in_bounds()
	queue_redraw()

func get_need(need: String) -> float:
	return float(needs.get(need, 0.0))

func adjust_need(need: String, amount: float) -> void:
	needs[need] = clampf(float(needs.get(need, 0.0)) + amount, 0.0, 100.0)

func wake_up() -> void:
	sleeping = false

func bark() -> void:
	bark_text = "¡Guau!"
	bark_timer = 1.2
	queue_redraw()

func wander(delta: float) -> void:
	_animation_time += delta
	if bark_timer > 0.0:
		bark_timer = maxf(0.0, bark_timer - delta)
	if sleeping:
		queue_redraw()
		return
	_wander_pause -= delta
	if _wander_pause <= 0.0 and position.distance_to(_wander_target) < 8.0:
		_wander_target = _random_point_in_bounds()
		_wander_pause = randf_range(1.2, 3.8)
	_move_towards(delta, _wander_target, 34.0)
	queue_redraw()

func follow_player(delta: float, player_position: Vector2) -> void:
	_animation_time += delta
	if bark_timer > 0.0:
		bark_timer = maxf(0.0, bark_timer - delta)
	if sleeping:
		wake_up()
	var current_zone := _zone_at(position)
	var target_zone := _zone_at(player_position)
	if current_zone == target_zone:
		_route.clear()
		_move_towards(delta, player_position - facing * 18.0, 112.0)
	else:
		if _route.is_empty() or _route_goal.distance_to(player_position) > 30.0:
			_build_route(current_zone, target_zone, player_position)
		if not _route.is_empty() and position.distance_to(_route[0]) < 10.0:
			_route.remove_at(0)
		if not _route.is_empty():
			_move_towards(delta, _route[0], 112.0)
	queue_redraw()

func chase(delta: float, target_position: Vector2) -> void:
	_animation_time += delta
	if bark_timer > 0.0:
		bark_timer = maxf(0.0, bark_timer - delta)
	_move_towards(delta, target_position, 78.0)
	queue_redraw()

func _build_route(current_zone: String, target_zone: String, goal: Vector2) -> void:
	_route.clear()
	_route_goal = goal
	if current_zone == "kitchen":
		_route.append(Vector2(265.0, 290.0))
		_route.append(Vector2(265.0, 320.0))
	elif current_zone == "bathroom":
		_route.append(Vector2(680.0, 290.0))
		_route.append(Vector2(680.0, 320.0))
	elif current_zone == "bedroom":
		_route.append(Vector2(220.0, 380.0))
		_route.append(Vector2(220.0, 355.0))
	elif current_zone == "patio":
		_route.append(Vector2(850.0, 410.0))
		_route.append(Vector2(815.0, 410.0))
	if target_zone == "kitchen":
		_route.append(Vector2(265.0, 320.0))
		_route.append(Vector2(265.0, 290.0))
	elif target_zone == "bathroom":
		_route.append(Vector2(680.0, 320.0))
		_route.append(Vector2(680.0, 290.0))
	elif target_zone == "bedroom":
		_route.append(Vector2(220.0, 355.0))
		_route.append(Vector2(220.0, 380.0))
	_route.append(goal)

func _zone_at(point: Vector2) -> String:
	if point.x >= 835.0:
		return "patio"
	if point.y < 300.0:
		if point.x < 510.0:
			return "kitchen"
		return "bathroom"
	if point.y >= 390.0 and point.x < 360.0:
		return "bedroom"
	return "living"

func _move_towards(delta: float, target: Vector2, move_speed: float) -> void:
	var difference := target - position
	if difference.length_squared() < 4.0:
		return
	var direction := difference.normalized()
	facing = direction
	var step := minf(move_speed * delta, difference.length())
	position += direction * step

func _random_point_in_bounds() -> Vector2:
	return Vector2(
		randf_range(bounds.position.x + 10.0, bounds.end.x - 10.0),
		randf_range(bounds.position.y + 10.0, bounds.end.y - 10.0)
	)

func _draw() -> void:
	var forward := facing.normalized()
	if forward.length_squared() < 0.1:
		forward = Vector2.RIGHT
	var right := Vector2(-forward.y, forward.x)
	var head_center := forward * 11.0
	var shadow_offset := Vector2(7.0, 8.0)
	if night_mode and is_clone:
		shadow_offset = Vector2(-8.0, -7.0)
	var moving_bob := sin(_animation_time * 10.0) * 1.0
	draw_polygon(_ellipse(shadow_offset + Vector2(0.0, 4.0), Vector2(22.0, 11.0)), Color(0.04, 0.03, 0.06, 0.38))
	if revealed:
		draw_polygon(_ellipse(Vector2.ZERO, Vector2(29.0, 20.0)), Color(0.58, 0.08, 0.72, 0.18))
	draw_line(-forward * 14.0 + right * 5.0, -forward * 24.0 + right * 8.0, Color(0.84, 0.78, 0.67), 5.0)
	draw_line(-forward * 14.0 - right * 5.0, -forward * 24.0 - right * 8.0, Color(0.84, 0.78, 0.67), 5.0)
	for leg_side in [-1.0, 1.0]:
		for leg_forward in [-8.0, 8.0]:
			var leg_position := forward * leg_forward + right * 7.0 * leg_side + Vector2(0.0, moving_bob * leg_forward / 8.0)
			draw_circle(leg_position, 4.0, Color(0.87, 0.83, 0.73))
	draw_polygon(_ellipse(Vector2.ZERO, Vector2(20.0, 12.0)), Color(0.96, 0.93, 0.84))
	_draw_coat_patch(forward, right)
	draw_polygon(_ellipse(head_center, Vector2(12.0, 10.0)), Color(0.97, 0.94, 0.86))
	var ear_color := Color(0.73, 0.48, 0.25)
	if coat_style == 1:
		ear_color = Color(0.16, 0.14, 0.13)
	draw_polygon(_ellipse(head_center + right * 10.0 - forward * 3.0, Vector2(5.0, 8.0)), ear_color)
	draw_polygon(_ellipse(head_center - right * 10.0 - forward * 3.0, Vector2(5.0, 8.0)), ear_color)
	draw_line(head_center - forward * 2.0 + right * 8.0, head_center - forward * 2.0 - right * 8.0, Color(0.72, 0.22, 0.26), 4.0)
	var eye_offset := right * 4.5 + forward * 3.5
	if sleeping:
		draw_line(head_center + eye_offset - right * 1.8, head_center + eye_offset + right * 1.8, Color(0.10, 0.08, 0.08), 1.5)
		draw_line(head_center - eye_offset - right * 1.8, head_center - eye_offset + right * 1.8, Color(0.10, 0.08, 0.08), 1.5)
	else:
		var eye_color := Color(0.08, 0.07, 0.07)
		if revealed:
			eye_color = Color(1.0, 0.08, 0.10)
		draw_circle(head_center + eye_offset, 1.8, eye_color)
		draw_circle(head_center - eye_offset, 1.8, eye_color)
	draw_circle(head_center + forward * 9.0, 2.4, Color(0.08, 0.07, 0.07))
	if is_clone and not revealed:
		draw_circle(head_center + eye_offset, 0.7, Color(0.45, 0.0, 0.0))
		draw_circle(head_center - eye_offset, 0.7, Color(0.45, 0.0, 0.0))
	var font := ThemeDB.fallback_font
	var label_position := Vector2(-28.0, -37.0)
	draw_string(font, label_position, dog_name, HORIZONTAL_ALIGNMENT_CENTER, 56.0, 14, Color(1.0, 0.93, 0.75))
	if following:
		draw_circle(Vector2(17.0, -25.0), 3.0, Color(0.40, 0.88, 1.0))
	if bark_timer > 0.0:
		draw_string(font, Vector2(-32.0, -52.0), bark_text, HORIZONTAL_ALIGNMENT_CENTER, 64.0, 16, Color(1.0, 0.88, 0.40))
	if sleeping:
		draw_string(font, Vector2(12.0, -29.0), "Zzz", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 14, Color(0.70, 0.78, 1.0))

func _draw_coat_patch(forward: Vector2, right: Vector2) -> void:
	var black := Color(0.12, 0.11, 0.11)
	var tan := Color(0.73, 0.47, 0.24)
	match coat_style:
		0:
			draw_polygon(_ellipse(right * 5.0 - forward * 3.0, Vector2(9.0, 7.0)), black)
			draw_polygon(_ellipse(forward * 4.0 + right * 7.0, Vector2(6.0, 5.0)), tan)
		1:
			draw_polygon(_ellipse(-forward * 4.0, Vector2(12.0, 8.0)), black)
			draw_polygon(_ellipse(forward * 7.0 - right * 6.0, Vector2(7.0, 6.0)), tan)
		2:
			draw_polygon(_ellipse(forward * 5.0 + right * 5.0, Vector2(8.0, 6.0)), tan)
			draw_polygon(_ellipse(-forward * 6.0 - right * 5.0, Vector2(7.0, 5.0)), tan)
		3:
			draw_polygon(_ellipse(forward * 8.0 + right * 4.0, Vector2(8.0, 7.0)), black)
			draw_polygon(_ellipse(forward * 9.0 - right * 4.0, Vector2(6.0, 5.0)), tan)

func _ellipse(center: Vector2, radius: Vector2, points: int = 24) -> PackedVector2Array:
	var polygon := PackedVector2Array()
	for index in points:
		var angle := TAU * float(index) / float(points)
		polygon.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	return polygon
