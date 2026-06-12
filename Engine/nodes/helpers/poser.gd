## The helper class for switching [Transform2D] and [Transform3D].
@tool
class_name Poser extends Node

@export_group("Pose")
@export var target:Node
@export var property:StringName=&"transform"
@export var index:int
@export var path:String
@export var names:PackedStringArray
@export var poses:Array
@export_tool_button("Save") var _save:Callable=func()->void:
	if target==null:return
	elif index>=0:poses[index]=target.get(property)
	else:poses.append(target.get(property))
	GodotExtension.editor_dirty(self)
@export_tool_button("Load") var _load:Callable=func()->void:
	seek(index)
	GodotExtension.editor_dirty(self)

func seek(i:int)->void:
	index=i;if i>=poses.size():return
	if target!=null:target.set(property,poses[i])

func open(s:String)->void:
	var i:int=names.find(s)
	if i>=0:seek(i)

func _ready()->void:
	if Engine.is_editor_hint():return
	#
	if target==null:
		target=GodotExtension.assign_node(self,"Node3D")
	if not path.is_empty():
		names.clear();poses.clear()
		var a:Array[Pose]=Asset.make_array(path,Pose)
		if target is Node2D:
			for it in a:names.append(it.name);poses.append(it.to_2d())
		elif target is Node3D:
			for it in a:names.append(it.name);poses.append(it.to_3d())
	if index>=0:seek(index)

class Pose:
	var name:String
	var T:Vector3
	var R:Quaternion
	var E:Vector3
	var S:Vector3

	func to_2d()->Transform2D:
		return Transform2D((R.x+E.x)*MathExtension.k_deg_to_rad,Vector2(S.x,S.y),E.y,Vector2(T.x,T.y))

	func to_3d()->Transform3D:
		if not E.is_zero_approx():R=Quaternion.from_euler(E*MathExtension.k_deg_to_rad)
		return Transform3D(Basis(R).scaled_local(S),T)

	func _set(k:StringName,v:Variant)->bool:
		match k:
			&"tx":T.x=float(v);return true
			&"ty":T.y=float(v);return true
			&"tz":T.z=float(v);return true
			&"r",&"rx":R.x=float(v);return true
			&"ry":R.y=float(v);return true
			&"rz":R.z=float(v);return true
			&"rw":R.w=float(v);return true
			&"e",&"ex":E.x=float(v);return true
			&"ey":E.y=float(v);return true
			&"ez":E.z=float(v);return true
			&"sx":S.x=float(v);return true
			&"sy":S.y=float(v);return true
			&"sz":S.z=float(v);return true
			&"s":S=Vector3.ONE*float(v);return true
			&"k":E.y=float(v);return true
		return false
