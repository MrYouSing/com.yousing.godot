## The abstract class driven by [InputEventMouseMotion] and [InputEventScreenDrag].
@abstract class_name AbsDrag extends Node

@export_group("Drag")
@export var mask:int
@export var area:Control

var _control:Control
var _touch_id:int=-1
var _touch_point:Vector2
var _start_point:Vector2

func accept(e:InputEvent)->bool:
	if mask!=0:if mask&(1<<InputExtension.event_get_index(e))==0:return false
	if area!=null:if not UITransform.has_point(area,screen_point(e.position)):return false
	return true

func touch(e:InputEvent)->void:
	if e!=null:
		_touch_point=screen_point(e.position)
		_start_point=get_point()
		_on_begin()
	else:
		_on_end()
		_touch_point=Vector2.ZERO
		_start_point=Vector2.ZERO

func drag(p:Vector2)->void:
	set_point(_start_point+screen_point(p)-_touch_point)
	_on_change()

func screen_point(p:Vector2)->Vector2:
	if _control!=null:return _control.get_global_transform_with_canvas()*p
	else:return p

func handle_input(e:InputEvent)->void:
	get_viewport().set_input_as_handled()

@abstract func get_point()->Vector2
@abstract func set_point(p:Vector2)->void
@abstract func _on_begin()->void
@abstract func _on_change()->void
@abstract func _on_end()->void

func _ready()->void:
	_control=get_node(^".") as Control
	if area==null:area=_control
	if _control==null:GodotExtension.input_node(self,0x42)
	else:GodotExtension.input_node(self,0x41)

func _gui_input(e:InputEvent)->void:_on_input(e)
# <!-- Macro.Patch OnInput
func _input(e:InputEvent)->void:_on_input(e)
func _unhandled_input(e:InputEvent)->void:_on_input(e)

func _on_input(e:InputEvent)->void:
	var b:bool=false
	#
	if e is InputEventScreenTouch:
		if e.pressed and accept(e):
			if _touch_id<0:
				_touch_id=e.index
				touch(e)
				b=true
		else:
			if _touch_id==e.index:
				touch(null)
				_touch_id=-1
				b=true
	elif e is InputEventScreenDrag:
		if _touch_id==e.index:
			drag(e.position)
			b=true
	elif e is InputEventMouseButton:
		if e.pressed and accept(e):
			if _touch_id==-1:
				_touch_id=-2
				touch(e)
				b=true
		else:
			if _touch_id==-2:
				touch(null)
				_touch_id=-1
				b=true
	elif e is InputEventMouseMotion:
		if _touch_id==-2:
			drag(e.position)
			b=true
	#
	if b:handle_input(e)#get_viewport().set_input_as_handled()
# Macro.Patch -->
