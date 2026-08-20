## An optimized detector for computing slopes.
class_name SlopedDetector extends RaycastDetector

@export_group("Detector")
@export var offsets:PackedVector3Array

var _rotation:Quaternion

func detect()->bool:
	if offsets.is_empty():return super.detect()
	if dirty:_on_dirty()
	#
	var n:Node3D=root;var c:PhysicsDirectSpaceState3D=n.get_world_3d().direct_space_state
	var d:float=distance.y-distance.x;var m:Transform3D=n.global_transform
	_rotation=m.basis.get_rotation_quaternion();_direction=_rotation*forward
	clear();var j:int=0;var a:PackedVector3Array
	var i:int=-1;for it in offsets:
		i+=1;_origin=m.origin+_rotation*it+_direction*distance.x
		var r:Dictionary=PhysicsExtension.ray_cast(c,_origin,_origin+_direction*d,mask,exclude,flags)
		if not r.is_empty():
			if target==null:target=r.collider
			#elif r.collider==target:continue
			j|=1<<i;a.append(r.position);a.append(r.normal)
	return _on_slope(a,j)

func eval_offset(v:Vector3,n:Vector3)->Vector3:
	var q:Quaternion=Quaternion(_rotation*-forward,n)
	return q*v

func _on_slope(a:PackedVector3Array,i:int)->bool:
	var c:int=a.size();if c>0:
		var h:PhysicsExtension.HitInfo=PhysicsExtension.HitInfo.new()
		h.collider=target;h.rid=target.get_rid()
		c/=2;match c:
			1:
				h.point=a[0];h.normal=a[1]
				if i!=0x01:h.point+=eval_offset(offsets[0]-offsets[1],h.normal)
			2:
				h.point=(a[0]+a[2])*0.5
				h.normal=(a[2]-a[0]).normalized()
				h.normal=Quaternion(Vector3.RIGHT,PI*-0.5)*h.normal
				h.point+=eval_offset(offsets[0]-offsets[1],h.normal)*0.5
		apply(h);return true
	return false
