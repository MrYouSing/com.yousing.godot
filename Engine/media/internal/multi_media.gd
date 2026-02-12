## A composite class for [Media].
class_name MultiMedia extends Media

@export_group("Multi-Media")
@export var aspect:UICanvas.AspectRatio:
	set(x):aspect=x;if is_inited:player.set(&"aspect",x)
@export var speed:float=1.0:
	set(x):speed=x;if is_inited:player.set(&"speed",x)
@export var actors:Array[Node]
@export var players:Array[Node]
@export var loaders:Array[Resource]

var is_done:bool

func find(e:String)->int:
	var i:int=-1;for it in loaders:
		i+=1;if it!=null and it.support(e):return i
	return i

func refresh()->void:
	var p:Node=players[type];
	if p==player:return
	#
	if player!=null:
		player.stop()
		GodotExtension.set_enabled(actors[players.find(player)],false)
	player=p
	if player!=null:
		GodotExtension.set_enabled(actors[players.find(player)],true)

func set_stream(s:Object)->void:
	if s==null:stop();return
	type=find(IOExtension.file_extension(s.resource_name))
	if type>=0:refresh();player.stream=s

# Tricks for MediaPlayer.

func get_length()->float:
	if player!=null:return player.get_length()
	return -1.0

func get_position()->float:
	if player!=null:
		if is_done:return player.get_length()
		return player.get_position()
	return -1.0

func set_position(f:float)->void:
	if player!=null:
		if is_done:play()
		player.set_position(f)

func get_volume()->float:
	if mute:return 0.0
	else:return volume

func set_volume(f:float)->void:
	if mute:volume=f
	else:super.set_volume(f)

func is_paused()->bool:
	if is_done:return true
	else:return super.is_paused()

func set_paused(b:bool)->void:
	if is_done:play()
	else:super.set_paused(b)

func open(p:String)->void:
	type=find(IOExtension.file_extension(p))
	if type>=0:refresh();player.open(p)

func _audio()->void:
	if player!=null:
		var b:StringName=bus
		if not b.is_empty():player.bus=b
		var v:float=volume;if mute:v=0.0
		player.volume=v

func _done()->void:
	is_done=true
	super._done()

func init()->void:
	if is_inited:return
	is_inited=true
	var a:Node
	var i:int=-1;for it in players:
		i+=1;a=actors[i]
		if a==null:a=it;actors[i]=a
		GodotExtension.set_enabled(a,i==type)
		if LangExtension.exist_signal(it,&"finished"):
			it.loop=false
			it.connect(&"finished",_done)

func play()->void:
	if not is_inited:init()
	#
	is_done=false
	if player!=null:
		_audio()
		player.set(&"aspect",aspect)
		player.set(&"speed",speed)
		player.play()
