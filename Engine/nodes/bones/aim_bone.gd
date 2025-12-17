## A simple implementation for AimIK
@tool
class_name AimBone extends ArrowBone

@export_group("Aim")
@export_range(0.0,1.0,0.001) var weight:float=1.0
@export var axis:Vector3=Vector3.ZERO
@export var angle:float=0.0
@export var curve:Curve

func _on_update(c:Skeleton3D,b:int,d:float)->void:
	transform=c.get_bone_global_pose(b);
	var p:Basis=start.global_basis.get_rotation_quaternion();var q:Basis
	var v:Vector3=end.global_position-start.global_position
	if !normal.is_zero_approx():v=v.slide(p*normal)
	q=MathExtension.looking_at(v)
	#
	var a:float=angle;if curve!=null:a=curve.sample_baked(a)
	if !is_zero_approx(a) and !axis.is_zero_approx():q=q*Basis(axis,deg_to_rad(a))
	#
	global_basis=p.slerp(q,weight)

func _on_blend(c:Object,f:float)->void:
	weight=f
