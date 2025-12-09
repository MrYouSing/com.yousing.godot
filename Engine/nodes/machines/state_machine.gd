class_name StateMachine extends Node

@export var target:Node
@export var state:StringName
@export var states:Dictionary
@export var transition:Transition
@export var transitions:TransitionLibrary
@export var machines:Array[StateMachine]

var idle:StringName
var tween:Tween

func _ready()->void:
	if !state.is_empty():
		idle=state
		var tmp:String=state;state=&"*";set_state(tmp)

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

func _on_state(c:StateMachine,k:StringName,v:Variant,t:Transition)->void:
	state=k
	if target!=null and target.has_method(&"_on_state"):
		target.call(&"_on_state",self,state,v,t)
	# Broadcast downward.
	for it in machines:it.set_state(state)
