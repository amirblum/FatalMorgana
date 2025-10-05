extends Node2D

@onready var water_meter = $UI/WaterMeter
@onready var startup_message = $UI/StartupMessage

func _ready():
	print("Game Started!")
	print("GameManager accessible: ", GameManager != null)
	
	# Initialize UI with correct values immediately
	GameManager.initialize_ui()
	
	# Connect to startup message signal
	startup_message.message_finished.connect(_on_startup_message_finished)
	
	# Don't start the game yet - wait for startup message to finish

func _on_startup_message_finished():
	print("Startup message finished, starting game...")
	GameManager.start_new_run()
