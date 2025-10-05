extends Control

signal message_finished

@onready var background = $Background
@onready var message_label = $MessageContainer/MessageLabel

func _ready():
	# Set up the message styling
	message_label.add_theme_font_size_override("font_size", 32)
	message_label.add_theme_color_override("font_color", Color.WHITE)
	
	# Start the fade-out sequence after a short delay
	await get_tree().create_timer(2.0).timeout
	fade_out()

func fade_out():
	# Create a tween for smooth fade-out
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Fade out background
	tween.tween_property(background, "modulate:a", 0.0, 1.0)
	
	# Fade out text
	tween.tween_property(message_label, "modulate:a", 0.0, 1.0)
	
	# Wait for fade to complete, then emit signal and remove from scene
	await tween.finished
	message_finished.emit()
	queue_free()
