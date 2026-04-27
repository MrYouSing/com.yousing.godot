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
	if b:# Re-Active.
		if root!=null:root._on_dirty()
		if not path.is_empty():view=get_node_or_null(path)
	if view==null:
		set(&"visible",b)
		if b:GodotExtension.move_node(self,-1)# Topmost.
	else:
		GodotExtension.set_enabled(view,b)
		if b:GodotExtension.move_node(view,-1)# Topmost.

func _ready()->void:
	if root==null:root=GodotExtension.assign_node(self,"Control") as UITransform

func _enter_tree()->void:
	if is_node_ready():set_enabled(true)

func _exit_tree()->void:
	set_enabled(false)
