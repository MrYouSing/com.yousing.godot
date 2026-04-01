## A helper class for level.
class_name Level extends Node

@export_group("Level")
@export var actors:Array[Node]
@export var points:PackedVector3Array
@export var rooms:Array[Room]

var _room:int
var room:Room:
	get():return rooms[_room]
	set(x):
		_room=rooms.find(x)
		if _room<0:_room=rooms.size();x.index=_room;rooms.append(x)

func load()->void:
	var i:int=SaveData.get_int(&"Room",0)
	var j:int=SaveData.get_int(&"Door",-1);if j<0:j=0
	var r:Room=rooms[i];if r==null:return
	var d:Node=r.actors[j];if d==null:return
	#
	if _room!=i:
		rooms[_room].hide();rooms[i].show()
	_room=i
	#
	var t:Transform3D=GodotExtension.get_global_transform(d)
	var v:Vector3=t.basis*Vector3.MODEL_FRONT;var p:Vector3
	j=points.size()
	i=-1;for it in actors:
		i+=1;if it==null:continue
		if i<j:p=points[i]
		GodotExtension.set_global_position(it,t*p)
		GodotExtension.set_global_rotation(it,NAN,v)

func _enter_tree()->void:
	var i:int=-1;for it in rooms:
		i+=1;if it!=null:it.index=i

func _ready()->void:
	self.load()
