class_name CharacterController extends Node

@export_group("Character")
@export var root:Node3D
@export var normal:Vector3=Vector3.UP
@export var viewer:Node3D
@export var model:Node3D
@export var input:PlayerInput
@export var motor:CharacterMotor
@export var animator:Animator

func set_model(m:Node3D)->void:
	if m==null:
		if model!=null:
			pass
		# Clean up.
		model=null
		animator=null
	else:
		if m!=model:
			m.set_parent(root);m.transform=Transform3D.IDENTITY
		model=m
		#
		animator=model.get_node_or_null(^"./Animator")
		if animator!=null:
			var n:Node=motor;if n==null:n=self
			animator.setup(n)

func set_enabled(b:bool)->void:
	set_process(b)
	set_physics_process(b)

func get_rotation()->Quaternion:
	if motor!=null:
		var v=motor.direction
		if !v.is_zero_approx():
			v.y=0.0;return MathExtension.looking_at(v,normal)
	var t:Node3D=model;if t==null:t=root
	return MathExtension.get_heading(t.global_basis,normal)

func get_move()->Vector2:
	if input!=null:return input.stick(0);
	else:return Input.get_vector("left","right","backward","forward")#,"down","up")

## From [constant Vector3.UP] to [constant Vector3.FORWARD].
func input_to_world(i:Vector2)->Vector3:
	var v:Vector3=Vector3(i.x,0.0,-i.y)
	if viewer!=null:v=MathExtension.get_heading(viewer.global_basis,normal)*v
	return v

## From [constant Vector3.MODEL_LEFT] to [constant Vector2.LEFT].
func world_to_animation(i:Vector3)->Vector2:
	i=get_rotation().inverse()*i
	return Vector2(-i.x,i.z)

func play_animation(k:StringName)->void:
	if animator!=null:animator.play(k,0)
	if motor!=null:motor.anim=k

func _ready()->void:
	set_model(model)
