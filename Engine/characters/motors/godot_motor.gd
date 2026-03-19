class_name GodotMotor extends CharacterMotor

@export var model:Node3D
@export var rotation:Vector2=Vector2(-1,60.0)
@export var character:CharacterBody3D
@export var rigidbody:RigidBody3D
@export var collide:bool

var _info:KinematicCollision3D

func _process(delta:float)->void:
	var n:Vector3=Vector3.UP
	if character!=null:n=character.up_direction
	update_rotation(model,direction,n,rotation,delta)

func _physics_process(delta:float)->void:
	if character!=null:
		if collide:
			_info=character.move_and_collide(velocity*delta)
		else:
			character.velocity=velocity;character.move_and_slide()
			_info=character.get_last_slide_collision()
	elif rigidbody!=null:
		if collide:
			_info=rigidbody.move_and_collide(velocity*delta)
		else:
			rigidbody.linear_velocity=velocity;
			_info=null

func is_on_floor()->bool:
	if character!=null:
		return character.is_on_floor()
	elif rigidbody!=null:
		pass
	return true
