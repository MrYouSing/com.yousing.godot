## Optimized color setter for [Material]s.
class_name ColorRenderer extends Node

static var s_pools:Dictionary[String,Dictionary]

@export_group("Color")
@export var target:Node
@export var color:Color=Color.WHITE:
	set(x):color=x;render(x)

var _material:Material

func get_material(m:Material,c:Color)->Material:
	if m!=null:
		var k:String=m.resource_name
		var v:int=c.to_rgba32()
		if k.is_empty():k=m.resource_path
		#
		if s_pools.has(k):
			var p:Dictionary[int,Object]=s_pools[k]
			if p.has(v):m=p[v];return m
			else:m=m.duplicate();p.set(v,m)
		else:
			var p:Dictionary[int,Object];s_pools[k]=p
			m=m.duplicate();p.set(v,m)
		RenderingExtension.material_set_color(m,0,c)
	return m

func render(c:Color)->void:
	if target==null:
		pass
	elif target is Control:
		target.modulate=c
	elif target is GeometryInstance3D:
		if _material==null:_material=target.material_override
		target.material_override=get_material(_material,c)
	elif target is CanvasItem:
		if _material==null:_material=target.material_override
		target.material_override=get_material(_material,c)
