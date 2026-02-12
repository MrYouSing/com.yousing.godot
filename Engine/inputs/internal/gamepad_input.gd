## An input class for the gamepad devices.
class_name GamepadInput extends Node

const k_axes:Dictionary[StringName,int]={
&"JOY_AXIS_INVALID":-1,
&"JOY_AXIS_LEFT_X":0,
&"JOY_AXIS_LEFT_Y":1,
&"JOY_AXIS_RIGHT_X":2,
&"JOY_AXIS_RIGHT_Y":3,
&"JOY_AXIS_TRIGGER_LEFT":4,
&"JOY_AXIS_TRIGGER_RIGHT":5,
&"JOY_AXIS_SDL_MAX":6,
&"JOY_AXIS_MAX":10,
}
const k_buttons:Dictionary[StringName,int]={
&"JOY_BUTTON_INVALID":-1,
&"JOY_BUTTON_A":0,
&"JOY_BUTTON_B":1,
&"JOY_BUTTON_X":2,
&"JOY_BUTTON_Y":3,
&"JOY_BUTTON_BACK":4,
&"JOY_BUTTON_GUIDE":5,
&"JOY_BUTTON_START":6,
&"JOY_BUTTON_LEFT_STICK":7,
&"JOY_BUTTON_RIGHT_STICK":8,
&"JOY_BUTTON_LEFT_SHOULDER":9,
&"JOY_BUTTON_RIGHT_SHOULDER":10,
&"JOY_BUTTON_DPAD_UP":11,
&"JOY_BUTTON_DPAD_DOWN":12,
&"JOY_BUTTON_DPAD_LEFT":13,
&"JOY_BUTTON_DPAD_RIGHT":14,
&"JOY_BUTTON_MISC1":15,
&"JOY_BUTTON_PADDLE1":16,
&"JOY_BUTTON_PADDLE2":17,
&"JOY_BUTTON_PADDLE3":18,
&"JOY_BUTTON_PADDLE4":19,
&"JOY_BUTTON_TOUCHPAD":20,
&"JOY_BUTTON_SDL_MAX":21,
&"JOY_BUTTON_MAX":128,
}

static var current:GamepadInput
static var instances:Array[GamepadInput]=LangExtension.alloc_array(GamepadInput,JOY_AXIS_MAX)

@export_group("Gamepad")
@export var device:int=-1
@export_flags(
	"Virtual","Vibrate","Unhandled","Handled",
)var features:int:
	set(x):features=x;if is_node_ready():_featured()

var _timestamp:int=-1
var _axes:Array[float]=LangExtension.alloc_array(TYPE_FLOAT,JOY_AXIS_MAX)
var _buttons:int
var _previous:int

func clear()->void:
	_timestamp=-1;_buttons=0;_previous=0
	for i in _axes.size():_axes[i]=0.0

func vibrate(v:Vector3)->void:
	if features&0x02==0:
		pass
	elif device>=0:
		if v.is_zero_approx():Input.stop_joy_vibration(device)
		else:Input.start_joy_vibration(device,v.x,v.y,v.z)
	else:
		if not v.is_zero_approx():
			Input.vibrate_handheld(maxf(v.z,0.1)*1000,(v.x+v.y)*0.5)

func try_update()->void:
	var n:int=Application.get_frames()
	if n!=_timestamp:
		_timestamp=n
		do_update()

func do_update()->void:
	_previous=_buttons

func axis(i:int)->float:
	try_update()
	return _axes[i]

func stick(i:int)->Vector2:
	try_update()
	i*=2;return Vector2(_axes[i],_axes[i+1])

func on(i:int)->bool:
	try_update()
	i=1<<i;return _buttons&i!=0

func off(i:int)->bool:
	try_update()
	i=1<<i;return _buttons&i==0

func down(i:int)->bool:
	try_update()
	i=1<<i;return _previous&i==0 and _buttons&i!=0

func up(i:int)->bool:
	try_update()
	i=1<<i;return _previous&i!=0 and _buttons&i==0

func _featured()->void:
	var a:bool=features&0x01==0
	var b:bool=features&0x04!=0
	set_process(a)
	set_process_input(a and not b)
	set_process_unhandled_input(a and b)

func _ready()->void:
	_featured()
	#
	if device>=0:
		if instances[device]==null:instances[device]=self
		return
	if current==null:current=self

func _exit_tree()->void:
	device=instances.find(self)
	if device>=0:
		if self==instances[device]:instances[device]=null
		return
	if self==current:current=null

func _input(e:InputEvent)->void:_on_input(e)
func _unhandled_input(e:InputEvent)->void:_on_input(e)

func _on_input(e:InputEvent)->void:
	var b:bool=false
	if e is InputEventJoypadMotion:
		if device<0 or device==e.device:
			_axes[e.axis]=e.axis_value
			b=true
	elif e is InputEventJoypadButton:
		if device<0 or device==e.device:
			if e.pressed:_buttons|=(1<<e.button_index)
			else:_buttons&=~(1<<e.button_index)
			b=true
	if b:
		try_update()
		if features&0x08!=0:get_viewport().set_input_as_handled()

func _process(d:float)->void:
	try_update()
