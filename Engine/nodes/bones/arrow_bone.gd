@tool
class_name ArrowBone extends BaseBone

@export var arrow:Node3D
@export var normal:Vector3

func _update(c:Skeleton3D,b:int,d:float)->void:
	transform=c.get_bone_global_pose(b);
	if arrow!=null:
		var q:Basis;
		if normal.is_zero_approx():q=arrow.global_basis
		else:q=MathExtension.get_heading(arrow.global_basis,normal)
		global_basis=q.get_rotation_quaternion()
