## A helper class for barrier questions.
class_name Barrier extends Node

static func circle_point(r:float,f:float)->Vector2:
	f*=2.0*PI
	return Vector2(sin(f)*r,cos(f)*r)

static func rectangle_point(w:float,h:float,f:float)->Vector2:
	if f<=0.25:return Vector2(f*4.0*w,0.0)
	elif f<=0.5:return Vector2(w,(f-0.25)*4.0*h)
	elif f<=0.75:return Vector2((0.75-f)*4.0*w,h)
	else:return Vector2(0.0,(1.0-f)*4.0*h)

@export_group("Barrier")
@export var root:Node
@export var dimensions:Vector3=Vector3.ONE
@export var points:PackedVector2Array
@export var owners:Array[Node]

func release()->void:
	var it:Node
	for i in owners.size():
		it=owners[i];if it!=null:
			if it.has_method(&"_on_point"):it._on_point(MathExtension.k_vec3_nan)
			else:GodotExtension.set_enabled(it,false)
		owners[i]=null

func apply(n:Node,v:Vector3)->bool:
	return false

func build()->void:
	var n:int;var c:bool=dimensions.y==0.0
	if dimensions.z<0.0:
		n=-dimensions.z
	else:
		if c:n=ceili(2.0*PI*dimensions.x/dimensions.z)
		else:n=ceili(2.0*(dimensions.x+dimensions.y)/dimensions.z)
	#
	points.resize(n);var f:float=1.0/n
	if c:
		for i in n:points[i]=circle_point(dimensions.x,i*f)
	else:
		var o:Vector2=Vector2(dimensions.x*-0.5,dimensions.y*-0.5)
		for i in n:points[i]=o+rectangle_point(dimensions.x,dimensions.y,i*f)

func _ready()->void:
	if points.is_empty():build()
	if owners.is_empty():owners.resize(points.size())
