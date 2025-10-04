extends Control

@onready var progress_bar = $ProgressBar
@onready var label = $WaterLabel

func update_water(current: float, maximum: float):
	progress_bar.max_value = maximum
	progress_bar.value = current
	label.text = "Water: %.0f / %.0f" % [current, maximum]
