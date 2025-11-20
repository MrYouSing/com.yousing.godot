class_name FsmTransition extends FsmNode

@export var time:Vector2
@export var trigger:BaseTrigger
@export var next:FsmState
var state:FsmState

func in_time(f:float)->bool:
	if time.x!=time.y:
		var t:Vector2=time;var d=state.root.state.duration
		if d<=0.0 and state!=state.root.state:#parent state
			pass
		elif t.x<t.y:#[min,max]
			if t.x<0.0:t.x=d+t.x
			if t.y<0.0:t.y=d+t.y
			return f>=t.x&&f<=t.y;
		else:#[min,∞)
			if t.x<=0.0:t.x=d+t.x;
			return f>=t.x;
	return true;

func is_trigger()->bool:
	if trigger!=null:return trigger.is_trigger()
	else:return next==state.root.states[0]
