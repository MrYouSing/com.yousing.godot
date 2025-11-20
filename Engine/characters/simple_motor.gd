class_name SimpleMotor extends CharacterMotor

@export var model:Node3D
@export var rotation:Vector2=Vector2(-1,60.0)
@export var character:CharacterBody3D
@export var rigidbody:RigidBody3D
@export var position:Vector2=Vector2(-1,60.0)

func _process(delta:float)->void:
	if model==null or direction.length_squared()==0.0:return
	#
	var q=Basis.looking_at(-direction,Vector3.UP)
	model.quaternion=MathExtension.quat_lerp(model.quaternion,q.get_rotation_quaternion(),rotation,delta)
	
func  _physics_process(delta:float)->void:
	if character!=null:
		character.velocity=velocity;character.move_and_slide()
	elif rigidbody!=null:
		rigidbody.linear_velocity=velocity;

func is_on_floor()->bool:
	if character!=null:
		return character.is_on_floor()
	elif rigidbody!=null:
		pass
	return true
