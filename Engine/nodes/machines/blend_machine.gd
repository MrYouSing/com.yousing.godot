class_name BlendMachine extends BaseMachine

@export_group("Blend")
@export var weight:float=1.0:
	set(x):weight=x;_on_blend(self,weight)
@export var remap:Vector4

signal on_blend(c:Object,f:float)

func _on_dirty()->void:
	on_execute=LangExtension.merge_signal(self,on_execute,on_blend,targets,&"_on_blend")
	dirty=false

func _on_blend(c:Object,f:float)->void:
	if dirty:_on_dirty()
	#
	if !remap.is_zero_approx():
		f=remap(f,remap.x,remap.y,remap.z,remap.w)
	on_execute.emit(c,f)

# From other systems.

func _on_state(c:Object,k:StringName,v:Variant,t:Transition)->void:
	if c==null:return
	if typeof(v)==TYPE_DICTIONARY:v=v[&"$BlendMachine"]
	#
	if t==null or t.instant():
		_on_blend(c,v)
	else:
		var tmp:Tween=c.get_tween()
		t.to_tween(tmp,self,^"weight",v)

func _on_toggle(c:Object,b:bool)->void:
	var f:float=0.0;if b:f=1.0
	_on_blend(c,f)
