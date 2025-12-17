class_name BlendMachine extends BaseMachine

@export_group("Blend")
@export var weight:float=1.0
func blend(f:float)->void:_on_blend(thiz,f)
@export var remap:Vector4

var thiz:Object=self
signal on_blend(c:Object,f:float)

func _on_dirty()->void:
	on_execute=LangExtension.merge_signal(self,on_execute,on_blend,targets,&"_on_blend")
	dirty=false

func _on_blend(c:Object,f:float)->void:
	weight=f
	if dirty:_on_dirty()
	#
	if !remap.is_zero_approx():
		f=remap(f,remap.x,remap.y,remap.z,remap.w)
	on_execute.emit(c,f)

# From other systems.

func _on_state(c:Object,k:StringName,v:Variant,t:Transition)->void:
	thiz=self# Revert context.
	match typeof(v):
		TYPE_DICTIONARY:v=v[name]
		TYPE_FLOAT:pass
		_:_on_event(c,k);return
	#
	if t==null or t.instant():
		_on_blend(c,v)
	elif c!=null:
		thiz=c;var tmp:Tween=c.get_tween()
		t.do_tween(tmp,self,&"blend",weight,v)

func _on_toggle(c:Object,b:bool)->void:
	var f:float=0.0;if b:f=1.0
	_on_blend(c,f)
