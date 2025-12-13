## The base class for machine system.
class_name BaseMachine extends Node

@export_group("Machine")
@export var targets:Array[Node]

var dirty:bool=true
var on_execute:Signal

func add_target(t:Node)->void:
	var i:int=targets.find(t);if i>=0:return
	targets.append(t);dirty=true

func remove_target(t:Node)->void:
	var i:int=targets.find(t);if i<0:return
	targets.remove_at(i);dirty=true

func _on_dirty()->void:
	LangExtension.throw_exception(self,LangExtension.e_not_implemented)

func _on_state(c:Object,k:StringName,v:Variant,t:Transition)->void:
	LangExtension.throw_exception(self,LangExtension.e_not_implemented)

func _on_toggle(c:Object,b:bool)->void:
	LangExtension.throw_exception(self,LangExtension.e_not_implemented)

func _on_blend(c:Object,f:float)->void:
	LangExtension.throw_exception(self,LangExtension.e_not_implemented)

func _on_event(c:Object,e:StringName)->void:
	LangExtension.throw_exception(self,LangExtension.e_not_implemented)
