## A helper class for game pause.
class_name UIPause extends Node

@export_group("Pause")
@export var view:Node
@export var views:Array[Node]

func set_enabled(b:bool)->void:
	var n:Node=self if view==null else view
	if n.get_meta(&"game_pause",true):Application.pause(b)
	for it in views:GodotExtension.set_enabled(it,b)

func _changed()->void:
	if view.has_method(&"is_visible_in_tree"):set_enabled(view.is_visible_in_tree())
	else:set_enabled(view.visible)

func _ready()->void:
	var m:ProcessMode=PROCESS_MODE_WHEN_PAUSED
	for it in views:if it!=null:it.process_mode=m
	if view!=null:view.process_mode=m
	#
	GodotExtension.set_enabled(view,false)
	LangExtension.try_signal(view,&"visibility_changed",_changed)

func _exit_tree()->void:
	if GodotExtension.s_reparenting:return
	LangExtension.remove_signal(view,&"visibility_changed",_changed)
