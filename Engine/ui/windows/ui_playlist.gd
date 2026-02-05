## A playlist window for [Media].
class_name UIPlaylist extends UIPanel

@export_group("Playlist")
@export var media:Media
@export var model:Resource
@export var view:ItemList
@export var loop:Loop:
	set(x):if x!=loop:loop=x;_random.clear()
@export_flags(
	"Index",
	"Show",
	"Mode",
	"None",
	"Loop",
	"List",
	"Random",
)var features:int=-1
@export var icons:Dictionary[String,Resource]
@export var buttons:Array[Node]=[null,null,null,null,null,null]

var url:String:
	get():
		return _url
	set(x):
		if x==_url:return
		_url=x;play(x)

# List APIs

var _url:String
var _index:int=-1
var _slot:int=-1
var _random:Array[int]

func count()->int:
	if model!=null:return model.count()
	return 0

func clear()->void:
	if model!=null:if model.has_method(&"clear"):model.clear()
	_random.clear()
	refresh()

func peek(i:int)->String:
	var a:Array=LangExtension.k_empty_array
	if model is Album:a=model.paths
	elif model is ListModel:a=model.items
	else:return LangExtension.k_empty_string
	return a[i]

func push(i:int,s:String)->void:
	var a:Array=LangExtension.k_empty_array
	if model is Album:a=model.paths
	elif model is ListModel:a=model.items
	if i>=0 and i<a.size():a[i]=s

func play(f:String)->void:
	if model!=null and !f.is_empty():
		var n:int=count();model.set(&"value",f);
		var v:Variant=model.get(&"index");if v!=null:
			var i:int=v
			if i<0:if view!=null:blur();return
			if i>=n or n!=count():refresh()
			_selected(i);return
		else:
			blur()
	if media!=null:media.url=f;_url=f

func select(i:int)->void:
	var n:int=count();if n<=0:return
	i=(i+n)%n;_index=i
	if features&0x01!=0:set_config("Index",_index)
	#
	if model!=null and media!=null:
		if model is Album:media.album=model;media.emit(i)
		elif model is ListModel:media.url=model.items[i];model.set(&"index",i)
		_url=media.url
	if view!=null:
		view.select(i,true)

# Model APIs

func text(s:String)->String:
	return IOExtension.file_name(IOExtension.check_path(s))

func icon(s:String)->Resource:
	return icons.get(IOExtension.file_extension(s),null)

func tooltip(s:String)->String:
	return IOExtension.check_path(s)

# View APIs

func prev()->void:
	var n:int=count();_selected((_index-1+n)%n)

func next()->void:
	var n:int=count();_selected((_index+1)%n)

func toggle()->void:
	set_enabled(!_shown)
	if features&0x02!=0:set_config("Show",_shown)

func switch()->void:
	var n:int=Loop.Count
	for i in n:
		if features&(1<<((loop+i)%n+3))!=0:
			loop=i;break
	var b:Node=buttons[1];if b!=null:b.set(&"model",loop)
	if features&0x04!=0:set_config("Loop",loop)

func focus()->void:
	var s:String=url;model.set(&"value",s)
	var v:Variant=model.get(&"index")
	if v!=null:
		var m:Object=media;media=null
		select(v)
		media=m

func blur()->void:
	if view!=null:
		view.deselect_all()

func refresh()->void:
	if model==null or view==null:return
	view.clear();if count()<=0:return
	var a:Array=LangExtension.k_empty_array
	if model is Album:a=model.paths
	elif model is ListModel:a=model.items
	var s:String;var t:Texture
	var i:int=-1;for it in a:
		i+=1;s=text(it);t=icon(it)
		if t==null:view.add_item(s)
		else:view.add_icon_item(t);view.set_item_text(i,s)
		s=tooltip(it);if !s.is_empty():view.set_item_tooltip(i,s)

func menu(i:int)->void:
	match i:
		0:
			OS.shell_show_in_file_manager(peek(_slot))
		_:
			model.set(ListModel.k_operations[8+i-1],_slot);
			refresh();focus()
	_slot=-1

# Messages

func _clicked(i:int,p:Vector2,m:int)->void:
	if m==MouseButton.MOUSE_BUTTON_RIGHT:
		var b:Node=buttons[5];if b!=null:
			_slot=i;
			b.position=PointerInput.get_mouse_position(0)
			b.show()

func _selected(i:int)->void:
	_random.clear()
	select(i)

func _finished()->void:
	if media==null:return
	match loop:
		Loop.Loop:media.play()
		Loop.List:select(_index+1)
		Loop.Random:select(MathExtension.random_index(_random,_index,count()))

func _ready()->void:
	var b:Node;var i:int=0;var s:StringName=&"pressed"
	b=buttons[i];i+=1;if b!=null:b.connect(s,prev)
	b=buttons[i];i+=1;if b!=null:b.connect(s,next)
	b=buttons[i];i+=1;if b!=null:b.connect(s,toggle)
	b=buttons[i];i+=1;if b!=null:b.connect(s,switch)
	b=buttons[i];i+=1;if b!=null:b.connect(s,clear)
	b=buttons[i];i+=1;if b!=null:b.connect(&"id_pressed",menu)
	if features&0x01!=0:_index=get_config("Index",_index)
	if features&0x02!=0:set_enabled(get_config("Show",true))
	if features&0x04!=0:loop=get_config("Loop",loop)
	if view!=null:
		refresh()
		view.item_selected.connect(_selected)
		view.item_clicked.connect(_clicked)
	if media!=null:
		media.loop=false
		media.finished.connect(_finished)
	if model!=null:
		if _index>=0:select(_index)
		else:url=model.get(&"value")

enum Loop {
	None,
	Loop,
	List,
	Random,
	Count
}
