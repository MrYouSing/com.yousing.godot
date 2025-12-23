## Another implementation for AimIK,which is pole-like.
@tool
class_name PoleBone extends ArrowBone

@export_group("Pole")
@export var pole:Vector3=Vector3.MODEL_FRONT
@export var target:Vector3=Vector3.ZERO

func _on_update(c:Skeleton3D,b:int,d:float)->void:
	if start==null or pole.is_zero_approx():return
	# All in model-space.
	var p:Transform3D=c.get_bone_global_pose(b)
	var s:Vector3=p*start.position;var e:Vector3
	var q:Basis=(p.basis*start.basis).get_rotation_quaternion()
	# World-space to model-space.
	if end==null:e=target
	else:e=end.global_position
	e=c.global_transform.inverse()*e
	#
	p.basis=MathExtension.rotate_between(q*pole,s-e,normal)*p.basis
	c.set_bone_global_pose(b,p)
