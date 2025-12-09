# An entity which like UnityEngine.GameObject.
class_name Actor extends Node3D

@export var components:Array[Node]
var tween:Tween

func get_component(s:StringName)->Node:
	for it in components:
		if it!=null and it.name==s:return it
	return null

func get_components(s:String,l:Array[Node])->Array[Node]:
	for it in components:
		if it!=null and it.name.match(s) and l.find(it)<0:
			l.append(it)
	return l

func get_tween(b:bool=false)->Tween:
	if tween!=null:
		if b and tween.is_running():tween.finished.emit()
		tween.kill();tween=null#Stop
	tween=create_tween();return tween
