class_name TpsDash extends FsmDash

@export_group("TPS")
@export var dpad:Vector4=Vector4.ZERO

func update_animation(c:CharacterController,d:Vector3)->void:
	super.update_animation(c,d)

func _on_enter()->void:
	#
	var c:TpsCharacter=get_character()
	lock=c.lock
	#
	super._on_enter()
