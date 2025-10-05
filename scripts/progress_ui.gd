extends Control

@onready var label = $ProgressLabel

func _ready() -> void:
	GameManager.distance_updated.connect(_on_distance_changed)

func _on_distance_changed(_amount: float, total: float):
	label.text = "Distance: %.0f / %.0f" % [total/100, GameManager.win_distance/100]
