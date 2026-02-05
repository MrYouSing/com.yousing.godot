## The abstract class for visual widgets.
class_name AbsGraphic extends Node

@export_group("Graphic")
@export var graphic:Node
@export var model:Variant=null:
	set(x):if x!=model:render(x);model=x

signal rendered()

func clazz()->String:
	return "Control"

func render(m:Variant)->void:
	if graphic==null:return
	if !rendered.has_connections():LangExtension.throw_exception(self,LangExtension.e_not_implemented)
	rendered.emit()

func _ready()->void:
	if graphic==null:graphic=GodotExtension.assign_node(self,clazz())
	render(model)
