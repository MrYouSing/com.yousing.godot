## A helper class for fading.
class_name FadeRenderer extends Node

@export_group("Fade")
@export var view:Node
@export var mixer:Node
@export var fade:Vector4=Vector4(0.0,0.25,-1.0,0.25)## x:Delay,y:In,z:Duration,w:Out.

signal started()
signal finished()
signal entered()
signal exited()

var _call:int=Juggler.k_invalid_id
var _version:int
var _time:Vector2=Vector2(-1.0,-1.0)

var range:Vector2:
	get():
		var f:float=fade.z;if f>=0.0:f+=fade.x+fade.y
		return Vector2(fade.x,f)
	set(x):
		fade.x=x.x
		if x.y>0.0:fade.z=x.y-fade.x-fade.y
		else:fade.z=-1.0

func get_time(b:bool=false)->float:
	var f:float=_time.y if b else _time.x
	var t:float=Application.get_time()
	if f>=0:return t-f
	else:return -1.0

func set_enabled(b:bool)->void:
	if b:
		if _time.x<0.0:_on_run(fade.x,_on_show)
	else:
		if _time.x>=0.0:_on_run(0.0,_on_exit)

func _on_run(f:float,c:Callable)->void:
	# Clean up
	Juggler.try_kill(self);_version+=1
	if mixer!=null:
		if mixer.has_method(&"stop"):mixer.stop()
		else:Tweenable.kill_tween(mixer)
	# Run it
	if not c.is_valid():return
	if is_zero_approx(f):c.call()
	elif f>0.0:_call=Juggler.instance.delay_call(c,LangExtension.k_empty_array,f)

func _on_mix(f:float,b:bool,c:Callable)->void:
	if mixer==null:_on_run(f,c);return
	_on_run(0.0,LangExtension.k_empty_callable)
	#
	mixer.set(&"delay",0.0);mixer.set(&"duration",f)
	if b:mixer.set(&"in_delay",0.0);mixer.set(&"in_duration",f)
	else:mixer.set(&"out_delay",0.0);mixer.set(&"out_duration",f)
	#
	var d:Object=LangExtension.defer_call(c,self,&"_version",false)
	LangExtension.try_signal(mixer,&"finished",d.invoke_pass,CONNECT_ONE_SHOT)
	GodotExtension.set_enabled(mixer,b)

func _on_show()->void:
	_time=Vector2(Application.get_time(),-1.0)
	GodotExtension.set_enabled(view,true)
	#
	started.emit()
	_on_mix(fade.y,true,_on_enter)

func _on_enter()->void:
	_time.y=Application.get_time()
	#
	entered.emit()
	_on_run(fade.z,_on_exit)

func _on_exit()->void:
	exited.emit()
	_on_mix(fade.w,false,_on_hide)
	#
	_time.y=-1.0

func _on_hide()->void:
	finished.emit()
	#
	GodotExtension.set_enabled(view,false)
	_time=Vector2(-1.0,-1.0)
