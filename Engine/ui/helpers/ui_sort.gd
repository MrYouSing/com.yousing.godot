## A helper class for sorting ui z-index.
class_name UISort extends Tickable

@export_group("Sort")
@export var meta:bool
@export var key:StringName
@export var descend:bool
@export_group("UI")
@export var root:Node
@export var nodes:Array[Node]

func compare(a:Object,b:Object)->bool:
	var x:Variant;var y:Variant
	if a!=null:
		if meta:x=a.get_meta(key,-1.0)
		else:x=a.get(key);if x==null:x=-1.0
	if b!=null:
		if meta:y=b.get_meta(key,-1.0)
		else:y=b.get(key);if y==null:y=-1.0
	#
	if x<=y:return not descend
	else:return descend

func _play()->void:
	if root==null:root=self

func _tick()->void:
	var a:Array=LangExtension.k_empty_array
	if nodes.is_empty():a=root.get_children()
	else:a=nodes
	a.sort_custom(compare)
	for it in a:GodotExtension.move_node(it,-1)

func _stop()->void:
	pass
