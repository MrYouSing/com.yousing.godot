@tool
class_name BeehaveCall extends BeehaveLeaf

@export_group("Call")

var call:Callable

func before_run(a:Node,b:Blackboard)->void:
	super.before_run(a,b)
	if call.is_null() and a.has_method(name):call=Callable(a,name)

func invoke(a:Node,b:Blackboard)->bool:
	if call.is_valid():return result(a,b,call.call())
	return false
