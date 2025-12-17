## Another implementation for AimIK,which is pole-like.
@tool
class_name PoleBone extends ArrowBone

@export_group("Pole")

func _on_update(c:Skeleton3D,b:int,d:float)->void:
	if start==null or normal.is_zero_approx():return
	var s:Vector3=start.position
	var e:Vector3=end.global_position
	#
	var p:Transform3D=c.get_bone_global_pose(b)
	var g:Transform3D=c.global_transform*p
	s=e-g*s;e=(g.basis*start.basis).get_rotation_quaternion()*normal
	p.basis=MathExtension.rotate_between(e,s)*p.basis
	c.set_bone_global_pose(b,p)
	
