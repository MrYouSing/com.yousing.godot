class_name FsmAnimation extends FsmAction

@export_group("Animation")
@export var sleep:bool=true

func on_enter()->void:
	var c:CharacterController=get_character()
	if c!=null:
		if sleep:
			if c.motor!=null:c.motor.velocity=Vector3.ZERO
			c.set_enabled(false)
		else:
			c.set_enabled(true)
		c.play_animation(name)
	#
	GodotExtension.set_enabled(actor,true)

func on_exit()->void:
	if sleep:
		var c:CharacterController=get_character()
		if c!=null:c.set_enabled(true)
	#
	GodotExtension.set_enabled(actor,false)
