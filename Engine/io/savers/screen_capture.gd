## A tool class to take screenshots.
@tool
class_name ScreenCapture extends Node

@export_group("Capture")
@export var time:float=-1.0
@export var path:String="user://screenshot_{0}{1}{2}{3}{4}{5}{6}.png"
@export var view:Viewport
@export_tool_button("Capture")var _capture:Callable=capture

func capture()->void:
	var v:Viewport=view;if v==null:v=get_viewport()
	await RenderingServer.frame_post_draw
	_on_capture(v)

func _on_capture(v:Viewport)->void:
	if v==null:return
	var t:ViewportTexture=v.get_texture()
	var d:Dictionary=Time.get_datetime_dict_from_system()
	var s:String=path.format(["%04d"%d.year,"%02d"%d.month,"%02d"%d.day,"%02d"%d.hour,"%02d"%d.minute,"%02d"%d.second,"%04d"%(randi()%10000)])
	TextureSaver.save_to_file(t,s)

func _ready()->void:
	if Engine.is_editor_hint():return
	if time>=0.0:Juggler.instance.delay_call(capture,LangExtension.k_empty_array,time)
