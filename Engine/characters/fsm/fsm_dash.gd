class_name FsmDash extends FsmAction

@export_group("Dash")
@export var direction:Vector3=Vector3.MODEL_FRONT 
@export var speed:float=10.0
@export var curve:Curve
@export var blend:StringName

var lock:bool
var motor:CharacterMotor
var velocity:Vector3

func get_direction(c:CharacterController)->Vector3:
	var v:Vector2=c.get_move();var d:Vector3
	if v.is_zero_approx():d=c.get_rotation()*direction
	else:d=c.input_to_world(v)
	return d

func update_animation(c:CharacterController,d:Vector3)->void:
	if motor!=null:
		if lock:motor.direction=c.input_to_world(Vector2.DOWN)
		else:motor.direction=d
	if c.animator!=null and !blend.is_empty():
		c.animator.set(blend,c.world_to_animation(d))

func on_enter()->void:
	var c:CharacterController=get_character()
	var d:Vector3=Vector3.ZERO
	if c!=null:
		motor=c.motor
		c.set_enabled(false)
		d=get_direction(c)
		# Apply the animation.
		update_animation(c,d)
		c.play_animation(name)
	# Apply the dash.
	if motor!=null:motor.velocity=Vector3.ZERO
	velocity=d*speed
	

func on_tick()->void:
	if motor==null:return
	#
	var v:Vector3=velocity
	if curve!=null:v*=curve.sample_baked(root.time.x/duration)
	motor.velocity=v

func on_exit()->void:
	var c:CharacterController=get_character()
	if c!=null:
		c.set_enabled(true)
	# Clean up.
	motor=null
	velocity=Vector3.ZERO
