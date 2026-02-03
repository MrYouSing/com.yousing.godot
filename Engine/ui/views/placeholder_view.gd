## The placeholder view for ui pattern.
class_name PlaceholderView extends Node

@export_group("View")
@export var node:Node
@export var resource:Resource
@export var content:StringName

var _is_inited:bool
var _view:Object

func init()->void:
	if _is_inited:return
	_is_inited=true
	if node!=null:_view=node
	else:_view=resource

var display:Variant:
	get():
		if !_is_inited:init()
		if _view!=null:return _view.get(content)
		return null
	set(x):
		if !_is_inited:init()
		if _view!=null:_view.set(content,x)
