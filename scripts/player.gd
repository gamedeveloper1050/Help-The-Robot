class_name Player
extends CharacterBody3D


@export_group("Movement Settings")
@export var walk_speed : float = 5.0
@export var sprint_speed : float = 8.0
@export var jump_force : float = 4.8

@export_group("Camera Movement Settings")
@export var bob_freq : float = 2.4
@export var bob_amp : float = 0.08
@export var sensitvity : float = 0.004
@export var FOV_change : float = 2.5
@export var base_FOV : float = 75.0


var gravity : float = 9.8

# Local Variables
var t_bob : float = 0.0
var current_speed : float


@onready var head = $Head
@onready var camera = $Head/Camera3D


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * sensitvity)
		camera.rotate_x(-event.relative.y * sensitvity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))


func _physics_process(delta):
	# Add the gravity.
	_handle_gravity(delta)
	
	# Handle Jump.
	_handle_jumping()
	
	# Handle Sprint.
	_handle_sprint()

	# Get the input direction and handle the movement/deceleration.
	_handle_movement(delta)
	
	
	# Head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	# FOV
	FOV_handle(delta)

	move_and_slide()
	
	
func _handle_gravity(delta : float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta


func _handle_jumping() -> void:
	if Input.is_action_just_pressed(&"jump") and is_on_floor():
		velocity.y = jump_force
	
func _handle_sprint() -> void:
	if Input.is_action_pressed(&"sprint"):
		current_speed = sprint_speed
	else:
		current_speed = walk_speed

func _handle_movement(delta : float) -> void:
	var input_dir : Vector2 = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	var direction: Vector3 = Vector3(input_dir.x, 0, input_dir.y)
	direction = direction.rotated(Vector3.UP, head.rotation.y)
	direction = direction.normalized()

	if is_on_floor():
		if direction:
			velocity.x = direction.x * current_speed
			velocity.z = direction.z * current_speed
		else:
			velocity.x = lerp(velocity.x, direction.x * current_speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * current_speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * current_speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * current_speed, delta * 3.0)
	


func FOV_handle(delta : float) -> void :
	var velocity_clamped = clamp(velocity.length(), 0.5, sprint_speed * 2)
	var target_fov = base_FOV + FOV_change * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	

func _headbob(time : float) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * bob_freq) * bob_amp
	pos.x = cos(time * bob_freq / 2) * bob_amp
	return pos
