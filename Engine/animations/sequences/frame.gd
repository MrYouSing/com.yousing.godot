class_name Frame extends Resource

@export_group("Frame")
@export var time:float=-1.0
@export var variant:Variant
# For Runtime
var key:StringName
var value:float
var object:Object
var callable:Callable=LangExtension.k_empty_callable

func _set(k:StringName,v:Variant)->bool:
	match k:
		&"$variant":
			variant=str_to_var(v)
			return true
		&"$resource":
			var p:String=v
			if FileAccess.file_exists(p):object=load(p)
			return true
	return false
