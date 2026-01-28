extends Node2D

## Level Environment Manager
## Creates the game world with walls, obstacles, and decorations

@export var tile_size: float = 32.0
@export var level_width: int = 40
@export var level_height: int = 23

var walls: Array[StaticBody2D] = []
var obstacles: Array[Node2D] = []
var decorations: Array[Node2D] = []

func _ready() -> void:
	_build_level()

func _build_level() -> void:
	_create_boundaries()
	_create_walls()
	_create_obstacles()
	_create_decorations()

func _create_boundaries() -> void:
	var screen_size = get_viewport_rect().size
	
	# Floor
	_create_wall_segment(Vector2(screen_size.x / 2, screen_size.y - 16), Vector2(screen_size.x, 32))
	# Ceiling
	_create_wall_segment(Vector2(screen_size.x / 2, 16), Vector2(screen_size.x, 32))
	# Left wall
	_create_wall_segment(Vector2(16, screen_size.y / 2), Vector2(32, screen_size.y))
	# Right wall
	_create_wall_segment(Vector2(screen_size.x - 16, screen_size.y / 2), Vector2(32, screen_size.y))

func _create_walls() -> void:
	# Central structure
	_create_wall_segment(Vector2(400, 200), Vector2(200, 32))
	_create_wall_segment(Vector2(400, 400), Vector2(200, 32))
	
	# Side structures
	_create_wall_segment(Vector2(700, 300), Vector2(32, 200))
	_create_wall_segment(Vector2(900, 150), Vector2(150, 32))
	_create_wall_segment(Vector2(900, 450), Vector2(150, 32))
	
	# Lower area
	_create_wall_segment(Vector2(550, 500), Vector2(100, 32))
	_create_wall_segment(Vector2(750, 550), Vector2(32, 100))

func _create_wall_segment(pos: Vector2, size: Vector2) -> void:
	var wall = StaticBody2D.new()
	wall.position = pos
	
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = size
	collision.shape = shape
	wall.add_child(collision)
	
	var sprite = Sprite2D.new()
	var texture = _create_wall_texture()
	sprite.texture = texture
	sprite.scale = size / texture.get_size()
	wall.add_child(sprite)
	
	add_child(wall)
	walls.append(wall)

func _create_wall_texture() -> Texture2D:
	var image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.15, 0.15, 0.2))
	
	# Add some detail
	for x in range(0, 64, 8):
		for y in range(0, 64, 8):
			if randf() > 0.5:
				var shade = Color(0.2, 0.2, 0.25)
				image.fill_rect(Rect2(x, y, 7, 7), shade)
	
	return ImageTexture.create_from_image(image)

func _create_obstacles() -> void:
	# Crates
	_create_crate(Vector2(300, 300))
	_create_crate(Vector2(320, 300))
	_create_crate(Vector2(310, 280))
	
	_create_crate(Vector2(850, 350))
	_create_crate(Vector2(850, 380))
	
	# Barrels
	_create_barrel(Vector2(500, 150))
	_create_barrel(Vector2(520, 150))
	_create_barrel(Vector2(510, 170))
	
	# Control panels
	_create_control_panel(Vector2(600, 250))
	_create_control_panel(Vector2(800, 500))

func _create_crate(pos: Vector2) -> void:
	var crate = Node2D.new()
	crate.position = pos
	
	var sprite = Sprite2D.new()
	var texture = _create_crate_texture()
	sprite.texture = texture
	sprite.scale = Vector2(0.5, 0.5)
	crate.add_child(sprite)
	
	var area = Area2D.new()
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(32, 32)
	collision.shape = shape
	area.add_child(collision)
	crate.add_child(area)
	
	add_child(crate)
	obstacles.append(crate)

func _create_barrel(pos: Vector2) -> void:
	var barrel = Node2D.new()
	barrel.position = pos
	
	var sprite = Sprite2D.new()
	var texture = _create_barrel_texture()
	sprite.texture = texture
	sprite.scale = Vector2(0.4, 0.4)
	barrel.add_child(sprite)
	
	var area = Area2D.new()
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 16
	collision.shape = shape
	area.add_child(collision)
	barrel.add_child(area)
	
	add_child(barrel)
	obstacles.append(barrel)

