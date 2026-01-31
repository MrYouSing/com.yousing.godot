## A singleton class for ui management.
class_name UIManager extends Node
# <!-- Macro.Patch Singleton
const k_keyword:StringName=&"YouSing_UIManager"
const k_class:Variant=UIManager
static var exists:bool:
	get:return Engine.has_singleton(k_keyword)
static var instance:UIManager:
	get:return Singleton.try_instance(k_keyword,k_class)
	set(x):Singleton.set_instance(k_keyword,x)
# Macro.Patch -->
static func register(k:StringName,v:Object)->void:
	if Engine.is_editor_hint():return
	var i:UIManager;if v!=null:i=instance;v.name=k
	else:i=Singleton.get_instance(k_keyword)
	if i!=null:i.set_view(k,v)

@export_group("UI")
@export var root:Node
@export var camera:Node
@export var sound:Media
@export var database:UIDatabase
@export var events:BaseMachine
@export var buttons:Array[StringName]=[
	&"ui_up",&"ui_down",&"ui_left",&"ui_right",
	&"ui_accept",&"ui_cancel",&"ui_menu",&"ui_select",
	&"ui_end",&"ui_home"
]
@export var prefabs:Dictionary[StringName,Resource]
@export_flags(
	"Up Tap","Auto Back","Auto Select","Auto Start",
	"Auto Pause"
)var features:int=-1

var _views:Dictionary[StringName,Object]
var _stack:Array[Object]
var _sounds:Collections.Ring

func _ready()->void:
	if Singleton.init_instance(k_keyword,self):
		if root==null:
			root=self
		if sound==null:
			sound=Audio.create(&"UI",1,self);sound.name=&"Sound"
		_sounds=Collections.Ring.new(get_meta(&"num_sounds",8))
		if database==null:
			if UIDatabase.instance!=null:database=UIDatabase.instance
			else:
				var s:String="res://assets/databases/"+name+".tres"
				database=IOExtension.load_asset(s)
		if events==null:
			events=EventMachine.new();events.name=&"Events"
			GodotExtension.add_node(events,self,false)
		init_ui()

func _exit_tree()->void:
	if Singleton.exit_instance(k_keyword,self):
		Application.exit()

func _process(delta:float)->void:
	if features&0x02!=0 and _stack.size()>1:
		if is_tap(5):
			active_view(peek_view(),false);return
	if features&0x04!=0:
		if is_tap(8):
			show_view(&"App.Select",true)
	if features&0x08!=0:
		if is_tap(9):
			show_view(&"App.Start",true)

func _notification(what:int)->void:
	match what:
		MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN,MainLoop.NOTIFICATION_APPLICATION_RESUMED:
			Application.focus(true)
		MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT:
			Application.focus(false)
		MainLoop.NOTIFICATION_APPLICATION_PAUSED:
			if features&0x10!=0:
				if get_view(&"App.Pause")!=null:_on_pause(true)
			Application.focus(false)

func _on_pause(b:bool)->void:
	Application.pause(b)
	var v:Object=find_view(&"App.Pause",true)
	if v!=null:active_view(v,b)

func _on_quit(b:bool)->void:
	if !b:
		var v:Object=find_view(&"App.Quit",true)
		if v==null:b=true
		else:active_view(v,true)
	if b:Application.quit()

func init_ui()->void:
	var a:Resource;var n:Node;for it in prefabs:
		a=prefabs[it];if a==null:continue
		n=a.instantiate();GodotExtension.add_node(n,root)
		GodotExtension.set_enabled(n,false);n.name=it;set_view(it,n)
	if events is EventMachine:
		events.add_listener(&"App.Pause",_on_pause.bind(true))
		events.add_listener(&"App.Resume",_on_pause.bind(false))
		events.add_listener(&"App.Quit",_on_quit.bind(false))
		events.add_listener(&"App.Exit",_on_quit.bind(true))
	if !prefabs.is_empty():
		flush_view(get_view(prefabs.keys()[0]))

# Get/Set

func get_view(k:StringName,v:Object=null)->Object:
	return _views.get(k,v)

func set_view(k:StringName,v:Object)->void:
	if v==null:_views.erase(k)
	else:_views[k]=v

func peek_view()->Object:
	var n:int=_stack.size()
	return _stack[n-1] if n>0 else null

func pop_view()->Object:
	var n:int=_stack.size()
	return _stack.pop_back() if n>0 else null

func push_view(v:Object)->void:
	if v==null:return
	_stack.push_back(v)

func find_view(k:StringName,b:bool=true)->Object:
	if b:for it in _stack:
		if it!=null and it.name==k:return it
	return get_view(k,null)

# Operations

func active_view(v:Object,b:bool)->void:
	if v==null:return
	if b:GodotExtension.move_node(v,-1)
	GodotExtension.set_enabled(v,b)
	# UI Stack
	var i:int=_stack.rfind(v);if i>=0:_stack.remove_at(i)
	if b:push_view(v)

func flush_view(v:Object)->void:
	for it in _stack:GodotExtension.set_enabled(it,false)
	_stack.clear()
	#for it in _views.values():GodotExtension.set_enabled(it,false)
	if v!=null:active_view(v,true)
	else:_stack.push_back(v)

func show_view(k:StringName,b:bool=true)->void:
	var v:Object=find_view(k,b);if v==null:return
	if b:active_view(v,true)
	else:GodotExtension.move_node(v,-1);GodotExtension.set_enabled(v,true)

func hide_view(k:StringName,b:bool=true)->void:
	var v:Object=find_view(k,b);if v==null:return
	if b:active_view(v,false)
	else:GodotExtension.set_enabled(v,false)

# Misc

func is_hold(i:int)->bool:
	if i<0||i>=buttons.size():return false
	else:return Input.is_action_pressed(buttons[i])

func is_tap(i:int)->bool:
	if i<0||i>=buttons.size():return false
	elif features&0x01!=0:return Input.is_action_just_released(buttons[i])
	else:return Input.is_action_just_pressed(buttons[i])

func set_busy(b:bool)->void:
	if b:LangExtension.begin_busy(self)
	else:LangExtension.end_busy(self)
	set_process(LangExtension.not_busy(self))

## See [url=https://developer.android.google.cn/reference/android/media/SoundPool]SoundPool[/url].
func play_sound(s:Variant)->void:
	var m:Media=_sounds.pop()
	if m==null:m=sound.clone(self,false);_sounds.place(m)
	m.emit(s)

func invoke_event(k:StringName,...args:Array)->void:
	if LangExtension.exist_signal(self,k):LangExtension.send_signal(self,k,args)# From Engine
	if events is EventMachine:events.emit_event(k,args)# From User
