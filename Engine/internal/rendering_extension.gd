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

  # Transform APIs

static func pose_orbit(n:Node,v:Vector3,w:Vector4)->void:
	if n==null:return
	#
	if not w.is_zero_approx():
		var e:Vector3=Vector3(w.x*MathExtension.k_deg_to_rad,w.y*MathExtension.k_deg_to_rad,0.0)
		var q:Basis=Basis.from_euler(e)*MathExtension.looking_at(v)
		e=GodotExtension.get_global_position(n)+v*w.z
		v=e+q*Vector3(0.0,0.0,w.w)
		GodotExtension.set_global_position(n,v)
		GodotExtension.set_global_rotation(n,NAN,e-v)

# Particle APIs

static func stop_particles(n:Node)->void:
	if n!=null and k_class_particles.has(n.get_class()):
		n.restart();n.emitting=false
