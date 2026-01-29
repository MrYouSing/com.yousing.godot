## An advanced [Range] for displaying numbers.
class_name UIRange extends Node

@export_group("Range")
@export var range:Vector3=Vector3(0.0,100.0,0.01)
@export var value:float=100.0:
	set(x):_on_value(value,x);value=x
@export var ranges:Array[Node]
@export var fades:Array[Vector2]
@export var trans:Array[Transition]

var _states:Array[int]
var _values:Array[float]
var _previous:Array[float]
var _events:Array[Callable]

var min_value:float:
	get():return range.x
	set(x):range.x=x;for it in ranges:if it!=null:it.min_value=x

var max_value:float:
	get():return range.y
	set(x):range.y=x;for it in ranges:if it!=null:it.max_value=x

var step:float:
	get():return range.z
	set(x):range.z=x;for it in ranges:if it!=null:it.step=x

func get_mode(o:float,n:float)->int:
	var v:Vector3=range
	if o==n or n<v.x or n>v.y:return -1
	if o<v.x or o>v.y:return 1
	else:return 0

func get_range(i:int)->Node:
	if i>=0 and i<ranges.size():return ranges[i]
	else:return null

func get_state(i:int)->int:
	var r:Node=get_range(i);if r==null:return -1
	if Tweenable.have_tween(r):return _states[i]
	return -1

func set_state(i:int,s:int)->void:
	_states[i]=s
	if s==2:
		var n:float=_values[i]
		if ranges[i].value!=n:tween_to(i,n)

func try_tween(i:int,c:bool)->bool:
	if get_state(i)==1:
		var d:Vector2=fades[i];if c:fades[i].x=0.0
		if d.y>0.0:fades[i].y=-absf(_values[i]-_previous[i])/d.y# Speed mode.
		return true
	return false

func direct_to(i:int,f:float)->void:
	var r:Node=get_range(i);if r==null:return
	_previous[i]=_values[i];_values[i]=f# Range.value
	Tweenable.kill_tween(r);r.value=f

func tween_to(i:int,f:float)->void:
	var r:Node=get_range(i);if r==null:return
	_previous[i]=_values[i];_values[i]=f# Range.value
	var d:Vector2=fades[i];if d.y==0.0:# Instant.
		Tweenable.kill_tween(r);r.value=f;return
	#
	var t:Tween=Tweenable.make_tween(r);var a:Transition=trans[i]
	if d.y<0.0:d.y=absf(f-r.value)/-d.y# Speed mode.
	if d.x>0.0:
		set_state(i,0)
		t.tween_interval(d.x);t.tween_callback(_events[2*i+0])
	else:
		set_state(i,1)
	if a!=null:
		a.delay=0.0;a.duration=d.y
		Transition.current=null;a.to_tween(t,r,^"value",f)
	else:
		t.tween_property(r,^"value",f,d.y)
	t.tween_callback(_events[2*i+1])

## Override it for more behaviours.
func auto_to(i:int,f:float,t:int)->void:
	var r:Node=get_range(i);if r==null:return
	var d:Vector2=fades[i]
	var v:float=r.value;var n:float=_values[i]
	match t:
		0:# Change continually.
			try_tween(i,true);tween_to(i,f)
		-1:# Change directly.
			direct_to(i,f)
		2:# Change from highest.
			if v<n:r.value=n# Snap to highest.
			if try_tween(i,true):# Godot can't add new tweeners into running tween.
				_values[i]=f# Add the trick.
			else:
				tween_to(i,f)
		1,3:# if Wait:Start,Play:Continue,Idle:Direct.
			if try_tween(i,true) or get_state(i)>=0:
				tween_to(i,f)
			else:direct_to(i,f)
	fades[i]=d

func _on_value(o:float,n:float)->void:
	var m:int=get_mode(o,n);if m<0:return
	var v:Vector3=range
	if m==1:
		for i in ranges.size():direct_to(i,n)
	elif o<n:
		auto_to(0,n,0)
		tween_to(1,n)
		direct_to(2,n)
		auto_to(3,n,3)
	else:#o>n
		auto_to(0,n,1)
		tween_to(1,n)
		direct_to(2,n)
		auto_to(3,n,2)

func _ready()->void:
	var v:Vector3=range;var i:int=ranges.size();
	_states.resize(i);_events.resize(2*i)
	_values.resize(i);_previous.resize(i)
	i=-1;for it in ranges:
		i+=1;_states[i]=-1;_values[i]=-1.0;_previous[i]=-1.0
		_events[2*i]=set_state.bind(i,1);_events[2*i+1]=set_state.bind(i,2)
		if it!=null:it.min_value=v.x;it.max_value=v.y;it.step=v.z
	_on_value(v.x-1.0,value)
