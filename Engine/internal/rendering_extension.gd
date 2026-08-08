class_name RenderingExtension

static var k_class_particles:PackedStringArray=["CPUParticles2D","GPUParticles2D","CPUParticles3D","GPUParticles3D"]
static var k_includes:PackedStringArray=["#include \"","\"",
	"#[vertex]","#[fragment]","#[tesselation]","#[evaluation]","#[compute]"
]
static var s_tags:PackedStringArray=[LangExtension.k_empty_string]
static var s_defines:Dictionary[String,Variant]={
	"#VERSION":gl_version,
	"#PLATFORM":gl_platform,
	"#QUALITY":gl_quality
}
static var s_properties:Dictionary[StringName,Dictionary]:
	get():
		if s_properties.is_empty():
			var d:Dictionary[StringName,Array]=Dictionary({
				 &"colors":Array([
					 &"albedo_color"
				],TYPE_STRING_NAME,LangExtension.k_empty_name,null)
				,&"textures":Array([
					 &"albedo_texture"
				],TYPE_STRING_NAME,LangExtension.k_empty_name,null)
			},TYPE_STRING_NAME,LangExtension.k_empty_name,null
			,TYPE_ARRAY,LangExtension.k_empty_name,null)
			s_properties[&"BaseMaterial3D"]=d
			s_properties[&"ORMMaterial3D"]=d
			s_properties[&"StandardMaterial3D"]=d
			d=Dictionary({
				 &"colors":Array([
					 &"shader_parameter/color"
				],TYPE_STRING_NAME,LangExtension.k_empty_name,null)
				,&"textures":Array([
					 &"shader_parameter/texture"
				],TYPE_STRING_NAME,LangExtension.k_empty_name,null)
			},TYPE_STRING_NAME,LangExtension.k_empty_name,null
			,TYPE_ARRAY,LangExtension.k_empty_name,null)
			s_properties[&"ShaderMaterial"]=d
		return s_properties
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

static func get_material(o:Object,b:bool=false,i:int=0)->Material:
	if o==null:
		pass
	elif o is MeshInstance3D:
		var m:Material=null
		# Whole material.
		match i:
			-2:
				m=o.material_override
				if b and m!=null:m=m.duplicate();o.material_override=m
				return m
			-3:
				m=o.material_overlay
				if b and m!=null:m=m.duplicate();o.material_overlay=m
				return m
		# Override firstly.
		m=o.get_surface_override_material(i)
		# Surface secondly.
		if m==null:var a:Mesh=o.mesh;if a!=null:m=a.surface_get_material(i)
		#
		if b and m!=null:m=m.duplicate();o.set_surface_override_material(i,m)
		return m
	return null

static func set_material(o:Object,m:Material,i:int=0)->Material:
	if o==null:
		pass
	elif o is MeshInstance3D:
		# Whole material.
		match i:
			-2:o.material_override=m;return
			-3:o.material_overlay=m;return
		# Override first.
		o.set_surface_override_material(i,m)
	return null

static func get_materials(a:Array[Material],o:Object,b:bool=false)->void:
	if o==null:
		pass
	elif o is MeshInstance3D:
		var r:Mesh=o.mesh;var m:Material
		for i in o.get_surface_override_material_count():
			# Override firstly.
			m=o.get_surface_override_material(i)
			# Surface secondly.
			if m==null:m=r.surface_get_material(i)
			#
			if b and m!=null:m=m.duplicate();o.set_surface_override_material(i,m)
			a.append(m)

static func cap_materials(a:Array[Material],n:Node,b:bool=false,i:int=0,h:Array[Material]=[])->void:
	if n==null:return
	var m:Material=get_material(n,false,i)
	if m!=null:
		var j=h.find(m);if j>=0:# Reuse
			if b:set_material(n,a[j],i)
		else:# Register
			h.append(m)
			if b:m=m.duplicate();set_material(n,m,i)
			a.append(m)
	for it in n.get_children():cap_materials(a,it,b,i,h)

static func material_get_color(m:Material,i:int)->Color:
	if m!=null:
		var d:Dictionary=s_properties.get(m.get_class(),LangExtension.k_empty_dictionary)
		if not d.is_empty():
			return m.get(d.colors[i])
	return Color.BLACK

static func material_set_color(m:Material,i:int,c:Color)->void:
	if m!=null:
		var d:Dictionary=s_properties.get(m.get_class(),LangExtension.k_empty_dictionary)
		if not d.is_empty():
			m.set(d.colors[i],c)

static func material_get_texture(m:Material,i:int)->Texture:
	if m!=null:
		var d:Dictionary=s_properties.get(m.get_class(),LangExtension.k_empty_dictionary)
		if not d.is_empty():
			return m.get(d.textures[i])
	return null

