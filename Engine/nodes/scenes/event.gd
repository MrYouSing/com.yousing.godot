## A helper class for event.
class_name Event extends Node

@export_group("Event")
@export var global:bool
@export var targets:Array[Node]
@export var methods:Array[StringName]

var event:Signal:
	get:
		if event.is_null():
			event=LangExtension.bake_signal(self,self.name,targets,methods)
			for it in get_children():if it is Func:event.connect(it.invoke_with)
		return event

func invoke(...a:Array)->void:
	var e:Signal=event
	if e.has_connections():LangExtension.call_signal(e,a)

func _ready()->void:
	if global:LangExtension.add_signal(Event,name,invoke)
