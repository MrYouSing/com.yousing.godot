## A tool class for [Control] detection.
class_name UIDetector extends Node

@export_group("UI")
@export_flags_3d_physics var canvas:int
@export_flags_3d_physics var layer:int=-1
@export var blacklist:PackedStringArray

var results:Array[Control]

func visual_control(c:Control)->bool:
	return c.visible and not is_zero_approx(c.modulate.a*c.self_modulate.a)

func valid_control(c:Control)->bool:
	return layer&c.visibility_layer!=0 and not blacklist.has(c.get_class())

func detect_control(c:Control,p:Vector2)->bool:
	if c!=null:
		if valid_control(c):
			if c.has_method(&"_has_point"):
				var t:Transform2D=c.get_global_transform_with_canvas()
				return c._has_point(t.inverse()*p)
			else:
				return UITransform.has_point(c,p)
	return false

func detect_deep(n:Node,p:Vector2)->void:
	if n!=null:var c:Control;for it in n.get_children():
		c=it as Control
		if c==null:detect_deep(it,p);continue
		if visual_control(c):
			if detect_control(c,p):results.append(c)
			detect_deep(c,p)

func detect_layer(l:int,p:Vector2)->void:
	var c:UICanvas=UICanvas.instances[l]
	if c!=null:detect_deep(c,p)

func detect_point(p:Vector2)->int:
	results.clear()
	if canvas==0:detect_deep(get_viewport(),p)
	else:for i in 32:if canvas&(1<<i)!=0:detect_layer(i,p)
	return results.size()

func detect_mouse()->int:
	return detect_point(PointerInput.get_mouse_position(DisplayServer.MAIN_WINDOW_ID))
