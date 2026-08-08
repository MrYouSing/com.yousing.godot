## A helper class that maintains visual thickness via [Material] UV transformations.
class_name RingRenderer extends Updatable

@export_group("Ring")
@export var source:Node
@export var dimensions:Vector3=Vector3(0.1,1.0,1.0)## x for thickness,y for full-size,z for output.
@export var destination:Node
@export var slot:int
@export var material:Material
@export var property:StringName
@export var matrix_x:Vector3=Vector3(1.0,0.0,0.0)
@export var matrix_y:Vector3=Vector3(0.0,1.0,0.0)

func get_ring()->float:
	var f:float=dimensions.y
	if source!=null:
		f*=GodotExtension.get_global_basis(source).get_scale().x
	return f

func set_ring(f:float)->void:
	if material==null:return
	var v:Vector2=Vector2(f,0.0)
	v=MathExtension.mat_mul_vec2(matrix_x,matrix_y,v)
	material.set(property,v)

func run()->void:
	var f:float=get_ring()
	set_ring(MathExtension.float_divide(dimensions.x,f))

func _ready()->void:
	if destination!=null:
		if material==null:
			material=RenderingExtension.get_material(destination,true,slot)
		else:
			material=material.duplicate()
			RenderingExtension.set_material(destination,material,slot)
	super._ready()
