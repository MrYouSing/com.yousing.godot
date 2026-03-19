## A helper class for playing upper-body animations.
class_name FsmGesture extends FsmAction

@export_group("Main","main_")
@export var main_layer:int=0
@export var main_anim:Array[StringName]=[&"Idle",&"Move"]
@export var main_args:Vector4=Vector4(0.25,1.0,0.25,1.0)
@export_group("Gesture","gest_")
@export var gest_layer:int=1
@export var gest_anim:StringName=&"Hello"
@export var gest_args:Vector4=Vector4(0.25,1.0,0.25,1.0)
@export_group("Misc")
@export var gearbox:FsmGearbox

func _set(k:StringName,v:Variant)->bool:
	match k:
		&"animation":
			var s:String=v
			if not s.is_empty():
				if s.find(",")>=0:
					var p:PackedStringArray=s.split(",")
					main_anim[0]=p[0];s=p[1]
				gest_anim=s;return true
	return false

func _on_layer(a:Animator,i:int,v:Vector4,m:int)->void:
	if a==null:return
	var l:AnimatorLayer=a.get_layer(i%32)
	if l==null:return
	if m&0x01!=0:_on_layer_weight(a,l,1.0,v.x)
	elif m&0x02!=0:_on_layer_weight(a,l,0.0,v.z)
	if v.y==v.w:return
	if m&0x04!=0:_on_layer_speed(a,l,v.y,v.x)
	elif m&0x08!=0:_on_layer_speed(a,l,v.w,v.z)

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
			_on_layer(a,main_layer,main_args,0x04)
			if a.has_layer(gest_layer):
				a.play(gest_anim,gest_layer)
				_on_layer(a,gest_layer,gest_args,0x05)

func _on_exit()->void:
	var c:CharacterController=get_character()
	if c!=null:
		if gearbox!=null:gearbox._on_motor(c,c.motor,false)
		var a:Animator=c.animator;if a!=null:
			Tweenable.kill_tween(a)
			#
			a.stop(0xF000|(1<<main_layer)|(1<<gest_layer))
			_on_layer(a,main_layer,main_args,0x08)
			if a.has_layer(gest_layer):
				_on_layer(a,gest_layer,gest_args,0x0A)
	#
	if duration>0.0:FsmEvent.invoke_signal(self,finished,LangExtension.k_empty_array)
