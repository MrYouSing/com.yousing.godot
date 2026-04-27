## The base animation for the ui system.
class_name UIAnimation extends Node

@export_group("UI")
@export var event:StringName

signal started()
signal finished()

func play()->void:
	_started()

func stop()->void:
	_finished()

func _started()->void:
	started.emit()

func _finished()->void:
	finished.emit()

func _on_animate(...a:Array)->void:
	match a.size():
		1:if a[0]:play();return
	stop()

func _ready()->void:
	#if process_mode==PROCESS_MODE_INHERIT:
	#	process_mode=Node.PROCESS_MODE_ALWAYS
	if not event.is_empty():
		LangExtension.add_signal(UIManager.instance,event,_on_animate)

func _exit_tree()->void:
	if GodotExtension.s_reparenting:return
	if not event.is_empty() and UIManager.exists:
		LangExtension.remove_signal(UIManager.instance,event,_on_animate)
