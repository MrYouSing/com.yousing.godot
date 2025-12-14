## A helper singleton for audio management.
class_name Theater extends Node

const k_keyword:StringName=&"YouSing_Theater"
static var s_create:Callable=func()->Object:
	var i:Theater=Theater.new()
	GodotExtension.add_node(i,null,false);
	i._ready();return i

static var instance:Theater:
	get:return Singleton.try_instance(k_keyword,s_create)
	set(x):Singleton.set_instance(k_keyword,x)

@export_group("Theater")
@export var bgm:Audio
@export var sfx:Audio
@export var fade:Transition

var old:Audio
var tween:Tween

func _ready()->void:
	if Singleton.init_instance(k_keyword,self):
		if bgm==null:bgm=Audio.create(1,self);bgm.loop=true
		if sfx==null:sfx=Audio.create(GodotExtension.s_dimension,self)
		if fade==null:fade=Transition.new()

func _exit_tree()->void:
	Singleton.exit_instance(k_keyword,self)

func get_tween()->Tween:
	if tween!=null:tween.kill()
	#
	tween=create_tween();return tween

func play_bgm(k:StringName,f:float=0.0)->void:
	if tween!=null:tween.kill()
	#
	if f>0.0:
		if bgm.playing:var tmp:Audio=bgm;bgm=old;old=tmp
		if bgm==null:bgm=old.clone(self)
	else:
		if old!=null:old.stop()
	bgm.open(k);bgm.play()
	if f>0.0:
		fade.duration=f
		fade.tr_media_volume(get_tween(),old,bgm)

func one_shot(k:String,p:Vector3,v:float=1.0)->void:
	if sfx.player==null:return
	#
	var a:Audio=sfx.clone(self);var n:Node=a.player
	if n is Node3D:n.global_position=p
	elif n is Node2D:n.global_position=Vector2(p.x,p.y)
	a.open(k);a.volume=v;a.play()
