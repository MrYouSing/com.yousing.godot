class_name StateTrigger extends ToggleTrigger

@export_group("State")
@export var time:Vector3=Vector3.FORWARD## [x,y] for range,z for lifetime.

var _time:float=-1.0
var _done:float=-1.0

func is_trigger()->bool:
	if _time<0.0:# Not in state.
		if is_on:is_on=false;return true# One-shot.
		if trigger!=null:return trigger.is_trigger()
	return false

func _on_enter()->void:
	if trigger==null:return
	is_on=false;_time=0.0;_done=-1.0

func _on_tick(d:float)->void:
	if trigger==null:return
	_time+=d;if is_on:return
	if MathExtension.time_outside(_time,time.x,time.y):return
	#
	if trigger!=null and trigger.is_trigger():
		is_on=true;_done=_time

func _on_exit()->void:
	if trigger==null:return
	if MathExtension.time_outside(_time,time.x,time.y):is_on=false
	if MathExtension.time_dead(_time-_done,time.z):is_on=false
	_time=-1.0;_done=-1.0
