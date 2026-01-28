extends Node2D
class_name CameraController

## Smooth Camera Follow
## Adds cinematic feel with smooth following and shake

@export var follow_speed: float = 5.0
@export var deadzone: Vector2 = Vector2(100, 50)
@export var shake_decay: float = 0.9
@export var max_shake: float = 20.0

var target: Node2D = null
var current_offset: Vector2 = Vector2.ZERO
var shake_amount: Vector2 = Vector2.ZERO
var base_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	pass

func set_target(t: Node2D) -> void:
	target = t
	base_position = position

func _process(delta: float) -> void:
	if not target:
		return
	
	# Calculate desired position
	var target_pos = target.position
	var viewport_center = get_viewport_rect().size / 2
	
	# Only follow if target is outside deadzone
	var offset = target_pos - viewport_center - current_offset
	
	if abs(offset.x) > deadzone.x:
		current_offset.x = lerp(current_offset.x, offset.x, follow_speed * delta)
	if abs(offset.y) > deadzone.y:
		current_offset.y = lerp(current_offset.y, offset.y, follow_speed * delta)
	
	# Apply shake
	shake_amount *= shake_decay
	if shake_amount.length() < 0.1:
		shake_amount = Vector2.ZERO
	
	var shake_offset = Vector2(
		randf_range(-shake_amount.x, shake_amount.x),
		randf_range(-shake_amount.y, shake_amount.y)
	)
	
	position = base_position - current_offset + shake_offset

func add_shake(amount: float) -> void:
	shake_amount.x = min(shake_amount.x + amount, max_shake)
	shake_amount.y = min(shake_amount.y + amount, max_shake)

func screen_shake(intensity: float, duration: float) -> void:
	shake_amount = Vector2(intensity, intensity)
	# Auto decay handles the duration

func pulse_zoom(zoom_factor: float, duration: float) -> void:
	var tween = create_tween()
	tween.tween_property(self, "zoom", Vector2(zoom_factor, zoom_factor), duration / 2)
	tween.tween_property(self, "zoom", Vector2(1, 1), duration / 2)

func flash_screen(color: Color, duration: float) -> void:
	var flash = ColorRect.new()
	flash.color = color
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(flash)
	
	var tween = create_tween()
	tween.tween_property(flash, "modulate:a", 0.0, duration)
	tween.tween_callback(flash.queue_free)
