## A domain model for ui system.
class_name UIModel extends Resource

@export_group("Database")
@export var category:StringName
@export var dbid:int=-1
@export_group("Model")
var name:StringName:
	get():return get_text(0,resource_name)
@export var icon:Texture2D:
	get():return get_texture(0,icon)
@export var preview:Texture2D:
	get():return get_texture(1,preview)
@export var description:StringName:
	get():return get_text(1,description)

func get_text(i:int,s:StringName)->StringName:
	return TranslationServer.translate(s,category)

func get_texture(i:int,t:Texture2D)->Texture2D:
	return t

func get_text_n(i:int,s:StringName,p:StringName,n:int)->StringName:
	return TranslationServer.translate_plural(s,p,n,category)
