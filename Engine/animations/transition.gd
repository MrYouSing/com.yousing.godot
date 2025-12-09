class_name Transition extends Resource

static var current:Object
static var timestamp:int=-1

@export_group("Transition")
@export var from:StringName
@export var to:StringName
@export var delay:float
@export var duration:float=1.0
@export_group("Tween")
@export var trans:Tween.TransitionType
@export var ease:Tween.EaseType
@export var curve:Curve

func instant()->bool:return delay==0.0 and duration==0.0

func to_tween(t:Tween,o:Object,k:NodePath,v:Variant)->void:
	if t==null or o==null:return
	var n:int=Engine.get_process_frames();
	if n!=timestamp:timestamp=n;current=null
	#
	if o==current:t=t.parallel()
	elif delay>0.0:t.tween_interval(delay)
	current=o
	t.tween_property(o,k,v,duration).set_trans(trans).set_ease(ease)

func to_skeleton_modifier_3d(t:Tween,o:SkeletonModifier3D,b:bool)->void:
	if t==null or o==null:return
	#
	var f:float=0.0;if b:f=1.0
	o.active=true;to_tween(t,o,^"influence",f)
	var cb:=func()->void:o.active=o.influence>0.1
	t.finished.connect(cb)
