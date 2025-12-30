## An additional info asset for animator state machines.
class_name AnimatorLayer extends Resource

@export_group("Layer")
@export var name:StringName
@export var weight:StringName
@export var speed:StringName
@export var exit:StringName
@export var exit_times:Dictionary[StringName,Variant]
@export var exit_funcs:Dictionary[StringName,Variant]

var index:int=-1

func get_float(c:Animator,k:StringName)->float:
	if c==null or k.is_empty():return 0.0
	return c.read(k)

func set_float(c:Animator,k:StringName,v:float)->void:
	if c==null or k.is_empty():return
	c.write(k,v)

func tween_float(c:Animator,k:StringName,v:float,a:Tween=null,f:float=0.25,t:Transition=null)->void:
	if c==null or k.is_empty():return
	if a==null:a=Tweenable.hunt_tween(c)
	#
	var m:Callable=func(x)->void:set_float(c,k,x)
	if t==null:a.tween_method(m,get_float(c,k),v,f)
	else:t.do_tween(a,c,m,get_float(c,k),v)

func get_weight(c:Animator)->float:return get_float(c,weight)
func set_weight(c:Animator,v:float)->void:set_float(c,weight,v)
func tween_weight(c:Animator,v:float,a:Tween=null,f:float=0.25,t:Transition=null)->void:tween_float(c,weight,v,a,f,t)

func get_speed(c:Animator)->float:return get_float(c,speed)
func set_speed(c:Animator,v:float)->void:set_float(c,speed,v)
func tween_speed(c:Animator,v:float,a:Tween=null,f:float=0.25,t:Transition=null)->void:tween_float(c,speed,v,a,f,t)
