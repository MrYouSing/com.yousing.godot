class_name TpsCamera extends Node3D

@export_group("Camera")
@export var pivot:Node3D
@export var camera:Node3D
@export var head:Node3D
@export var zoom:float=10.0
@export var ball:float=0.5
@export var smooth:Vector2=Vector2(-1.0,60.0)
@export_group("Input")
@export var input:PlayerInput
@export var cursor:bool=true
@export var speed:Vector2=Vector2(10.0,10.0)
@export var range:Vector4=Vector4(-90.0,0.0,90.0,0.0)
@export_group("Scene")
@export var lock:bool=false
@export var target:Node3D
@export var exclude:Array[PhysicsBody3D]

var ray:=PhysicsRayQueryParameters3D.new()
var rot:=Vector3.ZERO

func _ready()->void:
	if camera:camera.rotation=Vector3(0.0,PI,0.0)
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
		from=to+pivot.global_basis.get_rotation_quaternion()*Vector3(0.0,0.0,-zoom)
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
