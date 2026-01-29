## A video player.
class_name Video extends Media

@export_group("Video")
@export var aspect:UICanvas.AspectRatio:
	set(x):aspect=x;if is_inited:_size_changed()

func get_length()->float:
	if is_playing():return player.get_stream_length() 
	else:return -1.0

func get_position()->float:
	if is_playing():return player.stream_position
	else:return -1.0

func set_position(f:float)->void:
	if is_playing():player.stream_position=f

func get_size()->Vector2:
	if is_playing():
		var t:Texture2D=player.get_video_texture()
		if t!=null:return t.get_size()
	return Vector2.ZERO

func play()->void:
	super.play()
	_size_changed()

func _size_changed()->void:
	if aspect>=UICanvas.AspectRatio.MatchWidth:return
	var c:Control=player;var s:Vector2=get_size()
	if c!=null and !s.is_zero_approx():
		var d:Vector2=c.get_parent_area_size()
		s=UICanvas.fit_scale(aspect,s,d)*s
		s*=0.5;var m:Vector2=MathExtension.k_vec2_half
		UITransform.set_anchor_and_offset(c,m,m,-s,s)

func _ready()->void:
	super._ready()
	UICanvas.register(self,0,_size_changed)

func _exit_tree() -> void:
	UICanvas.unregister(self,0,_size_changed)

func init()->void:
	if is_inited:return
	super.init()
	#
	if player!=null:
		if player is VideoStreamPlayer:
			type=1;player.loop=false;player.expand=true

func is_playing()->bool:
	if !is_inited:init()
	#
	if type==1:return player.is_playing()
	else:return false

func open(p:StringName)->void:
	if !is_inited:init()
	#
	if player!=null and FileAccess.file_exists(p):
		var s:Object=LangExtension.class_cast(player.stream,&"FFmpegVideoStream")
		if s!=null:s.file=p;player.stream=s;return
	super.open(p)
