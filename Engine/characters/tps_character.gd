class_name TpsCharacter extends CharacterController

@export_group("Arguments")
@export var lock:bool
@export var speed:float=5.0
@export var smooth:Vector2=Vector2(-1,60)

func _process(delta:float)->void:
	if motor==null:return
	var v:Vector3=to_world(get_move()*speed);var d:Vector3
	#
	if lock:d=to_world(Vector2.UP) 
	elif v.length()!=0.0:d=v.normalized()
	elif model!=null:d=MathExtension.get_heading(model.global_basis)*Vector3.BACK
	#
	motor.direction=d
	motor.velocity=MathExtension.vec3_lerp(motor.velocity,v,smooth,delta)
