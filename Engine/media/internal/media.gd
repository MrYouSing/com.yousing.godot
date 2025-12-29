## A base class for media system.
class_name Media extends Node

@export_group("Media")
@export var player:Node
@export var album:Album
@export_group("Player")
@export var auto:StringName
@export var loop:bool=false
@export var mute:bool=false:
	set(x):mute=x;_audio()
@export_range(0.0,1.0,0.001,"or_greater") var volume:float=1.0:
	set(x):volume=x;_audio()
signal on_done()

var is_inited:bool
var type:int

var playing:bool:
	get:return is_playing()
	set(x):
		playing=x;
		if x:play()
		else:stop()

var paused:bool:
	get:return is_paused()
	set(x):
		paused=x;
		if x:pause()
		else:resume()

func _ready()->void:
	if !auto.is_empty():open(auto);play()

func _audio()->void:
	if player!=null:
		var v:float=volume;if mute:v=0.0
		player.volume_db=linear_to_db(v)

func _done()->void:
	if loop:play()
	else:on_done.emit()

func init()->void:
	if is_inited:return
	is_inited=true
	#
	type=-1
	if player==null:player=get_parent()
	if player!=null:player.finished.connect(_done)
	_audio()

func is_playing()->bool:
	if !is_inited:init()
	#
	if player!=null:return player.playing
	else:return false

func is_paused()->bool:
	if !is_inited:init()
	#
	if player!=null:return player.paused
	else:return false

func clone(p:Node,b:bool=false)->Media:
	if !is_inited:init()
	#
	var t:Node=player;if t==null:return null
	t=t.duplicate();GodotExtension.add_node(t,p,b)
	return t.get_child(self.get_index())

func open(p:StringName)->void:
	if !is_inited:init()
	#
	if player!=null:
		if album!=null:player.stream=album.load(p)
		else:player.stream=load("res://"+p)

func emit(o:Variant)->void:
	if !is_inited:init()
	if player==null:return
	#
	match typeof(o):
		TYPE_STRING_NAME:open(o);play()
		TYPE_INT:player.stream=album.clips[o];play()
		_:if o is Album:player.stream=o.random();play()

func play()->void:
	if !is_inited:init()
	#
	if player!=null:player.play()

func stop()->void:
	if !is_inited:init()
	#
	if player!=null:player.stop()

func pause()->void:
	if !is_inited:init()
	#
	if player!=null:player.pause()

func resume()->void:
	if !is_inited:init()
	#
	if player!=null:player.resume()
