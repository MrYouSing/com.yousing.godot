## A [url=https://github.com/xiSage/godot-vlc.git]VLC[/url] player.
class_name VlcMedia extends AbsVideo

@export_group("VLC")
@export var seek:Vector2=Vector2.ONE*0.1

var _playing:bool# TODO: Fix finished().
var _time:Vector3=Vector3.ONE*-1.0# TODO: Fix seek().

func get_stream()->Object:
	if player!=null:return player.media
	else:return null

func set_stream(s:Object)->void:
	if !is_inited:init()
	if player!=null:player.media=s

func get_duration()->float:
	return player.get_length()*0.001

func get_length()->float:
	if _playing:
		if _time.y>=0.0:return _time.y
		return get_duration()
	else:return -1.0

func get_position()->float:
	if _playing:
		if _time.z>=0.0:return _time.z
		return get_duration()*get_progress()
	else:return -1.0

func set_position(f:float)->void:
	if _playing:set_progress(f/get_duration())

func get_progress()->float:
	if _playing:
		if _time.x>=0.0:return _time.x
		return player.get_position()
	else:return -1.0

func set_progress(f:float)->void:
	if _playing:
		if is_zero_approx(f-player.get_position()):return
		_seek(f);player.set_position(f,false)

func has_size()->bool:
	return _playing

func get_size()->Vector2:
	if _playing:
		var t:Texture2D=player.get_texture()
		if t!=null:return t.get_size()
	return Vector2.ZERO

func _seek(f:float)->void:
	_time=Vector3(f,get_duration(),0.0);_time.z=_time.x*_time.y
	LangExtension.try_signal(player,&"video_frame",_wait)

func _wait()->void:
	var t:float=player.get_position();var f:float=(t-_time.x)
	f*=get_duration();if f*f>=seek.x*seek.x and _playing:return
	#
	LangExtension.remove_signal(player,&"video_frame",_wait)
	_time=Vector3.ONE*-1.0;set_process(true)

func _speed_changed()->void:# TODO: Fix speed()[Unfinished].
	if seek.y<0.0:return
	if player!=null and _playing:
		if is_zero_approx(player.get_rate()-speed):return
		var t:float=player.get_position()+seek.y/get_duration()
		set_progress(t);player.set_rate(speed)
		Juggler.instance.delay_call(set_progress,[t],seek.y)

func _process(d:float)->void:
	if _playing:
		var f:float=player.get_position()
		match player.get_state():
			5,6:f=1.0
		if f>=1.0:
			_playing=false;_time=Vector3.ONE*-1.0
			_done()

func is_playing()->bool:
	return _playing

func init()->void:
	if is_inited:return
	super.init()
	if player!=null:
		if player.is_class("VLCMediaPlayer"):
			type=3;player.stretch_mode=TextureRect.STRETCH_SCALE
		else:
			player=null

func is_paused()->bool:
	if !is_inited:init()
	#
	if player!=null:return player.get_state()==4
	else:return false

func open(p:String)->void:
	if !is_inited:init()
	#
	if player!=null:
		var m:Resource=VlcLoader.load_from_file(p)
		if m!=null:player.media=m;return
	super.open(p)

func play()->void:
	if !is_inited:init()
	#
	set_process(true)
	_playing=true;_time=Vector3.ONE*-1.0
	if player!=null:
		player.set_rate(speed)
		player.visible=_playing;player.play()
		LangExtension.try_signal(player,&"video_frame",_prepared)

func _prepared()->void:# TODO: Fix size_changed()
	if get_position()<0.01 and _playing:return
	LangExtension.remove_signal(player,&"video_frame",_prepared)
	_size_changed()

func stop()->void:
	if !is_inited:init()
	#
	set_process(false)
	_playing=false;_time=Vector3.ONE*-1.0
	if player!=null:
		player.stop_async();player.visible=_playing

func pause()->void:
	if !is_inited:init()
	#
	if player!=null:player.set_pause(true)

func resume()->void:
	if !is_inited:init()
	#
	if player!=null:player.set_pause(false)
