## A [SkeletonModifier3D] with pose control.
@tool
class_name PoseBone extends BaseBone

static func set_from_actor(c:Actor,k:StringName,v:String,a:Album)->void:
	if c==null:return
	var p:PoseBone=c.get_component(k)
	if p!=null:
		if a!=null:
			var t:Album=a.load(c.name) as Album
			if t!=null:a=t
		p.context=c;p.variant=v;p.album=a

@export_group("Pose")
@export var album:Album
@export var variant:String
@export var from:Snapshot
@export var to:Snapshot
@export_range(0.0,1.0,0.001)var weight:float=1.0
@export var names:PackedStringArray
@export_tool_button("Bake")var _bake:Callable=bake

var context:Object=self
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
		if not variant.is_empty():
			var s:String=variant.format([context.name,self.name,k])
			if album!=null and album.exist(s):v=album.load(s)
			elif c.states.has(s):v=c.states.get(s,null)
		to=v as Snapshot
	if from==null:from=Snapshot.new()
	#
	if to==null:bake()
	elif o!=null:from.variants.assign(o.variants)
	weight=0.0;t.to_tween(Tweenable.make_tween(self),self,^"weight",1.0)
