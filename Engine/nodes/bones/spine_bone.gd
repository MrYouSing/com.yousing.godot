## A simple implementation for LookAtIK.
@tool
class_name SpineBone extends ArrowBone

@export_group("Spine")
@export var spine:Quaternion=Quaternion.IDENTITY
@export var offset:Quaternion=Quaternion.IDENTITY
@export var names:Array[String]
@export var indexes:Array[int]
@export_range(0.0,1.0,0.001,"or_greater") var weights:Array[float]

var poses:Array[Transform3D]

func _process_modification_with_delta(delta:float)->void:
	var q:Quaternion=spine
	if start!=null:
		if end==null:q=start.basis
		else:
			var v:Vector3=end.global_position-start.global_position
			q=MathExtension.looking_at(v)
			q=start.global_basis.inverse().get_rotation_quaternion()*q
	if !normal.is_zero_approx():
		q=MathExtension.looking_at((q*Vector3.BACK).slide(normal))
	if q.is_equal_approx(Quaternion.IDENTITY):return
	#
	var ctx:Skeleton3D=get_skeleton()
	if ctx==null:return
	var b:int=indexes.size();if names.size()!=b:
		indexes.clear()
		for it in names:indexes.append(ctx.find_bone(it))
	GodotExtension.get_bone_global_poses(ctx,indexes,poses)
	#
	var p:Quaternion;
	if !offset.is_equal_approx(Quaternion.IDENTITY):
		q=Basis((offset*q.get_axis()).normalized(),q.get_angle())
	for i in range(b):
		b=indexes[i];if b<0:continue
		p=poses[i].basis
		p=p*Quaternion.IDENTITY.slerp(q,weights[i])
		GodotExtension.set_bone_global_rotation(ctx,b,p)
