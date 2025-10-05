extends ParallaxBackground

@onready var sky_layer = $SkyLayer if has_node("SkyLayer") else null
@onready var dunes_back = $DunesBackLayer if has_node("DunesBackLayer") else null
@onready var dunes_front = $DunesFrontLayer if has_node("DunesFrontLayer") else null
@onready var vegetation_layer = $VegetationLayer if has_node("VegetationLayer") else null

var scroll_multiplier: float = 0.1
var current_stage: int = -1  # Track to avoid redundant updates

func _ready():
	# Initial stage setup
	# update_stage(0)
	GameManager.distance_updated.connect(_on_distance_updated)
	
func _on_distance_updated(_amount:float, total_distance: float):	
	# Scroll background
	scroll_offset.x = -total_distance * scroll_multiplier
	
	# Check if stage changed
	var new_stage = GameManager.visual_stage
	if new_stage != current_stage:
		current_stage = new_stage
		# update_stage(new_stage)

func update_stage(stage: int):
	print("Desert updating to stage: ", stage)
	
	match stage:
		0:  # Barren desert
			if sky_layer:
				modulate_layer(sky_layer, Color(0.95, 0.85, 0.7))  # Hot, sandy sky
			if dunes_back:
				modulate_layer(dunes_back, Color(0.9, 0.8, 0.6))  # Pale dunes
			if dunes_front:
				modulate_layer(dunes_front, Color(0.85, 0.75, 0.55))  # Slightly darker
			if vegetation_layer:
				modulate_layer(vegetation_layer, Color(1.0, 1.0, 1.0, 0.0))  # Invisible
		
		1:  # Sparse vegetation
			if sky_layer:
				modulate_layer(sky_layer, Color(0.9, 0.88, 0.8))  # Slightly cooler
			if dunes_back:
				modulate_layer(dunes_back, Color(0.85, 0.8, 0.65))
			if dunes_front:
				modulate_layer(dunes_front, Color(0.8, 0.75, 0.6))
			if vegetation_layer:
				modulate_layer(vegetation_layer, Color(1.0, 1.0, 1.0, 0.4))  # Semi-visible
		
		2:  # Lush oasis
			if sky_layer:
				modulate_layer(sky_layer, Color(0.85, 0.9, 0.85))  # Green-tinted
			if dunes_back:
				modulate_layer(dunes_back, Color(0.7, 0.8, 0.65))
			if dunes_front:
				modulate_layer(dunes_front, Color(0.65, 0.75, 0.6))
			if vegetation_layer:
				modulate_layer(vegetation_layer, Color(1.0, 1.0, 1.0, 1.0))  # Fully visible

# Helper function to modulate a layer's children
func modulate_layer(paralaxLayer: ParallaxLayer, color: Color):
	# Modulate all sprites/visuals in the layer
	for child in paralaxLayer.get_children():
		if child is CanvasItem:  # Sprite2D, ColorRect, etc.
			child.modulate = color

# Optional: React to low water with visual warning
func set_danger_tint(enabled: bool):
	var tint = Color(1.0, 0.95, 0.95) if enabled else Color.WHITE
	
	if sky_layer:
		modulate_layer(sky_layer, tint)
