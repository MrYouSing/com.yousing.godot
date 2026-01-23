## A stick control displayed on screen and moved around by touch.
class_name OnScreenStick extends OnScreenControl

@export_group("Stick")
@export_flags(
	"Hide","Dynamic","Follow"
)var features:int:
	set(x):features=x;if is_node_ready():_featured()
@export var actions:Array[StringName]=[&"ui_left",&"ui_right",&"ui_up",&"ui_down",&"ui_move"]
@export_group("Nodes")
@export var area:Control
@export var pivot:Control
@export var thumb:Control
@export var arrow:Control
@export_group("Arguments")
@export var smooth:Vector2=Vector2(-1,60)
@export var lengths:Array[float]
@export var fades:Array[float]
@export var colors:Array[Color]
@export var images:Array[Texture]

var _touch_id:int=-1
var _pivot_point:Vector2
var _stick_origin:Vector2
var _stick_offset:Vector2
var _stick_level:int=-1
var _stick_value:Vector2

func register(b:bool)->void:
	if b:_featured()

func refresh()->void:
	_pivot_point=get_position(pivot)
	_stick_origin=_pivot_point
	if _touch_id<0:clear()

func dirty()->bool:
	if _touch_id>=0:return false
	#
	var v:Vector2=Input.get_vector(actions[0],actions[1],actions[2],actions[3])*lengths[power()]
	if (v-_stick_offset).length_squared()>=MathExtension.k_epsilon:
		_stick_offset=v;return true
	else:
		return false

func draw()->void:
	var p:Vector2=get_position(pivot)
	var v:Vector2=get_position(thumb)
	v=MathExtension.vec2_lerp(v-p,_stick_offset,smooth,Application.get_delta())
	render(p,v)

func clear()->void:
	var v:Vector2=Vector2.ZERO
	_stick_level=-1
	_stick_value=v
	render(_stick_origin,v)
	InputExtension.set_vector(actions,v)
	for i in actions.size()-4:InputExtension.set_button(actions[4+i],false)

func value()->Vector2:
	if _touch_id>=0:return _stick_value
	else:return Vector2.ZERO

func power()->int:
	var n:int=actions.size()-5;var j:int;for i in n:
		j=n-1-i;if Input.is_action_pressed(actions[5+j]):return 2+j
	return 1

func level(v:Vector2)->int:
	var s:float=v.length_squared()
	var i:int=-1;for it in lengths:
		i+=1;if s<=it*it+1:return i
	return i

func show(b:bool)->void:
	GodotExtension.set_enabled(pivot,b)
	GodotExtension.set_enabled(thumb,b)

func render(p:Vector2,v:Vector2)->void:
	_stick_offset=v
	pivot.global_position=UITransform.get_position(pivot,p)
	thumb.global_position=UITransform.get_position(thumb,p+v)
	#
	var g:Control=thumb;if arrow!=null:# Error rect caused by rotation.
		g=arrow;g.rotation=MathExtension.clocking_at(v)
	var i:int=level(v);if i!=_stick_level:
		_stick_level=i
		set_image(g,colors[i],images[i],fades[i])

func touch(e:InputEvent)->void:
	if e!=null:
		var v:Vector2=e.position
		if features&0x02!=0:_stick_origin=v
		drag(v)
		if features&0x01!=0:show(true)
	else:
		_stick_origin=_pivot_point
		clear()
		if features&0x01!=0:show(false)

func drag(p:Vector2)->void:
	var v:Vector2=p-_stick_origin
	var s:float=v.length_squared()
	var d:float=lengths[-1]
	if s>d*d:
		v*=d/sqrt(s)
		if features&0x06==0x06:_stick_origin=p-v
	render(_stick_origin,v)
	#
	var j:int=level(v)-2
	if !actions[4].is_empty():InputExtension.set_button(actions[4],j>=-1)
	for i in actions.size()-5:
		InputExtension.set_button(actions[5+i],i==j)
	#
	v=v/lengths[1]
	s=v.length_squared();if s>1.0:v/=sqrt(s)
	else:d=lengths[0];if s<=d*d:v=Vector2.ZERO
	_stick_value=v
	InputExtension.set_vector(actions,v)

func _featured()->void:
	if features&0x01!=0:show(false)
	else:show(true)

func _input(e:InputEvent)->void:
	var b:bool=false
	#
	if e is InputEventScreenTouch:
		if e.pressed and in_area(area,e.position):
			if _touch_id<0:
				_touch_id=e.index
				touch(e)
				b=true
		else:
			if _touch_id==e.index:
				touch(null)
				_touch_id=-1
				b=true
	elif e is InputEventScreenDrag:
		if _touch_id==e.index:
			drag(e.position)
			b=true
	#
	if b:get_viewport().set_input_as_handled()
