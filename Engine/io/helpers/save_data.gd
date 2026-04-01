## A helper class for saving data.
class_name SaveData extends Resource

static var current:SaveData
static var slot:String="save_data_00"

@export_group("Save")
@export var level:String="level_00"
@export var paths:PackedStringArray=["res://assets/texts/saves/%s.json","user://saves/%s.json"]
# <!-- Macro.Patch AutoGen
@export var dict_bool:Dictionary[StringName,bool]

static func get_bool(k:StringName,v:bool)->bool:
	if current!=null:return current.dict_bool.get(k,v)
	else:return Application.get_config().get_value(slot,k,v)

static func set_bool(k:StringName,v:bool)->void:
	if current!=null:current.dict_bool.set(k,v)
	else:Application.get_config().set_value(slot,k,v)

@export var dict_int:Dictionary[StringName,int]

static func get_int(k:StringName,v:int)->int:
	if current!=null:return current.dict_int.get(k,v)
	else:return Application.get_config().get_value(slot,k,v)

static func set_int(k:StringName,v:int)->void:
	if current!=null:current.dict_int.set(k,v)
	else:Application.get_config().set_value(slot,k,v)

@export var dict_float:Dictionary[StringName,float]

static func get_float(k:StringName,v:float)->float:
	if current!=null:return current.dict_float.get(k,v)
	else:return Application.get_config().get_value(slot,k,v)

static func set_float(k:StringName,v:float)->void:
	if current!=null:current.dict_float.set(k,v)
	else:Application.get_config().set_value(slot,k,v)

@export var dict_string:Dictionary[StringName,String]

static func get_string(k:StringName,v:String)->String:
	if current!=null:return current.dict_string.get(k,v)
	else:return Application.get_config().get_value(slot,k,v)

static func set_string(k:StringName,v:String)->void:
	if current!=null:current.dict_string.set(k,v)
	else:Application.get_config().set_value(slot,k,v)

@export var dict_vector:Dictionary[StringName,Vector4]

static func get_vector(k:StringName,v:Vector4)->Vector4:
	if current!=null:return current.dict_vector.get(k,v)
	else:return Application.get_config().get_value(slot,k,v)

static func set_vector(k:StringName,v:Vector4)->void:
	if current!=null:current.dict_vector.set(k,v)
	else:Application.get_config().set_value(slot,k,v)

# Macro.Patch -->

func _on_save(s:String,v:Variant)->void:
	IOExtension.save_json(s,v)

func _on_load(s:String)->Variant:
	return IOExtension.load_json(s)

func save(s:String=LangExtension.k_empty_string)->void:
	if s.is_empty():s=slot
	#
	var m:Dictionary[StringName,Variant]={
		&"level":level,
# <!-- Macro.Patch Save
		&"bool":dict_bool,
		&"int":dict_int,
		&"float":dict_float,
		&"String":dict_string,
		&"Vector4":dict_vector,
# Macro.Patch -->
	}
	_on_save(paths[1]%s,m)

func load(s:String=LangExtension.k_empty_string)->void:
	if s.is_empty():s=slot
	#
	var v:Variant=_on_load(paths[1]%s)
	if v==null:
		v=_on_load(paths[1]%level)
		if v==null:return
	#
	var m:Dictionary=v
# <!-- Macro.Patch Load
	if m.has(&"bool"):dict_bool.assign(m.bool)
	else:dict_bool.clear()
	if m.has(&"int"):dict_int.assign(m.int)
	else:dict_int.clear()
	if m.has(&"float"):dict_float.assign(m.float)
	else:dict_float.clear()
	if m.has(&"String"):dict_string.assign(m.String)
	else:dict_string.clear()
	if m.has(&"Vector4"):dict_vector.assign(m.Vector4)
	else:dict_vector.clear()
# Macro.Patch -->
