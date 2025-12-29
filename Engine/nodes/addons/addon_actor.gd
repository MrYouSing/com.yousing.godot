## A base class for other add-on systems.
class_name AddonActor extends Node

@export_group("Addon")
@export var context:Node
@export var nodes:Array[Node]

func addon(n:Node)->bool:
	LangExtension.throw_exception(self,LangExtension.e_not_implemented)
	return false

func setup(n:Node)->void:
	LangExtension.throw_exception(self,LangExtension.e_not_implemented)

func teardown(n:Node)->void:
	LangExtension.throw_exception(self,LangExtension.e_not_implemented)

func add(n:Node)->void:
	if addon(n):nodes.append(n)
	for it in get_children():add(it)

func find(k:StringName)->Node:
	for it in nodes:if it!=null and it.name==k:return it
	return null

func _ready()->void:
	if context==null:context=self
	if nodes.is_empty():for it in get_children():add(it)
	#
	for it in nodes:if it!=null:setup(it)

func _exit_tree()->void:
	for it in nodes:if it!=null:teardown(it)
	nodes.clear()
