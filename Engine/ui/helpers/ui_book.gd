## A controller class that displays a single content from the collection.
class_name UIBook extends Node

@export_group("Book")
@export var content:Node
@export var property:StringName
@export var book:Resource
@export var pages:Array[Node]

var index:int=-1
var key:StringName

var value:Variant:
	get():
		if index>=0:
			if book!=null:return book.get_page(index)
			return pages[index]
		return null
	set(x):
		match typeof(x):
			TYPE_INT:seek(x)
			TYPE_STRING,TYPE_STRING_NAME:open(x)
			TYPE_OBJECT:
				if book!=null:seek(book.find_page(x))
				else:seek(pages.find(x))

func set_enabled(b:bool)->void:
	if content==self:set(&"visible",b)
	else:GodotExtension.set_enabled(content,b)

func show()->void:set_enabled(true)
func hide()->void:set_enabled(false)

func count()->int:
	if book!=null:return book.count()
	else:return pages.size()

func display(v:Variant)->void:
	if content!=null:content.set(property,v)

func seek(p:int)->void:
	#
	if p==index:return
	index=p
	#
	if book!=null:
		display(book.get_page(p))
	else:
		key=LangExtension.k_empty_name;var b:bool
		var i:int=-1;for it in pages:
			i+=1;if it==null:continue
			b=i==p;if b:key=it.name
			GodotExtension.set_enabled(it,b)

func open(p:StringName)->void:
	#
	if p==key:return
	key=p
	#
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
