extends Area2D
class_name Collectable

@onready var sprite = $Sprite
@onready var animation = $AnimationPlayer if has_node("AnimationPlayer") else null
@onready var particles = $CollectParticles if has_node("CollectParticles") else null

@export var water_value: float = 5.0
@export var float_amplitude: float = 10.0
@export var float_speed: float = 2.0

var collected: bool = false
var time_alive: float = 0.0
var base_y: float = 0.0

func _ready():
	add_to_group("collectable")
	
	# Enable input detection - THIS IS KEY FOR CLICKING
	input_pickable = true
	
	# Connect click signal
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	# Store base position for floating animation
	base_y = global_position.y
	
	# Play idle animation if available
	if animation and animation.has_animation("float"):
		animation.play("float")

func _process(delta: float):
	if collected:
		return
	
	time_alive += delta
	
	# Smooth floating animation
	global_position.y = base_y + sin(time_alive * float_speed) * float_amplitude
	
	# Move left to simulate caravan moving right
	global_position.x -= 100.0 * delta
	
	# Despawn if off-screen (left side)
	if global_position.x < -100:
		queue_free()

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	# Detect mouse click
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if not collected:
				collect()

func _on_mouse_entered():
	# Visual feedback: scale up slightly when hovering
	if not collected:
		var tween = create_tween()
		tween.tween_property(sprite, "scale", Vector2(1.2, 1.2), 0.1)

func _on_mouse_exited():
	# Return to normal scale
	if not collected:
		var tween = create_tween()
		tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.1)

func collect():
	if collected:
		return
	
	collected = true
	
	# Add water to game manager
	GameManager.change_water(water_value)
	
	# Visual feedback
	play_collect_animation()
	
	# Play sound effect (if you have one)
	# $AudioStreamPlayer2D.play()

func play_collect_animation():
	# Emit particles
	if particles:
		particles.emitting = true
	
	# Animate sprite
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Fade out
	tween.tween_property(sprite, "modulate:a", 0.0, 0.4)
	
	# Scale up and move up
	tween.tween_property(sprite, "scale", Vector2(1.5, 1.5), 0.4)
	tween.tween_property(sprite, "global_position:y", global_position.y - 50, 0.4)
	
	# Slight rotation for extra juice
	tween.tween_property(sprite, "rotation_degrees", 360, 0.4)
	
	# Destroy after animation
	tween.tween_callback(queue_free).set_delay(0.4)

# Optional: Make collectables more valuable if clicked quickly after spawning
func get_bonus_multiplier() -> float:
	if time_alive < 1.0:
		return 1.5  # 50% bonus for quick collection
	elif time_alive < 2.0:
		return 1.2  # 20% bonus
	return 1.0
