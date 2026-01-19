## A helper class that tracks Mouse or Touch.
class_name UIPointer extends Node

@export_group("Pointer")
@export var input:PointerInput
@export var id:int=-1
@export var control:Control

func set_position(v:Vector2)->void:
	if control!=null:
		control.global_position=UITransform.get_position(control,v)

func _ready()->void:
	if input==null:input=PointerInput.current
	if control==null:control=GodotExtension.assign_node(self,"Control")

func _process(d:float)->void:
	if input==null:return
	var p:PointerInput.PointerEvent=input.get_pointer(id)
	if p!=null:
		set_position(p.position if p.on() else UITransform.k_hidden_pos)
	
