## A base class for media system.
class_name Media extends Node

@export_group("Media")
@export var player:Node
@export var album:Album
@export_group("Player")
@export var url:String:
	set(x):
		url=x;if is_inited:
			if x.is_empty():stop()
			else:open(x);play()
@export var loop:bool=false:
	set(x):
		loop=x;if is_inited:
			if x and not is_playing():play()
@export var bus:StringName:
	set(x):bus=x;_audio()
@export var mute:bool=false:
	set(x):mute=x;_audio()
@export_range(0.0,1.0,0.001,"or_greater") var volume:float=1.0:
	get=get_volume,set=set_volume
func get_volume()->float:return volume
func set_volume(f:float)->void:volume=f;_audio()

signal finished()

var is_inited:bool
var type:int

var playing:bool:
	get:return is_playing()
	set(x):set_playing(x);playing=x

func set_playing(b:bool)->void:
	if b:play()
	else:stop()

var paused:bool:
	get:return is_paused()
	set(x):set_paused(x);paused=x

func set_paused(b:bool)->void:
	if b:pause()
	else:resume()

var stream:Object:
	get:return get_stream()
	set(x):set_stream(x);play()
func get_stream()->Object:
	if player!=null:return player.stream
	else:return null
func set_stream(s:Object)->void:
	if not is_inited:init()
	if player!=null:player.stream=s

var length:float:get=get_length
func get_length()->float:LangExtension.throw_exception(self,LangExtension.e_not_implemented);return -1.0

var position:float:get=get_position,set=set_position
func get_position()->float:LangExtension.throw_exception(self,LangExtension.e_not_implemented);return -1.0
func set_position(f:float)->void:LangExtension.throw_exception(self,LangExtension.e_not_implemented);return

var progress:float:get=get_progress,set=set_progress
func get_progress()->float:
	var l:float=get_length()
	if l>=0.0:return position/l
	else:return -1.0
func set_progress(f:float)->void:
	var l:float=get_length()
	if l>=0.0:
		var p:float=get_progress()
		if not is_zero_approx(f-p):position=l*f

func _ready()->void:
	if not url.is_empty() and not is_playing():
		open(url);play()

func _audio()->void:
	if player!=null:
		var b:StringName=bus
		if not b.is_empty():player.bus=b
		var v:float=volume;if mute:v=0.0
		player.volume_db=linear_to_db(v)

func _done()->void:
	if loop:play()
	else:finished.emit()

func open(p:String)->void:
	var s:Object=null
	if album!=null:s=album.load(p)
	else:s=IOExtension.load_asset(p)
	set_stream(s)

func init()->void:
	if is_inited:return
	is_inited=true
	#
	type=-1
	if player==null:
		player=get_node_or_null(^"./Player")
		if player==null:player=get_parent()
	if player!=null:LangExtension.try_signal(player,&"finished",_done)
	_audio()

func is_playing()->bool:
	if not is_inited:init()
	#
	if player!=null:return player.playing
	else:return false

func is_paused()->bool:
	if not is_inited:init()
	#
	if player!=null:return player.paused
	else:return false

func clone(p:Node,b:bool=false)->Media:
	if not is_inited:init()
	if player==null:return null
	#
	var n:Node;var m:Media
	if player==self or self.is_ancestor_of(player):
		m=self.duplicate();m.name=self.name
		n=m
		m.player=m.get_node(self.get_path_to(player))
	else:
		n=player.duplicate();n.name=player.name
		m=n.get_node(player.get_path_to(self))
		m.player=n
	#
	if p!=null:GodotExtension.add_node(n,p,b)
	return m

func emit(o:Variant)->void:
	if not is_inited:init()
	if player==null:return
	#
	var s:Object=null;match typeof(o):
		TYPE_STRING,TYPE_STRING_NAME:open(o);play();return
		TYPE_INT:s=album.clips[o]
		TYPE_ARRAY:volume=o[1];emit(o[0]);return
		TYPE_OBJECT:
			if o is Album:s=o.random
			else:s=o
	set_stream(s);play()

func play()->void:
	if not is_inited:init()
	#
	if player!=null:player.play()

func stop()->void:
	if not is_inited:init()
	#
	if player!=null:player.stop()

func pause()->void:
	if not is_inited:init()
	#
	if player!=null:player.pause()

func resume()->void:
	if not is_inited:init()
	#
	if player!=null:player.resume()
