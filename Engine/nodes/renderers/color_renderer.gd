## Optimized color setter for [Material]s.
class_name ColorRenderer extends Node

static var s_pools:Dictionary[String,Dictionary]

@export_group("Color")
@export var target:Node
@export var color:Color=Color.WHITE:
	set(x):color=x;render(x)

func material(m:Material,c:Color)->Material:
	if m!=null:
		var k:String=m.resource_name
		var v:int=c.to_rgba32()
		if s_pools.has(k):
			var p:Dictionary[int,Object]=s_pools[k]
			if p.has(v):m=p[v];return
			else:m=m.duplicate();p.set(v,m)
		else:
			var p:Dictionary[int,Object];s_pools[k]=p
			m=m.duplicate();p.set(v,m)
		m.set(&"shader_parameter/color",c)
	return m

func render(c:Color)->void:
	if target==null:
		pass
	elif target is Control:
		target.modulate=c
	elif target is GeometryInstance3D:
		var m:Material=target.material_override
		target.material_override=material(m,c)
	elif target is CanvasItem:
		var m:Material=target.material
		target.material=material(m,c)
