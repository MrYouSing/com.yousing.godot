@tool
class_name BeehaveCall extends BeehaveLeaf

@export_group("Call")

var call:Callable

func before_run(a:Node,b:Blackboard)->void:
	if duration>=0.0:time=-1.0
	if call.is_null() and a.has_method(name):call=Callable(a,name)

func invoke(a:Node,b:Blackboard)->bool:
	if call.is_valid():return result(a,b,call.call())
	return false
