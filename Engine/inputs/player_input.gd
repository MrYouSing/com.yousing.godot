class_name PlayerInput extends Node

static var mouse_to_stick:float=0.005

@export var deadzone:Vector4=Vector4(0.125,0.5,0.5,0.5)
@export var axes:Array[String]
@export var buttons:Array[String]

var m_axes:Array[Vector2]
var m_previous:int
var m_buttons:int

var timestamp:int=-1
func try_update()->void:
	var n:int=Engine.get_process_frames()
	if(n!=timestamp):
		timestamp=n
		do_update()

func do_update()->void:
	# Axes
	var i:int=0;var n:int=axes.size()/4;var v:Vector2;
	var f:float;var s:float=deadzone.x*deadzone.x;
	for a in n:
		if !axes[i].is_empty():
			v=Vector2(Input.get_axis(axes[i],axes[i+1]),Input.get_axis(axes[i+2],axes[i+3]))
			f=v.length_squared()
			if f<=s:v=Vector2.ZERO
			elif f>1.0:v=v.normalized()
			m_axes[i/4]=v
		i+=4
	# Buttons
	m_previous=m_buttons;m_buttons=0;
	i=-1;for k in buttons:
		++i;if Input.get_action_strength(k)>deadzone.y:
			m_buttons|=1<<i
	# Advanced

func axis(i:int)->float:
	try_update()
	return m_axes[i/2][i%2]

func stick(i:int)->Vector2:
	try_update()
	return m_axes[i];

func on(i:int)->bool:
	try_update()
	return (m_buttons&(1<<i))!=0

func off(i:int)->bool:
	try_update()
	return (m_buttons&(1<<i))==0

func down(i:int)->bool:
	try_update()
	return (m_previous&(1<<i))==0 and (m_buttons&(1<<i))!=0

func up(i:int)->bool:
	try_update()
	return (m_previous&(1<<i))!=0 and (m_buttons&(1<<i))==0

#
func _init()->void:
	var n:int=axes.size()/4
	if m_axes==null:m_axes=[];m_axes.resize(n)
	elif n<m_axes.size():m_axes.resize(n)

func _process(delta: float)->void:
	try_update()
