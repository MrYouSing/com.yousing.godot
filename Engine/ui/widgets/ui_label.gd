## A helper class that makes [Label] and [Button] with more formats.
class_name UILabel extends Node

@export_group("Label")
@export_enum("None","File",".Ext","File.Ext")
var type:int
@export var label:Node
@export var texts:PackedStringArray

var model:Variant:
	set(x):render(x);model=x

func render(m:Variant)->void:
	if label==null:return
	var s:String=LangExtension.k_empty_string
	match typeof(m):
		TYPE_BOOL,TYPE_INT,TYPE_FLOAT:
			s=texts[int(m)]
		TYPE_STRING,TYPE_STRING_NAME:
			s=m
			match type:
				1:s=IOExtension.file_name_only(IOExtension.check_path(s))
				2:s=IOExtension.file_extension(IOExtension.check_path(s))
				3:s=IOExtension.file_name(IOExtension.check_path(s))
	label.set(&"text",s)

func _ready()->void:
	if label==null:label=GodotExtension.assign_node(self,"Label")
	render(model)
