## A tool class for dragging scroll view.
class_name UIScroll extends AbsDrag

@export_group("Scroll")
@export var layer:int
@export var scroll:Node
@export var scale:Vector2=Vector2(1.0,-1.0)
@export var bar_h:StringName=&"get_h_scroll_bar"
@export var bar_v:StringName=&"get_v_scroll_bar"

func get_bar(k:StringName)->float:
	if scroll!=null:
		var b:ScrollBar=scroll.call(k)
		if b!=null:return b.value
	return 0.0

func set_bar(k:StringName,v:float)->void:
	if scroll!=null:
		var b:ScrollBar=scroll.call(k)
		if b!=null:b.value=v

func screen_point(p:Vector2)->Vector2:
	p=super.screen_point(p)
	var c:UICanvas=UICanvas.instances[layer]
	if c!=null:p*=c.screen_to_ui
	return p

func handle_input(e:InputEvent)->void:
	pass

func get_point()->Vector2:
	return Vector2(get_bar(bar_h),get_bar(bar_v))*scale

func set_point(p:Vector2)->void:
	p*=scale;set_bar(bar_h,p.x);set_bar(bar_v,p.y)

func _on_begin()->void:
	if scroll==null:scroll=area

func _on_change()->void:
	pass

func _on_end()->void:
	pass
