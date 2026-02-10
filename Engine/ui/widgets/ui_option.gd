## An option view for user selection.
class_name UIOption extends Node

static var s_options:Dictionary[StringName,Array]

@export_group("Option")
@export var path:String
@export var type:Variant.Type
@export var value:Variant:
	set(x):_on_changed(x);value=x
@export_group("UI")
@export var category:StringName
@export var container:Node
@export var prefab:Node

## See [signal Range.value_changed].
signal value_changed(v:Variant)

var _busy:bool
var _popup:PopupMenu
var _options:Array[Option]
var _views:Array[Node]

func reload()->void:
	_options.clear()
	if s_options.has(path):
		_options.append_array(s_options.get(path))
	else:
		Asset.load_array(_options,path,Option)

func find(v:Variant)->int:
	var i:int=-1;for it in _options:
		i+=1;if it!=null and it.value==v:return i
	return -1

func pressed(i:int)->bool:
	if _popup!=null:return _popup.is_item_checked(i)
	else:return _views[i].pressed

func view(i:int)->Node:
	var v:Node
	if i<_views.size():
		v=_views[i]
	elif prefab!=null:
		v=prefab.duplicate()
		container.add_child(v)
		v.connect(&"pressed",_on_selected.bind(i))
		_views.append(v)
	GodotExtension.set_enabled(v,true)
	return v

func menu(m:PopupMenu,o:Option,i=-1)->void:
	if m!=null and o!=null:
		var k:StringName=o.name
		if k.is_empty():
			m.add_separator(tr(o.tooltip,category))
		else:
			k=tr(k,category)
			if o.icon!=null:m.add_icon_item(o.icon,k,i)
			else:m.add_item(k,i)
			m.set_item_metadata(i,o.value)
			if !o.tooltip.is_empty():m.set_item_tooltip(i,tr(o.tooltip,category))

func render(n:Node,o:Option)->void:
	if n!=null and o!=null:
		n.set(&"text",tr(o.name,category))
		n.set(&"icon",o.icon)
		n.set(&"tooltip_text",tr(o.tooltip,category))
		n.set_meta(&"value",o.value)

func rebuild()->void:
	var b:bool=_busy;_busy=true
	_popup=null
	if container is OptionButton:_popup=container.get_popup()
	elif container is MenuButton:_popup=container.get_popup()
	elif container is PopupMenu:_popup=container
	if _popup!=null:
		LangExtension.add_signal(_popup,&"id_pressed",_on_selected)
		_popup.clear()
		var i:int=-1;for it in _options:
			i+=1;menu(_popup,it,i)
	else:
		var v:Node
		var i:int=-1;for it in _options:
			i+=1;v=view(i);render(v,it)
		for j in _views.size()-i-1:
			GodotExtension.set_enabled(_views[j],false)
	_busy=b

func refresh()->void:
	value=value

func _do_changed(v:Variant)->void:
	_value_changed(v)
	value_changed.emit(v)

func _on_changed(v:Variant)->void:
	if _busy:return
	_busy=true
	_do_changed(v)
	_busy=false

func _on_selected(i:int)->void:
	if _busy:return
	_busy=true
	var v:Variant=_index_selected(i)
	_do_changed(v);value=v
	_busy=false

func _index_selected(i:int)->Variant:
	LangExtension.throw_exception(self,LangExtension.e_not_implemented)
	return null

## See [method Range._value_changed].
func _value_changed(v:Variant)->void:
	LangExtension.throw_exception(self,LangExtension.e_not_implemented)

func _ready()->void:
	if type==0:type=typeof(value)
	if container==null and !self.is_class("Node"):container=self
	reload();rebuild();refresh()

class Option:
	var name:StringName
	var value:Variant
	var icon:Texture2D
	var tooltip:StringName

	func _set(k:StringName,v:Variant)->bool:
		match k:
			&"$icon":
				icon=IOExtension.load_asset(v)
				return true
			&"$value":
				value=str_to_var(v)
				return true
		return false
