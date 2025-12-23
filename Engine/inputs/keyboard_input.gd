## An input class for keyboard device.
class_name KeyboardInput extends Node

@export_group("Keyboard")
@export var src_keys:Array[Key]
@export var dst_keys:Array[Key]

var old_keys:Array[Key]
var new_keys:Array[Key]

func reload()->void:
	#
	if !src_keys.is_empty() and dst_keys.is_empty():
		dst_keys.append_array(src_keys)
	#
	old_keys.clear()
	new_keys.clear()

var _timestamp:int=-1
func try_update(k:Key)->void:
	#
	if k!=KEY_UNKNOWN and !src_keys.has(k):
		src_keys.append(k);dst_keys.append(k)
	#
	var n:int=Engine.get_process_frames()
	if(n!=_timestamp):
		_timestamp=n
		do_update()

func do_update()->void:
	var tmp:Array=old_keys;old_keys=new_keys;new_keys=tmp;
	new_keys.clear()
	var i:int=-1;for k in src_keys:
		i+=1;if Input.is_key_pressed(k):new_keys.append(dst_keys[i])

func on(k:Key)->bool:
	try_update(k)
	return new_keys.has(k)

func off(k:Key)->bool:
	try_update(k)
	return !new_keys.has(k)

func down(k:Key)->bool:
	try_update(k)
	return !old_keys.has(k) and new_keys.has(k)

func up(k:Key)->bool:
	try_update(k)
	return old_keys.has(k) and !new_keys.has(k)

func _ready()->void:
	reload()

func _process(delta: float)->void:
	try_update(KEY_UNKNOWN)
