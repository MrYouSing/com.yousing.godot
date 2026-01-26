## A pad control for on-screen gestures.
class_name OnScreenPad extends OnScreenControl

@export_group("Pad")
@export_flags(
	"Button","Stick","Swipe","Reserved"
)var features:int
@export var area:Control
@export var stick:Vector2=Vector2.ONE
@export var swipe:Vector2=Vector2.LEFT
@export var actions:Array[StringName]=[&"ui_left",&"ui_right",&"ui_up",&"ui_down",&"ui_accept",&"ui_cancel"]

var _touch_id:int=-1
var _touch_time:float=-1.0
var _touch_point:Vector2
var _touch_last:Vector2

func register(b:bool)->void:pass
func refresh()->void:pass
func dirty()->bool:return false
func draw()->void:pass

func touch(e:InputEvent)->void:
	var b:bool=e!=null;var t:float=Application.get_time()
	if features&0x01!=0:InputExtension.set_button(actions[4],b)
	if features&0x02!=0:InputExtension.set_vector(actions,Vector2.ZERO)
	if b:
		_touch_time=t
		_touch_point=e.position
	else:
		if features&0x04!=0:
			var v:Vector2=_touch_last-_touch_point
			if !MathExtension.time_dead(t-_touch_time,swipe.x):
				if v.length_squared()>swipe.y*swipe.y:
					InputExtension.set_swipe(actions,actions[5],v.normalized())
		_touch_time=-1.0
		_touch_point=Vector2.ZERO
	_touch_last=_touch_point

func drag(p:Vector2)->void:
	if features&0x02!=0:
		var v:Vector2=p-_touch_last
		v/=Application.get_delta()
		InputExtension.set_vector(actions,v*stick*InputExtension.s_mouse_to_stick)
	_touch_last=p
# <!-- Macro.Patch OnInput
func _input(e:InputEvent)->void:_on_input(e)
func _unhandled_input(e:InputEvent)->void:_on_input(e)

func _on_input(e:InputEvent)->void:
	var b:bool=false
	#
	if e is InputEventScreenTouch:
		if e.pressed and in_area(area,e.position):
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
		if e.pressed and in_area(area,e.position):
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
	if b:if is_handled_input():get_viewport().set_input_as_handled()
# Macro.Patch -->
