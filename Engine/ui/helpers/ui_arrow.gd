## A helper arrow for ui navigation.
class_name UIArrow extends Node

@export_group("Arrow")
@export var root:UITransform
@export var path:NodePath
@export var view:Node

var _direction:int

func set_enabled(b:bool)->void:
	var d:int=MathExtension.bool_to_sign(b)
	if d==_direction:return
	_direction=d
	#
	if b:
		if root!=null:root._on_dirty()
		if not path.is_empty():view=get_node_or_null(path)
	GodotExtension.set_enabled(view,b)

func _ready()->void:
	if root==null:root=GodotExtension.assign_node(self,"Control") as UITransform

func _enter_tree()->void:
	set_enabled(true)

func _exit_tree()->void:
	set_enabled(false)
