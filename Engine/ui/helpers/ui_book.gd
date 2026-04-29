## A controller class that displays a single content from the collection.
class_name UIBook extends Node

@export_group("Book")
@export_flags(
	"Loop","Force","Control","Page",
)var features:int=0x03
@export var content:Node
@export var property:StringName
@export var book:Resource
@export var pages:Array[Node]
@export var buttons:Array[Node]

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
	_prepared()
	index=p;key=LangExtension.k_empty_name
	#
	if book!=null:
		display(book.get_page(p))
	elif features&0x02==0:
		var it:Node=pages[index]
		if it!=null:
			key=it.name
			GodotExtension.set_enabled(it,true)
	else:
		var b:bool
		var i:int=-1;for it in pages:
			i+=1;if it==null:continue
			b=i==p;if b:key=it.name
			GodotExtension.set_enabled(it,b)
	_refreshed()

func open(p:StringName)->void:
	#
	if p==key:return
	_prepared()
	key=p;index=-1
	#
	if book!=null:
		index=book.index_of(p)
		display(book.get_page(index))
	elif features&0x02==0:
		var i:int=-1;for it in pages:
			i+=1;if it==null:continue
			if it.name==p:
				index=i
				GodotExtension.set_enabled(it,true)
				break
	else:
		var b:bool
		var i:int=-1;for it in pages:
			i+=1;if it==null:continue
			b=it.name==p;if b:index=i
			GodotExtension.set_enabled(it,b)
	_refreshed()

func prev()->void:
	var n:int=count()
	if features&0x01!=0:seek((index-1+n)%n)
	else:seek(clampi(index-1,0,n-1))

func next()->void:
	var n:int=count()
	if features&0x01!=0:seek((index+1)%n)
	else:seek(clampi(index+1,0,n-1))

func first()->void:
	seek(0)

func last()->void:
	seek(count()-1)

func build()->void:
	var b:int=0
	if features&0x04!=0:
		LangExtension.try_signal(buttons[b],&"pressed",prev);b+=1
		LangExtension.try_signal(buttons[b],&"pressed",next);b+=1
		LangExtension.try_signal(buttons[b],&"pressed",first);b+=1
		LangExtension.try_signal(buttons[b],&"pressed",last);b+=1
	if features&0x08!=0:
		var n:int=mini(pages.size(),buttons.size()-4)
		for i in n:LangExtension.try_signal(buttons[b+i],&"pressed",seek.bind(i));

func _prepared()->void:
	if features&0x02==0:
		if book==null and index>=0:
			GodotExtension.set_enabled(pages[index],false)

func _refreshed()->void:
	if features&0x05==0x04:
		var n:int=count()-1;var b:int=0
		GodotExtension.set_enabled(buttons[b],index>0);b+=1
		GodotExtension.set_enabled(buttons[b],index<n);b+=1
		GodotExtension.set_enabled(buttons[b],index>0);b+=1
		GodotExtension.set_enabled(buttons[b],index<n);b+=1

func _ready()->void:
	build()
	var f:int=features;features|=0x02
	seek(0)
	features=f
