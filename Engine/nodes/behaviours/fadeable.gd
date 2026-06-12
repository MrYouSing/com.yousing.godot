## A helper class for fade-in and fade-out.
class_name Fadeable extends Node

@export_group("Fade")

signal started()
signal finished()
signal entered()
signal exited()

var _call:int=Juggler.k_invalid_id
var _version:int

func set_enabled(b:bool)->void:
	_on_stop()
	if b:_on_show()
	else:_on_exit()

func _on_stop()->void:
	Juggler.try_kill(self);_version+=1

func _on_show()->void:
	started.emit()

func _on_enter()->void:
	entered.emit()

func _on_exit()->void:
	exited.emit()

func _on_hide()->void:
	finished.emit()
