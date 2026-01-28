extends RigidBody2D
class_name Wall

## Wall Obstacle
## Static body that the drone must avoid

@export var wall_type: String = "concrete"

func _ready() -> void:
	_setup_collision()
	_setup_visuals()

func _setup_collision() -> void:
	contact_monitor = true
	max_contacts_reported = 4

func _setup_visuals() -> void:
	# Visual setup handled by parent level environment
	pass

func take_damage(damage: float) -> void:
	# Walls don't take damage but could have effects
	pass


class_name Obstacle extends Node2D

## Obstacle Base Class
## Generic obstacles in the level

@export var destructible: bool = false
@export var health: float = 50.0

func _ready() -> void:
	pass

func take_damage(damage: float) -> void:
	if not destructible:
		return
	
	health -= damage
	if health <= 0:
		destroy()

func destroy() -> void:
	# Spawn debris effect
	_create_debris()
	queue_free()

func _create_debris() -> void:
	# Would spawn particle effects
	pass


class_name Collectible extends Area2D

## Collectible Items
## Batteries, intel, powerups

@export var item_type: String = "battery"
@export var value: float = 25.0

signal collected(collectible: Collectible)

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body is Drone:
		_collect(body)

func _collect(drone: Drone) -> void:
	match item_type:
		"battery":
			drone.battery = min(drone.battery + value, drone.max_battery)
		"intel":
			# Score bonus
			pass
		"powerup":
			# Temporary boost
			pass
	
	_visual_feedback()
	collected.emit(self)
	queue_free()

func _visual_feedback() -> void:
	# Sparkle or glow effect
	pass
