## A custom [RayCast3D].
class_name RaycastDetector extends BaseDetector

@export_group("Raycast")
@export var distance:Vector2=Vector2.DOWN*100

var _origin:Vector3
var _direction:Vector3

func detect()->bool:
	if dirty:_on_dirty()
	#
	var n:Node3D=root;var m:Transform3D=n.global_transform
	var c:PhysicsDirectSpaceState3D=n.get_world_3d().direct_space_state
	_origin=m.origin;_direction=m.basis.get_rotation_quaternion()*forward
	var r:Dictionary=GodotExtension.ray_cast(c,_origin,_origin+_direction*distance.y,mask,exclude,flags)
	if !r.is_empty():
		clear()
		if (r.position-_origin).length_squared()>=distance.x*distance.x:
			target=r.collider;_on_find(r)
			return true
		else:
			_on_miss(r)
	return false
