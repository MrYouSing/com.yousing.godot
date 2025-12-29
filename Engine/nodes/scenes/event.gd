## A helper class for event.
class_name Event extends Node

@export var targets:Array[Node]
@export var methods:Array[StringName]

var event:Signal:
	get:
		if event.is_null():
			event=LangExtension.bake_signal(self,self.name,targets,methods)
			for it in get_children():if it is Func:event.connect(it.invoke_with)
		return event

func invoke(...args:Array)->void:
	var e:Signal=event
	if !e.is_null() and e.has_connections():e.emit(args)
