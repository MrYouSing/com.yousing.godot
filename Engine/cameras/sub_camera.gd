## A helper class for camera management.
class_name SubCamera extends Node

static var instances:Array[SubCamera]=LangExtension.alloc_array(SubCamera,32)

@export_group("Camera")
@export var index:int
@export var root:Node
@export var camera:Node
@export var viewport:SubViewport
@export_flags_3d_render var mask:int=-1

func set_enabled(b:bool)->void:
	set_process(b and root!=null and camera!=null)
	if camera!=null:
		camera.set(&"visible",b)
		camera.set(&"cull_mask",mask if b else 0)
	if viewport!=null:
		if b:viewport.render_target_update_mode=SubViewport.UPDATE_WHEN_VISIBLE
		else:viewport.render_target_update_mode=SubViewport.UPDATE_DISABLED
	else:
		GodotExtension.set_camera(camera,b)

func _ready()->void:
	if camera==null:camera=GodotExtension.assign_node(self,"Camera3D")
	set_enabled(index>=0)
	#
	if index<0:index=-index-1
	if instances[index]==null:instances[index]=self

func _exit_tree()->void:
	if GodotExtension.s_reparenting:return
	if self==instances[index]:instances[index]=null

func _process(d:float)->void:
	camera.global_transform=root.global_transform
