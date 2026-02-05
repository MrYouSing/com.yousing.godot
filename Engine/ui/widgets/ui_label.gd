## A helper class that enables [Label] and [Button] to support more formats.
class_name UILabel extends AbsGraphic

@export_group("Label")
@export_enum("None","File",".Ext","File.Ext")
var type:int
@export var rect:Node
@export var label:Node
@export var texts:PackedStringArray

var progress:float:
	get():
		if rect!=null:return rect.value
		if label!=null:return label.visible_ratio
		return 0.0
	set(x):
		if rect!=null:
			rect.value=x
			return
		if label!=null:
			if x<0.0:label.visible_characters=-x
			else:label.visible_ratio=x
			return

func clazz()->String:
	return "Label"

func render(m:Variant)->void:
	if graphic==null:return
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
	graphic.set(&"text",s)
	if label!=null:label.set(&"text",s)
	rendered.emit()
