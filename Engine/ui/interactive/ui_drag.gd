## A simple drag tool for ui control.
class_name UIDrag extends AbsDrag
@export_group("Drag")
@export var control:Control

signal on_begin(n:Node)
signal on_change(n:Node)
signal on_end(n:Node)

func _on_begin()->void:
	on_begin.emit(control)

func _on_change()->void:
	on_change.emit(control)

func _on_end()->void:
	on_end.emit(control)

func get_point()->Vector2:
	return control.get_global_position()

func set_point(p:Vector2)->void:
	control.set_global_position(p)

func _ready()->void:
	super._ready()
	if control==null:control=_control
