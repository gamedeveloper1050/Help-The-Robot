extends Control


func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Prototype.tscn")


func _on_contine_pressed() -> void:
	Global.want_to_contine = true
	push_error("We Are So Sorry But Saving And Loading System Will Be Added Soon")


func _on_settings_pressed() -> void:
	push_error("We Are So Sorry But Settings Will Be Added Soon")


func _on_credits_pressed() -> void:
	push_error("We Are So Sorry But Cridits Will Be Added Soon")


func _on_exit_game_pressed() -> void:
	get_tree().quit()
