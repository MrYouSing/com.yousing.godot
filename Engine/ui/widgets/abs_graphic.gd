## The abstract class for visual widgets.
@abstract class_name AbsGraphic extends Node

@export_group("Graphic")
@export var graphic:Node
@export var model:Variant:
	set(x):if x!=model:
		if is_node_ready():render(x);changed.emit(x)
		model=x

signal rendered()
signal changed(m:Variant)

@abstract func clazz()->String
@abstract func render(m:Variant)->void

func _ready()->void:
	if graphic==null:graphic=GodotExtension.assign_node(self,clazz())
	var m:Variant=model;render(m);changed.emit(m)

# Messages

func _clicked()->void:
	var m:Variant=model
	match typeof(m):
		TYPE_BOOL:model=!m
		TYPE_INT:model=m+1
		TYPE_FLOAT:model=m+1.0
