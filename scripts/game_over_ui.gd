extends Control

@onready var title_label = $CenterContainer/VBoxContainer/TitleLabel
@onready var subtitle_label = $CenterContainer/VBoxContainer/SubtitleLabel
@onready var stats_label = $CenterContainer/VBoxContainer/StatsLabel

var is_win: bool = false

func _ready(): 
	# Connect to GameManager signals
	GameManager.game_over.connect(_on_game_over)
	GameManager.game_won.connect(_on_game_won)
	
	# Initially hide the UI
	visible = false

func _unhandled_input(event):
	# Only handle input when the game over screen is visible
	if not visible:
		return
		
	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.keycode == KEY_R):
		_restart_game()

func _on_game_over():
	show_game_over_screen(false)

func _on_game_won():
	show_game_over_screen(true)

func show_game_over_screen(won: bool):
	is_win = won
	
	if won:
		title_label.text = "YOU WIN!"
		title_label.modulate = Color(0.2, 1.0, 0.2)  # Green tint
		subtitle_label.text = "Congratulations! You reached the oasis!"
	else:
		title_label.text = "GAME OVER"
		title_label.modulate = Color(1.0, 0.2, 0.2)  # Red tint
		subtitle_label.text = "You ran out of water!"
	
	# Update stats
	var distance_meters = int(GameManager.distance_traveled / 100)
	stats_label.text = "Distance Traveled: %d / %d" % [distance_meters, int(GameManager.win_distance / 100)]
	
	# Show the UI
	visible = true
	
	# Stop the game logic (but don't pause the entire tree)
	GameManager.is_running = false

func _restart_game():
	# Hide the UI
	visible = false
	
	# Restart the game
	GameManager.start_new_run()
