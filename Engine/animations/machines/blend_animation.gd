## A blend animation which has states.
class_name BlendAnimation extends BlendMachine

@export_group("Animation")
@export var keywords:Array[StringName]
@export var fade:float=1.0
@export var transitions:TransitionLibrary

var curve:Curve

func _on_state(c:Object,k:StringName,v:Variant,t:Transition)->void:
	_on_event(c,k)

func _on_event(c:Object,e:StringName)->void:
	stop_tween();curve=null;thiz=c
	#
	var f:float=0.0;var t:Transition
	if keywords.has(e):f=1.0
	if transitions!=null:t=transitions.eval(c.state,e)
	#
	if t!=null:curve=t.curve;t.do_tween(get_tween(),self,&"blend",weight,f)
	else:get_tween().tween_method(blend,weight,f,fade)

func _on_blend(c:Object,f:float)->void:
	weight=f
	if dirty:_on_dirty()
	#
	if curve!=null:f=curve.sample_baked(f)
	if !remap.is_zero_approx():f=remap.x*f+remap.y
	on_execute.emit(c,f)
