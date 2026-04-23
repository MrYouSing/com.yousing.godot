## A custom implementation for [TabContainer].
class_name UITab extends UIBook

@export_group("Tab")
@export var arrow:Node
@export var icons:Array[Texture]
@export var labels:Array[Node]
@export var images:Array[Node]
@export var views:Array[Node]

func set_enabled(b:bool)->void:
	if index>=0:GodotExtension.set_enabled(views[index],b)

func render(m:int,v:int)->void:
	if v<0 or v>=labels.size():return
	if pages[m]==null:UIExtension.set_text(labels[v],tr(&"None"))
	else:UIExtension.set_text(labels[v],tr(pages[m].name))
	if m<0 or m>=icons.size():return
	UIExtension.set_texture(images[v],icons[m])

func _prepared()->void:
	super._prepared()
	#
	if index>=0:GodotExtension.set_enabled(views[index],false)

func _refreshed()->void:
	super._refreshed()
	#
	var n:int=count()
	render(index,0)
	render((index-1+n)%n,1)
	render((index+1)%n,2)
	GodotExtension.set_enabled(views[index],true)
	if features&0x08!=0:
		if arrow!=null:
			if features&0x04!=0:n=4
			else:n=0
			GodotExtension.add_node(arrow,buttons[n+index],false)
			GodotExtension.set_enabled(arrow,true)
