## A widget which performs as a button with [url=https://docs.unity3d.com/ScriptReference/GUIContent.html]GUIContent[/url].
class_name UIButton extends UIView

@export_group("Button")
@export var button:Button
@export var label:Control
@export var image:TextureRect
@export var tooltip:Control

var callback:Callable

func get_enabled()->bool:
	if button!=null:return button.visible
	return false

func set_enabled(b:bool)->void:
	if button!=null:button.visible=b

func render()->void:
	if not dirty:return
	if button==null:return
	dirty=false
	#
	if model==null:
		if get_enabled():set_enabled(false)
		return
	else:
		if not get_enabled():set_enabled(true)
	#
	var d:StringName=model.name
	var i:Texture2D=model.icon
	var t:StringName=model.description
	#
	if label!=null:label.text=d
	else:button.text=d
	if image!=null:image.texture=i
	else:button.icon=i
	if tooltip!=null:tooltip.text=t
	else:button.tooltip_text=t

func _clicked()->void:
	if callback.is_valid():callback.call()

func _ready()->void:
	if button==null:button=GodotExtension.assign_node(self,"Button") as Button
	if button!=null:button.pressed.connect(_clicked)
	super._ready()
