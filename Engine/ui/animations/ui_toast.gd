## A [url=https://developer.android.google.cn/reference/android/widget/Toast]Toast[/url] implementation for Godot.
class_name UIToast extends UIAnimation

static var s_time_short:float=2.0
static var s_time_long:float=3.5

@export_group("Toast")
@export var view:Node
@export var label:Node

var _call:int=Juggler.k_invalid_id
var _kill:Callable

func _ready()->void:
	if view==null:view=GodotExtension.assign_node(self,"Node2D")
	if label==null:label=GodotExtension.assign_node(self,"Label")
	super._ready()

func make_text(s:String,t:float,c:Callable)->void:
	Juggler.try_kill(self)
	if s.is_empty():stop();return
	#
	play();_kill=c
	GodotExtension.set_enabled(view,true)
	if label!=null:label.text=s
	if t<0.0:
		if is_equal_approx(t,-2.0):t=s_time_long
		else:t=s_time_short
	if t>0.0:_call=Juggler.instance.delay_call(stop,LangExtension.k_empty_array,t,1)

func stop()->void:
	Juggler.try_kill(self)
	#
	GodotExtension.set_enabled(view,false)
	if not _kill.is_null():_kill.call()
	_kill=LangExtension.k_empty_callable
	#
	super.stop()

func _on_animate(...a:Array)->void:
	match a.size():
		3:make_text(a[0],a[1],a[2])
		_:stop()
