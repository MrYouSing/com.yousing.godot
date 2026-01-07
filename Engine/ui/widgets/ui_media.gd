## A [Control] which plays media.
class_name UIMedia extends Node

@export_group("Media")
@export var control:Control
@export var media:Media
@export var clips:Dictionary[StringName,Variant]

var _calls:Dictionary[StringName,Callable]

func _ready()->void:
	if control==null:control=GodotExtension.assign_node(self,"Control")
	if control!=null:
		_calls.clear()
		var c:Callable;for it in clips:
			c=play.bind(clips[it])
			_calls[it]=c;control.connect(it,c)

func _exit_tree()->void:
	if control!=null:
		for it in clips:control.disconnect(it,_calls[it])
		_calls.clear()

func play(v:Variant)->void:
	if media!=null:media.emit(v)
	else:UIManager.instance.play_sound(v)
