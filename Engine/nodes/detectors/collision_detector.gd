## A helper class for detecting collisions manually.
class_name CollisionDetector extends BaseDetector

@export_group("Collision")
@export var capacity:int=32
@export var shape:Resource

func detect()->bool:
	if dirty:_on_dirty()
	#
	clear();if shape!=null:
		var c:PhysicsDirectSpaceState3D=root.get_world_3d().direct_space_state()
		var n:int=PhysicsExtension.shared_max;PhysicsExtension.shared_max=capacity;
		var m:Transform3D=root.global_transform;var r:Array=PhysicsExtension.shape_overlap(c,m.origin,m.basis,shape,mask,exclude,flags)
		PhysicsExtension.shared_max=n;if not r.is_empty():
			for it in r:
				_on_find(it)
				apply(PhysicsExtension.HitInfo.from_points(it,GodotExtension.get_global_position(it),m.origin))
			target=targets[0];return true
	return false
