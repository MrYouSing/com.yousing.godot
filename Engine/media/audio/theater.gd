## A helper singleton for audio management.
class_name Theater extends Node

const k_keyword:StringName=&"YouSing_Theater"
static var s_create:Callable=func()->Object:
	var i:Theater=Theater.new();i.name=k_keyword
	GodotExtension.add_node(i,null,false)
	i._ready();return i

static var instance:Theater:
	get:return Singleton.try_instance(k_keyword,s_create)
	set(x):Singleton.set_instance(k_keyword,x)

@export_group("Theater")
@export var bgm:Audio
@export var sfx:Audio
@export var voice:Audio
@export var fade:Transition
@export var capacity:int=16

signal on_speak(o:Node,k:StringName)

var old:Audio
var sfx_ring:Collections.Ring
var voice_ring:Collections.Ring

func _ready()->void:
	if Singleton.init_instance(k_keyword,self):
		if bgm==null:bgm=Audio.create(1,self);bgm.name=&"Bgm";bgm.loop=true
		if sfx==null:sfx=Audio.create(GodotExtension.s_dimension,self);sfx.name=&"Sfx"
		if voice==null:voice=Audio.create(1,self);voice.name=&"Voice"
		if fade==null:fade=Transition.new()
		if capacity>0:
			sfx_ring=Collections.Ring.new(capacity)
			voice_ring=Collections.Ring.new(capacity)

func _exit_tree()->void:
	if Singleton.exit_instance(k_keyword,self):
		pass

func get_audio(a:Audio,p:Vector3,r:Collections.Ring=null)->Audio:
	if a!=null and a.player!=null:
		var c:Audio
		if r==null:c=a.clone(self,false)
		else:c=r.pop();if c==null:c=a.clone(self,false);r.place(c)
		#
		GodotExtension.set_global_position(a.player,p);return c
	return null

func play_bgm(k:StringName,f:float=0.0)->void:
	Tweenable.kill_tween(self)
	#
	if f>0.0:
		if bgm.playing:var tmp:Audio=bgm;bgm=old;old=tmp
		if bgm==null:bgm=old.clone(self)
	else:
		if old!=null:old.stop()
	bgm.open(k);bgm.play()
	if f>0.0:
		fade.duration=f
		fade.tr_media_volume(Tweenable.make_tween(self),old,bgm)

func one_shot(k:StringName,p:Vector3,v:float=1.0)->void:
	var a:Audio=get_audio(sfx,p,sfx_ring);if a==null:return
	#
	a.open(k);a.volume=v;a.play()

func one_emit(o:Variant,p:Vector3,v:float=1.0)->void:
	var a:Audio=get_audio(sfx,p,sfx_ring);if a==null:return
	#
	a.volume=v;a.emit(o)

func speak(o:Node,k:StringName)->void:
	var a:Audio=get_audio(voice,GodotExtension.get_global_position(o),voice_ring);if a==null:return
	#
	a.open(k);a.play()
	if on_speak.has_connections():on_speak.emit(o,k)
