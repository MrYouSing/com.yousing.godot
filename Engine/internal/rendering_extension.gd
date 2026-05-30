class_name RenderingExtension

static var k_class_particles:PackedStringArray=["CPUParticles2D","GPUParticles2D","CPUParticles3D","GPUParticles3D"]

# Camera APIs

static func set_camera(n:Node,b:bool)->void:
	if n!=null:
		if n.has_method(&"is_current"):
			if b!=n.is_current():
				if b:n.make_current()
				elif n.has_method(&"clear_current"):n.clear_current()
		else:
			GodotExtension.set_enabled(n,b)

static func world_to_screen(n:Node,v:Vector3)->Vector2:
	var u:Vector2=MathExtension.k_vec2_nan
	if n==null:
		pass
	elif n is Camera3D:
		if n.is_position_in_frustum(v):
			u=n.unproject_position(v)
	return u

static func world_to_viewport(n:Node,v:Vector3)->Vector2:
	var u:Vector2=MathExtension.k_vec2_nan
	if n==null:
		pass
	elif n is Camera3D:
		if n.is_position_in_frustum(v):
			u=n.unproject_position(v)
			u/=Application.get_resolution()
	return u

# Particle APIs

static func stop_particles(n:Node)->void:
	if n!=null and k_class_particles.has(n.get_class()):
		n.restart();n.emitting=false
