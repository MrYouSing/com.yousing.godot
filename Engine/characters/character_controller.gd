class_name CharacterController extends Node

@export_group("Components")
@export var root:Node3D
@export var viewer:Node3D
@export var model:Node3D
@export var input:PlayerInput
@export var motor:CharacterMotor

func get_move()->Vector2:
	if input!=null:return input.stick(0);
	else:return Input.get_vector("left","right","backward","forward")#,"down","up")

func to_world(i:Vector2)->Vector3:
	var v:Vector3=Vector3(i.x,0.0,-i.y)
	if viewer!=null:v=MathExtension.get_heading(viewer.global_basis)*v
	return v
