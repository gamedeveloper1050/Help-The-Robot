class_name Enemy
extends CharacterBody3D

@export var current_speed: float = 2.0

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
var target: CharacterBody3D


func _ready() -> void:
	if target:
		navigation_agent.target_position = target.global_position


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	if not target:
		return
		
	
		
	navigation_agent.target_position = target.global_position

	_handle_movement(delta)
	move_and_slide()


func _handle_movement(delta : float) -> void:
	if navigation_agent.is_navigation_finished():
		velocity = Vector3.ZERO
		return

	var next_position: Vector3 = navigation_agent.get_next_path_position()
	var direction: Vector3 = (next_position - global_position).normalized()

	
	velocity = direction * current_speed
