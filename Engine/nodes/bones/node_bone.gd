## A helper class that modifies bones from node mode.
@tool
class_name NodeBone extends BaseBone

@export_group("Node")
@export_flags(
	"Modify T","Global T","Additive T","Reserved 0",
	"Modify R","Global R","Additive R","Reserved 1"
)var features:int

func _on_update(c:Skeleton3D,b:int,d:float)->void:
	var m:Transform3D=c.global_transform.inverse()
	var t:Transform3D=c.get_bone_global_pose(b)
	if features&0x01!=0:
		if features&0x02!=0:
			if features&0x04!=0:
				t.origin+=m*global_position
			else:
				t.origin=m*global_position
		else:
			if features&0x04!=0:
				t.origin+=position
			else:
				t.origin=position
	if features&0x10!=0:
		if features&0x20!=0:
			if features&0x40!=0:
				t.basis=m.basis*global_basis*t.basis
			else:
				t.basis=m.basis*global_basis
		else:
			if features&0x40!=0:
				t.basis=basis*t.basis
			else:
				t.basis=basis
	c.set_bone_global_pose(b,t)
