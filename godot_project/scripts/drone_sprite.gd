extends Node2D
class_name DroneSprite

## Drone Sprite Renderer
## Creates procedural drone graphics

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	# Main body - circular drone core
	draw_circle(Vector2.ZERO, 15, Color(0.2, 0.2, 0.25))
	draw_arc(Vector2.ZERO, 15, 0, TAU, 32, Color(0.0, 1.0, 0.5), 2.0)
	
	# Inner light
	draw_circle(Vector2.ZERO, 8, Color(0.0, 0.8, 0.4))
	draw_circle(Vector2.ZERO, 4, Color(0.5, 1.0, 0.8))
	
	# Rotor arms
	var arm_length = 25.0
	var arm_thickness = 3.0
	
	for i in range(4):
		var angle = i * PI / 2
		var direction = Vector2(cos(angle), sin(angle))
		var start = direction * 12
		var end = direction * arm_length
		
		# Arm
		draw_line(start, end, Color(0.3, 0.3, 0.35), arm_thickness)
		
		# Rotor at end
		var rotor_center = end
		var rotor_size = 8
		
		draw_circle(rotor_center, rotor_size, Color(0.15, 0.15, 0.2))
		draw_arc(rotor_center, rotor_size, 0, TAU, 16, Color(0.0, 0.8, 0.4), 1.5)
		
		# Rotor blades
		var blade_angle = Time.get_ticks_msec() / 50.0 + i * PI / 2
		var blade1 = Vector2(cos(blade_angle), sin(blade_angle)) * rotor_size * 0.9
		var blade2 = Vector2(cos(blade_angle + PI), sin(blade_angle + PI)) * rotor_size * 0.9
		draw_line(rotor_center - blade1, rotor_center + blade1, Color(0.8, 0.8, 0.8), 2.0)
		draw_line(rotor_center - blade2, rotor_center + blade2, Color(0.8, 0.8, 0.8), 2.0)
	
	# Camera lens
	draw_arc(Vector2(0, 0), 5, -PI/4, PI/4, 16, Color(0.1, 0.1, 0.15), 1.0)
	draw_circle(Vector2(0, 0), 2, Color(1.0, 0.3, 0.3))
	
	# Status LEDs
	var blink_speed = 2.0
	var blink = sin(Time.get_ticks_msec() / 1000.0 * PI * blink_speed) * 0.5 + 0.5
	var led_color = Color(1.0, 0.5, 0.0, blink)
	
	draw_circle(Vector2(10, 10), 2, led_color)
