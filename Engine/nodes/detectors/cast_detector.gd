## A [ShapeCast3D] bridge for detections.
class_name CastDetector extends BaseDetector

@export_group("Cast")
@export var distance:float=1.0

var caster:Node

func _on_dirty()->void:
	super._on_dirty()
	if caster!=null:
		caster.enabled=false
		caster.collide_with_areas=(flags&0x01)!=0
		caster.collide_with_bodies=(flags&0x02)!=0
		caster.collision_mask=mask
		caster.clear_exceptions()
		for it in exclude:caster.add_exception_rid(it)

func detect()->bool:
	if dirty:_on_dirty()
	clear();if caster!=null:
		caster.target_position=MathExtension.vec3_to_var(forward*distance,caster)
		caster.force_shapecast_update()
		var n:int=caster.get_collision_count()
		var h:PhysicsExtension.HitInfo=null
		if n>0:
			for i in n:
				h=PhysicsExtension.HitInfo.from_cast(caster,i)
				apply(h);_on_find(h.collider)
			target=targets[0];return true
	return false

func _ready()->void:
	if caster==null and PhysicsExtension.is_cast(root):caster=root
