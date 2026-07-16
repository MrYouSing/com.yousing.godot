class_name CharacterMotor extends Node

@export var direction:Vector3
@export var velocity:Vector3
@export var gravity:float=1.0
# For Animations
var anim:StringName
var state:int
var phase:int## Sub-State

func is_on_floor()->bool:
	return true

func update_rotation(m:Node3D,v:Vector3,n:Vector3,t:Vector2,d:float)->void:
	if m==null or v.is_zero_approx():return
	#
	var q:Quaternion=MathExtension.looking_at(v,n)
	m.quaternion=MathExtension.quat_lerp(m.quaternion,q,t,d)
