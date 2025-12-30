## A helper mixer for [method MeshInstance3D.set_blend_shape_value].
@tool
class_name MorphMixer extends BaseMixer

@export_group("Morph")
@export var shape:StringName:
	set(x):if Engine.is_editor_hint() and x!=shape:shape=x;shapes.clear()
@export var targets:Array[MeshInstance3D]
@export var shapes:Array[int]

func is_valid()->bool:
	var i:int=0
	for it in targets:
		i+=1;if it==null:return false
	for it in shapes:
		i+=1;if it<0:return false
	return i>0

func sample(f:float)->void:
	if shapes.is_empty():
		for it in targets:
			if it==null:shapes.append(-1)
			else:shapes.append(it.find_blend_shape_by_name(shape))
	#
	var j:int
	var i:int=-1;for it in targets:
		i+=1;if it==null:continue
		j=shapes[i];if j<0:continue
		#
		it.set_blend_shape_value(j,f)
