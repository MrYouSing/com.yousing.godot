class_name TpsCamera extends Node3D

@export_group("Camera")
@export var pivot:Node3D
@export var camera:Node3D
@export var head:Node3D
@export var arm:Vector3=Vector3(0.0,0.0,10)
@export_range(0.0,1.0,0.001,"or_greater","or_less")var side:float=0.5
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
	var to:Vector3=pivot.global_position
	var from:Vector3=Vector3.ZERO
	if lock==true and target!=null:
		pass
	else:
		var q:Quaternion=pivot.global_basis.get_rotation_quaternion()
		to=to+q*Vector3(arm.x*(side-0.5)*2.0,arm.y,0.0)
		from=to+q*Vector3(0.0,0.0,-arm.z)
	#
	if head!=null:to=head.global_position
	from=ray_cast(to,from)
	camera.global_position=MathExtension.vec3_lerp(camera.global_position,from,smooth,delta)

func ray_cast(a:Vector3,b:Vector3)->Vector3:
	var rids:Array[RID];
	for it in exclude:rids.append(it.get_rid())
	var res:Dictionary;
	if ball>0.0:res=Physics.sphere_cast(get_world_3d().direct_space_state,a,b,ball,-1,rids,-1)
	else:res=Physics.ray_cast(get_world_3d().direct_space_state,a,b,-1,rids,-1)
	if res:b=res.position+res.normal*ball
	return b

func _on_state(c:Object,k:StringName,v:Variant,t:Transition)->void:
	var l:Lens=v;if l==null:return
	if l.settings.has(&"lock"):lock=l.settings.lock
	if t==null or t.instant():
		l.direct_to_camera_3d(cam)
		if l.settings.has(&"arm"):arm=l.settings.arm
	else:#Tween
		var tmp=Tweenable.cast_tween(c)
		l.tween_to_camera_3d(cam,tmp,t);Transition.current=self
		if l.settings.has(&"arm"):t.to_tween(tmp,self,^"arm",l.settings.arm)
