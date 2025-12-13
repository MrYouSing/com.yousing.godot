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

func _process_modification()->void:
	if start!=null:
		if end==null:spine=start.basis
		else:
			var vec:Vector3=end.global_position-start.global_position
			spine=MathExtension.looking_at(vec)
			spine=start.global_basis.inverse().get_rotation_quaternion()*spine
	if !normal.is_zero_approx():
		spine=MathExtension.looking_at((spine*Vector3.BACK).slide(normal))
	if spine.is_equal_approx(Quaternion.IDENTITY):return
	#
	var ctx:Skeleton3D=get_skeleton()
	if ctx==null:return
	var b:int=indexes.size();if names.size()!=b:
		indexes.clear()
		for it in names:indexes.append(ctx.find_bone(it))
	GodotExtension.get_bone_global_poses(ctx,indexes,poses)
	#
	var q:Quaternion;var t:Quaternion;#print(spine)
	if offset.is_equal_approx(Quaternion.IDENTITY):t=spine
	else:t=Basis((offset*spine.get_axis()).normalized(),spine.get_angle())
	for i in range(b):
		b=indexes[i];if b<0:continue
		q=poses[i].basis
		q=q*Quaternion.IDENTITY.slerp(t,weights[i])
		GodotExtension.set_bone_global_rotation(ctx,b,q)
