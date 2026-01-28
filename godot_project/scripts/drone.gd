extends RigidBody2D
class_name Drone

## Drone Recon Ops - Player Controlled Drone
## Physics-based flight with battery management and stealth considerations

signal battery_changed(value: float)
signal detection_changed(value: float)
signal action_completed(action_type: String, success: bool)
signal crashed()

@export var move_speed: float = 300.0
@export var acceleration: float = 800.0
@export var max_battery: float = 100.0
@export var battery_drain_rate: float = 2.0
@export var vertical_thrust: float = 400.0
@export var drag: float = 3.0
@export var action_cooldown: float = 0.5

var battery: float = 100.0
var current_detection: float = 0.0
var action_timer: float = 0.0
var is_crashed: bool = false
var velocity_multiplier: float = 1.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var detection_zone: Area2D = $DetectionZone
@onready var battery_bar: ProgressBar = $UI/BatteryBar
@onready var trail_particles: GPUParticles2D = $TrailParticles
@onready var thruster_particles: GPUParticles2D = $ThrusterParticles
@onready var camera: Camera2D = $Camera2D

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 4
	gravity_scale = 0.0
	linear_damp = drag
	angular_damp = 2.0
	
	battery = max_battery
	battery_changed.emit(battery)
	
	if detection_zone:
		detection_zone.body_entered.connect(_on_body_entered)
	
	_setup_particles()

func _setup_particles() -> void:
	if trail_particles:
		trail_particles.emitting = false
	if thruster_particles:
		thruster_particles.emitting = false

func _physics_process(delta: float) -> void:
	if is_crashed:
		return
	
	_handle_movement(delta)
	_handle_battery(delta)
	_handle_action_cooldown(delta)
	_update_particles()
	_check_battery_warning()

func _handle_movement(delta: float) -> void:
	var input_dir := Vector2.ZERO
	
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1
	if Input.is_action_pressed("move_up"):
		input_dir.y -= 1
	if Input.is_action_pressed("move_down"):
		input_dir.y += 1
	
	if Input.is_action_pressed("ascend"):
		apply_central_force(Vector2.UP * vertical_thrust)
	if Input.is_action_pressed("descend"):
		apply_central_force(Vector2.DOWN * vertical_thrust)
	
	input_dir = input_dir.normalized()
	
	if input_dir != Vector2.ZERO:
		var target_velocity = input_dir * move_speed * velocity_multiplier
		var force = (target_velocity - linear_velocity) * acceleration * mass * delta
		apply_central_force(force)
		
		# Rotate towards movement direction
		var target_angle = linear_velocity.angle()
		rotation = lerp_angle(rotation, target_angle, delta * 5.0)
		
		# Play thrust sound effect
		_play_thrust_effect()

func _handle_battery(delta: float) -> void:
	if linear_velocity.length() > 10:
		battery -= battery_drain_rate * delta
	
	battery = clamp(battery, 0, max_battery)
	battery_changed.emit(battery)
	
	if battery <= 0:
		_crash("Battery depleted!")

func _handle_action_cooldown(delta: float) -> void:
	if action_timer > 0:
		action_timer -= delta

func _update_particles() -> void:
	var speed = linear_velocity.length()
	
	if trail_particles and speed > 50:
		trail_particles.emitting = true
		trail_particles.amount_ratio = min(speed / move_speed, 1.0)
	else:
		trail_particles.emitting = false

func _check_battery_warning() -> void:
	if battery < 20:
		# Add screen shake or warning effect
		if randf() < 0.05:
			_camera_shake(3.0)

func _play_thrust_effect() -> void:
	# Play sound effect if audio player exists
	pass

func _camera_shake(amount: float) -> void:
	if camera:
		camera.h_offset = randf_range(-amount, amount)
		camera.v_offset = randf_range(-amount, amount)

func perform_action(action_type: String) -> bool:
	if action_timer > 0 or is_crashed:
		return false
	
	action_timer = action_cooldown
	
	match action_type:
		"scan":
			return _perform_scan()
		"hack":
			return _perform_hack()
		"mark":
			return _perform_mark()
		"photograph":
			return _perform_photograph()
	
	return false

func _perform_scan() -> bool:
	# Quick scan to detect nearby enemies
	if battery < 10:
		return false
	battery -= 10
	
	# Visual feedback - expanding ring
	_create_scan_effect()
	action_completed.emit("scan", true)
	return true

func _perform_hack() -> bool:
	# Hack nearby terminals
	if battery < 15:
		return false
	battery -= 15
	action_completed.emit("hack", true)
	return true

func _perform_mark() -> bool:
	# Mark enemy positions
	if battery < 5:
		return false
	battery -= 5
	action_completed.emit("mark", true)
	return true

func _perform_photograph() -> bool:
	# Photograph targets
	if battery < 8:
		return false
	battery -= 8
	_create_capture_effect()
	action_completed.emit("photograph", true)
	return true

func _create_scan_effect() -> void:
	var ring = RingEffect.new()
	ring.position = position
	ring.scale = Vector2(0.1, 0.1)
	ring.modulate = Color(0.0, 1.0, 0.5, 0.8)
	get_parent().add_child(ring)

func _create_capture_effect() -> void:
	var flash = CameraFlash.new()
	flash.position = position
	get_parent().add_child(flash)

func _on_body_entered(body: Node) -> void:
	if body is Wall or body is Obstacle:
		_crash("Collision detected!")

func _crash(reason: String) -> void:
	if is_crashed:
		return
	is_crashed = true
	crashed.emit(reason)
	linear_damp = 10.0
	
	if trail_particles:
		trail_particles.emitting = false
	if thruster_particles:
		thruster_particles.emitting = false
	
	# Explosion effect
	_create_explosion()

func _create_explosion() -> void:
	var explosion = ExplosionEffect.new()
	explosion.position = position
	explosion.modulate = Color(1.0, 0.3, 0.1, 1.0)
	get_parent().add_child(explosion)

func reset_drone(pos: Vector2) -> void:
	position = pos
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	battery = max_battery
	is_crashed = false
	linear_damp = drag
	detection_changed.emit(0.0)


class RingEffect extends Node2D:
	var lifetime: float = 0.5
	var max_radius: float = 200.0
	
	func _ready() -> void:
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(3, 3), lifetime)
		tween.parallel().tween_property(self, "modulate:a", 0.0, lifetime)
		tween.tween_callback(queue_free)
	
	func _draw() -> void:
		draw_arc(Vector2.ZERO, max_radius * scale.x, 0, TAU, 64, Color.WHITE, 2.0)


class CameraFlash extends Node2D:
	var lifetime: float = 0.1
	
	func _ready() -> void:
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.0, lifetime)
		tween.tween_callback(queue_free)
	
	func _draw() -> void:
		draw_rect(get_viewport_rect(), Color.WHITE)


class ExplosionEffect extends Node2D:
	var lifetime: float = 0.3
	var particles: Array[Vector2] = []
	
	func _ready() -> void:
		for i in range(20):
			particles.append(Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized())
		
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(self, "scale", Vector2(2, 2), lifetime)
		tween.tween_property(self, "modulate:a", 0.0, lifetime)
		tween.tween_callback(queue_free)
	
	func _draw() -> void:
		for dir in particles:
			var end = dir * 50 * scale.x
			draw_line(Vector2.ZERO, end, Color(1.0, 0.5, 0.0), 3.0 * modulate.a)
