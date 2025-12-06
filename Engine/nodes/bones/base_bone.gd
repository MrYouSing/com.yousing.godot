@tool
class_name BaseBone extends SkeletonModifier3D

@export var bone_index:int=-1
@export_enum(" ") var bone_name:String:
	set(x):
		bone_name=x
		var ctx:Skeleton3D=get_skeleton()
		if ctx!=null:bone_index=ctx.find_bone(bone_name)

func _validate_property(property:Dictionary)->void:
	if property.name=="bone_name":
		var ctx:Skeleton3D=get_skeleton()
		if ctx!=null:
			property.hint=PROPERTY_HINT_ENUM
			property.hint_string=ctx.get_concatenated_bone_names()

func _process_modification()->void:
	var ctx:Skeleton3D=get_skeleton()
	if ctx!=null and bone_index>=0:_update(ctx,bone_index,0.0)

func _update(c:Skeleton3D,b:int,d:float)->void:
	transform=c.get_bone_global_pose(b)
