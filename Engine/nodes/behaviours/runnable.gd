## The Godot version of [url=https://docs.oracle.com/javase/8/docs/api/java/lang/Runnable.html]Runnable[/url].
class_name Runnable extends Node

@export_group("Run")
@export var target:Node
@export var event:StringName

func run()->void:
	LangExtension.throw_exception(self,LangExtension.e_not_implemented)

func _ready()->void:
	LangExtension.try_signal(target,event,run)

func _exit_tree()->void:
	if GodotExtension.s_reparenting:return
	LangExtension.remove_signal(target,event,run)
