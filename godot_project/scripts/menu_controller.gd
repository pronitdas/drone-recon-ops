extends Control
class_name MenuController

## Main Menu Controller
## Handles menu navigation and game start

signal start_game(level: int)
signal show_controls()
signal quit_game()

@export var current_level: int = 1

@onready var controls_panel: Panel = $ControlsPanel
@onready var level_button: Button = $VBoxContainer/LevelButton

func _ready() -> void:
	controls_panel.visible = false

func _on_start_pressed() -> void:
	start_game.emit(current_level)

func _on_level_pressed() -> void:
	current_level = (current_level % 3) + 1
	level_button.text = "LEVEL " + str(current_level)

func _on_controls_pressed() -> void:
	controls_panel.visible = true

func _on_close_controls_pressed() -> void:
	controls_panel.visible = false

func _on_quit_pressed() -> void:
	quit_game.emit()
	get_tree().quit()
