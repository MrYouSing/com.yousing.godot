## A helper class for playing upper-body animations.
class_name FsmGesture extends FsmAction

@export_group("Main","main_")
@export var main_layer:int=0
@export var main_anim:StringName=&"Idle"
@export_group("Gesture","gest_")
@export var gest_layer:int=1
@export var gest_anim:StringName=&"Hello"

func _on_motor(c:Node,m:Node,b:bool)->void:
	if c==null or m==null:return
	#
	m.velocity=Vector3.ZERO

func _on_enter()->void:
	var c:CharacterController=get_character()
	if c!=null:
		_on_motor(c,c.motor,true)
		if c.animator!=null:
			if c.animator.has_layer(main_layer):
				c.animator.play(main_anim,main_layer)
			else:
				c.play_animation(main_anim)
			if c.animator.has_layer(gest_layer):
				c.animator.play(gest_anim,gest_layer)
	#
	GodotExtension.set_enabled(actor,true)

func _on_exit()->void:
	var c:CharacterController=get_character()
	if c!=null:
		_on_motor(c,c.motor,false)
		if c.animator!=null:
			c.animator.stop(0xF000|(1<<main_layer)|(1<<gest_layer))
	#
	GodotExtension.set_enabled(actor,false)
