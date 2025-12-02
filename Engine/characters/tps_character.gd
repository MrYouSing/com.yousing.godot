class_name TpsCharacter extends CharacterController

@export_group("Arguments")
@export var lock:bool
@export var speed:float=5.0
@export var smooth:Vector2=Vector2(-1,60)
@export var blend:StringName
@export var animations:Array[StringName]

var moving:bool

func set_enabled(b:bool)->void:
	super.set_enabled(b)
	moving=false

func get_facing(v:Vector3)->Vector3:
	if motor!=null:motor.direction=Vector3.ZERO# Reset for realtime.
	if lock:return input_to_world(Vector2.DOWN) 
	elif !v.is_zero_approx():return v.normalized()
	else:return get_rotation()*Vector3.BACK

func sync_animation(v:Vector3)->void:
	if animator==null or motor==null:return
	if v.is_zero_approx() or blend.is_empty():return
	#
	var u:Vector2;
	if lock:u=world_to_animation(v)
	else:u=Vector2.DOWN
	animator.set(blend,u)

func play_animation(k:StringName)->void:
	if motor!=null:
		var i:int=animations.find(k)
		if i>=0:motor.state=i;return
	motor.state=-1
	super.play_animation(k)

func _process(delta:float)->void:
	if motor==null:return
	# Get
	var v:Vector3=input_to_world(get_move())*speed;
	var d:Vector3;var b=!v.is_zero_approx();
	# Apply
	motor.direction=get_facing(v)
	motor.velocity=MathExtension.vec3_lerp(motor.velocity,v,smooth,delta)
	if !moving and b:sync_animation(v)
	else:sync_animation(motor.velocity)
	moving=b
