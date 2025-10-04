extends Node2D

@onready var water_meter = $UI/WaterMeter

func _ready():
	print("Game Started!")
	print("GameManager accessible: ", GameManager != null)
	GameManager.start_new_run()
	
	# Connect signal
	GameManager.water_changed.connect(_on_water_changed)

func _on_water_changed(new_water: float):
	water_meter.update_water(new_water, GameManager.max_water)
	print("Water: ", new_water)
