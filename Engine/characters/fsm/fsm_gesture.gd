## A helper class for playing upper-body animations.
class_name FsmGesture extends FsmAction

@export_group("Main","main_")
@export var main_layer:int=0
@export var main_anim:Array[StringName]=[&"Idle",&"Move"]
@export var main_speed:Vector4=Vector4(0.25,0.25,1.0,1.0)
@export_group("Gesture","gest_")
@export var gest_layer:int=1
@export var gest_anim:StringName=&"Hello"
@export var gest_weight:Vector2=Vector2(0.25,0.25)
@export_group("Misc")
@export var gearbox:FsmGearbox

func _on_layer_weight(a:Animator,l:AnimatorLayer,w:float,t:float)->void:
	if a==null or l==null:return
	l.tween_weight(a,w,null,MathExtension.time_fade(l.get_weight(a),w,t),null)

func _on_layer_speed(a:Animator,l:AnimatorLayer,s:float,t:float)->void:
	if a==null or l==null:return
	l.tween_speed(a,s,null,MathExtension.time_fade(l.get_speed(a),s,t),null)

func _on_enter()->void:
	var c:CharacterController=get_character()
	if c!=null:
		if gearbox!=null:gearbox._on_motor(c,c.motor,true)
		var a:Animator=c.animator;if a!=null:
			Tweenable.kill_tween(a)
			#
			if a.has_layer(main_layer):
				a.context.set(&"state",-1)
				if not main_anim.has(a.get_current(main_layer).name):
					a.play(main_anim[0],main_layer)
			else:
				c.play_animation(main_anim[0])
			if main_speed.z!=main_speed.w:
				_on_layer_speed(a,a.get_layer(main_layer%32),main_speed.z,main_speed.x)
			if a.has_layer(gest_layer):
				a.play(gest_anim,gest_layer)
				_on_layer_weight(a,a.get_layer(gest_layer),1.0,gest_weight.x)
	#
	GodotExtension.set_enabled(actor,true)

func _on_exit()->void:
	var c:CharacterController=get_character()
	if c!=null:
		if gearbox!=null:gearbox._on_motor(c,c.motor,false)
		var a:Animator=c.animator;if a!=null:
			Tweenable.kill_tween(a)
			#
			a.stop(0xF000|(1<<main_layer)|(1<<gest_layer))
			if main_speed.z!=main_speed.w:
				_on_layer_speed(a,a.get_layer(main_layer%32),main_speed.w,main_speed.y)
			if a.has_layer(gest_layer):
				_on_layer_weight(a,a.get_layer(gest_layer),0.0,gest_weight.y)
	#
	GodotExtension.set_enabled(actor,false)
	if duration>0.0:FsmEvent.invoke_signal(self,finished,LangExtension.k_empty_array)
