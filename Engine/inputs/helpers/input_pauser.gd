## An input helper for game-pause.
class_name InputPauser extends Node

@export_group("Pause")
@export var hide:Input.MouseMode=Input.MOUSE_MODE_CAPTURED
@export var show:Input.MouseMode=Input.MOUSE_MODE_VISIBLE
@export var button:MouseButton=MOUSE_BUTTON_LEFT
@export var keycode:Key=KEY_ESCAPE

var _paused:bool
var _mouse:int

func _on_pause(b:bool)->void:
	_paused=b
	if b:_mouse=Input.mouse_mode;Input.mouse_mode=show
	else:Input.mouse_mode=_mouse

func _ready()->void:
	Application.on_pause.connect(_on_pause)

func _exit_tree()->void:
	if GodotExtension.s_reparenting:return
	Application.on_pause.disconnect(_on_pause)

func _unhandled_input(e:InputEvent)->void:
	if _paused:return
	PointerInput.on_lock_mouse(e,button,keycode,hide,show)
