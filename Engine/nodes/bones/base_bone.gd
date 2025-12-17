## A base class for procedural animations.
@tool
class_name BaseBone extends SkeletonModifier3D

@export_group("Bone")
@export var bone_index:int=-1
@export_enum(" ") var bone_name:String:
	set(x):
		bone_name=x
		var ctx:Skeleton3D=get_skeleton()
		if ctx!=null:bone_index=ctx.find_bone(bone_name)

func set_enabled(b:bool)->void:active=b
func show()->void:active=true
func hide()->void:active=false

func _validate_property(property:Dictionary)->void:
	if property.name=="bone_name":
		var ctx:Skeleton3D=get_skeleton()
		if ctx!=null:
			property.hint=PROPERTY_HINT_ENUM
			property.hint_string=ctx.get_concatenated_bone_names()

func _process_modification_with_delta(delta:float)->void:
	var ctx:Skeleton3D=get_skeleton()
	if ctx!=null and bone_index>=0:_on_update(ctx,bone_index,delta)

func _on_update(c:Skeleton3D,b:int,d:float)->void:
	transform=c.get_bone_global_pose(b)

# For other systems.

func _on_toggle(c:Object,b:bool)->void:
	active=b

func _on_blend(c:Object,f:float)->void:
	influence=f;active=!is_zero_approx(f)
