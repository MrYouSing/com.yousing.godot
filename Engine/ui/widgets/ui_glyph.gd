## A graphic version of [Button].
class_name UIGlyph extends AbsGraphic

@export_group("Glyph")
@export var union:bool=true
@export var label:Node
@export var image:Node
@export var scales:PackedFloat32Array

var text:String:
	get():
		if label!=null:return label.text
		elif graphic!=null:return graphic.text
		return LangExtension.k_empty_string
	set(x):
		render(x)

var icon:Texture:
	get():
		if image!=null:return image.texture
		elif graphic!=null:return graphic.icon
		return null
	set(x):
		render(x)

func get_scale(i:int)->float:
	var n:int=scales.size()
	if n>0:
		if i>=n:i=n-1
		return scales[i]
	return 1.0

func clazz()->String:
	return "Button"

func render(m:Variant)->void:
	match typeof(m):
		TYPE_STRING,TYPE_STRING_NAME:
			if union:GodotExtension.set_enabled(image,false)
			if label!=null:
				var s:String=m
				UIExtension.set_text(label,s)
				label.scale=Vector2.ONE*get_scale(s.length())
			elif graphic!=null:
				graphic.set(&"text",m)
				if union:graphic.set(&"icon",null)
		TYPE_OBJECT:
			if union:GodotExtension.set_enabled(label,false)
			if image!=null:
				UIExtension.set_texture(image,m)
			elif graphic!=null:
				if union:graphic.set(&"text",LangExtension.k_empty_string)
				graphic.set(&"icon",m)
		_:
			GodotExtension.set_enabled(image,false)
			GodotExtension.set_enabled(label,false)
			if graphic!=null:
				graphic.set(&"text",LangExtension.k_empty_string)
				graphic.set(&"icon",null)
	rendered.emit()

func _ready()->void:
	if graphic==null:graphic=GodotExtension.assign_node(self,clazz())
	if graphic==self:graphic=null
	var m:Variant=model;render(m);changed.emit(m)
