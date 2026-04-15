class_name FsmDash extends FsmAction

@export_group("Dash")
@export var trigger:Node
@export var direction:Vector3=Vector3.MODEL_FRONT 
@export var speed:float=10.0
@export var curve:Curve
@export var blend:StringName

var lock:bool
var stick:Vector2
var motor:CharacterMotor
var velocity:Vector3

func get_direction(c:CharacterController)->Vector3:
	var v:Vector2=c.get_move()
	if v.is_zero_approx():v=stick# Fallback.
	stick=Vector2.ZERO# One-shot.
	#
	if v.is_zero_approx():return c.get_rotation()*direction
	else:return c.input_to_world(v.normalized())

func update_animation(c:CharacterController,d:Vector3)->void:
	if motor!=null:
		if lock:motor.direction=c.input_to_world(Vector2.DOWN)
		else:motor.direction=d
	if c.animator!=null and not blend.is_empty():
		c.animator.write(blend,c.world_to_animation(d))

func _on_init()->void:
	character=get_character()#super._on_init()
	LangExtension.try_signal(trigger,&"triggered",_on_trigger)

func _on_trigger()->void:
	var c:CharacterController=get_character()
	if c!=null:stick=c.get_move()

func _on_enter()->void:
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

func _on_tick()->void:
	if motor==null:return
	#
	var v:Vector3=velocity
	if curve!=null:v*=curve.sample_baked(root.time.x/duration)
	motor.velocity=v

func _on_exit()->void:
	var c:CharacterController=get_character()
	if c!=null:
		c.set_enabled(true)
		if motor!=null:motor.velocity=motor.velocity.project(c.normal)
	else:
		if motor!=null:motor.velocity=Vector3.ZERO
	# Clean up.
	motor=null
	velocity=Vector3.ZERO
	#
	FsmEvent.invoke_signal(self,finished,LangExtension.k_empty_array)
