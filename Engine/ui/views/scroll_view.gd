## A scrollable view that shows part of content.
class_name ScrollView extends Container

const k_interface:Array[StringName]=[&"set_scroll",&"get_focus"]

@export_group("Scroll")
@export var style:UIStyle
@export var rate:int
@export var scroll:ScrollContainer
@export var view:Control
@export var content:Control

var _busy:bool

func refresh()->void:
	if style==null:return
	_busy=true
	#
	var p:Vector2=view.global_position-global_position
	var i:Vector2i=style.layout_index(p)
	var s:Vector2=style.layout_point(i)
	p=style.layout_local(p-s)
	i=content.set_scroll(style,i,p)
	p=style.layout_size((i*style.layout_mask).maxi(1.0))
	fit_child_in_rect(content,Rect2(s,p))
	custom_minimum_size=p
	_busy=false

func _focus()->void:
	if _busy:return
	var i:Vector2i=content.get_focus();if i.x<0:return
	var p:Vector2=style.layout_point(i*style.layout_mask)
	scroll.scroll_horizontal=p.x
	scroll.scroll_vertical=p.y
	# Update position.
	i=style.layout_index(p)
	p=style.layout_point(i)
	fit_child_in_rect(content,Rect2(p,content.size))

func _ready()->void:
	if view==null:view=get_parent()
	if scroll==null:scroll=view
	if content==null:content=get_child(0)
	#
	if style==null:return
	if scroll==null or view==null or content==null:
		style=null;return
	if !LangExtension.class_is(content,k_interface):
		Application.debug(content.name+" is not ScrollView.Content!",3);content=null
		style=null;return
	style.layout_apply(content)
	var c:Control=content.get(&"prefab");if c!=null:style.layout_apply(c)
	LangExtension.add_signal(content,&"on_focus",_focus)

func _process(d:float)->void:
	if rate<=0 or Application.get_frames()%rate==0:
		refresh()

func _notification(i:int)->void:
	match i:
		NOTIFICATION_SORT_CHILDREN:refresh()
