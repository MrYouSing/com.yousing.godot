class_name InteractTrigger extends BaseTrigger

@export_group("Interact")
@export var interact:Interact
@export var time:Vector3## [x,y] for range,z for lifetime.
@export var triggers:Array[BaseTrigger]

var _mask:int
var _count:int
var _done:float=-1.0
var _time:float=-1.0

var _timestamp:int=-1

func try_update(d:float)->void:
	var n:int=Application.get_frames()
	if n!=_timestamp:
		_timestamp=n
		do_update(d)

func do_update(d:float)->void:
	#
	var m:int=0;var f:int=0
	var t:float=Application.get_time()
	var i=-1;for it in triggers:
		i+=1;if it==null:continue
		f|=(1<<i)
		if it.is_trigger():m|=(1<<i)
	#
	match interact:
		InteractTrigger.Interact.Tap:
			if is_tap(m,d)==3:set_done(t)
		InteractTrigger.Interact.Hold:
			if m==0:clear();return# Off
			elif _mask==0:set_begin(true)# Down
			elif is_begin():_time+=d# On
			if not is_done() and not MathExtension.time_outside(_time,time.x,time.y):
				set_done(t)
		InteractTrigger.Interact.Combine:
			if m!=_mask and m==f:
				set_done(t)
		InteractTrigger.Interact.Repeat:
			if m!=f:
				clear();return
			else:
				if not is_begin():
					set_begin(true);_time=time.x
				else:
					_time-=d
					if _time<=0.0:
						_time+=time.y# Next.
						_count+=1;set_done(t)
		_:
			var n:int=interact-1000
			if not is_done() and _count<n:
				match is_tap(m,d):
					3:# Success.
						_count+=1;
						if _count>=n:set_done(t)
						else:_done=minf(-t,-MathExtension.k_epsilon)# Set done=(-,0)
					-1:# Failure.
						clear();return
					_:# Kill in-active.
						if _count>0 and MathExtension.time_dead(t+_done,time.y):
							clear();return
	#
	_mask=m
	if is_done() and MathExtension.time_dead(t-_done-d,time.z):# Next frame of dead.
		clear()

func clear()->void:
	_mask=0;
	_count=0;
	_done=-1.0;
	_time=-1.0

func is_begin()->bool:return _time>=0.0
func set_begin(b:bool)->void:
	if b:_time=0.0
	else:_time=-1.0
func is_done()->bool:return _done>=0.0
func set_done(t:float)->void:_done=t
func get_progress()->float:
	if is_done():
		if time.z>0.0:
			return (Application.get_time()-_done)/time.z
		return 1.0
	return 0.0

func is_tap(m:int,d:float)->int:
	var b:int=0
	if _mask==0 and m!=0:# Down
		set_begin(true);b=1
	elif _mask!=0 and m==0:# Up
		if not is_begin():pass
		elif MathExtension.time_alive(_time,time.x):b=3
		else:b=-1
		set_begin(false)
	elif is_begin():# On
		_time+=d;b=2
	return b

func is_trigger()->bool:
	try_update(Application.get_delta())
	if is_done():clear();return true# One-shot.
	else:return false

func _process(delta:float)->void:
	try_update(delta)

enum Interact {
	None,
	Tap,
	Hold,
	Repeat,
	Combine,
	Double=1002,
	Triple=1003,
}
