/* <!-- Macro.Define bFixPatch=
true
 Macro.End --> */
/* <!-- Macro.Define OnInput
func _input(e:InputEvent)->void:_on_input(e)
func _unhandled_input(e:InputEvent)->void:_on_input(e)

func _on_input(e:InputEvent)->void:
	var b:bool=false
	#
	if e is InputEventScreenTouch:
		if e.pressed{0}:
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
		if e.pressed{0}:
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
	if b:{1}get_viewport().set_input_as_handled()
 Macro.End --> */

/* <!-- Macro.Table Replace
\r\n,\n
 Macro.End --> */

/* <!-- Macro.Call OnInput
 and in_area(area&#44;e.position),if is_handled_input():,
 Macro.End --> */
/* <!-- Macro.Replace Replace
 Macro.End --> */
/* <!-- Macro.Patch
on_screen_stick.gd,OnInput
on_screen_pad.gd,OnInput
 Macro.End --> */

/* <!-- Macro.Call OnInput
 and accept(e),,
 Macro.End --> */
/* <!-- Macro.Replace Replace
 Macro.End --> */
/* <!-- Macro.Patch
../../ui/interactive/abs_drag.gd,OnInput
 Macro.End --> */