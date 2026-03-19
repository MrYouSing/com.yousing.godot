@tool
class_name BeehaveFunc extends BeehaveLeaf

@export_group("Func")
@export var target:Node
@export var method:StringName
@export var arguments:Array

func invoke(a:Node,b:Blackboard)->bool:
	var t:Node=a if target==null else target
	#
	if t.has_method(method):
		return result(a,b,t.callv(method,arguments))
	return false
