## The Godot version of [url=https://docs.unity3d.com/Documentation/ScriptReference/MonoBehaviour.html]MonoBehaviour[/url].
class_name GDBehaviour extends Node

var _direction:int

func set_enabled(b:bool)->void:
	var d:int=MathExtension.bool_to_sign(b)
	if d==_direction:return
	_direction=d
	#
	if b:_on_enable()
	else:_on_disable()

func _awake()->void:pass
func _start()->void:pass
func _on_destroy()->void:pass
func _on_enable()->void:pass
func _on_disable()->void:pass

func _ready()->void:
	_awake()
	var v:Variant=get(&"visible")
	if v!=null:set_enabled(v)
	else:set_enabled(is_processing())
	_start.call_deferred()

func _exit_tree()->void:
	if GodotExtension.s_reparenting:return
	_on_destroy()
