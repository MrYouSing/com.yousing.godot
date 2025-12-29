@tool
class_name BeehaveLeaf extends Leaf

@export_group("Leaf")
@export var duration:float

var time:float

func result(a:Node,b:Blackboard,r:Variant)->bool:
	match typeof(r):
		TYPE_BOOL:return r
		_:return true

func invoke(a:Node,b:Blackboard)->bool:
	LangExtension.throw_exception(self,LangExtension.e_not_implemented)
	return false

func before_run(a:Node,b:Blackboard)->void:
	if duration>0.0:time=-1.0

func tick(a:Node,b:Blackboard)->int:
	if Engine.is_editor_hint():return FAILURE
	#
	if duration<0.0:# Condition
		if invoke(a,b):return SUCCESS
		else:return FAILURE
	else:# Action
		var t:float=Application.get_time()
		if time<0.0:time=t;if !invoke(a,b):return FAILURE
		#
		if t-time<=duration:return RUNNING
		else:time=-1.0;return SUCCESS
