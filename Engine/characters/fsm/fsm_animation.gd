class_name FsmAnimation extends FsmAction

@export_group("Animation")
@export var sleep:bool=true
@export var animation:StringName

func _on_enter()->void:
	var c:CharacterController=get_character()
	if c!=null:
		if sleep:
			if c.motor!=null:c.motor.velocity=Vector3.ZERO
			c.set_enabled(false)
		else:
			c.set_enabled(true)
		if animation.is_empty():animation=name
		c.play_animation(animation)

func _on_exit()->void:
	if sleep:
		var c:CharacterController=get_character()
		if c!=null:c.set_enabled(true)
