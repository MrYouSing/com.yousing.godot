## The base renderer for drawing curves.
class_name CurveRenderer extends Node

@export_group("Curve")
@export var root:Node
@export var world:bool
@export var node:Node
@export var resource:Resource

func count()->int:
	if node!=null:return node.count()
	elif resource!=null:return 1+ceili(resource.get_baked_length()/resource.bake_interval)
	return 0

func length()->float:
	if node!=null:return node.length()
	elif resource!=null:return resource.get_baked_length()
	return 0.0

func get_points_2d()->PackedVector2Array:
	if node!=null:return node.points()
	elif resource!=null:return resource.get_baked_points()
	return LangExtension.k_empty_array

func get_points_3d()->PackedVector3Array:
	if node!=null:return node.points()
	elif resource!=null:return resource.get_baked_points()
	return LangExtension.k_empty_array

func clear()->void:
	pass

func draw()->void:
	clear()
	#
	if root==null:pass
	elif root is Node3D:_on_3d()
	else:_on_2d()

func _on_2d()->void:
	var p:PackedVector2Array=get_points_2d();var n:int=p.size()
	if n>=2:
		if world:
			var m:Transform2D=root.global_transform
			var a:Vector2=m*p[0];var b:Vector2
			_begin_2d(a)
			n-=1;for i in n:b=m*p[1+i];_draw_2d(a,b);a=b
			_end_2d(b)
		else:
			var a:Vector2=p[0];var b:Vector2
			_begin_2d(a)
			n-=1;for i in n:b=p[1+i];_draw_2d(a,b);a=b
			_end_2d(b)

func _begin_2d(v:Vector2)->void:
	LangExtension.throw_exception(self,LangExtension.e_not_implemented)

func _draw_2d(a:Vector2,b:Vector2)->void:
	LangExtension.throw_exception(self,LangExtension.e_not_implemented)

func _end_2d(v:Vector2)->void:
	LangExtension.throw_exception(self,LangExtension.e_not_implemented)

func _on_3d()->void:
	var p:PackedVector3Array=get_points_3d();var n:int=p.size()
	if n>=2:
		if world:
			var m:Transform3D=root.global_transform
			var a:Vector3=m*p[0];var b:Vector3
			_begin_3d(a)
			n-=1;for i in n:b=m*p[1+i];_draw_3d(a,b);a=b
			_end_3d(b)
		else:
			var a:Vector3=p[0];var b:Vector3
			_begin_3d(a)
			n-=1;for i in n:b=p[1+i];_draw_3d(a,b);a=b
			_end_3d(b)

func _begin_3d(v:Vector3)->void:
	LangExtension.throw_exception(self,LangExtension.e_not_implemented)

func _draw_3d(a:Vector3,b:Vector3)->void:
	LangExtension.throw_exception(self,LangExtension.e_not_implemented)

func _end_3d(v:Vector3)->void:
	LangExtension.throw_exception(self,LangExtension.e_not_implemented)

func _ready()->void:
	if root==null:root=GodotExtension.assign_node(self,"Node3D")
	draw()
