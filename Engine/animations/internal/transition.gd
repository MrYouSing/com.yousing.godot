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

func on_tween(t:Tween,o:Object)->void:
	var n:int=Engine.get_process_frames();
	if n!=timestamp:timestamp=n;current=null
	#
	if o==current:t.parallel()
	elif delay>0.0:t.tween_interval(delay)
	current=o

func to_tween(t:Tween,o:Object,k:NodePath,v:Variant)->void:
	if t==null or o==null:return
	on_tween(t,o)
	t.tween_property(o,k,v,duration).set_trans(trans).set_ease(ease)

func do_tween(t:Tween,o:Object,m:StringName,a:Variant,b:Variant)->void:
	if t==null or o==null:return
	on_tween(t,o)
	t.tween_method(Callable(o,m),a,b,duration).set_trans(trans).set_ease(ease)

func to_skeleton_modifier_3d(t:Tween,o:SkeletonModifier3D,b:bool,d:float=0.1)->void:
	if t==null or o==null:return
	#
	var f:float=0.0;if b:f=1.0
	o.active=true;to_tween(t,o,^"influence",f)
	if d>=0.0:# Has deadzone.
		var a:=func()->void:o.active=o.influence>d
		t.finished.connect(a)

func to_media_volume(t:Tween,o:Media,v:float)->void:
	if t==null or o==null:return
	#
	to_tween(t,o,^"volume",v)
	if v>0.0:
		if o.volume==v:o.volume=0.0
		if !o.playing:o.play()
	else:
		var cb:=func()->void:if is_zero_approx(o.volume):o.stop()
		t.finished.connect(cb)

func tr_media_volume(t:Tween,a:Media,b:Media)->void:
	if t==null:return
	#
	current=a;to_media_volume(t,a,0.0)
	current=b;to_media_volume(t,b,1.0)
