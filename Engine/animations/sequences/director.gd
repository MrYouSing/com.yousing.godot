## A player class for custom playables.
class_name Director extends Node

@export_group("Director")
@export var clip:Clip
@export var speed:float=1.0:
	set(x):speed=x;_speed=signf(_speed)*maxf(x,0.001)
@export var events:BaseMachine

var _time:float=-1.0
var _index:int=-1
var _speed:float=1.0

func play(c:Clip)->void:
	stop()
	if c!=null:
		clip=c
		_time=0.0
		_index=0

func stop()->void:
	clip=null
	_time=-1.0
	_index=-1

func pause()->void:
	set_process(false)

func resume()->void:
	set_process(true)

func set_clip(c:Clip)->void:
	if c==null:
		stop()
	elif _index<0:
		play(c)
	else:
		clip=c;
		_on_frame(c.frames[_index])

func invoke_event(e:StringName)->void:
	if events!=null:events._on_event(self,e)

func _on_frame(f:Frame)->void:
	LangExtension.throw_exception(self,LangExtension.e_not_implemented)

func _on_complete()->void:
	if clip!=null:match clip.loop:
		Animation.LOOP_NONE:
			stop()
		Animation.LOOP_LINEAR:
			_time=-1.0/clip.fps;_index=0
		Animation.LOOP_PINGPONG:
			_speed*=-1.0
			if _speed>0:
				_time=-1.0/clip.fps;_index=0
			else:
				_time+=1.0/clip.fps;_index-=1

func _process(d:float)->void:
	if _time<=-1.0 or clip==null:return
	_time+=d*_speed
	#
	var t:float=clip.get_time(_index)
	if _speed>0.0:if _time>=t:
		_on_frame(clip.frames[_index]);_index+=1
		if _index>=clip.frames.size():_on_complete()
	else:if _time>=t:
		_on_frame(clip.frames[_index]);_index-=1
		if _index<0:_on_complete()
