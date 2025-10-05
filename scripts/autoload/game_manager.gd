extends Node

# ===== SIGNALS =====
signal water_changed(new_value: float, max_value: float)
signal water_depleted()
signal game_over()
signal game_won()
signal distance_updated(amount: float, total_distance: float)

# ===== GAME STATE =====
var is_running: bool = false
var is_paused: bool = false

# ===== WATER SYSTEM =====
var current_water: float = 50.0
var max_water: float = 20.0
var water_drain_rate: float = 1.0  # Water lost per second

# ===== PROGRESSION =====
var progression_speed: float = 50.0
var distance_traveled: float = 0.0
var win_distance: float = 5000.0  # Distance needed to win

# ===== VISUAL STAGES =====
var visual_stage: int = 0  # 0=barren, 1=sparse, 2=lush

func _ready():
	print("GameManager initialized")

# ===== GAME FLOW =====
func start_new_run():
	print("Starting new run...")
	
	# Reset run state
	distance_traveled = 0.0
	current_water = max_water
	visual_stage = 0
	
	# Start game
	is_running = true
	is_paused = false
	
	# Emit initial signals
	water_changed.emit(current_water, max_water)
	distance_updated.emit(0.0, distance_traveled)

func pause_game():
	is_paused = true
	print("Game paused")

func resume_game():
	is_paused = false
	print("Game resumed")

func end_game():
	is_running = false
	is_paused = false
	game_over.emit()
	print("Game Over - Out of water!")

func win_game():
	is_running = false
	is_paused = false
	game_won.emit()
	print("You Win - Reached the oasis!")

# ===== CORE GAME LOOP =====
func _process(delta: float):
	if not is_running or is_paused:
		return
	
	# Drain water continuously
	change_water(-water_drain_rate * delta)
	
	# Update distance (simulates caravan moving)
	add_distance(progression_speed * delta)  # 100 pixels per second
	
	# Check lose condition
	if current_water <= 0:
		end_game()

# ===== WATER MANAGEMENT =====
func change_water(amount: float):
	var old_water = current_water
	current_water = clamp(current_water + amount, 0, max_water)
	
	# Only emit if actually changed
	if current_water != old_water:
		water_changed.emit(current_water, max_water)
	
	# Check for depletion
	if current_water <= 0 and old_water > 0:
		water_depleted.emit()

# ===== DISTANCE/PROGRESSION =====
func add_distance(amount: float):
	distance_traveled += amount
	distance_updated.emit(amount, distance_traveled)
	
	# Check for visual stage changes
	update_visual_stage()
	
	# Check win condition
	if distance_traveled >= win_distance:
		win_game()

func update_visual_stage():
	var new_stage = get_stage_from_distance()
	
	if new_stage != visual_stage:
		visual_stage = new_stage
		print("Visual stage changed to: ", visual_stage)
		# Desert scene can listen to this or check visual_stage directly

func get_stage_from_distance() -> int:
	if distance_traveled < 1000:
		return 0  # Lush oasis
	elif distance_traveled < 2000:
		return 1  # Sparse vegetation
	else:
		return 2  # Barren desert

# ===== HELPER FUNCTIONS =====
func get_water_percentage() -> float:
	return (current_water / max_water) * 100.0

func get_distance_percentage() -> float:
	return (distance_traveled / win_distance) * 100.0

func is_low_water() -> bool:
	return current_water < max_water * 0.25  # Less than 25%

func is_critical_water() -> bool:
	return current_water < max_water * 0.1  # Less than 10%
