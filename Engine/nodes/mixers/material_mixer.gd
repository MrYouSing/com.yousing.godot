## A helper mixer for [Material]s.
class_name MaterialMixer extends BaseMixer

@export_group("Material")
@export var property:String=&"shader_parameter/weight"
@export var materials:Array[Material]
@export var slot:int
@export var nodes:Array[Node]
@export_group("Mixer")
@export var from:Variant
@export var to:Variant
@export var curve:Curve

var _shown:bool

var material:Material:
	get():
		if materials.is_empty():return null
		else:return materials[0]
	set(x):
		if materials.is_empty():materials.append(x)
		else:materials[0]=x
		if _shown:_shown=false;set_enabled(true)

func set_enabled(b:bool)->void:
	if b==_shown:return
	_shown=b
	if slot>=-1:return
	var m:Material=material
	#
	for it in nodes:
		if it==null:continue
		RenderingExtension.set_material(it,m,slot)

func sample(f:float)->void:
	if curve!=null:f=curve.sample_baked(f)
	var v:Variant=lerp(from,to,f)
	_set(property,v)
	set_enabled(not is_zero_approx(f))

func _set(k:StringName,v:Variant)->bool:
	for it in materials:
		if it==null:continue
		it.set(k,v)
	return true

func _ready()->void:
	if slot>=0:
		for it in nodes:
			if it==null:continue
			materials.append(RenderingExtension.get_material(it,true,slot))
	elif slot==-1:
		for it in nodes:
			if it==null:continue
			RenderingExtension.get_materials(materials,it,true)
	super._ready()
