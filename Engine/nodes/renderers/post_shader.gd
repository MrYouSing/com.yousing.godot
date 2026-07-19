## A shader wrapper for [CompositorEffect].
class_name PostShader extends CompositorEffect

static var s_template:String=LangExtension.k_empty_string

@export_group("Post Effect")
@export_range(0.0,1.0,0.001) var weight:float=1.0:
	set(x):
		var a:bool=is_zero_approx(weight)
		var b:bool=is_zero_approx(x)
		if a!=b:
			enabled=not b
			_time=Application.get_time()
			_on_dirty()
		weight=x
@export var buffers:Array[Resource]
@export var keys:Array[StringName]
@export var values:Array
@export_multiline var code:String:
	set(x):
		mutex.lock()
		code=x;dirty=true
		mutex.unlock()

var mutex:Mutex=Mutex.new()
var dirty:bool=true
var _call:int=Juggler.k_invalid_id
var _time:float
var materials:Array[Material]

var device:RenderingDevice
var shader:RID=LangExtension.k_empty_rid
var pipeline:RID=LangExtension.k_empty_rid
var caches:Dictionary[RID,RID]

func add_material(m:Material)->void:
	if m==null:return
	apply_material(m)
	if materials.find(m)>=0:return
	materials.append(m)

func remove_material(m:Material)->void:
	if m==null:return
	materials.erase(m)

func apply_material(m:Material)->void:
	if m==null:return
	m.set(get_meta(&"META_SHADER_WEIGHT",&"shader_parameter/weight"),weight)
	var n:int=mini(keys.size(),values.size())
	for i in n:m.set(keys[i],values[i])

func refresh()->void:
	for it in materials:apply_material(it)
	_call=Juggler.k_invalid_id

func _on_dirty()->void:
	if _call>Juggler.k_invalid_id:return
	_call=Juggler.instance.delay_call(refresh,LangExtension.k_empty_array,0.0)

func _get(k:StringName)->Variant:
	var i:int=keys.find(k)
	if i>=0:return values[i]
	else:return null

func _set(k:StringName,v:Variant)->bool:
	var i:int=keys.find(k)
	if i>=0:values[i]=v;_on_dirty();return true
	else:return false

func _init()->void:
	device=RenderingExtension.s_device

func _notification(w:int)->void:
	if w==NOTIFICATION_PREDELETE:
		Juggler.try_kill(self)
		if device!=null and shader.is_valid():
			device.free_rid(shader)
		#
		shader=LangExtension.k_empty_rid
		pipeline=LangExtension.k_empty_rid
		caches.clear()

func _check_shader()->bool:
	if device==null:return false
	var txt:String=LangExtension.k_empty_string
	mutex.lock()
	if dirty:txt=code;dirty=false
	mutex.unlock()
	if not txt.is_empty():
		GodotExtension.dispose(self)
		#
		if s_template.is_empty():s_template=RenderingExtension.load_shader("res://addons/yousing/Engine/shaders/post_processing/template.glsl")
		shader=RenderingExtension.create_compute_shader(txt,s_template)
		if not shader.is_valid():return false
		pipeline=device.compute_pipeline_create(shader)
	return pipeline.is_valid()

func _pack_shader(c:PackedFloat32Array,u:Array[RDUniform])->void:
	u.resize(buffers.size()+1)
	#
	if values.is_empty():return
	RenderingExtension.pack_shader(values,c,u)
	var i:int=c.size()%4;if i>0:
		i=4-i;while i>0:i-=1;c.append(0.0)

func _pack_buffer(a:Array[RDUniform],b:RenderSceneBuffersRD,i:int,c:RID)->void:
	a[0]=RenderingExtension.create_uniform(c)
	var j:int=0;for it in buffers:
		j+=1;if it==null:continue
		a[j]=it.create_uniform(b,i)

func _render_callback(i:int,r:RenderData)->void:
	var d:RenderingDevice=device
	if d!=null and i==effect_callback_type and _check_shader():
		var buffers:RenderSceneBuffersRD=r.get_render_scene_buffers()
		if buffers!=null:
			var size:Vector2i=buffers.get_internal_size()
			if size.x==0 and size.y==0:return
			#
			var g:Vector3i=Vector3i((size.x-1)/8+1,(size.y-1)/8+1,1)
			var c:PackedFloat32Array=[size.x,size.y,Application.get_time()-_time,weight]
			var u:Array[RDUniform]
			_pack_shader(c,u)
			var n:int=buffers.get_view_count();for j in n:
				#
				var k:RID=buffers.get_color_layer(j)
				var v:RID=caches.get(k,LangExtension.k_empty_rid)
				if not v.is_valid():
					var a:Array[RDUniform]=Array(u)
					_pack_buffer(a,buffers,j,k)
					v=UniformSetCacheRD.get_cache(shader,0,a)
					if caches.size()>=32:caches.clear();print("PostShader clears caches.")
					caches[k]=v
				#
				var l:int=device.compute_list_begin()
				d.compute_list_bind_compute_pipeline(l,pipeline)
				d.compute_list_bind_uniform_set(l,v,0)
				d.compute_list_set_push_constant(l,c.to_byte_array(),c.size()*4)
				d.compute_list_dispatch(l,g.x,g.y,g.z)
				d.compute_list_end()
