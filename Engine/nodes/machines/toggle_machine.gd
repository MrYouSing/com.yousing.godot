class_name ToggleMachine extends Node

@export var is_on:bool
func set_on(b:bool)->void:_on_toggle(self,b)
@export var threshold:float=0.5
@export var targets:Array[Node]

func _on_toggle(c:Node,b:bool)->void:
	if b==is_on:return
	is_on=b
	# Broadcast downward.
	if threshold<0.0:b=!b
	for it in targets:
		if it!=null and it.has_method(&"_on_toggle"):
			it.call(&"_on_toggle",c,b)


# From other systems.

func _on_state(c:StateMachine,k:StringName,v:Variant,t:Transition)->void:
	if c==null:return
	if typeof(v)==TYPE_DICTIONARY:v=v[&"$ToggleMachine"]
	#
	if t==null or t.instant():
		match typeof(v):
			TYPE_BOOL:_on_toggle(c,v)
			TYPE_FLOAT:_on_blend(c,v)
	else:
		match typeof(v):
			TYPE_BOOL:_on_toggle(c,v)
			TYPE_FLOAT:
				var tmp:Tween=c.get_tween()
				t.to_tween(tmp,self,^"weight",v)

var weight:float=-1.0:
	set(x):
		weight=x;if x>=0.0:_on_blend(self,x)
	get:
		if weight<0.0:
			if is_on:weight=1.0
			else:weight=0.0
		return weight

func _on_blend(c:Node,f:float)->void:
	var b:bool=f>=abs(threshold)
	_on_toggle(c,b)
