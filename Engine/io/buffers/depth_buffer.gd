## A helper buffer for [RDPipelineDepthStencilState].
# Taken from https://github.com/FuWan722/godot_compositor_write_depth/blob/main/rdstencilpipeline/DepthWritingQuadEffect.gd.
class_name DepthBuffer extends CompositorBuffer

@export_group("Depth")
@export var buffers:Array[CompositorBuffer]

func create_uniform(b:RenderSceneBuffersRD,i:int)->RDUniform:
	if buffers.is_empty():
		var u:RDUniform=RDUniform.new()
		var s:RDSamplerState=RenderingExtension.s_sampler
		u.add_id(RenderingExtension.s_device.sampler_create(s))
		u.add_id(b.get_depth_layer(i))
		return u
	else:
		if i<buffers.size():
			var c:CompositorBuffer=buffers[i]
			if c!=null:return c.create_uniform(b,i)
		return null

func _create_vertex()->void:
	return

func _check_buffers(b:RenderSceneBuffersRD,s:Vector2i)->int:
	if layer<b.get_view_count():
		texture=b.get_depth_layer(layer)
	return 0

func _draw_list()->int:
	return 0
