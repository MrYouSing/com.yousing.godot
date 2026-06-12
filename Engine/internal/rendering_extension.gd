class_name RenderingExtension

static var k_class_particles:PackedStringArray=["CPUParticles2D","GPUParticles2D","CPUParticles3D","GPUParticles3D"]

# Camera APIs

static func set_camera(n:Node,b:bool)->void:
	if n!=null:
		if n.has_method(&"is_current"):
			if b!=n.is_current():
				if b:n.make_current()
				elif n.has_method(&"clear_current"):n.clear_current()
				# Find next camera for AudioListener.
		else:
			GodotExtension.set_enabled(n,b)

static func world_to_screen(n:Node,v:Vector3,i:int=0)->Vector2:
	var u:Vector2=MathExtension.k_vec2_nan
	if n==null:
		pass
	elif n is Camera3D:
		var b:bool=true;match i:
			0:pass
			1:if n.is_position_behind(v):b=false
			2:if n.is_position_in_frustum(v):b=false
		if b:
			u=n.unproject_position(v)
	return u

static func world_to_viewport(n:Node,v:Vector3,i:int=0)->Vector2:
	var u:Vector2=MathExtension.k_vec2_nan
	if n==null:
		pass
	elif n is Camera3D:
		var b:bool=true;match i:
			0:pass
			1:if n.is_position_behind(v):b=false
			2:if n.is_position_in_frustum(v):b=false
		if b:
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

static func pose_exit(n:Node,t:Transform3D,f:float=1.0,c:Callable=LangExtension.k_empty_callable,w:int=0)->Func:
	if n==null or is_zero_approx(f):
		if c.is_valid():c.call()
		return null
	#
	var p:Vector3=GodotExtension.get_global_position(n)
	f=MathExtension.time_fade(0.0,(p-t.origin).length(),f)
	GodotExtension.set_global_transform(n,t)
	return Func.update(n,^"Pose_Exit",_pose_exit,[n,t,f,c],w)

static func _pose_exit(n:Node,t:Transform3D,f:float,c:Callable,o:Func,e:float)->void:
	if n==null:return
	f=e/f
	#
	var d:Transform3D=GodotExtension.get_global_transform(n)
	t=MathExtension.pose_lerp(t,d,Vector2(-f,1.0),1.0)
	GodotExtension.set_global_transform(n,t)
	if f>=1.0:
		o.process(-1)
		if c.is_valid():c.call()

# Renderer APIs

static func get_material(o:Object,i:int=0,b:bool=false)->Material:
	if o==null:
		pass
	elif o is MeshInstance3D:
		# Whole material.
		match i:
			-1:return o.material_override
			-2:return o.material_overlay
		# Override first.
		var m:Material=o.get_surface_override_material(i)
		if m!=null:return m
		# Surface or override.
		var a:Mesh=o.mesh;if a!=null:
			m=a.surface_get_material(i)
			if m!=null and b:
				m=m.duplicate();o.set_surface_override_material(i,m)
			return m
	return null

# Particle APIs

static func stop_particles(n:Node)->void:
	if n!=null and k_class_particles.has(n.get_class()):
		n.restart();n.emitting=false

static func start_particles(n:Node)->void:
	if n!=null and k_class_particles.has(n.get_class()):
		n.restart();n.emitting=true
