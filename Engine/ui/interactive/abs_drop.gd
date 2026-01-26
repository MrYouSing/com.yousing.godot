## The abstract control for drag and drop.
class_name AbsDrop extends Control

static var current:AbsDrop

@export_group("Drop")
@export_flags("Drag","Drop")var drop:int=0x3

func in_area(p:Vector2)->bool:
	LangExtension.throw_exception(self,LangExtension.e_not_implemented)
	return false

func is_model(m:Variant)->bool:
	LangExtension.throw_exception(self,LangExtension.e_not_implemented)
	return false

func get_model()->Variant:
	LangExtension.throw_exception(self,LangExtension.e_not_implemented)
	return null

func set_model(m:Variant)->void:
	LangExtension.throw_exception(self,LangExtension.e_not_implemented)

func get_preview(m:Variant,p:Vector2)->Control:
	LangExtension.throw_exception(self,LangExtension.e_not_implemented)
	return null

func wrap_preview(s:Control,d:Control,p:Vector2)->Control:
	var c:Control=Control.new();c.name=&"Dummy";c.add_child(d)
	var t:Vector2=s.get_global_transform_with_canvas().get_scale()
	var q:Vector2=s.size*t;p*=t
	UITransform.set_anchor_and_offset(d,Vector2.ZERO,Vector2.ZERO,-p,q-p)
	return c

func _get_drag_data(p:Vector2)->Variant:
	if drop&0x01!=0:
		var m:Variant=get_model()
		if m!=null:
			var v:Control=get_preview(m,p)
			set_drag_preview(v)
			current=self;return m
	return null

func _can_drop_data(p:Vector2,m:Variant)->bool:
	return drop&0x02!=0 and in_area(p) and is_model(m)

func _drop_data(p:Vector2,m:Variant)->void:
	set_model(m)
