## A property mixer,see [method Object.set].
@tool
class_name PropertyMixer extends BaseMixer

@export_group("Property")
@export var target:Node
@export var property:StringName
@export var method:bool
@export_group("Mixer")
@export var from:Variant
@export var to:Variant
@export var curve:Curve

var _callable:Callable=LangExtension.k_empty_callable

func sample(f:float)->void:
	#
	if target==null:return
	if method:
		method=false
		if target.has_method(property):_callable=Callable.create(target,property)
		else:target=null;return
	#
	if curve!=null:f=curve.sample_baked(f)
	#
	var c:Variant
	if typeof(from)==TYPE_QUATERNION:
		c=Basis(from).slerp(Basis(to),f)
	else:c=lerp(from,to,f)
	#
	if _callable.is_valid():_callable.call(c)
	else:target.set(property,c)
