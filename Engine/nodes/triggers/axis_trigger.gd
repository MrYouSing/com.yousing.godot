class_name AxisTrigger extends InputTrigger

@export_group("Axes")
@export var axis:int
@export var axes:Array[StringName]
@export var deadzone:Vector4

var value:bool
var previous:bool
var _timestamp:int=-1

func try_update()->void:
	var n:int=Application.get_frames()
	if n!=_timestamp:
		_timestamp=n
		do_update()

func vector()->Vector2:
	if input!=null:
		if axis>=0:return Vector2(input.axis(axis),0.0)
		else:return input.stick(-axis-1)
	else:
		if axis>=0:return Vector2(Input.get_axis(axes[0],axes[1]),0.0)
		else:return Input.get_vector(axes[0],axes[1],axes[2],axes[3])
	return Vector2.ZERO

func do_update()->void:
	previous=value
	#
	var v:Vector2=vector();var s:float=v.length_squared();var d:float=deadzone.z
	var r:Vector2=Vector2(MathExtension.k_deg_to_rad*deadzone.x,MathExtension.k_deg_to_rad*deadzone.y)
	var b:bool=s>d*d
	d=deadzone.w;if b and !is_zero_approx(d):
		b=s<=d*d
	if b and !is_zero_approx(r.x*r.y):
		d=MathExtension.clocking_at(v)
		b=MathExtension.radian_inside(d,r.x,r.y)
	value=b

func is_trigger()->bool:
	try_update()
	match action:
		InputTrigger.Action.On:return value
		InputTrigger.Action.Off:return !value
		InputTrigger.Action.Down:return !previous and value
		InputTrigger.Action.Up:return previous and !value
	return false

func _process(delta:float)->void:
	try_update()