static func material_set_texture(m:Material,i:int,t:Texture)->void:
	if m!=null:
		var d:Dictionary=s_properties.get(m.get_class(),LangExtension.k_empty_dictionary)
		if not d.is_empty():
			m.set(d.textures[i],t)

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

static func gl_free(d:RenderingDevice,r:RID)->RID:
	if r.is_valid():d.free_rid(r)
	return LangExtension.k_empty_rid

static func gl_exit()->void:
	var d:RenderingDevice=s_device
	if d!=null:for it in s_rids.values():gl_free(d,it)
	s_uniforms.clear()

static func create_texture(o:Object)->RID:
	var r:RID=LangExtension.k_empty_rid
	if o!=null:
		r=s_rids.get(o,r)
		if not r.is_valid():
			if o.has_method(&"get_gl_format"):
				var f:RDTextureFormat=o.get_gl_format()
				if f!=null:
					r=s_device.texture_create(f,RDTextureView.new())
					s_rids[o]=r
			elif o.is_class("Texture2D"):
				r=o.get_rid()
				if r.is_valid():s_rids[o]=r
				else:r=_create_texture(o,o.get_image())
			elif o.is_class("Image"):
				r=o.get_rid()
				if r.is_valid():s_rids[o]=r
				else:r=_create_texture(o,o)
	return r

static func _create_texture(o:Object,i:Image,b:bool=false)->RID:
	var r:RID=LangExtension.k_empty_rid
	if i!=null:
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

static func attr_vertex(v:Variant)->RDVertexAttribute:
	var f:int;var s:int
	match typeof(v):
		TYPE_PACKED_FLOAT32_ARRAY:
			f=RenderingDevice.DATA_FORMAT_R32_SFLOAT
			s=4
		TYPE_PACKED_VECTOR2_ARRAY:
			f=RenderingDevice.DATA_FORMAT_R32G32_SFLOAT
			s=4*2
		TYPE_PACKED_VECTOR3_ARRAY:
			f=RenderingDevice.DATA_FORMAT_R32G32B32_SFLOAT
			s=4*3
		TYPE_PACKED_VECTOR4_ARRAY,TYPE_PACKED_COLOR_ARRAY:
			f=RenderingDevice.DATA_FORMAT_R32G32B32A32_SFLOAT
			s=4*4
		_:return null
	var a:RDVertexAttribute=RDVertexAttribute.new()
	a.location=0
	a.offset=0
	a.format=f
	a.stride=s
	return a

static func create_vertex(a:Array,i:int=0)->Array:
	var n:int=a.size()
	if n>0:
		var d:RenderingDevice=s_device
		var vf:Array[RDVertexAttribute]
		var vb:Array[RID]
		var o:int=0
		var it:Variant
		var va:RDVertexAttribute
		var tmp:PackedByteArray
		vf.resize(n);vb.resize(n);for j in n:
			it=a[j]
			va=attr_vertex(it)
			if va!=null:
				va.location=i+j
				va.offset=o
				#
				o+=va.stride*n
				vf[j]=va
				tmp=it.to_byte_array()
				vb[j]=d.vertex_buffer_create(tmp.size(),tmp)
		o=d.vertex_format_create(vf)
		return [o,vb,d.vertex_array_create(a[0].size(),o,vb)]
	return LangExtension.k_empty_array

static func create_index(a:Variant,i:int=0,n:int=-1)->Array:
	if n<0:n=a.size()
	n-=i;if n>0:
		var d:RenderingDevice=s_device
		var f:int=-1
		var b:PackedByteArray=LangExtension.k_empty_bytes
		match typeof(a):
			TYPE_PACKED_BYTE_ARRAY:
				b=a;n/=2;f=RenderingDevice.INDEX_BUFFER_FORMAT_UINT16
			TYPE_PACKED_INT32_ARRAY:
				b=a.to_byte_array();f=RenderingDevice.INDEX_BUFFER_FORMAT_UINT32
		if f>=0:
			var r:RID=d.index_buffer_create(b.size(),f,b)
			return [r,d.index_array_create(r,i,n)]
	return LangExtension.k_empty_array

static func create_frame(a:Array[RID])->Array:
	var n:int=a.size()
	if n>0:
		var d:RenderingDevice=s_device
		var af:RDAttachmentFormat
		var tf:RDTextureFormat
		var bf:Array[RDAttachmentFormat]
		for i in n:
			tf=d.texture_get_format(a[i])
			af=RDAttachmentFormat.new()
			af.format=tf.format
			af.usage_flags=tf.usage_bits
			af.samples=RenderingDevice.TEXTURE_SAMPLES_1
			bf.append(af)
		n=d.framebuffer_format_create(bf)
		return [n,d.framebuffer_create(a,n)]
	return LangExtension.k_empty_array

