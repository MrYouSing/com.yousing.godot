## A helper class that enables [TextureRect] and [Button] to support more formats.
class_name UIImage extends AbsGraphic

@export_group("Image")
@export var slot:StringName=&"texture"
@export var list:Array[Resource]
@export var dict:Dictionary[StringName,Resource]
@export var tooltips:Array[StringName]

func clazz()->String:
	return "TextureRect"

func render(m:Variant)->void:
	if graphic==null:return
	var t:Texture2D=null
	match typeof(m):
		TYPE_NIL:return
		TYPE_BOOL,TYPE_INT,TYPE_FLOAT:
			var i:int=int(m)%list.size();t=list[i]
			if !tooltips.is_empty():graphic.set(&"tooltip_text",tooltips[i])
		TYPE_STRING,TYPE_STRING_NAME:
			t=dict.get(m,null)
	graphic.set(slot,t)
	rendered.emit()
