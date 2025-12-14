class_name AxisTrigger extends InputTrigger

@export_group("Axes")
@export var axis:int
@export var axes:Array[StringName]
@export_range(0.0,1.0,0.001) var deadzone:float=0.0

var value:bool
var previous:bool
var timestamp:int=-1

func try_update()->void:
	var n:int=GodotExtension.get_frames()
	if n!=timestamp:
		timestamp=n
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
	value=vector().length_squared()>deadzone*deadzone

func is_trigger()->bool:
	try_update()
	match action:
		InputTrigger.Action.On:return value
		InputTrigger.Action.Off:return !value
		InputTrigger.Action.Down:return !previous and value
		InputTrigger.Action.Up:return previous and !value
	return false

func _process(delta: float)->void:
	try_update()
