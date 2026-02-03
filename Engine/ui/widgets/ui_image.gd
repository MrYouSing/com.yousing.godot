## A helper class that enables [TextureRect] and [Button] to support more formats.
class_name UIImage extends Node

@export_group("Image")
@export var image:Node
@export var slot:StringName=&"texture"
@export var list:Array[Resource]
@export var dict:Dictionary[StringName,Resource]

var model:Variant:
	set(x):render(x);model=x

func render(m:Variant)->void:
	if image==null:return
	var t:Texture2D=null
	match typeof(m):
		TYPE_BOOL,TYPE_INT,TYPE_FLOAT:
			t=list[int(m)]
		TYPE_STRING,TYPE_STRING_NAME:
			t=dict.get(m,null)
	image.set(slot,t)
