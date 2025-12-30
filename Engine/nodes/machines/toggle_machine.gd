class_name ToggleMachine extends BaseMachine

@export_group("Toggle")
@export var is_on:bool
func toggle(b:bool)->void:_on_toggle(self,b)
@export var threshold:float=0.5

signal on_toggle(c:Object,b:bool)

func _on_dirty()->void:
	on_execute=LangExtension.merge_signal(self,on_execute,on_toggle,targets,&"_on_toggle")
	dirty=false

func _on_toggle(c:Object,b:bool)->void:
	if b==is_on:return
	is_on=b
	#
	if dirty:_on_dirty()
	if threshold<0.0:b=!b
	#
	on_execute.emit(c,b)

# For other systems.

func _on_state(c:Object,k:StringName,v:Variant,t:Transition)->void:
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
				t.to_tween(Tweenable.cast_tween(c),self,^"weight",v)

var weight:float=-1.0:
	set(x):
		weight=x;if x>=0.0:_on_blend(self,x)
	get:
		if weight<0.0:
			if is_on:return 1.0
			else:return 0.0
		return weight

func _on_blend(c:Object,f:float)->void:
	var b:bool=f*f>=threshold*threshold
	_on_toggle(c,b)
