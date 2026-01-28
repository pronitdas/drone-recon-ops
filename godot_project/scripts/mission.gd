extends Node2D
class_name MissionObjective

## Mission Objective Base Class
## Extend this for different mission types

signal objective_completed(objective: MissionObjective)
signal objective_failed(objective: MissionObjective, reason: String)
signal progress_updated(objective: MissionObjective, progress: float)

enum Type { SURVEILLANCE, DATA_EXTRACTION, TARGET_MARKING, COLLECT_DATA }

@export var objective_type: Type
@export var objective_name: String = "Mission Objective"
@export var time_limit: float = 0.0  # 0 = no limit
@export var required_progress: float = 1.0

var player: Drone = null
var is_complete: bool = false
var is_failed: bool = false
var current_progress: float = 0.0
var time_remaining: float = 0.0

func _ready() -> void:
	if time_limit > 0:
		time_remaining = time_limit

func _physics_process(delta: float) -> void:
	if is_complete or is_failed:
		return
	
	_update_progress(delta)
	
	if time_limit > 0:
		time_remaining -= delta
		if time_remaining <= 0:
			_fail("Time limit exceeded!")

func _update_progress(delta: float) -> void:
	# Override in subclasses
	pass

func _complete() -> void:
	if is_complete or is_failed:
		return
	is_complete = true
	objective_completed.emit(self)

func _fail(reason: String) -> void:
	if is_complete or is_failed:
		return
	is_failed = true
	objective_failed.emit(self, reason)

func check_completion() -> bool:
	return is_complete

func check_failure() -> bool:
	return is_failed

func get_progress() -> float:
	return current_progress / required_progress


class SurveillanceObjective extends MissionObjective:
	## Photograph specific targets without detection
	
	var target_areas: Array[Area2D] = []
	var photographed_targets: Array[String] = []
	var max_targets: int = 3
	
	func _ready() -> void:
		super._ready()
		objective_type = Type.SURVEILLANCE
		objective_name = "Surveillance: Photograph targets"
	
	func register_target(area: Area2D, target_id: String) -> void:
		area.body_entered.connect(_on_target_entered.bind(target_id))
		target_areas.append(area)
	
	func _on_target_entered(body: Node, target_id: String) -> void:
		if body is Drone and not photographed_targets.has(target_id):
			if body.perform_action("photograph"):
				photographed_targets.append(target_id)
				current_progress += 1
				progress_updated.emit(self, get_progress())
				
				if current_progress >= required_progress:
					_complete()


class DataExtractionObjective extends MissionObjective:
	## Infiltrate and hack digital systems
	
	var hackable_devices: Array[Node2D] = []
	var hacked_devices: Array[String] = []
	var hack_time: float = 2.0
	var current_hack_progress: float = 0.0
	var is_hacking: bool = false
	
	func _ready() -> void:
		super._ready()
		objective_type = Type.DATA_EXTRACTION
		objective_name = "Data Extraction: Hack terminals"
	
	func register_device(device: Node2D, device_id: String) -> void:
		hackable_devices.append(device)
		device.set_meta("device_id", device_id)
	
	func start_hack(player_drone: Drone) -> void:
		if is_hacking or is_complete or is_failed:
			return
		
		player = player_drone
		is_hacking = true
		current_hack_progress = 0.0
	
	func _update_progress(delta: float) -> void:
		if not is_hacking or not player:
			return
		
		if player.is_crashed:
			is_hacking = false
			return
		
		# Must be close to a hackable device
		var near_device = false
		for device in hackable_devices:
			if position.distance_to(device.position) < 50:
				near_device = true
				break
		
		if not near_device:
			is_hacking = false
			current_hack_progress = 0.0
			return
		
		current_hack_progress += delta
		progress_updated.emit(self, current_hack_progress / hack_time)
		
		if current_hack_progress >= hack_time:
			is_hacking = false
			current_progress += 1
			
			if current_progress >= required_progress:
				_complete()


class TargetMarkingObjective extends MissionObjective:
	## Identify and mark enemy positions
	
	var marked_enemies: Array[Node2D] = []
	var enemy_list: Array[Node2D] = []
	var marking_range: float = 150.0
	
	func _ready() -> void:
		super._ready()
		objective_type = Type.TARGET_MARKING
		objective_name = "Target Marking: Mark enemy positions"
	
	func register_enemy(enemy: Node2D) -> void:
		if not enemy_list.has(enemy):
			enemy_list.append(enemy)
	
	func try_mark(player_drone: Drone) -> bool:
		if is_complete or is_failed:
			return false
		
		var nearest_enemy = _find_nearest_enemy(player_drone.position)
		if nearest_enemy and player_drone.position.distance_to(nearest_enemy.position) < marking_range:
			if player_drone.perform_action("mark"):
				marked_enemies.append(nearest_enemy)
				current_progress += 1
				progress_updated.emit(self, get_progress())
				
				if current_progress >= required_progress:
					_complete()
				return true
		return false
	
	func _find_nearest_enemy(from_pos: Vector2) -> Node2D:
		var nearest = null
		var nearest_dist = INF
		
		for enemy in enemy_list:
			var dist = from_pos.distance_to(enemy.position)
			if dist < nearest_dist:
				nearest = enemy
				nearest_dist = dist
		
		return nearest


class CollectDataObjective extends MissionObjective:
	## Collect data packets or intel items
	
	var data_locations: Array[Vector2] = []
	var collected_data: Array[int] = []
	
	func _ready() -> void:
		super._ready()
		objective_type = Type.COLLECT_DATA
		objective_name = "Collect Data"
	
	func add_data_location(pos: Vector2, data_id: int) -> void:
		data_locations.append(pos)
		data_locations.append(data_id)
	
	func try_collect(player_drone: Drone) -> bool:
		if is_complete or is_failed:
			return false
		
		for i in range(0, data_locations.size(), 2):
			var pos = data_locations[i]
			var data_id = data_locations[i + 1]
			
			if collected_data.has(data_id):
				continue
			
			if player_drone.position.distance_to(pos) < 30:
				collected_data.append(data_id)
				current_progress += 1
				progress_updated.emit(self, get_progress())
				
				if current_progress >= required_progress:
					_complete()
				return true
		return false
