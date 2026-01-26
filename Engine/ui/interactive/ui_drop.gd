## A drag-and-drop for model-view pattern.
class_name UIDrop extends AbsDrop

@export_group("Drop")
@export var model:Resource
@export var view:Node
@export var preview:Node

func in_area(p:Vector2)->bool:
	return true

func is_model(m:Variant)->bool:
	if model!=null:
		var r:Resource=m
		if r==null:return false
		return r.get_class()==model.get_class()
	else:
		return true

func get_model()->Variant:
	return model

func set_model(m:Variant)->void:
	var r:Resource=m
	if r!=null:
		var d:AbsDrop=current;current=null
		if d!=null:d.set_model(model)
		model=r
		if view!=null:
			if r is Texture2D:view.set(&"texture",r)
			else:view.set(&"model",r)

func get_preview(m:Variant,p:Vector2)->Control:
	var c:Control
	if preview!=null:
		c=preview.duplicate()
		c.model=m
	else:
		var r:Object=m;var t:Texture2D
		if r.is_class("Texture2D"):t=r
		else:t=r.get(&"icon")
		if t!=null:
			c=TextureRect.new()
			c.texture=t
		else:
			c=ColorRect.new()
	return wrap_preview(view,c,p)

func _ready()->void:
	if view==null:view=GodotExtension.assign_node(self,"Control")
	if model==null:model=view.get(&"texture")
