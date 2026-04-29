## A complex panel for displaying a batch of data.
class_name UIBrowser extends UIPanel

@export_group("Browser")
@export var scroll:ScrollView
@export var view:Node
@export var hint:Node
@export var buttons:Array[Node]
@export var menus:Array[Node]

var menu:Node

func set_enabled(b:bool)->void:
	super.set_enabled(b)
	if b:self.load()
	else:self.save()

func set_pause(b:bool)->void:
	if view!=null:view.set_process(not b)

func set_button(i:int,c:Callable)->Node:
	if i<0 or i>=buttons.size():return null
	var n:Node=buttons[i]
	LangExtension.try_signal(n,&"pressed",c)
	return n

func set_hint(i:int)->void:
	if hint!=null:hint.seek(i)

func set_menu(i:int)->void:
	GodotExtension.set_enabled(menu,false)
	if i>=0:menu=menus[i]
	else:menu=null
	GodotExtension.set_enabled(menu,true)

func build()->void:
	pass

func render()->void:
	pass

func save()->void:
	pass

func load()->void:
	pass

func refresh()->void:
	save()
	render()

func _ready()->void:
	super._ready()
	build()
