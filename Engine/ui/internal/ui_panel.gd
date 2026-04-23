## A container class for ui system.
class_name UIPanel extends Actor

@export_group("Panel")
@export var path:StringName
@export var canvas:Node
@export var mixer:Node

var _shown:bool

var busy:bool:
	get=is_busy,set=set_busy
func is_busy()->bool:
	if busy:return mixer!=null and Tweenable.find_tween(mixer)!=null
	else:return false
func set_busy(b:bool)->void:
	busy=b;if not b and mixer!=null:Tweenable.kill_tween(mixer)
	if get_meta(&"global_busy",false):UIManager.instance.set_busy(b)

func get_enabled()->bool:
	return _shown

func set_enabled(b:bool)->void:
	_shown=b;if busy:return
	#
	if mixer!=null:GodotExtension.set_enabled(mixer,b)
	else:super.set_enabled(_shown)

func get_config(k:StringName,v:Variant)->Variant:
	return Application.get_config().get_value(name,k,v)

func set_config(k:StringName,v:Variant)->void:
	Application.get_config().set_value(name,k,v);Application.try_flush()

func render_view(v:Node,m:Variant)->void:
	if v!=null:
		if v.get_script()==null:
			match typeof(m):
				TYPE_BOOL,TYPE_INT,TYPE_FLOAT:
					if v is BaseButton:v.button_pressed=bool(m);return
				TYPE_STRING,TYPE_STRING_NAME:
					UIExtension.set_text(v,m);return
				TYPE_OBJECT:
					if m is Texture:UIExtension.set_texture(v,m);return
		v.set(&"model",m)

func _mixer_started(b:bool)->void:
	busy=true
	if b:super.set_enabled(b);GodotExtension.set_enabled(canvas,b)

func _mixer_finished(b:bool)->void:
	busy=false
	if b!=_shown:set_enabled(_shown)
	elif not b:super.set_enabled(b);GodotExtension.set_enabled(canvas,b)

func _ready()->void:
	if canvas==null:canvas=GodotExtension.assign_node(self,"CanvasItem")
	LangExtension.try_signal(mixer,&"started",_mixer_started)
	LangExtension.try_signal(mixer,&"finished",_mixer_finished)
	if not path.is_empty():UIManager.register(path,self)

func _exit_tree()->void:
	if GodotExtension.s_reparenting:return
	if not path.is_empty():UIManager.register(path,null)
