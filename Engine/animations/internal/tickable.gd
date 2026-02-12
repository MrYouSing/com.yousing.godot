## An interface that ticks at intervals.
class_name Tickable extends Node

@export_group("Tick")
@export var rate:float=-1.0:
	set(x):rate=x;if _step>=0.0:_rate()

var _step:float=-1.0
var _time:float=-1.0

func set_enabled(b:bool)->void:
	var a:bool=_time>=0.0
	if not a and b:_play();_time=_step
	elif a and not b:_stop();_time=-1.0
	set_process(b)

func _play()->void:
	LangExtension.throw_exception(self,LangExtension.e_not_implemented)

func _tick()->void:
	LangExtension.throw_exception(self,LangExtension.e_not_implemented)

func _stop()->void:
	LangExtension.throw_exception(self,LangExtension.e_not_implemented)

func _rate()->void:
	_step=MathExtension.time_delta(rate)
	set_enabled(is_zero_approx(_step))

func _ready()->void:
	_step=0.0;_rate()

func _process(d:float)->void:
	_time-=d;if _time<=0.0:
		_time+=_step;_tick()
