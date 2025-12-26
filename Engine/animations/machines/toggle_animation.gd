## A Toggle animation which has states.
class_name ToggleAnimation extends ToggleMachine

@export_group("Animation")
@export var keywords:Array[StringName]
@export var fade:float=0.0
@export var transitions:TransitionLibrary

var curve:Curve

func _on_state(c:Object,k:StringName,v:Variant,t:Transition)->void:
	_on_event(c,k)

func _on_event(c:Object,e:StringName)->void:
	stop_tween();curve=null;
	#
	var f:float=0.0;var t:Transition
	if keywords.has(e):f=1.0
	if transitions!=null:t=transitions.eval(c.state,e)
	#
	if t!=null:curve=t.curve;t.to_tween(play_tween(),self,^"weight",f)
	elif fade>0.0:play_tween().tween_property(self,^"weight",f,fade)
	else:_on_toggle(c,f>0.5)
