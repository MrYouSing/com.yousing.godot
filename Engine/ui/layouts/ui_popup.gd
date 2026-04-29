## A helper class that makes [Popup]-style nodes appear in the correct position.
class_name UIPopup extends Runnable

@export_group("Popup")
@export var layer:int
@export var canvas:Node
@export var cursor:Node
@export var root:UITransform
@export var rects:PackedVector4Array
@export var anchors:PackedVector2Array=[Vector2.DOWN,Vector2.ONE,Vector2.ZERO,Vector2.RIGHT]
@export var pivots:PackedVector2Array=[Vector2.DOWN,Vector2.ONE,Vector2.ZERO,Vector2.RIGHT]

func is_visible()->bool:
	if root==null or root.control==null:return false
	return root.control.is_visible_in_tree()

func get_float(a:float,b:float)->float:
	if b*b<=1.0:
		if b<0.0:return a*(1.0+b)
		else:return a*b
	else:
		if b<0.0:return a+b
		else:return b

func get_point(v:Vector2,x:float,y:float)->Vector2:
	return Vector2(get_float(v.x,x),get_float(v.y,y))

func apply(i:int)->void:
	if root!=null:
		var p:Vector2=anchors[i]
		root.anchor_min=p
		root.anchor_max=p
		root.pivot=pivots[i]
		root.refresh()

func run()->void:
	if not is_visible():return
	#
	var p:Vector2
	if cursor!=null:
		p=cursor.get_global_transform_with_canvas().origin
	else:
		p=PointerInput.get_mouse_position(DisplayServer.MAIN_WINDOW_ID)
	var s:Vector2
	if canvas!=null:
		var m:Transform2D=canvas.get_global_transform_with_canvas()
		p-=m.origin;s=canvas.size*m.get_scale()
	else:
		s=Application.get_resolution()
	if layer>=0:
		var c:UICanvas=UICanvas.instances[layer]
		if c!=null:
			p*=c.screen_to_ui
			s*=c.screen_to_ui
	#
	var n:int=rects.size()-1
	var a:Vector2;var z:Vector2;var w:Vector4
	for i in n:
		w=rects[1+i]
		a=get_point(s,w.x,w.y);z=get_point(s,w.z,w.w)
		if MathExtension.vec2_inside(p,a,z):apply(1+i);return
	apply(0)
