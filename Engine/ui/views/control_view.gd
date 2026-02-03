## A view implementation with godot [Control]s for MVVM.
class_name ControlView extends UIView

static var s_is_inited:bool

func init_static()->void:
	if s_is_inited:return
	s_is_inited=true
	#
	var e:StringName=LangExtension.k_empty_name
	# bool
	ViewModel.register_binder(&"BaseButton",&"button_pressed",&"toggled",&"set_pressed_no_signal")
	ViewModel.register_binder(&"Node.bool",&"visible",&"visibility_changed",e)
	# Number
	ViewModel.register_binder(&"OptionButton",&"selected",&"item_selected",e)
	ViewModel.register_binder(&"Range",&"value",&"value_changed",&"set_value_no_signal")
	ViewModel.register_binder(&"Range.min",&"min_value",&"changed",e)
	ViewModel.register_binder(&"Range.max",&"max_value",&"changed",e)
	ViewModel.register_binder(&"UIOption",&"value",&"value_changed",e)
	ViewModel.register_binder(&"UIList",&"selection",&"selected",e)
	ViewModel.register_binder(&"Media.float",&"volume",e,e)
	ViewModel.register_binder(&"Media.progress",&"progress",e,e)
	# String
	ViewModel.register_binder(&"Label",&"text",e,e)
	ViewModel.register_binder(&"TextEdit",&"text",&"text_changed",e)
	ViewModel.register_binder(&"BaseButton.String",&"text",e,e)
	ViewModel.register_binder(&"BaseButton.StringName",&"text",e,e)
	ViewModel.register_binder(&"FileDialog",e,&"file_selected",e)
	ViewModel.register_binder(&"UILabel",&"model",e,e)
	ViewModel.register_binder(&"UIDialog",e,&"on_complete",e)
	ViewModel.register_binder(&"UIPlaylist",&"url",e,e)
	ViewModel.register_binder(&"Media",&"url",e,e)
	# Graphic
	ViewModel.register_binder(&"CanvasItem",&"modulate",e,e)
	ViewModel.register_binder(&"ColorRect.Color",&"color",e,e)
	ViewModel.register_binder(&"ColorPickerButton.Color",&"color",&"color_changed",e)
	ViewModel.register_binder(&"TextureRect",&"texture",e,e)
	ViewModel.register_binder(&"BaseButton.Object",&"icon",e,e)
	ViewModel.register_binder(&"VideoStreamPlayer",&"stream",e,e)
	ViewModel.register_binder(&"UIImage",&"model",e,e)
	# Pattern
	ViewModel.register_binder(&"UIView",&"model",e,e)
	ViewModel.register_binder(&"PlaceholderView",&"display",e,e)
	# Event
	ViewModel.register_binder(&"UIButton.Callable",&"callback",e,e)
	# Sub-classes
	ViewModel.inherit_binder(&"Node.bool",&"CanvasItem.bool")
	ViewModel.inherit_binder(&"Range",&"AbsRange",&"UIRange")
	ViewModel.inherit_binder(
		&"Range.max",&"AbsRange.max",&"UIRange.max",
		&"Range.length",&"AbsRange.length",&"UIRange.length",
		&"Range.duration",&"AbsRange.duration",&"UIRange.duration",
		&"ListModel.length"
	)
	ViewModel.inherit_binder(&"UIOption",&"UIMenu")
	ViewModel.inherit_binder(&"Label",&"RichTextLabel")
	ViewModel.inherit_binder(&"TextEdit",&"LineEdit")
	ViewModel.inherit_binder(&"TextureRect",&"NinePatchRect")
	ViewModel.inherit_binder(&"VideoStreamPlayer",&"Media.Object")

@export_group("MVVM")
@export var view_model:ViewModel

var _stub:ViewModel.Stub

func render()->void:
	if !dirty:return
	if view_model==null:return
	dirty=false
	if !s_is_inited:init_static()
	#
	if _stub==null:_stub=view_model.setup(model,self)
	elif model!=_stub.model:_stub.model=model
	else:_stub.refresh()
	GodotExtension.set_enabled(self,_stub!=null and model!=null)

func dispose()->void:
	super.dispose()
	if _stub!=null:_stub.dispose();_stub=null

func _get(k:StringName)->Variant:
	if _stub==null:return null
	return _stub._get(k)

func _set(k:StringName,v:Variant)->bool:
	if _stub==null:return false
	return _stub._set(k,v)
