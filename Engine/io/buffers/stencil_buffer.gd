## A helper buffer for [RDPipelineDepthStencilState].
## Taken from https://github.com/dmlary/godot-demo-sencil-buffer-compositor-effect/blob/main/render_pipeline_compositor_effect.gd.
class_name StencilBuffer extends CompositorBuffer

@export_group("Stencil")
@export_flags("Back","Front")var cull_mode:int=1
@export var op_compare:RenderingDevice.CompareOperator=7
@export var op_compare_mask:int
@export var op_depth_fail:RenderingDevice.StencilOperation=1
@export var op_fail:RenderingDevice.StencilOperation=1
@export var op_pass:RenderingDevice.StencilOperation=1
@export var op_reference:int
@export var op_write_mask:int

var depth:RID

func get_depth(s:RDPipelineDepthStencilState=null)->RDPipelineDepthStencilState:
	s=super.get_depth(s)
	s.enable_stencil=true
	if cull_mode&0x01==0:
		s.back_op_compare=op_compare
		s.back_op_compare_mask=op_compare_mask
		s.back_op_depth_fail=op_depth_fail
		s.back_op_fail=op_fail
		s.back_op_pass=op_pass
		s.back_op_reference=op_reference
		s.back_op_write_mask=op_write_mask
	if cull_mode&0x02==0:
		s.front_op_compare=op_compare
		s.front_op_compare_mask=op_compare_mask
		s.front_op_depth_fail=op_depth_fail
		s.front_op_fail=op_fail
		s.front_op_pass=op_pass
		s.front_op_reference=op_reference
		s.front_op_write_mask=op_write_mask
	return s

func _check_buffers(b:RenderSceneBuffersRD,s:Vector2i)->int:
	var i:int=super._check_buffers(b,s)
	var d:RID=b.get_depth_layer(layer)
	if d!=depth:
		depth=d
		i|=0x04
	if i&0x06!=0:
		if _create_frame([texture,depth]):
			i|=0x08
	if i&0x09!=0:
		_create_pipeline()
		i|=0x10
	return i
