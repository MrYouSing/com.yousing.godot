class_name OpenKCCMotor extends CharacterMotor

@export_group("OpenKCC")
@export var body:OpenKCCBody3D
@export var slide:bool
@export var model:Node3D
@export var rotation:Vector2=Vector2(-1,60.0)

func _process(delta:float)->void:
	if body==null:return
	#
	update_rotation(model,direction,body.up,rotation,delta)

func _physics_process(delta:float)->void:
	if body==null:return
	#
	if velocity.is_zero_approx():
		body.sleeping=true
	else:
		var m:Vector3=velocity*delta;
		if slide:body.move_and_slide(m)
		else:body.move_and_collide(m);body.check_grounded()
	#
	if body.is_on_floor():body.snap_to_ground()

func is_on_floor()->bool:
	if body!=null:return body.is_on_floor()
	return true
