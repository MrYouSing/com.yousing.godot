## A [SkeletonModifier3D] with pose control.
@tool
class_name PoseBone extends BaseBone

static func set_from_actor(a:Actor,k:StringName,v:Variant,i:int=-1)->void:
	if a==null:
		return
	if i>=0:
		if i>=v.size():return
		v=v[i]
	#
	var p:PoseBone=a.get_component(k)
	if p!=null:p.variant=v

@export_group("Pose")
@export var variant:String
@export var from:Snapshot
@export var to:Snapshot
@export_range(0.0,1.0,0.001)var weight:float=1.0
@export var names:PackedStringArray
@export_tool_button("Bake")var _bake:Callable=bake

var indexes:PackedInt32Array

func bake()->void:
	var c:Skeleton3D=get_parent();var t:Transform3D
	if c!=null:
		if from!=null:
			from.variants.clear()
			for it in names:
				t=c.get_bone_pose(c.find_bone(it))
				from.variants.append(t)
			from.emit_changed()
		else:
			print(c.get_concatenated_bone_names().split(","))

func _on_sample(c:Skeleton3D,i:int,b:int)->Transform3D:
	var f:Transform3D=c.get_bone_pose(b) if from==null else from.variants[i]
	var t:Transform3D=c.get_bone_pose(b) if to==null else to.variants[i]
	return Transform3D(f.basis.slerp(t.basis,weight),f.origin.lerp(t.origin,weight))

func _on_update(c:Skeleton3D,b:int,d:float)->void:
	b=names.size();if indexes.size()!=b:
		indexes.clear()
		for it in names:indexes.append(c.find_bone(it))
	for i in indexes.size():
		b=indexes[i]
		c.set_bone_pose(b,_on_sample(c,i,b))

func _on_state(c:Object,k:StringName,v:Variant,t:Transition)->void:
	var o:Snapshot=to;to=null
	if v!=null:
		if not variant.is_empty():v=c.states.get(variant.format([k]),null)
		to=v as Snapshot
	if from==null:from=Snapshot.new()
	#
	if to==null:bake()
	elif o!=null:from.variants.assign(o.variants)
	weight=0.0;t.to_tween(Tweenable.make_tween(self),self,^"weight",1.0)
