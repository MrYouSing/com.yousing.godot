## A [url=https://developer.android.google.cn/reference/android/widget/Toast]Toast[/url] implementation for Godot.
class_name UIToast extends Node

static var s_time_short:float=2.0
static var s_time_long:float=3.5

@export_group("Toast")
@export var event:StringName
@export var view:Node
@export var label:Node

var _call:int=-1
var _kill:Callable

func _ready()->void:
	if view==null:view=GodotExtension.assign_node(self,"Node2D")
	if label==null:label=GodotExtension.assign_node(self,"Label")
	if not event.is_empty():
		LangExtension.add_signal(UIManager.instance,event,make_text)

func _exit_tree()->void:
	if not event.is_empty() and UIManager.exists:
		LangExtension.remove_signal(UIManager.instance,event,make_text)

func stop_call()->void:
	Juggler.instance.kill_call(_call)
	_call=Juggler.k_invalid_id

func make_text(s:String,t:float,c:Callable)->void:
	stop_call()
	if s.is_empty():kill_text();return
	#
	GodotExtension.set_enabled(view,true)
	_kill=c
	if label!=null:label.text=s
	if t<0.0:
		if is_equal_approx(t,-2.0):t=s_time_long
		else:t=s_time_short
	if t>0.0:_call=Juggler.instance.delay_call(kill_text,LangExtension.k_empty_array,t,1)

func kill_text()->void:
	stop_call()
	#
	GodotExtension.set_enabled(view,false)
	if not _kill.is_null():_kill.call()
	_kill=LangExtension.k_empty_callable
