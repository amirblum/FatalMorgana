extends Node2D
class_name Caravan

@onready var sprite = $CaravanSprite
@onready var upgrade_visuals = $UpgradeVisuals if has_node("UpgradeVisuals") else null
@onready var animation_player = $AnimationPlayer if has_node("AnimationPlayer") else null

var bob_speed: float = 2.0
var bob_amount: float = 5.0
var time: float = 0.0

func _ready():
	GameManager.water_changed.connect(_on_water_changed)
	
	# Hide all upgrade visuals for now (we'll use them later)
	if upgrade_visuals:
		for child in upgrade_visuals.get_children():
			child.visible = false
	
	if animation_player and animation_player.has_animation("bob"):
		animation_player.play("bob")

func _process(delta: float):
	if not GameManager.is_running or GameManager.is_paused:
		return
	
	if not animation_player or not animation_player.is_playing():
		time += delta
		sprite.position.y = sin(time * bob_speed) * bob_amount

func _on_water_changed(new_water: float, max_water: float):
	var water_ratio = new_water / max_water
	
	if water_ratio < 0.25:
		sprite.modulate = Color(1.0, 0.7, 0.7)
	elif water_ratio < 0.5:
		sprite.modulate = Color(1.0, 0.9, 0.8)
	else:
		sprite.modulate = Color.WHITE

func celebrate():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "rotation_degrees", 10, 0.2)
	tween.tween_property(sprite, "scale", Vector2(1.15, 1.15), 0.2)
	tween.chain()
	tween.tween_property(sprite, "rotation_degrees", 0, 0.2)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.2)

# TODO: When you add upgrades back, uncomment this:
# func show_upgrade(upgrade_id: String):
#     if upgrade_visuals:
#         match upgrade_id:
#             "tarp": $UpgradeVisuals/TarpSprite.visible = true
#             "scout": $UpgradeVisuals/ScoutCamelSprite.visible = true
#             "jars": $UpgradeVisuals/ExtraJarsSprite.visible = true
