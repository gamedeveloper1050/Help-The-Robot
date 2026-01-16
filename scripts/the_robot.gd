class_name Robot
extends CharacterBody3D

@onready var robot_model: Node3D = $"Robot Model"

var speed : float = 2.0
var target: CharacterBody3D

var height_offset : float = 0.6      # THIS WILL NOW WORK
var hover_strength : float = 0.3     # THIS WILL NOW WORK
var hover_time : float = 0.0
var stop_distance : float = 1.5

func _ready() -> void:
	target = get_tree().get_first_node_in_group("Robot") as CharacterBody3D


func _physics_process(delta: float) -> void:
	if not target:
		return

	hover_time += delta

	_move_xy(delta)
	_update_height(delta)
	_look_at_target()

	move_and_slide()


func _move_xy(delta: float) -> void:
	var to_player := target.global_position - global_position
	to_player.y = 0.0

	var distance := to_player.length()

	if distance < 0.01:
		return

	var dir := to_player.normalized()

	# Desired speed based on distance
	var desired_speed := 0.0
	if distance > stop_distance:
		desired_speed = speed
	else:
		# Smoothly slow down near the player
		var t := distance / stop_distance
		desired_speed = speed * t

	var desired_velocity := dir * desired_speed

	# Smooth acceleration / deceleration
	velocity.x = move_toward(velocity.x, desired_velocity.x, 10.0 * delta)
	velocity.z = move_toward(velocity.z, desired_velocity.z, 10.0 * delta)



func _update_height(delta: float) -> void:
	var desired_y := target.global_position.y + height_offset
	var hover := sin(hover_time * 2.0) * hover_strength

	# THIS is why it now works:
	global_position.y = lerp(
		global_position.y,
		desired_y + hover,
		5.0 * delta
	)


func _look_at_target() -> void:
	var dir := target.global_position - global_position
	dir.y = 0.0

	if dir.length() > 0.001:
		robot_model.rotation.y = lerp_angle(
			robot_model.rotation.y,
			atan2(dir.x, dir.z),
			0.15
		)
