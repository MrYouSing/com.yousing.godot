## A mixer which modifies by weight.
class_name BaseMixer extends Node

@export_group("Mixer")
@export_range(0.0,1.0,0.001,"or_greater","or_less")
var weight:float=1.0:
	set(x):weight=x;sample(x)

func sample(f:float)->void:
	LangExtension.throw_exception(self,LangExtension.e_not_implemented)

# For other systems.

func _on_blend(c:Object,f:float)->void:
	weight=f
