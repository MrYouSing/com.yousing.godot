## A helper class for persistent functions.
class_name Func extends Node

@export_group("Func")
@export var target:Node
@export var path:NodePath
@export var method:StringName
@export var arguments:Array

func invoke()->Variant:
	if target==null or not target.has_method(method):return null
	return target.callv(method,arguments)

func invoke_with(...args:Array)->Variant:
	if target==null or not target.has_method(method):return null
	if args.is_empty():return target.callv(method,arguments)
	else:return target.callv(method,args)

func _ready()->void:
	if not path.is_empty():
		var p:Node=target;if p==null:p=GodotExtension.s_root
		var n:Node=p.get_node_or_null(path)
		if n!=null:target=n
