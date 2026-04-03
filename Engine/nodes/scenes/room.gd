## A helper class for room.
class_name Room extends Node

static var door:Object

@export_group("Room")
@export var index:int
@export var actors:Array[Node]

var _shown:bool

func set_enabled(b:bool)->void:
	if b:show()
	else:hide()

func show()->void:
	if _shown:return
	_shown=true
	#
	var i:int=actors.find(door)
	SaveData.set_int(&"Room",index)
	SaveData.set_int(&"Door",i)
	#
	for it in actors:GodotExtension.set_enabled(it,true)
	_on_show()

func hide()->void:
	if not _shown:return
	_shown=false
	for it in actors:GodotExtension.set_enabled(it,false)
	_on_hide()

func _on_show()->void:
	pass

func _on_hide()->void:
	pass

func _ready()->void:
	#
	var n:Node
	var i:int=-1;for it in actors:
		i+=1;if it!=null:
			n=it.get_node_or_null(^"Main")
			if n!=null:actors[i]=n
	#
	if index==0:_shown=false;show()
	else:_shown=true;hide()
