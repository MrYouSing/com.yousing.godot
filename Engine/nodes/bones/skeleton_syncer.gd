## A tool class for [Skeleton3D] synchronization.
class_name SkeletonSyncer extends Updatable

@export_group("Skeleton")
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

func sync_bones()->void:
	if not _inited:setup_bones()
	var n:int=dst_bones.size()
	var s:Node;var d:Node
	for i in n:
		s=src_bones[i];d=dst_bones[i]
		if s!=null and d!=null:
			d.global_transform=s.global_transform*src_poses[i]

func run()->void:
	if dst_root==null:sync_bones()
	#else:sync_skeleton()

func _ready()->void:
	AnimationExtension.find_bones(dst_root,dst_paths,dst_indexes)
	super._ready()
