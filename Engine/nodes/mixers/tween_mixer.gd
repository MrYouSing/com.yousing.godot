## A mixer driven by [Tween].
class_name TweenMixer extends PropertyMixer

@export_group("In","in_")
@export var in_delay:float
@export var in_duration:float=1.0
@export var in_trans:Tween.TransitionType
@export var in_ease:Tween.EaseType=Tween.EaseType.EASE_IN_OUT
@export var in_curve:Curve
@export_group("Out","out_")
@export var out_delay:float
@export var out_duration:float=1.0
@export var out_trans:Tween.TransitionType
@export var out_ease:Tween.EaseType=Tween.EaseType.EASE_IN_OUT
@export var out_curve:Curve

signal started(b:bool)
signal finished(b:bool)

var _direction:int=0

func set_enabled(b:bool)->void:
	if b and _direction==1:return
	elif not b and _direction==-1:return
	#
	var t:Tween=Tweenable.make_tween(target)
	if b:_on_tween(t,in_delay,in_duration,1.0,in_trans,in_ease,in_curve);_direction=1
	else:_on_tween(t,out_delay,out_duration,0.0,out_trans,out_ease,out_curve);_direction=-1
	_started();t.finished.connect(_finished)

func _on_tween(t:Tween,w:float,d:float,v:float,x:Tween.TransitionType,e:Tween.EaseType,c:Curve)->void:
	curve=c
	if w<0.0:
		if _direction==0:w=0.0
		else:w=-w
	var p:PropertyTweener=t.tween_property(self,^"weight",v,d).set_trans(x).set_ease(e)
	if w>0.0:p.set_delay(w)

func _started()->void:
	started.emit(_direction==1)

func _finished()->void:
	finished.emit(_direction==1)
