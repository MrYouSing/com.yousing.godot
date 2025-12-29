@tool
class_name BeehaveFunc extends BeehaveLeaf

@export_group("Func")
@export var target:Node
@export var method:StringName
@export var arguments:Array

func invoke(a:Node,b:Blackboard)->bool:
	var t:Node
	if target==null:t=a
	else:t=target
	#
	if t.has_method(method):
		return result(a,b,t.callv(method,arguments))
	return false
