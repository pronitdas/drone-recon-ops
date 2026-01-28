extends Node2D
class_name EnemySprite

## Enemy Guard Sprite Renderer
## Creates procedural guard graphics

@export var is_alert: bool = false
var alert_timer: float = 0.0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if is_alert:
		alert_timer += delta * 10
	queue_redraw()

func _draw() -> void:
	var base_color = Color(0.6, 0.2, 0.2) if is_alert else Color(0.3, 0.3, 0.4)
	var blink_intensity = abs(sin(alert_timer)) if is_alert else 0
	
	# Body
	draw_circle(Vector2.ZERO, 18, base_color)
	draw_arc(Vector2.ZERO, 18, 0, TAU, 32, Color(0.2, 0.2, 0.3), 2.0)
	
	# Head/Helmet
	draw_circle(Vector2.ZERO, 12, Color(0.25, 0.25, 0.35))
	
	# Visor
	var visor_y = -3
	draw_rect(Rect2(-10, visor_y - 3, 20, 6), Color(0.1, 0.1, 0.15))
	
	# Visor glow
	var visor_glow = Color(1.0, 0.3, 0.3, 0.5 + blink_intensity * 0.5) if is_alert else Color(0.3, 0.8, 0.3, 0.3)
	draw_rect(Rect2(-8, visor_y - 1, 16, 2), visor_glow)
	
	# Shoulders
	draw_circle(Vector2(-15, 10), 6, base_color)
	draw_circle(Vector2(15, 10), 6, base_color)
	
	# Weapon
	draw_rect(Rect2(15, 5, 20, 5), Color(0.2, 0.2, 0.25))
	draw_rect(Rect2(32, 3, 8, 9), Color(0.15, 0.15, 0.2))
	
	# Alert indicator above head
	if is_alert:
		var alert_y = -35 + sin(alert_timer) * 3
		var alert_size = 8 + blink_intensity * 4
		
		# Exclamation mark
		draw_circle(Vector2(0, alert_y), alert_size, Color(1.0, 0.2, 0.2, 0.8))
		draw_circle(Vector2(0, alert_y), alert_size * 0.6, Color(1.0, 0.5, 0.5, 0.9))
		
		# Eyes glow brighter when alert
		draw_circle(Vector2(-5, -3), 3, Color(1.0, 0.2, 0.2))
		draw_circle(Vector2(5, -3), 3, Color(1.0, 0.2, 0.2))
	else:
		# Normal eyes
		draw_circle(Vector2(-5, -3), 2, Color(0.3, 0.8, 0.3))
		draw_circle(Vector2(5, -3), 2, Color(0.3, 0.8, 0.3))
	
	# Feet
	draw_rect(Rect2(-10, 20, 8, 8), Color(0.2, 0.2, 0.25))
	draw_rect(Rect2(2, 20, 8, 8), Color(0.2, 0.2, 0.25))

func set_alert_state(alert: bool) -> void:
	is_alert = alert
	alert_timer = 0
