## A tool class for arrow-style.
@tool
class_name ArrowBone extends BaseBone

@export_group("Arrow")
@export var normal:Vector3
@export var start:Node3D
@export var end:Node3D

func _update(c:Skeleton3D,b:int,d:float)->void:
	transform=c.get_bone_global_pose(b);
	if start!=null:
		var q:Basis;
		if end==null:q=start.global_basis
		else:q=MathExtension.looking_at(end.global_position-start.global_position)
		if !normal.is_zero_approx():q=MathExtension.get_heading(q,normal)
		global_basis=q.get_rotation_quaternion()# Discard the scale.
