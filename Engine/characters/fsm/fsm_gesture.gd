## A helper class for playing upper-body animations.
class_name FsmGesture extends FsmAction

@export_group("Main","main_")
@export var main_layer:int=0
@export var main_anim:StringName=&"Idle"
@export var main_speed:Vector4=Vector4(0.25,0.25,1.0,1.0)
@export_group("Gesture","gest_")
@export var gest_layer:int=1
@export var gest_anim:StringName=&"Hello"
@export var gest_weight:Vector2=Vector2(0.25,0.25)

func _on_motor(c:Node,m:Node,b:bool)->void:
	if c==null or m==null:return
	#
	m.velocity=Vector3.ZERO

func _on_layer_weight(a:Animator,l:AnimatorLayer,w:float,t:float)->void:
	if a==null or l==null:return
	if t<0.0:t=absf(w-l.get_weight(a))/-t
	l.tween_weight(a,w,null,t,null)

func _on_layer_speed(a:Animator,l:AnimatorLayer,s:float,t:float)->void:
	if a==null or l==null:return
	if t<0.0:t=absf(s-l.get_speed(a))/-t
	l.tween_speed(a,s,null,t,null)

func _on_enter()->void:
	var c:CharacterController=get_character()
	if c!=null:
		_on_motor(c,c.motor,true)
		if c.animator!=null:
			Tweenable.kill_tween(c.animator)
			#
			if c.animator.has_layer(main_layer):
				c.animator.play(main_anim,main_layer)
			else:
				c.play_animation(main_anim)
			if main_speed.z!=main_speed.w:
				_on_layer_speed(c.animator,c.animator.get_layer(main_layer%32),main_speed.z,main_speed.x)
			if c.animator.has_layer(gest_layer):
				c.animator.play(gest_anim,gest_layer)
				_on_layer_weight(c.animator,c.animator.get_layer(gest_layer),1.0,gest_weight.x)
	#
	GodotExtension.set_enabled(actor,true)

func _on_exit()->void:
	var c:CharacterController=get_character()
	if c!=null:
		_on_motor(c,c.motor,false)
		if c.animator!=null:
			Tweenable.kill_tween(c.animator)
			#
			c.animator.stop(0xF000|(1<<main_layer)|(1<<gest_layer))
			if main_speed.z!=main_speed.w:
				_on_layer_speed(c.animator,c.animator.get_layer(main_layer%32),main_speed.w,main_speed.y)
			if c.animator.has_layer(gest_layer):
				_on_layer_weight(c.animator,c.animator.get_layer(gest_layer),0.0,gest_weight.y)
	#
	GodotExtension.set_enabled(actor,false)
