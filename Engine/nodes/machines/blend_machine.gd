class_name BlendMachine extends Node

@export var weight:float=1.0:
	set(x):weight=x;_on_blend(self,weight)
@export var remap:Vector4
@export var targets:Array[Node]

func _on_blend(c:Node,f:float)->void:
	if !remap.is_zero_approx():
		f=remap(f,remap.x,remap.y,remap.z,remap.w)
	for it in targets:
		if it!=null and it.has_method(&"_on_blend"):
			it.call(&"_on_blend",c,f)

# From other systems.

func _on_state(c:StateMachine,k:StringName,v:Variant,t:Transition)->void:
	if c==null:return
	if typeof(v)==TYPE_DICTIONARY:v=v[&"$BlendMachine"]
	#
	if t==null or t.instant():
		_on_blend(c,v)
	else:
		var tmp:Tween=c.get_tween()
		t.to_tween(tmp,self,^"weight",v)

func _on_toggle(c:Node,b:bool)->void:
	var f:float=0.0;if b:f=1.0
	_on_blend(c,f)
