## An input class for pointer devices that supports [InputEventMouse] or [InputEventScreenTouch].
class_name PointerInput extends Node

const k_buttons:PackedStringArray=[
"MOUSE_BUTTON_LEFT",
"MOUSE_BUTTON_RIGHT",
"MOUSE_BUTTON_MIDDLE",
"MOUSE_BUTTON_WHEEL_UP",
"MOUSE_BUTTON_WHEEL_DOWN",
"MOUSE_BUTTON_WHEEL_LEFT",
"MOUSE_BUTTON_WHEEL_RIGHT",
"MOUSE_BUTTON_XBUTTON1",
"MOUSE_BUTTON_XBUTTON2",
]

static var current:PointerInput

static func get_mouse_position(i:int)->Vector2:
	var o:Vector2i;match i:
		DisplayServer.MAIN_WINDOW_ID:o=DisplayServer.window_get_position()
		-DisplayServer.SCREEN_OF_MAIN_WINDOW:o=DisplayServer.window_get_position()+DisplayServer.screen_get_position(DisplayServer.SCREEN_PRIMARY)
		_:o=DisplayServer.screen_get_position(i)
	return DisplayServer.mouse_get_position()-o

static func on_lock_mouse(e:InputEvent,b:int,k:int)->bool:
	if e is InputEventMouseButton:
		if e.button_index==b and e.pressed:
			Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
			return true
	elif e is InputEventKey:
		if e.physical_keycode==k:
			Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
			return true
	return false

@export_group("Pointer")
@export_flags(
	"Non-emulated Touch","Mouse to Touch","Non-emulated Mouse","Touch to Mouse",
	"Unhandled","Native Mouse","Lock Mouse","Mouse To Stick"
)var features:int=0:
	set(x):features=x;if is_node_ready():_featured()
@export var capacity:int=10
@export var stick:int=-1

var input:PlayerInput
var mouse:PointerEvent
var pointers:Array[PointerEvent]

func _featured()->void:
	InputExtension.set_is_on(Input,&"emulate_touch_from_mouse",features)
	InputExtension.set_is_on(Input,&"emulate_mouse_from_touch",features>>2)
	var b:bool=features&0x10!=0;set_process_input(!b);set_process_unhandled_input(b)
	if features&0x40!=0:Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
	else:Input.mouse_mode=Input.MOUSE_MODE_VISIBLE

func _ready()->void:
	mouse=PointerEvent.new();mouse.index=-1
	pointers=LangExtension.new_array(PointerEvent,capacity)
	var i:int=-1;for it in pointers:i+=1;it.index=i
	_featured()
	if features&0x80!=0:if input==null:input=PlayerInput.current
	#
	if current==null:current=self

func _exit_tree()->void:
	if self==current:current=null

func _process(d:float)->void:
	get_mouse()
	if stick>=0:_on_stick()

func _input(e:InputEvent)->void:_on_input(e)
func _unhandled_input(e:InputEvent)->void:_on_input(e)

func _on_input(e:InputEvent)->void:
	if e is InputEventScreenTouch:
		var p:PointerEvent=pointers[e.index]
		p.touch(e,e.position,e.pressed and !e.canceled,e.double_tap)
	elif e is InputEventScreenDrag:
		var p:PointerEvent=pointers[e.index]
		p.drag(e,e.position,e.pressure)
	elif e is InputEventMouseButton:
		if features&0x20!=0:return
		var p:PointerEvent=get_mouse()
		p.touch(e,e.position,true,e.double_click)
	elif e is InputEventMouseMotion:
		if features&0x20!=0:return
		var p:PointerEvent=get_mouse()
		p.drag(e,e.position,e.pressure)

func _on_stick()->void:
	if features&0x40!=0:
		if Input.mouse_mode==Input.MOUSE_MODE_CAPTURED:# On Focus
			if Input.is_key_pressed(KEY_ESCAPE):Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
		else:# On Blur
			if mouse_down(0):Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
	if features&0x80!=0:
		if input==null:input=PlayerInput.current
		if input!=null:
			var v:Vector2=Input.get_last_mouse_velocity()*InputExtension.s_mouse_to_stick
			if !v.is_zero_approx():input.try_update();input.m_axes[stick]=v

func set_enabled(b:bool)->void:
	set_process(b)
	if features&0x10!=0:set_process_input(false);set_process_unhandled_input(b)
	else:set_process_input(b);set_process_unhandled_input(false)
	#
	if !b:
		if mouse!=null:mouse.clear()
		for it in pointers:if it!=null:it.clear()

func get_touches(a:Array[PointerEvent])->int:
	var i:int=0
	for it in pointers:if it.press>=0:a.append(it);i+=1
	return i

func get_mouse()->PointerEvent:
	if Application.get_frames()!=mouse.timestamp:
		if features&0x20!=0:mouse.drag(null,get_mouse_position(DisplayServer.MAIN_WINDOW_ID),0.0)
		mouse.button(null,Input.get_mouse_button_mask())
	return mouse

func get_pointer(i:int)->PointerEvent:
	if i<0:return get_mouse()
	else:return pointers[i]

func mouse_position()->Vector2:
	return get_mouse().position

func mouse_on(i:int)->bool:
	var m:PointerEvent=get_mouse()
	return m.buttons&(1<<i)!=0

func mouse_off(i:int)->bool:
	var m:PointerEvent=get_mouse()
	return m.buttons&(1<<i)==0

func mouse_down(i:int)->bool:
	var m:PointerEvent=get_mouse()
	return m.previous&(1<<i)==0 and m.buttons&(1<<i)!=0

func mouse_up(i:int)->bool:
	var m:PointerEvent=get_mouse()
	return m.previous&(1<<i)!=0 and m.buttons&(1<<i)==0

class PointerEvent:
	var index:int
	var position:Vector2=MathExtension.k_vec2_nan
	var pressure:float
	#
	var timestamp:int=-1
	var press:int=-1
	var release:int=-1
	var twice:int=-1
	# For Mouse
	var buttons:int
	var previous:int

	func clear()->void:
		#
		position=MathExtension.k_vec2_nan
		pressure=0.0
		timestamp=-1
		press=-1
		release=-1
		twice=-1
		buttons=0
		previous=0

	func touch(e:InputEvent,p:Vector2,b:bool,d:bool)->void:
		var n:int=Application.get_frames()#+1
		#
		if press>=0:# On
			if !b:# Up
				press=-1;release=n
		else:# Off
			if b:# Down
				press=n;release=-1
		#
		position=p
		if d:twice=n
		timestamp=n

	func drag(e:InputEvent,p:Vector2,f:float)->void:
		var n:int=Application.get_frames()#+1
		#
		position=p;pressure=f
		timestamp=n

	func button(e:InputEvent,b:int)->void:
		var n:int=Application.get_frames()#+1
		#
		press=n
		previous=buttons;buttons=b
		timestamp=n

	func on()->bool:
		return press>=0

	func off()->bool:
		return press<0

	func down()->bool:
		return press==Application.get_frames()

	func up()->bool:
		return release==Application.get_frames()

	func double()->bool:
		return twice==Application.get_frames()
