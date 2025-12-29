## A helper class for playing gestures with movements.
class_name TpsGesture extends FsmGesture

@export_group("TPS")
@export var speed:float
@export var smooth:Vector2
@export var blend:StringName

var _speed:float
var _smooth:Vector2
var _blend:StringName

func _on_motor(c:Node,m:Node,b:bool)->void:
	if m!=null:
		pass
	if c is TpsController:
		if b:
			_speed=c.speed
			_smooth=c.smooth
			_blend=c.blend
			#
			if !is_zero_approx(speed):c.speed=speed
			if !smooth.is_zero_approx():c.smooth=smooth
			if !blend.is_empty():c.blend=blend
			#
			if _blend!=c.blend:c.moving=false
		else:
			c.speed=_speed
			c.smooth=_smooth
			c.blend=_blend
