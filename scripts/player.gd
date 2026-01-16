class_name Player
extends CharacterBody3D


@export_group("Movement Settings")
@export var walk_speed : float = 5.0
@export var sprint_speed : float = 8.0
@export var jump_force : float = 4.8
@export var crouching_speed : float = 1.5
@export var crouch_while_sprinting_speed : float = 2.0

@export_group("Camera Movement Settings")
@export var bob_freq : float = 2.4
@export var bob_amp : float = 0.08
@export var sensitvity : float = 0.004
@export var FOV_change : float = 2.5
@export var base_FOV : float = 75.0
@export var max_look_up_angle : float = 90
@export var min_look_down_angle : float = -90


var gravity : float = 9.8

# Local Variables
var t_bob : float = 0.0
var current_speed : float = 0.0

var is_crouching : bool = false
var is_sprinting : bool = false
var is_jumping : bool = false

var can_jump : bool = true
var can_move : bool = true


@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var player_animations : AnimationPlayer = $player_animations


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$MeshInstance3D.visible = false


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * sensitvity)
		camera.rotate_x(-event.relative.y * sensitvity)
		camera.rotation.x = clamp(
			camera.rotation.x,
			deg_to_rad(min_look_down_angle),
			deg_to_rad(max_look_up_angle)
		)


func _physics_process(delta):
	_handle_gravity(delta)
	_handle_jumping()
	_handle_sprint()
	_handle_crouching()
	_update_speed()
	_handle_movement(delta)
	_handle_headbob(delta)
	_handle_fov(delta)

	move_and_slide()


# ----------------------------
# PHYSICS
# ----------------------------

func _handle_gravity(delta : float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta


func _handle_jumping() -> void:
	if Input.is_action_just_pressed(&"jump") and is_on_floor() and can_jump:
		velocity.y = jump_force
		is_jumping = true

	if is_on_floor():
		is_jumping = false


# ----------------------------
# STATES
# ----------------------------

func _handle_sprint() -> void:
	is_sprinting = Input.is_action_pressed(&"sprint")


func _handle_crouching() -> void:
	if not is_on_floor():
		return

	if Input.is_action_just_pressed("crouch") and not is_jumping:
		is_crouching = !is_crouching
		if is_crouching:
			player_animations.play("crouch")
		else:
			player_animations.play_backwards("crouch")

	can_jump = !is_crouching


# ----------------------------
# SPEED
# ----------------------------

func _update_speed() -> void:
	if is_crouching:
		if is_sprinting:
			current_speed = crouch_while_sprinting_speed
		else:
			current_speed = crouching_speed
	else:
		if is_sprinting:
			current_speed = sprint_speed
		else:
			current_speed = walk_speed


# ----------------------------
# MOVEMENT
# ----------------------------

func _handle_movement(delta : float) -> void:
	if not can_move:
		return

	var input_dir : Vector2 = Input.get_vector(
		&"move_left",
		&"move_right",
		&"move_up",
		&"move_down"
	)

	var direction : Vector3 = Vector3(input_dir.x, 0, input_dir.y)
	direction = direction.rotated(Vector3.UP, head.rotation.y)
	direction = direction.normalized()

	if is_on_floor():
		if direction != Vector3.ZERO:
			velocity.x = direction.x * current_speed
			velocity.z = direction.z * current_speed
		else:
			velocity.x = lerp(velocity.x, 0.0, delta * 7.0)
			velocity.z = lerp(velocity.z, 0.0, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * current_speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * current_speed, delta * 3.0)


# ----------------------------
# CAMERA
# ----------------------------

func _handle_headbob(delta : float) -> void:
	if velocity.length() < 0.1 or not is_on_floor():
		return

	var bob_strength := 1.0
	if is_crouching:
		bob_strength = 0.5

	t_bob += delta * velocity.length()
	camera.transform.origin = _headbob(t_bob) * bob_strength


func _handle_fov(delta : float) -> void:
	if is_crouching:
		return

	var velocity_clamped = clamp(velocity.length(), 0.5, sprint_speed * 2)
	var target_fov = base_FOV + FOV_change * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)


func _headbob(time : float) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * bob_freq) * bob_amp
	pos.x = cos(time * bob_freq / 2.0) * bob_amp
	return pos
