## A runtime injector for [Input] and [InputMap].
class_name InputInjector extends Node

static var current:InputInjector

@export_group("Injector")
@export var path:StringName

var _last:StringName
var _map:Array[Entry]
var _temp:Entry
var _callback:Callable

func clear(b:bool=false)->void:
	if b:
		InputMap.load_from_project_settings()
	else:
		for it in _map:if it!=null and it.event!=null:
			InputMap.action_erase_event(it.path,it.event)
	_map.clear()

func inject(p:StringName)->void:
	var t:Array[PackedStringArray]=Asset.load_table(p)
	if !t.is_empty():
		clear(true)
		LangExtension.array_add_table(_map,t,Entry)
		for it in _map:register(it)

func best(e:Entry)->Entry:
	if e!=null:
		var c:ConfigFile=Application.get_config();var k:String=e.name
		if c.has_section_key("Input",k):
			if _temp==null:_temp=Entry.new()
			var m:Dictionary=JSON.parse_string(c.get_value("Input",k,"{}"))
			_temp.copy_from(e);LangExtension.map_to_object(m,_temp)
			e=_temp
	return e

func text(e:Entry)->String:
	if e!=null:
		var v:float=0.0;var d:int=e.device
		if e.type==Type.GamepadMotion:v=signf(e.value)
		#elif e.type!=Type.GamepadButton:d=-1
		return "{\"$type\":\"{0}\",\"device\":\"{1}\",\"$index\":\"{2}\",\"value\":\"{3}\"}".format([e.get_type(),d,e.get_index(),v])
	return LangExtension.k_empty_string

func event(e:Entry)->InputEvent:
	var r:InputEvent
	if e!=null:
		e=best(e);match e.type:
			Type.MouseButton:
				var i:InputEventMouseButton=e.cast_event(e.type)
				i.button_index=1+e.index
				i.button_mask=1<<e.index
				r=i
			Type.Keyboard:
				var i:InputEventKey=e.cast_event(e.type)
				i.keycode=e.index
				r=i
			Type.GamepadMotion:
				var i:InputEventJoypadMotion=e.cast_event(e.type)
				i.axis=e.index
				i.axis_value=e.value
				r=i
			Type.GamepadButton:
				var i:InputEventJoypadButton=e.cast_event(e.type)
				i.button_index=e.index
				r=i
	if r!=null:r.device=e.device
	return r

func entry(e:InputEvent)->Entry:
	if e!=null:var i:int=InputExtension.event_get_type(e);if i>=0 and i<Type.Count:
		if _temp==null:_temp=Entry.new()
		_temp.path=LangExtension.s_none_string;_temp.type=i
		_temp.device=e.device;_temp.index=InputExtension.event_get_index(e,i)
		_temp.value=event_to_value(e,i);_temp.deadzone=-1.0
		_temp.name=LangExtension.k_empty_string;_temp.event=e
		return _temp
	return null

func register(e:Entry)->void:
	if e==null:return
	# Action
	var k:StringName=e.path
	if k.is_empty():k=_last;e.path=k
	else:_last=k
	# Event
	if e.event==null:
		e.event=event(e)
		if e.event==null:return
	# Input
	if !InputMap.has_action(k):InputMap.add_action(k)
	if e.deadzone>=0.0:InputMap.action_set_deadzone(k,e.deadzone)
	InputMap.action_add_event(k,e.event)

func listen(c:Callable)->void:
	_callback=c
	set_process_input(c.is_valid())

func _ready()->void:
	set_process_input(false)
	if !path.is_empty():inject(path)
	#
	if current==null:current=self

func _exit_tree()->void:
	if self==current:current=null

func _input(e:InputEvent)->void:
	var i:Entry=entry(e)
	if i!=null:
		var b:bool=true
		if _callback.is_valid():b=_callback.call(e,i)
		if b:
			listen(LangExtension.k_empty_callable)
			get_viewport().set_input_as_handled()

enum Type {
	None,
	MouseMotion,
	MouseButton,
	Keyboard,
	GamepadMotion,
	GamepadButton,
	Count,
}

static func type_to_device(i:Type)->StringName:
	match i:
		Type.MouseMotion,Type.MouseButton:return &"Mouse"
		Type.Keyboard:return &"Keyboard"
		Type.GamepadMotion,Type.GamepadButton:return &"Gamepad"
		_:return &"Unknown"

static func event_to_value(e:InputEvent,i:Type)->float:
	var v:Variant=InputExtension.event_get_value(e,i)
	if v!=null:
		match typeof(v):
			TYPE_BOOL:return 1.0 if v else 0.0
			TYPE_VECTOR2:return v.x*1E4+v.y
		return v
	return 0.0

class Entry:
	var path:StringName
	var type:int
	var device:int=-1
	var index:int
	var value:float
	var deadzone:float=-1.0
	var name:String:
		get():
			if name.is_empty():
				return InputInjector.type_to_device(type)+"."+path
			return name
	var event:InputEvent

	func copy_from(e:Entry)->void:
		if e==null:return
		self.path=e.path
		self.type=e.type
		self.device=e.device
		self.index=e.index
		self.value=e.value
		self.deadzone=e.deadzone
		self.name=e.name
		self.event=e.event

	func cast_event(t:Type)->InputEvent:
		if event!=null:
			if InputExtension.event_get_type(event)==t:return event
			else:event=null
		return InputExtension.event_new_input(t)

	func get_type()->String:
		return LangExtension.enum_to_str(type,Type)

	func get_index()->String:
		var i:int=index;if type==Type.MouseButton:i-=1
		return LangExtension.enum_to_str(i,InputExtension.event_get_enum(type))

	func _set(k:StringName,v:Variant)->bool:
		match k:
			&"$type":
				type=LangExtension.str_to_enum(v,Type)
				return true
			&"$index":
				index=LangExtension.str_to_enum(v,InputExtension.event_get_enum(type))
				return true
		return false

	func _to_string()->String:
		return "{0}:P={1} T={2} I={3} K={4} V={5} D={6}".format([name,path,get_type(),device,get_index(),value,deadzone])
