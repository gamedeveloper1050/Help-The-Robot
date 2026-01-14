class_name Enemy1
extends Enemy



func _ready() -> void:

	target = get_tree().get_first_node_in_group("Player")
	super._ready()
	print(current_speed)
	
	
func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	
	_handle_movement()
	move_and_slide()
