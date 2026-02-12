## An audio player.
class_name Audio extends Media

static func create(m:StringName,i:int,n:Node=null)->Audio:
	var p:Node
	match i:
		1:p=AudioStreamPlayer.new();p.name=&"AudioPlayer"
		2:p=AudioStreamPlayer2D.new();p.name=&"AudioPlayer2D"
		3:p=AudioStreamPlayer3D.new();p.name=&"AudioPlayer3D"
	if p!=null:
		var a:Audio=Audio.new()
		if not m.is_empty():a.name=m;p.bus=m
		if n!=null:n.add_child(p);
		p.add_child(a);a.player=p
		return a
	return null

func get_length()->float:
	if player!=null:
		var s:AudioStream=player.stream
		if s!=null:return s.get_length()
	return -1.0

func get_position()->float:
	if is_playing():return player.get_playback_position()
	else:return -1.0

func set_position(f:float)->void:
	if is_playing():
		var b:bool=player.stream_paused
		player.stream_paused=false;player.seek(f)
		player.stream_paused=b

func init()->void:
	if is_inited:return
	super.init()
	#
	if player!=null:
		if player is AudioStreamPlayer:type=1
		elif player is AudioStreamPlayer2D:type=2
		elif player is AudioStreamPlayer3D:type=3
		else:player=null

## TODO: [member AudioStreamPlayer.stream_paused]=true will cause that [member AudioStreamPlayer.playing]=false and [method AudioStreamPlayer.seek] does not work.
func is_playing()->bool:
	if not is_inited:init()
	#
	if player!=null:return player.playing or player.stream_paused
	else:return false

func is_paused()->bool:
	if not is_inited:init()
	#
	if player!=null:return player.stream_paused
	else:return false

func open(p:String)->void:
	if not is_inited:init()
	#
	if player!=null:
		var s:AudioStream=AudioLoader.load_from_file(p)
		if s!=null:player.stream=s;return
	super.open(p)

func play()->void:
	if not is_inited:init()
	#
	if player!=null:player.stream_paused=false;player.play()

func pause()->void:
	if not is_inited:init()
	#
	if player!=null:player.stream_paused=true

func resume()->void:
	if not is_inited:init()
	#
	if player!=null:player.stream_paused=false
