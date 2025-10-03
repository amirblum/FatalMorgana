extends Control

func _on_Play_pressed():
	# Load your game scene
	var game_scene = load("res://scenes/Game.tscn")
	get_tree().change_scene_to_packed(game_scene)

func _on_Quit_pressed():
	get_tree().quit()
