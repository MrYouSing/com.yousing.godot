class_name StateMachine extends BaseMachine

@export_group("State")
@export var state:StringName
@export var states:Dictionary[StringName,Variant]
@export var transition:Transition
@export var transitions:TransitionLibrary
@export var machines:Array[BaseMachine]

var idle:StringName
signal on_state(c:Object,k:StringName,v:Variant,t:Transition)

func _ready()->void:
	if not state.is_empty():
		idle=state
		var tmp:StringName=state;state=&"*";set_state(tmp)

func abort()->void:
	state=LangExtension.s_none_string;stop_tween()
	for it in machines:if it!=null:it.stop_tween()

func broadcast(s:StringName)->void:
	if s==state:return
	for it in machines:if it!=null:it._on_event(self,s)
	state=s# Flush it.

func set_state(s:StringName)->void:
	# Prepare a state.
	if states.is_empty():broadcast(s);return
	if s==state:return
	stop_tween()
	# Find a state.
	var v:Variant=states.get(s)
	if v==null:
		if idle.is_empty():return
		else:v=states.get(s);if v==null:return
	# Find a transition.
	var t:Transition=null
	if transitions!=null:t=transitions.eval(state,s)
	if t==null:t=transition
	#
	_on_state(self,s,v,t)

func _on_dirty()->void:
	on_execute=LangExtension.merge_signal(self,on_execute,on_state,targets,&"_on_state")
	dirty=false

func _on_state(c:Object,k:StringName,v:Variant,t:Transition)->void:
	if dirty:_on_dirty()
	#
	on_execute.emit(self,state,v,t)
	broadcast(k)

# For other systems.

func play(k:StringName)->void:set_state(k)
func _on_event(c:Object,e:StringName)->void:set_state(e)
