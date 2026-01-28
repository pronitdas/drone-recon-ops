extends Node2D
class_name StealthSystem

## Global stealth calculation and visibility management
## Aggregates detection from all enemies and manages player stealth state

signal stealth_changed(stealth_value: float)
signal detected(detection_method: String)
signal hidden()

@export var base_stealth: float = 1.0
@export var noise_penalty: float = 0.3
@export var light_bonus: float = 0.2
@export var darkness_bonus: float = 0.4

var player: Drone = null
var enemies: Array[Enemy] = []
var is_hidden: bool = true
var current_stealth: float = 1.0
var detection_accumulator: float = 0.0

func _ready() -> void:
	pass

func register_player(p: Drone) -> void:
	player = p

func register_enemy(e: Enemy) -> void:
	if not enemies.has(e):
		enemies.append(e)
		e.player_detected.connect(_on_enemy_detection)
		e.alert_state_changed.connect(_on_enemy_alert)

func _physics_process(delta: float) -> void:
	if not player or player.is_crashed:
		return
	
	var total_detection = 0.0
	var player_noise = _calculate_player_noise()
	
	for enemy in enemies:
		if not is_instance_valid(enemy):
			enemies.erase(enemy)
			continue
		
		var enemy_detection = _calculate_enemy_detection(enemy, player_noise)
		total_detection += enemy_detection
	
	current_stealth = clamp(1.0 - total_detection, 0, 1)
	
	if total_detection > 0.3:
		if is_hidden:
			is_hidden = false
			hidden.emit()
	else:
		if not is_hidden:
			is_hidden = true
			hidden.emit()
	
	stealth_changed.emit(current_stealth)

func _calculate_player_noise() -> float:
	if not player:
		return 0
	
	var speed = player.linear_velocity.length()
	var noise = speed / 300.0
	
	# Battery low makes more noise
	if player.battery < 20:
		noise += 0.2
	
	return noise

func _calculate_enemy_detection(enemy: Enemy, player_noise: float) -> float:
	if not enemy or enemy.current_state == Enemy.State.PATROL:
		return 0.0
	
	var distance = enemy.position.distance_to(player.position)
	
	# Vision detection
	var enemy_vision = enemy.vision_range
	if distance < enemy_vision:
		var visibility = 1.0 - (distance / enemy_vision)
		
		# Check if in vision cone
		var direction = (player.position - enemy.position).normalized()
		var angle_to_player = direction.angle()
		var angle_diff = abs(angle_diff_signed(angle_to_player, enemy.rotation))
		
		if angle_diff < enemy.vision_angle / 2:
			# Check line of sight
			if _has_line_of_sight(enemy.position, player.position):
				return visibility * (1.0 - current_stealth)
	
	# Audio detection
	if player_noise > 0:
		var audio_range = enemy.audio_detection_range
		if distance < audio_range:
			var audibility = (1.0 - distance / audio_range) * player_noise
			return audibility * noise_penalty * (1.0 - current_stealth)
	
	return 0.0

func _has_line_of_sight(from: Vector2, to: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(from, to)
	query.exclude = [player]
	
	var result = space_state.intersect_ray(query)
	return result.is_empty()

func _on_enemy_detection(player: Drone, method: String) -> void:
	detection_accumulator += 0.1
	detected.emit(method)

func _on_enemy_alert(is_alert: bool) -> void:
	if is_alert:
		detection_accumulator += 0.3
	else:
		detection_accumulator -= 0.1
	
	detection_accumulator = clamp(detection_accumulator, 0, 1)

func get_detection_level() -> float:
	return 1.0 - current_stealth

func angle_diff_signed(a: float, b: float) -> float:
	var diff = fmod(a - b + PI, TAU) - PI
	if diff < -PI:
		diff += TAU
	return diff

func reset() -> void:
	detection_accumulator = 0.0
	current_stealth = 1.0
	is_hidden = true
