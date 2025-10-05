extends Control
class_name HealthBar

@onready var health_fill: Panel = $HealthFill

var max_health: int = 1
var current_health: int = 1
var unique_style_box: StyleBoxFlat
var has_been_damaged: bool = false

func _ready():
	# Initially hide the health bar
	visible = false
	
	# Create a unique style box instance for this health bar
	_create_unique_style_box()

func set_max_health(value: int):
	max_health = value
	current_health = value
	update_display()

func set_current_health(value: int):
	# Check if this is the first time taking damage
	if current_health > value and not has_been_damaged:
		has_been_damaged = true
	
	current_health = value
	update_display()

func _create_unique_style_box():
	# Get the original style box and duplicate it
	var original_style_box = health_fill.get_theme_stylebox("panel")
	if original_style_box:
		unique_style_box = original_style_box.duplicate()
		health_fill.add_theme_stylebox_override("panel", unique_style_box)
	else:
		# Create a new style box if none exists
		unique_style_box = StyleBoxFlat.new()
		unique_style_box.bg_color = Color(0.2, 0.8, 0.2, 0.9)
		unique_style_box.corner_radius_top_left = 1
		unique_style_box.corner_radius_top_right = 1
		unique_style_box.corner_radius_bottom_right = 1
		unique_style_box.corner_radius_bottom_left = 1
		health_fill.add_theme_stylebox_override("panel", unique_style_box)

func update_display():
	# Hide health bar if max health is 1 or if it hasn't been damaged yet
	if max_health <= 1 or not has_been_damaged:
		visible = false
		return
	
	visible = true
	
	# Calculate the fill percentage
	var fill_percentage = float(current_health) / float(max_health)
	
	# Update the health fill bar size
	var new_width = (size.x - 2) * fill_percentage  # -2 for border
	health_fill.size.x = new_width
	
	# Change color based on health percentage using our unique style box
	if unique_style_box:
		if fill_percentage > 0.6:
			unique_style_box.bg_color = Color(0.2, 0.8, 0.2, 0.9)  # Green
		elif fill_percentage > 0.3:
			unique_style_box.bg_color = Color(0.8, 0.8, 0.2, 0.9)  # Yellow
		else:
			unique_style_box.bg_color = Color(0.8, 0.2, 0.2, 0.9)  # Red
