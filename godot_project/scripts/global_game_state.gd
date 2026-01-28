extends Node
class_name GlobalGameState

## Global Game State Singleton
## Persists across scenes and manages global game data

signal game_settings_changed(settings: Dictionary)
signal achievement_unlocked(achievement_id: String)

var current_level: int = 1
var total_score: int = 0
var highest_level_unlocked: int = 1
var total_play_time: float = 0.0
var achievements: Dictionary = {}
var settings: Dictionary = {
	"master_volume": 1.0,
	"music_volume": 0.8,
	"sfx_volume": 1.0,
	"voice_volume": 1.0,
	"fullscreen": false,
	"vsync": true,
	"show_fps": true,
	"camera_shake": true,
	"damage_flash": true
}

var game_session: Dictionary = {
	"start_time": 0.0,
	"missions_completed": 0,
	"times_detected": 0,
	"total_distance_flown": 0.0,
	"battery_collected": 0
}

func _ready() -> void:
	_load_game_data()

func _process(delta: float) -> void:
	total_play_time += delta

func start_session() -> void:
	game_session["start_time"] = Time.get_ticks_msec()
	game_session["missions_completed"] = 0
	game_session["times_detected"] = 0
	game_session["total_distance_flown"] = 0.0
	game_session["battery_collected"] = 0

func end_session() -> void:
	_save_game_data()

func add_score(points: int) -> void:
	total_score += points
	_check_achievements()

func complete_level(level_num: int) -> void:
	game_session["missions_completed"] += 1
	
	if level_num >= highest_level_unlocked and level_num < 3:
		highest_level_unlocked = level_num + 1
	
	_check_achievements()
	_save_game_data()

func record_detection() -> void:
	game_session["times_detected"] += 1

func record_distance(distance: float) -> void:
	game_session["total_distance_flown"] += distance

func unlock_achievement(achievement_id: String) -> void:
	if not achievements.has(achievement_id):
		achievements[achievement_id] = {
			"unlocked": true,
			"unlocked_at": Time.get_datetime_string_from_system(),
			"name": _get_achievement_name(achievement_id),
			"description": _get_achievement_description(achievement_id)
		}
		achievement_unlocked.emit(achievement_id)
		_save_game_data()

func has_achievement(achievement_id: String) -> bool:
	return achievements.has(achievement_id)

func _check_achievements() -> void:
	# Check various achievement conditions
	if total_score >= 10000:
		unlock_achievement("score_10k")
	if total_score >= 50000:
		unlock_achievement("score_50k")
	if game_session["missions_completed"] >= 1:
		unlock_achievement("first_mission")
	if game_session["missions_completed"] >= 10:
		unlock_achievement("veteran")
	if game_session["times_detected"] == 0 and game_session["missions_completed"] >= 3:
		unlock_achievement("ghost")
	if total_play_time >= 3600:
		unlock_achievement("dedicated")
	if highest_level_unlocked >= 3:
		unlock_achievement("completed_game")

func _get_achievement_name(id: String) -> String:
	match id:
		"score_10k":
			return "Amateur Pilot"
		"score_50k":
			return "Elite Operator"
		"first_mission":
			return "First Steps"
		"veteran":
			return "Veteran"
		"ghost":
			return "Ghost"
		"dedicated":
			return "Dedicated"
		"completed_game":
			return "Mission Accomplished"
	return id

func _get_achievement_description(id: String) -> String:
	match id:
		"score_10k":
			return "Earn 10,000 total points"
		"score_50k":
			return "Earn 50,000 total points"
		"first_mission":
			return "Complete your first mission"
		"veteran":
			return "Complete 10 missions"
		"ghost":
			return "Complete 3 missions without being detected"
		"dedicated":
			return "Play for 1 hour total"
		"completed_game":
			return "Complete all levels"
	return id

func update_settings(new_settings: Dictionary) -> void:
	settings.merge(new_settings, true)
	game_settings_changed.emit(settings)
	_save_game_data()

func _save_game_data() -> void:
	# Would save to file in real implementation
	pass

func _load_game_data() -> void:
	# Would load from file in real implementation
	pass

func reset_progress() -> void:
	total_score = 0
	highest_level_unlocked = 1
	achievements.clear()
	_save_game_data()
