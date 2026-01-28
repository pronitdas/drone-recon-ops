extends RigidBody2D
class_name Enemy

## Enemy Guard with Patrol Patterns and Line-of-Sight Detection
## Detects player drones using vision cones and audio

signal player_detected(player: Drone, detection_method: String)
signal player_lost()
signal alert_state_changed(is_alert: bool)

@export var patrol_speed: float = 60.0
@export var alert_speed: float = 100.0
@export var vision_range: float = 200.0
@export var vision_angle: float = 60.0
@export var audio_detection_range: float = 100.0
@export var detection_threshold: float = 0.5
@export var suspicion_decay: float = 0.3
@export var alert_duration: float = 5.0

enum State { PATROL, SUSPICIOUS, ALERT, INVESTIGATING }

var current_state: State = State.PATROL
var suspicion_level: float = 0.0
var alert_timer: float = 0.0
var current_patrol_index: int = 0
var last_known_player_position: Vector2 = Vector2.ZERO
var player: Drone = null

@onready var vision_cone: Polygon2D = $VisionCone
@onready var detection_bar: ProgressBar = $UI/DetectionBar
@onready var alert_indicator: Sprite2D = $AlertIndicator
@onready var patrol_points: Node2D = $PatrolPoints
@onready var hearing_range: Area2D = $HearingRange

var patrol_point_positions: Array[Vector2] = []

func _ready() -> void:
	_setup_vision_cone()
	_setup_patrol_points()
	_update_detection_ui()
	
	if hearing_range:
		hearing_range.body_entered.connect(_on_hearing_body_entered)

func _setup_vision_cone() -> void:
	if vision_cone:
		_draw_vision_cone()

func _draw_vision_cone() -> void:
	var points = PackedVector2Array()
	points.append(Vector2.ZERO)
	
	var segments = 32
	for i in range(segments + 1):
		var angle = -vision_angle / 2 + (vision_angle * i / segments)
		var point = Vector2(cos(angle), sin(angle)) * vision_range
		points.append(point)
	
	vision_cone.polygon = points
	vision_cone.color = Color(1.0, 0.0, 0.0, 0.2)

func _setup_patrol_points() -> void:
	if patrol_points:
		for child in patrol_points.get_children():
			patrol_point_positions.append(child.position)
	
	if patrol_point_positions.is_empty():
		# Default patrol: stay in place
		patrol_point_positions.append(position)

func _physics_process(delta: float) -> void:
	_update_detection(delta)
	
	match current_state:
		State.PATROL:
			_patrol(delta)
		State.SUSPICIOUS:
			_suspicious(delta)
		State.ALERT:
			_alert(delta)
		State.INVESTIGATING:
			_investigate(delta)

func _update_detection(delta: float) -> void:
	if not player or player.is_crashed:
		return
	
	# Vision detection
	if _can_see_player():
		var distance = position.distance_to(player.position)
		var visibility = 1.0 - (distance / vision_range)
		suspicion_level += visibility * delta * 2.0
	
	# Audio detection
	if _can_hear_player():
		var distance = position.distance_to(player.position)
		var audibility = 1.0 - (distance / audio_detection_range)
		suspicion_level += audibility * delta * 0.5
	
	# Decay suspicion when not detected
	if suspicion_level > 0 and current_state == State.PATROL:
		suspicion_level -= suspicion_decay * delta
	
	suspicion_level = clamp(suspicion_level, 0, 1)
	_update_detection_ui()
	
	# State transitions
	if suspicion_level >= detection_threshold:
		_become_alert()
	elif suspicion_level > 0.2 and current_state == State.PATROL:
		_become_suspicious()

func _can_see_player() -> bool:
	if not player:
		return false
	
	var direction_to_player = (player.position - position).normalized()
	var angle_to_player = direction_to_player.angle()
	var angle_diff = abs(angle_diff_signed(angle_to_player, rotation))
	
	if angle_diff > vision_angle / 2:
		return false
	
	# Raycast for obstacles
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(position, player.position)
	query.exclude = [self]
	
	var result = space_state.intersect_ray(query)
	return result.is_empty()

func _can_hear_player() -> bool:
	if not player:
		return false
	
	var distance = position.distance_to(player.position)
	var player_speed = player.linear_velocity.length()
	
	# Moving makes noise
	return distance < audio_detection_range and player_speed > 20

func _patrol(delta: float) -> void:
	if patrol_point_positions.is_empty():
		return
	
	var target = patrol_point_positions[current_patrol_index]
	var direction = (target - position).normalized()
	
	apply_central_force(direction * patrol_speed * 10)
	
	if position.distance_to(target) < 5:
		current_patrol_index = (current_patrol_index + 1) % patrol_point_positions.size()
	
	# Face movement direction
	if linear_velocity.length() > 5:
		rotation = lerp_angle(rotation, linear_velocity.angle(), delta * 3.0)

func _suspicious(delta: float) -> void:
	# Look around suspiciously
	rotation += sin(Time.get_ticks_msec() / 500.0) * delta * 2.0
	
	suspicion_level -= suspicion_decay * delta * 0.5
	
	if suspicion_level <= 0:
		current_state = State.PATROL
		alert_state_changed.emit(false)

func _alert(delta: float) -> void:
	alert_timer -= delta
	
	if player and _can_see_player():
		# Chase player
		var direction = (player.position - position).normalized()
		apply_central_force(direction * alert_speed * 20)
		last_known_player_position = player.position
	else:
		# Search last known position
		var direction = (last_known_player_position - position).normalized()
		apply_central_force(direction * alert_speed * 15)
	
	if linear_velocity.length() > 5:
		rotation = lerp_angle(rotation, linear_velocity.angle(), delta * 5.0)
	
	if alert_timer <= 0:
		current_state = State.PATROL
		suspicion_level = 0
		alert_state_changed.emit(false)

func _investigate(delta: float) -> void:
	var direction = (last_known_player_position - position).normalized()
	apply_central_force(direction * alert_speed * 15)
	
	if position.distance_to(last_known_player_position) < 10:
		current_state = State.PATROL
		alert_state_changed.emit(false)

func _become_suspicious() -> void:
	if current_state == State.PATROL:
		current_state = State.SUSPICIOUS
		alert_indicator.visible = true

func _become_alert() -> void:
	if current_state != State.ALERT:
		current_state = State.ALERT
		alert_timer = alert_duration
		alert_state_changed.emit(true)
		player_detected.emit(player, "visual" if _can_see_player() else "audio")

func _update_detection_ui() -> void:
	if detection_bar:
		detection_bar.value = suspicion_level * 100
		detection_bar.modulate = Color(
			suspicion_level,
			1.0 - suspicion_level,
			0.0,
			0.8
		)

func _on_hearing_body_entered(body: Node) -> void:
	if body is Drone:
		player = body

func angle_diff_signed(a: float, b: float) -> float:
	var diff = fmod(a - b + PI, TAU) - PI
	if diff < -PI:
		diff += TAU
	return diff

func set_patrol_points(points: Array[Vector2]) -> void:
	patrol_point_positions = points

func reset_state() -> void:
	current_state = State.PATROL
	suspicion_level = 0.0
	alert_timer = 0.0
	alert_indicator.visible = false
	player = null
	_update_detection_ui()


class AlertIndicator extends Sprite2D:
	func _ready() -> void:
		visible = false