func _create_control_panel(pos: Vector2) -> void:
	var panel = Node2D.new()
	panel.position = pos
	
	var sprite = Sprite2D.new()
	var texture = _create_panel_texture()
	sprite.texture = texture
	sprite.scale = Vector2(0.6, 0.6)
	panel.add_child(sprite)
	
	# Add blinking light
	var light = Sprite2D.new()
	light.texture = _create_light_texture()
	light.position = Vector2(0, -15)
	panel.add_child(light)
	
	add_child(panel)
	obstacles.append(panel)

func _create_crate_texture() -> Texture2D:
	var image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.5, 0.35, 0.2))
	
	# Cross pattern
	image.fill_rect(Rect2(0, 30, 64, 4), Color(0.4, 0.25, 0.15))
	image.fill_rect(Rect2(30, 0, 4, 64), Color(0.4, 0.25, 0.15))
	
	return ImageTexture.create_from_image(image)

func _create_barrel_texture() -> Texture2D:
	var image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.3, 0.3, 0.35))
	
	# Ribs
	image.fill_rect(Rect2(0, 10, 64, 4), Color(0.2, 0.2, 0.25))
	image.fill_rect(Rect2(0, 50, 64, 4), Color(0.2, 0.2, 0.25))
	
	return ImageTexture.create_from_image(image)

func _create_panel_texture() -> Texture2D:
	var image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.2, 0.25, 0.3))
	
	# Screen area
	image.fill_rect(Rect2(8, 8, 48, 25), Color(0.1, 0.15, 0.2))
	
	# Buttons
	image.fill_rect(Rect2(10, 40, 12, 12), Color(0.6, 0.3, 0.3))
	image.fill_rect(Rect2(26, 40, 12, 12), Color(0.3, 0.6, 0.3))
	image.fill_rect(Rect2(42, 40, 12, 12), Color(0.3, 0.3, 0.6))
	
	return ImageTexture.create_from_image(image)

func _create_light_texture() -> Texture2D:
	var image = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 1, 0, 0.8))
	return ImageTexture.create_from_image(image)

func _create_decorations() -> void:
	# Warning stripes
	_create_warning_stripe(Vector2(350, 250))
	_create_warning_stripe(Vector2(650, 350))
	
	# Ventilation grates
	_create_vent(Vector2(200, 100))
	_create_vent(Vector2(1000, 500))

func _create_warning_stripe(pos: Vector2) -> void:
	var stripe = Node2D.new()
	stripe.position = pos
	
	var sprite = Sprite2D.new()
	var texture = _create_stripe_texture()
	sprite.texture = texture
	sprite.scale = Vector2(0.8, 0.5)
	stripe.add_child(sprite)
	
	add_child(stripe)
	decorations.append(stripe)

func _create_vent(pos: Vector2) -> void:
	var vent = Node2D.new()
	vent.position = pos
	
	var sprite = Sprite2D.new()
	var texture = _create_vent_texture()
	sprite.texture = texture
	sprite.scale = Vector2(0.7, 0.7)
	vent.add_child(sprite)
	
	add_child(vent)
	decorations.append(vent)

func _create_stripe_texture() -> Texture2D:
	var image = Image.create(64, 32, false, Image.FORMAT_RGBA8)
	
	for x in range(64):
		for y in range(32):
			if (x + y) % 16 < 8:
				image.set_pixel(x, y, Color(1, 0.8, 0, 0.8))
			else:
				image.set_pixel(x, y, Color(0.1, 0.1, 0.1, 0.8))
	
	return ImageTexture.create_from_image(image)

func _create_vent_texture() -> Texture2D:
	var image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.25, 0.25, 0.3))
	
	# Slats
	for y in range(0, 64, 8):
		image.fill_rect(Rect2(8, y + 2, 48, 4), Color(0.15, 0.15, 0.2))
	
	return ImageTexture.create_from_image(image)
