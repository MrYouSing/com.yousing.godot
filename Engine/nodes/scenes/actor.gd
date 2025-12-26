## An entity which like UnityEngine.GameObject.
class_name Actor extends Node3D

@export var components:Array[Node]
var tween:Tween

func set_enabled(b:bool)->void:
	set_process(b)
	set_physics_process(b)
	visible=b
	# Broadcast
	for it in components:GodotExtension.set_enabled(it,b)

func show()->void:set_enabled(true)
func hide()->void:set_enabled(false)

func get_component(s:StringName)->Node:
	for it in components:
		if it!=null and it.name==s:return it
	return null

func get_components(s:String,l:Array[Node])->Array[Node]:
	for it in components:
		if it!=null and it.name.match(s) and l.find(it)<0:
			l.append(it)
	return l

func stop_tween(b:bool=false)->void:
	if tween!=null:
		if b and tween.is_valid():tween.finished.emit()
		tween.kill();tween=null#Stop

func play_tween(b:bool=false)->Tween:
	if tween!=null:
		if b and tween.is_valid():tween.finished.emit()
		tween.kill();tween=null#Stop
	tween=create_tween();return tween

# Messages

func _on_toggle(c:Object,b:bool)->void:set_enabled(b)
