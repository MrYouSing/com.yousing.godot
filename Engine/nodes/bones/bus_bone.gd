## A bus helper for procedural animations.
@tool
class_name BusBone extends BaseBone

@export_group("Bus")
@export var targets:Array[Node]

var dirty:bool=true
var on_execute:Signal

signal on_update(c:Skeleton3D,b:int,d:float)

func add_target(t:Node)->void:
	var i:int=targets.find(t);if i>=0:return
	targets.append(t);dirty=true

func remove_target(t:Node)->void:
	var i:int=targets.find(t);if i<0:return
	targets.remove_at(i);dirty=true

func _on_dirty()->void:
	on_execute=LangExtension.merge_signal(self,on_execute,on_update,targets,&"_on_update")
	dirty=false

func _on_update(c:Skeleton3D,b:int,d:float)->void:
	if dirty:_on_dirty()
	#
	on_execute.emit(c,b,d)
