## A helper camera for cutscenes and cinema.
class_name CutCamera extends VirCamera

@export_group("Cut")
@export var root:Node
@export var view:Node
@export var player:AnimationPlayer
@export var smooth:Vector2=Vector2(-1.0,60.0)
@export_flags(
	"Pause","Event","Screen","Exit"
)var features:int

var _root:Node

func set_event(i:int)->void:
	pass

func get_color()->Color:
	return get_meta(&"Background",Color.BLACK)

func set_screen(b:bool)->void:
	if ScreenRenderer.current!=null:
		var c:Color=get_color() if b else Color.TRANSPARENT
		ScreenRenderer.current.set_color(name,c)

func _on_show()->void:
	if features&0x01!=0:Application.pause(true)
	if features&0x02!=0:set_event(0)
	if features&0x04!=0:set_screen(true)
	if features&0x08!=0:LangExtension.remove_signal(ScreenRenderer.current,&"finished",_on_exit)
	if view!=null:view.set(&"visible",true)
	#
	if player!=null:player.stop()
	super._on_show()

func _on_enter()->void:
	if features&0x02!=0:set_event(1)
	if features&0x04!=0:set_screen(false)
	var a:Array;if get_nodes(a):GodotExtension.set_camera(a[0],true);_root=a[1]
	#
	set_process(_root!=null and root!=null)
	if player!=null:player.play(name)

func _on_hide()->void:
	if features&0x01!=0:Application.pause(false)
	if features&0x02!=0:set_event(2)
	if features&0x04!=0:set_screen(true)
	if features&0x0C==0x0C:LangExtension.try_signal(ScreenRenderer.current,&"finished",_on_exit,CONNECT_ONE_SHOT)
	else:_on_exit()
	#
	set_process(false)
	if player!=null:player.stop(true)

func _on_exit()->void:
	if features&0x02!=0:set_event(3)
	if features&0x0C==0x0C:set_screen(false)
	if view!=null:view.set(&"visible",false)
	_root=null;var a:Array;if get_nodes(a):GodotExtension.set_camera(a[0],false)

func _ready()->void:
	set_process(false)
	super._ready()

func _process(d:float)->void:
	var m:Transform3D=GodotExtension.get_global_transform(root)
	_root.global_position=MathExtension.vec3_lerp(_root.global_position,m.origin,smooth,d)
	_root.global_basis=MathExtension.quat_lerp(_root.global_basis,m.basis,smooth,d)
