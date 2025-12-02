class_name StateMachine extends Node

@export var target:Node
@export var state:StringName
@export var states:Dictionary
@export var transition:Transition
@export var transitions:TransitionLibrary
var tween:Tween

func _ready()->void:
	if !state.is_empty():
		var tmp:String=state;state="*";set_state(tmp)

func set_state(s:StringName)->void:
	if s==state:return
	if tween!=null:tween.kill();tween=null#Stop
	# Find a state.
	var v:Variant=states.get(s)
	if v==null:return
	# Find a transition.
	var t:Transition=null
	if transitions!=null:t=transitions.eval(state,s)
	if t==null:t=transition
	# Apply a state.
	state=s
	if target==null or !target.has_method(&"_on_state"):return
	target.call(&"_on_state",self,state,v,t)

func get_tween()->Tween:
	if tween!=null:tween.kill();tween=null#Stop
	tween=create_tween()
	return tween
