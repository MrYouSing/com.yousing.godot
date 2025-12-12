class_name StateMachine extends BaseMachine

@export_group("State")
@export var state:StringName
@export var states:Dictionary
@export var transition:Transition
@export var transitions:TransitionLibrary
@export var machines:Array[StateMachine]

var idle:StringName
var tween:Tween
signal on_state(c:Object,k:StringName,v:Variant,t:Transition)

func _ready()->void:
	if !state.is_empty():
		idle=state
		var tmp:StringName=state;state=&"*";set_state(tmp)

func get_tween()->Tween:
	if tween!=null:tween.kill();tween=null#Stop
	tween=create_tween();return tween

func set_state(s:StringName)->void:
	if s==state:return
	if tween!=null:tween.kill();tween=null#Stop
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
	state=k
	if dirty:_on_dirty()
	#
	on_execute.emit(self,state,v,t)
	for it in machines:it.set_state(state)

# For other systems.

func _on_event(c:Object,e:StringName)->void:
	set_state(e)
