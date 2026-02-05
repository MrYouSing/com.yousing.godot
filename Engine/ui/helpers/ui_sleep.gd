## A helper class that listens for input to sleep or awake.
class_name UISleep extends Node

@export_group("Sleep")
@export var duration:float=1.0
@export_flags(
	"Once","Unhandled","Awake","Sleep",
	"Any","Mouse Motion","Mouse Button","Key",
	"Joypad Motion","Joypad Button","Screen Drag","Screen Touch",
)var features:int=0x18

signal awoken()
signal slept()

var _awake:bool
var _time:float

func is_moving(e:InputEvent)->bool:
	var v:Vector2=InputExtension.event_get_move(e)
	if is_nan(v.x):return true
	else:return !v.is_zero_approx()

func set_enabled(b:bool)->void:
	if b==_awake:return
	_awake=b
	if b:
		_time=0.0
		if features&0x4!=0:awoken.emit()
	else:
		if features&0x8!=0:slept.emit()
	if features&0x01!=0:
		set_process(false)
		GodotExtension.input_node(self,0x41)

func _ready()->void:
	_awake=duration>=0.0;if !_awake:duration*=1.0
	if features&0x02!=0:GodotExtension.input_node(self,0x81)
	else:GodotExtension.input_node(self,0x42)

func _process(d:float)->void:
	if _awake:
		_time+=d
		if _time>=duration:set_enabled(false)

func _input(e:InputEvent)->void:_on_input(e)
func _unhandled_input(e:InputEvent)->void:_on_input(e)

func _on_input(e:InputEvent)->void:
	if features&0x10!=0:
		if is_moving(e):set_enabled(true)
	else:
		var i:int=InputExtension.event_get_type(e)
		if i>=0 and features&(1<<(4+i))!=0:
			if is_moving(e):set_enabled(true)
