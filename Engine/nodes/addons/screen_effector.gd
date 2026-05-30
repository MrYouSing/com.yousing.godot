## A wrapper class for [url=https://github.com/ioannis-koukourakis/godot_screen_effects.git]ScreenEffects[/url].
class_name ScreenEffector extends Node

static var s_plugin:Object
static var s_methods:Array[Array]=[
	[&"FovFade",&"GetFovFadeInstanceById",&"AddFovFade",&"StopFovFade",&"SetFovFadeMultiplier"],
	[&"FovShake",&"GetFovShakeInstanceById",&"AddFovShake",&"StopFovShake",&"SetFovShakeForce"],
	[&"MotionBlur",&"GetMotionBlurActive",&"SetMotionBlurActive"],
	[&"RadialBlur",&"GetRadialBlurInstanceById",&"AddRadialBlur",&"StopRadialBlur",&"SetRadialBlurFocusPosition"],
	[&"ScreenBlur",&"GetScreenBlurInstanceById",&"AddScreenBlur",&"StopScreenBlur",&"SetScreenBlurAmount"],
	[&"ScreenFade",&"GetScreenFadeInstanceById",&"AddScreenFade",&"",&""],
	[&"ScreenShake",&"GetScreenShakeInstanceById",&"AddScreenShake",&"StopScreenShake",&"SetScreenShakeForce"],
]

static func init_plugin()->bool:
	if s_plugin==null:
		s_plugin=Engine.get_main_loop().root.get_node_or_null(^"ScreenEffects")
		if s_plugin==null:return false
		#
		var k:StringName;var n:StringName
		for m in s_methods:
			n=m[0]
			for i in m.size()-1:
				k=m[1+i];if k.is_empty():continue
				if k.find(n)<0:
					push_error("{0} can't match {1}!".format([n,k]))
				if not s_plugin.has_method(k):
					push_error("{0} can't match {1}!".format([s_plugin.name,k]))
		#
		s_plugin.process_mode=PROCESS_MODE_ALWAYS
		s_plugin.SetMotionBlurActive(false)
	return true

static func set_camera(c:Camera3D)->void:
	if s_plugin==null:if not init_plugin():return
	#
	s_plugin.SetCamera(c)

static func set_fov(f:float)->void:
	if s_plugin==null:if not init_plugin():return
	#
	s_plugin.mfDefaultFov=f

@export_group("Screen Effect")
@export var enabled:bool=true:
	set=set_enabled
@export_enum(
	"Fov Fade","Fov Shake","Motion Blur","Radial Blur","Screen Blur","Screen Fade","Screen Shake",
)var type:int
@export var args:Array

var _id:int=-1
var _methods:Array[StringName]

func set_enabled(b:bool)->void:
	enabled=b
	match _methods.size():
		3:
			s_plugin.call(_methods[2],b)
		5:
			if _id>=0:# Stop
				var m:StringName=_methods[3]
				if m.is_empty():
					var v:Variant=s_plugin.call(_methods[1],_id)
					if v!=null:v.Stop()
				else:
					s_plugin.call(m,_id)
				_id=-1
			if b:# Play
				match type:
					3:
						if is_class("Node3D"):
							_process(0.0)
							if is_nan(args[4].x):set_process(false);return
					_:
						b=false
				#
				_id=s_plugin.callv(_methods[2],args)
	set_process(b)

func get_instance()->Variant:
	if _id>=0:match _methods.size():
		3:return s_plugin.call(_methods[1])
		5:return s_plugin.call(_methods[1],_id)
	return null

func set_value(v:Variant)->void:
	if _id>=0:match _methods.size():
		5:
			var m:StringName=_methods[4]
			if not m.is_empty():
				s_plugin.call(m,_id,v)

func _on_spawn()->void:
	if enabled:set_enabled(enabled)

func _ready()->void:
	if s_plugin==null:if not init_plugin():return
	#
	var a:Array=s_methods[type]
	if not a.is_typed():
		a=Array(a,TYPE_STRING_NAME,LangExtension.k_empty_name,null)
		s_methods[type]=a
	_methods=a
	#
	set_process(false)
	if enabled and not GodotExtension.in_stage(self):set_enabled(enabled)

func _process(d:float)->void:
	if s_plugin==null:return
	#
	var v:Vector3=GodotExtension.get_global_position(self)
	var u:Vector2=RenderingExtension.world_to_viewport(s_plugin.mCamera,v)
	if is_nan(u.x):
		args[4]=u;set_value(MathExtension.k_vec2_half)
	else:
		args[4]=u;set_value(u)
