## A helper class for object activation.
@abstract
class_name Activatable extends Node

signal on_show()
signal on_hide()

var _shown:bool
var _call:int=Juggler.k_invalid_id
var _version:int

@abstract func _on_show()->void
@abstract func _on_hide()->void

func set_enabled(b:bool)->void:
	if b==_shown:pass
	elif b:show()
	else:hide()

func show()->void:
	if _shown:return
	_shown=true
	#
	_on_stop();_on_show()
	if _shown:on_show.emit()

func hide()->void:
	if not _shown:return
	_shown=false
	#
	_on_stop();_on_hide()
	if not _shown:on_hide.emit()

func _on_stop()->void:
	Juggler.try_kill(self);_version+=1
