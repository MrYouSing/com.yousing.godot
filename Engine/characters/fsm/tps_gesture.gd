## A helper class for playing gestures with movements.
class_name TpsGesture extends FsmGesture

@export_group("TPS")
@export var footstep:Footstep
@export var speed:float
@export var smooth:Vector2
@export var blend:StringName

var _speed:float
var _smooth:Vector2
var _blend:StringName

func _on_init()->void:
	super._on_init()
	if footstep==null:footstep=actor

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

func _on_layer_speed(a:Animator,l:AnimatorLayer,s:float,t:float)->void:
	super._on_layer_speed(a,l,s,t)
	#
	if l.index==(main_layer%32) and footstep!=null:
		var tmp:Tween=Tweenable.make_tween(footstep)
		if t<0.0:t=absf(s-footstep.speed)/-t
		tmp.tween_property(footstep,^"speed",s,t)
