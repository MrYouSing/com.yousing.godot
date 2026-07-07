## A helper class for the full screen pause.
class_name ScreenFreezer extends Activatable

static var current:ScreenFreezer

@export_group("Screen")
@export var camera:int
@export var effect:Fadeable
@export var canvas:CanvasItem
@export var viewport:Viewport
@export var target:Node

var _tween:Tween
var _texture:Texture

func _on_stop()->void:
	super._on_stop()
	_tween=null

func _on_show()->void:
	GodotExtension.set_enabled(effect,true)# Blur.OnEnter()
	#
	_tween=Tweenable.current
	if _tween!=null and effect!=null:
		_tween.pause()
		effect.entered.connect(_on_prepare,CONNECT_ONE_SHOT)# UI.OnEnter()
	else:
		_on_prepare()

func _on_hide()->void:
	_on_camera(true)
	#
	_tween=Tweenable.current
	if _tween!=null:# UI.OnExit()
		_tween.finished.connect(GodotExtension.set_enabled.bind(effect,false))
		_tween.finished.connect(_on_texture.bind(null))
	else:# Blur.OnExit()
		GodotExtension.set_enabled(effect,false)
		_on_texture(null)

func _on_prepare()->void:
	LangExtension.defer_signal(RenderingServer.frame_post_draw,_on_freeze,self,&"_version")

func _on_freeze()->void:
	if canvas!=null:
		pass
	else:
		var v:Viewport=viewport
		if v==null:v=get_tree().root# Main Viewport.
		if v==null:return
		#
		var t:Texture=v.get_texture()
		if t!=null:_on_texture(ImageTexture.create_from_image(t.get_image()))
	if Tweenable.is_valid(_tween):_tween.play();_tween=null
	_on_camera(false)

func _on_camera(b:bool)->void:
	if camera>=0:GodotExtension.set_enabled(SubCamera.instances[camera],b)

func _on_texture(t:Texture)->void:
	if _texture!=null:
		_on_clear(target,_texture)
	_texture=t
	if t!=null:
		_on_render(target,_texture)

func _on_render(o:Object,t:Texture)->void:
	if o==null:
		pass
	elif o is MeshInstance3D:
		var m:Material=RenderingExtension.get_material(o)
		if m!=null:m.set(&"shader_parameter/main_tex",t)
		o.visible=true
	elif o is Control:
		o.texture=t;o.visible=true

func _on_clear(o:Object,t:Texture)->void:
	if o==null:
		pass
	else:
		o.set(&"visible",false)

func _started(b:bool)->void:
	if camera<-1:return# Disabled.
	if current==null:return
	#
	var tmp:Fadeable=current.effect;current.effect=effect
	if b:current.show()
	else:current.hide()
	current.effect=tmp

func _ready()->void:
	if process_mode==PROCESS_MODE_DISABLED:return
	Singleton.make_current(ScreenFreezer,self)

func _exit_tree()->void:
	if process_mode==PROCESS_MODE_DISABLED:return
	Singleton.clear_current(ScreenFreezer,self)
