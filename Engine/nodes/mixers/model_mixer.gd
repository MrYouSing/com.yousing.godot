## A mixer class that renders model transparency.
class_name ModelMixer extends BaseMixer

@export_group("Model")
@export_range(0.0,1.0,0.001) var cutoff:float=0.5
@export var range:Vector4=Vector4(0.0,1.0,0.0,1.0)
@export var models:Array[Node]
@export var materials:Array[Material]

signal mixed(f:float)

var distance:float:
	set(x):sample(MathExtension.float_remap(x,range));distance=x

func add_model(n:Node)->void:
	if n!=null and not models.has(n):
		models.append(n);_on_add_model(n)

func add_material(m:Material)->Material:
	if m!=null and not materials.has(m):
		m=m.duplicate()
		materials.append(m);_on_add_material(m)
	return m

func sample(f:float)->void:
	for it in materials:
		if it==null:continue
		if _on_mix_material(it,f):continue
		if it is BaseMaterial3D:it.albedo_color=Color(it.albedo_color,f)
		elif it is ShaderMaterial:it.set_shader_parameter(&"alpha",f)
	var b:bool=f>=cutoff
	for it in models:
		if it==null:continue
		if _on_mix_model(it,f):continue
		it.set(&"visible",b)
	mixed.emit(f)

func _on_add_model(n:Node)->void:
	if n==null:
		pass
	elif n is CanvasItem:
		n.material=add_material(n.material)
	elif n is MeshInstance3D:
		var it:Material;var m:Mesh=n.mesh
		for i in n.get_surface_override_material_count():
			it=n.get_surface_override_material(i)
			if it==null:it=m.surface_get_material(i)
			n.set_surface_override_material(i,add_material(it))
	else:
		for it in n.get_children():_on_add_model(it)

func _on_mix_model(n:Node,f:float)->bool:
	return false

func _on_add_material(m:Material)->void:
	if m is BaseMaterial3D:pass
	elif m is ShaderMaterial:pass

func _on_mix_material(m:Material,f:float)->bool:
	return false

func _ready()->void:
	if cutoff<1.0:
		if materials.is_empty():
			for it in models:if it!=null:_on_add_model(it)
		else:
			for it in materials:if it!=null:_on_add_material(it)
	super._ready()
