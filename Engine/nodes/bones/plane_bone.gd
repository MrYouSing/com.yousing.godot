## A [Plane]-based [SkeletonModifier3D].
@tool
class_name PlaneBone extends BaseBone

@export_group("Plane")
@export var root:Node
@export var node:Node
@export var plane:Plane=Plane(Vector3.UP,0.0)
@export var ray:Vector3
@export var arrow:Vector3

func project(p:Plane,v:Vector3)->Variant:
	if ray.length_squared()<=0.0:return p.project(v)
	else:return p.intersects_ray(v,ray)

func _on_update(c:Skeleton3D,b:int,d:float)->void:
	var p:Plane=plane;var m:Transform3D=c.global_transform
	if root!=null:
		p=(m.inverse()*GodotExtension.get_global_transform(root))*p
	var t:Transform3D=c.get_bone_global_pose(b)
	var v:Variant=project(p,t.origin);if v==null:return
	if arrow.length_squared()>0.0:
		var a:Vector3=t*arrow
		t.origin=v;v=project(p,a)
		if v!=null:t.basis=t.basis*Basis(Quaternion(a,v-t.origin))
	else:
		t.origin=v
	if node==null:c.set_bone_global_pose(b,t)
	else:GodotExtension.set_global_transform(node,m*t)
