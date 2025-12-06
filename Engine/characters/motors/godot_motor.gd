class_name GodotMotor extends CharacterMotor

@export var model:Node3D
@export var rotation:Vector2=Vector2(-1,60.0)
@export var character:CharacterBody3D
@export var rigidbody:RigidBody3D
@export var position:Vector2=Vector2(-1,60.0)

func _process(delta:float)->void:
	var n:Vector3=Vector3.UP
	if character!=null:n=character.up_direction
	update_rotation(model,direction,n,rotation,delta)

func _physics_process(delta:float)->void:
	if character!=null:
		var pos:Vector3=character.global_position
		character.velocity=velocity;character.move_and_slide()
		#if character.is_on_wall():
		#	character.global_position=pos
	elif rigidbody!=null:
		rigidbody.linear_velocity=velocity;

func is_on_floor()->bool:
	if character!=null:
		return character.is_on_floor()
	elif rigidbody!=null:
		pass
	return true
