## A composite class for [Media].
class_name MultiMedia extends Media

@export_group("Multi-Media")
@export var aspect:UICanvas.AspectRatio:
	set(x):aspect=x;if is_inited:player.set(&"aspect",x)
@export var players:Array[Node]
@export var loaders:Array[Resource]

func find(e:String)->int:
	var i:int=-1;for it in loaders:
		i+=1;if it.support(e):return i
	return i

func refresh()->void:
	var p:Node=players[type];
	if p==player:return
	#
	if player!=null:
		player.stop()
		GodotExtension.set_enabled(player,false)
	player=p
	if player!=null:
		GodotExtension.set_enabled(player,true)

func set_stream(s:Object)->void:
	if s==null:stop();return
	type=find(IOExtension.file_extension(s.resource_name))
	if type>=0:refresh();player.stream=s

func get_length()->float:
	if player!=null:return player.get_length()
	return -1.0

func get_position()->float:
	if player!=null:return player.get_position()
	return -1.0

func set_position(f:float)->void:
	if player!=null:player.set_position(f)

func open(p:String)->void:
	type=find(IOExtension.file_extension(p))
	if type>=0:refresh();player.open(p)

func _audio()->void:
	if player!=null:
		var b:StringName=bus
		if !b.is_empty():player.bus=b
		var v:float=volume;if mute:v=0.0
		player.volume=v

func init()->void:
	if is_inited:return
	is_inited=true
	for it in players:
		if LangExtension.exist_signal(it,&"finished"):
			it.loop=false
			it.connect(&"finished",_done)

func play()->void:
	if !is_inited:init()
	#
	if player!=null:
		player.set(&"aspect",aspect)
		player.play()
