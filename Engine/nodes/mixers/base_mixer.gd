## A mixer which modifies by weight.
class_name BaseMixer extends Node

@export_group("Mixer")
@export_range(0.0,1.0,0.001,"or_greater","or_less")
var weight:float=1.0:
	get:return clampf(weight,0.0,1.0)
	set(x):sample(x);weight=x

func sample(f:float)->void:
	LangExtension.throw_exception(self,LangExtension.e_not_implemented)

func _ready()->void:
	if weight>=0.0 and weight<=1.0:sample(weight)# At least once.

# For other systems.

func _on_blend(c:Object,f:float)->void:
	weight=f
