extends Node2D
class_name Spawner

## Spawner System
## Spawns enemies, items, and effects

@export var spawn_type: String = "enemy"
@export var spawn_interval: float = 5.0
@export var max_spawns: int = 10
@export var spawn_radius: float = 100.0

var spawn_points: Array[Vector2] = []
var active_spawns: Array[Node] = []
var spawn_timer: float = 0.0
var is_active: bool = true

func _ready() -> void:
	_setup_spawn_points()

func _setup_spawn_points() -> void:
	# Default spawn points
	pass

func _process(delta: float) -> void:
	if not is_active:
		return
	
	if spawn_interval > 0:
		spawn_timer += delta
		if spawn_timer >= spawn_interval:
			spawn_timer = 0
			_spawn_one()

func _spawn_one() -> void:
	if active_spawns.size() >= max_spawns:
		return
	
	var spawn_pos = _get_spawn_position()
	var spawned = _create_spawn(spawn_pos)
	
	if spawned:
		active_spawns.append(spawned)

func _get_spawn_position() -> Vector2:
	if spawn_points.is_empty():
		return position
	
	var random_point = spawn_points.pick_random()
	return random_point + Vector2(randf_range(-50, 50), randf_range(-50, 50))

func _create_spawn(pos: Vector2) -> Node:
	match spawn_type:
		"enemy":
			return _spawn_enemy(pos)
		"battery":
			return _spawn_battery(pos)
		"intel":
			return _spawn_intel(pos)
	return null

func _spawn_enemy(pos: Vector2) -> Node:
	var enemy = load("res://scenes/enemy.tscn").instantiate()
	enemy.position = pos
	add_child(enemy)
	return enemy

func _spawn_battery(pos: Vector2) -> Node:
	var battery = Collectible.new()
	battery.item_type = "battery"
	battery.position = pos
	add_child(battery)
	return battery

func _spawn_intel(pos: Vector2) -> Node:
	var intel = Collectible.new()
	intel.item_type = "intel"
	intel.position = pos
	add_child(intel)
	return intel

func set_spawn_type(type: String) -> void:
	spawn_type = type

func set_active(active: bool) -> void:
	is_active = active

func clear_all_spawns() -> void:
	for spawn in active_spawns:
		if is_instance_valid(spawn):
			spawn.queue_free()
	active_spawns.clear()

func add_spawn_point(pos: Vector2) -> void:
	spawn_points.append(pos)
