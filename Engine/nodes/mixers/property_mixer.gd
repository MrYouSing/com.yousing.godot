## A property mixer,see [method Object.set].
@tool
class_name PropertyMixer extends BaseMixer

@export_group("Property")
@export var target:Node
@export var property:StringName
@export var call:bool
@export_group("Mixer")
@export var from:Variant
@export var to:Variant
@export var curve:Curve

func sample(f:float)->void:
	if target==null:return
	if curve!=null:f=curve.sample_baked(f)
	#
	var c:Variant
	if typeof(from)==TYPE_QUATERNION:
		c=Basis(from).slerp(Basis(to),f)
	else:c=lerp(from,to,f)
	#
	if call and target.has_method(property):
		target.call(property,c)
	else:
		target.set(property,c)
