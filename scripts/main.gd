extends Node2D

@onready var water_meter = $UI/WaterMeter

func _ready():
	print("Game Started!")
	print("GameManager accessible: ", GameManager != null)
	# Connect signal
	GameManager.water_changed.connect(_on_water_changed)
	GameManager.start_new_run()

func _on_water_changed(new_water: float, maximum: float):
	water_meter.update_water(new_water, maximum)
	print("Water: ", new_water)
