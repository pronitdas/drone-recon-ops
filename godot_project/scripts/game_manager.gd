extends Node2D
class_name GameManager

## Main Game Manager
## Orchestrates all game systems and state

signal game_state_changed(new_state: String)
signal score_updated(score: int)
signal level_loaded(level_name: String)

enum State { MENU, PLAYING, PAUSED, GAME_OVER, VICTORY }

var current_state: State = State.MENU
var current_level: int = 1
var score: int = 0
var mission_time: float = 0.0

@onready var drone: Drone = $Drone
@onready var stealth_system: StealthSystem = $StealthSystem
@onready var enemies: Node2D = $Enemies
@onready var objectives: Node2D = $Objectives
@onready var ui: UIController = $UIController
@onready var level_environment: Node2D = $LevelEnvironment

func _ready() -> void:
	current_state = State.MENU
	game_state_changed.emit("menu")

func start_mission(level_num: int = 1) -> void:
	current_level = level_num
	current_state = State.PLAYING
	mission_time = 0.0
	
	_setup_game_systems()
	_load_level(level_num)
	
	game_state_changed.emit("playing")

func _setup_game_systems() -> void:
	# Connect drone
	if drone:
		drone.reset_drone(Vector2(100, 360))
		stealth_system.register_player(drone)
	
	# Register enemies
	for enemy in enemies.get_children():
		if enemy is Enemy:
			stealth_system.register_enemy(enemy)

func _load_level(level_num: int) -> void:
	match level_num:
		1:
			_load_level_1()
		2:
			_load_level_2()
		3:
			_load_level_3()
		_:
			_load_level_1()
	
	level_loaded.emit("Level " + str(level_num))

func _load_level_1() -> void:
	# Setup level 1 - Surveillance mission
	mission_time = 120.0
	
	# Create objectives
	var surveillance = MissionObjective.SurveillanceObjective.new()
	surveillance.position = Vector2(600, 200)
	surveillance.required_progress = 3
	
	objectives.add_child(surveillance)

func _load_level_2() -> void:
	# Setup level 2 - Data extraction
	mission_time = 90.0
	
	var data_extraction = MissionObjective.DataExtractionObjective.new()
	data_extraction.position = Vector2(500, 300)
	data_extraction.required_progress = 2
	data_extraction.hack_time = 3.0
	
	objectives.add_child(data_extraction)

func _load_level_3() -> void:
	# Setup level 3 - Target marking with more enemies
	mission_time = 60.0
	
	var marking = MissionObjective.TargetMarkingObjective.new()
	marking.position = Vector2(400, 360)
	marking.required_progress = 4
	
	objectives.add_child(marking)

func _physics_process(delta: float) -> void:
	if current_state != State.PLAYING:
		return
	
	mission_time += delta
	
	# Check win/lose conditions
	_check_mission_status()

func _check_mission_status() -> void:
	# Check if drone is crashed
	if drone and drone.is_crashed:
		_end_game(false, "Drone destroyed!")
		return
	
	# Check if mission time expired
	if mission_time <= 0:
		_end_game(false, "Time limit exceeded!")
		return
	
	# Check if all objectives complete
	var all_complete = true
	for obj in objectives.get_children():
		if obj is MissionObjective and not obj.check_completion():
			all_complete = false
			break
	
	if all_complete:
		_calculate_score()
		_end_game(true, "Mission Complete!")

func _calculate_score() -> void:
	# Base score for completing mission
	score += 1000 * current_level
	
	# Bonus for remaining battery
	if drone:
		score += int(drone.battery * 10)
	
	# Bonus for time remaining
	score += int(mission_time * 5)
	
	# Detection bonus (less detection = more score)
	var detection = stealth_system.get_detection_level()
	score += int((1.0 - detection) * 500)
	
	score_updated.emit(score)

func _end_game(success: bool, message: String) -> void:
	if success:
		current_state = State.VICTORY
		game_state_changed.emit("victory")
	else:
		current_state = State.GAME_OVER
		game_state_changed.emit("game_over")

func restart_level() -> void:
	get_tree().reload_current_scene()

func next_level() -> void:
	if current_level < 3:
		current_level += 1
		start_mission(current_level)
	else:
		# All levels complete
		current_state = State.VICTORY
		game_state_changed.emit("victory")

func _on_ui_mission_completed() -> void:
	_calculate_score()
	_end_game(true, "Mission Complete!")

func _on_ui_mission_failed(reason: String) -> void:
	_end_game(false, reason)
