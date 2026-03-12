## A custom [RayCast3D].
class_name RaycastDetector extends BaseDetector

@export_group("Raycast")
@export var distance:Vector2=Vector2.DOWN*100

var _origin:Vector3
var _direction:Vector3

func detect()->bool:
	if dirty:_on_dirty()
	#
	var n:Node3D=root;var c:PhysicsDirectSpaceState3D=n.get_world_3d().direct_space_state
	var d:float=distance.y-distance.x;var m:Transform3D=n.global_transform
	_direction=m.basis.get_rotation_quaternion()*forward
	_origin=m.origin+_direction*distance.x
	var r:Dictionary=Physics.ray_cast(c,_origin,_origin+_direction*d,mask,exclude,flags)
	if not r.is_empty():
		clear()
		target=r.collider;_on_find_hit(r)
		return true
	return false

func _on_find_hit(d:Dictionary)->void:
	if not d.is_empty():
		if d.normal.is_zero_approx():d.normal=-_direction
		#
		apply(Physics.HitInfo.from_dict(d))
		_on_find(d.collider)
