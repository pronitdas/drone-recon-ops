extends Node2D

## Particle Effects Manager
## Creates visual juice for maximum fun!

var particle_systems: Array[GPUParticles2D] = []

func _ready() -> void:
	pass

func create_thruster_effect(pos: Vector2, direction: Vector2) -> GPUParticles2D:
	var particles = GPUParticles2D.new()
	particles.position = pos
	particles.amount = 30
	particles.lifetime = 0.3
	particles.explosiveness = 0.8
	
	# Set process material
	var material = ParticleProcessMaterial.new()
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 5
	material.direction = -direction
	material.spread = 15
	material.initial_velocity_min = 100
	material.initial_velocity_max = 200
	material.gravity = Vector2.ZERO
	material.scale_min = 2
	material.scale_max = 6
	
	var gradient = Gradient.new()
	gradient.set_color(0, Color(0.0, 1.0, 0.5, 1.0))
	gradient.set_color(1, Color(0.0, 0.5, 1.0, 0.0))
	material.color_ramp = gradient
	
	particles.process_material = material
	
	# Set draw pass
	var pass_mesh = QuadMesh.new()
	pass_mesh.size = Vector2(8, 8)
	var mesh_material = StandardMaterial3D.new()
	mesh_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh_material.vertex_color_use_as_albedo = true
	pass_mesh.material = mesh_material
	particles.draw_pass_1 = pass_mesh
	
	add_child(particles)
	particle_systems.append(particles)
	
	particles.emitting = true
	particles.finished.connect(particles.queue_free)
	
	return particles

func create_scan_effect(pos: Vector2, radius: float = 200) -> void:
	var ring = RingScanEffect.new()
	ring.position = pos
	ring.max_radius = radius
	add_child(ring)

func create_explosion_effect(pos: Vector2, color: Color = Color(1.0, 0.5, 0.0)) -> void:
	var explosion = ExplosionEffect.new()
	explosion.position = pos
	explosion.modulate = color
	add_child(explosion)

func create_spark_effect(pos: Vector2) -> void:
	var sparks = GPUParticles2D.new()
	sparks.position = pos
	sparks.amount = 20
	sparks.lifetime = 0.2
	sparks.explosiveness = 1.0
	
	var material = ParticleProcessMaterial.new()
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINT
	material.direction = Vector2(randf() - 0.5, randf() - 0.5).normalized()
	material.spread = 180
	material.initial_velocity_min = 100
	material.initial_velocity_max = 300
	material.gravity = Vector2(0)
	
	var gradient, 200 = Gradient.new()
	gradient.set_color(0, Color(1.0, 1.0, 0.5, 1.0))
	gradient.set_color(1, Color(1.0, 0.3, 0.0, 0.0))
	material.color_ramp = gradient
	
	sparks.process_material = material
	
	var pass_mesh = QuadMesh.new()
	pass_mesh.size = Vector2(4, 4)
	var mesh_material = StandardMaterial3D.new()
	mesh_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh_material.vertex_color_use_as_albedo = true
	pass_mesh.material = mesh_material
	sparks.draw_pass_1 = pass_mesh
	
	add_child(sparks)
	sparks.emitting = true
	sparks.finished.connect(sparks.queue_free)

func create_detection_pulse(pos: Vector2) -> void:
	var pulse = DetectionPulse.new()
	pulse.position = pos
	add_child(pulse)

func create_hack_effect(pos: Vector2) -> void:
	var hack = HackEffect.new()
	hack.position = pos
	add_child(hack)


class RingScanEffect extends Node2D:
	var max_radius: float = 200
	var lifetime: float = 0.6
	var elapsed: float = 0.0
	
	func _ready() -> void:
		var tween = create_tween()
		tween.tween_callback(queue_free).tween_interval(lifetime)
	
	func _process(delta: float) -> void:
		elapsed += delta
		queue_redraw()
	
	func _draw() -> void:
		var progress = elapsed / lifetime
		var radius = max_radius * progress
		var alpha = 1.0 - progress
		draw_arc(Vector2.ZERO, radius, 0, TAU, 64, Color(0.0, 1.0, 0.5, alpha), 3.0)


class ExplosionEffect extends Node2D:
	var lifetime: float = 0.4
	var elapsed: float = 0.0
	var particles: Array[Vector2] = []
	
	func _ready() -> void:
		for i in range(30):
			particles.append(Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized())
		
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(self, "scale", Vector2(2, 2), lifetime)
		tween.tween_property(self, "modulate:a", 0.0, lifetime)
		tween.tween_callback(queue_free)
	
	func _process(delta: float) -> void:
		elapsed += delta
		queue_redraw()
	
	func _draw() -> void:
		for dir in particles:
			var t = elapsed / lifetime
			var end = dir * 80 * scale.x * (1.0 - t * 0.5)
			var width = 6 * (1.0 - t)
			draw_line(Vector2.ZERO, end, Color(1.0, 0.5, 0.0, modulate.a), width)


class DetectionPulse extends Node2D:
	var lifetime: float = 0.8
	var elapsed: float = 0.0
	
	func _ready() -> void:
		var tween = create_tween()
		tween.tween_callback(queue_free).tween_interval(lifetime)
	
	func _process(delta: float) -> void:
		elapsed += delta
		queue_redraw()
	
	func _draw() -> void:
		var progress = elapsed / lifetime
		var alpha = 1.0 - progress
		
		# Draw warning triangle
		var size = 30 * (1 + progress)
		var points = PackedVector2Array([
			Vector2(0, -size),
			Vector2(size * 0.866, size * 0.5),
			Vector2(-size * 0.866, size * 0.5)
		])
		
		draw_colored_polygon(points, Color(1.0, 0.0, 0.0, alpha * 0.5))
		draw_polyline(points + PackedVector2Array([points[0]]), Color(1.0, 0.2, 0.2, alpha), 3.0)


class HackEffect extends Node2D:
	var lifetime: float = 1.0
	var elapsed: float = 0.0
	
	func _ready() -> void:
		var tween = create_tween()
		tween.tween_callback(queue_free).tween_interval(lifetime)
	
	func _process(delta: float) -> void:
		elapsed += delta
		queue_redraw()
	
	func _draw() -> void:
		var progress = elapsed / lifetime
		
		# Draw binary rain effect
		for i in range(10):
			var y = (elapsed * 50 + i * 20) % 100 - 50
			var x = cos(i + elapsed * 5) * 30
			var alpha = (1.0 - abs(y) / 50) * (1.0 - progress)
			
			var char = "1" if randf() > 0.5 else "0"
			draw_string(ThemeDB.fallback_font, Vector2(x - 10, y), char, HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color(0.0, 1.0, 0.5, alpha))
