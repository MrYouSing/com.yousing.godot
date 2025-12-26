class_name CharacterMotor extends Node

@export var direction:Vector3
@export var velocity:Vector3
@export var gravity:float=1.0
# For Animations
var anim:StringName
var state:int
var phase:int## Sub-State

var exit_time:Callable
var exit_func:Callable
func _get(k:StringName)->Variant:
	return AnimatorController.call_parse(k,0,exit_time,exit_func)

func is_on_floor()->bool:
	return true

func update_rotation(m:Node3D,v:Vector3,n:Vector3,t:Vector2,d:float)->void:
	if m==null or v.is_zero_approx():return
	#
	var q=MathExtension.looking_at(v,n)
	m.quaternion=MathExtension.quat_lerp(m.quaternion,q,t,d)

#func _process(delta:float)->void:
#	pass
	
#func  _physics_process(delta:float)->void:
#	pass
