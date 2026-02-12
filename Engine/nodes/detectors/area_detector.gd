## An [Area3D] bridge for detections.
class_name AreaDetector extends BaseDetector

@export_group("Area")

func setup(a:Node)->void:
	if a!=null:
		if (flags&0x01)!=0:
			a.area_entered.connect(_on_enter)
			a.area_exited.connect(_on_exit)
		if (flags&0x02)!=0:
			a.body_entered.connect(_on_enter)
			a.body_exited.connect(_on_exit)

func teardown(a:Node)->void:
	if a!=null:
		if (flags&0x01)!=0:
			a.area_entered.disconnect(_on_enter)
			a.area_exited.disconnect(_on_exit)
		if (flags&0x02)!=0:
			a.body_entered.disconnect(_on_enter)
			a.body_exited.disconnect(_on_exit)

func detect()->bool:
	return not targets.is_empty()

func _on_enter(o:Object)->void:
	if dirty:_on_dirty()
	var r:RID=o.get_rid();if exclude.has(r):return
	var i:int=targets.find(o);if i>=0:return
	#
	apply(Physics.HitInfo.from_points(o,GodotExtension.get_global_position(o),GodotExtension.get_global_position(self)))
	_on_find(o)

func _on_exit(o:Object)->void:
	if dirty:_on_dirty()
	var r:RID=o.get_rid();if exclude.has(r):return
	var i:int=targets.find(o);if i<0:return
	#
	_on_miss(o)
	infos.erase(r)

func _ready()->void:
	setup(root)

func _exit_tree()->void:
	teardown(root)
