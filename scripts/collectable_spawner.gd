extends Node2D

@export var collectable_scenes: Array[PackedScene] = []
@export var spawn_weights: Array[float] = []  # Optional weights for each collectable type
@export var spawn_interval: float = 2.0
@export var spawn_variance: float = 1.0
@export var spawn_height_range: float = 150.0  # Vertical range for spawns
@export var min_spawn_interval: float = 0.5  # Prevents too many at once

var spawn_timer: float = 0.0
var screen_width: float
var screen_height: float

# Track spawn patterns for difficulty scaling
var collectables_spawned: int = 0
var difficulty_multiplier: float = 1.0

func _ready():
	var viewport_size = get_viewport_rect().size
	screen_width = viewport_size.x
	screen_height = viewport_size.y
	
	# Initialize spawn weights if not set
	if spawn_weights.is_empty() and not collectable_scenes.is_empty():
		# Equal weights for all collectables
		spawn_weights.resize(collectable_scenes.size())
		for i in range(spawn_weights.size()):
			spawn_weights[i] = 1.0

func _process(delta: float):
	if not GameManager.is_running or GameManager.is_paused:
		return
	
	spawn_timer -= delta
	
	if spawn_timer <= 0:
		spawn_collectable()
		
		# Calculate next spawn time with variance
		var base_interval = spawn_interval / difficulty_multiplier
		spawn_timer = max(base_interval + randf_range(-spawn_variance, spawn_variance), min_spawn_interval)
		
		collectables_spawned += 1
		
		# Gradually increase difficulty (more frequent spawns)
		if collectables_spawned % 10 == 0:
			difficulty_multiplier = min(difficulty_multiplier + 0.1, 2.0)

func get_random_collectable_scene() -> PackedScene:
	# Return a random collectable scene based on weights
	if collectable_scenes.is_empty():
		push_error("No collectable scenes assigned to spawner!")
		return null
	
	if spawn_weights.is_empty() or spawn_weights.size() != collectable_scenes.size():
		# Fallback to equal probability
		return collectable_scenes[randi() % collectable_scenes.size()]
	
	# Weighted random selection
	var total_weight = 0.0
	for weight in spawn_weights:
		total_weight += weight
	
	var random_value = randf() * total_weight
	var current_weight = 0.0
	
	for i in range(collectable_scenes.size()):
		current_weight += spawn_weights[i]
		if random_value <= current_weight:
			return collectable_scenes[i]
	
	# Fallback (shouldn't reach here)
	return collectable_scenes[0]

func spawn_collectable():
	var collectable_scene = get_random_collectable_scene()
	if not collectable_scene:
		return
	
	var collectable = collectable_scene.instantiate()
	add_child(collectable)
	
	# Get the collectable's collision shape to determine its width
	var collision_shape = collectable.get_node("CollisionShape2D")
	var collectable_width = 130.0  # Default fallback
	if collision_shape and collision_shape.shape:
		collectable_width = collision_shape.shape.size.x
	
	# Spawn position: right side of screen with offset equal to half width, random height
	var spawn_x = screen_width + (collectable_width / 2) + 50  # Extra 50px margin
	var spawn_y = global_position.y + randf_range(-spawn_height_range / 2, spawn_height_range / 2)
	
	# Keep within screen bounds with margin
	spawn_y = clamp(spawn_y, 50, screen_height - 50)
	
	collectable.global_position = Vector2(spawn_x, spawn_y)
	

# Optional: Spawn patterns (call this instead of spawn_collectable for variety)
func spawn_pattern_line():
	# Spawn 3 collectables in a horizontal line
	for i in range(3):
		await get_tree().create_timer(0.2).timeout
		spawn_collectable()

func spawn_pattern_wave():
	# Spawn collectables in a sine wave pattern
	for i in range(5):
		var collectable_scene = get_random_collectable_scene()
		if not collectable_scene:
			continue
			
		var collectable = collectable_scene.instantiate()
		add_child(collectable)
		
		# Get the collectable's collision shape to determine its width
		var collision_shape = collectable.get_node("CollisionShape2D")
		var collectable_width = 130.0  # Default fallback
		if collision_shape and collision_shape.shape:
			collectable_width = collision_shape.shape.size.x
		
		var spawn_x = screen_width + (collectable_width / 2) + 50 + (i * 80)
		var spawn_y = (screen_height / 2) + sin(i * 0.5) * 100
		
		collectable.global_position = Vector2(spawn_x, spawn_y)
		
		await get_tree().create_timer(0.1).timeout

func clear_all_collectables():
	# Remove all existing collectable children
	for child in get_children():
		if child.is_in_group("collectable"):
			child.queue_free()
	
	# Reset spawner state
	spawn_timer = 0.0
	collectables_spawned = 0
	difficulty_multiplier = 1.0
