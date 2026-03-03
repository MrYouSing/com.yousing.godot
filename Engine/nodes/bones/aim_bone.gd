## A simple implementation for AimIK
@tool
class_name AimBone extends ArrowBone

@export_group("Aim")
@export_flags(
	"Hybrid","Additive",
) var features:int
@export_range(0.0,1.0,0.001) var weight:float=1.0
@export var axis:Vector3=Vector3.ZERO
@export var angle:float=0.0
@export var curve:Curve

func _on_update(c:Skeleton3D,b:int,d:float)->void:
	var t:Transform3D=c.get_bone_global_pose(b);transform=t
	var p:Basis=start.global_basis.get_rotation_quaternion();var q:Basis
	var v:Vector3=end.global_position-start.global_position
	var a:float=angle;if curve!=null:a=curve.sample_baked(a)
	#
	if features&0x02!=0:
		q=MathExtension.get_heading(p)
		if not is_zero_approx(a) and not axis.is_zero_approx():q=q*Basis(axis,deg_to_rad(a))
		t.basis=c.global_basis.inverse()*p.slerp(q,weight)*t.basis;c.set_bone_global_pose(b,t)
	else:
		if not normal.is_zero_approx():v=v.slide(p*normal)
		q=MathExtension.looking_at(v)
		if not is_zero_approx(a) and not axis.is_zero_approx():q=q*Basis(axis,deg_to_rad(a))
		global_basis=p.slerp(q,weight)

func _on_blend(c:Object,f:float)->void:
	if features&0x01!=0:weight=f
	else:influence=f
