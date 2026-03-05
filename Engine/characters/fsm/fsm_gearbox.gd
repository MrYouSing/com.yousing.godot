## A helper class for motor state control.
class_name FsmGearbox extends FsmAction

@export_group("Gearbox")
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
			if not is_zero_approx(speed):c.speed=speed
			if not smooth.is_zero_approx():c.smooth=smooth
			if not blend.is_empty():c.blend=blend
			#
			if _blend!=c.blend:c.moving=false
		else:
			c.speed=_speed
			c.smooth=_smooth
			c.blend=_blend

func _on_enter()->void:
	var c:CharacterController=get_character()
	if c!=null:
		c.play_animation(name)
		_on_motor(c,c.motor,true)

func _on_exit()->void:
	var c:CharacterController=get_character()
	if c!=null:
		_on_motor(c,c.motor,false)
