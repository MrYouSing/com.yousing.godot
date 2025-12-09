class_name CharacterController extends Node

@export_group("Character")
@export var root:Node3D
@export var normal:Vector3=Vector3.UP
@export var viewer:Node3D
@export var model:Node3D
@export var input:PlayerInput
@export var motor:CharacterMotor
@export var animation:AnimationPlayer
@export var animator:AnimationTree

func set_model(m:Node3D)->void:
	if m==null:
		if model!=null:
			pass
		# Clean up.
		model=null
		animation=null;animator=null
	else:
		if m!=model:
			m.set_parent(root);m.transform=Transform3D.IDENTITY
		model=m
		# Link to the animation system.
		if animation==null:
			animation=model.get_node_or_null(^"./AnimationPlayer")
		if animator==null:
			animator=model.get_node_or_null(^"./AnimationTree")
		#
		if animator!=null:
			GodotExtension.set_anim_player(animator,animation)
			var n:Node=motor;if n==null:n=self
			GodotExtension.set_expression_node(animator,n)

func set_enabled(b:bool)->void:
	set_process(b)
	set_physics_process(b)

func get_rotation()->Quaternion:
	if motor!=null:
		var v=motor.direction
		if !v.is_zero_approx():
			v.y=0.0;return Basis.looking_at(v.normalized(),normal).get_rotation_quaternion()
	var t:Node3D=model;if t==null:t=root
	return MathExtension.get_heading(t.global_basis,normal)

func get_move()->Vector2:
	if input!=null:return input.stick(0);
	else:return Input.get_vector("left","right","backward","forward")#,"down","up")

func input_to_world(i:Vector2)->Vector3:
	var v:Vector3=Vector3(i.x,0.0,-i.y)
	if viewer!=null:v=MathExtension.get_heading(viewer.global_basis,normal)*v
	return v

func world_to_animation(i:Vector3)->Vector2:
	i=get_rotation().inverse()*i
	return Vector2(i.x,-i.z)

func play_animation(k:StringName)->void:
	if motor!=null:motor.anim=k

func _ready()->void:
	set_model(model)
