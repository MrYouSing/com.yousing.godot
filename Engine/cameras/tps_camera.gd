class_name TpsCamera extends Node3D

@export_group("Camera")
@export var pivot:Node3D
@export var camera:Node3D
@export var head:Node3D
@export var arm:Vector3=Vector3(0.0,0.0,10)
@export_range(0.0,1.0,0.001,"or_greater", "or_less")var side:float=0.5
@export_group("Input")
@export var input:PlayerInput
@export var cursor:bool=true
@export var speed:Vector2=Vector2(10.0,10.0)
@export var range:Vector4=Vector4(-90.0,0.0,90.0,0.0)
@export_group("Scene")
@export var lock:bool=false
@export var target:Node3D
@export var exclude:Array[CollisionObject3D]
@export var ball:float=0.5
@export var smooth:Vector2=Vector2(-1.0,60.0)

var ray:=PhysicsRayQueryParameters3D.new()
var rot:=Vector3.ZERO
var cam:Camera3D

func _ready()->void:
	if camera!=null:
		camera.rotation=Vector3(0.0,PI,0.0)
		if camera is Camera3D:cam=camera
	if cursor:Input.mouse_mode=Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent)->void:
	if cursor:
		if event is InputEventKey and event.physical_keycode==KEY_ESCAPE:
			Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
		if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.pressed:
			Input.mouse_mode=Input.MOUSE_MODE_CAPTURED

func _process(delta:float)->void:
	if pivot==null:return
	#
	var v:Vector2;
	if input!=null:v=input.get_stick(1)*delta
	else: v=Input.get_last_mouse_velocity()*(delta*PlayerInput.mouse_to_stick)
	v.x*=-1.0# Fix the Y-Axis.
	rot.y=MathExtension.float_clamp(rot.y+v.x*speed.x,range.y,range.w)
	rot.x=MathExtension.float_clamp(rot.x+v.y*speed.y,range.x,range.z)
	pivot.global_rotation=Vector3(deg_to_rad(rot.x),deg_to_rad(rot.y),rotation.z)

func _physics_process(delta:float)->void:
	if camera==null or pivot==null:return
	# 
	var world:=get_world_3d()
	var to:Vector3=pivot.global_position
	var from:Vector3=Vector3.ZERO
	if lock==true and target!=null:
		pass
	else:
		var v:Vector3=Vector3(arm.x*(side-0.5)*2.0,arm.y,-arm.z)
		from=to+pivot.global_basis.get_rotation_quaternion()*v
	# 
	if head==null:ray.from=to
	else:ray.from=head.global_position
	ray.to=from
	ray.hit_back_faces=true
	ray.hit_from_inside=true
	
	var as_array_rid:Array[RID]
	for phys_obj in exclude:as_array_rid.append(phys_obj.get_rid())
	ray.exclude=as_array_rid

	var res:=world.direct_space_state.intersect_ray(ray)
	if res:from=res.position+res.normal*ball
	camera.global_position=from#MathExtension.vec3_lerp(camera.global_position,from,smooth,delta)

func _on_state(c:StateMachine,k:StringName,v:Variant,t:Transition)->void:
	var w:Vector4=v;var u=Vector3(w.x,w.y,w.z);lock=w.z>0.0
	if t==null or t.duration==0.0:#Instant
		arm=u
		if cam!=null:cam.fov=absf(w.w)
	else:#Tween
		var tmp:Tween=c.get_tween();
		t.to_tween(tmp,self,"arm",u)
		if cam!=null:t.to_tween(tmp,cam,"fov",absf(w.w),true)
	
