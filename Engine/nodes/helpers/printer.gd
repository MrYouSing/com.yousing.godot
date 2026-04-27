## A helper class for printing nodes.
@tool
class_name Printer extends Node

static var s_float:String="%4f"

static func print_vec3(v:Vector3)->String:
	return "{\"x\"={0},\"y\"={1},\"z\"={2}}".format([s_float%v.x,s_float%v.y,s_float%v.z])

static func print_transform_3d(v:Transform3D)->String:
	var b:Basis=v.basis
	return "{$(Name) \"T\"={0} \"R\"={1} \"S\"={2}}"\
		.format([print_vec3(v.origin),print_vec3(b.get_euler()),print_vec3(b.get_scale())])

static func print_node_2d(v:Node2D)->String:
	return LangExtension.k_empty_string

static func print_node_3d(v:Node3D)->String:
	if v!=null:return print_transform_3d(v.transform)
	else:return LangExtension.k_empty_string

static func print_skeleton_3d(v:Skeleton3D)->String:
	if v!=null:
		var n:int=v.get_bone_count()
		if n>0:
			var s:String="{$(Name)},\n"
			for i in n:
				s+=print_transform_3d(v.get_bone_pose(i))\
				.replace("$(Name)","\"name\"=\"%s\""%v.get_bone_name(i))+",\n"
			return s.substr(0,s.length()-2)
	return LangExtension.k_empty_string

@export_group("Input")
@export var node:Node
@export var deep:bool
@export var format:String
@export_group("Output")
@export var view:StringName
@export var path:String
@export_tool_button("Tree")var _tree:Callable=func()->void:if node!=null:node.print_tree()
@export_tool_button("Print")var _print:Callable=print

func _on_print(n:Node,t:String)->String:
	match t:
		"Skeleton3D":return print_skeleton_3d(n)
		"Node2D":return print_node_2d(n)
		"Node3D":return print_node_3d(n)
	return LangExtension.k_empty_string

func print_node(n:Node)->String:
	if n!=null:
		var r:String="\"name\"=\"{0}\" \"path\"=\"{1}\"".format([n.name,node.get_path_to(n.get_parent())])
		var t:String=n.get_class();var s:String
		while not t.is_empty():
			s=_on_print(n,t)
			if not s.is_empty():return s.replace("$(Name)",r)
			t=ClassDB.get_parent_class(t)
	return LangExtension.k_empty_string

func print_deep(n:Node)->String:
	var s:String=LangExtension.k_empty_string
	var r:String=print_node(n)
	if not r.is_empty():s=r+",\n"
	for it in n.get_children():
		r=print_deep(it)
		if not r.is_empty():s+=r
	return s

func print()->void:
	if node==null:return
	#
	var s:String=LangExtension.k_empty_string
	var t:String=s_float
	if not format.is_empty():s_float=format
	if deep:s="["+print_deep(node)+"]"
	else:s=print_node(node)
	s_float=t
	#
	if not s.is_empty():
		if not view.is_empty():set(view,s)
		elif not path.is_empty():IOExtension.save_text(path,s)
		else:print(s)

func _process(d:float)->void:
	if not view.is_empty():self.print()
