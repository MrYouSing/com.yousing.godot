## A controller class that displays a single content from the collection.
class_name UIBook extends Node

@export_group("Book")
@export var book:Resource
@export var content:Node
@export var property:StringName
@export var pages:Array[Node]

var index:int

func set_enabled(b:bool)->void:
	GodotExtension.set_enabled(content,b)

func show()->void:set_enabled(true)
func hide()->void:set_enabled(false)

func count()->int:
	if content!=null:return content.count()
	else:return pages.size()

func display(v:Variant)->void:
	if content!=null:content.set(property,v)

func seek(p:int)->void:
	index=p
	if book!=null:
		display(book.get_page(p))
	else:
		var i:int=-1;for it in pages:
			i+=1;if it==null:continue
			GodotExtension.set_enabled(it,i==p)

func open(p:StringName)->void:
	if book!=null:
		index=book.index_of(p)
		display(book.get_page(index))
	else:
		index=-1;var b:bool
		var i:int=-1;for it in pages:
			i+=1;if it==null:continue
			b=it.name==p;if b:index=i
			GodotExtension.set_enabled(it,b)

func prev()->void:
	var n:int=count();seek((index-1+n)%n)

func next()->void:
	var n:int=count();seek((index+1)%n)

func _ready()->void:
	seek(0)
