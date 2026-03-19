## A helper class that modifies bones from node mode.
@tool
class_name NodeBone extends BaseBone

@export_group("Node")
@export var node:Node3D
@export_flags(
	"Modify T","Global T","Additive T","Reserved 0",
	"Modify R","Global R","Additive R","Reserved 1"
)var features:int

func _on_update(c:Skeleton3D,b:int,d:float)->void:
	var n:Node=node;if n==null:n=self
	var m:Transform3D=c.global_transform.inverse()
	var t:Transform3D=c.get_bone_global_pose(b)
	if features&0x01!=0:
		if features&0x02!=0:
			if features&0x04!=0:
				t.origin+=m*n.global_position
			else:
				t.origin=m*n.global_position
		else:
			if features&0x04!=0:
				t.origin+=n.position
			else:
				t.origin=n.position
	if features&0x10!=0:
		if features&0x20!=0:
			if features&0x40!=0:
				t.basis=m.basis*n.global_basis*t.basis
			else:
				t.basis=m.basis*n.global_basis
		else:
			if features&0x40!=0:
				t.basis=n.basis*t.basis
			else:
				t.basis=n.basis
	c.set_bone_global_pose(b,t)
