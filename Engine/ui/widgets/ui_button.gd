## A widget which performs as a button with [url=https://docs.unity3d.com/ScriptReference/GUIContent.html]GUIContent[/url].
class_name UIButton extends UIView

@export_group("Button")
@export var button:Button
@export var text:Control
@export var image:TextureRect
@export var tooltip:Control

func render()->void:
	if !dirty:return
	if button==null:return
	dirty=false
	#
	if model==null:
		button.visible=false;return
	else:
		button.visible=true
	#
	var d:StringName=model.name
	var i:Texture2D=model.icon
	var t:StringName=model.description
	#
	if text!=null:text.text=d
	else:button.text=d
	if image!=null:image.texture=i
	else:button.icon=i
	if tooltip!=null:tooltip.text=t
	else:button.tooltip_text=t

func _ready()->void:
	if button==null:button=GodotExtension.assign_node(self,"Button")
	super._ready()
