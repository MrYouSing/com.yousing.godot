## A helper class for playing gestures with movements.
class_name TpsGesture extends FsmGesture

@export_group("TPS")
@export var speed:float
@export var smooth:Vector2

var _speed:float
var _smooth:Vector2

func _on_motor(c:Node,m:Node,b:bool)->void:
	if m!=null:
		m.velocity=Vector3.ZERO
	if c is TpsController:
		if b:
			_speed=c.speed
			_smooth=c.smooth
			#
			if !is_zero_approx(speed):c.speed=speed
			if !smooth.is_zero_approx():c.smooth=smooth
			c.sync_animation(Vector3.ZERO);c.moving=false
		else:
			c.speed=_speed
			c.smooth=_smooth
