extends Node2D
class_name LevelTransition

## Level Transition Effects
## Creates cinematic transitions between levels

var transition_active: bool = false

func _ready() -> void:
	pass

func transition_to_black(duration: float = 1.0, callback: Callable = Callable()) -> void:
	transition_active = true
	
	var black_rect = ColorRect.new()
	black_rect.color = Color.BLACK
	black_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	black_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	black_rect.modulate.a = 0.0
	add_child(black_rect)
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(black_rect, "modulate:a", 1.0, duration / 2)
	tween.tween_callback(func(): 
		if callback.is_valid():
			callback.call()
	)
	tween.tween_interval(duration / 4)
	tween.tween_property(black_rect, "modulate:a", 0.0, duration / 2)
	tween.tween_callback(func():
		black_rect.queue_free()
		transition_active = false
	)

func transition_to_white(duration: float = 1.0, callback: Callable = Callable()) -> void:
	transition_active = true
	
	var white_rect = ColorRect.new()
	white_rect.color = Color.WHITE
	white_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	white_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	white_rect.modulate.a = 0.0
	add_child(white_rect)
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(white_rect, "modulate:a", 1.0, duration / 2)
	tween.tween_callback(func():
		if callback.is_valid():
			callback.call()
	)
	tween.tween_interval(duration / 4)
	tween.tween_property(white_rect, "modulate:a", 0.0, duration / 2)
	tween.tween_callback(func():
		white_rect.queue_free()
		transition_active = false
	)

func create_wipe(direction: Vector2, duration: float = 0.5) -> void:
	# Create a wipe effect in the given direction
	transition_active = true
	
	var wipe = Polygon2D.new()
	var viewport_size = get_viewport_rect().size
	var points = PackedVector2Array()
	
	# Create triangle that covers half the screen
	match direction:
		Vector2.RIGHT:
			points = PackedVector2Array([
				Vector2(viewport_size.x, 0),
				Vector2(viewport_size.x, viewport_size.y),
				Vector2(viewport_size.x + viewport_size.x, viewport_size.y / 2)
			])
		Vector2.LEFT:
			points = PackedVector2Array([
				Vector2(0, 0),
				Vector2(0, viewport_size.y),
				Vector2(-viewport_size.x, viewport_size.y / 2)
			])
		_:
			# Default to right wipe
			points = PackedVector2Array([
				Vector2(viewport_size.x, 0),
				Vector2(viewport_size.x, viewport_size.y),
				Vector2(viewport_size.x + viewport_size.x, viewport_size.y / 2)
			])
	
	wipe.polygon = points
	wipe.color = Color.BLACK
	wipe.position.x = -viewport_size.x
	add_child(wipe)
	
	var tween = create_tween()
	tween.tween_property(wipe, "position:x", 0, duration / 2)
	tween.tween_interval(0.1)
	tween.tween_property(wipe, "position:x", viewport_size.x, duration / 2)
	tween.tween_callback(func():
		wipe.queue_free()
		transition_active = false
	)

func create_slide_transition(duration: float = 0.5) -> void:
	# Slide current scene out and new scene in
	transition_active = true
	
	var current_scene = get_parent()
	var slide_out = Polygon2D.new()
	var viewport_size = get_viewport_rect().size
	slide_out.polygon = PackedVector2Array([
		Vector2(0, 0),
		Vector2(viewport_size.x, 0),
		Vector2(viewport_size.x, viewport_size.y),
		Vector2(0, viewport_size.y)
	])
	slide_out.color = Color.BLACK
	add_child(slide_out)
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(slide_out, "position:x", -viewport_size.x, duration)
	tween.tween_callback(func():
		slide_out.queue_free()
		transition_active = false
	)
