extends Area2D
class_name Collectable

@onready var sprite = $Sprite
@onready var animation = $AnimationPlayer if has_node("AnimationPlayer") else null
@onready var particles = $CollectParticles if has_node("CollectParticles") else null

@export var water_value: float = 5.0
@export var float_amplitude: float = 10.0
@export var float_speed: float = 2.0
@export var hp: int = 3
@export var highlight_color: Color = Color.YELLOW
@export var damage_color: Color = Color.RED
@export var outline_size: float = 2.0

var collected: bool = false
var current_hp: int = 0
var time_alive: float = 0.0
var base_y: float = 0.0
var base_outline_color: Color = Color(0, 0, 0, 0)  # Transparent (invisible)
var base_outline_size: float = 0.0  # No outline by default

var mat: ShaderMaterial
var is_mouse_hovering: bool = false

func _ready():
	add_to_group("collectable")
	
	# Initialize HP
	current_hp = hp
	
	# Create a unique material instance for this collectable
	_create_unique_material()
	
	# Initialize outline to be invisible
	_set_outline_color(base_outline_color)
	_set_outline_size(base_outline_size)
		
	# Connect GameManager signals
	GameManager.distance_updated.connect(_on_distance_updated)
	
	# Connect click signal
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	# Store base position for floating animation
	base_y = global_position.y
	
	# Play idle animation if available
	if animation and animation.has_animation("float"):
		animation.play("float")

func _on_distance_updated(amount:float, total_distance: float):
	# Move left to simulate caravan moving right
	global_position.x -= amount
	
		
func _process(delta: float):
	if collected:
		return
	
	time_alive += delta
	
	# Smooth floating animation
	#if not animation:
		#global_position.y = base_y + sin(time_alive * float_speed) * float_amplitude
	
	# Despawn if off-screen (left side)
	if global_position.x < -100:
		queue_free()

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	# Detect mouse click
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("Clicked collectable")
			if not collected:
				take_damage()

func _on_mouse_entered():
	# Visual feedback: outline when hovering
	if not collected:
		is_mouse_hovering = true
		_set_outline_color(highlight_color)
		_set_outline_size(outline_size)

func _on_mouse_exited():
	# Return to normal outline (invisible)
	if not collected:
		is_mouse_hovering = false
		_set_outline_color(base_outline_color)
		_set_outline_size(base_outline_size)

func take_damage():
	if collected:
		return
	
	current_hp -= 1
	print("Collectable took damage! HP: ", current_hp)
	
	# Visual feedback for taking damage
	play_damage_animation()
	
	# Check if HP reached 0
	if current_hp <= 0:
		collect()

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

func play_damage_animation():
	# Quick flash effect when taking damage
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Flash damage color outline briefly
	tween.tween_method(_set_outline_color, damage_color, base_outline_color, 0.2)
	tween.tween_method(_set_outline_size, outline_size, base_outline_size, 0.2)
	
	# After damage animation, restore hover state if mouse is still hovering
	tween.tween_callback(_restore_hover_state_if_needed).set_delay(0.2)

func _create_unique_material():
	# Create a unique material instance for this collectable
	if not sprite.material:
		push_error("Collectable sprite has no material assigned! Please assign an outline shader material to the sprite.")
		return
	
	mat = sprite.material.duplicate()
	sprite.material = mat

func _set_outline_color(color: Color):
	if mat:
		mat.set("shader_parameter/outline_color", color)

func _set_outline_size(size: float):
	if mat:
		mat.set("shader_parameter/outline_size", size)

func _restore_hover_state_if_needed():
	# Restore hover state if mouse is still hovering after damage animation
	if is_mouse_hovering and not collected:
		_set_outline_color(highlight_color)
		_set_outline_size(outline_size)

func play_collect_animation():
	# Emit particles
	if particles:
		particles.emitting = true
	
	# Animate sprite
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Fade out
	tween.tween_property(sprite, "modulate:a", 0.0, 0.4)
	
	# Fade out outline
	tween.tween_method(_set_outline_color, highlight_color, base_outline_color, 0.4)
	tween.tween_method(_set_outline_size, outline_size, base_outline_size, 0.4)
	
	# Scale up and move up
	tween.tween_property(sprite, "scale", Vector2(1.25, 1.25), 0.4)
	tween.tween_property(sprite, "global_position:y", global_position.y - 50, 0.4)
	
	# Slight rotation for extra juice
	tween.tween_property(sprite, "rotation_degrees", 360, 0.4)
	
	# Destroy after animation
	tween.tween_callback(queue_free).set_delay(0.4)
