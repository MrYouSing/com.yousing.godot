## An event dispatcher for [AnimationNodeStateMachine].
class_name AnimationMachine extends Tickable

@export_group("Animation")
@export var tree:AnimationTree
@export var layer:StringName=&"parameters/playback"
@export_flags("Play","Stop","Event","Blend","Normalized","From","Fade")var mask:int=0x1F
@export var machines:Array[Node]

var _playback:AnimationNodeStateMachinePlayback
var _state:StringName
var _position:float
var _length:float

func _play()->void:
	_state=LangExtension.k_empty_name
	if tree==null:
		tree=GodotExtension.assign_node(self,"AnimationTree")
	if _playback==null and tree!=null:
		_playback=tree.get(layer)
	if mask&0x01!=0:_on_toggle(self,_playback!=null)

func _tick()->void:
	if _playback==null:return
	_position=0.0;_length=-1.0
	var e:StringName;match mask&0xE0:
		0x20:
			e=_playback.get_fading_from_node()
			if not e.is_empty():
				_position=_playback.get_fading_from_play_position()
				_length=_playback.get_fading_from_length()
		0x40:
			e=_playback.get_fading_from_node()
			if not e.is_empty():
				e=e+"->"+_playback.get_current_node()
				_position=_playback.get_fading_position()
				_length=_playback.get_fading_length()
		_:
			e=_playback.get_current_node()
			if not e.is_empty():
				_position=_playback.get_current_play_position()
				_length=_playback.get_current_length()
	var f:float=_position
	if mask&0x10!=0:f/=_length
	if e!=_state:
		_state=e
		if mask&0x04!=0:_on_event(self,e)
	if mask&0x08!=0:_on_blend(self,f)

func _stop()->void:
	if mask&0x02!=0:_on_toggle(self,false)

##signal on_@(c:Object,$:%)
##var do_@:Signal=LangExtension.k_empty_signal
##func _on_@(c:Object,$:%)->void:
##	if do_@.is_null():
##		do_@=LangExtension.bake_signal(self,&"do_@",machines,[&"_on_@"])
##	on_@.emit(c,$)# Engine.
##	do_@.emit(c,$)# User.

signal on_toggle(c:Object,b:bool)
var do_toggle:Signal=LangExtension.k_empty_signal
func _on_toggle(c:Object,b:bool)->void:
	if do_toggle.is_null():
		do_toggle=LangExtension.bake_signal(self,&"do_toggle",machines,[&"_on_toggle"])
	on_toggle.emit(c,b)# Engine.
	do_toggle.emit(c,b)# User.

signal on_blend(c:Object,f:float)
var do_blend:Signal=LangExtension.k_empty_signal
func _on_blend(c:Object,f:float)->void:
	if do_blend.is_null():
		do_blend=LangExtension.bake_signal(self,&"do_blend",machines,[&"_on_blend"])
	on_blend.emit(c,f)# Engine.
	do_blend.emit(c,f)# User.

signal on_event(c:Object,e:StringName)
var do_event:Signal=LangExtension.k_empty_signal
func _on_event(c:Object,e:StringName)->void:
	if do_event.is_null():
		do_event=LangExtension.bake_signal(self,&"do_event",machines,[&"_on_event"])
	on_event.emit(c,e)# Engine.
	do_event.emit(c,e)# User.
