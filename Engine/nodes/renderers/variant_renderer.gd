## A variant renderer that depends on keywords.
class_name VariantRenderer extends Node

static var s_keywords:Dictionary[StringName,StringName]={&"Default":&"Default"}

@export_group("Variant")
@export var keyword:StringName=&"Default"
@export var nodes:Array[Node]

var _node:Node

func set_enabled(b:bool)->void:
	GodotExtension.set_enabled(_node,b)

func select(k:StringName)->void:
	for it in nodes:
		if it==null:continue
		if k==it.name:_node=it;GodotExtension.set_enabled(it,true)
		else:GodotExtension.set_enabled(it,false)

func draw()->void:
	if _node!=null:if _node.has_method(&"draw"):_node.draw()

func _on_spawn()->void:
	if _node!=null:if _node.has_method(&"_on_spawn"):_node._on_spawn()

func _on_despawn()->void:
	if _node!=null:if _node.has_method(&"_on_despawn"):_node._on_despawn()

func _enter_tree()->void:
	if is_node_ready():return
	var k:StringName=s_keywords.get(keyword,LangExtension.k_empty_name)
	select(k)
