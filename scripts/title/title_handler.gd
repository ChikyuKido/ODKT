extends Node



func _on_room_list_clicked() -> void:
	get_tree().change_scene_to_file("res://scene/room_list.tscn")
