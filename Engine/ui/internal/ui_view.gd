## The base visual widget for ui system.
class_name UIView extends Node

@export_group("View")
@export var path:StringName
@export var model:Resource:
	set(x):if x!=model:
		model=x;dirty=true
		if is_node_ready():render()

var dirty:bool

func render():
	if not dirty:return
	dirty=false
	#
	LangExtension.throw_exception(self,LangExtension.e_not_implemented)

func dispose()->void:
	if not path.is_empty():UIManager.register(path,null)

func _ready()->void:
	if not path.is_empty():UIManager.register(path,self)
	if dirty:render()

func _exit_tree()->void:
	dispose()
