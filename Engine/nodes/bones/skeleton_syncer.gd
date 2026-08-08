## A tool class for [Skeleton3D] synchronization.
class_name SkeletonSyncer extends Updatable

@export_group("Skeleton","skel_")
@export var skel_path:String
@export var skel_root:Node
@export var skel_pose:bool
@export_group("Source","src_")
@export var src_root:Node:
	set(x):
		if x==null:teardown()
		src_root=x
@export var src_paths:PackedStringArray
@export var src_bones:Array[Node]
@export var src_poses:Array
@export_group("Destination","dst_")
@export var dst_root:Node
@export var dst_paths:PackedStringArray
@export var dst_bones:Array[Node]

var _inited:bool
var src_indexes:PackedInt32Array
var dst_indexes:PackedInt32Array

func teardown()->void:
	if not _inited:return
	_inited=false
	#
	src_bones.clear()
	src_indexes.clear()
	if dst_root is Skeleton3D:dst_root.reset_bone_poses()

func clone()->Node:
	var c:Node=self.duplicate()
	c.target=self;c.event=&"clone"# Make it managed.
	c.skel_pose=true
	return c

func config()->void:
	var t:Array[PackedStringArray]=Asset.load_table(skel_path)
	if not t.is_empty():
		var i:int;for it in t:
			i=src_paths.find(it[0])
			if i>=0:src_poses[i]=MathExtension.str_to_mat(it[1],";")

func actor()->Node:
	return dst_root

func setup_bones()->void:
	if _inited:return
	_inited=true
	#
	var n:int=dst_bones.size()
	if src_bones.size()<n and src_root!=null:
		src_bones.resize(n)
		for i in n:
			src_bones[i]=src_root.get_node_or_null(src_paths[i])
	if src_poses.size()<n:
		src_poses.resize(n)
		for i in n:src_poses[i]=Transform3D.IDENTITY
	if not skel_path.is_empty():config()

func sync_bones()->void:
	if not _inited:setup_bones()
	#
	var n:int=src_bones.size()
	var s:Node;var d:Node
	for i in n:
		s=src_bones[i];d=dst_bones[i]
		if s!=null and d!=null:
			d.global_transform=s.global_transform*src_poses[i]

func setup_skeleton()->void:
	if _inited:return
	_inited=true
	#
	var n:int=dst_paths.size()
	if src_paths.size()<n:
		src_paths.clear();src_paths.append_array(dst_paths)
	if src_indexes.size()<n:
		AnimationExtension.find_bones(src_root,src_paths,src_indexes)
	if src_poses.size()<n:
		src_poses.resize(n)
		for i in n:src_poses[i]=Transform3D.IDENTITY
	if not skel_path.is_empty():config()

func sync_skeleton()->void:
	if not _inited:setup_skeleton()
	#
	var n:int=dst_indexes.size()
	var s:int;var d:int
	if skel_pose:GodotExtension.set_global_transform(dst_root,\
		GodotExtension.get_global_transform(src_root))
	for i in n:
		s=src_indexes[i];d=dst_indexes[i]
		if s<0 or d<0:continue
		dst_root.set_bone_global_pose(d,src_root.get_bone_global_pose(s)*src_poses[i])

func bake_skeleton(a:Array)->void:
	if not _inited:setup_skeleton()
	#
	var n:int=src_indexes.size()
	var c:int=a.size();a.resize(c+1+n)
	a[c]=GodotExtension.get_global_transform(src_root)
	var s:int;var d:int
	c+=1;for i in n:
		s=src_indexes[i];d=dst_indexes[i]
		if s<0:
			if d>=0:a[c+i]=dst_root.get_bone_global_pose(d)
			continue
		a[c+i]=src_root.get_bone_global_pose(s)

func apply_skeleton(a:Array,i:int)->int:
	if not _inited:setup_skeleton()
	#
	var j:int
	if skel_pose:
		if skel_root==null:skel_root=dst_root
		GodotExtension.set_global_transform(skel_root,a[i])
	i+=1;for d in dst_indexes:
		if d>=0:
			dst_root.set_bone_global_pose(d,a[i]*src_poses[j])
			#dst_root.force_update_bone_child_transform(j)
		i+=1;j+=1
	return i

func run()->void:
	if dst_root==null:sync_bones()
	elif src_root!=null:sync_skeleton()

func bake(a:Array)->void:
	if dst_root==null:pass
	else:bake_skeleton(a)

func apply(a:Array,i:int)->int:
	if dst_root==null:return i
	else:return apply_skeleton(a,i)

func _ready()->void:
	if dst_root!=null:
		if dst_paths.is_empty():AnimationExtension.fill_bones(dst_root,dst_paths)
		AnimationExtension.find_bones(dst_root,dst_paths,dst_indexes)
	super._ready()
