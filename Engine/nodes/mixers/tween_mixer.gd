## A mixer driven by [Tween].
class_name TweenMixer extends PropertyMixer

@export_group("Tween")
@export var duration:Vector4=Vector4(0.0,1.0,0.0,1.0)
@export var curveIn:Curve
@export var curveOut:Curve

signal finished(b:bool)

var _direction:int=0

func get_delay(f:float)->float:
	if f<0.0:
		if _direction==0:f=0.0
		else:f=-f
	return f

func set_enabled(b:bool)->void:
	if b and _direction==1:return
	elif not b and _direction==-1:return
	#
	var t:Tween=Tweenable.make_tween(target)
	if b:
		_direction=1;curve=curveIn
		var d:float=get_delay(duration.x);if d>0.0:t.tween_interval(d)
		t.tween_property(self,^"weight",1.0,duration.y)
	else:
		_direction=-1;curve=curveOut
		var d:float=get_delay(duration.z);if d>0.0:t.tween_interval(d)
		t.tween_property(self,^"weight",0.0,duration.w)
	t.finished.connect(_finished)

func _finished()->void:
	finished.emit(_direction==1)
