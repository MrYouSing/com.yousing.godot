## A helper class that tracks Mouse or Touch.
class_name UIPointer extends Node

@export_group("Pointer")
@export var control:Control
@export var id:int=-1

func set_position(v:Vector2)->void:
	if control!=null:
		control.position=UITransform.get_position(control,v)

func _ready()->void:
	if control==null:control=GodotExtension.assign_node(self,"Control")

func _input(e:InputEvent)->void:
	if id<0:if e is InputEventMouse:
		set_position(e.position)
	elif e is InputEventScreenTouch:if e.index==id:
		set_position(e.position if e.pressed else UITransform.k_hidden_pos)
	elif e is InputEventScreenDrag:
		set_position(e.position)