static func type_uniform(o:Object)->int:
	if o==null:
		pass
	elif o.is_class("Texture2D"):
		return RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
	return RenderingDevice.UNIFORM_TYPE_IMAGE

static func create_uniform(v:Variant)->RDUniform:
	var u:RDUniform=s_uniforms.get(v,null)
	if u==null:match typeof(v):
		TYPE_RID:
			u=RDUniform.new()
			#
			u.uniform_type=type_uniform(null)
			u.add_id(v)
			#
			s_uniforms[v]=u
		TYPE_OBJECT:
			u=RDUniform.new()
			#
			var i:int=type_uniform(v);u.uniform_type=i
			if i==RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE:
				u.add_id(s_device.sampler_create(s_sampler))
			u.add_id(create_texture(v))
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
			s=patch_shader(s)
	return s

static func patch_shader(s:String)->String:
	var v:Variant=null
	for it in s_defines:
		v=s_defines[it]
		if typeof(v)==TYPE_CALLABLE:
			s=s.replace(it,v.call())
		else:
			s=s.replace(it,v)
	return s

static func create_shader(l:int,v:String,f:String,t:String,e:String,c:String)->RID:
	var d:RenderingDevice=s_device
	var a:RDShaderSource=RDShaderSource.new()
	a.language=l
	a.source_vertex=v
	a.source_fragment=f
	a.source_tesselation_control=t
	a.source_tesselation_evaluation=e
	a.source_compute=c
	#
	var b:RDShaderSPIRV=d.shader_compile_spirv_from_source(a)
	if not b.compile_error_compute.is_empty():
		push_error(b.compile_error_compute)
		push_error("In:\n"+"\n".join([k_includes[2],v,k_includes[3],f,k_includes[4],t,k_includes[5],e,k_includes[6],c]))
		return LangExtension.k_empty_rid
	return d.shader_create_from_spirv(b)

static func create_compute_shader(s:String,t:String=LangExtension.k_empty_string)->RID:
	var l:int=RenderingDevice.SHADER_LANGUAGE_GLSL
	if s.ends_with(".glsl"):s=load_shader(s)
	elif s.ends_with(".hlsl"):s=load_shader(s);l=RenderingDevice.SHADER_LANGUAGE_HLSL
	elif t.is_empty():return LangExtension.k_empty_rid
	else:s=t.replace("#COMPUTE_CODE",s)
	var e:String=LangExtension.k_empty_string
	return create_shader(l,e,e,e,e,s)

static func create_render_shader(s:String)->RID:
	var l:int=RenderingDevice.SHADER_LANGUAGE_GLSL
	if s.ends_with(".hlsl"):l=RenderingDevice.SHADER_LANGUAGE_HLSL
	var v:PackedStringArray;var f:PackedStringArray
	var h:PackedStringArray;var t:PackedStringArray=h
	var a:FileAccess=FileAccess.open(s,FileAccess.READ)
	while(not a.eof_reached()):
		s=a.get_line()
		if s==k_includes[2]:v.append_array(h);t=v
		elif s==k_includes[3]:v.append_array(h);t=f
		else:t.append(s)
	a.close()
	s=LangExtension.k_empty_string
	return create_shader(l,patch_shader("\n".join(v)),patch_shader("\n".join(f)),s,s,s)

static func pack_shader(v:Variant,c:PackedFloat32Array,u:Array[RDUniform])->void:
	match typeof(v):
		TYPE_BOOL,TYPE_INT,TYPE_FLOAT:c.append(v)
		TYPE_VECTOR2,TYPE_VECTOR2I:c.append(v.x);c.append(v.y)
		TYPE_VECTOR3,TYPE_VECTOR3I:c.append(v.x);c.append(v.y);c.append(v.z)
		TYPE_VECTOR4,TYPE_VECTOR4I:c.append(v.x);c.append(v.y);c.append(v.z);c.append(v.w)
		TYPE_COLOR:c.append(v.r);c.append(v.g);c.append(v.b);c.append(v.a)
		TYPE_RID,TYPE_OBJECT:var rd:RDUniform=create_uniform(v);rd.binding=u.size();u.append(rd)
		TYPE_CALLABLE:pack_shader(v.call(),c,u)
		TYPE_ARRAY:for it in v:pack_shader(it,c,u)
		TYPE_DICTIONARY:pack_shader(v.values(),c,u)
