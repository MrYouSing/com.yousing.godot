## A base class for on-screen elements.
class_name OnScreenControl extends Node

static func get_position(c:Control)->Vector2:
	if c!=null:return MathExtension.rect_position(c.get_global_rect(),c.pivot_offset_ratio)
	else:return Vector2.ZERO

static func in_area(c:Control,p:Vector2)->bool:
	if c!=null:return MathExtension.rect_contain(c.get_global_rect(),p)
	else:return true

static func set_color(g:CanvasItem,c:Color,f:float=0.0)->void:
	if g==null:return
	if is_zero_approx(f):Tweenable.kill_tween(g);g.modulate=c
	else:Tweenable.make_tween(g).tween_property(g,^"modulate",c,f)

static func set_image(g:CanvasItem,c:Color,t:Texture2D,f:float=0.0)->void:
	if g==null:return
	if t!=null:g.set(&"texture",t)
	set_color(g,c,f)

static func set_size(g:Shape2D,s:Vector2)->void:
	if g==null:
		pass
	elif g is CircleShape2D:
		g.radius=(s.x+s.y)*0.25
	elif g is RectangleShape2D:
		g.size=s
	elif g is CapsuleShape2D:
		g.radius=s.x*0.5
		g.height=s.y

@export_group("Control")
@export var layer:int

func register(b:bool)->void:
	LangExtension.throw_exception(self,LangExtension.e_not_implemented)

func refresh()->void:
	LangExtension.throw_exception(self,LangExtension.e_not_implemented)

func dirty()->bool:
	LangExtension.throw_exception(self,LangExtension.e_not_implemented)
	return false

func draw()->void:
	LangExtension.throw_exception(self,LangExtension.e_not_implemented)

func is_handled_input()->bool:
	return get_meta(&"Handled",true)

func set_enabled(b:bool)->void:
	var a:bool=get_meta(&"Unhandled",false)
	set_process(b)
	set_process_input(not a and b)
	set_process_unhandled_input(a and b)
	if b:draw()

func _ready()->void:
	UICanvas.register(self,layer,refresh)
	register(true)
	refresh()
	set_enabled(is_processing())

func _exit_tree()->void:
	register(false)
	UICanvas.unregister(self,layer,refresh)

func _process(d:float)->void:
	if dirty():draw()
