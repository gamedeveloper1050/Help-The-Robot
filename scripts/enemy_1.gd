class_name Enemy1
extends Enemy

@onready var visual_pivot: Node3D = $VisualPivot

func _ready() -> void:
	target = get_tree().get_first_node_in_group("Player")
	super._ready()


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_handle_movement(delta)


func _process(delta: float) -> void:
	if not target:
		return

	# Y-ONLY rotation, no tilt
	var dir = target.global_position - global_position
	dir.y = 0.0

	if dir.length() < 0.001:
		return

	visual_pivot.rotation.y = atan2(dir.x, dir.z)
