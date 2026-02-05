## A texture player.
class_name Picture extends Media

@export_group("Picture")
@export var slot:StringName=&"texture"
@export var duration:float=1.0
@export var container:AspectRatioContainer
@export var aspect:UICanvas.AspectRatio:
	set(x):aspect=x;if is_inited:_size_changed()

var _time:float=-1.0
var _texture:Texture

func get_stream()->Object:
	if player!=null:return player.get(slot)
	else:return null

func set_stream(s:Object)->void:
	if !is_inited:init()
	if player!=null:player.set(slot,s)
	_texture=s;_size_changed()

func get_length()->float:return duration
func get_position()->float:return _time
func set_position(f:float)->void:_time=f

func is_playing()->bool:
	return _time>=0.0

func is_paused()->bool:
	return !is_processing()

func pause()->void:
	set_process(false)

func resume()->void:
	set_process(true)

func open(p:String)->void:
	set_stream(TextureLoader.load_from_file(p))

func _audio()->void:
	pass

func _size_changed()->void:
	if _texture==null:return
	UICanvas.fit_control(container,player,aspect,_texture.get_size())

func _ready()->void:
	set_process(false)
	super._ready()
	if container==null:UICanvas.register(self,0,_size_changed)

func _exit_tree() -> void:
	if container==null:UICanvas.unregister(self,0,_size_changed)

func _process(d:float)->void:
	if _time<0.0:return
	_time+=d;if _time>=duration:
		stop();_done()

func init()->void:
	if is_inited:return
	is_inited=true
	if player==null:
		player=GodotExtension.assign_node(self,"TextureRect")
	if player!=null:
		player.set(&"expand_mode",1)

func play()->void:
	if !is_inited:init()
	#
	_time=0.0;set_process(true)
	if player!=null:player.set(slot,_texture)

func stop()->void:
	if !is_inited:init()
	#
	set_process(false);_time=-1.0
	if player!=null:player.set(slot,null)
