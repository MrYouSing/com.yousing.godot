## A helper buffer from [Compositor].
class_name CompositorBuffer extends CompositorEffect

@export_group("Buffer")
@export var layer:int
@export var format:RenderingDevice.DataFormat=RenderingDevice.DATA_FORMAT_R8G8B8A8_UNORM
@export var size:Vector2i=Vector2i.ZERO
@export var color:Color=Color(0.0,0.0,0.0,0.0)
@export_multiline() var code:String="res://addons/yousing/Engine/shaders/internal/mask.glsl"

var mutex:Mutex=Mutex.new()
var dirty:bool=true
var formats:PackedInt64Array=[0,0,0,0]
var canvas:Texture2DRD

var device:RenderingDevice
var shader:RID=LangExtension.k_empty_rid
var pipeline:RID=LangExtension.k_empty_rid
var vertices:Array[RID]
var vertex:RID=LangExtension.k_empty_rid
var texture:RID=LangExtension.k_empty_rid
var frame:RID=LangExtension.k_empty_rid

func get_format()->RDTextureFormat:
	var f:RDTextureFormat=RDTextureFormat.new()
	f.format=format;f.width=size.x;f.height=size.y
	f.usage_bits=RenderingDevice.TEXTURE_USAGE_COLOR_ATTACHMENT_BIT|\
		RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT
	return f

func get_gl_format()->RDTextureFormat:return get_format()

func get_blend()->RDPipelineColorBlendState:
	var blend:RDPipelineColorBlendState=RDPipelineColorBlendState.new()
	blend.attachments.append(RDPipelineColorBlendStateAttachment.new())
	return blend

func get_depth(s:RDPipelineDepthStencilState=null)->RDPipelineDepthStencilState:
	if s==null:s=RDPipelineDepthStencilState.new()
	return s

func get_texture()->Texture2D:
	if canvas==null:
		canvas=Texture2DRD.new()
		canvas.texture_rd_rid=texture
	return canvas

func create_uniform(b:RenderSceneBuffersRD,i:int)->RDUniform:
	if layer!=i:return null
	var u:RDUniform=RDUniform.new()
	var s:RDSamplerState=RenderingExtension.s_sampler
	u.add_id(RenderingExtension.s_device.sampler_create(s))
	u.add_id(texture)
	return u

func _init()->void:
	device=RenderingExtension.s_device
	_create_vertex()

func _notification(w:int)->void:
	if w==NOTIFICATION_PREDELETE:
		var d:RenderingDevice=device
		if d!=null:
			RenderingExtension.gl_free(d,shader)
			RenderingExtension.gl_free(d,pipeline)
			for it in vertices:if it.is_valid():RenderingExtension.gl_free(d,it)
			RenderingExtension.gl_free(d,vertex)
			RenderingExtension.gl_free(d,texture)
			RenderingExtension.gl_free(d,frame)
		shader=LangExtension.k_empty_rid
		pipeline=LangExtension.k_empty_rid
		vertices.clear()
		vertex=LangExtension.k_empty_rid
		texture=LangExtension.k_empty_rid
		frame=LangExtension.k_empty_rid

func _create_texture()->void:
	if canvas!=null:# Auto-Free.
		canvas.texture_rd_rid=LangExtension.k_empty_rid
	var d:RenderingDevice=device
	texture=RenderingExtension.gl_free(d,texture)
	frame=LangExtension.k_empty_rid# Auto-Free.
	if size.length_squared()==0:return
	#
	texture=d.texture_create(get_format(),RDTextureView.new())
	RenderingExtension.s_rids[self]=texture
	if canvas!=null:
		canvas.texture_rd_rid=texture

func _create_shader()->void:
	mutex.lock()
	dirty=false
	mutex.unlock()
	var d:RenderingDevice=device
	shader=RenderingExtension.gl_free(d,shader)
	pipeline=LangExtension.k_empty_rid# Auto-Free.
	#
	shader=RenderingExtension.create_render_shader(code)

func _create_vertex()->void:
	var v:PackedVector3Array=[
		Vector3(-1.0,-1.0,0.0),
		Vector3( 1.0,-1.0,0.0),
		Vector3(-1.0, 1.0,0.0),
		Vector3( 1.0,-1.0,0.0),
		Vector3( 1.0, 1.0,0.0),
		Vector3(-1.0, 1.0,0.0)
	]
	var a:Array=RenderingExtension.create_vertex([v],0)
	if a.is_empty():return
	formats[0]=a[0];vertices=a[1];vertex=a[2]

func _create_frame(a:Array[RID])->bool:
	var d:RenderingDevice=device
	frame=RenderingExtension.gl_free(d,frame)
	var b:Array=RenderingExtension.create_frame(a)
	if a.is_empty():return false
	var f:int=formats[1]
	formats[1]=b[0];frame=b[1]
	return formats[1]!=f

func _create_pipeline()->void:
	var d:RenderingDevice=device
	pipeline=RenderingExtension.gl_free(d,pipeline)
	if not shader.is_valid():return
	#
	pipeline=d.render_pipeline_create(
		shader,formats[1],formats[0],RenderingDevice.RENDER_PRIMITIVE_TRIANGLES,
		RDPipelineRasterizationState.new(),RDPipelineMultisampleState.new(),
		get_depth(),get_blend()
	)

func _check_buffers(b:RenderSceneBuffersRD,s:Vector2i)->int:
	var i:int=0
	if dirty or not shader.is_valid():
		_create_shader()
		i|=0x01
	if size!=s:
		size=s
		_create_texture()
		i|=0x02
	return i

func _draw_list()->int:
	return device.draw_list_begin(
		frame,RenderingDevice.DRAW_CLEAR_COLOR_0,
		[color],1.0,0,
		Rect2(),RenderingDevice.OPAQUE_PASS
	)

func _render_callback(i:int,r:RenderData)->void:
	if i!=effect_callback_type:return
	var d:RenderingDevice=device;if d==null:return
	var b:RenderSceneBuffersRD=r.get_render_scene_buffers();if b==null:return
	if layer>=b.get_view_count():return
	var s:Vector2i=b.get_internal_size()
	if s.x==0 and s.y==0:return
	#
	_check_buffers(b,s)
	var l:int=_draw_list();if l==0:return
	d.draw_list_bind_render_pipeline(l,pipeline)
	d.draw_list_bind_vertex_array(l,vertex)
	d.draw_list_draw(l,false,3)
	d.draw_list_end()
