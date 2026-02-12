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
func time(a:float,b:float)->float:return duration if duration>=0.0 else (absf(b-a)/-duration)

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

func do_tween(t:Tween,o:Object,c:Callable,a:Variant,b:Variant)->void:
	if t==null or o==null:return
	on_tween(t,o)
	t.tween_method(c,a,b,duration).set_trans(trans).set_ease(ease)

func to_skeleton_modifier_3d(t:Tween,o:SkeletonModifier3D,b:bool,d:float=0.1)->void:
	if t==null or o==null:return
	#
	var f:float=1.0 if b else 0.0
	var tmp:float=duration;duration=time(o.influence,f)
	o.active=true;to_tween(t,o,^"influence",f)
	if d>=0.0:# Has deadzone.
		var a:=func()->void:o.active=o.influence>d
		t.finished.connect(a)
	duration=tmp

func tr_skeleton_modifier_3d(t:Tween,a:SkeletonModifier3D,b:SkeletonModifier3D,c:Callable,d:float=0.1)->void:
	if t==null:return
	#
	current=a;to_skeleton_modifier_3d(t,a,false,d)
	if c.is_null():
		current=b
	else:
		t.chain().tween_callback(c)
		current=null
	to_skeleton_modifier_3d(t,b,true,d)

func to_media_volume(t:Tween,o:Media,v:float)->void:
	if t==null or o==null:return
	#
	var tmp:float=duration;duration=time(o.volume,v)
	to_tween(t,o,^"volume",v)
	if v>0.0:
		if o.volume==v:o.volume=0.0
		if not o.playing:o.play()
	else:
		var cb:=func()->void:if is_zero_approx(o.volume):o.stop()
		t.finished.connect(cb)
	duration=tmp

func tr_media_volume(t:Tween,a:Media,b:Media)->void:
	if t==null:return
	#
	current=a;to_media_volume(t,a,0.0)
	current=b;to_media_volume(t,b,1.0)

func to_mixer(t:Tween,o:BaseMixer,w:float)->void:
	if t==null or o==null:return
	#
	var tmp:float=duration;duration=time(o.weight,w)
	to_tween(t,o,^"weight",w)
	duration=tmp

func tr_mixer(t:Tween,a:BaseMixer,b:BaseMixer,c:Callable)->void:
	if t==null:return
	#
	current=a;to_mixer(t,a,0.0)
	if c.is_null():
		current=b
	else:
		t.chain().tween_callback(c)
		current=null
	to_mixer(t,b,1.0)
