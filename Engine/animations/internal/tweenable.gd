## A helper class for [Tween].
class_name Tweenable extends Node

const k_interface:Array[StringName]=[&"play_tween",&"stop_tween"]
static var s_tweens:Dictionary[Node,Tween]

## See [method Tween.kill].
static func kill_tween(n:Node)->void:
	if n==null:return
	var t:Tween=s_tweens.get(n,null)
	if t!=null:t.kill();s_tweens.erase(n)#Stop

## See [method Node.create_tween].
static func make_tween(n:Node)->Tween:
	if n==null:return
	var t:Tween=s_tweens.get(n,null)
	if t!=null:t.kill()#;s_tweens.erase(n)#Stop
	# Play
	t=n.create_tween()
	s_tweens[n]=t;return t

static func have_tween(n:Node)->bool:
	if n==null:return false
	var t:Tween=s_tweens.get(n,null)
	if t!=null and t.is_valid():return true
	return false

static func find_tween(n:Node)->Tween:
	if n==null:return null
	var t:Tween=s_tweens.get(n,null)
	if t!=null and t.is_valid():return t
	return null

static func hunt_tween(n:Node)->Tween:
	if n==null:return null
	var t:Tween=s_tweens.get(n,null)
	if t!=null and t.is_valid():return t
	# Play
	t=n.create_tween()
	s_tweens[n]=t;return t

static func cast_tween(n:Node,b:bool=true)->Tween:
	if n==null:return null
	if n.has_method(&"play_tween"):
		var t:Tween=n.tween
		if t!=null and t.is_valid():return t
		if b:return n.play_tween()
		else:return null
	else:
		if b:return hunt_tween(n)
		else:return find_tween(n)

var tween:Tween

func stop_tween()->void:
	if tween!=null:tween.kill();tween=null#Stop

func play_tween()->Tween:
	if tween!=null:tween.kill();tween=null#Stop
	#
	tween=create_tween();return tween
