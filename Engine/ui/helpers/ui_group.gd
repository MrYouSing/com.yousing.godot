## A helper class that modifies targets at once.
class_name UIGroup extends Node

@export_group("Group")
@export var targets:Array[Node]
@export var filters:PackedStringArray=["Control"]
@export var settings:Dictionary[StringName,Variant]

func apply(o:Object)->void:
	if o!=null:for k in settings:
		o.set(k,settings[k])

func search(n:Node)->void:
	if n!=null:
		if filters.has(n.get_class()):apply(n)
		for it in n.get_children():search(it)

func flush()->void:
	if targets.is_empty():
		for it in get_children():search(it)
	else:
		for it in targets:apply(it)

func _ready()->void:
	flush()
