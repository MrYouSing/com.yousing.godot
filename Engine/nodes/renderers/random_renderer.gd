## A renderer that draws objects randomly.
class_name RandomRenderer extends Node

@export_group("Random")
@export var nodes:Array[Node]
@export var paths:Array[NodePath]
@export var from:Array[Variant]
@export var to:Array[Variant]

signal drawn()

var _call:int=Juggler.k_invalid_id

func draw()->void:
	Juggler.try_kill(self)
	self.set(&"visible",true)
	#
	var it:Node;var n:Node
	for i in nodes.size():
		it=nodes[i];if it!=null:n=it
		n.set_indexed(paths[i],lerp(from[i],to[i],randf()))
	drawn.emit()

func erase()->void:
	_call=Juggler.k_invalid_id
	self.set(&"visible",false)

func set_enabled(b:bool)->void:
	if b:draw()

func _set(k:StringName,v: Variant)->bool:
	match k:
		&"sleep":
			_call=Juggler.instance.delay_call(erase,LangExtension.k_empty_array,v)
			return true
	return false

func _ready()->void:
	if get(&"visible")==true:draw()
