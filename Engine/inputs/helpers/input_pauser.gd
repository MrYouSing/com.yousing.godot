## An input helper for game-pause.
class_name InputPauser extends Node

@export_group("Pause")
@export var hide:Input.MouseMode=Input.MOUSE_MODE_CAPTURED
@export var show:Input.MouseMode=Input.MOUSE_MODE_VISIBLE
@export var button:MouseButton=MOUSE_BUTTON_LEFT
@export var keycode:Key=KEY_ESCAPE
@export_flags(
	"Unhandled Input","Resume Previous","Fire Focus","Fire Blur",
)var features:int=0x0F

var _paused:bool
var _mouse:int

func _on_pause(b:bool)->void:
	_paused=b
	var m:int;if b:
		m=show
		if features&0x02!=0:_mouse=Input.mouse_mode
	else:
		if features&0x02!=0:m=_mouse
		else:m=hide
	Input.mouse_mode=m

func _on_input(e:InputEvent)->void:
	if _paused:return
	if PointerInput.on_lock_mouse(e,button,keycode,hide,show):
		if Input.mouse_mode==hide:
			if features&0x04!=0:Application.focus(true)
		else:
			if features&0x08!=0:Application.focus(false)

func _ready()->void:
	var b:bool=features&0x01!=0
	set_process_input(not b);set_process_unhandled_input(b)
	#
	Application.on_pause.connect(_on_pause)

func _exit_tree()->void:
	if GodotExtension.s_reparenting:return
	Application.on_pause.disconnect(_on_pause)

func _input(e:InputEvent)->void:_on_input(e)
func _unhandled_input(e:InputEvent)->void:_on_input(e)
