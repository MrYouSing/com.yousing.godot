## A helper class for input device management.
class_name DeviceManager extends Node

static var instances:Array[DeviceManager]=LangExtension.alloc_array(DeviceManager,8)

static func set_device(d:int,m:int=-1)->void:
	var i:int=-1;for it in instances:
		i+=1;if it==null:continue
		if m&(1<<i)!=0:
			it.device=d;it.changed.emit(d)

@export_group("Device")
@export var index:int
@export var device:int=-1

signal changed(i:int)

func _enter_tree()->void:
	if instances[index]==null:instances[index]=self

func _exit_tree()->void:
	if self==instances[index]:instances[index]=null

func _input(e:InputEvent)->void:
	var i:int
	match InputExtension.event_get_type(e):
		1,2,3:i=0
		4,5:i=1
		6,7:i=2
	if i!=device:
		device=i
		changed.emit(i)
