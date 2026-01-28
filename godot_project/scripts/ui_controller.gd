extends CanvasLayer
class_name UIController

## Main Game UI Controller
## Manages all HUD elements and game UI

signal game_paused()
signal game_resumed()
signal mission_completed()
signal mission_failed(reason: String)

@export var show_minimap: bool = true
@export var show_battery_warning: bool = true

@onready var battery_bar: ProgressBar = $HUD/BatteryPanel/BatteryBar
@onready var detection_bar: ProgressBar = $HUD/DetectionPanel/DetectionBar
@onready var mission_panel: Panel = $HUD/MissionPanel
@onready var mission_label: Label = $HUD/MissionPanel/MissionLabel
@onready var mission_progress: ProgressBar = $HUD/MissionPanel/ProgressBar
@onready var objective_list: VBoxContainer = $HUD/MissionPanel/ObjectiveList
@onready var alert_panel: Panel = $HUD/AlertPanel
@onready var alert_label: Label = $HUD/AlertPanel/AlertLabel
@onready var minimap: Control = $HUD/Minimap
@onready var pause_menu: Control = $PauseMenu
@onready var game_over_screen: Control = $GameOverScreen
@onready var victory_screen: Control = $VictoryScreen

var player: Drone = null
var stealth_system: StealthSystem = null
var current_mission: MissionObjective = null
var is_paused: bool = false
var is_game_over: bool = false

func _ready() -> void:
	pause_menu.visible = false
	game_over_screen.visible = false
	victory_screen.visible = false
	alert_panel.visible = false
	
	if show_minimap:
		_setup_minimap()

func setup_game(p: Drone, ss: StealthSystem, mission: MissionObjective) -> void:
	player = p
	stealth_system = ss
	current_mission = mission
	
	if player:
		player.battery_changed.connect(_on_battery_changed)
		player.crashed.connect(_on_player_crashed)
	
	if stealth_system:
		stealth_system.stealth_changed.connect(_on_stealth_changed)
		stealth_system.detected.connect(_on_detection_alert)
	
	if current_mission:
		current_mission.objective_completed.connect(_on_objective_completed)
		current_mission.objective_failed.connect(_on_objective_failed)
		_update_mission_display()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		_toggle_pause()
	
	if is_paused or is_game_over:
		return
	
	_update_hud()

func _update_hud() -> void:
	if player:
		battery_bar.value = player.battery
		
		# Battery warning color
		if player.battery < 20:
			battery_bar.modulate = Color(1.0, 0.3, 0.3)
		elif player.battery < 50:
			battery_bar.modulate = Color(1.0, 1.0, 0.3)
		else:
			battery_bar.modulate = Color(0.3, 1.0, 0.3)
	
	if stealth_system:
		var detection = stealth_system.get_detection_level()
		detection_bar.value = detection * 100
		
		if detection > 0.5:
			detection_bar.modulate = Color(1.0, 0.2, 0.2)
			_show_alert("DETECTION IMMINENT!")
		elif detection > 0.3:
			detection_bar.modulate = Color(1.0, 0.8, 0.2)
			_show_alert("CAUTION: DETECTED")
		else:
			detection_bar.modulate = Color(0.2, 1.0, 0.2)
			_hide_alert()

func _update_mission_display() -> void:
	if current_mission:
		mission_label.text = current_mission.objective_name
		mission_progress.value = current_mission.get_progress() * 100

func _setup_minimap() -> void:
	if minimap:
		# Set up minimap rendering
		pass

func _on_battery_changed(value: float) -> void:
	battery_bar.value = value

func _on_stealth_changed(stealth_value: float) -> void:
	detection_bar.value = (1.0 - stealth_value) * 100

func _on_detection_alert(method: String) -> void:
	_show_alert("DETECTED BY " + method.to_upper())

func _show_alert(message: String) -> void:
	alert_panel.visible = true
	alert_label.text = message
	
	var tween = create_tween()
	tween.tween_property(alert_panel, "modulate", Color(1, 1, 1, 1), 0.1)
	tween.tween_interval(0.5)
	tween.tween_property(alert_panel, "modulate", Color(1, 1, 1, 0), 0.3)

func _hide_alert() -> void:
	alert_panel.visible = false

func _on_player_crashed(reason: String) -> void:
	is_game_over = true
	game_over_screen.visible = true
	$GameOverScreen/ReasonLabel.text = "MISSION FAILED: " + reason

func _on_objective_completed(objective: MissionObjective) -> void:
	mission_completed.emit()
	victory_screen.visible = true
	$VictoryScreen/ScoreLabel.text = "MISSION COMPLETE!"

func _on_objective_failed(objective: MissionObjective, reason: String) -> void:
	mission_failed.emit(reason)
	is_game_over = true
	game_over_screen.visible = true
	$GameOverScreen/ReasonLabel.text = "MISSION FAILED: " + reason

func _toggle_pause() -> void:
	is_paused = not is_paused
	
	if is_paused:
		pause_menu.visible = true
		game_paused.emit()
		get_tree().paused = true
	else:
		pause_menu.visible = false
		game_resumed.emit()
		get_tree().paused = false

func _on_resume_pressed() -> void:
	_toggle_pause()

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
