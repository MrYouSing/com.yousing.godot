class_name Transition extends Resource

@export_group("Transition")
@export var from:StringName
@export var to:StringName
@export var delay:float
@export var duration:float=1.0
@export_group("Tween")
@export var trans:Tween.TransitionType
@export var ease:Tween.EaseType
@export var curve:Curve

func to_tween(t:Tween,o:Object,k:NodePath,v:Variant,p:bool=false)->void:
	if t==null or o==null:return
	#
	if p:t=t.parallel()
	elif delay>0.0:t.tween_interval(delay)
	t.tween_property(o,k,v,duration).set_trans(trans).set_ease(ease)
