## A video player.
class_name Video extends Media

@export_group("Video")
@export var container:AspectRatioContainer
@export var aspect:UICanvas.AspectRatio:
	set(x):aspect=x;if is_inited:_size_changed()
@export var speed:float=1.0:
	set(x):speed=x;_video()

var _stream:VideoStream
var _speed:float=1.0

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

func _video()->void:
	if player!=null:
		player.speed_scale=speed*_speed

func _size_changed()->void:
	if player==null or !player.is_playing:return
	UICanvas.fit_control(container,player,aspect,get_size())

func _ready()->void:
	super._ready()
	if container==null:UICanvas.register(self,0,_size_changed)

func _exit_tree() -> void:
	if container==null:UICanvas.unregister(self,0,_size_changed)

func init()->void:
	if is_inited:return
	super.init()
	#
	if player!=null:
		if player is VideoStreamPlayer:
			type=1;player.loop=false;player.expand=true
		else:
			player=null

func is_playing()->bool:
	if !is_inited:init()
	#
	if player!=null:return player.is_playing()
	else:return false

func is_paused()->bool:
	if !is_inited:init()
	#
	if player!=null:return player.is_playing() and _speed==0.0
	else:return false

func open(p:String)->void:
	if !is_inited:init()
	#
	if player!=null:
		_stream=VideoLoader.load_from_file(p,_stream)
		if _stream!=null:player.stream=_stream;return
	super.open(p)

func play()->void:
	if !is_inited:init()
	#
	if player!=null:_speed=1.0;_video();player.play()
	_size_changed()

func stop()->void:
	if !is_inited:init()
	#
	if player!=null:_speed=1.0;player.stop()

func pause()->void:
	if !is_inited:init()
	#
	if player!=null:_speed=0.0;_video()

func resume()->void:
	if !is_inited:init()
	#
	if player!=null:_speed=1.0;_video()
