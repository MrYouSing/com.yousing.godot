@tool
class_name CompositeMixer extends BaseMixer

@export_group("Composite")
@export var range:Vector2
@export var mixers:Array[BaseMixer]
@export var remaps:Array[Vector4]

func sample(f:float)->void:
	if !range.is_zero_approx():f=lerpf(range.x,range.y,f)
	var j:int=remaps.size()
	if j==0:
		for it in mixers:
			if it!=null:it.sample(f)
	else:
		var r:Vector4
		var i:int=-1;for it in mixers:
			i+=1;if it!=null:
				if i<j:r=remaps[i]
				it.weight=MathExtension.float_remap(f,r)

func flush(a:Array[float])->void:
	var j:int=a.size();var f:float=weight
	var i:int=-1;for it in mixers:
		i+=1;if i>=j:return
		if it!=null:it.weight=a[i]*f
