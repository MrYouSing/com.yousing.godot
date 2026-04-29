## A menu class with context.
class_name UISubmenu extends UIMenu

@export_group("SubMenu")
@export var context:Node
@export var layout:UIPopup
@export var arrow:Node
@export var loop:bool

var index:int=-1

func select(i:int)->void:
	index=i
	GodotExtension.add_node(arrow,menu.get_child(i),false)

func show()->void:
	super.show()
	#
	if not is_popup():
		if context!=null:
			if context.has_method(&"set_pause"):context.set_pause(true)
			else:GodotExtension.set_enabled(context,false)
		if layout!=null:layout.run()
		select(0)

func hide()->void:
	super.hide()
	#
	index=-1
	if not is_popup():
		if context!=null:
			if context.has_method(&"set_pause"):context.set_pause(false)
			else:GodotExtension.set_enabled(context,true)

func _ready()->void:
	super._ready()
	if layout!=null:
		GodotExtension.meta_node(self,&"Canvas",layout,&"canvas")
		GodotExtension.meta_node(self,&"Cursor",layout,&"cursor")
	super.hide()

func _process(d:float)->void:
	super._process(d)
	if index>=0:
		var i:int=index;var m:UIManager=UIManager.instance
		if m.is_trigger(0):i=MathExtension.int_wrap(i-1,menu.get_child_count(),loop)
		elif m.is_trigger(1):i=MathExtension.int_wrap(i+1,menu.get_child_count(),loop)
		if i!=index:select(i);return
		if m.is_tap(4):_on_click(index)
		elif m.is_tap(5):hide()
