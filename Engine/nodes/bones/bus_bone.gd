## A bus helper for procedural animations.
@tool
class_name BusBone extends BaseBone

@export_group("Bus")
@export var targets:Array[Node]

var dirty:bool=true
var on_execute:Signal

signal on_bus_modification(c:Skeleton3D,b:int,d:float)

func add_target(t:Node)->void:
	var i:int=targets.find(t);if i>=0:return
	targets.append(t);dirty=true

func remove_target(t:Node)->void:
	var i:int=targets.find(t);if i<0:return
	targets.remove_at(i);dirty=true

func _on_dirty()->void:
	on_execute=LangExtension.merge_signal(self,on_execute,on_bus_modification,targets,&"_on_bus_modification")
	dirty=false

func _on_bus_modification(c:Skeleton3D,b:int,d:float)->void:
	if dirty:_on_dirty()
	#
	on_execute.emit(c,b,d)

func _process_modification_with_delta(delta:float)->void:
	if influence<=0.0 or !active:return
	#
	var c:Skeleton3D=get_skeleton()
	if c!=null:_on_bus_modification(c,bone_index,delta)
