extends Node2D

@onready var water_meter = $UI/WaterMeter

func _ready():
	print("Game Started!")
	print("GameManager accessible: ", GameManager != null)
	GameManager.start_new_run()
