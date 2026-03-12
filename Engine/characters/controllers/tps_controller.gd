class_name TpsController extends CharacterController

@export_group("Arguments")
@export var lock:bool
@export var target:Node3D
@export var speed:float=5.0
@export var smooth:Vector2=Vector2(-1,60)
@export_group("Animations")
@export var move:StringName=&"Move"
@export var blend:Vector2=Vector2(-1,60)
@export var threshold:Vector2=Vector2(0.1,5.0)
@export var anims:PackedStringArray
@export var shots:PackedStringArray

var moving:bool

func set_enabled(b:bool)->void:
	super.set_enabled(b)
	moving=false

func set_model(m:Node3D)->void:
	var a:Actor=model as Actor;if a!=null:
		var t:Node3D=a.get_component(&"LookAt")
		if t!=null:t.reparent(model,true);
	super.set_model(m)
	a=model as Actor;if a!=null and target!=null:
		var t:Node3D=a.get_component(&"LookAt")
		if t!=null:t.reparent(target,false);t.transform=Transform3D.IDENTITY

func get_facing(v:Vector3)->Vector3:
	if motor!=null:motor.direction=Vector3.ZERO# Reset for realtime.
	if lock:return input_to_world(Vector2.DOWN) 
	elif not v.is_zero_approx():return v.normalized()
	else:return get_rotation()*Vector3.BACK

func sync_animation(v:Vector3,d:float)->void:
	if animator==null or motor==null:return
	if v.is_zero_approx() or move.is_empty():return
	#
	var u:Vector2=Vector2.DOWN
	if lock:u=world_to_animation(v)/threshold.y
	if d>=0.0:
		var w:Vector2=animator.read(move)
		w=MathExtension.vec2_lerp(w,u,blend,d)
		u=MathExtension.vec2_fade(w,u,threshold.x)
	else:
		u=MathExtension.vec2_fade(u,Vector2.ZERO,threshold.x)
	animator.write(move,u)

func play_animation(k:StringName)->void:
	var i:int;var b:bool=true
	if motor!=null:
		motor.state=-1
		i=anims.find(k)
		if i>=0:motor.state=i;b=false
	i=shots.find(k)
	if i>=0:animator.play(k,0)
	#
	if b:super.play_animation(k)

func _process(delta:float)->void:
	if motor==null:return
	# Get
	var v:Vector3=input_to_world(get_move())*speed;
	var d:Vector3;var b=not v.is_zero_approx();
	# Apply
	motor.direction=get_facing(v)
	motor.velocity=MathExtension.vec3_lerp(motor.velocity,v,smooth,delta)
	if not moving and b:sync_animation(v,-1.0)
	else:sync_animation(motor.velocity,delta)
	moving=b
