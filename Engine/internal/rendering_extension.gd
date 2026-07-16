class_name RenderingExtension

static var k_class_particles:PackedStringArray=["CPUParticles2D","GPUParticles2D","CPUParticles3D","GPUParticles3D"]
static var k_includes:PackedStringArray=["#include \"","\""]
static var s_tags:PackedStringArray=[LangExtension.k_empty_string]
static var s_defines:Dictionary[String,Variant]={
	"#VERSION":gl_version,
	"#PLATFORM":gl_platform,
	"#QUALITY":gl_quality
}
static var s_device:RenderingDevice:
	get:
		if s_device==null:
			s_device=RenderingServer.get_rendering_device()
		return s_device
	set(x):
		s_device=x
static var s_sampler:RDSamplerState:
	get:
		if s_sampler==null:
			s_sampler=RDSamplerState.new()
			s_sampler.repeat_u=0;s_sampler.repeat_v=0;s_sampler.repeat_w=0
			s_sampler.min_filter=1;s_sampler.mip_filter=1;s_sampler.mag_filter=1
		return s_sampler
	set(x):
		s_sampler=x
static var s_rids:Dictionary[Object,RID]
static var s_uniforms:Dictionary[Variant,RDUniform]

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

# Shader APIs

static func gl_version()->String:
	return "450"

static func gl_platform()->String:
	return Application.get_platform()

static func gl_quality()->String:
	return "Quality_Low"

static func gl_exit()->void:
	var d:RenderingDevice=s_device
	for it in s_rids.values():d.free_rid(it)
	s_uniforms.clear()

static func make_texture(o:Object)->RID:
	var r:RID=LangExtension.k_empty_rid
	if o==null:
		pass
	elif o.is_class("Texture2D"):
		r=s_rids.get(o,r)
		if not r.is_valid():
			r=_make_texture(o,o.get_image())
	elif o.is_class("Image"):
		r=s_rids.get(o,r)
		if not r.is_valid():
			r=_make_texture(o,o)
	return r

static func _make_texture(o:Object,i:Image,b:bool=false)->RID:
	var r:RID=LangExtension.k_empty_rid
	if i!=null:
		r=s_rids.get(i,r)
		if not r.is_valid():
			# Prepare.
			var u:int=RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT
			if b:u|=RenderingDevice.TEXTURE_USAGE_STORAGE_BIT
			if i.get_format()!=Image.FORMAT_RGBA8:
				i.decompress();i.convert(Image.FORMAT_RGBA8)
			# Create.
			var f:RDTextureFormat=RDTextureFormat.new()
			var v:RDTextureView=RDTextureView.new()
			f.format=RenderingDevice.DATA_FORMAT_R8G8B8A8_UNORM
			f.usage_bits=u
			f.width=i.get_width();f.height=i.get_height()
			r=s_device.texture_create(f,v,[i.get_data()])
			s_rids[o]=r
	return r

static func type_uniform(o:Object)->int:
	if o==null:
		pass
	elif o.is_class("Texture2D"):
		return RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
	return RenderingDevice.UNIFORM_TYPE_IMAGE

static func make_uniform(v:Variant)->RDUniform:
	var u:RDUniform=null
	match typeof(v):
		TYPE_RID:
			u=s_uniforms.get(v,null)
			if u==null:
				u=RDUniform.new()
				#
				u.uniform_type=type_uniform(null)
				u.add_id(v)
				#
				s_uniforms[v]=u
		TYPE_OBJECT:
			u=s_uniforms.get(v,null)
			if u==null:
				u=RDUniform.new()
				#
				var i:int=type_uniform(v);u.uniform_type=i
				if i==RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE:
					u.add_id(s_device.sampler_create(s_sampler))
				u.add_id(make_texture(v))
				#
				s_uniforms[v]=u
	return u

static func load_shader(f:String,b:bool=true)->String:
	var s:String=IOExtension.load_text(f)
	var n:int=s.length()
	if n>0:
		var i:int=0;var j:int=-1;var k:int=-1
		while i<n:
			j=s.find(k_includes[0],i);if j<0:break
			k=j+k_includes[0].length()
			i=s.find(k_includes[1],k);if i<0:break
			f=s.substr(k,i-k)
			s=s.replace(s.substr(j,i-j+1),load_shader(f,false))
			i=j;n=s.length()
		if b:
			var v:Variant=null
			for it in s_defines:
				v=s_defines[it]
				if typeof(v)==TYPE_CALLABLE:
					s=s.replace(it,v.call())
				else:
					s=s.replace(it,v)
	return s

static func make_shader(s:String,t:String=LangExtension.k_empty_string)->RID:
	var l:int=RenderingDevice.SHADER_LANGUAGE_GLSL
	if s.ends_with(".glsl"):s=load_shader(s)
	elif s.ends_with(".hlsl"):s=load_shader(s);l=RenderingDevice.SHADER_LANGUAGE_HLSL
	elif t.is_empty():return LangExtension.k_empty_rid
	else:s=t.replace("#COMPUTE_CODE",s)
	#
	var d:RenderingDevice=s_device
	var a:RDShaderSource=RDShaderSource.new()
	a.language=l;a.source_compute=s
	var b:RDShaderSPIRV=d.shader_compile_spirv_from_source(a)
	if not b.compile_error_compute.is_empty():
		push_error(b.compile_error_compute)
		push_error("In:\n"+s)
		return LangExtension.k_empty_rid
	return d.shader_create_from_spirv(b)

static func pack_shader(v:Variant,c:PackedFloat32Array,u:Array[RDUniform])->void:
	match typeof(v):
		TYPE_BOOL,TYPE_INT,TYPE_FLOAT:c.append(v)
		TYPE_VECTOR2,TYPE_VECTOR2I:c.append(v.x);c.append(v.y)
		TYPE_VECTOR3,TYPE_VECTOR3I:c.append(v.x);c.append(v.y);c.append(v.z)
		TYPE_VECTOR4,TYPE_VECTOR4I:c.append(v.x);c.append(v.y);c.append(v.z);c.append(v.w)
		TYPE_COLOR:c.append(v.r);c.append(v.g);c.append(v.b);c.append(v.a)
		TYPE_RID,TYPE_OBJECT:var rd:RDUniform=make_uniform(v);rd.binding=u.size();u.append(rd)
		TYPE_ARRAY:for it in v:pack_shader(it,c,u)
		TYPE_DICTIONARY:pack_shader(v.values(),c,u)
