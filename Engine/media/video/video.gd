## A video player.
class_name Video extends AbsVideo

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

func has_size()->bool:
	return player!=null and player.is_playing

func get_size()->Vector2:
	var t:Texture2D=player.get_video_texture()
	if t!=null:return t.get_size()
	else:return Vector2.ZERO

func _speed_changed()->void:
	if player!=null:player.speed_scale=speed*_speed

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
	if player!=null:_speed=1.0;_speed_changed();player.play()
	_size_changed()

func stop()->void:
	if !is_inited:init()
	#
	if player!=null:_speed=1.0;player.stop()

func pause()->void:
	if !is_inited:init()
	#
	if player!=null:_speed=0.0;_speed_changed()

func resume()->void:
	if !is_inited:init()
	#
	if player!=null:_speed=1.0;_speed_changed()
