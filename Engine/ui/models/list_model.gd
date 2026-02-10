## The list model that stores items.
class_name ListModel extends AbsModel

const k_operations:Array[StringName]=[
	&"length",
	&"is_empty",
	&"index",
	&"value",
	&"is_begin",
	&"not_begin",
	&"is_end",
	&"not_end",
	&"move_prev",
	&"move_next",
	&"move_first",
	&"move_last",
	&"delete"
]

@export_group("List")
@export var source:StringName
@export var destination:StringName
@export var items:Array
@export var property:StringName

signal index_changed(i:int)
signal value_changed(v:Variant)

var _index:int=-1

func clear()->void:
	items.clear();flush()

func index_of(k:StringName)->int:
	var n:int=k.length()
	if n>2 and k.begins_with("[") and k.ends_with("]"):
		return int(k.substr(1,n-2))
	return -1

func select(i:int)->void:
	_index=i
	var s:String=resource_name;if !s.is_empty():
		Application.get_config().set_value("ListModel",s,i);Application.try_flush()
	if i<0 or i>=items.size():return
	# Events
	var v:Variant=items[i]
	if _stub!=null and !_stub._busy:_stub.broadcast(property,v)
	index_changed.emit(i);value_changed.emit(v)

func flush()->void:
	if !destination.is_empty():
		IOExtension.save_json(JSON.from_native(items,true),destination)

func read(k:StringName,v:Variant=null)->Variant:
	var i:int=items.size()
	match k_operations.find(k):
		0:return i
		1:return i==0
		2:return _index
		3:if _index>=0 and _index<i:return items[_index]
		4:return i>0 and _index==0
		5:return i>0 and _index!=0
		6:return i>0 and _index==i-1
		7:return i>0 and _index!=i-1
	i=index_of(k)
	if i>=0:v=items[i]
	return v

func write(k:StringName,v:Variant)->void:
	var i:int=k_operations.find(k)
	match i:
		2:select(v);return
		3:i=items.find(v);if i>=0:select(i);return
		8:LangExtension.move_item(items,v,v-1);flush();return
		9:LangExtension.move_item(items,v,v+1);flush();return
		10:LangExtension.move_item(items,v,0);flush();return
		11:LangExtension.move_item(items,v,-1);flush();return
		12:items.remove_at(v);flush();return
		-1:pass
		_:return
	i=index_of(k)
	if i>=0:items[i]=v
	else:i=items.size();items.append(v)
	flush();select(i)

func init()->void:
	if _is_inited:return
	super.init()
	#
	var f:String=LangExtension.k_empty_string
	if FileAccess.file_exists(destination):f=destination
	else:f=source
	if FileAccess.file_exists(f):
		items=JSON.to_native(IOExtension.load_json(f),true)
	if _index<0:
		_index=Application.get_config().get_value("ListModel",resource_name,0)
	select(_index)

func count()->int:
	if !_is_inited:init()
	return items.size()

func prev()->void:
	if !_is_inited:init()
	var n:int=items.size()
	select((_index-1+n)%n)

func next()->void:
	if !_is_inited:init()
	var n:int=items.size()
	select((_index+1)%n)

func random()->void:
	if !_is_inited:init()
	var n:int=items.size()
	select(randi()%n)
